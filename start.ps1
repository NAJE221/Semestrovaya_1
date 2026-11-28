param([int]$Port = 0)

$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

function Save-Text($path, $text) {
    # UTF-8 without BOM
    [IO.File]::WriteAllText((Join-Path $PSScriptRoot $path), $text)
}
function Yaml($value) { "'" + $value.Replace("'", "''").Replace('$', '$$') + "'" }

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) { throw 'Docker is not installed.' }
cmd /c "docker info >nul 2>&1"
if ($LASTEXITCODE -ne 0) { throw 'Docker is not running. Start Docker Desktop.' }

if (Test-Path .docker) { Remove-Item .docker -Recurse -Force }
New-Item -ItemType Directory -Force .docker/db | Out-Null

# 1. Settings: make a copy adapted for Docker (the original is not changed)
$settings = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'MiniHttpServer/settings.json')) | ConvertFrom-Json
$server = $settings.ServerSettings
$database = $settings.DatabaseServerSettings
if (-not $server -or -not $database) { throw 'settings.json must contain ServerSettings and DatabaseServerSettings.' }

if ($Port -eq 0) { $Port = [int]$server.Port }
$dbName = [string]$database.DataBase
$dbUser = [string]$database.Username
$dbPass = [string]$database.Password
$path = ([string]$server.Path).Trim('/')
$url = "http://localhost:$Port/"
if ($path) { $url += "$path/" }

$server.Host = '+'          # listen on all interfaces inside the container
$server.Port = $Port
$database.Host = 'db'       # database container name
$database.Port = 5432
Save-Text '.docker/settings.json' ($settings | ConvertTo-Json -Depth 10)
$mounts = @("      - './.docker/settings.json:/app/settings.json:ro'")

# 2. SQL: scripts with CREATE TABLE run first, then data
$sql = @(Get-ChildItem db -Filter *.sql | Sort-Object @{ Expression = {
    if ([IO.File]::ReadAllText($_.FullName) -match 'CREATE\s+TABLE') { 0 } else { 1 } } }, Name)
if ($sql.Count -eq 0) { throw 'No .sql files in the db folder.' }
$i = 1
foreach ($f in $sql) {
    Save-Text (".docker/db/{0:D2}_{1}" -f $i, $f.Name) ([IO.File]::ReadAllText($f.FullName))
    $i++
}

# 3. Docker files
Save-Text 'Dockerfile' @'
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY . .
RUN dotnet publish MiniHttpServer/MiniHttpServer.csproj -c Release -o /app

FROM mcr.microsoft.com/dotnet/runtime:10.0
RUN apt-get update && apt-get install -y --no-install-recommends libgssapi-krb5-2 && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=build /app .
ENTRYPOINT ["dotnet", "MiniHttpServer.dll"]
'@

Save-Text '.dockerignore' @'
**/bin
**/obj
.git
.idea
.docker
db
tests
'@

$compose = @"
services:
  db:
    image: postgres:17
    environment:
      POSTGRES_DB: $(Yaml $dbName)
      POSTGRES_USER: $(Yaml $dbUser)
      POSTGRES_PASSWORD: $(Yaml $dbPass)
    volumes:
      - './.docker/db:/docker-entrypoint-initdb.d:ro'
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -h 127.0.0.1 -U `$`$POSTGRES_USER -d `$`$POSTGRES_DB"]
      interval: 3s
      retries: 30

  app:
    build: .
    stdin_open: true
    depends_on:
      db:
        condition: service_healthy
    ports:
      - "${Port}:${Port}"
    volumes:
$($mounts -join "`n")
"@
Save-Text 'docker-compose.yml' $compose

# 4. Run with a clean database
docker compose down -v
Write-Host "`nAfter startup open: $url  (stop: Ctrl+C)`n" -ForegroundColor Green
docker compose up --build
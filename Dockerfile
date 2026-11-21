# 1) Сборка: образ с .NET SDK компилирует проект
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY . .
RUN dotnet publish MiniHttpServer/MiniHttpServer.csproj -c Release -o /app/publish

# 2) Запуск: лёгкий образ, в него копируется только результат сборки
FROM mcr.microsoft.com/dotnet/runtime:10.0
WORKDIR /app
COPY --from=build /app/publish .
COPY MiniHttpServer/static ./static

EXPOSE 8080
ENTRYPOINT ["dotnet", "MiniHttpServer.dll"]

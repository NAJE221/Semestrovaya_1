# MiniHttpServer: запуск в Docker

## Что нужно
Windows и установленный **Docker Desktop** (он должен быть запущен). .NET и PostgreSQL устанавливать не нужно.

## Запуск
Откройте PowerShell в корне проекта (там, где `MiniHttpServer.sln`) и выполните:

```powershell
powershell -ExecutionPolicy Bypass -File .\start.ps1
```

Скрипт создаст Docker-файлы, поднимет базу, выполнит SQL-скрипты из `db` и запустит сервер.
Сайт: http://localhost:8080/hearthstone/ (адрес также выводится в консоли зелёной строкой). Первый запуск занимает несколько минут.

## Остановка
Нажмите `Ctrl+C`. Чтобы удалить контейнеры и данные:

```powershell
docker compose down -v
```

## Если не запускается
- `Docker is not running`: запустите Docker Desktop.
- `port is already allocated`: закройте программу, занимающую порт (например, сервер, запущенный в Rider).

Каждый запуск через `start.ps1` создаёт базу заново.
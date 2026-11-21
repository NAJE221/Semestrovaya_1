# Hearthstone Cards

Сайт-каталог карт Hearthstone на C# (.NET 10) и PostgreSQL.

## Запуск

Нужен только Docker. В папке с `docker-compose.yml` выполните:

```bash
docker compose up --build
```

Сайт: http://localhost:8080/hearthstone

При первом запуске база создаётся сама из `db/hearthstone_full.sql`.

## Остановка

```bash
docker compose down
```

Удалить базу (SQL выполнится заново при следующем запуске):

```bash
docker compose down -v
```

## Настройки

В Docker настройки берутся из `server.docker.json`. Имя базы, пользователь и пароль там должны совпадать с `docker-compose.yml`.

Без Docker используется `server.json`.


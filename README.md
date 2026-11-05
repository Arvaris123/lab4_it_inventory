# IT Inventory API — Лабораторна робота №4, варіант 47

Back-end на **Flask + SQLAlchemy + MySQL** для бази даних обліку ІТ-обладнання в офісах (`it_inventory`).

## Структура проєкту

```
config/app.yml            налаштування підключення до MySQL
my_project/
  __init__.py             create_app(): Flask, SQLAlchemy, обробка помилок
  auth/
    domain/               моделі таблиць + DTO (put_into_dto / create_from_dto)
    dao/                  робота з БД (find_all, find_by_id, create, update, patch, delete)
    service/              бізнес-логіка
    controller/           перетворення об'єктів у DTO, 404
    route/                HTTP-ендпоінти (Blueprint)
tests/                    тести
app.py                    точка запуску
data.sql                  скрипт створення та заповнення БД (з ЛР3)
postman_collection.json   колекція запитів для Postman
```

Потік запиту: **route → controller → service → dao → domain → MySQL**.

## Запуск

1. Виконати `data.sql` у MySQL Workbench (створить базу `it_inventory` з даними).
2. У `config/app.yml` вписати свій пароль MySQL.
3. Встановити залежності та запустити:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python3 app.py
```

API буде доступне на `http://127.0.0.1:5000`.

## Ендпоінти

Для кожної таблиці: `office`, `workplace`, `employee`, `manufacturer`, `equipment-type`, `equipment-model`, `computer-configuration`, `equipment`, `equipment-assignment`

| Метод | URL | Дія |
| --- | --- | --- |
| GET | `/office` | усі записи |
| GET | `/office/1` | один запис |
| POST | `/office` | створити |
| PUT | `/office/1` | повністю оновити |
| PATCH | `/office/1` | частково оновити |
| DELETE | `/office/1` | видалити |

Таблиця зв'язку M:M `employee-workplace` має складений ключ: `/employee-workplace/<employee_id>/<workplace_id>`.

**Зв'язки M:1**

| URL | Що повертає |
| --- | --- |
| `/office/<id>/workplaces` | робочі місця офісу |
| `/office/workplaces` | усі офіси з їхніми робочими місцями |
| `/office/<id>/equipment?status=На складі` | обладнання офісу (з фільтром за статусом) |
| `/manufacturer/<id>/models` | моделі виробника |
| `/equipment-type/<id>/models` | моделі типу обладнання |
| `/employee/<id>/assignments` | обладнання, видане працівнику |
| `/equipment/<id>/assignments` | історія видач обладнання |

**Зв'язки M:M (через `employee_workplace`)**

| URL | Що повертає |
| --- | --- |
| `/employee/<id>/workplaces` | робочі місця працівника |
| `/workplace/<id>/employees` | працівники на робочому місці |
| `/employee/workplaces` | усі працівники з їхніми робочими місцями |

## Тестування в Postman

Postman → **Import** → файл `postman_collection.json`. Запити згруповані за таблицями, плюс папки «Зв'язки M:1», «Зв'язки M:M» і «Пошук і помилки».

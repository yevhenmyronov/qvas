#!/usr/bin/env python3
"""Наповнює базу демо-застосунку даними під скріншоти.

Пише прямо в `qvas.sqlite`, витягнутий із `com.qvas.app.demo` — окремого
застосунку з debug-збірки. **Робочої бази це не торкається**: вона живе в
даних `com.qvas.app`, і `run-as` до неї доступу не має.

    python tool/seed_demo.py qvas.sqlite [uk|en]

Порядок цілком:
    adb exec-out run-as com.qvas.app.demo cat app_flutter/qvas.sqlite > qvas.sqlite
    python tool/seed_demo.py qvas.sqlite en
    adb push qvas.sqlite /data/local/tmp/
    adb shell run-as com.qvas.app.demo cp /data/local/tmp/qvas.sqlite app_flutter/

Персона — людина, яка веде облік акуратно: нотатки конкретні, а не
«витрати», категорії дібрані під власне життя, п'ятірка закріплена
вручну. Суми завжди кратні 100 мінорним одиницям: пад не має крапки,
тож копійок і центів у базі не буває.

Набори різняться не лише мовою нотаток, а й порядком сум: 95 ₴ за каву
й 5 $ за неї ж — це та сама кава, а не переклад числа. Вбудовані
категорії перекладаються самі, за `name_key`; свої — задані в наборі.
Мова застосунку перемикається тут же, через `locale_override`.

Числа фіксовані, не випадкові: скріншот має бути відтворюваним. Дати
рахуються від TODAY — щоб перезняти через місяць, досить змінити її.
"""
import sqlite3
import sys
import uuid
from datetime import date, datetime, timedelta, timezone

sys.stdout.reconfigure(encoding="utf-8")

# Сьогодні береться з годинника машини, а не з константи: інакше через
# добу верхня група стрічки стає «Учора» і знімок це показує.
# Відтворюваність від цього не страждає — усі записи задані зсувом у днях.
TODAY = date.today()

# Закріплена п'ятірка — однакова в обох наборах.
PINNED = ["cat.coffee", "cat.groceries", "cat.cafe", "cat.transport", "cat.car"]

UK = {
    "currency": "UAH",
    "locale": "uk",
    "custom": [("Підписки", "🔁", 18), ("Книги", "📖", 19)],
    # (днів тому, категорія, одиниць валюти, нотатка)
    "expenses": [
        (0, "cat.coffee", 95, "подвійне еспресо, дорогою на роботу"),
        (0, "cat.groceries", 840, "Сільпо: овочі, риба, олія"),
        (0, "cat.transport", 16, None),
        (1, "cat.coffee", 85, None),
        (1, "cat.cafe", 620, "обід з Олею"),
        (1, "Підписки", 199, "Spotify + iCloud 200 ГБ"),
        (2, "cat.car", 1840, "заправка до повного, 42 л"),
        (2, "cat.coffee", 95, "зерно Ethiopia на тиждень"),
        (2, "cat.pharmacy", 460, "вітамін D, магній"),
        (3, "cat.groceries", 1240, "закупка на тиждень"),
        (3, "cat.transport", 32, None),
        (3, "Книги", 480, "«Атомні звички», тверда"),
        (4, "cat.coffee", 85, None),
        (4, "cat.cafe", 340, "бізнес-ланч"),
        (4, "cat.entertainment", 560, "кіно, два квитки"),
        (5, "cat.utilities", 2180, "світло за липень"),
        (5, "cat.coffee", 95, None),
        (5, "cat.groceries", 620, "хліб, молоко, ягоди"),
        (6, "cat.sport", 1600, "абонемент, серпень"),
        (6, "cat.transport", 48, "таксі додому після дощу"),
        (7, "cat.coffee", 85, None),
        (7, "cat.beauty", 750, "стрижка"),
        (7, "cat.groceries", 980, None),
        (8, "cat.phone", 250, "тариф на місяць"),
        (8, "cat.coffee", 95, None),
        (8, "cat.cafe", 420, "сніданок на вихідних"),
        (9, "cat.gifts", 1200, "мамі на день народження"),
        (9, "cat.transport", 16, None),
        (10, "cat.groceries", 1460, "закупка на тиждень"),
        (10, "cat.coffee", 85, None),
        (10, "cat.pets", 640, "корм, 2 кг"),
        (11, "cat.education", 1800, "курс з фотографії, 2 з 6"),
        (11, "cat.coffee", 95, None),
        (12, "cat.cafe", 380, None),
        (12, "cat.transport", 32, None),
        (13, "cat.groceries", 720, "овочі на ринку"),
        (13, "cat.coffee", 85, None),
        (13, "Підписки", 99, "хмара для фото"),
        (14, "cat.home", 2400, "полиці й лампа в кабінет"),
        (14, "cat.coffee", 95, None),
        (15, "cat.groceries", 1180, None),
        (15, "cat.clothes", 1650, "кросівки на осінь"),
        (16, "cat.coffee", 85, None),
        (16, "cat.cafe", 540, "вечеря після виставки"),
        (16, "cat.transport", 16, None),
    ],
    "incomes": [
        (2, "cat.salary", 24000, "аванс за серпень"),
        (5, "cat.freelance", 12500, "лендінг для студії"),
        (12, "cat.cashback", 340, None),
        (16, "cat.sale", 2800, "продав старий монітор"),
    ],
}

EN = {
    "currency": "USD",
    "locale": "en",
    "custom": [("Subscriptions", "🔁", 18), ("Books", "📖", 19)],
    "expenses": [
        (0, "cat.coffee", 5, "double espresso on the way to work"),
        (0, "cat.groceries", 64, "greens, salmon, olive oil"),
        (0, "cat.transport", 3, None),
        (1, "cat.coffee", 5, None),
        (1, "cat.cafe", 38, "lunch with Ann"),
        (1, "Subscriptions", 20, "Spotify + iCloud 200 GB"),
        (2, "cat.car", 52, "full tank, 11 gal"),
        (2, "cat.coffee", 18, "Ethiopia beans for the week"),
        (2, "cat.pharmacy", 32, "vitamin D, magnesium"),
        (3, "cat.groceries", 96, "weekly run"),
        (3, "cat.transport", 6, None),
        (3, "Books", 28, "Atomic Habits, hardcover"),
        (4, "cat.coffee", 5, None),
        (4, "cat.cafe", 22, "business lunch"),
        (4, "cat.entertainment", 34, "movies, two tickets"),
        (5, "cat.utilities", 148, "electricity for July"),
        (5, "cat.coffee", 5, None),
        (5, "cat.groceries", 41, "bread, milk, berries"),
        (6, "cat.sport", 68, "gym, August"),
        (6, "cat.transport", 24, "cab home after the rain"),
        (7, "cat.coffee", 5, None),
        (7, "cat.beauty", 45, "haircut"),
        (7, "cat.groceries", 73, None),
        (8, "cat.phone", 35, "monthly plan"),
        (8, "cat.coffee", 5, None),
        (8, "cat.cafe", 27, "weekend breakfast"),
        (9, "cat.gifts", 80, "birthday gift for mom"),
        (9, "cat.transport", 3, None),
        (10, "cat.groceries", 112, "weekly run"),
        (10, "cat.coffee", 5, None),
        (10, "cat.pets", 42, "dry food, 4 lb"),
        (11, "cat.education", 120, "photography course, 2 of 6"),
        (11, "cat.coffee", 5, None),
        (12, "cat.cafe", 25, None),
        (12, "cat.transport", 6, None),
        (13, "cat.groceries", 48, "farmers market"),
        (13, "cat.coffee", 5, None),
        (13, "Subscriptions", 10, "cloud for photos"),
        (14, "cat.home", 165, "shelves and a desk lamp"),
        (14, "cat.coffee", 5, None),
        (15, "cat.groceries", 79, None),
        (15, "cat.clothes", 110, "sneakers for fall"),
        (16, "cat.coffee", 5, None),
        (16, "cat.cafe", 36, "dinner after the exhibition"),
        (16, "cat.transport", 3, None),
    ],
    "incomes": [
        (2, "cat.salary", 1600, "August advance"),
        (5, "cat.freelance", 850, "landing page for the studio"),
        (12, "cat.cashback", 23, None),
        (16, "cat.sale", 190, "sold my old monitor"),
    ],
}

SETS = {"uk": UK, "en": EN}


def seconds(dt):
    return int(dt.replace(tzinfo=timezone.utc).timestamp())


def main(path, which="uk"):
    data = SETS[which]
    db = sqlite3.connect(path)
    ids = {key: cid for key, cid in db.execute(
        "select name_key, id from categories where name_key is not null")}

    db.execute("delete from transactions")
    db.execute("delete from categories where is_built_in = 0")
    db.execute("delete from category_ranking_cache")

    created = seconds(datetime(2026, 5, 12, 9, 0))
    for name, emoji, order in data["custom"]:
        cid = str(uuid.uuid4())
        ids[name] = cid
        db.execute(
            "insert into categories (id, type, name_key, custom_name, emoji,"
            " is_built_in, is_pinned, is_archived, sort_order, created_at)"
            " values (?,'expense',NULL,?,?,0,0,0,?,?)",
            (cid, name, emoji, order, created))

    db.execute("update categories set is_pinned = 0")
    for key in PINNED:
        db.execute("update categories set is_pinned = 1 where name_key = ?", (key,))

    rows = ([(*e, "expense") for e in data["expenses"]]
            + [(*i, "income") for i in data["incomes"]])
    for ago, cat, major, note, kind in rows:
        day = TODAY - timedelta(days=ago)
        # Час дня рознесений, щоб порядок усередині дня був стабільний.
        stamp = datetime(day.year, day.month, day.day, 8 + (ago * 3) % 12,
                         (ago * 17) % 60)
        db.execute(
            "insert into transactions (id, type, amount_minor, category_id,"
            " currency_code, created_at_utc, local_date_key, note, deleted_at)"
            " values (?,?,?,?,?,?,?,?,NULL)",
            (str(uuid.uuid4()), kind, major * 100, ids[cat], data["currency"],
             seconds(stamp), day.isoformat(), note))

    # Стан застосунку: онбординг пройдено, підказки згоріли, банер бекапу
    # прибраний — усе це шари поверх екрана, яким на скріншоті не місце.
    db.execute(
        "update app_settings set currency_code = ?, locale_override = ?,"
        " onboarding_done = 1, hints_shown = 7, backup_banner_dismissed = 1,"
        " first_launch_at = ?, last_backup_at = ? where id = 1",
        (data["currency"], data["locale"],
         seconds(datetime(2026, 5, 12, 8, 30)),
         seconds(datetime(2026, 8, 16, 21, 10))))

    db.commit()
    spent = db.execute("select sum(amount_minor) from transactions"
                       " where type='expense'").fetchone()[0] // 100
    earned = db.execute("select sum(amount_minor) from transactions"
                        " where type='income'").fetchone()[0] // 100
    n = db.execute("select count(*) from transactions").fetchone()[0]
    print(f"[{which}] {n} записів; витрати {spent}, доходи {earned}, "
          f"різниця {earned - spent:+} {data['currency']}")


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "qvas.sqlite",
         sys.argv[2] if len(sys.argv) > 2 else "uk")

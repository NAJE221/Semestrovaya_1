BEGIN;

DROP TABLE IF EXISTS
    rarity_dust_costs, card_factions, card_keywords, card_spell_schools, card_tribes,
    cards, factions, keywords, spell_schools, tribes, rarities, card_types, classes,
    card_set_group_memberships, card_set_groups, card_sets
CASCADE;

-- ---------- Схема ----------

CREATE TABLE card_sets (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE card_set_groups (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) NOT NULL UNIQUE,
    parent_group_id BIGINT REFERENCES card_set_groups(id)
);

CREATE TABLE card_set_group_memberships (
    card_set_id BIGINT NOT NULL REFERENCES card_sets(id) ON DELETE CASCADE,
    group_id BIGINT NOT NULL REFERENCES card_set_groups(id) ON DELETE CASCADE,
    PRIMARY KEY (card_set_id, group_id)
);

CREATE TABLE classes (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    ornament_svg_path VARCHAR(500),
    slug VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE card_types (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE rarities (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE tribes (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE spell_schools (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE keywords (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    code VARCHAR(100) NOT NULL UNIQUE,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    slug VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE factions (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    code VARCHAR(100) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE cards (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    card_code VARCHAR(100) NOT NULL UNIQUE,
    slug VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    text TEXT,
    flavor_text TEXT,
    image TEXT,
    image_gold TEXT,
    crop_image TEXT,
    artist_name VARCHAR(255),
    mana_cost SMALLINT NOT NULL DEFAULT 0,
    attack SMALLINT,
    health SMALLINT,
    durability SMALLINT,
    overload SMALLINT,
    spell_damage SMALLINT,
    rune_cost JSONB,
    collectible BOOLEAN NOT NULL DEFAULT FALSE,
    card_set_id BIGINT REFERENCES card_sets(id),
    card_type_id BIGINT REFERENCES card_types(id),
    rarity_id BIGINT REFERENCES rarities(id),
    class_id BIGINT NOT NULL REFERENCES classes(id)
);

CREATE TABLE card_tribes (
    card_id BIGINT NOT NULL REFERENCES cards(id) ON DELETE CASCADE,
    tribe_id BIGINT NOT NULL REFERENCES tribes(id),
    PRIMARY KEY (card_id, tribe_id)
);

CREATE TABLE card_spell_schools (
    card_id BIGINT NOT NULL REFERENCES cards(id) ON DELETE CASCADE,
    spell_school_id BIGINT NOT NULL REFERENCES spell_schools(id),
    PRIMARY KEY (card_id, spell_school_id)
);

CREATE TABLE card_keywords (
    card_id BIGINT NOT NULL REFERENCES cards(id) ON DELETE CASCADE,
    keyword_id BIGINT NOT NULL REFERENCES keywords(id),
    parameter_value VARCHAR(100),
    PRIMARY KEY (card_id, keyword_id)
);

CREATE TABLE card_factions (
    card_id BIGINT NOT NULL REFERENCES cards(id) ON DELETE CASCADE,
    faction_id BIGINT NOT NULL REFERENCES factions(id),
    PRIMARY KEY (card_id, faction_id)
);

CREATE TABLE rarity_dust_costs (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    rarity_id BIGINT NOT NULL REFERENCES rarities(id),
    is_golden BOOLEAN NOT NULL DEFAULT FALSE,
    crafting_cost INTEGER NOT NULL,
    disenchant_cost INTEGER NOT NULL,
    UNIQUE (rarity_id, is_golden)
);

-- Индексы под фильтры страницы
CREATE INDEX idx_cards_class_id      ON cards (class_id);
CREATE INDEX idx_cards_card_set_id   ON cards (card_set_id);
CREATE INDEX idx_cards_card_type_id  ON cards (card_type_id);
CREATE INDEX idx_cards_rarity_id     ON cards (rarity_id);
CREATE INDEX idx_card_tribes_tribe   ON card_tribes (tribe_id);
CREATE INDEX idx_card_schools_school ON card_spell_schools (spell_school_id);
CREATE INDEX idx_card_keywords_kw    ON card_keywords (keyword_id);
CREATE INDEX idx_card_factions_fac   ON card_factions (faction_id);
CREATE INDEX idx_memberships_group   ON card_set_group_memberships (group_id);


-- ---------- Справочники ----------

INSERT INTO classes (name, ornament_svg_path, slug) VALUES
    ('Рыцарь смерти', 'death_knight.svg', 'death-knight'),
    ('Друид', 'druid.svg', 'druid'),
    ('Охотник', 'hunter.svg', 'hunter'),
    ('Маг', 'mage.svg', 'mage'),
    ('Паладин', 'paladin.svg', 'paladin'),
    ('Жрец', 'priest.svg', 'priest'),
    ('Разбойник', 'rogue.svg', 'rogue'),
    ('Шаман', 'shaman.svg', 'shaman'),
    ('Чернокнижник', 'warlock.svg', 'warlock'),
    ('Воин', 'warrior.svg', 'warrior'),
    ('Общие', 'general.svg', 'general'),
    ('Охотник на демонов', 'demon_hunter.svg', 'demon-hunter');

INSERT INTO card_types (name, slug) VALUES
    ('Локация', 'location'),
    ('Существо', 'minion'),
    ('Заклинание', 'spell'),
    ('Оружие', 'weapon');

INSERT INTO rarities (name, slug) VALUES
    ('Обычная', 'common'),
    ('Эпическая', 'epic'),
    ('Бесплатная', 'free'),
    ('Легендарная', 'legendary'),
    ('Редкая', 'rare');

INSERT INTO tribes (name, slug) VALUES
    ('Зверь', 'beast'),
    ('Демон', 'demon'),
    ('Дреней', 'draenei'),
    ('Дракон', 'dragon'),
    ('Элементаль', 'elemental'),
    ('Механизм', 'mech'),
    ('Мурлок', 'murloc'),
    ('Нага', 'naga'),
    ('Пират', 'pirate'),
    ('Свинобраз', 'quilboar'),
    ('Тотем', 'totem'),
    ('Нежить', 'undead');

INSERT INTO spell_schools (name, slug) VALUES
    ('Тайная магия', 'arcane'),
    ('Скверна', 'fel'),
    ('Огонь', 'fire'),
    ('Лёд', 'frost'),
    ('Свет', 'holy'),
    ('Природа', 'nature'),
    ('Тьма', 'shadow');

INSERT INTO keywords (code, name, description, slug) VALUES ( 'BATTLECRY', 'Боевой клич', 'Срабатывает при разыгрывании карты из руки.', 'battlecry'),
( 'CHARGE', 'Рывок', 'Может атаковать сразу после выхода на поле.', 'charge'),
( 'CHOOSE_ONE', 'Выберите эффект', 'При розыгрыше можно выбрать один из предложенных эффектов.', 'choose-one'),
( 'COLOSSAL', 'Колоссальный', 'При призыве создаёт дополнительные части, связанные с этим существом.', 'colossal'),
( 'COMBO', 'Серия приёмов', 'Дополнительный эффект, если в этом ходу ранее была разыграна другая карта.', 'combo'),
( 'DEATHRATTLE', 'Предсмертный хрип', 'Срабатывает, когда это существо уничтожено.', 'deathrattle'),
( 'DISCOVER', 'Раскопка', 'Позволяет выбрать одну карту из трёх предложенных.', 'discover'),
( 'DIVINE_SHIELD', 'Божественный щит', 'Первый полученный урон полностью предотвращается.', 'divine-shield'),
( 'ELUSIVE', 'Неуловимость', NULL, 'elusive'),
( 'ENRAGED', 'Бешенство', NULL, 'enrage'),
( 'FREEZE', 'Заморозка', 'Замороженный персонаж пропускает следующую возможность атаковать.', 'freeze'),
( 'GRIMY_GOONS', 'Ржавые бугаи', 'Фракция Ржавых бугаев из Злачного города Прибамбасска.', 'grimy-goons'),
( 'JADE_GOLEM', 'Нефритовый голем', 'Механика нефритовых големов: каждый следующий призванный голем становится сильнее.', 'jade-golem'),
( 'JADE_LOTUS', 'Нефритовый лотос', 'Фракция Нефритового лотоса из Злачного города Прибамбасска.', 'jade-lotus'),
( 'KABAL', 'Кабал', 'Фракция Кабала из Злачного города Прибамбасска.', 'kabal'),
( 'LIFESTEAL', 'Похищение жизни', 'Урон, нанесённый картой с этим свойством, восстанавливает здоровье вашему герою на то же значение.', 'lifesteal'),
( 'OUTCAST', 'Изгой', 'Дополнительный эффект, если карта находится на крайней левой или крайней правой позиции руки при розыгрыше.', 'outcast'),
( 'OVERLOAD', 'Перегрузка', 'Указанное количество кристаллов маны будет заблокировано на следующий ход.', 'overload'),
( 'POISONOUS', 'Яд', 'Уничтожает любое существо, которому наносит урон.', 'poisonous'),
( 'QUEST', 'Задание', 'Задание, которое продвигается при выполнении указанного условия и даёт награду после завершения.', 'quest'),
( 'REBORN', 'Перерождение', 'После первого уничтожения возвращается с 1 единицей здоровья.', 'reborn'),
( 'RUSH', 'Натиск', 'Может атаковать существ в ход выхода, но не может сразу атаковать героя.', 'rush'),
( 'SECRET', 'Секрет', 'Скрытое заклинание, которое автоматически срабатывает при выполнении условия.', 'secret'),
( 'SIDE_QUEST', 'Побочная задача', 'Побочное задание, которое даёт награду после выполнения условия.', 'sidequest'),
( 'SPELLPOWER', 'Урон от заклинаний', 'Увеличивает урон ваших заклинаний на указанное значение.', 'spell-damage'),
( 'START_OF_GAME_KEYWORD', 'Начало матча', 'Эффект срабатывает в начале матча.', 'start-of-game'),
( 'STEALTH', 'Маскировка', 'Не может быть выбрано целью атак или эффектов противника, пока не атакует.', 'stealth'),
( 'TAUNT', 'Провокация', 'Противник должен атаковать существ с «Провокацией», прежде чем атаковать других существ или героя.', 'taunt'),
( 'TRADEABLE', 'Можно обменять', 'Можно замешать в колоду и взять вместо неё другую карту, потратив 1 кристалл маны.', 'tradeable'),
( 'WINDFURY', 'Неистовство ветра', 'Может атаковать дважды за ход.', 'windfury');

INSERT INTO factions (code, name, slug) VALUES ( 'GRIMY_GOONS', 'Ржавые бугаи', 'goons'),
( 'JADE_LOTUS', 'Нефритовый лотос', 'jade-lotus'),
( 'KABAL', 'Кабал', 'kabal'),
( 'ZERG', 'Зерги', 'zerg'),
( 'TERRAN', 'Терраны', 'terran'),
( 'PROTOSS', 'Протоссы', 'protoss');

INSERT INTO card_set_groups (name, slug) VALUES
('Стандартные карты', 'standard'),
('Вольные наборы', 'wild'),
('Событие', 'event'),
('Основные наборы', 'core'),
('Прошлые наборы', 'past');

-- slug наборов совпадают со значениями data-value на странице
INSERT INTO card_sets (name, slug) VALUES
    ('Власть Тёмной Империи', 'dark-empire'),
    ('Катаклизм', 'cataclysm'),
    ('Основные наборы', 'core'),
    ('Объятия Изумрудного Сна', 'emerald-dream'),
    ('Событие', 'event'),
    ('Злачный город Прибамбасск', 'gangs'),
    ('Затерянный город Ун''Горо', 'lost-city-ungoro'),
    ('Сквозь потоки времени', 'across-the-timeways');

INSERT INTO card_set_group_memberships (card_set_id, group_id)
SELECT cs.id, g.id
FROM (VALUES
    ('dark-empire', 'standard'),
    ('cataclysm', 'standard'),
    ('core', 'standard'),
    ('core', 'core'),
    ('emerald-dream', 'standard'),
    ('event', 'standard'),
    ('event', 'event'),
    ('gangs', 'wild'),
    ('gangs', 'past'),
    ('lost-city-ungoro', 'standard'),
    ('across-the-timeways', 'standard')) AS m(set_slug, group_slug)
JOIN card_sets cs ON cs.slug = m.set_slug
JOIN card_set_groups g ON g.slug = m.group_slug;


-- 150 карт: русские тексты из локализованного набора, атрибуты сопоставлены по dbfId.

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('CFM_321', 'osvedomitel-iz-trushchob_CFM_321', 'Осведомитель из трущоб', '<b>Боевой клич:</b>
вы <b>раскапываете</b> карту охотника, паладина или воина.', '«Трущобы, говорите? Какие такие трущобы... Сто золотых?! Ах, э-э-эти трущобы...»', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/CFM_321.png', NULL, 'https://art.hearthstonejson.com/v1/512x/CFM_321.jpg', 'Anton Zemskov', 2, 2, 2, TRUE, (SELECT id FROM card_sets WHERE slug = 'gangs'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Редкая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Охотник'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('CFM_685', 'don-khan-cho_CFM_685', 'Дон Хан''Чо', '<b>Боевой клич:</b> случайное существо у вас в руке получает +5/+5.', 'Талантливый и хитроумный лидер «Ржавых Бугаев» Хан подумывает кинуть туповатого братца Чо. Но «разрыв» в его случае придется понимать буквально.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/CFM_685.png', NULL, 'https://art.hearthstonejson.com/v1/512x/CFM_685.jpg', 'Tyson Murphy', 5, 5, 5, TRUE, (SELECT id FROM card_sets WHERE slug = 'gangs'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Легендарная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Охотник'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('CFM_853', 'kontrabandistka_CFM_853', 'Контрабандистка', '<b>Боевой клич:</b> случайное существо у вас в руке получает +1/+1.', 'Говорят, она может достать даже карты еще не вышедших дополнений!', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/CFM_853.png', NULL, 'https://art.hearthstonejson.com/v1/512x/CFM_853.jpg', 'Sean McNally', 3, 2, 4, TRUE, (SELECT id FROM card_sets WHERE slug = 'gangs'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Обычная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Охотник'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('CFM_715', 'nefritovyy-dukh_CFM_715', 'Нефритовый дух', '<b>Боевой клич:</b> призывает <b>нефритового голема</b> {0}.', '«Како-ой миленький! Так бы и растащила по големам. Но сперва бы затискала!» — Айя Черная Лапа', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/CFM_715.png', NULL, 'https://art.hearthstonejson.com/v1/512x/CFM_715.jpg', 'Peter Stapleton', 4, 3, 3, TRUE, (SELECT id FROM card_sets WHERE slug = 'gangs'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Обычная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Друид'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('CFM_852', 'agenty-lotosa_CFM_852', 'Агенты «Лотоса»', '<b>Боевой клич:</b> вы <b>раскапываете</b> карту друида, разбойника или шамана.', 'Как правило, они просто стоят и круто смотрятся.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/CFM_852.png', NULL, 'https://art.hearthstonejson.com/v1/512x/CFM_852.jpg', 'Grace Liu', 3, 3, 3, TRUE, (SELECT id FROM card_sets WHERE slug = 'gangs'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Редкая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Друид'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('CFM_902', 'ayya-chernaya-lapa_CFM_902', 'Айя Черная Лапа', '[x]<b>Боевой клич
и предсмертный хрип:</b>
призывает <b>нефритового
голема</b> {0}.', 'Природное обаяние и смекалка помогли Айе возглавить «Лотос» после того, как его прежнего лидера совершенно случайно раздавил нефритовый голем.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/CFM_902.png', NULL, 'https://art.hearthstonejson.com/v1/512x/CFM_902.jpg', 'Glenn Rane', 6, 6, 3, TRUE, (SELECT id FROM card_sets WHERE slug = 'gangs'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Легендарная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Друид'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('CFM_619', 'khimik-kabala_CFM_619', 'Химик «Кабала»', '<b>Боевой клич:</b> вы кладете в руку случайное зелье.', '«Да, у меня есть зелье превращения. Но позволь предложить тебе вот это загадочное зелье. Оно может оказаться чем угодно, даже зельем превращения!»', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/CFM_619.png', NULL, 'https://art.hearthstonejson.com/v1/512x/CFM_619.jpg', 'Mike Azevedo', 4, 3, 3, TRUE, (SELECT id FROM card_sets WHERE slug = 'gangs'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Обычная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Маг'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('CFM_621', 'kazakus_CFM_621', 'Казакус', '<b>Боевой клич:</b> если в вашей колоде
нет одинаковых карт, создает
заклинание с выбранными
вами характеристиками.', 'Таинственный лидер «Кабала» НЕ ЯВЛЯЕТСЯ драконом и совершенно НЕПРИЧАСТЕН к незаконной торговле зельями. Любые заявления об обратном будут встречены судебными исками и зельями драконьего огня.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/CFM_621.png', NULL, 'https://art.hearthstonejson.com/v1/512x/CFM_621.jpg', 'Jomaro Kindred', 4, 3, 3, TRUE, (SELECT id FROM card_sets WHERE slug = 'gangs'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Легендарная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Маг'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('CFM_649', 'kurer-kabala_CFM_649', 'Курьер «Кабала»', '<b>Боевой клич:</b>
вы <b>раскапываете</b> карту мага, жреца или чернокнижника.', 'Припарковал кодо под гнездом гарпии — потом не жалуйся!', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/CFM_649.png', NULL, 'https://art.hearthstonejson.com/v1/512x/CFM_649.jpg', 'Arthur Bozonnet', 2, 2, 2, TRUE, (SELECT id FROM card_sets WHERE slug = 'gangs'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Редкая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Маг'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('CATA_432', 'khromatiy_CATA_432', 'Хроматий', '<b>Гигант +4</b>. <b>Провокация</b>. <b>Похищение жизни</b> <b>Неуловимость</b> <b>Божественный щит</b>', 'В нашей временной линии Нефарий так и не смог создать идеального дракона, объединив силу всех пяти родов. Но Дорнозму нашел измерение, где это произошло.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/CATA_432.png', NULL, 'https://art.hearthstonejson.com/v1/512x/CATA_432.jpg', 'Timur Shevtsov', 8, 8, 8, TRUE, (SELECT id FROM card_sets WHERE slug = 'cataclysm'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Легендарная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Паладин'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('CORE_RLK_657', 'podzemnyy-korol_CORE_RLK_657', 'Подземный король', '<b>Натиск</b>. <b>Боевой клич и предсмертный хрип:</b>& ваш герой получает +6 к броне.', 'Узрите, подземный король! Я всегда внизу – и нет того, что было бы ниже моего достоинства! Я объявляю войну миру и счастью! Скоро все будут дрожать предо мной!', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/CORE_RLK_657.png', NULL, 'https://art.hearthstonejson.com/v1/512x/CORE_RLK_657.jpg', 'L. Lullabi & K. Turovec', 7, 6, 6, TRUE, (SELECT id FROM card_sets WHERE slug = 'core'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Эпическая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Друид'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('FIR_924', 'lovchiy-plameni-tmy_FIR_924', 'Ловчий пламени Тьмы', '<b>Боевой клич:</b>& вы <b>раскапываете</b> демона с <b>«Темным даром»</b> и получаете его копию.', 'Фиолетовый — для скрытности. Вот такой незаметный огонь.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/FIR_924.png', NULL, 'https://art.hearthstonejson.com/v1/512x/FIR_924.jpg', 'Ivo Campelo da Silva', 4, 4, 3, TRUE, (SELECT id FROM card_sets WHERE slug = 'emerald-dream'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Обычная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Чернокнижник'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('BE_207', 'nestabilnyy-prototip_BE_207', 'Нестабильный прототип', '<b>Перерождение</b> <b>Предсмертный хрип:</b>& существа у вас в руке получают +1 к атаке.', 'Тут сразу видно — боль в животе.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/BE_207.png', NULL, 'https://art.hearthstonejson.com/v1/512x/BE_207.jpg', 'Matt Dixon', 1, 0, 1, TRUE, (SELECT id FROM card_sets WHERE slug = 'dark-empire'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Редкая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Общие'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('CORE_AT_052', 'totemnyy-golem_CORE_AT_052', 'Тотемный голем', '<b>Перегрузка:</b> (1)', 'Вот что получится, если слепить воедино несколько тотемов.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/CORE_AT_052.png', NULL, 'https://art.hearthstonejson.com/v1/512x/CORE_AT_052.jpg', 'Steve Prescott', 2, 3, 4, TRUE, (SELECT id FROM card_sets WHERE slug = 'core'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Обычная'), NULL, 1, NULL, NULL, (SELECT id FROM classes WHERE name = 'Шаман'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('EDR_493', 'alara-shi_EDR_493', 'Алара''ши', '[x]<b>Боевой клич:</b> превращает
 существ у вас в руке в случайных
 демонов. <i>(Изначальные
 характеристики и стоимость
существ сохраняются.)</I>', 'Это птица? Это самолет? Медведь? Ловец Скверны? Страж ужаса? Бес?..', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/EDR_493.png', NULL, 'https://art.hearthstonejson.com/v1/512x/EDR_493.jpg', 'Jakub Kasper', 5, 5, 5, TRUE, (SELECT id FROM card_sets WHERE slug = 'emerald-dream'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Легендарная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Охотник на демонов'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('RLK_708', 'zamerzshiy-baron_RLK_708', 'Замерзший барон', '<b>Боевой клич и
 предсмертный хрип:</b>&
вы берете карту.', 'Он не любит, когда температуру -30 называют холодной.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/RLK_708.png', NULL, 'https://art.hearthstonejson.com/v1/512x/RLK_708.jpg', 'Greg Staples', 3, 2, 2, TRUE, (SELECT id FROM card_sets WHERE slug = 'core'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Обычная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Рыцарь смерти'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('TLC_522', 'nezrimyy-opu_TLC_522', 'Незримый Опу', '[x]<b><b>Маскировка</b></b>
<b>Боевой клич, cерия приемов
и предсмертный хрип:</b>&
     применяет «Веер клинков».  ', 'Мы только предполагаем, что Опу так выглядит. Обновим картинку, если когда-нибудь его увидим.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/TLC_522.png', NULL, 'https://art.hearthstonejson.com/v1/512x/TLC_522.jpg', 'Timur Shevtsov', 6, 6, 4, TRUE, (SELECT id FROM card_sets WHERE slug = 'lost-city-ungoro'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Легендарная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Разбойник'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('TIME_890', 'mediv-osvyashchennyy_TIME_890', 'Медив Освященный', '<b>Герой саги</b>. Если вы контролируете Каражан, стоит (0).
<b>Боевой клич:</b> применяет к остальным существам <b>«Немоту»</b> и уничтожает их.', 'В нашей временной линии Медив убеждает себя, что он не мог воспротивиться темному влиянию Саргераса. Но есть временная линия, в которой ему это удалось.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/TIME_890.png', NULL, 'https://art.hearthstonejson.com/v1/512x/TIME_890.jpg', 'Sergey Tsvelykh', 10, 7, 7, TRUE, (SELECT id FROM card_sets WHERE slug = 'across-the-timeways'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Легендарная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Жрец'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('EDR_480', 'goldrinn_EDR_480', 'Голдринн', '<b>Натиск</b>. Ваши звери наносят двойной урон.', 'Этого свирепого хищника знают многие. Ло''гош и Великий волк — лишь некоторые из имен, данных ему разными народами.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/EDR_480.png', NULL, 'https://art.hearthstonejson.com/v1/512x/EDR_480.jpg', 'Eva Widermann', 9, 9, 9, TRUE, (SELECT id FROM card_sets WHERE slug = 'emerald-dream'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Легендарная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Охотник'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('END_024', 'plamya-beskonechnosti_END_024', 'Пламя Бесконечности', '[x]<b>Секрет:</b> когда ход вашего
противника заканчивается,
наносит БЕСКОНЕЧНЫЙ урон
его существу с самым
высоким здоровьем.', 'Эта карта позволяет сверхурону заиграть новыми красками.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/END_024.png', NULL, 'https://art.hearthstonejson.com/v1/512x/END_024.jpg', 'Studio Hive', 3, NULL, NULL, TRUE, (SELECT id FROM card_sets WHERE slug = 'across-the-timeways'), (SELECT id FROM card_types WHERE name = 'Заклинание'), (SELECT id FROM rarities WHERE name = 'Обычная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Маг'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('EDR_570', 'zloveshchie-koshmary_EDR_570', 'Зловещие кошмары', '[x]<b>Выберите эффект:</b>
наносит $1 ед. урона
всем существам или
дает существу с неполным
здоровьем +2/+2.', 'Все говорят о каком-то «кошмаре», но я не вижу здесь ничего особенного.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/EDR_570.png', NULL, 'https://art.hearthstonejson.com/v1/512x/EDR_570.jpg', 'Jakub Kasper', 1, NULL, NULL, TRUE, (SELECT id FROM card_sets WHERE slug = 'emerald-dream'), (SELECT id FROM card_types WHERE name = 'Заклинание'), (SELECT id FROM rarities WHERE name = 'Обычная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Воин'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('TLC_451', 'proklyatye-katakomby_TLC_451', 'Проклятые катакомбы', '[x]Вы <b>раскапываете</b> другую
карту из вашей колоды.
  Она становится <b>временной</b>. ', 'Это существо теперь проклято навеки. Временно.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/TLC_451.png', NULL, 'https://art.hearthstonejson.com/v1/512x/TLC_451.jpg', 'BOSi Studio', 0, NULL, NULL, TRUE, (SELECT id FROM card_sets WHERE slug = 'lost-city-ungoro'), (SELECT id FROM card_types WHERE name = 'Заклинание'), (SELECT id FROM rarities WHERE name = 'Эпическая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Чернокнижник'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('CATA_180', 'voin-lok_CATA_180', 'Воин''лок', '<b>Боевой клич:</b> ваш следующий мурлок за (3) или меньше расходует здоровье,
а не ману.', 'Твои мрррглы будут моими!!!', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/CATA_180.png', NULL, 'https://art.hearthstonejson.com/v1/512x/CATA_180.jpg', 'Max Grecke', 2, 1, 1, TRUE, (SELECT id FROM card_sets WHERE slug = 'cataclysm'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Эпическая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Общие'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('BE_784', 'i-sharadzh-groza-titanov_BE_784', 'И''Шарадж, Гроза Титанов', '<b>Древний бог.</b> <b>Боевой клич:</b>
если вы потратили 30 ед. маны на существ за этот матч, получает <b>неуязвимость</b> на 1 ход. <i>(Еще {0}!)</i>@<b>Древний бог.</b> <b>Боевой клич:</b>
если вы потратили 30 ед. маны на существ за этот матч, получает <b>неуязвимость</b> на 1 ход. <i>(Готово!)</i>@<b>Древний бог.</b> <b>Боевой клич:</b>
если вы потратили 30 ед. маны на существ за этот матч, получает <b>неуязвимость</b> на 1 ход.', '«Громадный Скользящий» + «Кронн Пронзатель» + («Мать-Земля Теразан» - «Нептулон, Владыка Приливов»)', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/BE_784.png', NULL, 'https://art.hearthstonejson.com/v1/512x/BE_784.jpg', 'Mooncolony', 9, 10, 10, TRUE, (SELECT id FROM card_sets WHERE slug = 'dark-empire'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Легендарная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Общие'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('TIME_020', 'broksigar_TIME_020', 'Броксигар', '[x]<b>Герой саги. Рывок</b>.
<b>Начало матча:</b> исчезает.
Убейте всех 4 демонов с Аргуса,
чтобы он снова появился
в вашей руке.', 'Подвиг Броксигара — ранить самого Саргераса в отчаянной битве — остается величайшим достижением героев-орков.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/TIME_020.png', NULL, 'https://art.hearthstonejson.com/v1/512x/TIME_020.jpg', 'Luca Zontini', 2, 12, 12, TRUE, (SELECT id FROM card_sets WHERE slug = 'across-the-timeways'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Легендарная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Охотник на демонов'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('CORE_CS2_024', 'ledyanaya-strela_CORE_CS2_024', 'Ледяная стрела', 'Наносит $3 ед. урона цели и <b>замораживает</b> ее.', 'Разыгрывая эту карту, не стесняйтесь кричать: «Остудись!», «Застынь!» или даже «Мороз и солнце, день чудесный!»', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/CORE_CS2_024.png', NULL, 'https://art.hearthstonejson.com/v1/512x/CORE_CS2_024.jpg', 'Steve Ellis', 2, NULL, NULL, TRUE, (SELECT id FROM card_sets WHERE slug = 'core'), (SELECT id FROM card_types WHERE name = 'Заклинание'), (SELECT id FROM rarities WHERE name = 'Обычная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Маг'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('TLC_EVENT_400', 'shturm-vorot_TLC_EVENT_400', 'Штурм ворот', '[x]<b>Побочная задача:</b>
разыграйте 3 существ
типа «Нежить» или зверей.
<b>Награда:</b> создает зомбозверя.
Он стоит на (3) меньше.', 'Удачи в штурме затерянного города!', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/TLC_EVENT_400.png', NULL, 'https://art.hearthstonejson.com/v1/512x/TLC_EVENT_400.jpg', 'James Ryman', 1, NULL, NULL, TRUE, (SELECT id FROM card_sets WHERE slug = 'event'), (SELECT id FROM card_types WHERE name = 'Заклинание'), (SELECT id FROM rarities WHERE name = 'Эпическая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Общие'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('CATA_EVENT_401', 'geomant-prokhodchik_CATA_EVENT_401', 'Геомант-проходчик', '<b>Подготовка</b>
<b>Урон от заклинаний +1</b>', 'Я ВИЖУ СВЕТ! А, это просто свеча...', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/CATA_EVENT_401.png', NULL, 'https://art.hearthstonejson.com/v1/512x/CATA_EVENT_401.jpg', 'Patrik Bjorkstrom', 3, 2, 3, TRUE, (SELECT id FROM card_sets WHERE slug = 'event'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Эпическая'), NULL, NULL, 1, NULL, (SELECT id FROM classes WHERE name = 'Общие'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('BE_733', 'molotoboets-titanov_BE_733', 'Молотобоец титанов', '<b>Натиск</b>
<b>Неистовство ветра</b>
Стоит на (1) меньше за каждое существо противника.', 'Чувствую себя королем!', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/BE_733.png', NULL, 'https://art.hearthstonejson.com/v1/512x/BE_733.jpg', 'Jakub Kasper', 8, 6, 6, TRUE, (SELECT id FROM card_sets WHERE slug = 'dark-empire'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Обычная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Общие'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('TLC_446', 'pobeg-iz-nizhepadi_TLC_446', 'Побег из Нижепади', '[x]<b>Задача:</b> разыграйте
6 <b>временных</b> карт.
<b>Награда:</b> «Разлом
в Нижепадь».', 'День 7. Ужасный день! Земля разверзлась у нас под ногами, и мы упали кверху панцирем прямо в проклятый разлом! Скверна притупила мое чутье, и тут из тумана на нас напали демонические твари. Нам удалось сбежать лишь благодаря Умбре, защитившей нас с помощью своей магии.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/TLC_446.png', NULL, 'https://art.hearthstonejson.com/v1/512x/TLC_446.jpg', 'Edgar Hidalgo', 1, NULL, NULL, TRUE, (SELECT id FROM card_sets WHERE slug = 'lost-city-ungoro'), (SELECT id FROM card_types WHERE name = 'Заклинание'), (SELECT id FROM rarities WHERE name = 'Легендарная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Чернокнижник'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('CATA_302', 'izlechenie_CATA_302', 'Излечение', '[x]Восполняет существу
полный запас здоровья.
Вы берете карту.', 'С тобой все в порядке... все хорошо, маме ничего не рассказывай.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/CATA_302.png', NULL, 'https://art.hearthstonejson.com/v1/512x/CATA_302.jpg', 'Ivan Fomin', 1, NULL, NULL, TRUE, (SELECT id FROM card_sets WHERE slug = 'cataclysm'), (SELECT id FROM card_types WHERE name = 'Заклинание'), (SELECT id FROM rarities WHERE name = 'Обычная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Жрец'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('BE_EVENT_101', 'pribytie-titanov_BE_EVENT_101', 'Прибытие титанов', '[x]Вы берете 2 заклинания.
Восстанавливает 6 кристаллов
маны. До конца хода вы можете
разыгрывать только заклинания.', '«Эй, зацените! Тут кое-кто проиграл пять игр подряд!»', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/BE_EVENT_101.png', NULL, 'https://art.hearthstonejson.com/v1/512x/BE_EVENT_101.jpg', 'Mooncolony', 6, NULL, NULL, TRUE, (SELECT id FROM card_sets WHERE slug = 'event'), (SELECT id FROM card_types WHERE name = 'Заклинание'), (SELECT id FROM rarities WHERE name = 'Эпическая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Маг'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('MEND_305', 'zabota-o-prirode_MEND_305', 'Забота о природе', 'Выбранное существо и все его копии получают +1/+2
<i>(где бы они ни были)</i>.', 'Что получило усиление раньше — курица или яйцо?', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/MEND_305.png', NULL, 'https://art.hearthstonejson.com/v1/512x/MEND_305.jpg', 'Brian Despain', 2, NULL, NULL, TRUE, (SELECT id FROM card_sets WHERE slug = 'cataclysm'), (SELECT id FROM card_types WHERE name = 'Заклинание'), (SELECT id FROM rarities WHERE name = 'Редкая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Охотник'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('DINO_136', 'rog-pirshestva_DINO_136', 'Рог пиршества', '[x]Призывает трех ящеров
2/1 с <b>«Натиском»</b>.
 <b>Изгой:</b> они получают
<b>«Неуязвимость»</b> во время
атаки на этом ходу.', 'Эта говядина настолько сырая, что я слышу ее мычание!', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/DINO_136.png', NULL, 'https://art.hearthstonejson.com/v1/512x/DINO_136.jpg', 'Ramzy Kamen', 4, NULL, NULL, TRUE, (SELECT id FROM card_sets WHERE slug = 'lost-city-ungoro'), (SELECT id FROM card_types WHERE name = 'Заклинание'), (SELECT id FROM rarities WHERE name = 'Обычная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Охотник на демонов'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('BE_193', 'gazovyy-skat_BE_193', 'Газовый скат', '<b>Яд</b>', 'Не кормите его бобовыми.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/BE_193.png', NULL, 'https://art.hearthstonejson.com/v1/512x/BE_193.jpg', 'Slawomir Maniak', 1, 1, 2, TRUE, (SELECT id FROM card_sets WHERE slug = 'dark-empire'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Обычная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Общие'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('TIME_713', 'khronoadmiral-kryukokhvost_TIME_713', 'Хроноадмирал Крюкохвост', '<b>Боевой клич:</b>
призывает сундук 0/8
на сторону противника. <i>В нем КУЧА монеток!</i>', 'Любимое упражнение дракона-пирата — открывание сундуков с сокровищами.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/TIME_713.png', NULL, 'https://art.hearthstonejson.com/v1/512x/TIME_713.jpg', 'Ivan Fomin', 5, 4, 6, TRUE, (SELECT id FROM card_sets WHERE slug = 'across-the-timeways'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Легендарная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Разбойник'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('CORE_OG_218', 'khrabrets-krovavogo-kopyta_CORE_OG_218', 'Храбрец Кровавого Копыта', '<b>Провокация</b>
+3 к атаке,
если у этого существа неполное здоровье.', 'Ему послышалось, что дополнение будет называться «Угощение в деревне быков», и только поэтому он записался в добровольцы. Бедняге явно стоит проверить слух.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/CORE_OG_218.png', NULL, 'https://art.hearthstonejson.com/v1/512x/CORE_OG_218.jpg', 'Paul Mafayon', 4, 2, 6, TRUE, (SELECT id FROM card_sets WHERE slug = 'core'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Обычная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Воин'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('CATA_151', 'azshara-vladychitsa-okeana_CATA_151', 'Азшара, владычица океана', '[x]<b>Гигант +2</b>
Ваш герой получает
<b>  «Неистовство ветра»</b>.', 'Азшара не желала признавать чье-либо превосходство — даже в случае Смертокрыла. Но вот заключить сделку, это другое дело.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/CATA_151.png', NULL, 'https://art.hearthstonejson.com/v1/512x/CATA_151.jpg', 'James Ryman', 8, 8, 8, TRUE, (SELECT id FROM card_sets WHERE slug = 'cataclysm'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Легендарная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Охотник на демонов'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('TLC_255', 'khranitel-kristalla_TLC_255', 'Хранитель кристалла', '[x]<b>Можно обменять</b>. <b>Боевой клич:</b>
вы получаете пустые кристаллы
маны до тех пор, пока у обоих
игроков не будет одинаковое
количество маны.', '«Руки прочь! А то отпечатки останутся!»', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/TLC_255.png', NULL, 'https://art.hearthstonejson.com/v1/512x/TLC_255.jpg', 'Edgar Hidalgo', 2, 2, 2, TRUE, (SELECT id FROM card_sets WHERE slug = 'lost-city-ungoro'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Эпическая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Общие'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('CORE_GIL_534', 'bandyuga_CORE_GIL_534', 'Бандюга', 'Получает +1/+1, после того как ваш герой атакует.', '«НАШИ БЬЮТ!»', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/CORE_GIL_534.png', NULL, 'https://art.hearthstonejson.com/v1/512x/CORE_GIL_534.jpg', 'A. J. Nazzaro', 3, 3, 3, TRUE, (SELECT id FROM card_sets WHERE slug = 'core'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Обычная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Общие'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('CATA_EVENT_400', 'tyuremnaya-torgovka_CATA_EVENT_400', 'Тюремная торговка', '<b>Подготовка</b>. <b>Боевой клич:</b> расходует всю вашу ману. Призывает случайное существо за ту же ману.', 'Болит голова? У тюремной торговки есть лекарство. Вот, синее.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/CATA_EVENT_400.png', NULL, 'https://art.hearthstonejson.com/v1/512x/CATA_EVENT_400.jpg', 'Jason Kang', 3, 4, 3, TRUE, (SELECT id FROM card_sets WHERE slug = 'event'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Эпическая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Друид'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('TIME_006', 'zerkalnoe-izmerenie_TIME_006', 'Зеркальное измерение', 'Призывает существо
0/4 с <b>«Провокацией»</b>.
Если у вас в руке есть дракон, призывает еще одно.', 'Также призывает двух существ 4/0.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/TIME_006.png', NULL, 'https://art.hearthstonejson.com/v1/512x/TIME_006.jpg', 'Kevin Sidharta', 1, NULL, NULL, TRUE, (SELECT id FROM card_sets WHERE slug = 'across-the-timeways'), (SELECT id FROM card_types WHERE name = 'Заклинание'), (SELECT id FROM rarities WHERE name = 'Обычная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Маг'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('BE_013', 'k-tun-oko-imperii_BE_013', 'К''Тун, Око Империи', '[x]<b>Древний бог.</b> Если вы активировали
все 4 способности К''Туна в этом
матче, эффекты способностей
этого существа усиливаются
в четыре раза.', '«Амитут, хранитель Амитус»/2 + (2*«Инкубация»)/2 + («Непостижимый»/3)', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/BE_013.png', NULL, 'https://art.hearthstonejson.com/v1/512x/BE_013.jpg', 'Kevin Sidharta', 10, 12, 12, TRUE, (SELECT id FROM card_sets WHERE slug = 'dark-empire'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Легендарная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Общие'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('EDR_518', 'ozhivshiy-sad_EDR_518', 'Оживший сад', '<b>Боевой клич:</b> <b>заряжает</b> вашу силу героя. Уменьшает стоимость существа
у вас в руке на (1).', 'Луга, небосклоны, сады, дальше что?', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/EDR_518.png', NULL, 'https://art.hearthstonejson.com/v1/512x/EDR_518.jpg', 'L. Lullabi & R. Kamen', 3, 2, 4, TRUE, (SELECT id FROM card_sets WHERE slug = 'emerald-dream'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Редкая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Шаман'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('BE_EVENT_102', 'temnoe-terraformirovanie_BE_EVENT_102', 'Темное терраформирование', '[x]Наносит существу $5
ед. урона. Затем поражает
соседние цели, нанося
на 1 ед. урона меньше.', 'Хм, кажется, тут чего-то не хватает... Нужен еще один обелиск вон в том углу.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/BE_EVENT_102.png', NULL, 'https://art.hearthstonejson.com/v1/512x/BE_EVENT_102.jpg', 'Ian Ameling', 5, NULL, NULL, TRUE, (SELECT id FROM card_sets WHERE slug = 'event'), (SELECT id FROM card_types WHERE name = 'Заклинание'), (SELECT id FROM rarities WHERE name = 'Эпическая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Жрец'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('TIME_019', 'ozhivshie-potoki-vremeni_TIME_019', 'Ожившие потоки времени', '<b>Боевой клич:</b> если
у вас есть активная аура,& наносит противникам
3 ед. урона.', 'Подождите, сейчас активирую ауру.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/TIME_019.png', NULL, 'https://art.hearthstonejson.com/v1/512x/TIME_019.jpg', 'Daniil Kudriavtsev', 4, 3, 3, TRUE, (SELECT id FROM card_sets WHERE slug = 'across-the-timeways'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Редкая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Паладин'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('CATA_490', 'okulyarnyy-okkultist_CATA_490', 'Окулярный оккультист', '<b>Провокация</b>
 <b>Боевой клич:</b> вы выбираете и сбрасываете карту в руке.', 'Что лучше сбросить? Номер 1 или номер 2? Или все же номер 1? И номер 2.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/CATA_490.png', NULL, 'https://art.hearthstonejson.com/v1/512x/CATA_490.jpg', 'James Ryman', 3, 3, 6, TRUE, (SELECT id FROM card_sets WHERE slug = 'cataclysm'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Обычная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Чернокнижник'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('BE_204', 'gromadnyy-skolzyashchiy_BE_204', 'Громадный Скользящий', '[x]<b>Провокация</b>
<b>Боевой клич:</b>& вы
выбираете и применяете
способность К''Туна.', 'Двадцать каменных великанов отправились на бой с Согготом Скользящим. Только Кронн, величайший из них,', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/BE_204.png', NULL, 'https://art.hearthstonejson.com/v1/512x/BE_204.jpg', 'Ian Ameling', 6, 6, 7, TRUE, (SELECT id FROM card_sets WHERE slug = 'dark-empire'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Обычная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Общие'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('FIR_954', 'podzhiganie_FIR_954', 'Поджигание', '[x]Наносит существу
$5 ед. урона. Его владелец
берет карту.', 'Из пепла восстанет новая карта.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/FIR_954.png', NULL, 'https://art.hearthstonejson.com/v1/512x/FIR_954.jpg', 'Vlad Botos', 1, NULL, NULL, TRUE, (SELECT id FROM card_sets WHERE slug = 'emerald-dream'), (SELECT id FROM card_types WHERE name = 'Заклинание'), (SELECT id FROM rarities WHERE name = 'Редкая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Чернокнижник'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('TLC_836', 'niri-iz-kratera_TLC_836', 'Нири из кратера', '[x]Когда вы разыгрываете
существо за (1), его характеристики
удваиваются.  Когда вы
применяете заклинание за (1),
оно срабатывает дважды.', 'Прекрасно умеет раскачиваться на лианах, а вот деревья огибает плоховато.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/TLC_836.png', NULL, 'https://art.hearthstonejson.com/v1/512x/TLC_836.jpg', 'Anzka Nguyen', 3, 2, 5, TRUE, (SELECT id FROM card_sets WHERE slug = 'lost-city-ungoro'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Легендарная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Охотник'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('EDR_950', 'zorkaya-dozornaya_EDR_950', 'Зоркая дозорная', '<b>Боевой клич:</b> Вы берете карту. Она стоит на (1) меньше до конца хода. <i>(Сейчас назову!)</i>', '«Это птица! Или не птица? Нет, это все-таки птица!»', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/EDR_950.png', NULL, 'https://art.hearthstonejson.com/v1/512x/EDR_950.jpg', 'Mooncolony', 3, 2, 3, TRUE, (SELECT id FROM card_sets WHERE slug = 'event'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Эпическая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Общие'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('CORE_KAR_057', 'belyy-kon_CORE_KAR_057', 'Белый конь', '<b>Боевой клич:</b> вы <b>раскапываете</b> заклинание. Ваш герой восстанавливает здоровье в размере его стоимости.', 'На самом деле им управляет рыцарь.<i></i>', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/CORE_KAR_057.png', NULL, 'https://art.hearthstonejson.com/v1/512x/CORE_KAR_057.jpg', 'Zoltan Boros', 4, 4, 4, TRUE, (SELECT id FROM card_sets WHERE slug = 'core'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Редкая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Паладин'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('EDR_818', 'nizendra_EDR_818', 'Низендра', '<b>Провокация</b>. <b>Предсмертный хрип:</b> разделяется на жуков 1/1. В начале вашего хода собирается обратно из оставшихся.', 'Отчет о баге: существа разделяются на жуков 1/1 и собираются обратно в начале следующего хода.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/EDR_818.png', NULL, 'https://art.hearthstonejson.com/v1/512x/EDR_818.jpg', 'Zoltan Boros', 7, 7, 7, TRUE, (SELECT id FROM card_sets WHERE slug = 'emerald-dream'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Легендарная'), NULL, NULL, NULL, '{"blood":0,"frost":0,"unholy":2}'::jsonb, (SELECT id FROM classes WHERE name = 'Рыцарь смерти'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('END_006', 'khronikar_END_006', 'Хроникар', '<b>Боевой клич:</b> дает вашему герою +3 к атаке на этом ходу, на следующем ходу и через 2 хода.', 'И на следующем ходу! И на следующем ходу!', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/END_006.png', NULL, 'https://art.hearthstonejson.com/v1/512x/END_006.jpg', 'Grafit Studio', 5, 3, 5, TRUE, (SELECT id FROM card_sets WHERE slug = 'across-the-timeways'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Легендарная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Охотник на демонов'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('BE_771', 'khlyst-shchupaltse_BE_771', 'Хлыст-щупальце', 'После того как ваш герой атакует, уменьшает стоимость К''Туна на (1). Вы выбираете и применяете способность К''Туна.', 'К''Тун наделил меня своей мощью!', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/BE_771.png', NULL, 'https://art.hearthstonejson.com/v1/512x/BE_771.jpg', 'Studio Hive', 5, 1, 2, TRUE, (SELECT id FROM card_sets WHERE slug = 'dark-empire'), (SELECT id FROM card_types WHERE name = 'Оружие'), (SELECT id FROM rarities WHERE name = 'Эпическая'), 0, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Охотник на демонов'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('CATA_556', 'drakonchik-nosilshchik_CATA_556', 'Дракончик-носильщик', '<b>Боевой клич:</b>& вы получаете случайного дракона за (3) или меньше.', 'Так вот откуда берутся дракончики...', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/CATA_556.png', NULL, 'https://art.hearthstonejson.com/v1/512x/CATA_556.jpg', 'Tanamaes Leejierasaes', 1, 1, 2, TRUE, (SELECT id FROM card_sets WHERE slug = 'cataclysm'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Обычная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Общие'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('TLC_477', 'blagoslovenie-vsadnika_TLC_477', 'Благословение всадника', '[x] Ваше существо получает +4/+4
и «<b>Предсмертный хрип:</b>
призывает  случайное
существо за (4)».', 'Как по мне, так это просто фонарик...', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/TLC_477.png', NULL, 'https://art.hearthstonejson.com/v1/512x/TLC_477.jpg', 'Danny Beck', 5, NULL, NULL, TRUE, (SELECT id FROM card_sets WHERE slug = 'lost-city-ungoro'), (SELECT id FROM card_types WHERE name = 'Заклинание'), (SELECT id FROM rarities WHERE name = 'Эпическая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Паладин'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('CATA_EVENT_110', 'raskolotaya-dusha-drakona_CATA_EVENT_110', 'Расколотая Душа Дракона', '[x]<b>Начало матча</b>:
раскалывается на 6 сущностей.
Находящиеся рядом сущности
применяются вместе.', 'Изначальные драконы отреклись от своих сородичей еще до того, как Аспекты впервые наделили Душу Дракона своей силой. Но теперь впервые в истории даже Виранот выступила против Смертокрыла.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/CATA_EVENT_110.png', NULL, 'https://art.hearthstonejson.com/v1/512x/CATA_EVENT_110.jpg', 'Daniil Kudriavtsev', 6, NULL, NULL, TRUE, (SELECT id FROM card_sets WHERE slug = 'event'), (SELECT id FROM card_types WHERE name = 'Заклинание'), (SELECT id FROM rarities WHERE name = 'Легендарная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Общие'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('CORE_EX1_246', 'sglaz_CORE_EX1_246', 'Сглаз', 'Превращает существо в лягушку 0/1 с <b>«Провокацией»</b>.', 'Если сглазить мурлока, можно и не заметить разницы.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/CORE_EX1_246.png', NULL, 'https://art.hearthstonejson.com/v1/512x/CORE_EX1_246.jpg', 'Steve Hui', 3, NULL, NULL, TRUE, (SELECT id FROM card_sets WHERE slug = 'core'), (SELECT id FROM card_types WHERE name = 'Заклинание'), (SELECT id FROM rarities WHERE name = 'Обычная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Шаман'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('FIR_959', 'firakk-pylayushchiy_FIR_959', 'Фиракк Пылающий', '[x]<b>Неуязвимость</b> к заклинаниям
огня. <b>Боевой клич:</b> применяет
к случайным противникам
заклинания огня суммарной
стоимостью (15).', 'Раньше Фиракк хотел лишь избавиться от влияния титанов, но пламя Тьмы исказило его разум, наполнив бесконечной злобой. Теперь Воздаятель Снов жаждет лишь одного — сжечь весь мир дотла.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/FIR_959.png', NULL, 'https://art.hearthstonejson.com/v1/512x/FIR_959.jpg', 'Kevin Sidharta', 10, 7, 7, TRUE, (SELECT id FROM card_sets WHERE slug = 'emerald-dream'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Легендарная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Общие'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('CATA_480', 'aura-peschanoy-buri_CATA_480', 'Аура песчаной бури', '[x]Эффекты конца хода
ваших существ
срабатывают дважды.
Действует 3 |4(ход,хода,ходов).', 'Песок всегда изменяет ход времени, когда попадает в мои часы.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/CATA_480.png', NULL, 'https://art.hearthstonejson.com/v1/512x/CATA_480.jpg', 'Tee Fuyuan', 3, NULL, NULL, TRUE, (SELECT id FROM card_sets WHERE slug = 'cataclysm'), (SELECT id FROM card_types WHERE name = 'Заклинание'), (SELECT id FROM rarities WHERE name = 'Редкая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Паладин'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('TIME_704', 'vysokorozhdennyy-nastavnik_TIME_704', 'Высокорожденный-наставник', '[x]<b>Боевой клич:</b> вы получаете
ученика 2/2, <b>раскапываете</b>
заклинание из прошлого
за (7) или больше и обучаете
ему ученика.', 'Все время валит учеников каверзными вопросами.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/TIME_704.png', NULL, 'https://art.hearthstonejson.com/v1/512x/TIME_704.jpg', 'Sergey Tsvelykh', 7, 6, 6, TRUE, (SELECT id FROM card_sets WHERE slug = 'across-the-timeways'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Эпическая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Друид'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('TLC_820', 'lesnoy-ekolog_TLC_820', 'Лесной эколог', '<b>Предсмертный хрип:</b>
вы получаете заклинание
Света за (1), дающее существу +2 или -2 ед. здоровья.', 'Получил второе образование в области биологии Нижепади. Теперь это настоящий тортоллан на все руки!.. То есть науки.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/TLC_820.png', NULL, 'https://art.hearthstonejson.com/v1/512x/TLC_820.jpg', 'Ursula Dorada', 1, 2, 1, TRUE, (SELECT id FROM card_sets WHERE slug = 'lost-city-ungoro'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Редкая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Жрец'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('BE_565', 'koroleva-stai-sha-kar_BE_565', 'Королева стаи Ша''кар', '[x]<b>Боевой клич</b>: если на этом ходу
погибло 5 ваших существ,
в этом матче ваши существа c
<b>«Натиском»</b> получают <b>«Рывок»</b>.
<i>(Еще {0}!)</i>@[x]<b>Боевой клич</b>: если на этом ходу
погибло 5 ваших существ,
в этом матче ваши существа c
<b>«Натиском»</b> получают <b>«Рывок»</b>.
<i>(Готово!)</i>@[x]<b>Боевой клич</b>: если на этом
ходу погибло 5 ваших
существ, в этом матче ваши
существа c <b>«Натиском»</b>
получают <b>«Рывок»</b>.', 'Снимите их с меня!', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/BE_565.png', NULL, 'https://art.hearthstonejson.com/v1/512x/BE_565.jpg', 'Dmitry Bolotov', 5, 3, 5, TRUE, (SELECT id FROM card_sets WHERE slug = 'dark-empire'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Легендарная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Охотник на демонов'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('TLC_EVENT_402', 'posokh-vestnitsy-gibeli_TLC_EVENT_402', 'Посох Вестницы гибели', '<b>Предсмертный хрип:</b>& уничтожает всех существ на поле.', 'Наконец-то с босса выпало то, что мне надо! Вот только это не мой основной персонаж...', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/TLC_EVENT_402.png', NULL, 'https://art.hearthstonejson.com/v1/512x/TLC_EVENT_402.jpg', 'Drew Hill', 3, 1, 6, TRUE, (SELECT id FROM card_sets WHERE slug = 'event'), (SELECT id FROM card_types WHERE name = 'Оружие'), (SELECT id FROM rarities WHERE name = 'Легендарная'), 0, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Рыцарь смерти'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('EDR_461', 'ritual-novoluniya_EDR_461', 'Ритуал новолуния', 'Призывает двух случайных существ за (3).[x]
<i>(Примените 3 |4(заклинание, заклинания, заклинаний),
чтобы вместо этого призвать
существ за (6).)</i>', 'Этот ритуал не действует, но они проводят его чисто для тимбилдинга.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/EDR_461.png', NULL, 'https://art.hearthstonejson.com/v1/512x/EDR_461.jpg', 'Patrik Bjorkstrom', 5, NULL, NULL, TRUE, (SELECT id FROM card_sets WHERE slug = 'emerald-dream'), (SELECT id FROM card_types WHERE name = 'Заклинание'), (SELECT id FROM rarities WHERE name = 'Эпическая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Жрец'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('TIME_876', 'besformennyy_TIME_876', 'Бесформенный', '[x]Находясь в руке,
каждый ход превращается
в случайное существо
из руки противника.', 'Не круглый, не квадратный и даже не ромбовидный...', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/TIME_876.png', NULL, 'https://art.hearthstonejson.com/v1/512x/TIME_876.jpg', 'Todd Harris', 1, 1, 1, TRUE, (SELECT id FROM card_sets WHERE slug = 'across-the-timeways'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Эпическая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Разбойник'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('CATA_724', 'vladychitsa-shtormov_CATA_724', 'Владычица Штормов', '<b>Предсмертный хрип:</b> ваши кристаллы маны освобождаются от <b>«Перегрузки»</b>. <b>Перегрузка:</b> (3)', 'Какой-то орк, глядя на дождь: «Ну, с погодой ничего не сделаешь». Владыка бурь: «Подержи мой тотем».', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/CATA_724.png', NULL, 'https://art.hearthstonejson.com/v1/512x/CATA_724.jpg', 'Zoltan Boros', 4, 7, 7, TRUE, (SELECT id FROM card_sets WHERE slug = 'cataclysm'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Обычная'), NULL, 3, NULL, NULL, (SELECT id FROM classes WHERE name = 'Шаман'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('CORE_DRG_107', 'ametistovyy-charokryl_CORE_DRG_107', 'Аметистовый чарокрыл', '<b>Предсмертный хрип:</b>
вы кладете в руку «Чародейские стрелы».', 'Лучше чарокрыл в руке, чем три стрелы в лицо.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/CORE_DRG_107.png', NULL, 'https://art.hearthstonejson.com/v1/512x/CORE_DRG_107.jpg', 'Jakub Kasper', 1, 2, 1, TRUE, (SELECT id FROM card_sets WHERE slug = 'core'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Обычная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Маг'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('TIME_EVENT_997', 'dobro-pozhalovat-domoy_TIME_EVENT_997', 'Добро пожаловать домой!', '[x]Открывает область
снова. Она получает
«<b>Предсмертный хрип:</b>
призывает случайное
существо за (3)».', 'Снимайте ботинки, разожгите очаг и сыграйте партийку!', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/TIME_EVENT_997.png', NULL, 'https://art.hearthstonejson.com/v1/512x/TIME_EVENT_997.jpg', 'Mooncolony', 3, NULL, NULL, TRUE, (SELECT id FROM card_sets WHERE slug = 'event'), (SELECT id FROM card_types WHERE name = 'Заклинание'), (SELECT id FROM rarities WHERE name = 'Эпическая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Общие'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('BE_222', 'drevnee-slovo-voploshchenie_BE_222', 'Древнее слово: воплощение', '[x]Призывает двух безднокрылов
3/4 с <b>«Похищением жизни»</b>.
<i>(Следующее заклинание Тьмы,
которое вы разыграете,
повторит этот эффект!)</i>', 'Не люблю яичницу из яиц Бездны.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/BE_222.png', NULL, 'https://art.hearthstonejson.com/v1/512x/BE_222.jpg', 'Zoltan Boros', 5, NULL, NULL, TRUE, (SELECT id FROM card_sets WHERE slug = 'dark-empire'), (SELECT id FROM card_types WHERE name = 'Заклинание'), (SELECT id FROM rarities WHERE name = 'Обычная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Жрец'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('TLC_246', 'drevniy-terrodaktil_TLC_246', 'Древний терродактиль', '<b>Боевой клич:</b> получает
на выбор <b>«Маскировку»</b> до вашего следующего хода, <b>«Неуловимость»</b> или <b>«Неистовство ветра»</b>.', 'Летает, пугает и не проводит электричество.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/TLC_246.png', NULL, 'https://art.hearthstonejson.com/v1/512x/TLC_246.jpg', 'Jaemin Kim', 4, 4, 4, TRUE, (SELECT id FROM card_sets WHERE slug = 'lost-city-ungoro'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Редкая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Общие'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('CATA_210', 'sumerechnoe-yaytso_CATA_210', 'Сумеречное яйцо', '<b>Предсмертный хрип:</b> призывает дракончика {0}/{1}. <i>(Получает +1/+1 в начале каждого вашего хода!)</i>', 'Гм. А это еще что такое?', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/CATA_210.png', NULL, 'https://art.hearthstonejson.com/v1/512x/CATA_210.jpg', 'Felideus Bubastis', 1, 0, 2, TRUE, (SELECT id FROM card_sets WHERE slug = 'cataclysm'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Обычная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Общие'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('CORE_EX1_007', 'sluzhitel-boli_CORE_EX1_007', 'Служитель боли', 'Когда это существо получает урон,& вы берете карту.', 'Вообще-то он учился на служителя радости, но что-то пошло не так...', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/CORE_EX1_007.png', NULL, 'https://art.hearthstonejson.com/v1/512x/CORE_EX1_007.jpg', 'Dave Kendall', 3, 1, 4, TRUE, (SELECT id FROM card_sets WHERE slug = 'core'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Обычная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Общие'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('FIR_908', 'obozhzhennyy-khameleon_FIR_908', 'Обожженный хамелеон', '<b>Боевой клич:</b> если на этом ходу вы использовали силу героя, ваше существо получает
+1/+2 и <b>«Натиск»</b>.', 'Хамелеоны умеют не выделяться, даже когда все вокруг горит.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/FIR_908.png', NULL, 'https://art.hearthstonejson.com/v1/512x/FIR_908.jpg', 'Matt Dixon', 1, 1, 2, TRUE, (SELECT id FROM card_sets WHERE slug = 'emerald-dream'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Обычная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Друид'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('TLC_447', 'edkie-pary_TLC_447', 'Едкие пары', '[x]Уничтожает существо
противника. <b>Родня:</b>
наносит $2 ед. урона
всем существам.', 'Если едкие пары не действуют, то надо просто больше едких паров!', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/TLC_447.png', NULL, 'https://art.hearthstonejson.com/v1/512x/TLC_447.jpg', 'Grafit Studio', 4, NULL, NULL, TRUE, (SELECT id FROM card_sets WHERE slug = 'lost-city-ungoro'), (SELECT id FROM card_types WHERE name = 'Заклинание'), (SELECT id FROM rarities WHERE name = 'Обычная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Чернокнижник'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('TIME_609', 'komandir-sledopytov-silvana_TIME_609', 'Командир следопытов Сильвана', '[x]<b>Герой саги</b>. <b>Боевой клич:</b>
наносит противникам 2 ед. урона.
Если вы уже разыграли Аллерию
или Верису, эффект повторяется
за каждую из них.', 'Кем бы она ни стала впоследствии, это не отменяет того, что командир следопытов Луносвета отважнее всех сражалась против Короля-лича.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/TIME_609.png', NULL, 'https://art.hearthstonejson.com/v1/512x/TIME_609.jpg', 'Rafael Zanchetin', 3, 2, 4, TRUE, (SELECT id FROM card_sets WHERE slug = 'across-the-timeways'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Легендарная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Охотник'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('BE_255', 'doistoricheskiy-zmey_BE_255', 'Доисторический змей', '[x]После того как вы
разыгрываете существо,&
   получает +1 к здоровью.   ', '.ынам мордев с енидеан хи етйялватсо ен ешчул ,ызоргу йошьлоб тюялватсдерп ен ино ятоХ .йеигренэ йоксйедорач ястюатип иемз итЭ', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/BE_255.png', NULL, 'https://art.hearthstonejson.com/v1/512x/BE_255.jpg', 'Tee Fuyuan', 1, 2, 1, TRUE, (SELECT id FROM card_sets WHERE slug = 'dark-empire'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Обычная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Общие'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('CATA_EVENT_402', 'smertelnaya-vzyatka_CATA_EVENT_402', 'Смертельная взятка', 'Уничтожает существо и дает вашему противнику монетку. <b>Серия приемов:</b> вы тоже получаете монетку.', 'Отдать долю доли, чтобы получить долю.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/CATA_EVENT_402.png', NULL, 'https://art.hearthstonejson.com/v1/512x/CATA_EVENT_402.jpg', 'Zoltan Boros', 3, NULL, NULL, TRUE, (SELECT id FROM card_sets WHERE slug = 'event'), (SELECT id FROM card_types WHERE name = 'Заклинание'), (SELECT id FROM rarities WHERE name = 'Эпическая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Разбойник'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('TLC_464', 'karta-gory_TLC_464', 'Карта горы', '[x]Вы <b>раскапываете</b> существо того
типа, что еще не разыгрывали.
Разыграв его на этом ходу,
вы выбираете еще одно 
существо из предложенных.', 'Видишь тот кружок на вершине? Это вершина.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/TLC_464.png', NULL, 'https://art.hearthstonejson.com/v1/512x/TLC_464.jpg', 'Vika Yarova', 1, NULL, NULL, TRUE, (SELECT id FROM card_sets WHERE slug = 'lost-city-ungoro'), (SELECT id FROM card_types WHERE name = 'Заклинание'), (SELECT id FROM rarities WHERE name = 'Редкая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Шаман'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('CORE_EX1_058', 'zastupnitsa-sin-doray_CORE_EX1_058', 'Заступница син''дорай', '[x]<b>Боевой клич:</b> находящиеся
по обе стороны существа
 получают <b>«Провокацию»</b>.', '«Будь джентльменом, подержи щит!»
Андрей М. «Wishmaster»', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/CORE_EX1_058.png', NULL, 'https://art.hearthstonejson.com/v1/512x/CORE_EX1_058.jpg', 'James Ryman', 2, 2, 3, TRUE, (SELECT id FROM card_sets WHERE slug = 'core'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Редкая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Общие'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('CATA_492', 'sumerechnoe-svyatilishche_CATA_492', 'Сумеречное святилище', '<b>Возвещает</b>, что
скоро явится
{0}. Вы берете карту.', 'Здесь Чо''Галл хранит мерч, связанный с Древними богами.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/CATA_492.png', NULL, 'https://art.hearthstonejson.com/v1/512x/CATA_492.jpg', 'BOSi Studio', 4, NULL, 2, TRUE, (SELECT id FROM card_sets WHERE slug = 'cataclysm'), (SELECT id FROM card_types WHERE name = 'Локация'), (SELECT id FROM rarities WHERE name = 'Редкая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Чернокнижник'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('FIR_910', 'obzhigayushchie-vetra_FIR_910', 'Обжигающие ветра', 'Наносит $3 ед. урона. Сбрасывает случайное заклинание огня и наносит еще $3 ед. урона.', 'Как говорится, где есть дым, есть и огонь. А где есть огонь, там скоро будет еще больше огня.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/FIR_910.png', NULL, 'https://art.hearthstonejson.com/v1/512x/FIR_910.jpg', 'A. J. Nazzaro', 3, NULL, NULL, TRUE, (SELECT id FROM card_sets WHERE slug = 'emerald-dream'), (SELECT id FROM card_types WHERE name = 'Заклинание'), (SELECT id FROM rarities WHERE name = 'Редкая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Маг'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('BE_851', 'khranitelnitsa-doliny_BE_851', 'Хранительница долины', '<b>Боевой клич:</b> вы <b>собираете</b> зверя.', 'На ласку и зверь соберется.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/BE_851.png', NULL, 'https://art.hearthstonejson.com/v1/512x/BE_851.jpg', 'Sergey Tsvelykh', 2, 2, 3, TRUE, (SELECT id FROM card_sets WHERE slug = 'dark-empire'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Обычная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Друид'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('TIME_103', 'khromi_TIME_103', 'Хроми', '<b>Предсмертный хрип:</b> вы берете еще по одной копии карт, которые вы разыграли
в этом матче.@ <i>(@ |4(карта,карты,карт))</i>', 'Хроми обыскала весь мир, но так и не нашла группу героев, которые смогли бы победить Дорнозму. По крайней мере, в <i>этой</i> временной линии...', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/TIME_103.png', NULL, 'https://art.hearthstonejson.com/v1/512x/TIME_103.jpg', 'Ivan Fomin', 6, 4, 6, TRUE, (SELECT id FROM card_sets WHERE slug = 'across-the-timeways'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Легендарная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Общие'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('CATA_EVENT_002', 'porochnyy-podzhigatel_CATA_EVENT_002', 'Порочный поджигатель', '<b>Боевой клич:</b> если вы разыграли заклинание
огня на этом ходу, уничтожает существо.', 'Я ПРОЙДУ!', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/CATA_EVENT_002.png', NULL, 'https://art.hearthstonejson.com/v1/512x/CATA_EVENT_002.jpg', 'Vladimir Kafanov', 3, 4, 3, TRUE, (SELECT id FROM card_sets WHERE slug = 'event'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Эпическая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Воин'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('CORE_RLK_745', 'boleznetvornyy-uzhas_CORE_RLK_745', 'Болезнетворный ужас', '<b>Перерождение</b>
В конце вашего хода расходует 4 <b>трупа</b> и призывает копию этого существа.', 'Чпок! Гнойничок лопнул.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/CORE_RLK_745.png', NULL, 'https://art.hearthstonejson.com/v1/512x/CORE_RLK_745.jpg', 'Richie Marella', 4, 2, 4, TRUE, (SELECT id FROM card_sets WHERE slug = 'core'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Обычная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Рыцарь смерти'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('DINO_419', 'travoyadnyy-pomoshchnik_DINO_419', 'Травоядный помощник', '<b>Боевой клич:</b>
ваш зверь получает
+2/+2 и <b>«Натиск»</b>.', '«Ваш вечер полностью расписан. Я могу сдвинуть жевание листьев, чтобы освободить место для обязательной прогулки».', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/DINO_419.png', NULL, 'https://art.hearthstonejson.com/v1/512x/DINO_419.jpg', 'Patrik Bjorkstrom', 3, 3, 2, TRUE, (SELECT id FROM card_sets WHERE slug = 'lost-city-ungoro'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Обычная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Общие'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('EDR_815', 'trupotsvet_EDR_815', 'Трупоцвет', 'После того как противник призывает существо, расходует 2 <b>трупа</b> и наносит этому существу 3 ед. урона.', 'Иногда лучше не останавливаться, чтобы полюбоваться цветами.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/EDR_815.png', NULL, 'https://art.hearthstonejson.com/v1/512x/EDR_815.jpg', 'Slawomir Maniak', 3, 0, 5, TRUE, (SELECT id FROM card_sets WHERE slug = 'emerald-dream'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Редкая'), NULL, NULL, NULL, '{"blood":0,"frost":0,"unholy":2}'::jsonb, (SELECT id FROM classes WHERE name = 'Рыцарь смерти'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('BE_778', 'prismotr_BE_778', 'Присмотр', 'Вы выбираете и применяете две разные способности К''Туна.', 'За этими к''тирами нужен глаз да глаз.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/BE_778.png', NULL, 'https://art.hearthstonejson.com/v1/512x/BE_778.jpg', 'Mooncolony', 6, NULL, NULL, TRUE, (SELECT id FROM card_sets WHERE slug = 'dark-empire'), (SELECT id FROM card_types WHERE name = 'Заклинание'), (SELECT id FROM rarities WHERE name = 'Обычная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Шаман'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('CATA_525', 'bronirovannyy-krovopuskatel_CATA_525', 'Бронированный кровопускатель', '<b>Натиск</b>. <b>Боевой клич:</b> <b>возвещает</b>, что скоро явится {0}.', 'Милый Каз''джан, пишу тебе, чтобы сообщить, что Катаклизм идет как по маслу! Считаю дни до возвращения. С любовью, Видж''ар.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/CATA_525.png', NULL, 'https://art.hearthstonejson.com/v1/512x/CATA_525.jpg', 'Ian Ameling', 3, 3, 1, TRUE, (SELECT id FROM card_sets WHERE slug = 'cataclysm'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Обычная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Охотник на демонов'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('TIME_036', 'korolevskiy-osvedomitel_TIME_036', 'Королевский осведомитель', '<b>Боевой клич:</b> вы просматриваете крайнюю правую карту в руке противника. Дает вам ее
копию или увеличивает ее стоимость на (2).', '«Эй, по секрету... тот человек в короне — это король».', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/TIME_036.png', NULL, 'https://art.hearthstonejson.com/v1/512x/TIME_036.jpg', 'Ursula Dorada', 3, 2, 4, TRUE, (SELECT id FROM card_sets WHERE slug = 'across-the-timeways'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Эпическая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Разбойник'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('CATA_EVENT_001', 'razrushitelnyy-feniks_CATA_EVENT_001', 'Разрушительный феникс', '<b>Боевой клич:</b> вы выбираете и поджигаете карту в руке. Через 3 хода сбрасываете ее и призываете копию этого существа.', 'А вы представьте, каково это – в 9000-й раз возрождаться из пепла!', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/CATA_EVENT_001.png', NULL, 'https://art.hearthstonejson.com/v1/512x/CATA_EVENT_001.jpg', 'Daniil Kudriavtsev', 4, 5, 5, TRUE, (SELECT id FROM card_sets WHERE slug = 'event'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Эпическая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Чернокнижник'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('TLC_829', 'prozhorlivyy-dyavozavr_TLC_829', 'Прожорливый дьявозавр', '<b>Боевой клич:</b> уничтожает существо. <b>Родня:</b> получает
[x]его характеристики.', 'Ты не ты, когда голоден. И при этом прожорлив.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/TLC_829.png', NULL, 'https://art.hearthstonejson.com/v1/512x/TLC_829.jpg', 'L. Lullabi & I. Campelo da Silva', 7, 3, 3, TRUE, (SELECT id FROM card_sets WHERE slug = 'lost-city-ungoro'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Эпическая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Общие'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('BE_227', 'klinok-temnoy-imperii_BE_227', 'Клинок Темной Империи', '[x]Если вы применили заклинание
Тьмы, в конце вашего хода
противник получает урон
  от усталости. В противном
случае его получаете вы.', 'Ксал''атат на протяжении многих веков попадала в руки легендарных героев. Они не обрели бы такой славы, если бы не помощь проклятого клинка.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/BE_227.png', NULL, 'https://art.hearthstonejson.com/v1/512x/BE_227.jpg', 'Tanamaes Leejierasaes', 3, 0, 3, TRUE, (SELECT id FROM card_sets WHERE slug = 'dark-empire'), (SELECT id FROM card_types WHERE name = 'Оружие'), (SELECT id FROM rarities WHERE name = 'Легендарная'), 0, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Жрец'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('CORE_DRG_079', 'neulovimyy-zmey_CORE_DRG_079', 'Неуловимый змей', '<b>Божественный щит</b>. <b>Натиск</b>. <b>Неуловимость</b>.', 'Уклоняется от заклинаний, извиваясь, как уж на сковородке.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/CORE_DRG_079.png', NULL, 'https://art.hearthstonejson.com/v1/512x/CORE_DRG_079.jpg', 'Arthur Bozonnet', 6, 5, 4, TRUE, (SELECT id FROM card_sets WHERE slug = 'core'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Обычная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Общие'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('MEND_805', 'blagotvoritelnost_MEND_805', 'Благотворительность', 'Вы получаете копии всех ваших существ, погибших на этом ходу. Они получают +3/+3.', 'Жертвую этих существ... сам себе!', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/MEND_805.png', NULL, 'https://art.hearthstonejson.com/v1/512x/MEND_805.jpg', 'Bima Kusuma', 3, NULL, NULL, TRUE, (SELECT id FROM card_sets WHERE slug = 'cataclysm'), (SELECT id FROM card_types WHERE name = 'Заклинание'), (SELECT id FROM rarities WHERE name = 'Эпическая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Паладин'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('FIR_958', 'tindral-polet-mysli_FIR_958', 'Тиндрал Полет Мысли', '<b>Предсмертный хрип:</b> наносит противникам 1 ед. урона.
Если сейчас ход противника, вместо этого наносит
4 ед. урона.', 'Раскален докрасна.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/FIR_958.png', NULL, 'https://art.hearthstonejson.com/v1/512x/FIR_958.jpg', 'James Ryman', 4, 4, 3, TRUE, (SELECT id FROM card_sets WHERE slug = 'emerald-dream'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Легендарная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Общие'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('TIME_213', 'pervozdannaya-smotritelnitsa_TIME_213', 'Первозданная смотрительница', '<b>Боевой клич:</b> если вы разыграли заклинание природы с этой картой в руке,& получает +1/+1,
а вы берете карту.', 'В этой временной линии дворфы очень увлеклись резьбой по тотемам.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/TIME_213.png', NULL, 'https://art.hearthstonejson.com/v1/512x/TIME_213.jpg', 'Kati Sarin', 2, 2, 3, TRUE, (SELECT id FROM card_sets WHERE slug = 'across-the-timeways'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Обычная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Шаман'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('TIME_EVENT_300', 'predvestnik-chernogo-zheleza_TIME_EVENT_300', 'Предвестник Черного Железа', '<b>Предсмертный хрип:</b> призывает вестника рока 0/7, уничтожающего всех существ в начале вашего хода.', 'Вестник рока уже было отчаялся, пока не узнал о новом Катаклизме!', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/TIME_EVENT_300.png', NULL, 'https://art.hearthstonejson.com/v1/512x/TIME_EVENT_300.jpg', 'Mike Sass', 4, 7, 4, TRUE, (SELECT id FROM card_sets WHERE slug = 'event'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Эпическая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Общие'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('CATA_308', 'triumf-mediva_CATA_308', 'Триумф Медива', '[x]Наносит $4 ед. урона
всем существам. Cтоит (1),
если вы контролируете
<b>легендарную</b> карту.', 'Этот Медив долго противился искушению Саргераса, познав истинную тьму... и через это как никто иной научившись понимать Свет.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/CATA_308.png', NULL, 'https://art.hearthstonejson.com/v1/512x/CATA_308.jpg', 'Vika Yarova', 5, NULL, NULL, TRUE, (SELECT id FROM card_sets WHERE slug = 'cataclysm'), (SELECT id FROM card_types WHERE name = 'Заклинание'), (SELECT id FROM rarities WHERE name = 'Эпическая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Жрец'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('TLC_623', 'rezchik-po-kamnyu_TLC_623', 'Резчик по камню', '[x]В конце вашего хода&
другое ваше существо
с неполным здоровьем
получает +2/+2.', '*дзынь!* *дзынь!* *дзынь!* *тресь!* «Ну вот, опять сначала!»', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/TLC_623.png', NULL, 'https://art.hearthstonejson.com/v1/512x/TLC_623.jpg', 'Stefano Spagnuolo', 2, 1, 4, TRUE, (SELECT id FROM card_sets WHERE slug = 'lost-city-ungoro'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Эпическая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Воин'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('EDR_495', 'iskazhennyy-dreven_EDR_495', 'Искаженный древень', '<b>Предсмертный хрип:</b> случайное существо
в руке каждого игрока получает -2 к атаке.', 'Дружит только со скрюченными елками и гуляет только по скрюченной дорожке.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/EDR_495.png', NULL, 'https://art.hearthstonejson.com/v1/512x/EDR_495.jpg', 'Mauricio Herrera', 2, 2, 2, TRUE, (SELECT id FROM card_sets WHERE slug = 'emerald-dream'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Обычная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Общие'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('TIME_034', 'kommentator-na-stadione_TIME_034', 'Комментатор на стадионе', '[x]<b>Перемотка</b>. <b>Боевой клич:</b>
снаряжает обоих игроков
случайным оружием. Ваше
      оружие получает +1/+1.      ', '«ВНИМАНИЕ!» «БОМБОЧКА!»', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/TIME_034.png', NULL, 'https://art.hearthstonejson.com/v1/512x/TIME_034.jpg', 'Kleston Marques', 4, 3, 3, TRUE, (SELECT id FROM card_sets WHERE slug = 'across-the-timeways'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Редкая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Воин'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('CORE_WON_351', 'melkiy-bukaner_CORE_WON_351', 'Мелкий буканьер', '+2 к атаке,
пока вы вооружены.', '«Нет, книпель тебе в печень, я пират только по выходным и праздникам!»', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/CORE_WON_351.png', NULL, 'https://art.hearthstonejson.com/v1/512x/CORE_WON_351.jpg', 'Paul Mafayon', 1, 1, 2, TRUE, (SELECT id FROM card_sets WHERE slug = 'core'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Редкая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Общие'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('BE_571', 'vayanie-ploti_BE_571', 'Ваяние плоти', '[x]<b>Собирает</b> существо с
<b>«Предсмертным хрипом»</b>.
Существа у вас в руке
получают +2/+2.', 'Хватит, щекотно!', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/BE_571.png', NULL, 'https://art.hearthstonejson.com/v1/512x/BE_571.jpg', 'Stefan Bogdasarov', 3, NULL, NULL, TRUE, (SELECT id FROM card_sets WHERE slug = 'dark-empire'), (SELECT id FROM card_types WHERE name = 'Заклинание'), (SELECT id FROM rarities WHERE name = 'Редкая'), NULL, NULL, NULL, '{"blood":1,"frost":0,"unholy":1}'::jsonb, (SELECT id FROM classes WHERE name = 'Рыцарь смерти'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('JAIL_EVENT_101', 'zhar-dushi_JAIL_EVENT_101', 'Жар души', '[x]Сила героя меняется на
«Коллапсирующую звезду».
Если у вас уже есть эта
сила героя, наносимый ею
 урон увеличивается на 1.', 'Это что, фрагмент души? Я не видел их, с тех пор как закончил Некроситет!', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/JAIL_EVENT_101.png', NULL, 'https://art.hearthstonejson.com/v1/512x/JAIL_EVENT_101.jpg', 'Alex Stone', 2, NULL, NULL, TRUE, (SELECT id FROM card_sets WHERE slug = 'event'), (SELECT id FROM card_types WHERE name = 'Заклинание'), (SELECT id FROM rarities WHERE name = 'Эпическая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Охотник на демонов'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('CORE_EX1_259', 'groza_CORE_EX1_259', 'Гроза', 'Наносит $3 ед. урона всем существам противника. <b>Перегрузка:</b> (1)', 'Боюсь, от этой грозы зонтик вам не поможет.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/CORE_EX1_259.png', NULL, 'https://art.hearthstonejson.com/v1/512x/CORE_EX1_259.jpg', 'Christopher Moeller', 3, NULL, NULL, TRUE, (SELECT id FROM card_sets WHERE slug = 'core'), (SELECT id FROM card_types WHERE name = 'Заклинание'), (SELECT id FROM rarities WHERE name = 'Редкая'), NULL, 1, NULL, NULL, (SELECT id FROM classes WHERE name = 'Шаман'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('EDR_454', 'kladka-porchi_EDR_454', 'Кладка порчи', '[x]Выберите вашего дракона.
 Призывает яйцо 0/2, из которого
вылупится копия
выбранного дракона.', 'Эти яйца вообще-то очень тяжело разбить!', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/EDR_454.png', NULL, 'https://art.hearthstonejson.com/v1/512x/EDR_454.jpg', 'Grafit Studio', 2, NULL, 2, TRUE, (SELECT id FROM card_sets WHERE slug = 'emerald-dream'), (SELECT id FROM card_types WHERE name = 'Локация'), (SELECT id FROM rarities WHERE name = 'Эпическая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Воин'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('TIME_706', 'vnevremennyy-plavnik_TIME_706', 'Вневременный Плавник', '<b>Боевой клич:</b> ваша рука заменяется на стартовую.
В конце вашего хода
она меняется обратно.', 'Карты? Там, куда мы идем, карты не нужны.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/TIME_706.png', NULL, 'https://art.hearthstonejson.com/v1/512x/TIME_706.jpg', 'Max Grecke', 2, 2, 3, TRUE, (SELECT id FROM card_sets WHERE slug = 'across-the-timeways'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Легендарная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Паладин'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('DINO_429', 'maska-ovtsy_DINO_429', 'Маска овцы', '[x]Характеристики существа
становятся равны 1/1 и оно
получает «<b>Предсмертный хрип:</b>
наносит 2 ед. урона
всем существам».', 'О чем же думают электроовцы?', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/DINO_429.png', NULL, 'https://art.hearthstonejson.com/v1/512x/DINO_429.jpg', 'Adam Byrne', 4, NULL, NULL, TRUE, (SELECT id FROM card_sets WHERE slug = 'lost-city-ungoro'), (SELECT id FROM card_types WHERE name = 'Заклинание'), (SELECT id FROM rarities WHERE name = 'Редкая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Маг'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('BE_114', 'tenevaya-skulptura_BE_114', 'Теневая скульптура', '[x]<b>Собирает</b> существо.
Оно стоит на (2) меньше.', 'А что, если мы будем играть в Warcraft без света?', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/BE_114.png', NULL, 'https://art.hearthstonejson.com/v1/512x/BE_114.jpg', 'AJ Nazzaro', 3, NULL, NULL, TRUE, (SELECT id FROM card_sets WHERE slug = 'dark-empire'), (SELECT id FROM card_types WHERE name = 'Заклинание'), (SELECT id FROM rarities WHERE name = 'Обычная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Шаман'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('CATA_208', 'samootverzhennyy-zashchitnik_CATA_208', 'Самоотверженный защитник', '[x]<b>Провокация</b>
 Получает на 1 ед. урона
   больше от всех эффектов. ', '— Я скромнее всех, кого ты когда-либо встретишь.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/CATA_208.png', NULL, 'https://art.hearthstonejson.com/v1/512x/CATA_208.jpg', 'Max Grecke', 2, 2, 6, TRUE, (SELECT id FROM card_sets WHERE slug = 'cataclysm'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Редкая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Общие'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('CATA_EVENT_000', 'pervorodnyy-vlastelin_CATA_EVENT_000', 'Первородный властелин', '<b>Боевой клич:</b>& вы получаете случайное <b>гигантское</b> [x]существо из прошлого.', 'Под холодной обсидиановой броней у него очень теплое сердце... из раскаленной лавы.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/CATA_EVENT_000.png', NULL, 'https://art.hearthstonejson.com/v1/512x/CATA_EVENT_000.jpg', 'Konstantin Turovec', 6, 7, 6, TRUE, (SELECT id FROM card_sets WHERE slug = 'event'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Эпическая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Общие'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('TLC_460', 'zapretnyy-protokol_TLC_460', 'Запретный протокол', '<b>Задача:</b> <b>раскопайте</b> 8 карт. <b>Награда:</b> «Камень истока».', 'День 9. Нас встретили не с распростертыми объятиями, а с оружием в руках! К счастью, градоправитель Эшо сжалился над нами и отозвал стражей. Титанограф умыкнул Элизу в библиотеку, как только узнал, что она опытный исследователь. А Умбра исчезла в лабиринте улиц...', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/TLC_460.png', NULL, 'https://art.hearthstonejson.com/v1/512x/TLC_460.jpg', 'Mooncolony', 1, NULL, NULL, TRUE, (SELECT id FROM card_sets WHERE slug = 'lost-city-ungoro'), (SELECT id FROM card_types WHERE name = 'Заклинание'), (SELECT id FROM rarities WHERE name = 'Легендарная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Маг'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('FIR_956', 'drakonya-cherepakha_FIR_956', 'Драконья черепаха', '[x]<b>Боевой клич:</b> если у вас в руке
есть существо с <b>«Темным даром»</b>,&
ваш герой получает +3 к атаке
до конца хода и +6 к броне.', 'Если вам казалось, что злобные лавовые черепахи — это недостаточно круто, то эта еще дракон!', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/FIR_956.png', NULL, 'https://art.hearthstonejson.com/v1/512x/FIR_956.jpg', 'Gabor Szikszai', 4, 3, 6, TRUE, (SELECT id FROM card_sets WHERE slug = 'emerald-dream'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Редкая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Воин'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('CORE_RLK_063', 'yarost-ledyanogo-zmeya_CORE_RLK_063', 'Ярость ледяного змея', 'Наносит $5 ед. урона. <b>Замораживает</b> существ противника. Призывает ледяного змея 5/5.', 'Ужасная сила разрушения — но со свежим морозным дыханием!', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/CORE_RLK_063.png', NULL, 'https://art.hearthstonejson.com/v1/512x/CORE_RLK_063.jpg', 'Grafit Studio', 7, NULL, NULL, TRUE, (SELECT id FROM card_sets WHERE slug = 'core'), (SELECT id FROM card_types WHERE name = 'Заклинание'), (SELECT id FROM rarities WHERE name = 'Эпическая'), NULL, NULL, NULL, '{"blood":0,"frost":3,"unholy":0}'::jsonb, (SELECT id FROM classes WHERE name = 'Рыцарь смерти'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('BE_555', 'perezaryadka_BE_555', 'Перезарядка', 'Вы <b>раскапываете</b> заклинание. Его стоимость уменьшается на (8). Эффект повторяется, перенося избыток уменьшения стоимости.', 'Перезаряжайтесь и открывайте огонь.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/BE_555.png', NULL, 'https://art.hearthstonejson.com/v1/512x/BE_555.jpg', 'Timur Shevtsov', 8, NULL, NULL, TRUE, (SELECT id FROM card_sets WHERE slug = 'dark-empire'), (SELECT id FROM card_types WHERE name = 'Заклинание'), (SELECT id FROM rarities WHERE name = 'Эпическая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Охотник'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('TIME_021', 'vyzhivalshchik-sudnogo-dnya_TIME_021', 'Выживальщик судного дня', '<b>Изгой:</b>& ваш герой <b>неуязвим</b> до вашего следующего хода.', 'Я пожертвовал местом в кладовой ради всяких непортящихся продуктов. А какова была ТВОЯ жертва?', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/TIME_021.png', NULL, 'https://art.hearthstonejson.com/v1/512x/TIME_021.jpg', 'Danny Beck', 5, 5, 4, TRUE, (SELECT id FROM card_sets WHERE slug = 'across-the-timeways'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Эпическая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Охотник на демонов'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('BE_EVENT_103', 'styazhatel-sokrovishch_BE_EVENT_103', 'Стяжатель сокровищ', '<b>Боевой клич:</b> вы берете две карты. Разыграв одну, [x]вы сбрасываете вторую.', 'Идите за ним. Что такого может случиться?', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/BE_EVENT_103.png', NULL, 'https://art.hearthstonejson.com/v1/512x/BE_EVENT_103.jpg', 'Max Grecke', 2, 2, 2, TRUE, (SELECT id FROM card_sets WHERE slug = 'event'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Эпическая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Чернокнижник'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('CATA_306', 'skhizma_CATA_306', 'Схизма', '<b>Раскол</b>. Ваше существо получает +2/+3 и <b>«Неуловимость»</b>. Вы призываете его копию.', 'Я знаю, что это половинки одной карты. Она раскололась у меня на глазах!', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/CATA_306.png', NULL, 'https://art.hearthstonejson.com/v1/512x/CATA_306.jpg', 'Grafit Studio', 4, NULL, NULL, TRUE, (SELECT id FROM card_sets WHERE slug = 'cataclysm'), (SELECT id FROM card_types WHERE name = 'Заклинание'), (SELECT id FROM rarities WHERE name = 'Редкая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Жрец'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('CORE_CS2_189', 'elfiyskaya-luchnitsa_CORE_CS2_189', 'Эльфийская лучница', '<b>Боевой клич:</b>
наносит 1 ед. урона.', 'Даже не пытайтесь пригласить ее на свидание. Она умеет стрелять не только глазами.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/CORE_CS2_189.png', NULL, 'https://art.hearthstonejson.com/v1/512x/CORE_CS2_189.jpg', 'Steve Prescott', 1, 1, 1, TRUE, (SELECT id FROM card_sets WHERE slug = 'core'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Обычная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Общие'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('BE_143', 'amitut-khranitel-amitus_BE_143', 'Амитут, хранитель Амитус', '<b>Провокация</b>. <b>Боевой клич:</b>
вы замешиваете в колоду копии всех заклинаний Света в ней. Они <b>разыгрываются при взятии</b>.', 'Хфрьаьнщишткеел-ьгндиецще--еАцмнифт-ущт--упеоуррукчуиел-ищ-лп-оудкдуефрзжуиув-актщь--фгсащррм-офнвикющ-псуруекдвищ--офсцтгашлпьенгырхы--тфвиодрфеенди-йф-тттигтсащншоевт.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/BE_143.png', NULL, 'https://art.hearthstonejson.com/v1/512x/BE_143.jpg', 'Milica Celikovic', 7, 5, 8, TRUE, (SELECT id FROM card_sets WHERE slug = 'dark-empire'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Легендарная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Паладин'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('EDR_031', 'on-ara_EDR_031', 'Он''ара', '[x]В конце вашего хода&
вы разыгрываете 3 верхние
карты из вашей колоды.', 'Таурены и кентавры почитают Он''ару, восхищаясь ее властью над ветром.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/EDR_031.png', NULL, 'https://art.hearthstonejson.com/v1/512x/EDR_031.jpg', 'Alex Stone', 9, 5, 11, TRUE, (SELECT id FROM card_sets WHERE slug = 'emerald-dream'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Легендарная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Шаман'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('TIME_047', 'kovarnyy-koyot_TIME_047', 'Коварный койот', '<b>Маскировка</b>
Стоит на (1) меньше за каждый раз, когда герой противника
[x] получил урон на этом ходу.', 'Что-то здесь не так...', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/TIME_047.png', NULL, 'https://art.hearthstonejson.com/v1/512x/TIME_047.jpg', 'Max Grecke', 5, 5, 3, TRUE, (SELECT id FROM card_sets WHERE slug = 'across-the-timeways'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Обычная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Общие'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('TLC_469', 'tunnelnyy-uzhas_TLC_469', 'Туннельный ужас', '[x]<b>Предсмертный хрип:</b>&
вы получаете 2 случайных
<b>   временных</b> существ за (2).  ', 'С маленькой стильной бородкой, чтобы уравновешивала рог.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/TLC_469.png', NULL, 'https://art.hearthstonejson.com/v1/512x/TLC_469.jpg', 'Ian Ameling', 3, 4, 3, TRUE, (SELECT id FROM card_sets WHERE slug = 'lost-city-ungoro'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Обычная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Чернокнижник'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('MEND_802', 'vosstanovlenie_MEND_802', 'Восстановление', '[x]Призывает двух
паладинов-рекрутов {0}
с <b>«Божественным щитом»</b>.', 'Скоро ты сможешь снова радоваться встрече!', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/MEND_802.png', NULL, 'https://art.hearthstonejson.com/v1/512x/MEND_802.jpg', 'Ramzy Kamen', 2, NULL, NULL, TRUE, (SELECT id FROM card_sets WHERE slug = 'cataclysm'), (SELECT id FROM card_types WHERE name = 'Заклинание'), (SELECT id FROM rarities WHERE name = 'Обычная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Паладин'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('TIME_EVENT_301', 'poslushnik-pogibeli_TIME_EVENT_301', 'Послушник погибели', '<b>Боевой клич:</b> уничтожает другое случайное существо.
Эффект повторяется за каждого дракона у вас в руке.', 'Дракон отваги, дракон мудрости и дракон силы. Соберите их всех, чтобы победить.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/TIME_EVENT_301.png', NULL, 'https://art.hearthstonejson.com/v1/512x/TIME_EVENT_301.jpg', 'Alex Stone', 8, 8, 8, TRUE, (SELECT id FROM card_sets WHERE slug = 'event'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Эпическая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Общие'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('TIME_616', 'voploshchennoe-vospominanie_TIME_616', 'Воплощенное воспоминание', 'Призывает ваше существо-нежить с наивысшей стоимостью, погибшее в этом матче.', '«Просто дайте мне умереть!»', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/TIME_616.png', NULL, 'https://art.hearthstonejson.com/v1/512x/TIME_616.jpg', 'Felideus Bubastis', 4, NULL, NULL, TRUE, (SELECT id FROM card_sets WHERE slug = 'across-the-timeways'), (SELECT id FROM card_types WHERE name = 'Заклинание'), (SELECT id FROM rarities WHERE name = 'Редкая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Рыцарь смерти'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('BE_552', 'ogneplyuy_BE_552', 'Огнеплюй', '[x]После того как
ваш герой атакует,&
вы получаете
«Форсаж».', 'Наносит раны и тут же прижигает их.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/BE_552.png', NULL, 'https://art.hearthstonejson.com/v1/512x/BE_552.jpg', 'Mauricio Herrera', 3, 3, 2, TRUE, (SELECT id FROM card_sets WHERE slug = 'dark-empire'), (SELECT id FROM card_types WHERE name = 'Оружие'), (SELECT id FROM rarities WHERE name = 'Обычная'), 0, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Охотник'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('DINO_412', 'tortotem_DINO_412', 'Тортотем', 'В конце вашего хода
вы получаете
случайное существо нескольких типов.', 'Тот, кто его уронит, получит сглаз на 7 лет.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/DINO_412.png', NULL, 'https://art.hearthstonejson.com/v1/512x/DINO_412.jpg', 'Studio Hive', 1, 0, 3, TRUE, (SELECT id FROM card_sets WHERE slug = 'lost-city-ungoro'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Редкая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Шаман'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('EDR_257', 'svetlyy-tselitel_EDR_257', 'Светлый целитель', '<b>Провокация</b>. <b>Выберите эффект:</b> получает +3 к атаке и <b>«Божественный щит»</b> или получает +3 к здоровью и <b>«Похищение жизни»</b>.', 'Сколько светлых целителей нужно, чтобы исцелить лампочку?', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/EDR_257.png', NULL, 'https://art.hearthstonejson.com/v1/512x/EDR_257.jpg', 'James Ryman', 4, 3, 3, TRUE, (SELECT id FROM card_sets WHERE slug = 'emerald-dream'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Обычная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Паладин'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('CORE_ICC_214', 'obsidianovaya-statuya_CORE_ICC_214', 'Обсидиановая статуя', '<b>Провокация</b>. <b>Похищение жизни</b>. <b>Предсмертный хрип:</b>& уничтожает случайное существо противника.', 'Скульптор потратил чертовски много времени и сил, вытесывая у этой статуи максимально глумливое, провокационное лицо.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/CORE_ICC_214.png', NULL, 'https://art.hearthstonejson.com/v1/512x/CORE_ICC_214.jpg', 'A. J. Nazzaro', 9, 4, 8, TRUE, (SELECT id FROM card_sets WHERE slug = 'core'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Эпическая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Жрец'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('CATA_202', 'pokhishchennaya-sila_CATA_202', 'Похищенная сила', 'Вы получаете случайную карту другого класса с <b>«Расколом»</b>. <i>(Она уже соединена.)</i>', 'Твоя сила теперь моя!', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/CATA_202.png', NULL, 'https://art.hearthstonejson.com/v1/512x/CATA_202.jpg', 'Patrik Bjorkstrom', 3, NULL, NULL, TRUE, (SELECT id FROM card_sets WHERE slug = 'cataclysm'), (SELECT id FROM card_types WHERE name = 'Заклинание'), (SELECT id FROM rarities WHERE name = 'Обычная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Разбойник'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('JAIL_EVENT_102', 'otchayannaya-vzyatka_JAIL_EVENT_102', 'Отчаянная взятка', '[x]Призывает двух существ
за (2) на сторону каждого
игрока. Ваши существа
превращаются в других
существ на (1) дороже.', 'ВОТ ВСЕ МОИ ДЕНЬГИ!', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/JAIL_EVENT_102.png', NULL, 'https://art.hearthstonejson.com/v1/512x/JAIL_EVENT_102.jpg', 'Alex Stone', 3, NULL, NULL, TRUE, (SELECT id FROM card_sets WHERE slug = 'event'), (SELECT id FROM card_types WHERE name = 'Заклинание'), (SELECT id FROM rarities WHERE name = 'Эпическая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Шаман'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('CORE_BT_292', 'dlan-a-dala_CORE_BT_292', 'Длань А''дала', 'Существо получает +2/+1. Вы берете карту.', 'При случае всегда пожимает руку Гул''дана.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/CORE_BT_292.png', NULL, 'https://art.hearthstonejson.com/v1/512x/CORE_BT_292.jpg', 'Anton Zemskov', 2, NULL, NULL, TRUE, (SELECT id FROM card_sets WHERE slug = 'core'), (SELECT id FROM card_types WHERE name = 'Заклинание'), (SELECT id FROM rarities WHERE name = 'Обычная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Паладин'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('CATA_530', 'nasyshchenie-skvernoy_CATA_530', 'Насыщение Скверной', '<b>Возвещает</b>, что скоро явится {0}. Ваш герой получает <b>«Похищение жизни»</b> до конца хода.', 'Терпеть не могу все эти новые моднючие хипстерские рестораны.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/CATA_530.png', NULL, 'https://art.hearthstonejson.com/v1/512x/CATA_530.jpg', 'Vladimir Kafanov', 2, NULL, NULL, TRUE, (SELECT id FROM card_sets WHERE slug = 'cataclysm'), (SELECT id FROM card_types WHERE name = 'Заклинание'), (SELECT id FROM rarities WHERE name = 'Эпическая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Охотник на демонов'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('TIME_040', 'ugasayushchee-vospominanie_TIME_040', 'Угасающее воспоминание', '[x]<b>Предсмертный хрип:</b>& вы
получаете случайное суще[d]    ство из прошлого за (5).    ', 'Мне пришло в голову отличное описание! ...Хм, как там было...', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/TIME_040.png', NULL, 'https://art.hearthstonejson.com/v1/512x/TIME_040.jpg', 'A. J. Nazzaro', 4, 6, 3, TRUE, (SELECT id FROM card_sets WHERE slug = 'across-the-timeways'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Обычная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Общие'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('DINO_130', 'yaytso-dlinnosheego_DINO_130', 'Яйцо длинношеего', '<b>Предсмертный хрип:</b>& призывает зверя 3/3. Ваши существа получают +1/+1.', 'К сожалению, детеныши длинношеих не называются короткошеими.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/DINO_130.png', NULL, 'https://art.hearthstonejson.com/v1/512x/DINO_130.jpg', 'Todd Harris', 2, 0, 2, TRUE, (SELECT id FROM card_sets WHERE slug = 'lost-city-ungoro'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Обычная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Друид'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('BE_999', 'mekha-tigr_BE_999', 'Меха-тигр', 'В начале хода КАЖДОГО игрока& атакует случайного противника.', 'Почему опять отключился интернет? Да потому что эта киса опять выдернула кабель!', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/BE_999.png', NULL, 'https://art.hearthstonejson.com/v1/512x/BE_999.jpg', 'Gabor Szikszai', 6, 6, 6, TRUE, (SELECT id FROM card_sets WHERE slug = 'dark-empire'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Обычная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Общие'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('EDR_819', 'ursok_EDR_819', 'Урсок', '<b>Боевой клич:</b> атакует ВСЕХ других существ. <b>Предсмертный хрип:</b> воскрешает существ, убитых этим существом.', 'Великий повелитель медведей был настолько могуч, что Кошмар свел его с ума, но не лишил силы.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/EDR_819.png', NULL, 'https://art.hearthstonejson.com/v1/512x/EDR_819.jpg', 'Juan Calle', 9, 6, 14, TRUE, (SELECT id FROM card_sets WHERE slug = 'emerald-dream'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Легендарная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Рыцарь смерти'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('TIME_EVENT_998', 'vremennaya-strazhnitsa-runi_TIME_EVENT_998', 'Временная стражница Руни', '[x]<b>Боевой клич:</b> отправляет
всех существ у вас в руке
   на 2 хода в будущее. Они  
возвратятся с +5/+5.', 'В своей временной линии Руни стала последним выжившим паладином и временной стражницей. Получив благословение Ми''ды, Руни обрела власть над нитями судьбы, сплетая их там, где они нужнее всего.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/TIME_EVENT_998.png', NULL, 'https://art.hearthstonejson.com/v1/512x/TIME_EVENT_998.jpg', 'L. Lullabi & T. Shevtsov', 5, 5, 5, TRUE, (SELECT id FROM card_sets WHERE slug = 'event'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Легендарная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Паладин'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('FIR_904', 'vspyshka-plameni-skverny_FIR_904', 'Вспышка пламени Скверны', '[x]После того как вы применяете
 заклинание Скверны,&
это существо уничтожается
и наносит всем противникам
2 ед. урона.', 'И пламя Скверны терзает душу мне.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/FIR_904.png', NULL, 'https://art.hearthstonejson.com/v1/512x/FIR_904.jpg', 'Alex Stone', 2, 2, 3, TRUE, (SELECT id FROM card_sets WHERE slug = 'emerald-dream'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Редкая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Охотник на демонов'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('TIME_730', 'kaldoray-kultivator_TIME_730', 'Калдорай-культиватор', '<b>Боевой клич:</b> вы <b>раскапываете</b> 2 зверей и помещаете их в конец колоды с +5/+5.', 'Если они всплыли на самый верх колоды — дело плохо.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/TIME_730.png', NULL, 'https://art.hearthstonejson.com/v1/512x/TIME_730.jpg', 'Sergey Tsvelykh', 2, 2, 3, TRUE, (SELECT id FROM card_sets WHERE slug = 'across-the-timeways'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Редкая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Друид'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('CORE_EX1_414', 'grommash-adskiy-krik_CORE_EX1_414', 'Громмаш Адский Крик', '<b>Рывок</b>
+6 к атаке,
если у этого существа неполное здоровье.', 'Громмаш выпил оскверненную кровь Маннорота и обрек орков на зеленую кожу и красные глаза. Возможно, это было не лучшим из его решений.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/CORE_EX1_414.png', NULL, 'https://art.hearthstonejson.com/v1/512x/CORE_EX1_414.jpg', 'Glenn Rane', 8, 4, 9, TRUE, (SELECT id FROM card_sets WHERE slug = 'core'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Легендарная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Воин'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('TLC_251', 'derzkiy-paleomurlok_TLC_251', 'Дерзкий палеомурлок', '<b>Боевой клич:</b>
ваш следующий
эффект <b>«Родни»</b>
  срабатывает дважды.', 'Есть мргрглглр? А если найдет?', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/TLC_251.png', NULL, 'https://art.hearthstonejson.com/v1/512x/TLC_251.jpg', 'Mauricio Herrera', 3, 3, 2, TRUE, (SELECT id FROM card_sets WHERE slug = 'lost-city-ungoro'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Редкая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Общие'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('BE_702', 'tvorets-teney_BE_702', 'Творец теней', '<b>Серия приемов</b>: <b>собирает</b> существо другого класса.', 'Здорово, конечно, но с 4 руками так каждый может.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/BE_702.png', NULL, 'https://art.hearthstonejson.com/v1/512x/BE_702.jpg', 'Patrik Bjorkstrom', 2, 3, 2, TRUE, (SELECT id FROM card_sets WHERE slug = 'dark-empire'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Эпическая'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Разбойник'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('CATA_610', 'posledniy-boy-lo-gosha_CATA_610', 'Последний бой Ло''гоша', 'Существо получает «<b>Предсмертный хрип:</b> призывает случайное существо из вашей руки».', 'Перед лицом Катаклизма Ло''гош и его друзья сражались за будущее Азерота так же отважно, как когда-то бились на потеху толпы в Багровом Круге.', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/CATA_610.png', NULL, 'https://art.hearthstonejson.com/v1/512x/CATA_610.jpg', 'Dmitry Bolotov', 5, NULL, NULL, TRUE, (SELECT id FROM card_sets WHERE slug = 'cataclysm'), (SELECT id FROM card_types WHERE name = 'Заклинание'), (SELECT id FROM rarities WHERE name = 'Обычная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Воин'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('JAIL_EVENT_100', 'kvatson_JAIL_EVENT_100', 'Кватсон', '<b>Боевой клич:</b> вы <b>раскапываете</b> существо. Выберите <i>подозрительное</i> существо, чтобы получить +1/+1.', 'Добро пожаловать на викторину!', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/JAIL_EVENT_100.png', NULL, 'https://art.hearthstonejson.com/v1/512x/JAIL_EVENT_100.jpg', 'Caroline Gariba', 2, 3, 2, TRUE, (SELECT id FROM card_sets WHERE slug = 'event'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Легендарная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Общие'));

INSERT INTO cards (card_code, slug, name, text, flavor_text, image, image_gold, crop_image, artist_name, mana_cost, attack, health, collectible, card_set_id, card_type_id, rarity_id, durability, overload, spell_damage, rune_cost, class_id) VALUES ('CATA_481', 'izo-rat_CATA_481', 'Изо''рат', '[x]<b>Боевой клич:</b> пожирает 2
cлучайные карты из руки противника
и впадает в <b>«Спячку»</b> на 2 хода.
<b>Предсмертный хрип:</b> возвращает
поглощенные карты.', '— Доедать будешь?', 'https://art.hearthstonejson.com/v1/render/latest/ruRU/512x/CATA_481.png', NULL, 'https://art.hearthstonejson.com/v1/512x/CATA_481.jpg', 'Alex Horley Orlandelli', 5, 5, 3, TRUE, (SELECT id FROM card_sets WHERE slug = 'cataclysm'), (SELECT id FROM card_types WHERE name = 'Существо'), (SELECT id FROM rarities WHERE name = 'Легендарная'), NULL, NULL, NULL, NULL, (SELECT id FROM classes WHERE name = 'Разбойник'));
INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CFM_321' AND k.code = 'BATTLECRY';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CFM_321' AND k.code = 'DISCOVER';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CFM_321' AND k.code = 'GRIMY_GOONS';

INSERT INTO card_factions (card_id, faction_id) SELECT c.id, f.id FROM cards c, factions f WHERE c.card_code = 'CFM_321' AND f.code = 'GRIMY_GOONS';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CFM_685' AND k.code = 'BATTLECRY';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CFM_685' AND k.code = 'GRIMY_GOONS';

INSERT INTO card_factions (card_id, faction_id) SELECT c.id, f.id FROM cards c, factions f WHERE c.card_code = 'CFM_685' AND f.code = 'GRIMY_GOONS';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CFM_853' AND k.code = 'BATTLECRY';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CFM_853' AND k.code = 'GRIMY_GOONS';

INSERT INTO card_factions (card_id, faction_id) SELECT c.id, f.id FROM cards c, factions f WHERE c.card_code = 'CFM_853' AND f.code = 'GRIMY_GOONS';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'CFM_715' AND t.name = 'Элементаль';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CFM_715' AND k.code = 'BATTLECRY';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CFM_715' AND k.code = 'JADE_GOLEM';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CFM_715' AND k.code = 'JADE_LOTUS';

INSERT INTO card_factions (card_id, faction_id) SELECT c.id, f.id FROM cards c, factions f WHERE c.card_code = 'CFM_715' AND f.code = 'JADE_LOTUS';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CFM_852' AND k.code = 'BATTLECRY';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CFM_852' AND k.code = 'DISCOVER';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CFM_852' AND k.code = 'JADE_LOTUS';

INSERT INTO card_factions (card_id, faction_id) SELECT c.id, f.id FROM cards c, factions f WHERE c.card_code = 'CFM_852' AND f.code = 'JADE_LOTUS';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CFM_902' AND k.code = 'BATTLECRY';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CFM_902' AND k.code = 'DEATHRATTLE';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CFM_902' AND k.code = 'JADE_GOLEM';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CFM_902' AND k.code = 'JADE_LOTUS';

INSERT INTO card_factions (card_id, faction_id) SELECT c.id, f.id FROM cards c, factions f WHERE c.card_code = 'CFM_902' AND f.code = 'JADE_LOTUS';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CFM_619' AND k.code = 'BATTLECRY';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CFM_619' AND k.code = 'KABAL';

INSERT INTO card_factions (card_id, faction_id) SELECT c.id, f.id FROM cards c, factions f WHERE c.card_code = 'CFM_619' AND f.code = 'KABAL';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CFM_621' AND k.code = 'BATTLECRY';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CFM_621' AND k.code = 'KABAL';

INSERT INTO card_factions (card_id, faction_id) SELECT c.id, f.id FROM cards c, factions f WHERE c.card_code = 'CFM_621' AND f.code = 'KABAL';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CFM_649' AND k.code = 'BATTLECRY';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CFM_649' AND k.code = 'DISCOVER';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CFM_649' AND k.code = 'KABAL';

INSERT INTO card_factions (card_id, faction_id) SELECT c.id, f.id FROM cards c, factions f WHERE c.card_code = 'CFM_649' AND f.code = 'KABAL';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'CATA_432' AND t.name = 'Дракон';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CATA_432' AND k.code = 'COLOSSAL';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CATA_432' AND k.code = 'DIVINE_SHIELD';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CATA_432' AND k.code = 'ELUSIVE';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CATA_432' AND k.code = 'LIFESTEAL';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CATA_432' AND k.code = 'TAUNT';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'CORE_RLK_657' AND t.name = 'Нежить';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CORE_RLK_657' AND k.code = 'BATTLECRY';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CORE_RLK_657' AND k.code = 'DEATHRATTLE';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CORE_RLK_657' AND k.code = 'RUSH';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'FIR_924' AND t.name = 'Зверь';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'FIR_924' AND t.name = 'Элементаль';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'FIR_924' AND k.code = 'BATTLECRY';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'FIR_924' AND k.code = 'DISCOVER';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'BE_207' AND t.name = 'Механизм';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'BE_207' AND k.code = 'DEATHRATTLE';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'BE_207' AND k.code = 'REBORN';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'CORE_AT_052' AND t.name = 'Тотем';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CORE_AT_052' AND k.code = 'OVERLOAD';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'EDR_493' AND t.name = 'Зверь';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'EDR_493' AND t.name = 'Демон';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'EDR_493' AND k.code = 'BATTLECRY';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'RLK_708' AND t.name = 'Дреней';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'RLK_708' AND t.name = 'Нежить';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'RLK_708' AND k.code = 'BATTLECRY';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'RLK_708' AND k.code = 'DEATHRATTLE';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'TLC_522' AND k.code = 'BATTLECRY';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'TLC_522' AND k.code = 'COMBO';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'TLC_522' AND k.code = 'DEATHRATTLE';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'TLC_522' AND k.code = 'STEALTH';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'TIME_890' AND k.code = 'BATTLECRY';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'EDR_480' AND t.name = 'Зверь';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'EDR_480' AND k.code = 'RUSH';

INSERT INTO card_spell_schools (card_id, spell_school_id) SELECT c.id, s.id FROM cards c, spell_schools s WHERE c.card_code = 'END_024' AND s.name = 'Огонь';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'END_024' AND k.code = 'SECRET';

INSERT INTO card_spell_schools (card_id, spell_school_id) SELECT c.id, s.id FROM cards c, spell_schools s WHERE c.card_code = 'EDR_570' AND s.name = 'Тьма';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'EDR_570' AND k.code = 'CHOOSE_ONE';

INSERT INTO card_spell_schools (card_id, spell_school_id) SELECT c.id, s.id FROM cards c, spell_schools s WHERE c.card_code = 'TLC_451' AND s.name = 'Скверна';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'TLC_451' AND k.code = 'DISCOVER';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'CATA_180' AND t.name = 'Мурлок';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CATA_180' AND k.code = 'BATTLECRY';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'BE_784' AND k.code = 'BATTLECRY';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'TIME_020' AND k.code = 'CHARGE';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'TIME_020' AND k.code = 'START_OF_GAME_KEYWORD';

INSERT INTO card_spell_schools (card_id, spell_school_id) SELECT c.id, s.id FROM cards c, spell_schools s WHERE c.card_code = 'CORE_CS2_024' AND s.name = 'Лёд';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CORE_CS2_024' AND k.code = 'FREEZE';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'TLC_EVENT_400' AND k.code = 'SIDE_QUEST';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CATA_EVENT_401' AND k.code = 'SPELLPOWER';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'BE_733' AND k.code = 'RUSH';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'BE_733' AND k.code = 'WINDFURY';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'TLC_446' AND k.code = 'QUEST';

INSERT INTO card_spell_schools (card_id, spell_school_id) SELECT c.id, s.id FROM cards c, spell_schools s WHERE c.card_code = 'CATA_302' AND s.name = 'Свет';

INSERT INTO card_spell_schools (card_id, spell_school_id) SELECT c.id, s.id FROM cards c, spell_schools s WHERE c.card_code = 'BE_EVENT_101' AND s.name = 'Тайная магия';

INSERT INTO card_spell_schools (card_id, spell_school_id) SELECT c.id, s.id FROM cards c, spell_schools s WHERE c.card_code = 'MEND_305' AND s.name = 'Природа';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'DINO_136' AND k.code = 'OUTCAST';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'BE_193' AND t.name = 'Зверь';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'BE_193' AND k.code = 'POISONOUS';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'TIME_713' AND t.name = 'Дракон';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'TIME_713' AND t.name = 'Пират';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'TIME_713' AND k.code = 'BATTLECRY';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CORE_OG_218' AND k.code = 'ENRAGED';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CORE_OG_218' AND k.code = 'TAUNT';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'CATA_151' AND t.name = 'Нага';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CATA_151' AND k.code = 'COLOSSAL';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'TLC_255' AND k.code = 'BATTLECRY';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'TLC_255' AND k.code = 'TRADEABLE';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'CORE_GIL_534' AND t.name = 'Свинобраз';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'CATA_EVENT_400' AND t.name = 'Нежить';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CATA_EVENT_400' AND k.code = 'BATTLECRY';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'EDR_518' AND t.name = 'Элементаль';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'EDR_518' AND k.code = 'BATTLECRY';

INSERT INTO card_spell_schools (card_id, spell_school_id) SELECT c.id, s.id FROM cards c, spell_schools s WHERE c.card_code = 'BE_EVENT_102' AND s.name = 'Тьма';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'TIME_019' AND t.name = 'Элементаль';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'TIME_019' AND k.code = 'BATTLECRY';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'CATA_490' AND t.name = 'Демон';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CATA_490' AND k.code = 'BATTLECRY';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CATA_490' AND k.code = 'TAUNT';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'BE_204' AND k.code = 'BATTLECRY';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'BE_204' AND k.code = 'TAUNT';

INSERT INTO card_spell_schools (card_id, spell_school_id) SELECT c.id, s.id FROM cards c, spell_schools s WHERE c.card_code = 'FIR_954' AND s.name = 'Огонь';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'EDR_950' AND k.code = 'BATTLECRY';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CORE_KAR_057' AND k.code = 'BATTLECRY';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CORE_KAR_057' AND k.code = 'DISCOVER';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'EDR_818' AND t.name = 'Дракон';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'EDR_818' AND t.name = 'Нежить';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'EDR_818' AND k.code = 'DEATHRATTLE';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'EDR_818' AND k.code = 'TAUNT';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'END_006' AND t.name = 'Дракон';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'END_006' AND k.code = 'BATTLECRY';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'CATA_556' AND t.name = 'Дракон';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CATA_556' AND k.code = 'BATTLECRY';

INSERT INTO card_spell_schools (card_id, spell_school_id) SELECT c.id, s.id FROM cards c, spell_schools s WHERE c.card_code = 'TLC_477' AND s.name = 'Свет';

INSERT INTO card_spell_schools (card_id, spell_school_id) SELECT c.id, s.id FROM cards c, spell_schools s WHERE c.card_code = 'CORE_EX1_246' AND s.name = 'Природа';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'FIR_959' AND t.name = 'Дракон';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'FIR_959' AND k.code = 'BATTLECRY';

INSERT INTO card_spell_schools (card_id, spell_school_id) SELECT c.id, s.id FROM cards c, spell_schools s WHERE c.card_code = 'CATA_480' AND s.name = 'Свет';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'TIME_704' AND k.code = 'BATTLECRY';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'TIME_704' AND k.code = 'DISCOVER';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'TLC_820' AND k.code = 'DEATHRATTLE';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'BE_565' AND t.name = 'Зверь';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'BE_565' AND k.code = 'BATTLECRY';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'TLC_EVENT_402' AND k.code = 'DEATHRATTLE';

INSERT INTO card_spell_schools (card_id, spell_school_id) SELECT c.id, s.id FROM cards c, spell_schools s WHERE c.card_code = 'EDR_461' AND s.name = 'Тайная магия';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CATA_724' AND k.code = 'DEATHRATTLE';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CATA_724' AND k.code = 'OVERLOAD';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'CORE_DRG_107' AND t.name = 'Зверь';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'CORE_DRG_107' AND t.name = 'Элементаль';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CORE_DRG_107' AND k.code = 'DEATHRATTLE';

INSERT INTO card_spell_schools (card_id, spell_school_id) SELECT c.id, s.id FROM cards c, spell_schools s WHERE c.card_code = 'BE_222' AND s.name = 'Тьма';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'TLC_246' AND t.name = 'Зверь';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'TLC_246' AND k.code = 'BATTLECRY';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CATA_210' AND k.code = 'DEATHRATTLE';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'FIR_908' AND t.name = 'Зверь';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'FIR_908' AND k.code = 'BATTLECRY';

INSERT INTO card_spell_schools (card_id, spell_school_id) SELECT c.id, s.id FROM cards c, spell_schools s WHERE c.card_code = 'TLC_447' AND s.name = 'Скверна';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'TIME_609' AND k.code = 'BATTLECRY';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'BE_255' AND t.name = 'Зверь';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CATA_EVENT_402' AND k.code = 'COMBO';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'TLC_464' AND k.code = 'DISCOVER';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CORE_EX1_058' AND k.code = 'BATTLECRY';

INSERT INTO card_spell_schools (card_id, spell_school_id) SELECT c.id, s.id FROM cards c, spell_schools s WHERE c.card_code = 'FIR_910' AND s.name = 'Огонь';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'BE_851' AND k.code = 'BATTLECRY';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'TIME_103' AND k.code = 'DEATHRATTLE';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'CATA_EVENT_002' AND t.name = 'Элементаль';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CATA_EVENT_002' AND k.code = 'BATTLECRY';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'CORE_RLK_745' AND t.name = 'Нежить';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CORE_RLK_745' AND k.code = 'REBORN';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'DINO_419' AND k.code = 'BATTLECRY';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'EDR_815' AND t.name = 'Нежить';

INSERT INTO card_spell_schools (card_id, spell_school_id) SELECT c.id, s.id FROM cards c, spell_schools s WHERE c.card_code = 'BE_778' AND s.name = 'Тьма';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'CATA_525' AND t.name = 'Нага';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CATA_525' AND k.code = 'BATTLECRY';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CATA_525' AND k.code = 'RUSH';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'TIME_036' AND k.code = 'BATTLECRY';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'CATA_EVENT_001' AND t.name = 'Зверь';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'CATA_EVENT_001' AND t.name = 'Элементаль';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CATA_EVENT_001' AND k.code = 'BATTLECRY';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'TLC_829' AND t.name = 'Зверь';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'TLC_829' AND k.code = 'BATTLECRY';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'CORE_DRG_079' AND t.name = 'Дракон';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CORE_DRG_079' AND k.code = 'DIVINE_SHIELD';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CORE_DRG_079' AND k.code = 'ELUSIVE';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CORE_DRG_079' AND k.code = 'RUSH';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'FIR_958' AND k.code = 'DEATHRATTLE';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'TIME_213' AND k.code = 'BATTLECRY';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'TIME_EVENT_300' AND k.code = 'DEATHRATTLE';

INSERT INTO card_spell_schools (card_id, spell_school_id) SELECT c.id, s.id FROM cards c, spell_schools s WHERE c.card_code = 'CATA_308' AND s.name = 'Свет';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'EDR_495' AND k.code = 'DEATHRATTLE';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'TIME_034' AND t.name = 'Дракон';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'TIME_034' AND k.code = 'BATTLECRY';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'CORE_WON_351' AND t.name = 'Пират';

INSERT INTO card_spell_schools (card_id, spell_school_id) SELECT c.id, s.id FROM cards c, spell_schools s WHERE c.card_code = 'BE_571' AND s.name = 'Тьма';

INSERT INTO card_spell_schools (card_id, spell_school_id) SELECT c.id, s.id FROM cards c, spell_schools s WHERE c.card_code = 'JAIL_EVENT_101' AND s.name = 'Тьма';

INSERT INTO card_spell_schools (card_id, spell_school_id) SELECT c.id, s.id FROM cards c, spell_schools s WHERE c.card_code = 'CORE_EX1_259' AND s.name = 'Природа';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CORE_EX1_259' AND k.code = 'OVERLOAD';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'TIME_706' AND t.name = 'Мурлок';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'TIME_706' AND k.code = 'BATTLECRY';

INSERT INTO card_spell_schools (card_id, spell_school_id) SELECT c.id, s.id FROM cards c, spell_schools s WHERE c.card_code = 'BE_114' AND s.name = 'Тьма';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CATA_208' AND k.code = 'TAUNT';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'CATA_EVENT_000' AND t.name = 'Элементаль';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CATA_EVENT_000' AND k.code = 'BATTLECRY';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'TLC_460' AND k.code = 'QUEST';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'FIR_956' AND t.name = 'Зверь';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'FIR_956' AND t.name = 'Дракон';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'FIR_956' AND k.code = 'BATTLECRY';

INSERT INTO card_spell_schools (card_id, spell_school_id) SELECT c.id, s.id FROM cards c, spell_schools s WHERE c.card_code = 'CORE_RLK_063' AND s.name = 'Лёд';

INSERT INTO card_spell_schools (card_id, spell_school_id) SELECT c.id, s.id FROM cards c, spell_schools s WHERE c.card_code = 'BE_555' AND s.name = 'Тайная магия';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'BE_555' AND k.code = 'DISCOVER';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'TIME_021' AND k.code = 'OUTCAST';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'BE_EVENT_103' AND t.name = 'Демон';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'BE_EVENT_103' AND k.code = 'BATTLECRY';

INSERT INTO card_spell_schools (card_id, spell_school_id) SELECT c.id, s.id FROM cards c, spell_schools s WHERE c.card_code = 'CATA_306' AND s.name = 'Тьма';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CORE_CS2_189' AND k.code = 'BATTLECRY';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'BE_143' AND k.code = 'BATTLECRY';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'BE_143' AND k.code = 'TAUNT';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'EDR_031' AND t.name = 'Зверь';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'TIME_047' AND t.name = 'Зверь';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'TIME_047' AND k.code = 'STEALTH';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'TLC_469' AND t.name = 'Зверь';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'TLC_469' AND k.code = 'DEATHRATTLE';

INSERT INTO card_spell_schools (card_id, spell_school_id) SELECT c.id, s.id FROM cards c, spell_schools s WHERE c.card_code = 'MEND_802' AND s.name = 'Свет';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'TIME_EVENT_301' AND t.name = 'Дракон';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'TIME_EVENT_301' AND k.code = 'BATTLECRY';

INSERT INTO card_spell_schools (card_id, spell_school_id) SELECT c.id, s.id FROM cards c, spell_schools s WHERE c.card_code = 'TIME_616' AND s.name = 'Тьма';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'DINO_412' AND t.name = 'Тотем';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'EDR_257' AND k.code = 'CHOOSE_ONE';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'EDR_257' AND k.code = 'TAUNT';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CORE_ICC_214' AND k.code = 'DEATHRATTLE';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CORE_ICC_214' AND k.code = 'LIFESTEAL';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CORE_ICC_214' AND k.code = 'TAUNT';

INSERT INTO card_spell_schools (card_id, spell_school_id) SELECT c.id, s.id FROM cards c, spell_schools s WHERE c.card_code = 'CATA_202' AND s.name = 'Тьма';

INSERT INTO card_spell_schools (card_id, spell_school_id) SELECT c.id, s.id FROM cards c, spell_schools s WHERE c.card_code = 'CORE_BT_292' AND s.name = 'Свет';

INSERT INTO card_spell_schools (card_id, spell_school_id) SELECT c.id, s.id FROM cards c, spell_schools s WHERE c.card_code = 'CATA_530' AND s.name = 'Скверна';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'TIME_040' AND t.name = 'Нежить';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'TIME_040' AND k.code = 'DEATHRATTLE';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'DINO_130' AND k.code = 'DEATHRATTLE';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'BE_999' AND t.name = 'Зверь';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'BE_999' AND t.name = 'Механизм';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'EDR_819' AND t.name = 'Зверь';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'EDR_819' AND k.code = 'BATTLECRY';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'EDR_819' AND k.code = 'DEATHRATTLE';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'TIME_EVENT_998' AND t.name = 'Дреней';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'TIME_EVENT_998' AND k.code = 'BATTLECRY';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'FIR_904' AND t.name = 'Элементаль';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'TIME_730' AND k.code = 'BATTLECRY';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'TIME_730' AND k.code = 'DISCOVER';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CORE_EX1_414' AND k.code = 'CHARGE';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CORE_EX1_414' AND k.code = 'ENRAGED';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'TLC_251' AND t.name = 'Мурлок';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'TLC_251' AND k.code = 'BATTLECRY';

INSERT INTO card_tribes (card_id, tribe_id) SELECT c.id, t.id FROM cards c, tribes t WHERE c.card_code = 'JAIL_EVENT_100' AND t.name = 'Зверь';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'JAIL_EVENT_100' AND k.code = 'BATTLECRY';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'JAIL_EVENT_100' AND k.code = 'DISCOVER';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CATA_481' AND k.code = 'BATTLECRY';

INSERT INTO card_keywords (card_id, keyword_id) SELECT c.id, k.id FROM cards c, keywords k WHERE c.card_code = 'CATA_481' AND k.code = 'DEATHRATTLE';


-- Dust costs for standard (non-golden) and golden cards, keyed by rarity name.
INSERT INTO rarity_dust_costs (rarity_id, is_golden, crafting_cost, disenchant_cost)
SELECT r.id, d.is_golden, d.crafting_cost, d.disenchant_cost
FROM rarities r
JOIN (VALUES
    ('Обычная', FALSE, 40, 5),
    ('Редкая', FALSE, 100, 20),
    ('Эпическая', FALSE, 400, 100),
    ('Легендарная', FALSE, 1600, 400),
    ('Бесплатная', FALSE, 0, 0),
    ('Обычная', TRUE, 400, 50),
    ('Редкая', TRUE, 800, 100),
    ('Эпическая', TRUE, 1600, 400),
    ('Легендарная', TRUE, 3200, 1600),
    ('Бесплатная', TRUE, 0, 0)
) AS d(rarity_name, is_golden, crafting_cost, disenchant_cost)
ON r.name = d.rarity_name;

COMMIT;

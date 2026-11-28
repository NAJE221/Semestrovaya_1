BEGIN;

DROP TABLE IF EXISTS
    card_set_group_memberships,
    card_set_groups,
    card_classes,
    card_keywords,
    card_spell_schools,
    card_tribes,
    card_factions,
    cards,
    factions,
    keywords,
    spell_schools,
    tribes,
    rarities,
    card_types,
    classes,
    card_sets
CASCADE;

CREATE TABLE card_sets (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_code VARCHAR(80) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(120) NOT NULL UNIQUE,
    sort_order SMALLINT NOT NULL UNIQUE,
    is_standard BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE classes (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    code VARCHAR(80) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(80) NOT NULL UNIQUE,
    sort_order SMALLINT NOT NULL UNIQUE,
    ornament_svg_path VARCHAR(255) NOT NULL
);

CREATE TABLE card_types (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    code VARCHAR(80) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(80) NOT NULL UNIQUE,
    sort_order SMALLINT NOT NULL UNIQUE
);

CREATE TABLE rarities (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    code VARCHAR(80) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(80) NOT NULL UNIQUE,
    sort_order SMALLINT NOT NULL UNIQUE,
    craft_cost SMALLINT,
    craft_cost_golden SMALLINT,
    disenchant_dust SMALLINT,
    disenchant_dust_golden SMALLINT
);

CREATE TABLE tribes (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    code VARCHAR(80) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(80) NOT NULL UNIQUE,
    sort_order SMALLINT NOT NULL UNIQUE
);

CREATE TABLE spell_schools (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    code VARCHAR(80) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(80) NOT NULL UNIQUE,
    sort_order SMALLINT NOT NULL UNIQUE
);

CREATE TABLE keywords (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    code VARCHAR(100) NOT NULL UNIQUE,
    name VARCHAR(150) NOT NULL,
    slug VARCHAR(120) NOT NULL UNIQUE
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
    artist_name VARCHAR(255),

    mana_cost SMALLINT,
    attack SMALLINT,
    health SMALLINT,
    durability SMALLINT,
    armor SMALLINT,

    collectible BOOLEAN NOT NULL DEFAULT FALSE,

    card_set_id BIGINT REFERENCES card_sets(id),
    card_type_id BIGINT REFERENCES card_types(id),
    rarity_id BIGINT REFERENCES rarities(id)
);

CREATE TABLE card_classes (
    card_id BIGINT NOT NULL REFERENCES cards(id) ON DELETE CASCADE,
    class_id BIGINT NOT NULL REFERENCES classes(id),
    PRIMARY KEY (card_id, class_id)
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
    source VARCHAR(30) NOT NULL CHECK (source IN ('mechanic', 'referenced_tag')),
    PRIMARY KEY (card_id, keyword_id, source)
);

CREATE TABLE card_factions (
    card_id BIGINT NOT NULL REFERENCES cards(id) ON DELETE CASCADE,
    faction_id BIGINT NOT NULL REFERENCES factions(id),
    PRIMARY KEY (card_id, faction_id)
);

COMMIT;

-- Table: eor.idwh2_etalon_nr_fl

-- DROP TABLE IF EXISTS eor.idwh2_etalon_nr_fl;

CREATE TABLE IF NOT EXISTS eor.idwh2_etalon_nr_fl
(
    etalon_registry_id bigint NOT NULL,
    full_name text COLLATE pg_catalog."default",
    family_name text COLLATE pg_catalog."default",
    first_name text COLLATE pg_catalog."default",
    second_name text COLLATE pg_catalog."default",
    birth_date timestamp without time zone,
    doc_number text COLLATE pg_catalog."default",
    doc_date timestamp without time zone,
    address_reg text COLLATE pg_catalog."default",
    address_fakt text COLLATE pg_catalog."default",
    inn text COLLATE pg_catalog."default",
    snils text COLLATE pg_catalog."default",
    gender text COLLATE pg_catalog."default",
    birth_place text COLLATE pg_catalog."default",
    doc_type_id bigint,
    doc_who text COLLATE pg_catalog."default",
    doc_code text COLLATE pg_catalog."default",
    oksm_code text COLLATE pg_catalog."default",
    address_reg_date timestamp without time zone,
    address_close_date timestamp without time zone,
    address_reason_close_id bigint,
    ogrnip text COLLATE pg_catalog."default",
    inn_close_date timestamp without time zone,
    death_date timestamp without time zone,
    death_year smallint,
    birth_year smallint,
    full_name_lat text COLLATE pg_catalog."default",
    family_name_lat text COLLATE pg_catalog."default",
    first_name_lat text COLLATE pg_catalog."default",
    second_name_lat text COLLATE pg_catalog."default",
    doc_type_id_fns bigint,
    CONSTRAINT idwh2_etalon_nr_fl_pk PRIMARY KEY (etalon_registry_id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS eor.idwh2_etalon_nr_fl
    OWNER to r_fors_db_owner;

REVOKE ALL ON TABLE eor.idwh2_etalon_nr_fl FROM fors_db_ext_reader_eor;
REVOKE ALL ON TABLE eor.idwh2_etalon_nr_fl FROM fors_db_user;
REVOKE ALL ON TABLE eor.idwh2_etalon_nr_fl FROM oper_pg_rep;
REVOKE ALL ON TABLE eor.idwh2_etalon_nr_fl FROM r_fors_db_reader;
REVOKE ALL ON TABLE eor.idwh2_etalon_nr_fl FROM sym_sync;

GRANT SELECT ON TABLE eor.idwh2_etalon_nr_fl TO fors_db_ext_reader_eor;

GRANT SELECT ON TABLE eor.idwh2_etalon_nr_fl TO fors_db_user;

GRANT SELECT ON TABLE eor.idwh2_etalon_nr_fl TO oper_pg_rep;

GRANT ALL ON TABLE eor.idwh2_etalon_nr_fl TO r_fors_db_owner;

GRANT SELECT ON TABLE eor.idwh2_etalon_nr_fl TO r_fors_db_reader;

GRANT INSERT, DELETE, SELECT, UPDATE ON TABLE eor.idwh2_etalon_nr_fl TO sym_sync;

COMMENT ON TABLE eor.idwh2_etalon_nr_fl
    IS 'Атриубты иностранного физического лица карточки субъекта ЕОР';

COMMENT ON COLUMN eor.idwh2_etalon_nr_fl.etalon_registry_id
    IS 'Идентификатор субъекта в эталонном реестре';

COMMENT ON COLUMN eor.idwh2_etalon_nr_fl.full_name
    IS 'Наименование ЮЛ или ФИО через пробелы';

COMMENT ON COLUMN eor.idwh2_etalon_nr_fl.family_name
    IS 'Фамилия';

COMMENT ON COLUMN eor.idwh2_etalon_nr_fl.first_name
    IS 'Имя';

COMMENT ON COLUMN eor.idwh2_etalon_nr_fl.second_name
    IS 'Отчество';

COMMENT ON COLUMN eor.idwh2_etalon_nr_fl.birth_date
    IS 'Дата рождения';

COMMENT ON COLUMN eor.idwh2_etalon_nr_fl.doc_number
    IS 'Номер документа';

COMMENT ON COLUMN eor.idwh2_etalon_nr_fl.doc_date
    IS 'Дата документа';

COMMENT ON COLUMN eor.idwh2_etalon_nr_fl.address_reg
    IS 'Адрес места регистрации';

COMMENT ON COLUMN eor.idwh2_etalon_nr_fl.address_fakt
    IS 'Адрес фактического пребывания';

COMMENT ON COLUMN eor.idwh2_etalon_nr_fl.inn
    IS 'Идентификационный номер налогоплательщика (ИНН)';

COMMENT ON COLUMN eor.idwh2_etalon_nr_fl.snils
    IS 'СНИЛС';

COMMENT ON COLUMN eor.idwh2_etalon_nr_fl.gender
    IS 'Пол';

COMMENT ON COLUMN eor.idwh2_etalon_nr_fl.birth_place
    IS 'Место рождения';

COMMENT ON COLUMN eor.idwh2_etalon_nr_fl.doc_type_id
    IS 'Код документа, удостоверяющего личность (ДУЛ) - из ЕГРН - служебное поле';

COMMENT ON COLUMN eor.idwh2_etalon_nr_fl.doc_who
    IS 'Кем выдано ДУЛ';

COMMENT ON COLUMN eor.idwh2_etalon_nr_fl.doc_code
    IS 'Код подразделения ДУЛ';

COMMENT ON COLUMN eor.idwh2_etalon_nr_fl.oksm_code
    IS 'Гражданство';

COMMENT ON COLUMN eor.idwh2_etalon_nr_fl.address_reg_date
    IS 'Дата регистрации по месту жительства';

COMMENT ON COLUMN eor.idwh2_etalon_nr_fl.address_close_date
    IS 'Дата снятия с учета (в отношении умерших физических лиц; ИНН, признанных недействительными)';

COMMENT ON COLUMN eor.idwh2_etalon_nr_fl.address_reason_close_id
    IS 'Код причины снятия с учета (в отношении умерших физических лиц;ИНН, признанных недействительными)';

COMMENT ON COLUMN eor.idwh2_etalon_nr_fl.ogrnip
    IS 'ОГРНИП';

COMMENT ON COLUMN eor.idwh2_etalon_nr_fl.inn_close_date
    IS 'Дата признания ИНН недействительным';

COMMENT ON COLUMN eor.idwh2_etalon_nr_fl.death_date
    IS 'Дата смерти';

COMMENT ON COLUMN eor.idwh2_etalon_nr_fl.death_year
    IS 'Год смерти';

COMMENT ON COLUMN eor.idwh2_etalon_nr_fl.birth_year
    IS 'Год рождения';

COMMENT ON COLUMN eor.idwh2_etalon_nr_fl.full_name_lat
    IS 'ФИО на латинице';

COMMENT ON COLUMN eor.idwh2_etalon_nr_fl.family_name_lat
    IS 'Фамилия на латинице';

COMMENT ON COLUMN eor.idwh2_etalon_nr_fl.first_name_lat
    IS 'Имя на латинице';

COMMENT ON COLUMN eor.idwh2_etalon_nr_fl.second_name_lat
    IS 'Отчество на латинице';

COMMENT ON COLUMN eor.idwh2_etalon_nr_fl.doc_type_id_fns
    IS 'Тип документа из справочника ФНС';
-- Index: idwh2_etalon_nr_fl_14

-- DROP INDEX IF EXISTS eor.idwh2_etalon_nr_fl_14;

CREATE INDEX IF NOT EXISTS idwh2_etalon_nr_fl_14
    ON eor.idwh2_etalon_nr_fl USING btree
    (full_name_lat COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idwh2_etalon_nr_fl_15

-- DROP INDEX IF EXISTS eor.idwh2_etalon_nr_fl_15;

CREATE INDEX IF NOT EXISTS idwh2_etalon_nr_fl_15
    ON eor.idwh2_etalon_nr_fl USING btree
    (ogrnip COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idwh2_etalon_nr_fl_idx01

-- DROP INDEX IF EXISTS eor.idwh2_etalon_nr_fl_idx01;

CREATE INDEX IF NOT EXISTS idwh2_etalon_nr_fl_idx01
    ON eor.idwh2_etalon_nr_fl USING btree
    (upper(doc_number) COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idwh2_etalon_nr_fl_idx02

-- DROP INDEX IF EXISTS eor.idwh2_etalon_nr_fl_idx02;

CREATE INDEX IF NOT EXISTS idwh2_etalon_nr_fl_idx02
    ON eor.idwh2_etalon_nr_fl USING btree
    (upper((((lpad(date_part('day'::text, birth_date)::text, 2, '0'::text) || '-'::text) || lpad(date_part('month'::text, birth_date)::text, 2, '0'::text)) || '-'::text) || lpad((date_part('year'::text, birth_date)::integer % 100)::text, 2, '0'::text)) COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idwh2_etalon_nr_fl_idx03

-- DROP INDEX IF EXISTS eor.idwh2_etalon_nr_fl_idx03;

CREATE INDEX IF NOT EXISTS idwh2_etalon_nr_fl_idx03
    ON eor.idwh2_etalon_nr_fl USING btree
    (upper(full_name) COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idwh2_etalon_nr_fl_idx04

-- DROP INDEX IF EXISTS eor.idwh2_etalon_nr_fl_idx04;

CREATE INDEX IF NOT EXISTS idwh2_etalon_nr_fl_idx04
    ON eor.idwh2_etalon_nr_fl USING btree
    (upper(family_name) COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idwh2_etalon_nr_fl_idx05

-- DROP INDEX IF EXISTS eor.idwh2_etalon_nr_fl_idx05;

CREATE INDEX IF NOT EXISTS idwh2_etalon_nr_fl_idx05
    ON eor.idwh2_etalon_nr_fl USING btree
    (upper(first_name) COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idwh2_etalon_nr_fl_idx06

-- DROP INDEX IF EXISTS eor.idwh2_etalon_nr_fl_idx06;

CREATE INDEX IF NOT EXISTS idwh2_etalon_nr_fl_idx06
    ON eor.idwh2_etalon_nr_fl USING btree
    (upper(second_name) COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idwh2_etalon_nr_fl_idx07

-- DROP INDEX IF EXISTS eor.idwh2_etalon_nr_fl_idx07;

CREATE INDEX IF NOT EXISTS idwh2_etalon_nr_fl_idx07
    ON eor.idwh2_etalon_nr_fl USING btree
    (doc_number COLLATE pg_catalog."default" ASC NULLS LAST, (0) ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idwh2_etalon_nr_fl_idx08

-- DROP INDEX IF EXISTS eor.idwh2_etalon_nr_fl_idx08;

CREATE INDEX IF NOT EXISTS idwh2_etalon_nr_fl_idx08
    ON eor.idwh2_etalon_nr_fl USING btree
    (birth_date ASC NULLS LAST, (0) ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idwh2_etalon_nr_fl_idx09

-- DROP INDEX IF EXISTS eor.idwh2_etalon_nr_fl_idx09;

CREATE INDEX IF NOT EXISTS idwh2_etalon_nr_fl_idx09
    ON eor.idwh2_etalon_nr_fl USING btree
    (full_name COLLATE pg_catalog."default" ASC NULLS LAST, (0) ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idwh2_etalon_nr_fl_idx10

-- DROP INDEX IF EXISTS eor.idwh2_etalon_nr_fl_idx10;

CREATE INDEX IF NOT EXISTS idwh2_etalon_nr_fl_idx10
    ON eor.idwh2_etalon_nr_fl USING btree
    (family_name COLLATE pg_catalog."default" ASC NULLS LAST, (0) ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idwh2_etalon_nr_fl_idx11

-- DROP INDEX IF EXISTS eor.idwh2_etalon_nr_fl_idx11;

CREATE INDEX IF NOT EXISTS idwh2_etalon_nr_fl_idx11
    ON eor.idwh2_etalon_nr_fl USING btree
    (first_name COLLATE pg_catalog."default" ASC NULLS LAST, (0) ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idwh2_etalon_nr_fl_idx12

-- DROP INDEX IF EXISTS eor.idwh2_etalon_nr_fl_idx12;

CREATE INDEX IF NOT EXISTS idwh2_etalon_nr_fl_idx12
    ON eor.idwh2_etalon_nr_fl USING btree
    (second_name COLLATE pg_catalog."default" ASC NULLS LAST, (0) ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idwh2_etalon_nr_fl_idx13

-- DROP INDEX IF EXISTS eor.idwh2_etalon_nr_fl_idx13;

CREATE INDEX IF NOT EXISTS idwh2_etalon_nr_fl_idx13
    ON eor.idwh2_etalon_nr_fl USING btree
    (inn COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
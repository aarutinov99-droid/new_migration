-- Table: eor.idwh2_etalon_flrn

-- DROP TABLE IF EXISTS eor.idwh2_etalon_flrn;

CREATE TABLE IF NOT EXISTS eor.idwh2_etalon_flrn
(
    etalon_registry_id bigint NOT NULL,
    inn text COLLATE pg_catalog."default",
    snils text COLLATE pg_catalog."default",
    full_name text COLLATE pg_catalog."default",
    family_name text COLLATE pg_catalog."default",
    first_name text COLLATE pg_catalog."default",
    second_name text COLLATE pg_catalog."default",
    gender text COLLATE pg_catalog."default",
    birth_date timestamp without time zone,
    birth_place text COLLATE pg_catalog."default",
    doc_type_id bigint,
    doc_number text COLLATE pg_catalog."default",
    doc_date timestamp without time zone,
    doc_who text COLLATE pg_catalog."default",
    doc_code text COLLATE pg_catalog."default",
    oksm_code text COLLATE pg_catalog."default",
    address text COLLATE pg_catalog."default",
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
    address_reg text COLLATE pg_catalog."default",
    CONSTRAINT idwh2_etalon_flrn_pk PRIMARY KEY (etalon_registry_id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS eor.idwh2_etalon_flrn
    OWNER to r_fors_db_owner;

REVOKE ALL ON TABLE eor.idwh2_etalon_flrn FROM fors_db_ext_reader_eor;
REVOKE ALL ON TABLE eor.idwh2_etalon_flrn FROM fors_db_user;
REVOKE ALL ON TABLE eor.idwh2_etalon_flrn FROM oper_pg_rep;
REVOKE ALL ON TABLE eor.idwh2_etalon_flrn FROM r_fors_db_reader;
REVOKE ALL ON TABLE eor.idwh2_etalon_flrn FROM sym_sync;

GRANT SELECT ON TABLE eor.idwh2_etalon_flrn TO fors_db_ext_reader_eor;

GRANT SELECT ON TABLE eor.idwh2_etalon_flrn TO fors_db_user;

GRANT SELECT ON TABLE eor.idwh2_etalon_flrn TO oper_pg_rep;

GRANT ALL ON TABLE eor.idwh2_etalon_flrn TO r_fors_db_owner;

GRANT SELECT ON TABLE eor.idwh2_etalon_flrn TO r_fors_db_reader;

GRANT INSERT, DELETE, SELECT, UPDATE ON TABLE eor.idwh2_etalon_flrn TO sym_sync;

COMMENT ON TABLE eor.idwh2_etalon_flrn
    IS 'Атрибуты физического лица карточки субъекта ЕОР';

COMMENT ON COLUMN eor.idwh2_etalon_flrn.etalon_registry_id
    IS 'Идентификатор';

COMMENT ON COLUMN eor.idwh2_etalon_flrn.inn
    IS 'Идентификационный номер налогоплательщика (ИНН)';

COMMENT ON COLUMN eor.idwh2_etalon_flrn.snils
    IS 'СНИЛС';

COMMENT ON COLUMN eor.idwh2_etalon_flrn.full_name
    IS 'ФИО';

COMMENT ON COLUMN eor.idwh2_etalon_flrn.family_name
    IS 'Фамилия';

COMMENT ON COLUMN eor.idwh2_etalon_flrn.first_name
    IS 'Имя';

COMMENT ON COLUMN eor.idwh2_etalon_flrn.second_name
    IS 'Отчество';

COMMENT ON COLUMN eor.idwh2_etalon_flrn.gender
    IS 'Пол';

COMMENT ON COLUMN eor.idwh2_etalon_flrn.birth_date
    IS 'Дата рождения';

COMMENT ON COLUMN eor.idwh2_etalon_flrn.birth_place
    IS 'Место рождения';

COMMENT ON COLUMN eor.idwh2_etalon_flrn.doc_type_id
    IS 'Код документа, удостоверяющего личность (ДУЛ)';

COMMENT ON COLUMN eor.idwh2_etalon_flrn.doc_number
    IS 'Серия, номер ДУЛ';

COMMENT ON COLUMN eor.idwh2_etalon_flrn.doc_date
    IS 'Дата выдачи ДУЛ';

COMMENT ON COLUMN eor.idwh2_etalon_flrn.doc_who
    IS 'Кем выдано ДУЛ';

COMMENT ON COLUMN eor.idwh2_etalon_flrn.doc_code
    IS 'Код подразделения ДУЛ';

COMMENT ON COLUMN eor.idwh2_etalon_flrn.oksm_code
    IS 'Гражданство';

COMMENT ON COLUMN eor.idwh2_etalon_flrn.address
    IS 'Адрес места жительства (пребывания)';

COMMENT ON COLUMN eor.idwh2_etalon_flrn.address_reg_date
    IS 'Дата регистрации по месту жительства';

COMMENT ON COLUMN eor.idwh2_etalon_flrn.address_close_date
    IS 'Дата снятия с учета (в отношении умерших физических лиц; ИНН, признанных недействительными)';

COMMENT ON COLUMN eor.idwh2_etalon_flrn.address_reason_close_id
    IS 'Код причины снятия с учета (в отношении умерших физических лиц;ИНН, признанных недействительными)';

COMMENT ON COLUMN eor.idwh2_etalon_flrn.ogrnip
    IS 'ОГРНИП';

COMMENT ON COLUMN eor.idwh2_etalon_flrn.inn_close_date
    IS 'Дата признания ИНН недействительным';

COMMENT ON COLUMN eor.idwh2_etalon_flrn.death_date
    IS 'Дата смерти';

COMMENT ON COLUMN eor.idwh2_etalon_flrn.death_year
    IS 'Год смерти';

COMMENT ON COLUMN eor.idwh2_etalon_flrn.birth_year
    IS 'Год рождения';

COMMENT ON COLUMN eor.idwh2_etalon_flrn.full_name_lat
    IS 'ФИО на латинице';

COMMENT ON COLUMN eor.idwh2_etalon_flrn.family_name_lat
    IS 'Фамилия на латинице';

COMMENT ON COLUMN eor.idwh2_etalon_flrn.first_name_lat
    IS 'Имя на латинице';

COMMENT ON COLUMN eor.idwh2_etalon_flrn.second_name_lat
    IS 'Отчество на латинице';

COMMENT ON COLUMN eor.idwh2_etalon_flrn.doc_type_id_fns
    IS 'Тип документа из справочника ФНС';

COMMENT ON COLUMN eor.idwh2_etalon_flrn.address_reg
    IS 'Адрес места регистрации';
-- Index: idwh2_etalon_flrn_idx_00

-- DROP INDEX IF EXISTS eor.idwh2_etalon_flrn_idx_00;

CREATE INDEX IF NOT EXISTS idwh2_etalon_flrn_idx_00
    ON eor.idwh2_etalon_flrn USING btree
    (full_name COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idwh2_etalon_flrn_idx_01

-- DROP INDEX IF EXISTS eor.idwh2_etalon_flrn_idx_01;

CREATE INDEX IF NOT EXISTS idwh2_etalon_flrn_idx_01
    ON eor.idwh2_etalon_flrn USING btree
    (inn COLLATE pg_catalog."default" ASC NULLS LAST, snils COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idwh2_etalon_flrn_idx_02

-- DROP INDEX IF EXISTS eor.idwh2_etalon_flrn_idx_02;

CREATE INDEX IF NOT EXISTS idwh2_etalon_flrn_idx_02
    ON eor.idwh2_etalon_flrn USING btree
    (upper(inn) COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idwh2_etalon_flrn_idx_03

-- DROP INDEX IF EXISTS eor.idwh2_etalon_flrn_idx_03;

CREATE INDEX IF NOT EXISTS idwh2_etalon_flrn_idx_03
    ON eor.idwh2_etalon_flrn USING btree
    (upper(snils) COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idwh2_etalon_flrn_idx_04

-- DROP INDEX IF EXISTS eor.idwh2_etalon_flrn_idx_04;

CREATE INDEX IF NOT EXISTS idwh2_etalon_flrn_idx_04
    ON eor.idwh2_etalon_flrn USING btree
    (upper(full_name) COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idwh2_etalon_flrn_idx_05

-- DROP INDEX IF EXISTS eor.idwh2_etalon_flrn_idx_05;

CREATE INDEX IF NOT EXISTS idwh2_etalon_flrn_idx_05
    ON eor.idwh2_etalon_flrn USING btree
    (upper(family_name) COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idwh2_etalon_flrn_idx_06

-- DROP INDEX IF EXISTS eor.idwh2_etalon_flrn_idx_06;

CREATE INDEX IF NOT EXISTS idwh2_etalon_flrn_idx_06
    ON eor.idwh2_etalon_flrn USING btree
    (upper(first_name) COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idwh2_etalon_flrn_idx_07

-- DROP INDEX IF EXISTS eor.idwh2_etalon_flrn_idx_07;

CREATE INDEX IF NOT EXISTS idwh2_etalon_flrn_idx_07
    ON eor.idwh2_etalon_flrn USING btree
    (upper(second_name) COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idwh2_etalon_flrn_idx_08

-- DROP INDEX IF EXISTS eor.idwh2_etalon_flrn_idx_08;

CREATE INDEX IF NOT EXISTS idwh2_etalon_flrn_idx_08
    ON eor.idwh2_etalon_flrn USING btree
    (birth_date ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idwh2_etalon_flrn_idx_09

-- DROP INDEX IF EXISTS eor.idwh2_etalon_flrn_idx_09;

CREATE INDEX IF NOT EXISTS idwh2_etalon_flrn_idx_09
    ON eor.idwh2_etalon_flrn USING btree
    (upper(doc_number) COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idwh2_etalon_flrn_idx_10

-- DROP INDEX IF EXISTS eor.idwh2_etalon_flrn_idx_10;

CREATE INDEX IF NOT EXISTS idwh2_etalon_flrn_idx_10
    ON eor.idwh2_etalon_flrn USING btree
    (upper(oksm_code) COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idwh2_etalon_flrn_idx_11

-- DROP INDEX IF EXISTS eor.idwh2_etalon_flrn_idx_11;

CREATE INDEX IF NOT EXISTS idwh2_etalon_flrn_idx_11
    ON eor.idwh2_etalon_flrn USING btree
    (upper(address) COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idwh2_etalon_flrn_idx_12

-- DROP INDEX IF EXISTS eor.idwh2_etalon_flrn_idx_12;

CREATE INDEX IF NOT EXISTS idwh2_etalon_flrn_idx_12
    ON eor.idwh2_etalon_flrn USING btree
    (upper(ogrnip) COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idwh2_etalon_flrn_idx_13

-- DROP INDEX IF EXISTS eor.idwh2_etalon_flrn_idx_13;

CREATE INDEX IF NOT EXISTS idwh2_etalon_flrn_idx_13
    ON eor.idwh2_etalon_flrn USING btree
    (doc_number COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idwh2_etalon_flrn_idx_14

-- DROP INDEX IF EXISTS eor.idwh2_etalon_flrn_idx_14;

CREATE INDEX IF NOT EXISTS idwh2_etalon_flrn_idx_14
    ON eor.idwh2_etalon_flrn USING btree
    (family_name COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idwh2_etalon_flrn_idx_15

-- DROP INDEX IF EXISTS eor.idwh2_etalon_flrn_idx_15;

CREATE INDEX IF NOT EXISTS idwh2_etalon_flrn_idx_15
    ON eor.idwh2_etalon_flrn USING btree
    (full_name_lat COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idwh2_etalon_flrn_idx_16

-- DROP INDEX IF EXISTS eor.idwh2_etalon_flrn_idx_16;

CREATE INDEX IF NOT EXISTS idwh2_etalon_flrn_idx_16
    ON eor.idwh2_etalon_flrn USING btree
    (ogrnip COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idwh2_etalon_flrn_idx_17

-- DROP INDEX IF EXISTS eor.idwh2_etalon_flrn_idx_17;

CREATE INDEX IF NOT EXISTS idwh2_etalon_flrn_idx_17
    ON eor.idwh2_etalon_flrn USING btree
    (address COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idwh2_etalon_flrn_idx_18

-- DROP INDEX IF EXISTS eor.idwh2_etalon_flrn_idx_18;

CREATE INDEX IF NOT EXISTS idwh2_etalon_flrn_idx_18
    ON eor.idwh2_etalon_flrn USING btree
    (full_name COLLATE pg_catalog."default" ASC NULLS LAST, birth_date ASC NULLS LAST, etalon_registry_id ASC NULLS LAST)
    TABLESPACE pg_default;
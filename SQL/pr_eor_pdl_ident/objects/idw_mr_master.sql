-- Table: eor.idw_mr_master

-- DROP TABLE IF EXISTS eor.idw_mr_master;

CREATE TABLE IF NOT EXISTS eor.idw_mr_master
(
    master_id bigint,
    etalon_registry_id bigint NOT NULL,
    name text COLLATE pg_catalog."default",
    status bigint,
    er_type_id bigint,
    is_actual bigint DEFAULT 1,
    risk_level bigint,
    attention_level bigint,
    feature_count bigint,
    subject_type bigint,
    ko_sign character(1) COLLATE pg_catalog."default",
    ip_sign character(1) COLLATE pg_catalog."default",
    nr_sign character(1) COLLATE pg_catalog."default",
    filial_sign character(1) COLLATE pg_catalog."default",
    head_org_id bigint,
    name_full text COLLATE pg_catalog."default",
    name_short text COLLATE pg_catalog."default",
    inn text COLLATE pg_catalog."default",
    ogrn text COLLATE pg_catalog."default",
    bic text COLLATE pg_catalog."default",
    swift text COLLATE pg_catalog."default",
    start_date timestamp without time zone,
    eor_h_id bigint,
    eor_h_date timestamp without time zone,
    etalon_sign character(1) COLLATE pg_catalog."default",
    manual_sign character(1) COLLATE pg_catalog."default",
    deleted_sign character(1) COLLATE pg_catalog."default",
    eor_change_id bigint,
    object_change_role_id bigint,
    local_change_type_id bigint,
    rating integer DEFAULT 0,
    rating_date timestamp without time zone DEFAULT now(),
    CONSTRAINT "idw_mr_master$i1" PRIMARY KEY (etalon_registry_id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS eor.idw_mr_master
    OWNER to r_fors_db_owner;

REVOKE ALL ON TABLE eor.idw_mr_master FROM fors_db_ext_reader_eor;
REVOKE ALL ON TABLE eor.idw_mr_master FROM fors_db_user;
REVOKE ALL ON TABLE eor.idw_mr_master FROM oper_pg_rep;
REVOKE ALL ON TABLE eor.idw_mr_master FROM r_t_fors_pft_link;
REVOKE ALL ON TABLE eor.idw_mr_master FROM sym_sync;

GRANT SELECT ON TABLE eor.idw_mr_master TO fors_db_ext_reader_eor;

GRANT SELECT ON TABLE eor.idw_mr_master TO fors_db_user;

GRANT SELECT ON TABLE eor.idw_mr_master TO oper_pg_rep;

GRANT ALL ON TABLE eor.idw_mr_master TO r_fors_db_owner;

GRANT SELECT ON TABLE eor.idw_mr_master TO r_t_fors_pft_link;

GRANT INSERT, DELETE, SELECT, UPDATE ON TABLE eor.idw_mr_master TO sym_sync;

COMMENT ON TABLE eor.idw_mr_master
    IS 'Карточки субъектов ЕОР';

COMMENT ON COLUMN eor.idw_mr_master.master_id
    IS 'Идентификатор записи';

COMMENT ON COLUMN eor.idw_mr_master.etalon_registry_id
    IS 'Суррогатный ключ на запись в одном из эталонных реестров';

COMMENT ON COLUMN eor.idw_mr_master.name
    IS 'Наименование субъекта';

COMMENT ON COLUMN eor.idw_mr_master.status
    IS 'Статус субъекта';

COMMENT ON COLUMN eor.idw_mr_master.er_type_id
    IS 'Идентифкатор эталонного реестра (1 - реестр РКО, 2 - реестр ЮЛ)';

COMMENT ON COLUMN eor.idw_mr_master.is_actual
    IS 'Индикатор актуальности записи';

COMMENT ON COLUMN eor.idw_mr_master.risk_level
    IS 'Уровень риска (отношение числа сработавших признаков к общему числу признаков) 0..100';

COMMENT ON COLUMN eor.idw_mr_master.attention_level
    IS 'Уровень внимания (показатель, вычисляемый на основе классификатора по типам субъектов) 0..100';

COMMENT ON COLUMN eor.idw_mr_master.feature_count
    IS 'Число сработавших признаков (макс ~ 300)';

COMMENT ON COLUMN eor.idw_mr_master.subject_type
    IS 'Тип лица. ЮЛ/ФЛ. IDW_SR_PERSON_TYPE';

COMMENT ON COLUMN eor.idw_mr_master.ko_sign
    IS 'Признак КО. 1/0';

COMMENT ON COLUMN eor.idw_mr_master.ip_sign
    IS 'Признак ИП. 1/0';

COMMENT ON COLUMN eor.idw_mr_master.nr_sign
    IS 'Признак Нерезидента. 1/0';

COMMENT ON COLUMN eor.idw_mr_master.filial_sign
    IS 'Признак филиала. 1/0';

COMMENT ON COLUMN eor.idw_mr_master.head_org_id
    IS 'ИД головной органинизации - ETALON_REGISTRY_ID. Для филиала - FILIAL_SIGN=1.';

COMMENT ON COLUMN eor.idw_mr_master.name_full
    IS 'Для филиалов КО: <Полное имя КО> - филиал <Имя филиала>.
Для филиалов ЮЛ: Полное имя из ЕГРПО, либо <Полное имя ЮЛ> - филиал.
Для ФЛ: Фамилия Имя Отчество.';

COMMENT ON COLUMN eor.idw_mr_master.name_short
    IS 'Для филиалов КО:  <Краткое имя КО> - филиал <Имя филиала>.
Для филиалов ЮЛ:  Краткое имя из ЕГРПО, либо <Краткое имя ЮЛ> - филиал.
Для ФЛ:  Фамилия И.О.';

COMMENT ON COLUMN eor.idw_mr_master.inn
    IS 'ИНН';

COMMENT ON COLUMN eor.idw_mr_master.ogrn
    IS 'ОГРН/ОГРНИП/рег. номер иностранной организации';

COMMENT ON COLUMN eor.idw_mr_master.bic
    IS 'БИК';

COMMENT ON COLUMN eor.idw_mr_master.swift
    IS 'SWIFT';

COMMENT ON COLUMN eor.idw_mr_master.start_date
    IS 'ФЛ - дата рождения, ЮЛ - дата регистрации, Филиалы - дата открытия филиала';

COMMENT ON COLUMN eor.idw_mr_master.eor_h_id
    IS 'ИД версии записи';

COMMENT ON COLUMN eor.idw_mr_master.eor_h_date
    IS 'Дата версии записи';

COMMENT ON COLUMN eor.idw_mr_master.etalon_sign
    IS 'Признак эталонной записи';

COMMENT ON COLUMN eor.idw_mr_master.manual_sign
    IS 'Признак ручной коррекции';

COMMENT ON COLUMN eor.idw_mr_master.deleted_sign
    IS 'Признак удаления';

COMMENT ON COLUMN eor.idw_mr_master.eor_change_id
    IS 'ИД изменения для нескольких информационных объектов';

COMMENT ON COLUMN eor.idw_mr_master.object_change_role_id
    IS 'Роль объекта в операции над ЕОР. IDW_SR_EOR_CHANGE_ROLE';

COMMENT ON COLUMN eor.idw_mr_master.local_change_type_id
    IS 'Тип изменения карточки в контексте операции над IDWH2.IDW_SR_EOR_CHANGE_TYPE';

COMMENT ON COLUMN eor.idw_mr_master.rating
    IS 'Рейтинг записи. Показывает насколько полные атрибуты.';

COMMENT ON COLUMN eor.idw_mr_master.rating_date
    IS 'Дата установки рейтинга';
-- Index: idw_mr_master$10

-- DROP INDEX IF EXISTS eor."idw_mr_master$10";

CREATE INDEX IF NOT EXISTS "idw_mr_master$10"
    ON eor.idw_mr_master USING btree
    (name COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idw_mr_master$11

-- DROP INDEX IF EXISTS eor."idw_mr_master$11";

CREATE UNIQUE INDEX IF NOT EXISTS "idw_mr_master$11"
    ON eor.idw_mr_master USING btree
    (eor_h_id ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idw_mr_master$12

-- DROP INDEX IF EXISTS eor."idw_mr_master$12";

CREATE INDEX IF NOT EXISTS "idw_mr_master$12"
    ON eor.idw_mr_master USING btree
    (ogrn COLLATE pg_catalog."default" ASC NULLS LAST, er_type_id ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idw_mr_master$20

-- DROP INDEX IF EXISTS eor."idw_mr_master$20";

CREATE INDEX IF NOT EXISTS "idw_mr_master$20"
    ON eor.idw_mr_master USING btree
    (inn COLLATE pg_catalog."default" ASC NULLS LAST, etalon_sign COLLATE pg_catalog."default" ASC NULLS LAST, filial_sign COLLATE pg_catalog."default" ASC NULLS LAST, deleted_sign COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idw_mr_master$7

-- DROP INDEX IF EXISTS eor."idw_mr_master$7";

CREATE INDEX IF NOT EXISTS "idw_mr_master$7"
    ON eor.idw_mr_master USING btree
    (eor_change_id ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idw_mr_master$i13

-- DROP INDEX IF EXISTS eor."idw_mr_master$i13";

CREATE INDEX IF NOT EXISTS "idw_mr_master$i13"
    ON eor.idw_mr_master USING btree
    (bic COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idw_mr_master$i14

-- DROP INDEX IF EXISTS eor."idw_mr_master$i14";

CREATE INDEX IF NOT EXISTS "idw_mr_master$i14"
    ON eor.idw_mr_master USING btree
    (deleted_sign COLLATE pg_catalog."default" ASC NULLS LAST, etalon_registry_id ASC NULLS LAST, name_full COLLATE pg_catalog."default" ASC NULLS LAST, er_type_id ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idw_mr_master$i15

-- DROP INDEX IF EXISTS eor."idw_mr_master$i15";

CREATE INDEX IF NOT EXISTS "idw_mr_master$i15"
    ON eor.idw_mr_master USING btree
    (start_date ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idw_mr_master$i16

-- DROP INDEX IF EXISTS eor."idw_mr_master$i16";

CREATE INDEX IF NOT EXISTS "idw_mr_master$i16"
    ON eor.idw_mr_master USING btree
    (etalon_sign COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idw_mr_master$i17

-- DROP INDEX IF EXISTS eor."idw_mr_master$i17";

CREATE INDEX IF NOT EXISTS "idw_mr_master$i17"
    ON eor.idw_mr_master USING btree
    (er_type_id ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idw_mr_master$i2

-- DROP INDEX IF EXISTS eor."idw_mr_master$i2";

CREATE INDEX IF NOT EXISTS "idw_mr_master$i2"
    ON eor.idw_mr_master USING btree
    (master_id ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idw_mr_master$i3

-- DROP INDEX IF EXISTS eor."idw_mr_master$i3";

CREATE INDEX IF NOT EXISTS "idw_mr_master$i3"
    ON eor.idw_mr_master USING btree
    (er_type_id ASC NULLS LAST, etalon_registry_id ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idw_mr_master$i4

-- DROP INDEX IF EXISTS eor."idw_mr_master$i4";

CREATE INDEX IF NOT EXISTS "idw_mr_master$i4"
    ON eor.idw_mr_master USING btree
    (er_type_id ASC NULLS LAST, upper(name) COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idw_mr_master$i5

-- DROP INDEX IF EXISTS eor."idw_mr_master$i5";

CREATE INDEX IF NOT EXISTS "idw_mr_master$i5"
    ON eor.idw_mr_master USING btree
    (attention_level ASC NULLS LAST, risk_level ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idw_mr_master$i6

-- DROP INDEX IF EXISTS eor."idw_mr_master$i6";

CREATE INDEX IF NOT EXISTS "idw_mr_master$i6"
    ON eor.idw_mr_master USING btree
    (head_org_id ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idw_mr_master$i8

-- DROP INDEX IF EXISTS eor."idw_mr_master$i8";

CREATE INDEX IF NOT EXISTS "idw_mr_master$i8"
    ON eor.idw_mr_master USING btree
    (er_type_id ASC NULLS LAST, length(translate(name, 'а"- ()[]$%!&''+,*/.'::text, 'а'::text)) ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idw_mr_master$i9

-- DROP INDEX IF EXISTS eor."idw_mr_master$i9";

CREATE INDEX IF NOT EXISTS "idw_mr_master$i9"
    ON eor.idw_mr_master USING btree
    (inn COLLATE pg_catalog."default" ASC NULLS LAST, ogrn COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idw_mr_master_name_ci

-- DROP INDEX IF EXISTS eor.idw_mr_master_name_ci;

CREATE INDEX IF NOT EXISTS idw_mr_master_name_ci
    ON eor.idw_mr_master USING btree
    (upper(name) COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
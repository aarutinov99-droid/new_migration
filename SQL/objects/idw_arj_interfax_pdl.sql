-- Table: pdl.idw_arj_interfax_pdl

-- DROP TABLE IF EXISTS pdl.idw_arj_interfax_pdl;

CREATE TABLE IF NOT EXISTS pdl.idw_arj_interfax_pdl
(
    load_id bigint,
    updated_at character varying(50) COLLATE pg_catalog."default",
    system_id character varying(50) COLLATE pg_catalog."default",
    full_name character varying(1000) COLLATE pg_catalog."default",
    date_birthday character varying(20) COLLATE pg_catalog."default",
    date_death character varying(20) COLLATE pg_catalog."default",
    birth_place character varying(4000) COLLATE pg_catalog."default",
    dead character varying(20) COLLATE pg_catalog."default",
    gender character varying(10) COLLATE pg_catalog."default",
    names xml,
    translit_names xml,
    countries xml,
    categories xml,
    category407 xml,
    jobs xml,
    incomes xml,
    ownerships xml,
    sanlists xml,
    sanctions xml,
    relatives xml,
    biography xml,
    create_date timestamp without time zone DEFAULT now(),
    err_msg character varying(4000) COLLATE pg_catalog."default",
    sr_subject_id bigint DEFAULT 0,
    date_load timestamp without time zone,
    "position" character varying(4000) COLLATE pg_catalog."default",
    authority character varying(4000) COLLATE pg_catalog."default",
    country_names character varying(4000) COLLATE pg_catalog."default",
    names_err character varying(4000) COLLATE pg_catalog."default",
    translit_names_err character varying(4000) COLLATE pg_catalog."default",
    countries_err character varying(4000) COLLATE pg_catalog."default",
    categories_err character varying(4000) COLLATE pg_catalog."default",
    category407_err character varying(4000) COLLATE pg_catalog."default",
    jobs_err character varying(4000) COLLATE pg_catalog."default",
    incomes_err character varying(4000) COLLATE pg_catalog."default",
    ownerships_err character varying(4000) COLLATE pg_catalog."default",
    sanlists_err character varying(4000) COLLATE pg_catalog."default",
    sanctions_err character varying(4000) COLLATE pg_catalog."default",
    relatives_err character varying(4000) COLLATE pg_catalog."default",
    biography_err character varying(4000) COLLATE pg_catalog."default",
    persdocs xml,
    addresses xml,
    contact_infos xml,
    persdocs_err character varying(4000) COLLATE pg_catalog."default",
    addresses_err character varying(4000) COLLATE pg_catalog."default",
    contact_infos_err character varying(4000) COLLATE pg_catalog."default",
    is_load boolean DEFAULT false
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS pdl.idw_arj_interfax_pdl
    OWNER to r_arch_db_owner;

REVOKE ALL ON TABLE pdl.idw_arj_interfax_pdl FROM arch_pg_db_reader;
REVOKE ALL ON TABLE pdl.idw_arj_interfax_pdl FROM r_arch_db_reader;

GRANT SELECT ON TABLE pdl.idw_arj_interfax_pdl TO arch_pg_db_reader;

GRANT ALL ON TABLE pdl.idw_arj_interfax_pdl TO r_arch_db_owner;

GRANT SELECT ON TABLE pdl.idw_arj_interfax_pdl TO r_arch_db_reader;

GRANT ALL ON TABLE pdl.idw_arj_interfax_pdl TO t_reg_proc;

COMMENT ON TABLE pdl.idw_arj_interfax_pdl
    IS 'Архивный слой публичных должностных лиц (ИНТЕРФАКС X-Complience)';

COMMENT ON COLUMN pdl.idw_arj_interfax_pdl.load_id
    IS 'ИД загрузки';

COMMENT ON COLUMN pdl.idw_arj_interfax_pdl.updated_at
    IS 'Дата обновления анкеты';

COMMENT ON COLUMN pdl.idw_arj_interfax_pdl.system_id
    IS 'ИД субъекта';

COMMENT ON COLUMN pdl.idw_arj_interfax_pdl.full_name
    IS 'ФИО';

COMMENT ON COLUMN pdl.idw_arj_interfax_pdl.date_birthday
    IS 'Дата рождения';

COMMENT ON COLUMN pdl.idw_arj_interfax_pdl.date_death
    IS 'Дата смерти';

COMMENT ON COLUMN pdl.idw_arj_interfax_pdl.birth_place
    IS 'Место рождения';

COMMENT ON COLUMN pdl.idw_arj_interfax_pdl.dead
    IS 'Признак умер';

COMMENT ON COLUMN pdl.idw_arj_interfax_pdl.gender
    IS 'Пол';

COMMENT ON COLUMN pdl.idw_arj_interfax_pdl.names
    IS 'Имена';

COMMENT ON COLUMN pdl.idw_arj_interfax_pdl.translit_names
    IS 'Варианты имен в транслите';

COMMENT ON COLUMN pdl.idw_arj_interfax_pdl.countries
    IS 'Гражданства';

COMMENT ON COLUMN pdl.idw_arj_interfax_pdl.categories
    IS 'Категории лица';

COMMENT ON COLUMN pdl.idw_arj_interfax_pdl.category407
    IS 'Категории 407 (известны только коды)';

COMMENT ON COLUMN pdl.idw_arj_interfax_pdl.jobs
    IS 'Места работы)';

COMMENT ON COLUMN pdl.idw_arj_interfax_pdl.incomes
    IS 'Доходы';

COMMENT ON COLUMN pdl.idw_arj_interfax_pdl.ownerships
    IS 'Имущество';

COMMENT ON COLUMN pdl.idw_arj_interfax_pdl.sanlists
    IS 'Санкционные листы в, в которые включено данное физическое лицо';

COMMENT ON COLUMN pdl.idw_arj_interfax_pdl.sanctions
    IS 'Санкции, в которые включено физическое лицо';

COMMENT ON COLUMN pdl.idw_arj_interfax_pdl.relatives
    IS 'Лица, связанные с данным лицом (в том числе родственники)';

COMMENT ON COLUMN pdl.idw_arj_interfax_pdl.biography
    IS 'Биография';

COMMENT ON COLUMN pdl.idw_arj_interfax_pdl.create_date
    IS 'Дата создания записи';

COMMENT ON COLUMN pdl.idw_arj_interfax_pdl.err_msg
    IS 'Сообщение об ошибке';

COMMENT ON COLUMN pdl.idw_arj_interfax_pdl.sr_subject_id
    IS 'ИД субъекта спецреестра';

COMMENT ON COLUMN pdl.idw_arj_interfax_pdl.date_load
    IS 'Дата загрузки';

COMMENT ON COLUMN pdl.idw_arj_interfax_pdl."position"
    IS 'Последняя занимаемая должность';

COMMENT ON COLUMN pdl.idw_arj_interfax_pdl.authority
    IS 'Последнее место работы';

COMMENT ON COLUMN pdl.idw_arj_interfax_pdl.country_names
    IS 'Наименования стран - гражданств субъекта';

COMMENT ON COLUMN pdl.idw_arj_interfax_pdl.names_err
    IS 'Ошибка разбора имен';

COMMENT ON COLUMN pdl.idw_arj_interfax_pdl.translit_names_err
    IS 'Ошибка разбора имен в транслите';

COMMENT ON COLUMN pdl.idw_arj_interfax_pdl.countries_err
    IS 'Ошибка разбора гражданства';

COMMENT ON COLUMN pdl.idw_arj_interfax_pdl.categories_err
    IS 'Ошибка разбора категорий';

COMMENT ON COLUMN pdl.idw_arj_interfax_pdl.category407_err
    IS 'Ошибка разбора категорий 407';

COMMENT ON COLUMN pdl.idw_arj_interfax_pdl.jobs_err
    IS 'Ошибка разбора мест работы';

COMMENT ON COLUMN pdl.idw_arj_interfax_pdl.incomes_err
    IS 'Ошибка разбора доходов';

COMMENT ON COLUMN pdl.idw_arj_interfax_pdl.ownerships_err
    IS 'Ошибка разбора собственности';

COMMENT ON COLUMN pdl.idw_arj_interfax_pdl.sanlists_err
    IS 'Ошибка разбора санкционных листов';

COMMENT ON COLUMN pdl.idw_arj_interfax_pdl.sanctions_err
    IS 'Ошибка разбора санкций';

COMMENT ON COLUMN pdl.idw_arj_interfax_pdl.relatives_err
    IS 'Ошибка разбора связей';

COMMENT ON COLUMN pdl.idw_arj_interfax_pdl.biography_err
    IS 'Ошибка разбора биографии';

COMMENT ON COLUMN pdl.idw_arj_interfax_pdl.persdocs
    IS 'ДУЛ-ы';

COMMENT ON COLUMN pdl.idw_arj_interfax_pdl.addresses
    IS 'Адреса';

COMMENT ON COLUMN pdl.idw_arj_interfax_pdl.contact_infos
    IS 'Контакты';

COMMENT ON COLUMN pdl.idw_arj_interfax_pdl.persdocs_err
    IS 'Ошибка разбора ДУЛ-ов';

COMMENT ON COLUMN pdl.idw_arj_interfax_pdl.addresses_err
    IS 'Ошибка разбора адресов';

COMMENT ON COLUMN pdl.idw_arj_interfax_pdl.contact_infos_err
    IS 'Ошибка разбора контактов';
-- Index: idw_arj_interfax_pdl_country_names_idx

-- DROP INDEX IF EXISTS pdl.idw_arj_interfax_pdl_country_names_idx;

CREATE INDEX IF NOT EXISTS idw_arj_interfax_pdl_country_names_idx
    ON pdl.idw_arj_interfax_pdl USING btree
    (country_names COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idw_arj_interfax_pdl_load_id_idx

-- DROP INDEX IF EXISTS pdl.idw_arj_interfax_pdl_load_id_idx;

CREATE INDEX IF NOT EXISTS idw_arj_interfax_pdl_load_id_idx
    ON pdl.idw_arj_interfax_pdl USING btree
    (load_id ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idw_arj_interfax_pdl_position_idx

-- DROP INDEX IF EXISTS pdl.idw_arj_interfax_pdl_position_idx;

CREATE INDEX IF NOT EXISTS idw_arj_interfax_pdl_position_idx
    ON pdl.idw_arj_interfax_pdl USING btree
    ("position" COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idw_arj_interfax_pdl_sr_subject_id_idx

-- DROP INDEX IF EXISTS pdl.idw_arj_interfax_pdl_sr_subject_id_idx;

CREATE INDEX IF NOT EXISTS idw_arj_interfax_pdl_sr_subject_id_idx
    ON pdl.idw_arj_interfax_pdl USING btree
    (sr_subject_id ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idw_arj_interfax_pdl_system_id_idx

-- DROP INDEX IF EXISTS pdl.idw_arj_interfax_pdl_system_id_idx;

CREATE INDEX IF NOT EXISTS idw_arj_interfax_pdl_system_id_idx
    ON pdl.idw_arj_interfax_pdl USING btree
    (system_id COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
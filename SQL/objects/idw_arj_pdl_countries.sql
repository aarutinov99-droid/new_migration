-- Table: pdl.idw_arj_pdl_countries

-- DROP TABLE IF EXISTS pdl.idw_arj_pdl_countries;

CREATE TABLE IF NOT EXISTS pdl.idw_arj_pdl_countries
(
    id bigint NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1 ),
    load_id bigint NOT NULL,
    system_id character varying(50) COLLATE pg_catalog."default",
    updated_at timestamp without time zone,
    iso character varying(4000) COLLATE pg_catalog."default",
    en character varying(4000) COLLATE pg_catalog."default",
    country_name character varying(4000) COLLATE pg_catalog."default",
    create_date timestamp without time zone NOT NULL DEFAULT now(),
    create_user character varying(250) COLLATE pg_catalog."default" NOT NULL DEFAULT SESSION_USER,
    is_load boolean DEFAULT false,
    CONSTRAINT idw_arj_pdl_countries_pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS pdl.idw_arj_pdl_countries
    OWNER to r_arch_db_owner;

REVOKE ALL ON TABLE pdl.idw_arj_pdl_countries FROM arch_pg_db_reader;
REVOKE ALL ON TABLE pdl.idw_arj_pdl_countries FROM r_arch_db_reader;

GRANT SELECT ON TABLE pdl.idw_arj_pdl_countries TO arch_pg_db_reader;

GRANT ALL ON TABLE pdl.idw_arj_pdl_countries TO r_arch_db_owner;

GRANT SELECT ON TABLE pdl.idw_arj_pdl_countries TO r_arch_db_reader;

GRANT ALL ON TABLE pdl.idw_arj_pdl_countries TO t_reg_proc;

COMMENT ON TABLE pdl.idw_arj_pdl_countries
    IS 'Предназначен для выгрузки данных по странам, гражданином которых является данное лицо';

COMMENT ON COLUMN pdl.idw_arj_pdl_countries.id
    IS 'ИД';

COMMENT ON COLUMN pdl.idw_arj_pdl_countries.load_id
    IS 'ИД загрузки';

COMMENT ON COLUMN pdl.idw_arj_pdl_countries.system_id
    IS 'ИД субъекта';

COMMENT ON COLUMN pdl.idw_arj_pdl_countries.updated_at
    IS 'дата последнего обновления данных';

COMMENT ON COLUMN pdl.idw_arj_pdl_countries.iso
    IS 'код страны';

COMMENT ON COLUMN pdl.idw_arj_pdl_countries.en
    IS 'наименование страны на английском';

COMMENT ON COLUMN pdl.idw_arj_pdl_countries.country_name
    IS 'страна';

COMMENT ON COLUMN pdl.idw_arj_pdl_countries.create_date
    IS 'дата создания';

COMMENT ON COLUMN pdl.idw_arj_pdl_countries.create_user
    IS 'Автор';
-- Index: idw_arj_pdl_countries_id_idx

-- DROP INDEX IF EXISTS pdl.idw_arj_pdl_countries_id_idx;

CREATE UNIQUE INDEX IF NOT EXISTS idw_arj_pdl_countries_id_idx
    ON pdl.idw_arj_pdl_countries USING btree
    (id ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idw_arj_pdl_countries_load_id_system_id_idx

-- DROP INDEX IF EXISTS pdl.idw_arj_pdl_countries_load_id_system_id_idx;

CREATE INDEX IF NOT EXISTS idw_arj_pdl_countries_load_id_system_id_idx
    ON pdl.idw_arj_pdl_countries USING btree
    (load_id ASC NULLS LAST, system_id COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
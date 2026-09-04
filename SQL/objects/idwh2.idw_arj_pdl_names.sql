-- Table: pdl.idw_arj_pdl_names

-- DROP TABLE IF EXISTS pdl.idw_arj_pdl_names;

CREATE TABLE IF NOT EXISTS pdl.idw_arj_pdl_names
(
    id bigint NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1 ),
    load_id bigint NOT NULL,
    system_id character varying(50) COLLATE pg_catalog."default",
    locale character varying(20) COLLATE pg_catalog."default",
    updated_at timestamp without time zone,
    last_name character varying(4000) COLLATE pg_catalog."default",
    first_name character varying(4000) COLLATE pg_catalog."default",
    middle_name character varying(4000) COLLATE pg_catalog."default",
    full_name character varying(4000) COLLATE pg_catalog."default",
    create_date timestamp without time zone NOT NULL DEFAULT now(),
    create_user character varying(250) COLLATE pg_catalog."default" NOT NULL DEFAULT SESSION_USER,
    is_load boolean DEFAULT false,
    CONSTRAINT idw_arj_pdl_names_pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS pdl.idw_arj_pdl_names
    OWNER to r_arch_db_owner;

REVOKE ALL ON TABLE pdl.idw_arj_pdl_names FROM arch_pg_db_reader;
REVOKE ALL ON TABLE pdl.idw_arj_pdl_names FROM r_arch_db_reader;

GRANT SELECT ON TABLE pdl.idw_arj_pdl_names TO arch_pg_db_reader;

GRANT ALL ON TABLE pdl.idw_arj_pdl_names TO r_arch_db_owner;

GRANT SELECT ON TABLE pdl.idw_arj_pdl_names TO r_arch_db_reader;

GRANT ALL ON TABLE pdl.idw_arj_pdl_names TO t_reg_proc;

COMMENT ON TABLE pdl.idw_arj_pdl_names
    IS 'Предназначен для выгрузки основного и альтернативных имен (ФИО) физических лиц';

COMMENT ON COLUMN pdl.idw_arj_pdl_names.id
    IS 'ИД';

COMMENT ON COLUMN pdl.idw_arj_pdl_names.load_id
    IS 'ИД загрузки';

COMMENT ON COLUMN pdl.idw_arj_pdl_names.system_id
    IS 'ИД субъекта';

COMMENT ON COLUMN pdl.idw_arj_pdl_names.locale
    IS 'язык';

COMMENT ON COLUMN pdl.idw_arj_pdl_names.updated_at
    IS 'дата последнего обновления данных';

COMMENT ON COLUMN pdl.idw_arj_pdl_names.last_name
    IS 'фамилия';

COMMENT ON COLUMN pdl.idw_arj_pdl_names.first_name
    IS 'имя';

COMMENT ON COLUMN pdl.idw_arj_pdl_names.middle_name
    IS 'отчество';

COMMENT ON COLUMN pdl.idw_arj_pdl_names.full_name
    IS 'ФИО';

COMMENT ON COLUMN pdl.idw_arj_pdl_names.create_date
    IS 'Дата создания';

COMMENT ON COLUMN pdl.idw_arj_pdl_names.create_user
    IS 'Автор';
-- Index: idw_arj_pdl_names_load_id_system_id_idx

-- DROP INDEX IF EXISTS pdl.idw_arj_pdl_names_load_id_system_id_idx;

CREATE INDEX IF NOT EXISTS idw_arj_pdl_names_load_id_system_id_idx
    ON pdl.idw_arj_pdl_names USING btree
    (load_id ASC NULLS LAST, system_id COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
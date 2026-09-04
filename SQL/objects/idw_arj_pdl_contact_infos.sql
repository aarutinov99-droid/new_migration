-- Table: pdl.idw_arj_pdl_contact_infos

-- DROP TABLE IF EXISTS pdl.idw_arj_pdl_contact_infos;

CREATE TABLE IF NOT EXISTS pdl.idw_arj_pdl_contact_infos
(
    id bigint NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1 ),
    load_id bigint NOT NULL,
    system_id character varying(50) COLLATE pg_catalog."default",
    updated_at timestamp without time zone,
    type character varying(50) COLLATE pg_catalog."default",
    contact_infos character varying(4000) COLLATE pg_catalog."default",
    create_date timestamp without time zone NOT NULL DEFAULT now(),
    create_user character varying(250) COLLATE pg_catalog."default" NOT NULL DEFAULT SESSION_USER,
    is_load boolean DEFAULT false,
    CONSTRAINT idw_arj_pdl_contact_infos_pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS pdl.idw_arj_pdl_contact_infos
    OWNER to r_arch_db_owner;

REVOKE ALL ON TABLE pdl.idw_arj_pdl_contact_infos FROM arch_pg_db_reader;
REVOKE ALL ON TABLE pdl.idw_arj_pdl_contact_infos FROM r_arch_db_reader;

GRANT SELECT ON TABLE pdl.idw_arj_pdl_contact_infos TO arch_pg_db_reader;

GRANT ALL ON TABLE pdl.idw_arj_pdl_contact_infos TO r_arch_db_owner;

GRANT SELECT ON TABLE pdl.idw_arj_pdl_contact_infos TO r_arch_db_reader;

GRANT ALL ON TABLE pdl.idw_arj_pdl_contact_infos TO t_reg_proc;

COMMENT ON TABLE pdl.idw_arj_pdl_contact_infos
    IS 'Предназначен для выгрузки списка контактов принадлежащих физическому лицу';

COMMENT ON COLUMN pdl.idw_arj_pdl_contact_infos.id
    IS 'ИД';

COMMENT ON COLUMN pdl.idw_arj_pdl_contact_infos.load_id
    IS 'ИД загрузки';

COMMENT ON COLUMN pdl.idw_arj_pdl_contact_infos.system_id
    IS 'ИД субъекта';

COMMENT ON COLUMN pdl.idw_arj_pdl_contact_infos.updated_at
    IS 'Дата обновления информации';

COMMENT ON COLUMN pdl.idw_arj_pdl_contact_infos.type
    IS 'Тип контакта';

COMMENT ON COLUMN pdl.idw_arj_pdl_contact_infos.contact_infos
    IS 'Сущность контакт';

COMMENT ON COLUMN pdl.idw_arj_pdl_contact_infos.create_date
    IS 'Дата создания';

COMMENT ON COLUMN pdl.idw_arj_pdl_contact_infos.create_user
    IS 'Автор';
-- Index: idw_arj_pdl_contact_infos_id_idx

-- DROP INDEX IF EXISTS pdl.idw_arj_pdl_contact_infos_id_idx;

CREATE UNIQUE INDEX IF NOT EXISTS idw_arj_pdl_contact_infos_id_idx
    ON pdl.idw_arj_pdl_contact_infos USING btree
    (id ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idw_arj_pdl_contact_infos_load_id_system_id_idx

-- DROP INDEX IF EXISTS pdl.idw_arj_pdl_contact_infos_load_id_system_id_idx;

CREATE INDEX IF NOT EXISTS idw_arj_pdl_contact_infos_load_id_system_id_idx
    ON pdl.idw_arj_pdl_contact_infos USING btree
    (load_id ASC NULLS LAST, system_id COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
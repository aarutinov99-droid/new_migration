-- Table: pdl.idw_arj_pdl_sanlists

-- DROP TABLE IF EXISTS pdl.idw_arj_pdl_sanlists;

CREATE TABLE IF NOT EXISTS pdl.idw_arj_pdl_sanlists
(
    id bigint NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1 ),
    load_id bigint NOT NULL,
    system_id character varying(50) COLLATE pg_catalog."default",
    updated_at timestamp without time zone,
    sanlist_id bigint,
    sanlist character varying(4000) COLLATE pg_catalog."default",
    create_date timestamp without time zone NOT NULL DEFAULT now(),
    create_user character varying(250) COLLATE pg_catalog."default" NOT NULL DEFAULT SESSION_USER,
    is_load boolean DEFAULT false,
    CONSTRAINT idw_arj_pdl_sanlists_pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS pdl.idw_arj_pdl_sanlists
    OWNER to r_arch_db_owner;

REVOKE ALL ON TABLE pdl.idw_arj_pdl_sanlists FROM arch_pg_db_reader;
REVOKE ALL ON TABLE pdl.idw_arj_pdl_sanlists FROM r_arch_db_reader;

GRANT SELECT ON TABLE pdl.idw_arj_pdl_sanlists TO arch_pg_db_reader;

GRANT ALL ON TABLE pdl.idw_arj_pdl_sanlists TO r_arch_db_owner;

GRANT SELECT ON TABLE pdl.idw_arj_pdl_sanlists TO r_arch_db_reader;

GRANT ALL ON TABLE pdl.idw_arj_pdl_sanlists TO t_reg_proc;

COMMENT ON TABLE pdl.idw_arj_pdl_sanlists
    IS 'Предназначен для выгрузки списка санкционных листов, в которые включено данное физическое лицо';

COMMENT ON COLUMN pdl.idw_arj_pdl_sanlists.id
    IS 'ИД';

COMMENT ON COLUMN pdl.idw_arj_pdl_sanlists.load_id
    IS 'ИД загрузки';

COMMENT ON COLUMN pdl.idw_arj_pdl_sanlists.system_id
    IS 'ИД субъекта';

COMMENT ON COLUMN pdl.idw_arj_pdl_sanlists.updated_at
    IS 'дата обновления информации';

COMMENT ON COLUMN pdl.idw_arj_pdl_sanlists.sanlist_id
    IS 'внутренний идентификатор санкционного листа в Системе X-Compliance';

COMMENT ON COLUMN pdl.idw_arj_pdl_sanlists.sanlist
    IS 'санкционный лист';

COMMENT ON COLUMN pdl.idw_arj_pdl_sanlists.create_date
    IS 'Дата создания';

COMMENT ON COLUMN pdl.idw_arj_pdl_sanlists.create_user
    IS 'Автор';
-- Index: idw_arj_pdl_sanlists_id_idx

-- DROP INDEX IF EXISTS pdl.idw_arj_pdl_sanlists_id_idx;

CREATE UNIQUE INDEX IF NOT EXISTS idw_arj_pdl_sanlists_id_idx
    ON pdl.idw_arj_pdl_sanlists USING btree
    (id ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idw_arj_pdl_sanlists_load_id_system_id_idx

-- DROP INDEX IF EXISTS pdl.idw_arj_pdl_sanlists_load_id_system_id_idx;

CREATE INDEX IF NOT EXISTS idw_arj_pdl_sanlists_load_id_system_id_idx
    ON pdl.idw_arj_pdl_sanlists USING btree
    (load_id ASC NULLS LAST, system_id COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
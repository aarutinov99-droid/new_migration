-- Table: pdl.idw_arj_pdl_category407

-- DROP TABLE IF EXISTS pdl.idw_arj_pdl_category407;

CREATE TABLE IF NOT EXISTS pdl.idw_arj_pdl_category407
(
    id bigint NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1 ),
    load_id bigint NOT NULL,
    system_id character varying(50) COLLATE pg_catalog."default",
    category_code character varying(4000) COLLATE pg_catalog."default",
    create_date timestamp without time zone NOT NULL DEFAULT now(),
    create_user character varying(250) COLLATE pg_catalog."default" NOT NULL DEFAULT SESSION_USER,
    is_load boolean DEFAULT false,
    CONSTRAINT idw_arj_pdl_category407_pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS pdl.idw_arj_pdl_category407
    OWNER to r_arch_db_owner;

REVOKE ALL ON TABLE pdl.idw_arj_pdl_category407 FROM arch_pg_db_reader;
REVOKE ALL ON TABLE pdl.idw_arj_pdl_category407 FROM r_arch_db_reader;

GRANT SELECT ON TABLE pdl.idw_arj_pdl_category407 TO arch_pg_db_reader;

GRANT ALL ON TABLE pdl.idw_arj_pdl_category407 TO r_arch_db_owner;

GRANT SELECT ON TABLE pdl.idw_arj_pdl_category407 TO r_arch_db_reader;

GRANT ALL ON TABLE pdl.idw_arj_pdl_category407 TO t_reg_proc;

COMMENT ON TABLE pdl.idw_arj_pdl_category407
    IS 'Предназначен для выгрузки списка значений признака «Категория 407». ';

COMMENT ON COLUMN pdl.idw_arj_pdl_category407.id
    IS 'ИД';

COMMENT ON COLUMN pdl.idw_arj_pdl_category407.load_id
    IS 'ИД загрузки';

COMMENT ON COLUMN pdl.idw_arj_pdl_category407.system_id
    IS 'ИД субъекта';

COMMENT ON COLUMN pdl.idw_arj_pdl_category407.category_code
    IS 'код категории';

COMMENT ON COLUMN pdl.idw_arj_pdl_category407.create_date
    IS 'дата создания';

COMMENT ON COLUMN pdl.idw_arj_pdl_category407.create_user
    IS 'автор';
-- Index: idw_arj_pdl_category407_id_idx

-- DROP INDEX IF EXISTS pdl.idw_arj_pdl_category407_id_idx;

CREATE UNIQUE INDEX IF NOT EXISTS idw_arj_pdl_category407_id_idx
    ON pdl.idw_arj_pdl_category407 USING btree
    (id ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idw_arj_pdl_category407_load_id_system_id_idx

-- DROP INDEX IF EXISTS pdl.idw_arj_pdl_category407_load_id_system_id_idx;

CREATE INDEX IF NOT EXISTS idw_arj_pdl_category407_load_id_system_id_idx
    ON pdl.idw_arj_pdl_category407 USING btree
    (load_id ASC NULLS LAST, system_id COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
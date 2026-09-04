-- Table: pdl.idw_arj_pdl_jobs

-- DROP TABLE IF EXISTS pdl.idw_arj_pdl_jobs;

CREATE TABLE IF NOT EXISTS pdl.idw_arj_pdl_jobs
(
    id bigint NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1 ),
    load_id bigint NOT NULL,
    system_id character varying(50) COLLATE pg_catalog."default",
    updated_at timestamp without time zone,
    date_start timestamp without time zone,
    date_end timestamp without time zone,
    source character varying(4000) COLLATE pg_catalog."default",
    main character varying(50) COLLATE pg_catalog."default",
    unactive character varying(50) COLLATE pg_catalog."default",
    name character varying(4000) COLLATE pg_catalog."default",
    authority character varying(4000) COLLATE pg_catalog."default",
    reg_id character varying(4000) COLLATE pg_catalog."default",
    create_date timestamp without time zone NOT NULL DEFAULT now(),
    create_user character varying(250) COLLATE pg_catalog."default" NOT NULL DEFAULT SESSION_USER,
    is_load boolean DEFAULT false,
    CONSTRAINT idw_arj_pdl_jobs_pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS pdl.idw_arj_pdl_jobs
    OWNER to r_arch_db_owner;

REVOKE ALL ON TABLE pdl.idw_arj_pdl_jobs FROM arch_pg_db_reader;
REVOKE ALL ON TABLE pdl.idw_arj_pdl_jobs FROM r_arch_db_reader;

GRANT SELECT ON TABLE pdl.idw_arj_pdl_jobs TO arch_pg_db_reader;

GRANT ALL ON TABLE pdl.idw_arj_pdl_jobs TO r_arch_db_owner;

GRANT SELECT ON TABLE pdl.idw_arj_pdl_jobs TO r_arch_db_reader;

GRANT ALL ON TABLE pdl.idw_arj_pdl_jobs TO t_reg_proc;

COMMENT ON TABLE pdl.idw_arj_pdl_jobs
    IS 'Предназначен для выгрузки данных по должностям персоны';

COMMENT ON COLUMN pdl.idw_arj_pdl_jobs.id
    IS 'ИД';

COMMENT ON COLUMN pdl.idw_arj_pdl_jobs.load_id
    IS 'ИД загрузки';

COMMENT ON COLUMN pdl.idw_arj_pdl_jobs.system_id
    IS 'ИД субъекта';

COMMENT ON COLUMN pdl.idw_arj_pdl_jobs.updated_at
    IS 'дата обновления информации';

COMMENT ON COLUMN pdl.idw_arj_pdl_jobs.date_start
    IS 'дата начала работы на должности';

COMMENT ON COLUMN pdl.idw_arj_pdl_jobs.date_end
    IS 'дата завершения работы на данной должности';

COMMENT ON COLUMN pdl.idw_arj_pdl_jobs.source
    IS 'ссылка на источник информации или соответствующий указ';

COMMENT ON COLUMN pdl.idw_arj_pdl_jobs.main
    IS 'признак «основная»/ «неосновная» должность';

COMMENT ON COLUMN pdl.idw_arj_pdl_jobs.unactive
    IS 'неактивна';

COMMENT ON COLUMN pdl.idw_arj_pdl_jobs.name
    IS 'наименование должности';

COMMENT ON COLUMN pdl.idw_arj_pdl_jobs.authority
    IS 'наименование ведомства ';

COMMENT ON COLUMN pdl.idw_arj_pdl_jobs.reg_id
    IS 'уникальный идентификатор ведомства';

COMMENT ON COLUMN pdl.idw_arj_pdl_jobs.create_date
    IS 'дата создания';

COMMENT ON COLUMN pdl.idw_arj_pdl_jobs.create_user
    IS 'автор';
-- Index: idw_arj_pdl_jobs_id_idx

-- DROP INDEX IF EXISTS pdl.idw_arj_pdl_jobs_id_idx;

CREATE UNIQUE INDEX IF NOT EXISTS idw_arj_pdl_jobs_id_idx
    ON pdl.idw_arj_pdl_jobs USING btree
    (id ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idw_arj_pdl_jobs_load_id_system_id_idx

-- DROP INDEX IF EXISTS pdl.idw_arj_pdl_jobs_load_id_system_id_idx;

CREATE INDEX IF NOT EXISTS idw_arj_pdl_jobs_load_id_system_id_idx
    ON pdl.idw_arj_pdl_jobs USING btree
    (load_id ASC NULLS LAST, system_id COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
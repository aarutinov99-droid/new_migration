-- Table: pdl.idw_arj_pdl_sanctions

-- DROP TABLE IF EXISTS pdl.idw_arj_pdl_sanctions;

CREATE TABLE IF NOT EXISTS pdl.idw_arj_pdl_sanctions
(
    id bigint NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1 ),
    load_id bigint NOT NULL,
    system_id character varying(50) COLLATE pg_catalog."default",
    sanction character varying(4000) COLLATE pg_catalog."default",
    date_start timestamp without time zone,
    date_end timestamp without time zone,
    source character varying(4000) COLLATE pg_catalog."default",
    reason_inclusion character varying(4000) COLLATE pg_catalog."default",
    sanlist character varying(4000) COLLATE pg_catalog."default",
    country character varying(4000) COLLATE pg_catalog."default",
    extra_informations character varying(4000) COLLATE pg_catalog."default",
    uidd character varying(4000) COLLATE pg_catalog."default",
    last_update_in_source timestamp without time zone,
    create_date timestamp without time zone NOT NULL DEFAULT now(),
    create_user character varying(250) COLLATE pg_catalog."default" NOT NULL DEFAULT SESSION_USER,
    is_load boolean DEFAULT false,
    CONSTRAINT idw_arj_pdl_sanctions_pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS pdl.idw_arj_pdl_sanctions
    OWNER to r_arch_db_owner;

REVOKE ALL ON TABLE pdl.idw_arj_pdl_sanctions FROM arch_pg_db_reader;
REVOKE ALL ON TABLE pdl.idw_arj_pdl_sanctions FROM r_arch_db_reader;

GRANT SELECT ON TABLE pdl.idw_arj_pdl_sanctions TO arch_pg_db_reader;

GRANT ALL ON TABLE pdl.idw_arj_pdl_sanctions TO r_arch_db_owner;

GRANT SELECT ON TABLE pdl.idw_arj_pdl_sanctions TO r_arch_db_reader;

GRANT ALL ON TABLE pdl.idw_arj_pdl_sanctions TO t_reg_proc;

COMMENT ON TABLE pdl.idw_arj_pdl_sanctions
    IS 'Предназначен для выгрузки данных по санкциями, в которые включено физическое лицо';

COMMENT ON COLUMN pdl.idw_arj_pdl_sanctions.id
    IS 'ИД';

COMMENT ON COLUMN pdl.idw_arj_pdl_sanctions.load_id
    IS 'ИД загрузки';

COMMENT ON COLUMN pdl.idw_arj_pdl_sanctions.system_id
    IS 'ИД субъекта';

COMMENT ON COLUMN pdl.idw_arj_pdl_sanctions.sanction
    IS 'название санкционной программы';

COMMENT ON COLUMN pdl.idw_arj_pdl_sanctions.date_start
    IS 'дата включения лица в санкцию';

COMMENT ON COLUMN pdl.idw_arj_pdl_sanctions.date_end
    IS 'дата исключения лица из санкции';

COMMENT ON COLUMN pdl.idw_arj_pdl_sanctions.source
    IS 'ссылка на первоисточник санкционного подлиста ';

COMMENT ON COLUMN pdl.idw_arj_pdl_sanctions.reason_inclusion
    IS 'причина включения в санкции';

COMMENT ON COLUMN pdl.idw_arj_pdl_sanctions.sanlist
    IS 'наименование санкционного листа ';

COMMENT ON COLUMN pdl.idw_arj_pdl_sanctions.country
    IS 'страна -инициатор введения в действие санкции ';

COMMENT ON COLUMN pdl.idw_arj_pdl_sanctions.extra_informations
    IS 'дополнительная информация по персоне';

COMMENT ON COLUMN pdl.idw_arj_pdl_sanctions.uidd
    IS 'уникальный идентификатор персоны или порядковый номер в санкционной программе в первоисточнике ';

COMMENT ON COLUMN pdl.idw_arj_pdl_sanctions.last_update_in_source
    IS 'дата обновления записи в первоисточнике ';

COMMENT ON COLUMN pdl.idw_arj_pdl_sanctions.create_date
    IS 'дата создания';

COMMENT ON COLUMN pdl.idw_arj_pdl_sanctions.create_user
    IS 'автор';
-- Index: idw_arj_pdl_sanctions_id_idx

-- DROP INDEX IF EXISTS pdl.idw_arj_pdl_sanctions_id_idx;

CREATE UNIQUE INDEX IF NOT EXISTS idw_arj_pdl_sanctions_id_idx
    ON pdl.idw_arj_pdl_sanctions USING btree
    (id ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idw_arj_pdl_sanctions_load_id_system_id_idx

-- DROP INDEX IF EXISTS pdl.idw_arj_pdl_sanctions_load_id_system_id_idx;

CREATE INDEX IF NOT EXISTS idw_arj_pdl_sanctions_load_id_system_id_idx
    ON pdl.idw_arj_pdl_sanctions USING btree
    (load_id ASC NULLS LAST, system_id COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
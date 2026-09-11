-- Table: sr.sr_subject_h

-- DROP TABLE IF EXISTS sr.sr_subject_h;

CREATE TABLE IF NOT EXISTS sr.sr_subject_h
(
    sr_event_id bigint NOT NULL,
    sr_subject_id bigint,
    etalon_registry_id bigint,
    eor_subject_mention_id bigint,
    incl_first_date timestamp without time zone NOT NULL,
    incl_date timestamp without time zone,
    incl_reason text COLLATE pg_catalog."default",
    excl_date timestamp without time zone,
    excl_reason text COLLATE pg_catalog."default",
    deleted_sign character(1) COLLATE pg_catalog."default" DEFAULT '0'::character(1),
    sr_type_id integer NOT NULL,
    actual_sign character(1) COLLATE pg_catalog."default",
    checked_sign character(1) COLLATE pg_catalog."default",
    reg_num_ext_reestr text COLLATE pg_catalog."default",
    CONSTRAINT sr_subject_h_pk PRIMARY KEY (sr_event_id),
    CONSTRAINT fk_sr_subject_h_sr_subject FOREIGN KEY (sr_subject_id)
        REFERENCES sr.sr_subject (sr_subject_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT fk_sr_subject_h_sr_type FOREIGN KEY (sr_type_id)
        REFERENCES sr.sr_type (sr_type_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS sr.sr_subject_h
    OWNER to r_fors_db_owner;

REVOKE ALL ON TABLE sr.sr_subject_h FROM oper_pg_rep;
REVOKE ALL ON TABLE sr.sr_subject_h FROM r_t_oper_db_sr_rep;

GRANT SELECT ON TABLE sr.sr_subject_h TO oper_pg_rep;

GRANT ALL ON TABLE sr.sr_subject_h TO r_fors_db_owner;

GRANT SELECT ON TABLE sr.sr_subject_h TO r_t_oper_db_sr_rep;

COMMENT ON TABLE sr.sr_subject_h
    IS 'История Субъекта Cпецреестра';

COMMENT ON COLUMN sr.sr_subject_h.sr_event_id
    IS 'ИД события (таблица sr.SR_EVENT)';

COMMENT ON COLUMN sr.sr_subject_h.sr_subject_id
    IS 'ИД субъекта спецреестра';

COMMENT ON COLUMN sr.sr_subject_h.etalon_registry_id
    IS 'ИД субъекта в ЕОР';

COMMENT ON COLUMN sr.sr_subject_h.eor_subject_mention_id
    IS 'ИД субъекта упоминания (Таблица IDWH2.IDW_MR_SUBJECT_MENTION)';

COMMENT ON COLUMN sr.sr_subject_h.incl_first_date
    IS 'Дата первого включения в спецреестр';

COMMENT ON COLUMN sr.sr_subject_h.incl_date
    IS 'Дата последнего включения в спецреестр';

COMMENT ON COLUMN sr.sr_subject_h.incl_reason
    IS 'Основание последнего включения';

COMMENT ON COLUMN sr.sr_subject_h.excl_date
    IS 'Дата последнего исключения из спецреестра';

COMMENT ON COLUMN sr.sr_subject_h.excl_reason
    IS 'Причина последнего исключения из спецреестра';

COMMENT ON COLUMN sr.sr_subject_h.deleted_sign
    IS 'Признак удаления (ошибочная запись)';

COMMENT ON COLUMN sr.sr_subject_h.sr_type_id
    IS 'Тип спецреестра (таблица sr.SR_TYPE)';

COMMENT ON COLUMN sr.sr_subject_h.actual_sign
    IS 'Признак актуальности';

COMMENT ON COLUMN sr.sr_subject_h.checked_sign
    IS 'Признак проверки данных ( 0 - не проверены, 1- проверены, 2 - в очереди на распознавание )';

COMMENT ON COLUMN sr.sr_subject_h.reg_num_ext_reestr
    IS 'Регистрационный номер во внешнем реестре';
-- Index: ix_sr_subject_h_sr_subject_id

-- DROP INDEX IF EXISTS sr.ix_sr_subject_h_sr_subject_id;

CREATE INDEX IF NOT EXISTS ix_sr_subject_h_sr_subject_id
    ON sr.sr_subject_h USING btree
    (sr_subject_id ASC NULLS LAST)
    TABLESPACE pg_default;
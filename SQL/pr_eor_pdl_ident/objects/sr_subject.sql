-- Table: sr.sr_subject

-- DROP TABLE IF EXISTS sr.sr_subject;

CREATE TABLE IF NOT EXISTS sr.sr_subject
(
    sr_subject_id bigint NOT NULL,
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
    sr_event_id bigint,
    reg_num_ext_reestr text COLLATE pg_catalog."default",
    CONSTRAINT sr_subject_pk PRIMARY KEY (sr_subject_id),
    CONSTRAINT fk_sr_subject_sr_type FOREIGN KEY (sr_type_id)
        REFERENCES sr.sr_type (sr_type_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS sr.sr_subject
    OWNER to r_fors_db_owner;

REVOKE ALL ON TABLE sr.sr_subject FROM oper_pg_rep;
REVOKE ALL ON TABLE sr.sr_subject FROM r_t_oper_db_sr_rep;

GRANT SELECT ON TABLE sr.sr_subject TO oper_pg_rep;

GRANT ALL ON TABLE sr.sr_subject TO r_fors_db_owner;

GRANT SELECT ON TABLE sr.sr_subject TO r_t_oper_db_sr_rep;

COMMENT ON TABLE sr.sr_subject
    IS 'Субъект Cпецреестра';

COMMENT ON COLUMN sr.sr_subject.sr_subject_id
    IS 'ИД субъекта спецреестра';

COMMENT ON COLUMN sr.sr_subject.etalon_registry_id
    IS 'ИД субъекта в ЕОР';

COMMENT ON COLUMN sr.sr_subject.eor_subject_mention_id
    IS 'ИД субъекта упоминания (Таблица IDWH2.IDW_MR_SUBJECT_MENTION)';

COMMENT ON COLUMN sr.sr_subject.incl_first_date
    IS 'Дата первого включения в спецреестр';

COMMENT ON COLUMN sr.sr_subject.incl_date
    IS 'Дата последнего включения в спецреестр';

COMMENT ON COLUMN sr.sr_subject.incl_reason
    IS 'Основание последнего включения';

COMMENT ON COLUMN sr.sr_subject.excl_date
    IS 'Дата последнего исключения из спецреестра';

COMMENT ON COLUMN sr.sr_subject.excl_reason
    IS 'Причина последнего исключения из спецреестра';

COMMENT ON COLUMN sr.sr_subject.deleted_sign
    IS 'Признак удаления (ошибочная запись)';

COMMENT ON COLUMN sr.sr_subject.sr_type_id
    IS 'Тип спецреестра (таблица sr.SR_TYPE)';

COMMENT ON COLUMN sr.sr_subject.actual_sign
    IS 'Признак актуальности';

COMMENT ON COLUMN sr.sr_subject.checked_sign
    IS 'Признак проверки данных ( 0 - не проверены, 1- проверены, 2 - в очереди на распознавание)';

COMMENT ON COLUMN sr.sr_subject.sr_event_id
    IS 'ИД события (таблица sr.SR_EVENT)';

COMMENT ON COLUMN sr.sr_subject.reg_num_ext_reestr
    IS 'Регистрационный номер во внешнем реестре';
-- Index: ix_sr_subject_actual_sign

-- DROP INDEX IF EXISTS sr.ix_sr_subject_actual_sign;

CREATE INDEX IF NOT EXISTS ix_sr_subject_actual_sign
    ON sr.sr_subject USING hash
    (actual_sign COLLATE pg_catalog."default")
    TABLESPACE pg_default;
-- Index: ix_sr_subject_checked_sign

-- DROP INDEX IF EXISTS sr.ix_sr_subject_checked_sign;

CREATE INDEX IF NOT EXISTS ix_sr_subject_checked_sign
    ON sr.sr_subject USING hash
    (checked_sign COLLATE pg_catalog."default")
    TABLESPACE pg_default;
-- Index: ix_sr_subject_deleted_sign

-- DROP INDEX IF EXISTS sr.ix_sr_subject_deleted_sign;

CREATE INDEX IF NOT EXISTS ix_sr_subject_deleted_sign
    ON sr.sr_subject USING hash
    (deleted_sign COLLATE pg_catalog."default")
    TABLESPACE pg_default;
-- Index: ix_sr_subject_e_r_id

-- DROP INDEX IF EXISTS sr.ix_sr_subject_e_r_id;

CREATE INDEX IF NOT EXISTS ix_sr_subject_e_r_id
    ON sr.sr_subject USING btree
    (etalon_registry_id ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: ix_sr_subject_eor_s_m_id

-- DROP INDEX IF EXISTS sr.ix_sr_subject_eor_s_m_id;

CREATE INDEX IF NOT EXISTS ix_sr_subject_eor_s_m_id
    ON sr.sr_subject USING btree
    (eor_subject_mention_id ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: ix_sr_subject_excl_date

-- DROP INDEX IF EXISTS sr.ix_sr_subject_excl_date;

CREATE INDEX IF NOT EXISTS ix_sr_subject_excl_date
    ON sr.sr_subject USING btree
    (excl_date ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: ix_sr_subject_incl_date

-- DROP INDEX IF EXISTS sr.ix_sr_subject_incl_date;

CREATE INDEX IF NOT EXISTS ix_sr_subject_incl_date
    ON sr.sr_subject USING btree
    (incl_date ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: ix_sr_subject_incl_first_date

-- DROP INDEX IF EXISTS sr.ix_sr_subject_incl_first_date;

CREATE INDEX IF NOT EXISTS ix_sr_subject_incl_first_date
    ON sr.sr_subject USING btree
    (incl_first_date ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: ix_sr_subject_sr_event_id

-- DROP INDEX IF EXISTS sr.ix_sr_subject_sr_event_id;

CREATE INDEX IF NOT EXISTS ix_sr_subject_sr_event_id
    ON sr.sr_subject USING btree
    (sr_event_id ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: ix_sr_subject_sr_type_id

-- DROP INDEX IF EXISTS sr.ix_sr_subject_sr_type_id;

CREATE INDEX IF NOT EXISTS ix_sr_subject_sr_type_id
    ON sr.sr_subject USING btree
    (sr_type_id ASC NULLS LAST, etalon_registry_id ASC NULLS LAST)
    TABLESPACE pg_default;
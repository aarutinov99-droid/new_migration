-- Table: sr.sr_event

-- DROP TABLE IF EXISTS sr.sr_event;

CREATE TABLE IF NOT EXISTS sr.sr_event
(
    sr_event_id bigint NOT NULL,
    sr_event_type_id integer NOT NULL,
    sr_subject_id bigint NOT NULL,
    sr_event_date timestamp without time zone NOT NULL DEFAULT now(),
    sr_event_user text COLLATE pg_catalog."default" NOT NULL DEFAULT SESSION_USER,
    description text COLLATE pg_catalog."default",
    manual_sign character(1) COLLATE pg_catalog."default",
    sr_type_id integer NOT NULL,
    object_id bigint,
    sr_event_user_os text COLLATE pg_catalog."default",
    CONSTRAINT sr_event_pk PRIMARY KEY (sr_event_id),
    CONSTRAINT fk_sr_event_sr_event_type FOREIGN KEY (sr_event_type_id)
        REFERENCES sr.sr_event_type (sr_event_type_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT fk_sr_event_sr_type_sr_type_id FOREIGN KEY (sr_type_id)
        REFERENCES sr.sr_type (sr_type_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT fk_sr_subject FOREIGN KEY (sr_subject_id)
        REFERENCES sr.sr_subject (sr_subject_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        DEFERRABLE INITIALLY DEFERRED
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS sr.sr_event
    OWNER to r_fors_db_owner;

REVOKE ALL ON TABLE sr.sr_event FROM oper_pg_rep;
REVOKE ALL ON TABLE sr.sr_event FROM r_t_oper_db_sr_rep;

GRANT SELECT ON TABLE sr.sr_event TO oper_pg_rep;

GRANT ALL ON TABLE sr.sr_event TO r_fors_db_owner;

GRANT SELECT ON TABLE sr.sr_event TO r_t_oper_db_sr_rep;

COMMENT ON TABLE sr.sr_event
    IS 'Событие спецреестра';

COMMENT ON COLUMN sr.sr_event.sr_event_id
    IS 'ИД события';

COMMENT ON COLUMN sr.sr_event.sr_event_type_id
    IS 'ИД типа события';

COMMENT ON COLUMN sr.sr_event.sr_subject_id
    IS 'ИД субъекта спецреестра';

COMMENT ON COLUMN sr.sr_event.sr_event_date
    IS 'Дата события';

COMMENT ON COLUMN sr.sr_event.sr_event_user
    IS 'Пользователь';

COMMENT ON COLUMN sr.sr_event.description
    IS 'Примечание (основание включения/исключения, др.)';

COMMENT ON COLUMN sr.sr_event.manual_sign
    IS 'Признак ручного режима';

COMMENT ON COLUMN sr.sr_event.sr_type_id
    IS 'ИД Спецреестра';

COMMENT ON COLUMN sr.sr_event.object_id
    IS 'ИД объекта';
-- Index: ix_sr_event_sr_event_date

-- DROP INDEX IF EXISTS sr.ix_sr_event_sr_event_date;

CREATE INDEX IF NOT EXISTS ix_sr_event_sr_event_date
    ON sr.sr_event USING btree
    (sr_event_date ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: ix_sr_event_sr_event_user

-- DROP INDEX IF EXISTS sr.ix_sr_event_sr_event_user;

CREATE INDEX IF NOT EXISTS ix_sr_event_sr_event_user
    ON sr.sr_event USING btree
    (sr_event_user COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: ix_sr_event_sr_subject_id

-- DROP INDEX IF EXISTS sr.ix_sr_event_sr_subject_id;

CREATE INDEX IF NOT EXISTS ix_sr_event_sr_subject_id
    ON sr.sr_event USING btree
    (sr_subject_id ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: ix_sr_event_sr_type_id

-- DROP INDEX IF EXISTS sr.ix_sr_event_sr_type_id;

CREATE INDEX IF NOT EXISTS ix_sr_event_sr_type_id
    ON sr.sr_event USING btree
    (sr_type_id ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: ix_sr_event_type_id

-- DROP INDEX IF EXISTS sr.ix_sr_event_type_id;

CREATE INDEX IF NOT EXISTS ix_sr_event_type_id
    ON sr.sr_event USING btree
    (sr_event_type_id ASC NULLS LAST)
    TABLESPACE pg_default;
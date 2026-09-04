
ALTER TABLE IF EXISTS pdl.idw_arj_interfax_pdl
    ADD COLUMN id bigserial NOT NULL;

COMMENT ON COLUMN pdl.idw_arj_interfax_pdl.id
    IS 'Уникальный идентификатор записи';
	

ALTER TABLE IF EXISTS pdl.idw_arj_interfax_pdl
    ADD CONSTRAINT idw_arj_interfax_pdl_pkey PRIMARY KEY (id);

COMMENT ON CONSTRAINT idw_arj_interfax_pdl_pkey ON pdl.idw_arj_interfax_pdl
    IS 'Контроль уникальности';
	
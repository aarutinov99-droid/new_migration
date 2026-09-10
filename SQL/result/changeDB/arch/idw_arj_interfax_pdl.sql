/*
ALTER TABLE IF EXISTS pdl.idw_arj_interfax_pdl
    ADD COLUMN id bigserial NOT NULL;

COMMENT ON COLUMN pdl.idw_arj_interfax_pdl.id
    IS 'Уникальный идентификатор записи';
	

ALTER TABLE IF EXISTS pdl.idw_arj_interfax_pdl
    ADD CONSTRAINT idw_arj_interfax_pdl_pkey PRIMARY KEY (id);

COMMENT ON CONSTRAINT idw_arj_interfax_pdl_pkey ON pdl.idw_arj_interfax_pdl
    IS 'Контроль уникальности';
	
*/

DO $$
BEGIN
    -- Добавление колонки id
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'pdl' 
          AND table_name = 'idw_arj_interfax_pdl' 
          AND column_name = 'id'
    ) THEN
        ALTER TABLE pdl.idw_arj_interfax_pdl ADD COLUMN id bigserial NOT NULL;
        RAISE NOTICE 'Колонка id добавлена';
    ELSE
        RAISE NOTICE 'Колонка id уже существует';
    END IF;
    
    -- Добавление комментария к колонке
    COMMENT ON COLUMN pdl.idw_arj_interfax_pdl.id IS 'Уникальный идентификатор записи';
    
    -- Добавление первичного ключа
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE table_schema = 'pdl' 
          AND table_name = 'idw_arj_interfax_pdl' 
          AND constraint_name = 'idw_arj_interfax_pdl_pkey'
    ) THEN
        -- Проверяем, нет ли другого первичного ключа
        IF EXISTS (
            SELECT 1 FROM information_schema.table_constraints 
            WHERE table_schema = 'pdl' 
              AND table_name = 'idw_arj_interfax_pdl' 
              AND constraint_type = 'PRIMARY KEY'
        ) THEN
            RAISE WARNING 'В таблице уже есть первичный ключ. Добавление пропущено';
        ELSE
            ALTER TABLE pdl.idw_arj_interfax_pdl 
            ADD CONSTRAINT idw_arj_interfax_pdl_pkey PRIMARY KEY (id);
            RAISE NOTICE 'Первичный ключ добавлен';
        END IF;
    ELSE
        RAISE NOTICE 'Первичный ключ уже существует';
    END IF;
    
    -- Добавление комментария к констрейнту
    COMMENT ON CONSTRAINT idw_arj_interfax_pdl_pkey ON pdl.idw_arj_interfax_pdl 
    IS 'Контроль уникальности';
    
    RAISE NOTICE 'Все операции завершены';
END $$;


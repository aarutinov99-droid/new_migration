-- =====================================================================
-- СКРИПТ ИМПОРТА СХЕМЫ pdl ЧЕРЕЗ FDW С ПРОВЕРКОЙ СУЩЕСТВОВАНИЯ ОБЪЕКТОВ
-- =====================================================================

DO $$
BEGIN
    -- Проверка существования внешнего сервера
    IF NOT EXISTS (
        SELECT 1 
        FROM pg_foreign_server 
        WHERE srvname = 'arch_pg_fdw'
    ) THEN
        RAISE EXCEPTION 'Внешний сервер arch_pg_fdw не существует. Создайте его перед импортом.';
    END IF;
    
    -- Проверка существования схемы arch_ext
    IF NOT EXISTS (
        SELECT 1 
        FROM pg_namespace 
        WHERE nspname = 'arch_ext'
    ) THEN
        RAISE NOTICE 'Схема arch_ext не существует. Создаем...';
        EXECUTE 'CREATE SCHEMA arch_ext';
    END IF;
    
    -- Проверка наличия расширения postgres_fdw
    IF NOT EXISTS (
        SELECT 1 
        FROM pg_extension 
        WHERE extname = 'postgres_fdw'
    ) THEN
        RAISE NOTICE 'Расширение postgres_fdw не установлено. Устанавливаем...';
        EXECUTE 'CREATE EXTENSION IF NOT EXISTS postgres_fdw';
    END IF;
    
    RAISE NOTICE 'Все проверки пройдены. Начинаем импорт...';
END $$;

DO $$
DECLARE
    v_table_name text;
    v_import_sql text;
    v_owner_sql text;
    v_grant_sql text;
    v_schema_owner text;
BEGIN
    -- Получаем владельца схемы arch_ext
    SELECT nspowner::regrole::text INTO v_schema_owner
    FROM pg_namespace 
    WHERE nspname = 'arch_ext';
    
    RAISE NOTICE 'Владелец схемы arch_ext: %', v_schema_owner;
    
    -- Список таблиц для импорта
    FOR v_table_name IN 
        SELECT unnest(ARRAY[
            'idw_arj_interfax_pdl',
            'idw_arj_pdl_categories',
            'idw_arj_pdl_category407',
            'idw_arj_pdl_countries',
            'idw_arj_pdl_jobs',
            'idw_arj_pdl_names',
            'idw_arj_pdl_sanctions',
            'idw_arj_pdl_sanlists',
            'idw_arj_pdl_translit_names',
            'idw_pdl_ref'
        ])
    LOOP
        -- Проверяем существует ли уже таблица
        IF EXISTS (
            SELECT 1 
            FROM information_schema.tables 
            WHERE table_schema = 'arch_ext' 
              AND table_name = v_table_name
              AND table_type IN ('FOREIGN TABLE', 'BASE TABLE')
        ) THEN
            RAISE NOTICE 'Таблица arch_ext.% уже существует, пропускаем импорт', v_table_name;
            -- Назначаем владельца для существующей таблицы
            EXECUTE format('ALTER TABLE arch_ext.%I OWNER TO r_fors_db_owner', v_table_name);
            RAISE NOTICE 'Владелец назначен для существующей таблицы: %', v_table_name;
        ELSE
            -- Импортируем таблицу
            BEGIN
                v_import_sql := format(
                    'IMPORT FOREIGN SCHEMA pdl LIMIT TO (%I) FROM SERVER arch_pg_fdw INTO arch_ext',
                    v_table_name
                );
                EXECUTE v_import_sql;
                RAISE NOTICE 'Импортирована таблица: %', v_table_name;
                
                -- Сразу назначаем владельца
                EXECUTE format('ALTER TABLE arch_ext.%I OWNER TO r_fors_db_owner', v_table_name);
                RAISE NOTICE 'Владелец назначен для таблицы: %', v_table_name;
                
            EXCEPTION 
                WHEN OTHERS THEN
                    RAISE WARNING 'Ошибка при импорте таблицы %: %', v_table_name, SQLERRM;
            END;
        END IF;
    END LOOP;
    
    RAISE NOTICE 'Импорт и назначение владельцев завершены';
END $$;

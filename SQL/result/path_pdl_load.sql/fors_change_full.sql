-- =====================================================================
-- ЕДИНЫЙ СКРИПТ ИЗМЕНЕНИЙ БАЗЫ ДАННЫХ
-- Сформирован из файлов:
--   - create_FOREIGN.sql
--   - create_objects.sql
--   - workflow.sql
-- =====================================================================

BEGIN;

SET client_min_messages TO NOTICE;

-- =====================================================================
-- ЧАСТЬ 1: ИМПОРТ СХЕМЫ pdl ЧЕРЕЗ FDW
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

-- =====================================================================
-- ЧАСТЬ 2: СОЗДАНИЕ ОБЪЕКТОВ В СХЕМЕ arch_ext
-- =====================================================================

-- 2.1 Опорная таблица arch_ext.idw_arj_interfax_pdl_load_buffer
DO $$
BEGIN
    drop table IF EXISTS arch_ext.idw_arj_interfax_pdl_load_buffer;
    CREATE TABLE IF NOT EXISTS arch_ext.idw_arj_interfax_pdl_load_buffer
    (
        id bigint NOT NULL,
		sr_subject_id bigint NOT NULL default 0,
        create_date timestamp without time zone NOT NULL DEFAULT clock_timestamp(),
        CONSTRAINT idw_arj_interfax_pdl_load_buffer_pk PRIMARY KEY (id,sr_subject_id)
    );
	
	COMMENT ON COLUMN arch_ext.idw_arj_interfax_pdl_load_buffer.id    IS 'ИД записи';
	COMMENT ON COLUMN arch_ext.idw_arj_interfax_pdl_load_buffer.sr_subject_id    IS 'ИД субъекта';
	COMMENT ON TABLE arch_ext.idw_arj_interfax_pdl_load_buffer  IS 'Связь упоминаний истерфакса с объектами росереестра.';
	
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Ошибка при создании arch_ext.idw_arj_interfax_pdl_load_buffer: %', SQLERRM;
END;
$$;

DO $$
BEGIN
    ALTER TABLE IF EXISTS arch_ext.idw_arj_interfax_pdl_load_buffer OWNER TO r_fors_db_owner;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Ошибка при смене владельца arch_ext.idw_arj_interfax_pdl_load_buffer: %', SQLERRM;
END;
$$;

-- 2.2 Буферная таблица arch_ext.idw_arj_interfax_pdl_buffer
DO $$
BEGIN
    CREATE TABLE IF NOT EXISTS arch_ext.idw_arj_interfax_pdl_buffer AS
    SELECT * FROM arch_ext.idw_arj_interfax_pdl LIMIT 0;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Ошибка при создании arch_ext.idw_arj_interfax_pdl_buffer: %', SQLERRM;
END;
$$;

DO $$
BEGIN
    ALTER TABLE IF EXISTS arch_ext.idw_arj_interfax_pdl_buffer
        ADD CONSTRAINT idw_arj_interfax_pdl_buffer_pk PRIMARY KEY (id);
EXCEPTION
    WHEN SQLSTATE '42P07' OR SQLSTATE '23505' THEN
        RAISE NOTICE 'Ограничение idw_arj_interfax_pdl_buffer_pk уже существует или таблица уже имеет первичный ключ';
    WHEN OTHERS THEN
        RAISE NOTICE 'Ошибка при добавлении PK arch_ext.idw_arj_interfax_pdl_buffer: %', SQLERRM;
END;
$$;

DO $$
BEGIN
    COMMENT ON CONSTRAINT idw_arj_interfax_pdl_buffer_pk ON arch_ext.idw_arj_interfax_pdl_buffer
        IS 'Уникальность буферизации';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Ошибка при добавлении комментария arch_ext.idw_arj_interfax_pdl_buffer: %', SQLERRM;
END;
$$;

DO $$
BEGIN
    ALTER TABLE IF EXISTS arch_ext.idw_arj_interfax_pdl_buffer OWNER TO r_fors_db_owner;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Ошибка при смене владельца arch_ext.idw_arj_interfax_pdl_buffer: %', SQLERRM;
END;
$$;

-- 2.3 Буферная таблица arch_ext.idw_arj_pdl_category407_buffer
DO $$
BEGIN
    CREATE TABLE IF NOT EXISTS arch_ext.idw_arj_pdl_category407_buffer AS
    SELECT * FROM arch_ext.idw_arj_pdl_category407 LIMIT 0;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Ошибка при создании arch_ext.idw_arj_pdl_category407_buffer: %', SQLERRM;
END;
$$;

DO $$
BEGIN
    ALTER TABLE IF EXISTS arch_ext.idw_arj_pdl_category407_buffer
        ADD CONSTRAINT idw_arj_pdl_category407_buffer_pk PRIMARY KEY (id);
EXCEPTION
    WHEN SQLSTATE '42P07' OR SQLSTATE '23505' THEN
        RAISE NOTICE 'Ограничение idw_arj_pdl_category407_buffer_pk уже существует или таблица уже имеет первичный ключ';
    WHEN OTHERS THEN
        RAISE NOTICE 'Ошибка при добавлении PK arch_ext.idw_arj_pdl_category407_buffer: %', SQLERRM;
END;
$$;

DO $$
BEGIN
    COMMENT ON CONSTRAINT idw_arj_pdl_category407_buffer_pk ON arch_ext.idw_arj_pdl_category407_buffer
        IS 'Уникальность буферизации';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Ошибка при добавлении комментария arch_ext.idw_arj_pdl_category407_buffer: %', SQLERRM;
END;
$$;

DO $$
BEGIN
    ALTER TABLE IF EXISTS arch_ext.idw_arj_pdl_category407_buffer OWNER TO r_fors_db_owner;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Ошибка при смене владельца arch_ext.idw_arj_pdl_category407_buffer: %', SQLERRM;
END;
$$;

-- 2.4 Буферная таблица arch_ext.idw_arj_pdl_countries_buffer
DO $$
BEGIN
    CREATE TABLE IF NOT EXISTS arch_ext.idw_arj_pdl_countries_buffer AS
    SELECT * FROM arch_ext.idw_arj_pdl_countries LIMIT 0;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Ошибка при создании arch_ext.idw_arj_pdl_countries_buffer: %', SQLERRM;
END;
$$;

DO $$
BEGIN
    ALTER TABLE IF EXISTS arch_ext.idw_arj_pdl_countries_buffer
        ADD CONSTRAINT idw_arj_pdl_countries_buffer_pk PRIMARY KEY (id);
EXCEPTION
    WHEN SQLSTATE '42P07' OR SQLSTATE '23505' THEN
        RAISE NOTICE 'Ограничение idw_arj_pdl_countries_buffer_pk уже существует или таблица уже имеет первичный ключ';
    WHEN OTHERS THEN
        RAISE NOTICE 'Ошибка при добавлении PK arch_ext.idw_arj_pdl_countries_buffer: %', SQLERRM;
END;
$$;

DO $$
BEGIN
    COMMENT ON CONSTRAINT idw_arj_pdl_countries_buffer_pk ON arch_ext.idw_arj_pdl_countries_buffer
        IS 'Уникальность буферизации';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Ошибка при добавлении комментария arch_ext.idw_arj_pdl_countries_buffer: %', SQLERRM;
END;
$$;

DO $$
BEGIN
    ALTER TABLE IF EXISTS arch_ext.idw_arj_pdl_countries_buffer OWNER TO r_fors_db_owner;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Ошибка при смене владельца arch_ext.idw_arj_pdl_countries_buffer: %', SQLERRM;
END;
$$;

-- 2.5 Буферная таблица arch_ext.idw_arj_pdl_jobs_buffer
DO $$
BEGIN
    CREATE TABLE IF NOT EXISTS arch_ext.idw_arj_pdl_jobs_buffer AS
    SELECT * FROM arch_ext.idw_arj_pdl_jobs LIMIT 0;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Ошибка при создании arch_ext.idw_arj_pdl_jobs_buffer: %', SQLERRM;
END;
$$;

DO $$
BEGIN
    ALTER TABLE IF EXISTS arch_ext.idw_arj_pdl_jobs_buffer
        ADD CONSTRAINT idw_arj_pdl_jobs_buffer_pk PRIMARY KEY (id);
EXCEPTION
    WHEN SQLSTATE '42P07' OR SQLSTATE '23505' THEN
        RAISE NOTICE 'Ограничение idw_arj_pdl_jobs_buffer_pk уже существует или таблица уже имеет первичный ключ';
    WHEN OTHERS THEN
        RAISE NOTICE 'Ошибка при добавлении PK arch_ext.idw_arj_pdl_jobs_buffer: %', SQLERRM;
END;
$$;

DO $$
BEGIN
    COMMENT ON CONSTRAINT idw_arj_pdl_jobs_buffer_pk ON arch_ext.idw_arj_pdl_jobs_buffer
        IS 'Уникальность буферизации';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Ошибка при добавлении комментария arch_ext.idw_arj_pdl_jobs_buffer: %', SQLERRM;
END;
$$;

DO $$
BEGIN
    ALTER TABLE IF EXISTS arch_ext.idw_arj_pdl_jobs_buffer OWNER TO r_fors_db_owner;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Ошибка при смене владельца arch_ext.idw_arj_pdl_jobs_buffer: %', SQLERRM;
END;
$$;

-- 2.6 Буферная таблица arch_ext.idw_arj_pdl_names_buffer
DO $$
BEGIN
    CREATE TABLE IF NOT EXISTS arch_ext.idw_arj_pdl_names_buffer AS
    SELECT * FROM arch_ext.idw_arj_pdl_names LIMIT 0;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Ошибка при создании arch_ext.idw_arj_pdl_names_buffer: %', SQLERRM;
END;
$$;

DO $$
BEGIN
    ALTER TABLE IF EXISTS arch_ext.idw_arj_pdl_names_buffer
        ADD CONSTRAINT idw_arj_pdl_names_buffer_pk PRIMARY KEY (id);
EXCEPTION
    WHEN SQLSTATE '42P07' OR SQLSTATE '23505' THEN
        RAISE NOTICE 'Ограничение idw_arj_pdl_names_buffer_pk уже существует или таблица уже имеет первичный ключ';
    WHEN OTHERS THEN
        RAISE NOTICE 'Ошибка при добавлении PK arch_ext.idw_arj_pdl_names_buffer: %', SQLERRM;
END;
$$;

DO $$
BEGIN
    COMMENT ON CONSTRAINT idw_arj_pdl_names_buffer_pk ON arch_ext.idw_arj_pdl_names_buffer
        IS 'Уникальность буферизации';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Ошибка при добавлении комментария arch_ext.idw_arj_pdl_names_buffer: %', SQLERRM;
END;
$$;

DO $$
BEGIN
    ALTER TABLE IF EXISTS arch_ext.idw_arj_pdl_names_buffer OWNER TO r_fors_db_owner;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Ошибка при смене владельца arch_ext.idw_arj_pdl_names_buffer: %', SQLERRM;
END;
$$;

-- 2.7 Буферная таблица arch_ext.idw_arj_pdl_sanctions_buffer
DO $$
BEGIN
    CREATE TABLE IF NOT EXISTS arch_ext.idw_arj_pdl_sanctions_buffer AS
    SELECT * FROM arch_ext.idw_arj_pdl_sanctions LIMIT 0;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Ошибка при создании arch_ext.idw_arj_pdl_sanctions_buffer: %', SQLERRM;
END;
$$;

DO $$
BEGIN
    ALTER TABLE IF EXISTS arch_ext.idw_arj_pdl_sanctions_buffer
        ADD CONSTRAINT idw_arj_pdl_sanctions_buffer_pk PRIMARY KEY (id);
EXCEPTION
    WHEN SQLSTATE '42P07' OR SQLSTATE '23505' THEN
        RAISE NOTICE 'Ограничение idw_arj_pdl_sanctions_buffer_pk уже существует или таблица уже имеет первичный ключ';
    WHEN OTHERS THEN
        RAISE NOTICE 'Ошибка при добавлении PK arch_ext.idw_arj_pdl_sanctions_buffer: %', SQLERRM;
END;
$$;

DO $$
BEGIN
    COMMENT ON CONSTRAINT idw_arj_pdl_sanctions_buffer_pk ON arch_ext.idw_arj_pdl_sanctions_buffer
        IS 'Уникальность буферизации';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Ошибка при добавлении комментария arch_ext.idw_arj_pdl_sanctions_buffer: %', SQLERRM;
END;
$$;

DO $$
BEGIN
    ALTER TABLE IF EXISTS arch_ext.idw_arj_pdl_sanctions_buffer OWNER TO r_fors_db_owner;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Ошибка при смене владельца arch_ext.idw_arj_pdl_sanctions_buffer: %', SQLERRM;
END;
$$;

-- 2.8 Буферная таблица arch_ext.idw_arj_pdl_sanlists_buffer
DO $$
BEGIN
    CREATE TABLE IF NOT EXISTS arch_ext.idw_arj_pdl_sanlists_buffer AS
    SELECT * FROM arch_ext.idw_arj_pdl_sanlists LIMIT 0;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Ошибка при создании arch_ext.idw_arj_pdl_sanlists_buffer: %', SQLERRM;
END;
$$;

DO $$
BEGIN
    ALTER TABLE IF EXISTS arch_ext.idw_arj_pdl_sanlists_buffer
        ADD CONSTRAINT idw_arj_pdl_sanlists_buffer_pk PRIMARY KEY (id);
EXCEPTION
    WHEN SQLSTATE '42P07' OR SQLSTATE '23505' THEN
        RAISE NOTICE 'Ограничение idw_arj_pdl_sanlists_buffer_pk уже существует или таблица уже имеет первичный ключ';
    WHEN OTHERS THEN
        RAISE NOTICE 'Ошибка при добавлении PK arch_ext.idw_arj_pdl_sanlists_buffer: %', SQLERRM;
END;
$$;

DO $$
BEGIN
    COMMENT ON CONSTRAINT idw_arj_pdl_sanlists_buffer_pk ON arch_ext.idw_arj_pdl_sanlists_buffer
        IS 'Уникальность буферизации';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Ошибка при добавлении комментария arch_ext.idw_arj_pdl_sanlists_buffer: %', SQLERRM;
END;
$$;

DO $$
BEGIN
    ALTER TABLE IF EXISTS arch_ext.idw_arj_pdl_sanlists_buffer OWNER TO r_fors_db_owner;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Ошибка при смене владельца arch_ext.idw_arj_pdl_sanlists_buffer: %', SQLERRM;
END;
$$;

-- 2.9 Буферная таблица arch_ext.idw_arj_pdl_translit_names_buffer
DO $$
BEGIN
    CREATE TABLE IF NOT EXISTS arch_ext.idw_arj_pdl_translit_names_buffer AS
    SELECT * FROM arch_ext.idw_arj_pdl_translit_names LIMIT 0;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Ошибка при создании arch_ext.idw_arj_pdl_translit_names_buffer: %', SQLERRM;
END;
$$;

DO $$
BEGIN
    ALTER TABLE IF EXISTS arch_ext.idw_arj_pdl_translit_names_buffer
        ADD CONSTRAINT idw_arj_pdl_translit_names_buffer_pk PRIMARY KEY (id);
EXCEPTION
    WHEN SQLSTATE '42P07' OR SQLSTATE '23505' THEN
        RAISE NOTICE 'Ограничение idw_arj_pdl_translit_names_buffer_pk уже существует или таблица уже имеет первичный ключ';
    WHEN OTHERS THEN
        RAISE NOTICE 'Ошибка при добавлении PK arch_ext.idw_arj_pdl_translit_names_buffer: %', SQLERRM;
END;
$$;

DO $$
BEGIN
    COMMENT ON CONSTRAINT idw_arj_pdl_translit_names_buffer_pk ON arch_ext.idw_arj_pdl_translit_names_buffer
        IS 'Уникальность буферизации';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Ошибка при добавлении комментария arch_ext.idw_arj_pdl_translit_names_buffer: %', SQLERRM;
END;
$$;

DO $$
BEGIN
    ALTER TABLE IF EXISTS arch_ext.idw_arj_pdl_translit_names_buffer OWNER TO r_fors_db_owner;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Ошибка при смене владельца arch_ext.idw_arj_pdl_translit_names_buffer: %', SQLERRM;
END;
$$;

-- 2.10 Буферная таблица arch_ext.idw_pdl_ref_buffer
DO $$
BEGIN
    CREATE TABLE IF NOT EXISTS arch_ext.idw_pdl_ref_buffer AS
    SELECT * FROM arch_ext.idw_pdl_ref LIMIT 0;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Ошибка при создании arch_ext.idw_pdl_ref_buffer: %', SQLERRM;
END;
$$;

DO $$
BEGIN
    ALTER TABLE IF EXISTS arch_ext.idw_pdl_ref_buffer
        ADD CONSTRAINT idw_pdl_ref_buffer_pk PRIMARY KEY (id);
EXCEPTION
    WHEN SQLSTATE '42P07' OR SQLSTATE '23505' THEN
        RAISE NOTICE 'Ограничение idw_pdl_ref_buffer_pk уже существует или таблица уже имеет первичный ключ';
    WHEN OTHERS THEN
        RAISE NOTICE 'Ошибка при добавлении PK arch_ext.idw_pdl_ref_buffer: %', SQLERRM;
END;
$$;

DO $$
BEGIN
    COMMENT ON CONSTRAINT idw_pdl_ref_buffer_pk ON arch_ext.idw_pdl_ref_buffer
        IS 'Уникальность буферизации';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Ошибка при добавлении комментария arch_ext.idw_pdl_ref_buffer: %', SQLERRM;
END;
$$;

DO $$
BEGIN
    ALTER TABLE IF EXISTS arch_ext.idw_pdl_ref_buffer OWNER TO r_fors_db_owner;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Ошибка при смене владельца arch_ext.idw_pdl_ref_buffer: %', SQLERRM;
END;
$$;

-- 2.11 Буферная таблица arch_ext.idw_arj_pdl_categories_buffer
DO $$
BEGIN
    CREATE TABLE IF NOT EXISTS arch_ext.idw_arj_pdl_categories_buffer AS
    SELECT * FROM arch_ext.idw_arj_pdl_categories LIMIT 0;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Ошибка при создании arch_ext.idw_arj_pdl_categories_buffer: %', SQLERRM;
END;
$$;

DO $$
BEGIN
    ALTER TABLE IF EXISTS arch_ext.idw_arj_pdl_categories_buffer
        ADD CONSTRAINT idw_arj_pdl_categories_buffer_pk PRIMARY KEY (id);
EXCEPTION
    WHEN SQLSTATE '42P07' OR SQLSTATE '23505' THEN
        RAISE NOTICE 'Ограничение idw_arj_pdl_categories_buffer_pk уже существует или таблица уже имеет первичный ключ';
    WHEN OTHERS THEN
        RAISE NOTICE 'Ошибка при добавлении PK arch_ext.idw_arj_pdl_categories_buffer: %', SQLERRM;
END;
$$;

DO $$
BEGIN
    COMMENT ON CONSTRAINT idw_arj_pdl_categories_buffer_pk ON arch_ext.idw_arj_pdl_categories_buffer
        IS 'Уникальность буферизации';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Ошибка при добавлении комментария arch_ext.idw_arj_pdl_categories_buffer: %', SQLERRM;
END;
$$;

DO $$
BEGIN
    ALTER TABLE IF EXISTS arch_ext.idw_arj_pdl_categories_buffer OWNER TO r_fors_db_owner;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Ошибка при смене владельца arch_ext.idw_arj_pdl_categories_buffer: %', SQLERRM;
END;
$$;

-- =====================================================================
-- ЧАСТЬ 3: ВСТАВКА ДАННЫХ В WORKFLOW
-- =====================================================================

-- Вставка workflow (процесса)
INSERT INTO process_info.idw_sr_workflow (
    id,
    parent_id,
    code,
    "name",
    note,
    date_from,
    date_to,
    is_actual,
    is_deleted,
    create_date,
    create_user,
    update_date,
    update_user,
    delete_date,
    delete_user
) VALUES (
    225,
    NULL,
    'EOR_PDL_LOAD',
    'EOR: (ПДЛ).Пополнение спецреестра ЕОР из архивного слоя ПДЛ (ИНТЕРФАКС X-Complience))',
    'EOR: (ПДЛ).Пополнение спецреестра ЕОР из архивного слоя ПДЛ (ИНТЕРФАКС X-Complience))',
    '1900-01-01 00:00:00',
    '2099-01-01 00:00:00',
    '1',
    '0',
    '2018-03-26 16:06:19',
    'IDWH2',
    NULL,
    NULL,
    NULL,
    NULL
)
ON CONFLICT (id) DO NOTHING;

-- Вставка состояний процесса (order_by = 1)
INSERT INTO process_info.idw_sr_workflow_state (
    id,
    parent_id,
    code,
    "name",
    note,
    date_from,
    date_to,
    is_actual,
    is_deleted,
    create_date,
    create_user,
    update_date,
    update_user,
    delete_date,
    delete_user,
    workflow_id,
    order_by,
    object_descr,
    state_proc
) VALUES (
    2251,
    NULL,
    'EOR_PDL_LOAD',
    'EOR: (ПДЛ).Новая запись архивного слоя ПДЛ. Требуется загрузка в  спецреестр ЕОР.',
    'EOR: (ПДЛ).Новая запись архивного слоя ПДЛ. Требуется загрузка в  спецреестр ЕОР.',
    '1900-01-01 00:00:00',
    '2099-01-01 00:00:00',
    '1',
    '0',
    '2018-03-26 16:06:19',
    'IDWH2',
    NULL,
    NULL,
    NULL,
    NULL,
    225,
    1,
    NULL,
    NULL
)
ON CONFLICT (id) DO NOTHING;

-- Вставка состояний процесса (order_by = 2)
INSERT INTO process_info.idw_sr_workflow_state (
    id,
    parent_id,
    code,
    "name",
    note,
    date_from,
    date_to,
    is_actual,
    is_deleted,
    create_date,
    create_user,
    update_date,
    update_user,
    delete_date,
    delete_user,
    workflow_id,
    order_by,
    object_descr,
    state_proc
) VALUES (
    2252,
    NULL,
    'EOR_PDL_IDENT',
    'EOR: (ПДЛ).Запись ПДЛ в спецреестре ЕОР не имеет связи с субъектом ЕОР. Требуется установить связь.',
    'EOR: (ПДЛ).Запись ПДЛ в спецреестре ЕОР не имеет связи с субъектом ЕОР. Требуется установить связь.',
    '1900-01-01 00:00:00',
    '2099-01-01 00:00:00',
    '1',
    '0',
    '2018-03-26 16:06:21',
    'IDWH2',
    NULL,
    NULL,
    NULL,
    NULL,
    225,
    2,
    NULL,
    NULL
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO process_info.process_state (
    process_alias,
    last_id,
    last_time,
    can_run,
    before_last_time,
    last_id_2,
    workflow_id,
    state_id,
    batch_size,
    max_attempt,
    max_error,
    newest_first,
    log_level,
    parallel_level,
    load_size,
    change_user,
    change_date
) VALUES
    (
        'PR_EOR_PDL_IDENT',
        0,
        NULL,
        '1',
        NULL,
        0,
        225,
        2252,
        1000,
        3,
        5,
        '1',
        0,
        1,
        1000,
        'IDWH2',
        '2026-09-08 13:07:22.244567'
    ),
    (
        'PR_EOR_PDL_LOAD_PG',
        0,
        '2026-08-13 14:13:54.466195',
        '1',
        '2026-08-13 14:13:54.466197',
        85,
        225,
        2251,
        1000,
        5,
        1500000,
        '1',
        0,
        1,
        1000,
        'timonov.d',
        '2026-08-13 14:13:54.466198'
    )
ON CONFLICT (process_alias) DO NOTHING;

-- =====================================================================
-- ЧАСТЬ 4: ПРОВЕРКА ВСТАВЛЕННЫХ ЗАПИСЕЙ
-- =====================================================================

-- Проверка workflow
SELECT 'WORKFLOW:' as check_type, id, code, "name" 
FROM process_info.idw_sr_workflow WHERE id = 225;

-- Проверка состояний
SELECT 'WORKFLOW_STATES:' as check_type, id, code, "name", order_by 
FROM process_info.idw_sr_workflow_state 
WHERE workflow_id = 225 ORDER BY order_by;

-- Проверка process_state
SELECT 'PROCESS_STATES:' as check_type, process_alias, workflow_id, state_id, can_run
FROM process_info.process_state 
WHERE workflow_id = 225 ORDER BY process_alias;

-- Проверка связки
SELECT 
    w.id AS workflow_id,
    w.code AS workflow_code,
    s.id AS state_id,
    s.code AS state_code,
    s.order_by,
    p.process_alias,
    p.can_run
FROM process_info.idw_sr_workflow w
LEFT JOIN process_info.idw_sr_workflow_state s ON w.id = s.workflow_id
LEFT JOIN process_info.process_state p ON p.workflow_id = w.id AND p.state_id = s.id
WHERE w.id = 225
ORDER BY s.order_by;

-- =====================================================================
-- ИТОГОВОЕ СООБЩЕНИЕ
-- =====================================================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '╔══════════════════════════════════════════════════════════════╗';
    RAISE NOTICE '║         ЕДИНЫЙ СКРИПТ ИЗМЕНЕНИЙ ВЫПОЛНЕН                  ║';
    RAISE NOTICE '╠══════════════════════════════════════════════════════════════╣';
    RAISE NOTICE '║ Время выполнения: %', clock_timestamp();
    RAISE NOTICE '╠══════════════════════════════════════════════════════════════╣';
    RAISE NOTICE '║ Выполнены операции:                                        ║';
    RAISE NOTICE '║  1. Импорт схемы pdl через FDW в arch_ext                  ║';
    RAISE NOTICE '║  2. Создана опорная таблица                                ║';
    RAISE NOTICE '║  3. Созданы 10 буферных таблиц                             ║';
    RAISE NOTICE '║  4. Добавлен workflow EOR_PDL_LOAD (id=225)                ║';
    RAISE NOTICE '║  5. Добавлены состояния workflow (2251, 2252)              ║';
    RAISE NOTICE '║  6. Добавлены записи в process_state                       ║';
    RAISE NOTICE '╚══════════════════════════════════════════════════════════════╝';
    RAISE NOTICE '';
END $$;

COMMIT;
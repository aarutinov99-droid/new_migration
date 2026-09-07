-- =====================================================
-- 1. Опорная таблица arch_ext.idw_arj_interfax_pdl_load_buffer
-- =====================================================
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

-- =====================================================
-- 2. Буферная таблица arch_ext.idw_arj_interfax_pdl_buffer
-- =====================================================
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

-- =====================================================
-- 3. Буферная таблица arch_ext.idw_arj_pdl_category407_buffer
-- =====================================================
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

-- =====================================================
-- 4. Буферная таблица arch_ext.idw_arj_pdl_countries_buffer
-- =====================================================
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

-- =====================================================
-- 5. Буферная таблица arch_ext.idw_arj_pdl_jobs_buffer
-- =====================================================
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

-- =====================================================
-- 6. Буферная таблица arch_ext.idw_arj_pdl_names_buffer
-- =====================================================
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

-- =====================================================
-- 7. Буферная таблица arch_ext.idw_arj_pdl_sanctions_buffer
-- =====================================================
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

-- =====================================================
-- 8. Буферная таблица arch_ext.idw_arj_pdl_sanlists_buffer
-- =====================================================
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

-- =====================================================
-- 9. Буферная таблица arch_ext.idw_arj_pdl_translit_names_buffer
-- =====================================================
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

-- =====================================================
-- 10. Буферная таблица arch_ext.idw_pdl_ref_buffer
-- =====================================================
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



-- =====================================================
-- 11. Буферная таблица arch_ext.idw_arj_pdl_categories_buffer
-- =====================================================
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
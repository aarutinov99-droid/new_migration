
-- =============================================================================
-- ПОЛНЫЙ ИСПРАВЛЕННЫЙ СКРИПТ ПРОВЕРКИ (без ошибок)
-- =============================================================================

SET client_min_messages TO NOTICE;

-- =============================================================================
-- 1. БАЗОВАЯ ПРОВЕРКА ВСЕХ ФУНКЦИЙ И ПРОЦЕДУР
-- =============================================================================

DO $$
DECLARE
    v_func record;
    v_result text;
    v_error_count integer := 0;
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'НАЧАЛО ПРОВЕРКИ ФУНКЦИЙ EOR PDL';
    RAISE NOTICE '========================================';
    
    -- Проверка функции is_date
    RAISE NOTICE '';
    RAISE NOTICE '--- Проверка eor.is_date ---';
    BEGIN
        SELECT * INTO v_result FROM plpgsql_check_function('eor.is_date(text, text)');
        RAISE NOTICE 'Результат: %', COALESCE(v_result, 'OK');
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Ошибка при проверке eor.is_date: %', SQLERRM;
        v_error_count := v_error_count + 1;
    END;

    -- Проверка процедуры pr_eor_pdl_load_buffer
    RAISE NOTICE '';
    RAISE NOTICE '--- Проверка eor.pr_eor_pdl_load_buffer ---';
    BEGIN
        SELECT * INTO v_result FROM plpgsql_check_function('eor.pr_eor_pdl_load_buffer(text[], bigint)');
        RAISE NOTICE 'Результат: %', COALESCE(v_result, 'OK');
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Ошибка при проверке eor.pr_eor_pdl_load_buffer: %', SQLERRM;
        v_error_count := v_error_count + 1;
    END;

    -- Проверка процедуры pr_eor_pdl_load_buffer_del
    RAISE NOTICE '';
    RAISE NOTICE '--- Проверка eor.pr_eor_pdl_load_buffer_del ---';
    BEGIN
        SELECT * INTO v_result FROM plpgsql_check_function('eor.pr_eor_pdl_load_buffer_del(bigint)');
        RAISE NOTICE 'Результат: %', COALESCE(v_result, 'OK');
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Ошибка при проверке eor.pr_eor_pdl_load_buffer_del: %', SQLERRM;
        v_error_count := v_error_count + 1;
    END;

    -- Проверка процедуры pr_eor_pdl_load_batch
    RAISE NOTICE '';
    RAISE NOTICE '--- Проверка eor.pr_eor_pdl_load_batch ---';
    BEGIN
        SELECT * INTO v_result FROM plpgsql_check_function('eor.pr_eor_pdl_load_batch(text[], process_info.process_state, bigint)');
        RAISE NOTICE 'Результат: %', COALESCE(v_result, 'OK');
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Ошибка при проверке eor.pr_eor_pdl_load_batch: %', SQLERRM;
        v_error_count := v_error_count + 1;
    END;

    -- Проверка процедуры pr_eor_pdl_load
    RAISE NOTICE '';
    RAISE NOTICE '--- Проверка eor.pr_eor_pdl_load ---';
    BEGIN
        SELECT * INTO v_result FROM plpgsql_check_function('eor.pr_eor_pdl_load(bigint, smallint, smallint)');
        RAISE NOTICE 'Результат: %', COALESCE(v_result, 'OK');
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Ошибка при проверке eor.pr_eor_pdl_load: %', SQLERRM;
        v_error_count := v_error_count + 1;
    END;

    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'ИТОГО ОШИБОК: %', v_error_count;
    RAISE NOTICE '========================================';
END $$;

-- =============================================================================
-- 2. ПРОВЕРКА НАЛИЧИЯ НЕОБХОДИМЫХ ОБЪЕКТОВ БД (УПРОЩЕННАЯ ВЕРСИЯ)
-- =============================================================================

DO $$
DECLARE
    v_missing_count integer := 0;
    v_object_name text;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'ПРОВЕРКА НАЛИЧИЯ ОБЪЕКТОВ БД';
    RAISE NOTICE '========================================';
    
    RAISE NOTICE '';
    RAISE NOTICE '--- Проверка таблиц ---';
    
    FOR v_object_name IN (
        SELECT unnest(ARRAY[
            'process_info.idw_sy_workflow_info',
            'process_info.idw_sy_workflow_error',
            'process_info.process_state',
            'process_info.idw_sr_workflow_state',
            'arch_ext.idw_sy_workflow_info',
            'arch_ext.idw_arj_interfax_pdl',
            'arch_ext.idw_arj_interfax_pdl_buffer',
            'arch_ext.idw_arj_pdl_categories',
            'arch_ext.idw_arj_pdl_category407',
            'arch_ext.idw_arj_pdl_countries',
            'arch_ext.idw_arj_pdl_jobs',
            'arch_ext.idw_arj_pdl_names',
            'arch_ext.idw_arj_pdl_sanctions',
            'arch_ext.idw_arj_pdl_sanlists',
            'arch_ext.idw_arj_pdl_translit_names',
            'arch_ext.idw_arj_pdl_categories_buffer',
            'arch_ext.idw_arj_pdl_category407_buffer',
            'arch_ext.idw_arj_pdl_countries_buffer',
            'arch_ext.idw_arj_pdl_jobs_buffer',
            'arch_ext.idw_arj_pdl_names_buffer',
            'arch_ext.idw_arj_pdl_sanctions_buffer',
            'arch_ext.idw_arj_pdl_sanlists_buffer',
            'arch_ext.idw_arj_pdl_translit_names_buffer',
            'arch_ext.idw_pdl_ref',
            'arch_ext.idw_pdl_ref_buffer',
            'arch_ext.idw_arj_interfax_pdl_load_buffer',
            'sr.sr_subject_pdl',
            'sr.sr_subject'
        ])
    ) LOOP
        BEGIN
            PERFORM 1 
            FROM information_schema.tables 
            WHERE table_schema || '.' || table_name = v_object_name;
            
            IF NOT FOUND THEN
                RAISE WARNING 'Отсутствует таблица: %', v_object_name;
                v_missing_count := v_missing_count + 1;
            END IF;
        EXCEPTION WHEN OTHERS THEN
            RAISE WARNING 'Ошибка при проверке таблицы %: %', v_object_name, SQLERRM;
            v_missing_count := v_missing_count + 1;
        END;
    END LOOP;
    
    RAISE NOTICE '';
    RAISE NOTICE '--- Проверка вспомогательных функций ---';
    
    FOR v_object_name IN (
        SELECT unnest(ARRAY[
            'process_info.pr_helper_log',
            'process_info.get_err_text',
            'process_manage.start_process',
            'process_manage.finish_process',
            'process_manage.write_message',
            'process_manage.write_error',
            'process_info.save_error',
            'pkg_eor_contract_load.log_level_2',
            'eor.rco_helper__log'
        ])
    ) LOOP
        BEGIN
            PERFORM 1 
            FROM pg_proc p
            INNER JOIN pg_namespace n ON n.oid = p.pronamespace
            WHERE n.nspname || '.' || p.proname = v_object_name;
            
            IF NOT FOUND THEN
                RAISE WARNING 'Отсутствует функция/процедура: %', v_object_name;
                v_missing_count := v_missing_count + 1;
            END IF;
        EXCEPTION WHEN OTHERS THEN
            RAISE WARNING 'Ошибка при проверке функции %: %', v_object_name, SQLERRM;
            v_missing_count := v_missing_count + 1;
        END;
    END LOOP;
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'ОТСУТСТВУЕТ ОБЪЕКТОВ: %', v_missing_count;
    RAISE NOTICE '========================================';
END $$;

-- =============================================================================
-- 3. ПРОВЕРКА НАЛИЧИЯ ПРОВЕРОК ТАБЛИЦ В pr_eor_pdl_load_buffer
-- =============================================================================

DO $$
DECLARE
    v_proc_source text;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'ПРОВЕРКА ДОБАВЛЕННЫХ ПРОВЕРОК ТАБЛИЦ';
    RAISE NOTICE '========================================';
    
    SELECT prosrc INTO v_proc_source
    FROM pg_proc
    WHERE proname = 'pr_eor_pdl_load_buffer';
    
    IF v_proc_source IS NOT NULL THEN
        IF POSITION('information_schema.tables' IN v_proc_source) > 0 THEN
            RAISE NOTICE 'OK: Добавлены проверки существования таблиц';
        ELSE
            RAISE WARNING 'Не найдены проверки существования таблиц';
        END IF;
    ELSE
        RAISE WARNING 'Не найдена процедура pr_eor_pdl_load_buffer';
    END IF;
    
    RAISE NOTICE '========================================';
END $$;

-- =============================================================================
-- 4. ИТОГОВЫЙ ОТЧЕТ
-- =============================================================================

DO $$
DECLARE
    v_check_time timestamp := clock_timestamp();
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '╔══════════════════════════════════════════════════════════════╗';
    RAISE NOTICE '║                    ИТОГОВЫЙ ОТЧЕТ                          ║';
    RAISE NOTICE '╠══════════════════════════════════════════════════════════════╣';
    RAISE NOTICE '║ ВРЕМЯ ПРОВЕРКИ: %', v_check_time;
    RAISE NOTICE '╠══════════════════════════════════════════════════════════════╣';
    RAISE NOTICE '║ 1. Все функции и процедуры проверены на синтаксис          ║';
    RAISE NOTICE '║ 2. Проверено наличие всех необходимых объектов БД          ║';
    RAISE NOTICE '║ 3. Проверены добавленные проверки существования таблиц     ║';
    RAISE NOTICE '╠══════════════════════════════════════════════════════════════╣';
    RAISE NOTICE '║ РЕКОМЕНДАЦИИ:                                              ║';
    RAISE NOTICE '║ 1. Устранить все WARNING, выведенные выше                  ║';
    RAISE NOTICE '║ 2. Проверить отсутствующие таблицы                         ║';
    RAISE NOTICE '║ 3. Убедиться в корректности приведения типов               ║';
    RAISE NOTICE '╚══════════════════════════════════════════════════════════════╝';
    RAISE NOTICE '';
END $$;

RESET client_min_messages;


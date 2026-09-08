
-- =============================================================================
-- Функция обработки пакета записей
-- =============================================================================
CREATE OR REPLACE FUNCTION IDWH2.pr_eor_pdl_ident_batch(
    p_process_data     RECORD,
    p_batch_size       INTEGER,
    p_error_sign       CHAR(1)
)
RETURNS RECORD
LANGUAGE plpgsql
AS $$
DECLARE
    l_cnt         INTEGER := 0;
    l_err_cnt     INTEGER := 0;
    l_start_date  TIMESTAMP;
    l_end_date    TIMESTAMP;
    l_result      RECORD;
    l_process     TEXT := 'PR_EOR_PDL_IDENT';
    l_procedure   TEXT := 'pr_eor_pdl_ident';
BEGIN
    l_start_date := clock_timestamp();

    FOR c IN (
        SELECT p.date_birthday,
               p.full_name,
               p.sr_subject_id,
               p.system_id,
               p.countries,
               p.rowid AS rid,
               p.update_date
          FROM eor.sr_subject_pdl p
          LEFT JOIN eor.sr_subject s ON s.sr_subject_id = p.sr_subject_id
         WHERE p.is_eor_ident_process = 0
           AND s.etalon_registry_id IS NULL
         LIMIT p_batch_size
    ) LOOP
        BEGIN
            SAVEPOINT pr_eor_pdl_ident;

            RAISE NOTICE '% загрузка system_id = %  l_id = %', 
                l_process, c.system_id, c.sr_subject_id;

            -- Обработка субъекта
            l_result := IDWH2.process_pdl_subject(
                c.sr_subject_id,
                c.full_name,
                c.date_birthday,
                c.system_id::TEXT,
                c.countries,
                c.rid::TEXT,
                c.update_date,
                p_process_data
            );

            l_cnt := l_cnt + 1;
            l_err_cnt := l_err_cnt + l_result.error_count;

            RAISE NOTICE '% Выполнено system_id = %  l_id = %', 
                l_process, c.system_id, c.sr_subject_id;

            EXIT WHEN l_cnt >= p_batch_size;

        EXCEPTION
            WHEN OTHERS THEN
                PERFORM idwh2.pkg_eor_aux.save_error(
                    c.sr_subject_id::TEXT,
                    p_process_data.workflow_id,
                    p_process_data.state_id,
                    SQLSTATE,
                    SQLERRM,
                    'Backtrace not available in PostgreSQL'
                );
                ROLLBACK TO SAVEPOINT pr_eor_pdl_ident;
                l_err_cnt := l_err_cnt + 1;
        END;
    END LOOP;

    COMMIT;

    l_end_date := clock_timestamp();

    -- Возвращаем результат
    SELECT l_cnt, l_err_cnt, l_start_date, l_end_date INTO l_result;
    RETURN l_result;

END;
$$;


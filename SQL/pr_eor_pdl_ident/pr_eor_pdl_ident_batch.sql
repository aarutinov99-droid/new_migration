-- =============================================================================
-- ПРОЦЕДУРА ОБРАБОТКИ ПАКЕТА (бывшая встроенная процедура process_batch)
-- =============================================================================
CREATE OR REPLACE PROCEDURE IDWH2.process_batch_pdl_ident(
    p_process_data     RECORD,
    p_batch_size       INTEGER,
    p_error_sign       CHAR(1),
    INOUT p_cnt        INTEGER,
    INOUT p_err_cnt    INTEGER,
    INOUT p_start_date TIMESTAMP,
    INOUT p_end_date   TIMESTAMP
)
LANGUAGE plpgsql
AS $$
DECLARE
    l_sr_type_id               INTEGER := 145;
    l_source_id                INTEGER := 2070;
    l_sr_subject_count         INTEGER;
    l_sr_subject_id            INTEGER;
    l_etalon_registry_id       INTEGER;
    l_is_rfl                   INTEGER;
    l_find_id                  INTEGER;
    l_eor_subject_mention_id   INTEGER;
    l_sr_event_id              INTEGER;
    l_rfl_attr                 RECORD;
    l_ifl_attr                 RECORD;
    l_id                       TEXT;
    l_process                  TEXT := 'PR_EOR_PDL_IDENT';
    l_procedure                TEXT := 'pr_eor_pdl_ident';
BEGIN
    p_start_date := clock_timestamp();
    p_cnt := 0;
    p_err_cnt := 0;

	------------------------------------------------------------------------------
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
            -- Сохранение точки для отката
            SAVEPOINT pr_eor_pdl_ident;

            l_id := c.sr_subject_id::TEXT;
            RAISE NOTICE '% загрузка system_id = %  l_id = %', l_process, c.system_id, l_id;

            l_etalon_registry_id := NULL;
            l_sr_subject_id := NULL;

            -- Проверка наличия в спецреестре
            SELECT COUNT(1) INTO l_sr_subject_count
              FROM eor.sr_subject s
             WHERE s.sr_subject_id = c.sr_subject_id
               AND s.sr_type_id = l_sr_type_id;

            IF l_sr_subject_count > 0 THEN
                SELECT s.sr_subject_id INTO l_sr_subject_id
                  FROM eor.sr_subject s
                 WHERE s.sr_subject_id = c.sr_subject_id
                   AND s.sr_type_id = l_sr_type_id;
            END IF;

            -- Определение гражданства
            IF UPPER(c.countries) LIKE '%РОССИЯ%' OR c.countries IS NULL THEN
                l_is_rfl := 1;
            ELSE
                l_is_rfl := 0;
            END IF;

            -- =====================================================================
            -- Поиск в ЕОР для РФЛ
            -- =====================================================================
            IF l_is_rfl = 1 AND c.full_name IS NOT NULL THEN
                l_find_id := IDWH2.find_rfl_candidate_func(c.full_name, c.date_birthday);

                -- ФИО + ДатаРождения, Эталонная запись
                IF l_etalon_registry_id IS NULL AND c.full_name IS NOT NULL AND c.date_birthday IS NOT NULL THEN
                    BEGIN
                        SELECT m.etalon_registry_id INTO l_etalon_registry_id
                          FROM (
                                SELECT MAX(m.etalon_registry_id) AS etalon_registry_id,
                                       COUNT(1) AS c
                                  FROM eor.tmp_eor_ident_candidate t
                                  JOIN idwh2.idwh2_etalon_flrn m ON t.etalon_registry_id = m.etalon_registry_id
                                  JOIN idwh2.idw_mr_master mm ON m.etalon_registry_id = mm.etalon_registry_id
                                 WHERE m.full_name = TRIM(UPPER(c.full_name))
                                   AND m.birth_date = c.date_birthday
                                   AND mm.etalon_sign = '1'
                               ) sub
                         WHERE sub.c = 1;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            NULL;
                    END;
                END IF;

                -- ФИО + ДатаРождения, Неэталонная запись
                IF l_etalon_registry_id IS NULL AND c.full_name IS NOT NULL AND c.date_birthday IS NOT NULL THEN
                    BEGIN
                        SELECT m.etalon_registry_id INTO l_etalon_registry_id
                          FROM (
                                SELECT MAX(m.etalon_registry_id) AS etalon_registry_id,
                                       COUNT(1) AS c
                                  FROM eor.tmp_eor_ident_candidate t
                                  JOIN idwh2.idwh2_etalon_flrn m ON t.etalon_registry_id = m.etalon_registry_id
                                  JOIN idwh2.idw_mr_master mm ON m.etalon_registry_id = mm.etalon_registry_id
                                 WHERE m.full_name = TRIM(UPPER(c.full_name))
                                   AND m.birth_date = c.date_birthday
                                   AND mm.etalon_sign = '0'
                               ) sub
                         WHERE sub.c = 1;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            NULL;
                    END;
                END IF;

                -- ФИО, Эталонная запись
                IF l_etalon_registry_id IS NULL AND c.full_name IS NOT NULL THEN
                    BEGIN
                        SELECT m.etalon_registry_id INTO l_etalon_registry_id
                          FROM (
                                SELECT MAX(m.etalon_registry_id) AS etalon_registry_id,
                                       COUNT(1) AS c
                                  FROM eor.tmp_eor_ident_candidate t
                                  JOIN idwh2.idwh2_etalon_flrn m ON t.etalon_registry_id = m.etalon_registry_id
                                  JOIN idwh2.idw_mr_master mm ON m.etalon_registry_id = mm.etalon_registry_id
                                 WHERE m.full_name = TRIM(UPPER(c.full_name))
                                   AND mm.etalon_sign = '1'
                               ) sub
                         WHERE sub.c = 1;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            NULL;
                    END;
                END IF;

                -- ФИО, Неэталонная запись
                IF l_etalon_registry_id IS NULL AND c.full_name IS NOT NULL THEN
                    BEGIN
                        SELECT m.etalon_registry_id INTO l_etalon_registry_id
                          FROM (
                                SELECT MAX(m.etalon_registry_id) AS etalon_registry_id,
                                       COUNT(1) AS c
                                  FROM eor.tmp_eor_ident_candidate t
                                  JOIN idwh2.idwh2_etalon_flrn m ON t.etalon_registry_id = m.etalon_registry_id
                                  JOIN idwh2.idw_mr_master mm ON m.etalon_registry_id = mm.etalon_registry_id
                                 WHERE m.full_name = TRIM(UPPER(c.full_name))
                                   AND mm.etalon_sign = '0'
                               ) sub
                         WHERE sub.c = 1;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            NULL;
                    END;
                END IF;
            END IF;

            -- =====================================================================
            -- Поиск в ЕОР для ИФЛ
            -- =====================================================================
            IF l_is_rfl = 0 AND c.full_name IS NOT NULL THEN
                l_find_id := IDWH2.find_nr_fl_candidate_func(c.full_name, c.date_birthday);

                -- ФИО + ДатаРождения, Эталонная запись
                IF l_etalon_registry_id IS NULL AND c.full_name IS NOT NULL AND c.date_birthday IS NOT NULL THEN
                    BEGIN
                        SELECT m.etalon_registry_id INTO l_etalon_registry_id
                          FROM (
                                SELECT MAX(m.etalon_registry_id) AS etalon_registry_id,
                                       COUNT(1) AS c
                                  FROM eor.tmp_eor_ident_candidate t
                                  JOIN idwh2.idwh2_etalon_nr_fl m ON t.etalon_registry_id = m.etalon_registry_id
                                  JOIN idwh2.idw_mr_master mm ON m.etalon_registry_id = mm.etalon_registry_id
                                 WHERE m.full_name = TRIM(UPPER(c.full_name))
                                   AND m.birth_date = c.date_birthday
                                   AND mm.etalon_sign = '1'
                               ) sub
                         WHERE sub.c = 1;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            NULL;
                    END;
                END IF;

                -- ФИО + ДатаРождения, Неэталонная запись
                IF l_etalon_registry_id IS NULL AND c.full_name IS NOT NULL AND c.date_birthday IS NOT NULL THEN
                    BEGIN
                        SELECT m.etalon_registry_id INTO l_etalon_registry_id
                          FROM (
                                SELECT MAX(m.etalon_registry_id) AS etalon_registry_id,
                                       COUNT(1) AS c
                                  FROM eor.tmp_eor_ident_candidate t
                                  JOIN idwh2.idwh2_etalon_nr_fl m ON t.etalon_registry_id = m.etalon_registry_id
                                  JOIN idwh2.idw_mr_master mm ON m.etalon_registry_id = mm.etalon_registry_id
                                 WHERE m.full_name = TRIM(UPPER(c.full_name))
                                   AND m.birth_date = c.date_birthday
                                   AND mm.etalon_sign = '0'
                               ) sub
                         WHERE sub.c = 1;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            NULL;
                    END;
                END IF;

                -- ФИО, Эталонная запись
                IF l_etalon_registry_id IS NULL AND c.full_name IS NOT NULL THEN
                    BEGIN
                        SELECT m.etalon_registry_id INTO l_etalon_registry_id
                          FROM (
                                SELECT MAX(m.etalon_registry_id) AS etalon_registry_id,
                                       COUNT(1) AS c
                                  FROM eor.tmp_eor_ident_candidate t
                                  JOIN idwh2.idwh2_etalon_nr_fl m ON t.etalon_registry_id = m.etalon_registry_id
                                  JOIN idwh2.idw_mr_master mm ON m.etalon_registry_id = mm.etalon_registry_id
                                 WHERE m.full_name = TRIM(UPPER(c.full_name))
                                   AND mm.etalon_sign = '1'
                               ) sub
                         WHERE sub.c = 1;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            NULL;
                    END;
                END IF;

                -- ФИО, Неэталонная запись
                IF l_etalon_registry_id IS NULL AND c.full_name IS NOT NULL THEN
                    BEGIN
                        SELECT m.etalon_registry_id INTO l_etalon_registry_id
                          FROM (
                                SELECT MAX(m.etalon_registry_id) AS etalon_registry_id,
                                       COUNT(1) AS c
                                  FROM eor.tmp_eor_ident_candidate t
                                  JOIN idwh2.idwh2_etalon_nr_fl m ON t.etalon_registry_id = m.etalon_registry_id
                                  JOIN idwh2.idw_mr_master mm ON m.etalon_registry_id = mm.etalon_registry_id
                                 WHERE m.full_name = TRIM(UPPER(c.full_name))
                                   AND mm.etalon_sign = '0'
                               ) sub
                         WHERE sub.c = 1;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            NULL;
                    END;
                END IF;
            END IF;

            -- =====================================================================
            -- ИДЕНТИФИЦИРОВАН
            -- =====================================================================
            IF l_etalon_registry_id IS NOT NULL AND l_sr_subject_id > 0 THEN
                l_sr_event_id := idwh2.sr_common_pkg.sr_event_add(101, l_sr_type_id, c.sr_subject_id, l_etalon_registry_id, NULL, '0', CURRENT_USER);
                PERFORM idwh2.sr_common_pkg.sr_subject_save_h(c.sr_subject_id);

                UPDATE eor.sr_subject s
                   SET etalon_registry_id = l_etalon_registry_id,
                       sr_event_id = l_sr_event_id
                 WHERE s.sr_subject_id = c.sr_subject_id
                   AND s.sr_type_id = l_sr_type_id;

            ELSIF l_etalon_registry_id IS NOT NULL AND l_sr_subject_id IS NULL THEN
                l_sr_event_id := idwh2.sr_common_pkg.sr_event_add(100, l_sr_type_id, c.sr_subject_id, l_etalon_registry_id, NULL, '0', CURRENT_USER);

                INSERT INTO eor.sr_subject (
                    sr_subject_id,
                    etalon_registry_id,
                    incl_first_date,
                    incl_date,
                    incl_reason,
                    excl_reason,
                    deleted_sign,
                    sr_type_id,
                    actual_sign,
                    checked_sign,
                    sr_event_id
                ) VALUES (
                    c.sr_subject_id,
                    l_etalon_registry_id,
                    CURRENT_TIMESTAMP,
                    CURRENT_TIMESTAMP,
                    'X-Complince',
                    NULL,
                    '0',
                    l_sr_type_id,
                    '1',
                    '0',
                    l_sr_event_id
                );
            END IF;

            -- =====================================================================
            -- СОЗДАЕМ УПОМИНАНИЕ
            -- =====================================================================
            l_eor_subject_mention_id := NULL;

            IF l_etalon_registry_id IS NULL THEN
                BEGIN
                    SELECT t.eor_subject_mention_id INTO l_eor_subject_mention_id
                      FROM idwh2.idw_mr_subject_mention t
                     WHERE source_id = l_source_id
                       AND external_h_id = c.rid::TEXT;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        NULL;
                END;

                IF l_is_rfl = 1 AND l_eor_subject_mention_id IS NULL THEN
                    l_rfl_attr.full_name := c.full_name;
                    l_rfl_attr.birth_date := c.date_birthday;
                    l_eor_subject_mention_id := pkg_eor_api.add_subj_rfl_mention(
                        l_source_id,
                        0,
                        c.system_id,
                        c.rid::TEXT,
                        c.update_date,
                        l_rfl_attr,
                        10,
                        0
                    );
                END IF;

                IF l_is_rfl = 1 AND l_eor_subject_mention_id IS NULL THEN
                    l_ifl_attr.full_name := c.full_name;
                    l_ifl_attr.birth_date := c.date_birthday;
                    l_eor_subject_mention_id := pkg_eor_api.add_subj_ifl_mention(
                        l_source_id,
                        0,
                        c.system_id,
                        c.rid::TEXT,
                        c.update_date,
                        l_ifl_attr,
                        10,
                        0
                    );
                END IF;

                IF l_sr_subject_id IS NULL AND l_eor_subject_mention_id IS NOT NULL THEN
                    l_sr_event_id := idwh2.sr_common_pkg.sr_event_add(100, l_sr_type_id, c.sr_subject_id, l_etalon_registry_id, NULL, '0', CURRENT_USER);

                    INSERT INTO eor.sr_subject (
                        sr_subject_id,
                        eor_subject_mention_id,
                        incl_first_date,
                        incl_date,
                        incl_reason,
                        excl_reason,
                        deleted_sign,
                        sr_type_id,
                        actual_sign,
                        checked_sign,
                        sr_event_id
                    ) VALUES (
                        c.sr_subject_id,
                        l_eor_subject_mention_id,
                        CURRENT_TIMESTAMP,
                        CURRENT_TIMESTAMP,
                        'X-Complince',
                        NULL,
                        '0',
                        l_sr_type_id,
                        '1',
                        '0',
                        l_sr_event_id
                    );
                ELSE
                    PERFORM idwh2.sr_common_pkg.sr_subject_save_h(c.sr_subject_id);
                    l_sr_event_id := idwh2.sr_common_pkg.sr_event_add(101, l_sr_type_id, c.sr_subject_id, l_etalon_registry_id, NULL, '0', CURRENT_USER);

                    UPDATE eor.sr_subject s
                       SET eor_subject_mention_id = l_eor_subject_mention_id,
                           sr_event_id = l_sr_event_id,
                           deleted_sign = '0',
                           actual_sign = '1',
                           checked_sign = '4',
                           excl_date = NULL,
                           excl_reason = NULL
                     WHERE s.sr_subject_id = c.sr_subject_id
                       AND s.sr_type_id = l_sr_type_id;
                END IF;
            END IF;

            -- Удаление ошибок
            DELETE FROM idw_sy_workflow_error
             WHERE workflow_id = p_process_data.workflow_id
               AND state_id = p_process_data.state_id
               AND object_id = l_id;

            p_cnt := p_cnt + 1;

            UPDATE eor.sr_subject_pdl p
               SET is_eor_ident_process = 1
             WHERE p.sr_subject_id = c.sr_subject_id;

            RAISE NOTICE '% Выполнено system_id = %  l_id = %', l_process, c.system_id, l_id;

            -- Выход, если превышено количество обработанных объектов в пачке
            EXIT WHEN p_cnt >= p_batch_size;

        EXCEPTION
            WHEN OTHERS THEN
                PERFORM idwh2.pkg_eor_aux.save_error(
                    l_id,
                    p_process_data.workflow_id,
                    p_process_data.state_id,
                    SQLSTATE,
                    SQLERRM,
                    'Backtrace not available in PostgreSQL'
                );
                ROLLBACK TO SAVEPOINT pr_eor_pdl_ident;
                p_err_cnt := p_err_cnt + 1;
        END;
    END LOOP;

    COMMIT;
    p_end_date := clock_timestamp();

EXCEPTION
    WHEN OTHERS THEN
        p_end_date := clock_timestamp();
        RAISE;
END;
$$;
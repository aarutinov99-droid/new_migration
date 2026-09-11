-- =============================================================================
-- ПРОЦЕДУРА ОБРАБОТКИ ПАКЕТА (бывшая встроенная процедура process_batch)
-- =============================================================================
CREATE OR REPLACE PROCEDURE eor.pr_pdl_ident_batch(
	IN p_ids text[],
	IN p_process_data process_info.process_state,
	IN p_process_log_id bigint
)
LANGUAGE plpgsql
AS $$
DECLARE
	-- =========================================================================
	-- КОНСТАНТЫ
	-- =========================================================================
    c_workflow_id CONSTANT process_info.idw_sy_workflow_info.workflow_id%type := 225;  -- ИД рабочего процесса
    c_state_id CONSTANT process_info.idw_sy_workflow_info.state_id%type := 2252;        -- ИД состояния
	c_procedure constant text := 'fors_pg.eor.pr_pdl_ident_batch';                    -- Имя процедуры для логирования
    c_process CONSTANT text := 'PR_EOR_PDL_IDENT';                                    -- Имя процесса
    c_sr_type_id CONSTANT INTEGER := 145;                                                -- Тип субъекта в спецреестре
	c_source_id  CONSTANT INTEGER := 2070;
    
    -- =========================================================================
	-- ПЕРЕМЕННЫЕ
	-- =========================================================================
	c record;
    l_sr_subject_count         INTEGER;
    l_sr_subject_id            INTEGER;
    l_etalon_registry_id       INTEGER;
    l_is_rfl                   INTEGER;
    --l_find_id                  INTEGER; -- Не использовалась в логике кода Арутинов А.
    l_eor_subject_mention_id   INTEGER;
    l_sr_event_id              INTEGER;
    --l_rfl_attr                 RECORD;
    --l_ifl_attr                 RECORD;
    l_id                       TEXT;
	l_rfl_attr   eor.idw_mr_rfl_attr_src%rowtype;
   	l_ifl_attr   eor.idw_mr_ifl_attr_src%rowtype;
	
	----------------------------------------------------------------------------
	l_cnt INTEGER := 0;
	l_err_cnt INTEGER := 0;
	
BEGIN
    --p_start_date := clock_timestamp();
    --l_cnt := 0;
    --l_err_cnt := 0;

	------------------------------------------------------------------------------
    FOR c IN (
        SELECT p.date_birthday,
               p.full_name,
               p.sr_subject_id,
               p.system_id,
               p.countries,
               bf.id AS rid,
               p.update_date
          FROM sr.sr_subject_pdl p
		  join (select * from arch_ext.idw_arj_interfax_pdl_load_buffer where id = ANY(p_ids::bigint[])) bf on bf.sr_subject_id = p.sr_subject_id -- Ограничение батча
          LEFT JOIN sr.sr_subject s ON s.sr_subject_id = p.sr_subject_id
         WHERE p.is_eor_ident_process = 0
           AND s.etalon_registry_id IS NULL
    ) LOOP

        BEGIN
            -- Сохранение точки для отката
            --SAVEPOINT pr_eor_pdl_ident;
			
            l_id := c.sr_subject_id::TEXT;
            RAISE DEBUG '% загрузка system_id = %  l_id = %', c_process, c.system_id, l_id;

            l_etalon_registry_id := NULL;
            l_sr_subject_id := NULL;
			l_eor_subject_mention_id := NULL;
			l_is_rfl := NULL; 
			
            -- Проверка наличия в спецреестре
            SELECT COUNT(1) INTO l_sr_subject_count
              FROM sr.sr_subject s
             WHERE s.sr_subject_id = c.sr_subject_id
               AND s.sr_type_id = c_sr_type_id;

            IF l_sr_subject_count > 0 THEN
                SELECT s.sr_subject_id INTO l_sr_subject_id
                  FROM sr.sr_subject s
                 WHERE s.sr_subject_id = c.sr_subject_id
                   AND s.sr_type_id = c_sr_type_id;
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
                PERFORM eor.pr_eor_pdl_ident_find_rfl_candidate_func(c.full_name, c.date_birthday::date);
				IF EXISTS (SELECT 1 FROM eor.tmp_eor_ident_candidate) THEN -- Контроль наличия данных кандидатов

					-- ФИО + ДатаРождения, Эталонная запись
					IF l_etalon_registry_id IS NULL AND c.full_name IS NOT NULL AND c.date_birthday IS NOT NULL THEN
						BEGIN
							SELECT sub.etalon_registry_id INTO l_etalon_registry_id
							  FROM (
									SELECT MAX(m.etalon_registry_id) AS etalon_registry_id,
										   COUNT(1) AS c
									  FROM eor.tmp_eor_ident_candidate t
									  JOIN eor.idwh2_etalon_flrn m ON t.etalon_registry_id = m.etalon_registry_id
									  JOIN eor.idw_mr_master mm ON m.etalon_registry_id = mm.etalon_registry_id
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
							SELECT sub.etalon_registry_id INTO l_etalon_registry_id
							  FROM (
									SELECT MAX(m.etalon_registry_id) AS etalon_registry_id,
										   COUNT(1) AS c
									  FROM eor.tmp_eor_ident_candidate t
									  JOIN eor.idwh2_etalon_flrn m ON t.etalon_registry_id = m.etalon_registry_id
									  JOIN eor.idw_mr_master mm ON m.etalon_registry_id = mm.etalon_registry_id
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
							SELECT sub.etalon_registry_id INTO l_etalon_registry_id
							  FROM (
									SELECT MAX(m.etalon_registry_id) AS etalon_registry_id,
										   COUNT(1) AS c
									  FROM eor.tmp_eor_ident_candidate t
									  JOIN eor.idwh2_etalon_flrn m ON t.etalon_registry_id = m.etalon_registry_id
									  JOIN eor.idw_mr_master mm ON m.etalon_registry_id = mm.etalon_registry_id
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
							SELECT sub.etalon_registry_id INTO l_etalon_registry_id
							  FROM (
									SELECT MAX(m.etalon_registry_id) AS etalon_registry_id,
										   COUNT(1) AS c
									  FROM eor.tmp_eor_ident_candidate t
									  JOIN eor.idwh2_etalon_flrn m ON t.etalon_registry_id = m.etalon_registry_id
									  JOIN eor.idw_mr_master mm ON m.etalon_registry_id = mm.etalon_registry_id
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

			END IF;

            -- =====================================================================
            -- Поиск в ЕОР для ИФЛ
            -- =====================================================================
            IF l_is_rfl = 0 AND c.full_name IS NOT NULL THEN
                PERFORM eor.pr_eor_pdl_ident_find_nr_fl_candidate_func(c.full_name, c.date_birthday::date);

                IF EXISTS (SELECT 1 FROM eor.tmp_eor_ident_candidate) THEN -- Контроль наличия данных кандидатов
					-- ФИО + ДатаРождения, Эталонная запись
					IF l_etalon_registry_id IS NULL AND c.full_name IS NOT NULL AND c.date_birthday IS NOT NULL THEN
						BEGIN
							SELECT sub.etalon_registry_id INTO l_etalon_registry_id
							  FROM (
									SELECT MAX(m.etalon_registry_id) AS etalon_registry_id,
										   COUNT(1) AS c
									  FROM eor.tmp_eor_ident_candidate t
									  JOIN eor.idwh2_etalon_nr_fl m ON t.etalon_registry_id = m.etalon_registry_id
									  JOIN eor.idw_mr_master mm ON m.etalon_registry_id = mm.etalon_registry_id
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
							SELECT sub.etalon_registry_id INTO l_etalon_registry_id
							  FROM (
									SELECT MAX(m.etalon_registry_id) AS etalon_registry_id,
										   COUNT(1) AS c
									  FROM eor.tmp_eor_ident_candidate t
									  JOIN eor.idwh2_etalon_nr_fl m ON t.etalon_registry_id = m.etalon_registry_id
									  JOIN eor.idw_mr_master mm ON m.etalon_registry_id = mm.etalon_registry_id
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
							SELECT sub.etalon_registry_id INTO l_etalon_registry_id
							  FROM (
									SELECT MAX(m.etalon_registry_id) AS etalon_registry_id,
										   COUNT(1) AS c
									  FROM eor.tmp_eor_ident_candidate t
									  JOIN eor.idwh2_etalon_nr_fl m ON t.etalon_registry_id = m.etalon_registry_id
									  JOIN eor.idw_mr_master mm ON m.etalon_registry_id = mm.etalon_registry_id
									 WHERE m.full_name = TRIM(UPPER(c.full_name))  AND mm.etalon_sign = '1'
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
							SELECT sub.etalon_registry_id INTO l_etalon_registry_id
							  FROM (
									SELECT MAX(m.etalon_registry_id) AS etalon_registry_id,
										   COUNT(1) AS c
									  FROM eor.tmp_eor_ident_candidate t
									  JOIN eor.idwh2_etalon_nr_fl m ON t.etalon_registry_id = m.etalon_registry_id
									  JOIN eor.idw_mr_master mm ON m.etalon_registry_id = mm.etalon_registry_id
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
            END IF;

            -- =====================================================================
            -- ИДЕНТИФИЦИРОВАН
            -- =====================================================================
            IF l_etalon_registry_id IS NOT NULL AND l_sr_subject_id > 0 THEN
			
                l_sr_event_id := sr.sr_common_pkg__sr_event_add(
							101,
							c_sr_type_id,
							c.sr_subject_id,
							l_etalon_registry_id::bigint,
							NULL,
							'0',
							CURRENT_USER);

                PERFORM sr.sr_common_pkg__sr_subject_save_h(c.sr_subject_id);
                UPDATE sr.sr_subject s
                   SET etalon_registry_id = l_etalon_registry_id,
                       sr_event_id = l_sr_event_id
                 WHERE s.sr_subject_id = c.sr_subject_id
                   AND s.sr_type_id = c_sr_type_id;

            ELSIF l_etalon_registry_id IS NOT NULL AND l_sr_subject_id IS NULL THEN
                l_sr_event_id := sr.sr_common_pkg__sr_event_add(100, c_sr_type_id, c.sr_subject_id, l_etalon_registry_id::bigint, NULL, '0', CURRENT_USER);

                INSERT INTO sr.sr_subject (
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
                    c_sr_type_id,
                    '1',
                    '0',
                    l_sr_event_id
                );
            END IF;

            -- =====================================================================
            -- СОЗДАЕМ УПОМИНАНИЕ
            -- =====================================================================
            
            IF l_etalon_registry_id IS NULL THEN
                BEGIN
                    SELECT t.eor_subject_mention_id INTO l_eor_subject_mention_id
                      FROM eor.idw_mr_subject_mention t
                     WHERE source_id = c_source_id
                       AND external_h_id = c.rid::TEXT;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        NULL;
                END;

                IF l_is_rfl = 1 AND l_eor_subject_mention_id IS NULL THEN
                    l_rfl_attr.full_name := c.full_name;
                    l_rfl_attr.birth_date := c.date_birthday;
                    l_eor_subject_mention_id := pkg_eor_api.add_subj_rfl_mention(
                        c_source_id::integer,
                        0::integer,
                        c.system_id::text,
                        c.rid::TEXT,
                        c.update_date::date,
                        l_rfl_attr::eor.idw_mr_rfl_attr_src,
                        10::smallint,
                        0::smallint
                    );
				ELSIF l_is_rfl = 0 AND l_eor_subject_mention_id IS NULL THEN
                    l_ifl_attr.full_name := c.full_name;
                    l_ifl_attr.birth_date := c.date_birthday;
                    l_eor_subject_mention_id := pkg_eor_api.add_subj_ifl_mention(
                        c_source_id::integer,
                        0::integer,
                        c.system_id::text,
                        c.rid::TEXT,
                        c.update_date::date,
                        l_ifl_attr,
                        10::smallint,
                        0::smallint
                    );
                END IF;
				-- Логическая ошибка IF l_is_rfl = 1 AND l_eor_subject_mention_id IS NULL THEN по рекомендации Ефремова А. ставим 0
				/*
                IF l_is_rfl = 0 AND l_eor_subject_mention_id IS NULL THEN
                    l_ifl_attr.full_name := c.full_name;
                    l_ifl_attr.birth_date := c.date_birthday;
                    l_eor_subject_mention_id := pkg_eor_api.add_subj_ifl_mention(
                        c_source_id::integer,
                        0::integer,
                        c.system_id::text,
                        c.rid::TEXT,
                        c.update_date::date,
                        l_ifl_attr,
                        10::smallint,
                        0::smallint
                    );
				END IF;
				*/

                IF l_sr_subject_id IS NULL AND l_eor_subject_mention_id IS NOT NULL THEN
                    l_sr_event_id := sr.sr_common_pkg__sr_event_add(100, c_sr_type_id, c.sr_subject_id, l_etalon_registry_id, NULL, '0', CURRENT_USER);

                    INSERT INTO sr.sr_subject (
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
                        c_sr_type_id,
                        '1',
                        '0',
                        l_sr_event_id
                    );
                ELSIF l_eor_subject_mention_id IS NOT NULL THEN
                    PERFORM sr.sr_common_pkg__sr_subject_save_h(c.sr_subject_id);
                    l_sr_event_id := sr.sr_common_pkg__sr_event_add(
							p_sr_event_type_id=>101,
							p_sr_type_id=>c_sr_type_id, 
							p_sr_subject_id=>c.sr_subject_id,
							p_object_id=>l_etalon_registry_id,
							p_description=>NULL,
							p_manual_sign=>'0',
							p_sr_event_user_os=>CURRENT_USER);
							
                    UPDATE sr.sr_subject s
                       SET eor_subject_mention_id = l_eor_subject_mention_id,
                           sr_event_id = l_sr_event_id,
                           deleted_sign = '0',
                           actual_sign = '1',
                           checked_sign = '4',
                           excl_date = NULL,
                           excl_reason = NULL
                     WHERE s.sr_subject_id = c.sr_subject_id
                       AND s.sr_type_id = c_sr_type_id;
                END IF;
            END IF;

            -- Удаление очереди
			/*
			RAISE NOTICE ' Удалить очередь
			WHERE workflow_id = %
               AND state_id = %
               AND object_id = %
			',              p_process_data.workflow_id,
               p_process_data.state_id,
               c.rid;
			*/
            DELETE FROM process_info.idw_sy_workflow_info
             WHERE workflow_id = p_process_data.workflow_id
               AND state_id = p_process_data.state_id
               AND object_id = c.rid::text;

            l_cnt := l_cnt + 1;

            UPDATE sr.sr_subject_pdl p
               SET is_eor_ident_process = 1
             WHERE p.sr_subject_id = c.sr_subject_id;

            RAISE NOTICE '% Выполнено system_id = %  l_id = %', c_process, c.system_id, l_id;

        EXCEPTION
            WHEN OTHERS THEN
                call process_info.save_error(
                    l_id,
                    p_process_data.workflow_id,
                    p_process_data.state_id,
                    SQLSTATE,
                    SQLERRM,
                    'Backtrace not available in PostgreSQL'
                );
                --ROLLBACK TO SAVEPOINT pr_eor_pdl_ident;
                l_err_cnt := l_err_cnt + 1;
        END;
    END LOOP;

    --COMMIT;
    --p_end_date := clock_timestamp();

EXCEPTION
    WHEN OTHERS THEN
        --p_end_date := clock_timestamp();
        RAISE;
END;
$$;

ALTER PROCEDURE eor.pr_pdl_ident_batch(text[], process_info.process_state, bigint)
    OWNER TO r_fors_db_owner;



SELECT *  FROM plpgsql_check_function('eor.pr_pdl_ident_batch(text[], process_info.process_state, bigint)');

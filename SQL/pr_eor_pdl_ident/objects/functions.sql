-- DROP PROCEDURE eor.pr_pdl_ident_batch(_text, process_info.process_state, int8);

CREATE OR REPLACE PROCEDURE eor.pr_pdl_ident_batch(IN p_ids text[], IN p_process_data process_info.process_state, IN p_process_log_id bigint)
 LANGUAGE plpgsql
AS $procedure$
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
               p.sr_subject_id AS rid,
               p.update_date
          FROM sr.sr_subject_pdl p
		  join (select * from arch_ext.idw_arj_interfax_pdl_load_buffer where id = ANY(p_ids::bigint[])) bf on bf.sr_subject_id = p.sr_subject_id -- Ограничение батча
          LEFT JOIN eor.sr_subject s ON s.sr_subject_id = p.sr_subject_id
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
              FROM eor.sr_subject s
             WHERE s.sr_subject_id = c.sr_subject_id
               AND s.sr_type_id = c_sr_type_id;

            IF l_sr_subject_count > 0 THEN
                SELECT s.sr_subject_id INTO l_sr_subject_id
                  FROM eor.sr_subject s
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
                UPDATE eor.sr_subject s
                   SET etalon_registry_id = l_etalon_registry_id,
                       sr_event_id = l_sr_event_id
                 WHERE s.sr_subject_id = c.sr_subject_id
                   AND s.sr_type_id = c_sr_type_id;

            ELSIF l_etalon_registry_id IS NOT NULL AND l_sr_subject_id IS NULL THEN
                l_sr_event_id := sr.sr_common_pkg__sr_event_add(100, c_sr_type_id, c.sr_subject_id, l_etalon_registry_id::bigint, NULL, '0', CURRENT_USER);

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
							
                    UPDATE eor.sr_subject s
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

            -- Удаление ошибок
            DELETE FROM process_info.idw_sy_workflow_info
             WHERE workflow_id = p_process_data.workflow_id
               AND state_id = p_process_data.state_id
               AND object_id = l_id;

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
$procedure$
;


-- DROP FUNCTION sr.sr_common_pkg__sr_event_add(int4, int4, int8, int8, text, bpchar, text, int8);

CREATE OR REPLACE FUNCTION sr.sr_common_pkg__sr_event_add(p_sr_event_type_id integer, p_sr_type_id integer, p_sr_subject_id bigint, p_object_id bigint, p_description text, p_manual_sign character, p_sr_event_user_os text, p_sr_event_id bigint DEFAULT NULL::bigint)
 RETURNS integer
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
-- Добавление события (Возвращает SR_EVENT_ID)
declare
    l_TIME 			timestamp := now();
    l_SR_EVENT_ID	Int8;
begin
	l_SR_EVENT_ID := coalesce(P_SR_EVENT_ID, NEXTVAL('sr.sr_event_seq'));

	--call eor.print_debug_msg(format('l_SR_EVENT_ID=%s; P_SR_EVENT_TYPE_ID=%s; P_SR_SUBJECT_ID=%s; P_DESCRIPTION=%s; P_MANUAL_SIGN=%s; P_SR_TYPE_ID=%s; P_OBJECT_ID=%s; SR_EVENT_DATE=%s; P_SR_EVENT_USER_OS=%s', l_SR_EVENT_ID, P_SR_EVENT_TYPE_ID, P_SR_SUBJECT_ID, P_DESCRIPTION, P_MANUAL_SIGN, P_SR_TYPE_ID, P_OBJECT_ID, SR_EVENT_DATE ), 2::int)
	
    insert into sr.SR_EVENT (SR_EVENT_ID, SR_EVENT_TYPE_ID, SR_SUBJECT_ID, DESCRIPTION, MANUAL_SIGN, SR_TYPE_ID, OBJECT_ID, SR_EVENT_DATE, SR_EVENT_USER_OS)
    values (l_SR_EVENT_ID::int8, P_SR_EVENT_TYPE_ID, P_SR_SUBJECT_ID, P_DESCRIPTION, P_MANUAL_SIGN, P_SR_TYPE_ID, P_OBJECT_ID, l_TIME, P_SR_EVENT_USER_OS );

    return l_SR_EVENT_ID;
exception
    when others then 
       	declare
    		v_err_code text; -- SQLSTATE - код ошибки
    		v_msg_text text; -- SQLERRM - текст ошибки
    		v_context  text; -- стек вызовов
    		v_detail   text;
    		v_hint     text;
    	
    		l_err		text;
   		begin
     		GET STACKED DIAGNOSTICS
    	 		v_err_code = RETURNED_SQLSTATE,    -- SQLSTATE - код ошибки
		  		v_msg_text = MESSAGE_TEXT,         -- SQLERRM - текст ошибки
    	  		v_context  = PG_EXCEPTION_CONTEXT, -- стек вызовов
    	  		v_detail   = PG_EXCEPTION_DETAIL,
          		v_hint     = PG_EXCEPTION_HINT; 
       	
      	
		    	l_err := concat_ws( ', '
    	 			,'state: ' 	|| v_err_code
    	 			,'msg:'		|| v_msg_text
    	 			,'detail:' 	|| v_detail
					--,'hint:' 	|| v_hint
					--,'context:' || v_context
    	 		);    
    	 	raise exception '%', l_err;
        --return -1;
       end; 
end;
$function$
;





-- DROP FUNCTION sr.sr_common_pkg__sr_event_add(int4, int4, int8, int8, text, bpchar, text, int8);

CREATE OR REPLACE FUNCTION sr.sr_common_pkg__sr_event_add(p_sr_event_type_id integer, p_sr_type_id integer, p_sr_subject_id bigint, p_object_id bigint, p_description text, p_manual_sign character, p_sr_event_user_os text, p_sr_event_id bigint DEFAULT NULL::bigint)
 RETURNS integer
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
-- Добавление события (Возвращает SR_EVENT_ID)
declare
    l_TIME 			timestamp := now();
    l_SR_EVENT_ID	Int8;
begin
	l_SR_EVENT_ID := coalesce(P_SR_EVENT_ID, NEXTVAL('sr.sr_event_seq'));

	--call eor.print_debug_msg(format('l_SR_EVENT_ID=%s; P_SR_EVENT_TYPE_ID=%s; P_SR_SUBJECT_ID=%s; P_DESCRIPTION=%s; P_MANUAL_SIGN=%s; P_SR_TYPE_ID=%s; P_OBJECT_ID=%s; SR_EVENT_DATE=%s; P_SR_EVENT_USER_OS=%s', l_SR_EVENT_ID, P_SR_EVENT_TYPE_ID, P_SR_SUBJECT_ID, P_DESCRIPTION, P_MANUAL_SIGN, P_SR_TYPE_ID, P_OBJECT_ID, SR_EVENT_DATE ), 2::int)
	
    insert into sr.SR_EVENT (SR_EVENT_ID, SR_EVENT_TYPE_ID, SR_SUBJECT_ID, DESCRIPTION, MANUAL_SIGN, SR_TYPE_ID, OBJECT_ID, SR_EVENT_DATE, SR_EVENT_USER_OS)
    values (l_SR_EVENT_ID::int8, P_SR_EVENT_TYPE_ID, P_SR_SUBJECT_ID, P_DESCRIPTION, P_MANUAL_SIGN, P_SR_TYPE_ID, P_OBJECT_ID, l_TIME, P_SR_EVENT_USER_OS );

    return l_SR_EVENT_ID;
exception
    when others then 
       	declare
    		v_err_code text; -- SQLSTATE - код ошибки
    		v_msg_text text; -- SQLERRM - текст ошибки
    		v_context  text; -- стек вызовов
    		v_detail   text;
    		v_hint     text;
    	
    		l_err		text;
   		begin
     		GET STACKED DIAGNOSTICS
    	 		v_err_code = RETURNED_SQLSTATE,    -- SQLSTATE - код ошибки
		  		v_msg_text = MESSAGE_TEXT,         -- SQLERRM - текст ошибки
    	  		v_context  = PG_EXCEPTION_CONTEXT, -- стек вызовов
    	  		v_detail   = PG_EXCEPTION_DETAIL,
          		v_hint     = PG_EXCEPTION_HINT; 
       	
      	
		    	l_err := concat_ws( ', '
    	 			,'state: ' 	|| v_err_code
    	 			,'msg:'		|| v_msg_text
    	 			,'detail:' 	|| v_detail
					--,'hint:' 	|| v_hint
					--,'context:' || v_context
    	 		);    
    	 	raise exception '%', l_err;
        --return -1;
       end; 
end;
$function$
;


-- DROP FUNCTION pkg_eor_api.add_subj_rfl_mention(int4, int4, text, text, date, eor.idw_mr_rfl_attr_src, int2, int2);

CREATE OR REPLACE FUNCTION pkg_eor_api.add_subj_rfl_mention(p_source_id integer, p_source_etalon_id integer, p_external_id text, p_external_h_id text, p_actual_date date, p_attributes eor.idw_mr_rfl_attr_src, p_priority smallint DEFAULT (50)::smallint, p_in_queue smallint DEFAULT (1)::smallint)
 RETURNS bigint
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
#package
declare
  l_mention_id bigint;
begin
 
  l_mention_id := pkg_eor_aux.add_subj_rfl_mention(p_source_id, p_source_etalon_id, p_external_id, p_external_h_id, p_actual_date, p_attributes);
 
  if p_in_queue = 1 and l_mention_id is not null then
      insert into process_info.idw_sy_workflow_info (object_id, workflow_id, state_id, priority, create_date, state_date)
      values (l_mention_id::text, 93, 931, p_priority, clock_timestamp(), clock_timestamp());
  end if; 	 
	    
  return l_mention_id;
end;
$function$
;



-- DROP FUNCTION pkg_eor_aux.add_subj_rfl_mention(int4, int4, text, text, date, eor.idw_mr_rfl_attr_src);

CREATE OR REPLACE FUNCTION pkg_eor_aux.add_subj_rfl_mention(p_source_id integer, p_source_etalon_id integer, p_external_id text, p_external_h_id text, p_actual_date date, p_attributes eor.idw_mr_rfl_attr_src)
 RETURNS bigint
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
#package
declare
  l_mention_id bigint;
  l_md5 text;
begin
 
  call pkg_eor_aux.add_rfl_attr_src(p_attributes, l_md5);
 
  if p_attributes.mention_attribute_id is not null then
	   l_mention_id := nextval('eor.idw_mr_subject_mention_seq');
	  
	   -- Вставляем запись об упоминании
	   INSERT INTO eor.idw_mr_subject_mention(
	    eor_subject_mention_id,
	    create_date,
	    mention_attribute_id,
	    source_id,
	    source_etalon_id,
	    external_id,
	    external_h_id,
	    actual_date,
	    --mention_md5,
	    MENTION_ATTRIBUTE_MD5,
	    eor_mention_type_id,
		filial_sign
	   ) VALUES (
	    l_mention_id,
	    clock_timestamp(),
	    p_attributes.mention_attribute_id,
	    p_source_id,
	    p_source_etalon_id,
	    p_external_id,
	    p_external_h_id,
	    p_actual_date,
	    l_md5,
	    3, -- РФЛ
		'0'
	   );

  end if; 	 
	    
  return l_mention_id;
end;
$function$
;


-- DROP PROCEDURE pkg_eor_aux.add_rfl_attr_src(inout eor.idw_mr_rfl_attr_src, out text);

CREATE OR REPLACE PROCEDURE pkg_eor_aux.add_rfl_attr_src(INOUT p_attributes eor.idw_mr_rfl_attr_src, OUT p_md5 text)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $procedure$
#package
DECLARE
  l_new BOOLEAN;
begin autonomous
	
  p_md5 := pkg_eor_aux.get_rfl_attr_md5(p_attributes);

  SELECT p_ret, p_new 
	  INTO p_attributes.mention_attribute_id, l_new 
  FROM pkg_eor_aux.get_mention_attr_id(p_md5);
  
  IF l_new THEN
    INSERT INTO eor.idw_mr_rfl_attr_src
    VALUES (p_attributes.*)
    ON CONFLICT DO NOTHING;
  END IF;
END;
$procedure$
;


-- DROP FUNCTION pkg_eor_api.add_subj_ifl_mention(int4, int4, text, text, date, eor.idw_mr_ifl_attr_src, int2, int2);

CREATE OR REPLACE FUNCTION pkg_eor_api.add_subj_ifl_mention(p_source_id integer, p_source_etalon_id integer, p_external_id text, p_external_h_id text, p_actual_date date, p_attributes eor.idw_mr_ifl_attr_src, p_priority smallint DEFAULT (50)::smallint, p_in_queue smallint DEFAULT (1)::smallint)
 RETURNS bigint
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
#package
declare
  l_mention_id bigint;
begin
 
  l_mention_id := pkg_eor_aux.add_subj_ifl_mention(p_source_id, p_source_etalon_id, p_external_id, p_external_h_id, p_actual_date, p_attributes);
 
  if p_in_queue = 1 and l_mention_id is not null then
      insert into process_info.idw_sy_workflow_info (object_id, workflow_id, state_id, priority, create_date, state_date)
      values (l_mention_id::text, 96, 961, p_priority, clock_timestamp(), clock_timestamp());
  end if; 	 
	    
  return l_mention_id;
end;
$function$
;


-- DROP FUNCTION pkg_eor_aux.add_subj_ifl_mention(int4, int4, text, text, date, eor.idw_mr_ifl_attr_src);

CREATE OR REPLACE FUNCTION pkg_eor_aux.add_subj_ifl_mention(p_source_id integer, p_source_etalon_id integer, p_external_id text, p_external_h_id text, p_actual_date date, p_attributes eor.idw_mr_ifl_attr_src)
 RETURNS bigint
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
#package
declare
  l_mention_id bigint;
  l_md5 text;
begin
 
  call pkg_eor_aux.add_ifl_attr_src(p_attributes, l_md5);
 
  if p_attributes.mention_attribute_id is not null then
	  l_mention_id := nextval('eor.idw_mr_subject_mention_seq');
	  
	  -- Вставляем запись об упоминании
	  INSERT INTO eor.idw_mr_subject_mention(
	    eor_subject_mention_id,
	    create_date,
	    mention_attribute_id,
	    source_id,
	    source_etalon_id,
	    external_id,
	    external_h_id,
	    actual_date,
	    --mention_md5,
	    MENTION_ATTRIBUTE_MD5,
	    eor_mention_type_id
	  ) VALUES (
	    l_mention_id,
	    clock_timestamp(),
	    p_attributes.mention_attribute_id,
	    p_source_id,
	    p_source_etalon_id,
	    p_external_id,
	    p_external_h_id,
	    p_actual_date,
	    l_md5,
	    7 -- ИФЛ
	  );

  end if; 	 
	    
  return l_mention_id;
end;
$function$
;
-- DROP PROCEDURE pkg_eor_aux.add_ifl_attr_src(inout eor.idw_mr_ifl_attr_src, out text);

CREATE OR REPLACE PROCEDURE pkg_eor_aux.add_ifl_attr_src(INOUT p_attributes eor.idw_mr_ifl_attr_src, OUT p_md5 text)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $procedure$
#package
DECLARE
  l_new BOOLEAN;
begin autonomous
	
  p_md5 := pkg_eor_aux.get_ifl_attr_md5(p_attributes);

  SELECT p_ret, p_new 
	  INTO p_attributes.mention_attribute_id, l_new 
  FROM pkg_eor_aux.get_mention_attr_id(p_md5);
  
  IF l_new THEN
    INSERT INTO eor.idw_mr_ifl_attr_src
    VALUES (p_attributes.*)
    ON CONFLICT DO NOTHING;
  END IF;

exception
when others
then
	raise;
END;
$procedure$
;

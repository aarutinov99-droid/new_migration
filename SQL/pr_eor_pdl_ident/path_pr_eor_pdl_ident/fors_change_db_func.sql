-- =============================================================================
-- ЕДИНЫЙ СКРИПТ ИЗМЕНЕНИЙ К БД
-- =============================================================================
-- Описание: Скрипт обновления БД для регламентных процессов EOR PDL LOAD и
--           EOR PDL IDENT. Включает:
--           - регистрацию workflow и состояний процесса;
--           - настройки процесса в process_state;
--           - создание временной таблицы кандидатов;
--           - функции поиска кандидатов РФЛ/НР ФЛ;
--           - процедуру обработки пакета pr_pdl_ident_batch;
--           - процедуру запуска pr_eor_pdl_ident;
--           - диагностику взаимосвязей объектов.
-- =============================================================================

-- =============================================================================
-- 1. РЕГИСТРАЦИЯ WORKFLOW И СОСТОЯНИЙ ПРОЦЕССА
-- =============================================================================

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

-- =============================================================================
-- 2. НАСТРОЙКИ ПРОЦЕССОВ
-- =============================================================================

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

-- =============================================================================
-- 3. ТАБЛИЦА eor.tmp_eor_ident_candidate
-- =============================================================================


CREATE TABLE IF NOT EXISTS eor.tmp_eor_ident_candidate
(
    find_candidate_id numeric NOT NULL,
    etalon_registry_id numeric NOT NULL,
    eor_h_id numeric,
    weight numeric,
    CONSTRAINT tmp_eor_ident_candidate_pk PRIMARY KEY (etalon_registry_id, find_candidate_id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS eor.tmp_eor_ident_candidate
    OWNER to "arutinov.a";

COMMENT ON TABLE eor.tmp_eor_ident_candidate
    IS 'Временная таблица для хранения кандидатов при идентификации EOR для регламентного процесса EOR_PDL_IDENT';

COMMENT ON COLUMN eor.tmp_eor_ident_candidate.find_candidate_id
    IS 'Идентификатор найденного кандидата';

COMMENT ON COLUMN eor.tmp_eor_ident_candidate.etalon_registry_id
    IS 'Идентификатор эталонного реестра';

COMMENT ON COLUMN eor.tmp_eor_ident_candidate.eor_h_id
    IS 'Идентификатор EOR ';

COMMENT ON COLUMN eor.tmp_eor_ident_candidate.weight
    IS 'Вес или степень соответствия кандидата (коэффициент)';
COMMENT ON CONSTRAINT tmp_eor_ident_candidate_pk ON eor.tmp_eor_ident_candidate
    IS 'Уникальный ключ';
	
-- =============================================================================
-- 4. ФУНКЦИЯ eor.pr_eor_pdl_ident_find_rfl_candidate_func
-- =============================================================================

CREATE OR REPLACE FUNCTION eor.pr_eor_pdl_ident_find_rfl_candidate_func(
    p_full_name        TEXT,
    p_birth_date       DATE
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    l_max_cnt   CONSTANT INTEGER := 1000;
    l_find_id   INTEGER;
BEGIN
    l_find_id := nextval('eor.seq_find_candidate');

    -- Очистка временной таблицы
    DELETE FROM eor.tmp_eor_ident_candidate;

    -- По ФИО и дате рождения (точное совпадение)
    WITH res AS (
    SELECT m.etalon_registry_id,
           m.eor_h_id,
           count(1) OVER (PARTITION BY 1) AS cnt,
           1.0 / (1 + log(10, count(1) OVER (PARTITION BY 1))) AS w
      FROM eor.idw_mr_master m
      JOIN eor.idwh2_etalon_flrn f
        ON f.etalon_registry_id = m.etalon_registry_id
     WHERE f.birth_date = p_birth_date
       AND f.full_name = p_full_name
       AND m.deleted_sign = '0'
	)
	INSERT INTO eor.tmp_eor_ident_candidate AS ic (find_candidate_id,
											   etalon_registry_id,
											   eor_h_id,
											   weight)
	SELECT l_find_id,
		   res.etalon_registry_id,
		   res.eor_h_id,
		   res.w
	  FROM res
	 WHERE res.cnt <= l_max_cnt
	ON CONFLICT (etalon_registry_id, find_candidate_id)
	DO UPDATE
	   SET weight = ic.weight + EXCLUDED.weight
	 WHERE EXISTS (SELECT 1 FROM res WHERE res.cnt <= l_max_cnt);
	 
    -- По ФИО (точное совпадение)
	WITH res AS (
		SELECT m.etalon_registry_id,
			   m.eor_h_id,
			   count(1) OVER (PARTITION BY 1) AS cnt,
			   1.0 / (1 + log(10, count(1) OVER (PARTITION BY 1))) AS w
		  FROM eor.idw_mr_master m
		  JOIN eor.idwh2_etalon_flrn f
			ON f.etalon_registry_id = m.etalon_registry_id
		 WHERE f.full_name = p_full_name
		   AND m.deleted_sign = '0'
	)
	INSERT INTO eor.tmp_eor_ident_candidate AS ic (find_candidate_id,
											   etalon_registry_id,
											   eor_h_id,
											   weight)
	SELECT l_find_id,
		   res.etalon_registry_id,
		   res.eor_h_id,
		   res.w
	  FROM res
	 WHERE res.cnt <= l_max_cnt
	ON CONFLICT (etalon_registry_id, find_candidate_id)
	DO UPDATE
	   SET weight = ic.weight + EXCLUDED.weight
	 WHERE EXISTS (SELECT 1 FROM res WHERE res.cnt <= l_max_cnt);

	RETURN l_find_id;

EXCEPTION
    WHEN OTHERS THEN
        RAISE;
END;
$$;

ALTER FUNCTION eor.pr_eor_pdl_ident_find_rfl_candidate_func(TEXT,DATE) OWNER TO r_fors_db_owner;
GRANT ALL ON FUNCTION eor.pr_eor_pdl_ident_find_rfl_candidate_func(TEXT,DATE) TO r_fors_db_owner;

-- =============================================================================
-- 5. ФУНКЦИЯ eor.pr_eor_pdl_ident_find_nr_fl_candidate_func
-- =============================================================================

CREATE OR REPLACE FUNCTION eor.pr_eor_pdl_ident_find_nr_fl_candidate_func(
    p_full_name        TEXT,
    p_birth_date       DATE
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    l_max_cnt   CONSTANT INTEGER := 1000;
    l_find_id   INTEGER;
BEGIN
    l_find_id := nextval('eor.seq_find_candidate');

    -- Очистка временной таблицы
    DELETE FROM eor.tmp_eor_ident_candidate;

    -- По ФИО и дате рождения (точное совпадение)
	WITH res AS (
		SELECT m.etalon_registry_id,
			   m.eor_h_id,
			   count(1) OVER (PARTITION BY 1) AS cnt,
			   1.0 / (1 + log(10, count(1) OVER (PARTITION BY 1))) AS w
		  FROM eor.idw_mr_master m
		  JOIN eor.idwh2_etalon_nr_fl f
			ON f.etalon_registry_id = m.etalon_registry_id
		 WHERE f.birth_date = p_birth_date
		   AND f.full_name = p_full_name
		   AND m.deleted_sign = '0'
	)
	INSERT INTO  eor.tmp_eor_ident_candidate AS ic (find_candidate_id,
											   etalon_registry_id,
											   eor_h_id,
											   weight)
	SELECT l_find_id,
		   res.etalon_registry_id,
		   res.eor_h_id,
		   res.w
	  FROM res
	 WHERE res.cnt <= l_max_cnt
	ON CONFLICT (etalon_registry_id, find_candidate_id)
	DO UPDATE
	   SET weight = ic.weight + EXCLUDED.weight
	 WHERE EXISTS (SELECT 1 FROM res WHERE res.cnt <= l_max_cnt);	
	----------------------------------------------------------------
    -- По ФИО (точное совпадение)
	WITH res AS (
		SELECT m.etalon_registry_id,
			   m.eor_h_id,
			   count(1) OVER (PARTITION BY 1) AS cnt,
			   1.0 / (1 + log(10, count(1) OVER (PARTITION BY 1))) AS w
		  FROM eor.idw_mr_master m
		  JOIN eor.idwh2_etalon_nr_fl f
			ON f.etalon_registry_id = m.etalon_registry_id
		 WHERE f.full_name = p_full_name
		   AND m.deleted_sign = '0'
	)
	INSERT INTO  eor.tmp_eor_ident_candidate AS ic (find_candidate_id,
											   etalon_registry_id,
											   eor_h_id,
											   weight)
	SELECT l_find_id,
		   res.etalon_registry_id,
		   res.eor_h_id,
		   res.w
	  FROM res
	 WHERE res.cnt <= l_max_cnt
	ON CONFLICT (etalon_registry_id, find_candidate_id)
	DO UPDATE
	   SET weight = ic.weight + EXCLUDED.weight
	 WHERE EXISTS (SELECT 1 FROM res WHERE res.cnt <= l_max_cnt);
	-----------------------------------------------------------------------------------------
	RETURN l_find_id;

EXCEPTION
    WHEN OTHERS THEN
        RAISE;
END;
$$;
ALTER FUNCTION eor.pr_eor_pdl_ident_find_nr_fl_candidate_func(TEXT,DATE) OWNER TO r_fors_db_owner;
GRANT ALL ON FUNCTION eor.pr_eor_pdl_ident_find_nr_fl_candidate_func(TEXT,DATE) TO r_fors_db_owner;

-- =============================================================================
-- 6. ПРОЦЕДУРА eor.pr_pdl_ident_batch
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
				--RAISE NOTICE '1';
                l_sr_event_id := sr.sr_common_pkg__sr_event_add(
							101,
							c_sr_type_id,
							c.sr_subject_id,
							l_etalon_registry_id::bigint,
							NULL,
							'0',
							CURRENT_USER);
				--RAISE NOTICE '2';
                PERFORM sr.sr_common_pkg__sr_subject_save_h(c.sr_subject_id);
                UPDATE sr.sr_subject s
                   SET etalon_registry_id = l_etalon_registry_id,
                       sr_event_id = l_sr_event_id
                 WHERE s.sr_subject_id = c.sr_subject_id
                   AND s.sr_type_id = c_sr_type_id;

            ELSIF l_etalon_registry_id IS NOT NULL AND l_sr_subject_id IS NULL THEN
				--RAISE NOTICE '3';
                l_sr_event_id := sr.sr_common_pkg__sr_event_add(100, c_sr_type_id, c.sr_subject_id, l_etalon_registry_id::bigint, NULL, '0', CURRENT_USER);
				--RAISE NOTICE '4';
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
            --RAISE NOTICE 'СОЗДАЕМ УПОМИНАНИЕ';
            IF l_etalon_registry_id IS NULL THEN
                BEGIN
				  	--RAISE NOTICE '10';
                    SELECT t.eor_subject_mention_id INTO l_eor_subject_mention_id
                      FROM eor.idw_mr_subject_mention t
                     WHERE source_id = c_source_id
                       AND external_h_id = c.rid::TEXT;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        NULL;
                END;
				--RAISE NOTICE '11';
                IF l_is_rfl = 1 AND l_eor_subject_mention_id IS NULL THEN
					--RAISE NOTICE '11.1';
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
					--RAISE NOTICE '11.2';
				ELSIF l_is_rfl = 0 AND l_eor_subject_mention_id IS NULL THEN
					--RAISE NOTICE '12';
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
				--raise notice 'l_sr_subject_id IS % AND l_eor_subject_mention_id IS NOT %',l_sr_subject_id , l_eor_subject_mention_id;
                IF l_sr_subject_id IS NULL AND l_eor_subject_mention_id IS NOT NULL THEN
					--RAISE NOTICE '13';
                    l_sr_event_id := sr.sr_common_pkg__sr_event_add(100, c_sr_type_id, c.sr_subject_id, l_etalon_registry_id, NULL, '0', CURRENT_USER);
					--RAISE NOTICE '13.1 ';
                    
					--raise notice 'Вставка в спецреестр %' ,l_sr_event_id;
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
					--RAISE NOTICE '14  %- %' ,c.sr_subject_id,l_sr_event_id;
                    
                    PERFORM sr.sr_common_pkg__sr_subject_save_h(c.sr_subject_id);
					--RAISE NOTICE '14.1';
                    l_sr_event_id := sr.sr_common_pkg__sr_event_add(
							p_sr_event_type_id=>101,
							p_sr_type_id=>c_sr_type_id, 
							p_sr_subject_id=>c.sr_subject_id,
							p_object_id=>l_etalon_registry_id,
							p_description=>NULL,
							p_manual_sign=>'0',
							p_sr_event_user_os=>CURRENT_USER);
					--RAISE NOTICE '14.1';
                    	
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
				RAISE NOTICE 'ERROR %',SQLERRM;
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

    --RAISE NOTICE '-------------------------';

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
GRANT ALL ON PROCEDURE eor.pr_pdl_ident_batch(text[], process_info.process_state, bigint) TO r_fors_db_owner;

-- =============================================================================
-- 7. ПРОЦЕДУРА eor.pr_eor_pdl_ident
-- =============================================================================

CREATE OR REPLACE PROCEDURE eor.pr_eor_pdl_ident(
	IN p_process_log_id bigint,
	IN p_cnt_flow smallint DEFAULT NULL::smallint,
	IN p_num_flow smallint DEFAULT NULL::smallint)
LANGUAGE 'plpgsql'
    SECURITY DEFINER 
AS $BODY$

 
declare
	-- Регламентеый процесс "ЕОР: загрузка контрактов из архивного в буферный слой" в PG" (аналог ORION_38)
	-- 44.EXD.2026.
	-- использовать параметры p_cnt_flow, p_null_flow по default!!!
 
	
	l_process process_info.process_state.process_alias%type := 'PR_EOR_PDL_IDENT';
	l_procedure text := 'eor.pr_eor_pdl_ident';

  	l_process_data process_info.process_state%rowtype;
	l_batch_size int;

	l_error_sign bool := 0::bool;
	l_array_id text[];
 
	l_all_cnt int := 0::int;
  	l_cnt int := 0;
 	l_err_cnt int := 0;

  	l_proc_id int8;

	l_cnt_flow int2;
	l_num_flow int2;

	l_begin_date timestamp;

begin
	
	case
	when p_process_log_id is null
	then
	-- старт регламентного процесса

		select process_manage.start_process(
			 p_p_process_type => l_process
			,p_p_id_main_process => null
			,p_p_process_plan_id => null
			,p_p_msg => null
			,p_p_comments => null
	  	) 
	    into l_proc_id;

    else l_proc_id := p_process_log_id;
	end case;
raise notice 'l_proc_id:%',l_proc_id::text;
    call process_info.pr_helper_log(l_procedure,'Начало процесса: ' || l_process, l_proc_id::text);

	-- читаем настройки процесса
    select *
    into strict l_process_data
    from process_info.process_state
    where process_alias = l_process;

    l_batch_size := coalesce(l_process_data.batch_size, 200);

	case
	when not l_process_data.can_run in ('1', '2') 
	then
    
		call process_info.pr_helper_log(l_procedure, 'Процесс оостановлен пользователем, выход', l_proc_id::text);
		call process_manage.write_message(l_proc_id, 'Процесс оостановлен пользователем!');

		case
		when p_process_log_id is null 
		then call process_manage.finish_process(l_proc_id,  null);
		else null;
		end case;

       	return;

	else null;
    end case;

	l_error_sign := 
		case 
		when l_process_data.can_run = '1'::bpchar(1) 
		then false 
		else true 
		end;

    case
	when l_error_sign 
	then 
		
		call process_info.pr_helper_log(l_procedure , 'Начало, режим обработки ошибок', l_proc_id::text);
		call process_manage.write_message(l_proc_id, 'Режим обработки ошибок.');

    else 
		
		call process_info.pr_helper_log(l_procedure, 'Начало, нормальный режим', l_proc_id::text);
		call process_manage.write_message(l_proc_id, 'Нормальный режим обработки.');

    end case;

	-- проверяем, не много ли накопилось ошибок
    select count(8) 
    into strict l_err_cnt 
    from process_info.idw_sy_workflow_error
    where 
			workflow_id = l_process_data.workflow_id
   		and state_id = l_process_data.state_id;
     
	case
	when 
			l_err_cnt >= coalesce(l_process_data.max_error, 1000)::int
		and not l_error_sign 
	then 
    	
        call process_info.pr_helper_log(l_procedure, 'Превышен лимит ошибок (' || coalesce(l_process_data.max_error, 1000) || ') в регламентном процессе! Выход.', l_proc_id::text); 
        
		call process_manage.write_error(
			 l_proc_id --Yefremov p_process_log_id 	-- ИД процесса
			,'Накопилось много ошибок!!! Запустите процесс "' || l_process || '" в режиме обработки ошибок!'
			,'Накопилось много ошибок (' || l_err_cnt || ')!!! В таблице fors_pg.process_info.process_state для процесса "' || l_process || '" максимальное кол-во ошибок ' || l_process_data.max_error || '!'
			,'Ошибки данных'
		);
			   
        case
		when p_process_log_id is null
		then call process_manage.finish_process(l_proc_id, null);
		else null;
		end case;
	
       	return;

	else null;
    end case;

	l_cnt_flow := coalesce(p_cnt_flow,1::int2);
	l_num_flow := coalesce(p_num_flow,1::int2);

	-- проверка максимального количества потоков
	case
	when 
			l_cnt_flow < 1
		or  l_cnt_flow > 100
		or  l_num_flow < 1
		or  l_num_flow > l_cnt_flow
	then
		
		call process_info.pr_helper_log(l_procedure, 'Неверное значение количества потоков\текущий поток [' || l_cnt_flow::text || '''' || l_num_flow || ']! Выход.', l_proc_id::text); 
        
		call process_manage.write_error(
			 l_proc_id --Yefremov p_process_log_id 	-- ИД процесса
			,'Неверное значение количества потоков\текущий поток [' || l_cnt_flow::text || '\\' || l_num_flow || ']!'
			,null
			,'Ошибки'
		);
			   
        case
		when p_process_log_id is null
		then call process_manage.finish_process(l_proc_id, null);
		else null;
		end case;
	
       	return;

	else null;
	end case;

	l_begin_date := clock_timestamp();

	<<main_loop>>
	loop
		<<repeat_block>>	
		begin 
		-- если возникнет ошибка внутри блока, то изменения внутри блока не сохранятся

			-- читаем настройки процесса
		    select *
		    into strict l_process_data
		    from process_info.process_state
		    where process_alias = l_process;
		
		    l_batch_size := coalesce(l_process_data.batch_size, 200);
		
			case
			when not l_process_data.can_run in ('1', '2') 
			then
		    
				call process_info.pr_helper_log(l_procedure, 'Процесс оостановлен пользователем, выход', l_proc_id::text);
				call process_manage.write_message(l_proc_id, 'Процесс оостановлен пользователем!');
		
		       	exit main_loop;
		
			else null;
		    end case;

			l_error_sign := 
				case 
				when l_process_data.can_run = '1'::bpchar(1) 
				then false 
				else true 
				end;
		
		    case
			when l_error_sign 
			then 
				
				call process_info.pr_helper_log(l_procedure , 'Начало, режим обработки ошибок', l_proc_id::text);
				call process_manage.write_message(l_proc_id, 'Режим обработки ошибок.');
		
		    else 
				
				call process_info.pr_helper_log(l_procedure, 'Начало, нормальный режим', l_proc_id::text);
				call process_manage.write_message(l_proc_id, 'Нормальный режим обработки.');
		
		    end case;

			-- проверяем, не много ли накопилось ошибок
		    select count(8) 
		    into strict l_err_cnt 
		    from process_info.idw_sy_workflow_error
		    where 
					workflow_id = l_process_data.workflow_id
		   		and state_id = l_process_data.state_id;
		     
			case
			when 
					l_err_cnt >= coalesce(l_process_data.max_error, 1000)::int
				and not l_error_sign 
			then 
		    	
		        call process_info.pr_helper_log(l_procedure, 'Превышен лимит ошибок (' || coalesce(l_process_data.max_error, 1000) || ') в регламентном процессе! Выход.', l_proc_id::text); 
		        
				call process_manage.write_error(
					 l_proc_id --Yefremov p_process_log_id 	-- ИД процесса
					,'Накопилось много ошибок!!! Запустите процесс "' || l_process || '" в режиме обработки ошибок!'
					,'Накопилось много ошибок (' || l_err_cnt || ')!!! В таблице fors_pg.process_info.process_state для процесса "' || l_process || '" максимальное кол-во ошибок ' || l_process_data.max_error || '!'
					,'Ошибки данных.'
				);
			
		       	exit main_loop;
		
			else null;
		    end case;
	
			l_array_id := null;
		      
	        case
			when not l_error_sign 
			then
			-- Нормальный режим

				select 
					 array_agg(object_id)
					,count(8)
				into 
					 l_array_id
					,l_cnt
				from (
					select wi.object_id
					from process_info.idw_sy_workflow_info wi
					inner join arch_ext.idw_arj_interfax_pdl_load_buffer a on 
						wi.object_id = a.id::text
					where 
							wi.workflow_id = l_process_data.workflow_id
						and wi.state_id = l_process_data.state_id
--						and l_num_flow = ((TODO:!?a.inn::int8 % l_cnt_flow) + 1) 
						and not exists(
							select 'x'
							from process_info.idw_sy_workflow_error we
							where
									we.workflow_id = wi.workflow_id
								and we.state_id = wi.state_id
								and we.object_id = wi.object_id
						)
					order by 
						 wi.priority desc
						,wi.state_date 
					limit l_batch_size
				);
	
			else
			-- Режим обработки ошибок

				select 
					 array_agg(object_id)
					,count(8)
				into 
					 l_array_id
					,l_cnt
				from (
					select wi.object_id
					from process_info.idw_sy_workflow_info wi
					inner join arch_ext.idw_arj_interfax_pdl_load_buffer a on 
						wi.object_id = a.id::text
					where 
							wi.workflow_id = l_process_data.workflow_id
						and wi.state_id = l_process_data.state_id
--						and l_num_flow = ((TODO:!?a.inn::int8 % l_cnt_flow) + 1)
						and exists(
							select 'x'
							from process_info.idw_sy_workflow_error we
							where
									we.workflow_id = wi.workflow_id
								and we.state_id = wi.state_id
								and we.object_id = wi.object_id
								and coalesce(we.attempt_count,0) < l_process_data.max_attempt
								and we.attempt_date < l_begin_date
						)
					order by 
						 wi.priority desc
						,wi.state_date 
					limit l_batch_size
				);	
	
			end case;
	       
	        l_all_cnt := l_all_cnt + l_cnt;
			raise notice ' %   %' ,l_cnt,l_array_id;
	 	    case
			when l_cnt = 0 
			then
	
				call process_info.pr_helper_log(l_procedure ,'Нет данных для обработки!', l_proc_id::text);
	   	      	exit main_loop;
	
	   	    else call process_info.pr_helper_log(l_procedure,'Обработка пачки! Кол-во записей: ' || l_cnt, l_proc_id::text);
	   	    end case;
		   	  
			<<exec_block>>
			begin

				begin
					call eor.pr_pdl_ident_batch(
						 p_ids => l_array_id
						,p_process_data => l_process_data
						,p_process_log_id => l_proc_id					
					
					);
					--exit main_loop;
					
				exception
				when others
				then 

					declare
				    	v_err_code text; -- SQLSTATE - код ошибки
				    	v_msg_text text; -- SQLERRM - текст ошибки
				    	v_context text; -- стек вызовов
				    	v_detail text;
				    	v_hint text;
				   	begin
				
						get stacked diagnostics
							 v_err_code = RETURNED_SQLSTATE -- SQLSTATE - код ошибки
						  	,v_msg_text = MESSAGE_TEXT -- SQLERRM - текст ошибки
				    	  	,v_context  = PG_EXCEPTION_CONTEXT -- стек вызовов
				    	  	,v_detail   = PG_EXCEPTION_DETAIL
				          	,v_hint     = PG_EXCEPTION_HINT;
				 
				     	call process_info.pr_helper_log(l_procedure, process_info.get_err_text(v_err_code, v_msg_text, v_detail, v_hint, v_context), l_proc_id::text);
				
					   	call process_manage.write_error(
							 l_proc_id 	-- ИД процесса
							,'Ошибка обработки' 	
							,process_info.get_err_text(v_err_code, v_msg_text, v_detail, v_hint, v_context)
							,'Ошибки'
						);
					
						exit main_loop; -- !!!

					end;

				end;
					   
				-- удаление из ошибок если в режиме оброаботки ошибок
--		   	   	case
--				when l_error_sign 
--				then
--		   	    	
--					delete from process_info.idw_sy_workflow_error e
--		   	      	where 
--							e.workflow_id = l_process_data.workflow_id
--		   	        	and e.state_id  = l_process_data.state_id
--		   	        	and e.object_id = any(l_array_id::text[]);
--	
--				else null;
--		   	   	end case;  
		    
			end exec_block;
	
		end repeat_block;
	
	end loop main_loop;  

	call process_info.pr_helper_log(l_procedure ,'Нет данных для обработки, выход', l_proc_id::text);

	call process_manage.write_message(l_proc_id, 'Всего обработано (' || l_all_cnt || ')');
  
	case
	when p_process_log_id is null
	then call process_manage.finish_process(l_proc_id,  null);
	else null;
	end case;

exception
when others 
then
	
	declare
    	v_err_code text; -- SQLSTATE - код ошибки
    	v_msg_text text; -- SQLERRM - текст ошибки
    	v_context text; -- стек вызовов
    	v_detail text;
    	v_hint text;
   	begin

		get stacked diagnostics
			 v_err_code = RETURNED_SQLSTATE -- SQLSTATE - код ошибки
		  	,v_msg_text = MESSAGE_TEXT -- SQLERRM - текст ошибки
    	  	,v_context  = PG_EXCEPTION_CONTEXT -- стек вызовов
    	  	,v_detail   = PG_EXCEPTION_DETAIL
          	,v_hint     = PG_EXCEPTION_HINT;
 
     	call process_info.pr_helper_log(l_procedure, process_info.get_err_text(v_err_code, v_msg_text, v_detail, v_hint, v_context), l_proc_id::text);

	   	call process_manage.write_error(
			 l_proc_id 	-- ИД процесса
			,'Ошибка обработки' 	
			,process_info.get_err_text(v_err_code, v_msg_text, v_detail, v_hint, v_context)
			,'Ошибки'
		);
			   
		case
		when p_process_log_id is null
		then call process_manage.finish_process(l_proc_id, null);
		else null;
		end case;

   end;

end;
$BODY$;
ALTER PROCEDURE eor.pr_eor_pdl_ident(bigint, smallint, smallint)
    OWNER TO r_fors_db_owner;

GRANT EXECUTE ON PROCEDURE eor.pr_eor_pdl_ident(bigint, smallint, smallint) TO PUBLIC;

GRANT EXECUTE ON PROCEDURE eor.pr_eor_pdl_ident(bigint, smallint, smallint) TO r_fors_db_owner;

-- =============================================================================
-- 8. ДИАГНОСТИКА ВЗАИМОСВЯЗЕЙ
-- =============================================================================

-- =============================================================================
-- 8.1. Проверка вставленных записей workflow и состояний
-- =============================================================================

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

-- =============================================================================
-- 8.2. Проверка существования всех используемых таблиц
-- =============================================================================

DO $$
DECLARE
    v_table_name text;
    v_missing_count integer := 0;
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'ПРОВЕРКА СУЩЕСТВОВАНИЯ ТАБЛИЦ';
    RAISE NOTICE '========================================';

    FOR v_table_name IN (
        SELECT unnest(ARRAY[
            -- Спецреестр
            'sr.sr_subject_pdl',
            'sr.sr_subject',
            -- Очередь обработки
            'process_info.idw_sy_workflow_info',
            'process_info.idw_sy_workflow_error',
            'process_info.idw_sr_workflow_state',
            -- Буфер загрузки
            'arch_ext.idw_arj_interfax_pdl_load_buffer',
            -- Эталонные реестры
            'eor.idw_mr_master',
            'eor.idwh2_etalon_flrn',
            'eor.idwh2_etalon_nr_fl',
            -- Упоминания
            'eor.idw_mr_subject_mention',
            -- Временная таблица кандидатов
            'eor.tmp_eor_ident_candidate',
            -- Настройки процесса
            'process_info.process_state'
        ])
    ) LOOP
        BEGIN
            IF NOT EXISTS (
                SELECT 1
                FROM information_schema.tables
                WHERE table_schema || '.' || table_name = v_table_name
            ) THEN
                RAISE WARNING 'Отсутствует таблица: %', v_table_name;
                v_missing_count := v_missing_count + 1;
            ELSE
                RAISE NOTICE 'OK: %', v_table_name;
            END IF;
        EXCEPTION WHEN OTHERS THEN
            RAISE WARNING 'Ошибка при проверке таблицы %: %', v_table_name, SQLERRM;
            v_missing_count := v_missing_count + 1;
        END;
    END LOOP;

    RAISE NOTICE '----------------------------------------';
    RAISE NOTICE 'ОТСУТСТВУЕТ ТАБЛИЦ: %', v_missing_count;
    RAISE NOTICE '========================================';
END $$;

-- =============================================================================
-- 8.3. Проверка существования всех используемых функций и процедур
-- =============================================================================

DO $$
DECLARE
    v_func_name text;
    v_missing_count integer := 0;
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'ПРОВЕРКА СУЩЕСТВОВАНИЯ ФУНКЦИЙ И ПРОЦЕДУР';
    RAISE NOTICE '========================================';

    FOR v_func_name IN (
        SELECT unnest(ARRAY[
            -- Вызываемые из pr_eor_pdl_ident
            'eor.pr_pdl_ident_batch',
            'process_manage.start_process',
            'process_info.pr_helper_log',
            'process_manage.write_message',
            'process_manage.write_error',
            'process_info.get_err_text',
            'process_manage.finish_process',
            -- Вызываемые из pr_pdl_ident_batch
            'eor.pr_eor_pdl_ident_find_rfl_candidate_func',
            'eor.pr_eor_pdl_ident_find_nr_fl_candidate_func',
            'process_info.save_error',
            'sr.sr_common_pkg__sr_event_add',
            'sr.sr_common_pkg__sr_subject_save_h',
            'pkg_eor_api.add_subj_rfl_mention',
            'pkg_eor_api.add_subj_ifl_mention'
        ])
    ) LOOP
        BEGIN
            IF NOT EXISTS (
                SELECT 1
                FROM pg_proc p
                INNER JOIN pg_namespace n ON n.oid = p.pronamespace
                WHERE n.nspname || '.' || p.proname = v_func_name
            ) THEN
                RAISE WARNING 'Отсутствует функция/процедура: %', v_func_name;
                v_missing_count := v_missing_count + 1;
            ELSE
                RAISE NOTICE 'OK: %', v_func_name;
            END IF;
        EXCEPTION WHEN OTHERS THEN
            RAISE WARNING 'Ошибка при проверке функции %: %', v_func_name, SQLERRM;
            v_missing_count := v_missing_count + 1;
        END;
    END LOOP;

    RAISE NOTICE '----------------------------------------';
    RAISE NOTICE 'ОТСУТСТВУЕТ ФУНКЦИЙ/ПРОЦЕДУР: %', v_missing_count;
    RAISE NOTICE '========================================';
END $$;

-- =============================================================================
-- 8.4. Проверка последовательностей
-- =============================================================================

DO $$
DECLARE
    v_seq_name text;
    v_missing_count integer := 0;
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'ПРОВЕРКА СУЩЕСТВОВАНИЯ ПОСЛЕДОВАТЕЛЬНОСТЕЙ';
    RAISE NOTICE '========================================';

    FOR v_seq_name IN (
        SELECT unnest(ARRAY[
            'eor.seq_find_candidate',
            'sr.sr_subject_seq'
        ])
    ) LOOP
        BEGIN
            IF NOT EXISTS (
                SELECT 1
                FROM information_schema.sequences
                WHERE sequence_schema || '.' || sequence_name = v_seq_name
            ) THEN
                RAISE WARNING 'Отсутствует последовательность: %', v_seq_name;
                v_missing_count := v_missing_count + 1;
            ELSE
                RAISE NOTICE 'OK: %', v_seq_name;
            END IF;
        EXCEPTION WHEN OTHERS THEN
            RAISE WARNING 'Ошибка при проверке последовательности %: %', v_seq_name, SQLERRM;
            v_missing_count := v_missing_count + 1;
        END;
    END LOOP;

    RAISE NOTICE '----------------------------------------';
    RAISE NOTICE 'ОТСУТСТВУЕТ ПОСЛЕДОВАТЕЛЬНОСТЕЙ: %', v_missing_count;
    RAISE NOTICE '========================================';
END $$;

-- =============================================================================
-- 8.5. Проверка типов (rowtype) для атрибутов
-- =============================================================================

DO $$
DECLARE
    v_type_name text;
    v_missing_count integer := 0;
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'ПРОВЕРКА СУЩЕСТВОВАНИЯ ТИПОВ (ROWTYPE)';
    RAISE NOTICE '========================================';

    FOR v_type_name IN (
        SELECT unnest(ARRAY[
            'eor.idw_mr_rfl_attr_src',
            'eor.idw_mr_ifl_attr_src'
        ])
    ) LOOP
        BEGIN
            IF NOT EXISTS (
                SELECT 1
                FROM information_schema.tables
                WHERE table_schema || '.' || table_name = v_type_name
            ) THEN
                RAISE WARNING 'Отсутствует таблица/тип: %', v_type_name;
                v_missing_count := v_missing_count + 1;
            ELSE
                RAISE NOTICE 'OK: %', v_type_name;
            END IF;
        EXCEPTION WHEN OTHERS THEN
            RAISE WARNING 'Ошибка при проверке типа %: %', v_type_name, SQLERRM;
            v_missing_count := v_missing_count + 1;
        END;
    END LOOP;

    RAISE NOTICE '----------------------------------------';
    RAISE NOTICE 'ОТСУТСТВУЕТ ТИПОВ: %', v_missing_count;
    RAISE NOTICE '========================================';
END $$;

-- =============================================================================
-- 8.6. Проверка синтаксиса функций и процедур через plpgsql_check
-- =============================================================================

DO $$
DECLARE
    v_result text;
    v_error_count integer := 0;
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'ПРОВЕРКА СИНТАКСИСА ЧЕРЕЗ plpgsql_check';
    RAISE NOTICE '========================================';

    -- Проверка eor.pr_eor_pdl_ident_find_rfl_candidate_func
    BEGIN
        RAISE NOTICE '--- Проверка eor.pr_eor_pdl_ident_find_rfl_candidate_func ---';
        FOR v_result IN
            SELECT * FROM plpgsql_check_function('eor.pr_eor_pdl_ident_find_rfl_candidate_func(TEXT,DATE)')
        LOOP
            RAISE WARNING 'Результат: %', v_result;
            v_error_count := v_error_count + 1;
        END LOOP;
        IF v_error_count = 0 THEN
            RAISE NOTICE 'OK: eor.pr_eor_pdl_ident_find_rfl_candidate_func';
        END IF;
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Ошибка при проверке eor.pr_eor_pdl_ident_find_rfl_candidate_func: %', SQLERRM;
        v_error_count := v_error_count + 1;
    END;

    -- Проверка eor.pr_eor_pdl_ident_find_nr_fl_candidate_func
    BEGIN
        RAISE NOTICE '--- Проверка eor.pr_eor_pdl_ident_find_nr_fl_candidate_func ---';
        FOR v_result IN
            SELECT * FROM plpgsql_check_function('eor.pr_eor_pdl_ident_find_nr_fl_candidate_func(TEXT,DATE)')
        LOOP
            RAISE WARNING 'Результат: %', v_result;
            v_error_count := v_error_count + 1;
        END LOOP;
        IF v_error_count = 0 THEN
            RAISE NOTICE 'OK: eor.pr_eor_pdl_ident_find_nr_fl_candidate_func';
        END IF;
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Ошибка при проверке eor.pr_eor_pdl_ident_find_nr_fl_candidate_func: %', SQLERRM;
        v_error_count := v_error_count + 1;
    END;

    -- Проверка eor.pr_pdl_ident_batch
    BEGIN
        RAISE NOTICE '--- Проверка eor.pr_pdl_ident_batch ---';
        FOR v_result IN
            SELECT * FROM plpgsql_check_function('eor.pr_pdl_ident_batch(text[], process_info.process_state, bigint)')
        LOOP
            RAISE WARNING 'Результат: %', v_result;
            v_error_count := v_error_count + 1;
        END LOOP;
        IF v_error_count = 0 THEN
            RAISE NOTICE 'OK: eor.pr_pdl_ident_batch';
        END IF;
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Ошибка при проверке eor.pr_pdl_ident_batch: %', SQLERRM;
        v_error_count := v_error_count + 1;
    END;

    -- Проверка eor.pr_eor_pdl_ident
    BEGIN
        RAISE NOTICE '--- Проверка eor.pr_eor_pdl_ident ---';
        FOR v_result IN
            SELECT * FROM plpgsql_check_function('eor.pr_eor_pdl_ident(bigint,smallint,smallint)')
        LOOP
            RAISE WARNING 'Результат: %', v_result;
            v_error_count := v_error_count + 1;
        END LOOP;
        IF v_error_count = 0 THEN
            RAISE NOTICE 'OK: eor.pr_eor_pdl_ident';
        END IF;
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Ошибка при проверке eor.pr_eor_pdl_ident: %', SQLERRM;
        v_error_count := v_error_count + 1;
    END;

    RAISE NOTICE '----------------------------------------';
    RAISE NOTICE 'ВСЕГО ЗАМЕЧАНИЙ: %', v_error_count;
    RAISE NOTICE '========================================';
END $$;

-- =============================================================================
-- 8.7. ИТОГОВЫЙ ОТЧЕТ ПО ДИАГНОСТИКЕ
-- =============================================================================

DO $$
DECLARE
    v_check_time timestamp := clock_timestamp();
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '╔══════════════════════════════════════════════════════════════╗';
    RAISE NOTICE '║            ИТОГОВЫЙ ОТЧЕТ ПО ДИАГНОСТИКЕ                    ║';
    RAISE NOTICE '╠══════════════════════════════════════════════════════════════╣';
    RAISE NOTICE '║ ВРЕМЯ ПРОВЕРКИ: %', v_check_time;
    RAISE NOTICE '╠══════════════════════════════════════════════════════════════╣';
    RAISE NOTICE '║ 1. Проверены записи workflow и состояний                   ║';
    RAISE NOTICE '║ 2. Проверено существование всех используемых таблиц        ║';
    RAISE NOTICE '║ 3. Проверено существование всех функций и процедур         ║';
    RAISE NOTICE '║ 4. Проверено существование последовательностей             ║';
    RAISE NOTICE '║ 5. Проверено существование типов (rowtype)                 ║';
    RAISE NOTICE '║ 6. Проверен синтаксис функций и процедур                   ║';
    RAISE NOTICE '╠══════════════════════════════════════════════════════════════╣';
    RAISE NOTICE '║ РЕКОМЕНДАЦИИ:                                              ║';
    RAISE NOTICE '║ 1. Устранить все WARNING, выведенные выше                  ║';
    RAISE NOTICE '║ 2. Проверить отсутствующие объекты                         ║';
    RAISE NOTICE '║ 3. Убедиться в корректности вызовов функций                ║';
    RAISE NOTICE '╚══════════════════════════════════════════════════════════════╝';
    RAISE NOTICE '';
END $$;
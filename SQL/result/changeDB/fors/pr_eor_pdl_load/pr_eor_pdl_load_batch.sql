-- PROCEDURE: eor.pr_eor_pdl_load_batch(text[], process_info.process_state, bigint)

-- DROP PROCEDURE IF EXISTS eor.pr_eor_pdl_load_batch(text[], process_info.process_state, bigint);

CREATE OR REPLACE PROCEDURE eor.pr_eor_pdl_load_batch(
	IN p_ids text[],
	IN p_process_data process_info.process_state,
	IN p_process_log_id bigint)
LANGUAGE 'plpgsql'
    SECURITY DEFINER 
AS $BODY$
 

DECLARE
	-- =========================================================================
	-- КОНСТАНТЫ
	-- =========================================================================
	c_workflow_id CONSTANT process_info.idw_sy_workflow_info.workflow_id%type := 225;  -- ИД рабочего процесса
    c_state_id CONSTANT process_info.idw_sy_workflow_info.state_id%type := 2251;        -- ИД состояния
	c_procedure constant text := 'fors_pg.eor.pr_eor_pdl_load_batch';                    -- Имя процедуры для логирования
    l_process CONSTANT text := 'PR_EOR_PDL_LOAD_PG';                                    -- Имя процесса
    l_sr_type_id CONSTANT bigint := 145;                                                -- Тип субъекта в спецреестре
	
    -- =========================================================================
	-- ПЕРЕМЕННЫЕ
	-- =========================================================================
    c RECORD;                           -- Курсор для записи
	l_cnt bigint := 0;                  -- Счетчик обработанных записей
    l_err_cnt bigint := 0;              -- Счетчик ошибок
    l_id bigint;                        -- ИД обрабатываемой записи
    l_sr_subject_id bigint;             -- ИД субъекта в спецреестре
    l_sr_subject_count bigint;          -- Количество найденных субъектов
	l_error_sign varchar(1);            -- Признак режима обработки ошибок
   
    -- Переменные для буферизации ошибки
    l_error_sqlstate text;              -- Код SQL ошибки
    l_error_message text;               -- Текст сообщения об ошибке
    l_error_backtrace text;             -- Трассировка стека
    l_error_object_id bigint;           -- ИД объекта, вызвавшего ошибку

begin
	-- Инициализация счетчиков
    l_cnt := 0;
    l_err_cnt := 0;
	RAISE NOTICE 'Стартуем процесс обработки батча';

	-- Логируем запуск загрузки ПДЛ
	call pkg_eor_contract_load.log_level_2(
			 p_msg => 'Запуск загрузки ПДЛ'
			,p_process_log_id => p_process_log_id::text
			,p_procedure => c_procedure
			,p_proc_data => p_process_data
	);

    -- =========================================================================
    -- 1. ЗАГРУЗКА В ОПЕРАТИВНЫЙ СЛОЙ
    -- =========================================================================
    for c in (
		WITH source AS (
			SELECT 
				a.id,                                     -- Уникальный идентификатор
				a.load_id,                                -- ИД загрузки
				a.updated_at,                             -- Дата обновления
				a.system_id,                              -- ИД системы-источника
				UPPER(TRIM(BOTH a.full_name)) AS full_name, -- Полное имя (в верхнем регистре)
				a.date_birthday,                          -- Дата рождения
				a.date_death,                             -- Дата смерти
				a.birth_place,                            -- Место рождения
				a.dead,                                   -- Признак смерти
				a.gender,                                 -- Пол
				a.position,                               -- Должность
				a.authority,                              -- Орган власти
				a.country_names,                          -- Названия стран
				a.countries,                              -- Коды стран
				a.sr_subject_id,                          -- ИД субъекта в спецреестре
				a.err_msg                                 -- Сообщение об ошибке
			FROM arch_ext.idw_arj_interfax_pdl_buffer a
			WHERE a.sr_subject_id = 0                    -- Только не загруженные записи
				AND COALESCE(a.err_msg, '0') = CASE WHEN l_error_sign = '1' THEN '1' ELSE '0' END  -- Фильтр по ошибкам
				AND TRIM(BOTH a.full_name) NOT IN ('Child', 'Husb')  -- Исключаем служебные записи
				AND TRIM(BOTH a.full_name) IS NOT NULL    -- Имя не должно быть NULL
				and a.id::text = ANY(p_ids)                    -- Только переданные ИД
				AND NOT EXISTS (                         -- Исключаем записи с ошибками
					SELECT 1 
					FROM process_info.idw_sy_workflow_error we
					WHERE we.object_id = a.id::text
						AND we.workflow_id = p_process_data.workflow_id
						AND we.state_id = p_process_data.state_id
				)
		),
		-- Сбор всех агрегированных данных через LATERAL
		aggregated AS (
			SELECT 
				s.id,
				s.load_id,
				s.updated_at,
				s.system_id,
				s.full_name,
				-- Преобразование даты рождения в формат DATE
				CASE
					WHEN eor.is_date(s.date_birthday, 'dd.mm.yyyy') = 1 
						THEN TO_DATE(s.date_birthday, 'dd.mm.yyyy')
					WHEN eor.is_date(s.date_birthday, 'yyyy-mm-dd') = 1 
						THEN TO_DATE(s.date_birthday, 'yyyy-mm-dd')
					ELSE NULL
				END AS date_birthday,
				-- Преобразование даты смерти в формат DATE
				CASE
					WHEN eor.is_date(s.date_death, 'dd.mm.yyyy') = 1 
						THEN TO_DATE(s.date_death, 'dd.mm.yyyy')
					WHEN eor.is_date(s.date_death, 'yyyy-mm-dd') = 1 
						THEN TO_DATE(s.date_death, 'yyyy-mm-dd')
					ELSE NULL
				END AS date_death,
				s.birth_place,
				CASE WHEN UPPER(s.dead) = 'TRUE' THEN 1 ELSE 0 END AS is_dead,  -- Признак смерти (1 - мертв, 0 - жив)
				CASE 
					WHEN UPPER(s.gender) = 'M' THEN 'M'    -- Мужской пол
					WHEN UPPER(s.gender) = 'F' THEN 'F'    -- Женский пол
					ELSE NULL
				END AS gender,
				s.position,
				s.authority,
				s.country_names,
				s.countries,
				-- Агрегированные данные из дочерних таблиц
				COALESCE(n.c_names, '') AS c_names,                           -- Имена
				COALESCE(t.c_translit_names, '') AS c_translit_names,         -- Транслитерированные имена
				COALESCE(cat.c_categories, '') AS c_categories,               -- Категории
				COALESCE(cat407.c_categories407, '') AS c_categories407,      -- Категории 407
				COALESCE(j.c_jobs, '') AS c_jobs,                             -- Должности
				COALESCE(sl.c_sanlists, '') AS c_sanlists,                    -- Санкционные списки
				COALESCE(san.c_sanctions, '') AS c_sanctions,                 -- Санкции
				COALESCE(cnt.c_countries, '') AS c_countries                  -- Страны
			FROM source s
			-- Сбор имен через LATERAL
			LEFT JOIN LATERAL (
				SELECT SUBSTR(UPPER(STRING_AGG(COALESCE(sa.full_name, sa.first_name || ' ' || sa.last_name || ' ' || sa.middle_name), '; ' ORDER BY COALESCE(sa.full_name, sa.first_name || ' ' || sa.last_name || ' ' || sa.middle_name))), 1, 4000) AS c_names
				FROM arch_ext.idw_arj_pdl_names_buffer sa
				WHERE sa.load_id = s.load_id AND sa.system_id = s.system_id
			) n ON TRUE
			-- Сбор транслитерированных имен через LATERAL
			LEFT JOIN LATERAL (
				SELECT SUBSTR(UPPER(STRING_AGG(sa.translit_names, '; ' ORDER BY sa.translit_names)), 1, 4000) AS c_translit_names
				FROM arch_ext.idw_arj_pdl_translit_names_buffer sa
				WHERE sa.load_id = s.load_id AND sa.system_id = s.system_id
			) t ON TRUE
			-- Сбор категорий через LATERAL
			LEFT JOIN LATERAL (
				SELECT SUBSTR(UPPER(STRING_AGG(r.name, '; ' ORDER BY r.name)), 1, 4000) AS c_categories
				FROM arch_ext.idw_arj_pdl_categories_buffer sa
				INNER JOIN arch_ext.idw_pdl_ref_buffer r ON r.code = sa.category_code AND r.ref_name = 'CATEGORIES'
				WHERE sa.load_id = s.load_id AND sa.system_id = s.system_id
			) cat ON TRUE
			-- Сбор категорий 407 через LATERAL
			LEFT JOIN LATERAL (
				SELECT SUBSTR(UPPER(STRING_AGG(r.name, '; ' ORDER BY r.name)), 1, 4000) AS c_categories407
				FROM arch_ext.idw_arj_pdl_category407_buffer sa
				INNER JOIN arch_ext.idw_pdl_ref_buffer r ON r.code = sa.category_code AND r.ref_name = 'CATEGORIES407'
				WHERE sa.load_id = s.load_id AND sa.system_id = s.system_id
			) cat407 ON TRUE
			-- Сбор должностей через LATERAL
			LEFT JOIN LATERAL (
				SELECT SUBSTR(UPPER(STRING_AGG(sa.authority, '; ' ORDER BY sa.authority)), 1, 4000) AS c_jobs
				FROM arch_ext.idw_arj_pdl_jobs_buffer sa
				WHERE sa.load_id = s.load_id AND sa.system_id = s.system_id
			) j ON TRUE
			-- Сбор санкционных списков через LATERAL
			LEFT JOIN LATERAL (
				SELECT SUBSTR(UPPER(STRING_AGG(sa.sanlist, '; ' ORDER BY sa.sanlist)), 1, 4000) AS c_sanlists
				FROM arch_ext.idw_arj_pdl_sanlists_buffer sa
				WHERE sa.load_id = s.load_id AND sa.system_id = s.system_id
			) sl ON TRUE
			-- Сбор санкций через LATERAL
			LEFT JOIN LATERAL (
				SELECT SUBSTR(UPPER(STRING_AGG(sa.sanction, '; ' ORDER BY sa.sanction)), 1, 4000) AS c_sanctions
				FROM arch_ext.idw_arj_pdl_sanctions_buffer sa
				WHERE sa.load_id = s.load_id AND sa.system_id = s.system_id
			) san ON TRUE
			-- Сбор стран через LATERAL
			LEFT JOIN LATERAL (
				SELECT SUBSTR(UPPER(STRING_AGG(sa.country_name, '; ' ORDER BY sa.country_name)), 1, 4000) AS c_countries
				FROM arch_ext.idw_arj_pdl_countries_buffer sa
				WHERE sa.load_id = s.load_id AND sa.system_id = s.system_id
			) cnt ON TRUE
		)
		SELECT 
			id AS object_id,
			load_id,
			updated_at,
			system_id,
			full_name,
			date_birthday,
			date_death,
			birth_place,
			is_dead,
			gender,
			position,
			authority,
			country_names,
			countries,
			c_names,
			c_translit_names,
			c_categories,
			c_categories407,
			c_jobs,
			c_sanlists,
			c_sanctions,
			c_countries
		FROM aggregated 
	) loop
		
		-- =========================================================================
		-- НАЧАЛО БЛОКА ОБРАБОТКИ ЗАПИСИ
		-- =========================================================================
		<<record_block>>
		begin
			-- Сохраняем идентификатор объекта для обработки
			l_id := c.object_id;
			
			-- Логируем начало загрузки
			CALL eor.rco_helper__log(c_procedure || 'Загрузка system_id = ' || c.system_id || '  l_id = '|| l_id, c_procedure);
			
			-- =====================================================================
			-- ПОИСК ПО SYSTEM_ID В СПЕЦРЕЕСТРЕ ПДЛ (SR.SR_SUBJECT_PDL)
			-- Проставляем найденный ИД спецреестра в архивную запись
			-- Данные в спецреестре обновляем, считаем что данные более верные
			-- =====================================================================
			
			-- Проверяем, существует ли субъект с таким system_id в спецреестре
			select count(1)
			  into l_sr_subject_count
			  from sr.sr_subject_pdl dst
			  join sr.sr_subject s on s.sr_subject_id = dst.sr_subject_id
			 where dst.system_id = c.system_id
			   and s.sr_type_id = l_sr_type_id;

			if l_sr_subject_count > 0 then
				-- Субъект найден - получаем его ИД
				select dst.sr_subject_id
				  into STRICT l_sr_subject_id
				  from sr.sr_subject_pdl dst
				 where dst.system_id = c.system_id LIMIT 1; 

				-- Обновляем данные субъекта новыми значениями
				update sr.sr_subject_pdl dst
				  set is_eor_ident_process = 0,                    -- Сбрасываем признак идентификации
					  update_date = clock_timestamp(),              -- Дата обновления
					  death_date = coalesce(c.date_death, dst.death_date),         -- Дата смерти
					  is_death = coalesce(c.is_dead, dst.is_death),               -- Признак смерти
					  birth_place = coalesce(c.birth_place, dst.birth_place),      -- Место рождения
					  gender = coalesce(c.gender, dst.gender),                    -- Пол
					  names = coalesce(c.c_names, dst.names),                     -- Имена
					  translit_names = coalesce(c.c_translit_names, dst.translit_names), -- Транслит
					  countries = coalesce(c.c_countries, dst.countries),          -- Страны
					  categories = coalesce(c.c_categories, dst.categories),       -- Категории
					  categories407 = coalesce(c.c_categories407, dst.categories407), -- Категории 407
					  jobs = coalesce(c.c_jobs, dst.jobs),                         -- Должности
					  sanlists = coalesce(c.c_sanlists, dst.sanlists),             -- Санкционные списки
					  sanctions = coalesce(c.c_sanctions, dst.sanctions),          -- Санкции
					  position = coalesce(c.position, dst.position),               -- Должность
					  authority = coalesce(c.authority, dst.authority),            -- Орган власти
					  date_birthday = coalesce(c.date_birthday, dst.date_birthday), -- Дата рождения
					  full_name = coalesce(c.full_name, dst.full_name)             -- Полное имя
				where dst.sr_subject_id = l_sr_subject_id;
				
				-- Логируем обновление
				CALL eor.rco_helper__log(c_procedure || 'Обновление system_id = ' || c.system_id || '  l_id = '|| l_id || ' l_sr_subject_id = ' || l_sr_subject_id, c_procedure);
		   else
				-- Субъект не найден - создаем новый
				insert into sr.sr_subject_pdl(
					sr_subject_id,
					update_date,
					death_date,
					is_death,
					birth_place,
					gender,
					names,
					translit_names,
					countries,
					categories,
					categories407,
					jobs,
					sanlists,
					sanctions,
					position,
					authority,
					system_id,
					date_birthday,
					full_name,
					is_eor_ident_process
				) values (
					nextval('sr.sr_subject_seq'),                                  -- Новый ИД из последовательности
					to_date(c.updated_at, 'yyyy-mm-dd hh24:mi:ss" UTC"'),      -- Дата обновления
					c.date_death,                                               -- Дата смерти
					c.is_dead,                                                  -- Признак смерти
					c.birth_place,                                              -- Место рождения
					c.gender,                                                   -- Пол
					c.c_names,                                                  -- Имена
					c.c_translit_names,                                         -- Транслит
					c.c_countries,                                              -- Страны
					c.c_categories,                                             -- Категории
					c.c_categories407,                                          -- Категории 407
					c.c_jobs,                                                   -- Должности
					c.c_sanlists,                                               -- Санкционные списки
					c.c_sanctions,                                              -- Санкции
					c.position,                                                 -- Должность
					c.authority,                                                -- Орган власти
					c.system_id,                                                -- ИД системы
					c.date_birthday,                                            -- Дата рождения
					c.full_name,                                                -- Полное имя
					0                                                           -- Признак идентификации
				) returning sr_subject_id into l_sr_subject_id;
				
				-- Логируем вставку
				CALL eor.rco_helper__log(c_procedure || 'Вставка system_id = ' || c.system_id || '  l_id = '|| l_id || ' l_sr_subject_id = ' || l_sr_subject_id, c_procedure);
		   end if;

			-- =====================================================================
			-- ПРОСТАВЛЯЕМ ИД СУБЪЕКТА СПЕЦРЕЕСТРА В ТАБЛИЦУ ЗАГРУЗКИ
			-- =====================================================================
			update arch_ext.idw_arj_interfax_pdl_load_buffer a
			   set sr_subject_id = coalesce(l_sr_subject_id, 0),
				   create_date = clock_timestamp()                   
			 where a.id = l_id and a.sr_subject_id = 0;
			
			-- Увеличиваем счетчик обработанных записей
			l_cnt := l_cnt + 1;

			-- =====================================================================
			-- УДАЛЯЕМ ЗАПИСЬ ИЗ ТАБЛИЦЫ ОШИБОК (ЕСЛИ БЫЛА)
			-- =====================================================================
			delete from process_info.idw_sy_workflow_error
				  where workflow_id = p_process_data.workflow_id
					and state_id = p_process_data.state_id
					and object_id = l_id::text;
					
			-- =====================================================================
			-- ОЧИЩАЕМ БУФЕРНЫЕ ТАБЛИЦЫ
			-- =====================================================================
			CALL eor.pr_eor_pdl_load_buffer_del( p_id => l_id);
			
			-- =====================================================================
			-- ПРОДВИГАЕМ ЗАПИСЬ ПО ОЧЕРЕДИ ОБРАБОТКИ
			-- =====================================================================
			-- Добавление задания в очередь
			WITH moved_queue AS (
				SELECT 
					workflow_id,
					object_id,
					(
						SELECT state_next.id
						FROM process_info.idw_sr_workflow_state state_current
						INNER JOIN process_info.idw_sr_workflow_state state_next 
							ON state_next.workflow_id = state_current.workflow_id
							AND state_next.order_by = state_current.order_by + 1
						WHERE state_current.workflow_id = aif.workflow_id
						  AND state_current.id = aif.state_id
					) AS state_id,
					'0'::character(1) AS error_sign,
					priority,
					clock_timestamp() AS create_date,
					clock_timestamp() AS state_date
				FROM arch_ext.idw_sy_workflow_info aif
				where workflow_id = c_workflow_id
				and state_id = c_state_id
				and object_id = l_id::text		
			)
			INSERT INTO process_info.idw_sy_workflow_info (
				workflow_id, state_id, object_id, error_sign, priority, create_date, state_date
			)
			SELECT 
				workflow_id, state_id, object_id, error_sign, priority, create_date, state_date
			FROM moved_queue
			WHERE state_id IS NOT NULL;			
			-- Удаление записи из очереди архивного слоя
			
			DELETE FROM arch_ext.idw_sy_workflow_info
			where workflow_id = c_workflow_id  and state_id = c_state_id
  		    and object_id = l_id::text;			
			/*
			update process_info.idw_sy_workflow_info set
				object_id = l_id::text,
				state_id = (
					-- Выбираем следующее состояние
					select state_next.id
					from process_info.idw_sr_workflow_state state_current
					inner join process_info.idw_sr_workflow_state state_next on
						state_next.workflow_id = state_current.workflow_id
						and state_next.order_by = state_current.order_by + 1
					where state_current.workflow_id = c_workflow_id
					  and state_current.id = c_state_id
				),
				error_sign = '0'::text,                    -- Сбрасываем признак ошибки
				state_date = clock_timestamp()             -- Обновляем дату состояния
			where workflow_id = c_workflow_id
			  and state_id = c_state_id
			  and object_id = l_id::text;			
			*/
			-- Логируем успешное завершение обработки записи
			CALL eor.rco_helper__log(c_procedure || 'выполнено system_id = ' || c.system_id || '  l_id = '|| l_id || ' l_sr_subject_id = ' || l_sr_subject_id, c_procedure);
		   
		exception
			-- =====================================================================
			-- ОБРАБОТКА ОШИБОК
			-- =====================================================================
			when others then
				-- Сохраняем информацию об ошибке
				l_error_sqlstate := SQLSTATE;
				l_error_message := SQLERRM;
				--l_error_backtrace := format('%s', pg_exception_context());
				GET STACKED DIAGNOSTICS   l_error_backtrace = PG_EXCEPTION_CONTEXT;
				-- Сохраняем ошибку в таблицу workflow_error
				call process_info.save_error(
					p_object_id=>l_id::text,
					p_workflow_id=>c_workflow_id,
					p_state_id=>c_state_id,
					p_sqlcode=>l_error_sqlstate,
					p_sqlerrm=>l_error_message,
					p_sqlerr_stack=>l_error_backtrace);
				
				
				
				-- Увеличиваем счетчик ошибок
				l_err_cnt := l_err_cnt + 1;
				
				-- Логируем ошибку
				RAISE NOTICE 'Ошибка при обработке записи id=%: %', l_id, l_error_message;
		end record_block;
		-- =========================================================================
		-- КОНЕЦ БЛОКА ОБРАБОТКИ ЗАПИСИ
		-- =========================================================================
	end loop;

end;
$BODY$;
ALTER PROCEDURE eor.pr_eor_pdl_load_batch(text[], process_info.process_state, bigint)
    OWNER TO r_fors_db_owner;


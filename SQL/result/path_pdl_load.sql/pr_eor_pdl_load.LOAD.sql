
-- host 10.10.12.11
-- database fors_pg
-- shema eor

-- EOR: (ПДЛ).Новая запись архивного слоя ПДЛ. 
-- Требуется загрузка в  спецреестр ЕОР.
-- Установка идентификаторов субъектов в опорной таблице
-- Доавление / изменение данных в Спецреестр ПДЛ
-------------------------------------------------------------------
-- 1. Подготовка данных
-------------------------------------------------------------------
	-- Услови выполнения :
	-- Призведена настрока архивного слоя :
		-- Применены измененя к архивному слою (arch_pg)
			-- Выполнение скрипта (archi_change_full.sql)
		-- В архивный слой загруженны тестовые данные
			-- Выполнение скрипта (test/archi_pr_eor_pdl_load_data_test.sql )
	-- Призведена настрока опер слоя (fors_pg):
		-- Применены измененя к опер слою (fors_pg)
		--( fors_change_full.sql)
------------------------------------------------
	-- 1.1 Формирование тестовых данных
		
		INSERT INTO sr.sr_subject (
			sr_subject_id,
			etalon_registry_id,
			eor_subject_mention_id,
			incl_first_date,
			incl_date,
			incl_reason,
			excl_date,
			excl_reason,
			deleted_sign,
			sr_type_id,
			actual_sign,
			checked_sign,
			sr_event_id,
			reg_num_ext_reestr
		)
		SELECT
			p.sr_subject_id,
			NULL::bigint                                   AS etalon_registry_id,
			NULL::bigint                                   AS eor_subject_mention_id,
			COALESCE(p.update_date, now())::timestamp      AS incl_first_date,
			COALESCE(p.update_date, now())::timestamp      AS incl_date,
			p.sanctions                                    AS incl_reason,
			NULL::timestamp                                AS excl_date,
			NULL::text                                     AS excl_reason,
			'0'::character(1)                              AS deleted_sign,
			145                                            AS sr_type_id,
			'1'::character(1)                              AS actual_sign,
			'1'::character(1)                              AS checked_sign,
			NULL::bigint                                   AS sr_event_id,
			NULL::text                                     AS reg_num_ext_reestr
		--select * 
		FROM sr.sr_subject_pdl p
		WHERE NOT EXISTS (
			SELECT 1
			FROM sr.sr_subject s
			WHERE s.sr_subject_id = p.sr_subject_id
		);
		
	-- 1.4. создание опорной таблицы расчета
	create table if not exists eor.test_eor_subject_id(
		id bigint, 
		constraint test_eor_subject_id_pk primary key (id)
	);

	insert into eor.test_eor_subject_id(id)
	values
		(1),
		(2),
		(3),
		(4),
		(5),
       	(6)
	on conflict (id) DO nothing;

	insert into arch_ext.idw_sy_workflow_info(
		workflow_id, state_id, object_id, error_sign, priority, create_date, state_date
	)
	select 225, 2251, ts.id::text, '0', 50, clock_timestamp(), clock_timestamp()
	from eor.test_eor_subject_id ts 
	where  not exists 
	( select * from arch_ext.idw_sy_workflow_info where
		(workflow_id, state_id, object_id)=(225, 2251, ts.id::text)
	);
	-- 1.6. опорная таблица процесса расчета
	create table if not exists eor.test_eor_subject_process(
		id bigint, 
		dt_bgn timestamp, 
		dt_end timestamp
	);


-------------------------------------------------------------------
-- 2. Показ. Запуск.
-------------------------------------------------------------------

	do $$
	
	declare
		l_process_id int8;
	begin
		--Test
		select process_manage.start_process(
			 p_p_process_type => 'PR_EOR_PDL_LOAD_PG'
			,p_p_id_main_process => null
			,p_p_process_plan_id => null
			,p_p_msg => null
			,p_p_comments => null
		) 
		into l_process_id;
	
		insert into eor.test_eor_subject_process(id, dt_bgn)
		values (l_process_id, clock_timestamp());
		call eor.pr_eor_pdl_load(
			 p_process_log_id => l_process_id
			,p_cnt_flow => NULL::smallint
			,p_num_flow => NULL::smallint
		);
	
		call process_manage.finish_process(l_process_id, null);
	
		update eor.test_eor_subject_process set 
			dt_end = clock_timestamp()
		where id = l_process_id;
		
	end $$;

-------------------------------------------------------------------
-- 3. Показ. Результаты.
-------------------------------------------------------------------

	select t.* -- логирование
	from process_info.tbltracer t
	inner join eor.test_eor_subject_process tt on 
		tt.id::text = t.msg2
	order by t.seqnum	
	;
	
	select * -- данные для расчета
	from eor.test_eor_subject_id;
	
	select * -- настройки процесса обработки
	from process_info.process_state 
	where process_alias = 'PR_EOR_PDL_LOAD_PG'
	;
	select * -- атрибуты процесса обработки
	from eor.test_eor_subject_process
	;
	-- Опорная таблица буфера изменений субъектов
	select * from arch_ext.idw_arj_interfax_pdl_load_buffer;
	
	-- Список субъектов на основе опорной таблицы
	select * from sr.sr_subject_pdl dst
	where dst.sr_subject_id in (select sr_subject_id from arch_ext.idw_arj_interfax_pdl_load_buffer);

	-- Очередь в архивном слое (должна отсутвовать)
	select * from arch_ext.idw_sy_workflow_info
	where 
		(
		workflow_id = 225
		and state_id = 2251
		and object_id in (select t.id::text from eor.test_eor_subject_id t)
		) 
	;

	-- Очередь в fors (должна присутвовать только 2252)
	select * from process_info.idw_sy_workflow_info
	where 
		(
		workflow_id = 225
		and state_id = 2251
		and object_id in (select t.id::text from eor.test_eor_subject_id t)
		) 
		or
		(
		workflow_id = 225
		and state_id = 2252
		and object_id in (select t.id::text from eor.test_eor_subject_id t)
		) 
	;

	select we.* -- ошибки обработки
	from process_info.idw_sy_workflow_error we 
	where 
		we.workflow_id = 225
		and we.state_id = 2251
		AND we.object_id IN (SELECT t.id::text FROM eor.test_eor_subject_id t) 
	;
	-- Сводный результат
	WITH metrics AS (
    SELECT 
        '1. Всего субъектов для обработки' AS metric,
        COUNT(*)::text AS value,
        1 as sort_order
    FROM eor.test_eor_subject_id
    
    UNION ALL
    
    SELECT 
        '2. Записей в буфере изменений',
        COUNT(*)::text,
        2
    FROM arch_ext.idw_arj_interfax_pdl_load_buffer
    
    UNION ALL 
    
    SELECT 
        '3. Записей в архивной очереди (должно быть 0)',
        COUNT(*)::text,
        3
    FROM arch_ext.idw_sy_workflow_info
    WHERE workflow_id = 225 AND state_id = 2251
      AND object_id IN (SELECT t.id::text FROM eor.test_eor_subject_id t)
    
    UNION ALL
    
    SELECT 
        '4. Записей в очереди FORS state=2251',
        COUNT(*)::text,
        4
    FROM process_info.idw_sy_workflow_info
    WHERE workflow_id = 225 AND state_id = 2251
      AND object_id IN (SELECT t.id::text FROM eor.test_eor_subject_id t)
    
    UNION ALL
    
    SELECT 
        '5. Записей в очереди FORS state=2252',
        COUNT(*)::text,
        5
    FROM process_info.idw_sy_workflow_info
    WHERE workflow_id = 225 AND state_id = 2252
      AND object_id IN (SELECT t.id::text FROM eor.test_eor_subject_id t)
    
    UNION ALL
    
    SELECT 
        '6. Ошибок обработки',
        COUNT(*)::text,
        6
    FROM process_info.idw_sy_workflow_error we 
    WHERE we.workflow_id = 225 AND we.state_id = 2251
	AND object_id IN (SELECT t.id::text FROM eor.test_eor_subject_id t)
)
SELECT metric, value 
FROM metrics 
ORDER BY sort_order;	

-- Результат теста
SELECT 
    CASE 
        WHEN (SELECT COUNT(*) FROM arch_ext.idw_sy_workflow_info
              WHERE workflow_id = 225 AND state_id = 2251
              AND object_id IN (SELECT t.id::text FROM eor.test_eor_subject_id t)) = 0
        AND (SELECT COUNT(*) FROM process_info.idw_sy_workflow_info
              WHERE workflow_id = 225 AND state_id = 2252
              AND object_id IN (SELECT t.id::text FROM eor.test_eor_subject_id t)
			  ) > 0
        AND (SELECT COUNT(*) FROM process_info.idw_sy_workflow_error we 
              WHERE we.workflow_id = 225 AND we.state_id = 2251
			  AND object_id IN (SELECT t.id::text FROM eor.test_eor_subject_id t)
			  ) = 0
        THEN 'TEST PASSED'
        ELSE 'TEST FAILED - NEED ANALYSIS'
    END AS result;


-------------------------------------------------------------------
-- 4. Откат. Очистка данных предыдущего расчета
-------------------------------------------------------------------		
	-- Удаление ошибок расчета
	delete from process_info.idw_sy_workflow_error we
	where 
		we.workflow_id = 225
		and we.state_id  = 2251
		and we.object_id in (select t.id::text	from eor.test_eor_subject_id t	)
	;
	-- Очистка очереди архивного слоя
	delete from arch_ext.idw_sy_workflow_info
	where 
			workflow_id = 225
		and state_id = 2251
		and object_id in (select id::text from eor.test_eor_subject_id);

-- Очистка очереди fors
	delete from process_info.idw_sy_workflow_info
	where 
			workflow_id = 225
		and state_id = 2252
		and object_id in (select id::text from eor.test_eor_subject_id);

-- очистка буфера ----------------------------------------------------------------------------
-- Очистка дочерних таблиц PDL
-- 1. arch_ext.idw_arj_pdl_categories_buffer
	DELETE FROM arch_ext.idw_arj_pdl_categories_buffer a
	USING arch_ext.idw_arj_interfax_pdl_buffer x
	INNER JOIN eor.test_eor_subject_id t ON t.id = x.id
	WHERE a.load_id = x.load_id
	  AND a.system_id = x.system_id;
	
-- 2. arch_ext.idw_arj_pdl_category407_buffer
	DELETE FROM arch_ext.idw_arj_pdl_category407_buffer a
	USING arch_ext.idw_arj_interfax_pdl_buffer x
	INNER JOIN eor.test_eor_subject_id t ON t.id = x.id
	WHERE a.load_id = x.load_id
	  AND a.system_id = x.system_id;
	
-- 3. arch_ext.idw_arj_pdl_countries_buffer
	DELETE FROM arch_ext.idw_arj_pdl_countries_buffer a
	USING arch_ext.idw_arj_interfax_pdl_buffer x
	INNER JOIN eor.test_eor_subject_id t ON t.id = x.id
	WHERE a.load_id = x.load_id
	  AND a.system_id = x.system_id;
	
-- 4. arch_ext.idw_arj_pdl_jobs_buffer
	DELETE FROM arch_ext.idw_arj_pdl_jobs_buffer a
	USING arch_ext.idw_arj_interfax_pdl_buffer x
	INNER JOIN eor.test_eor_subject_id t ON t.id = x.id
	WHERE a.load_id = x.load_id
	  AND a.system_id = x.system_id;
	
-- 5. arch_ext.idw_arj_pdl_names_buffer
	DELETE FROM arch_ext.idw_arj_pdl_names_buffer a
	USING arch_ext.idw_arj_interfax_pdl_buffer x
	INNER JOIN eor.test_eor_subject_id t ON t.id = x.id
	WHERE a.load_id = x.load_id
	  AND a.system_id = x.system_id;
	
-- 6. arch_ext.idw_arj_pdl_sanctions_buffer
	DELETE FROM arch_ext.idw_arj_pdl_sanctions_buffer a
	USING arch_ext.idw_arj_interfax_pdl_buffer x
	INNER JOIN eor.test_eor_subject_id t ON t.id = x.id
	WHERE a.load_id = x.load_id
	  AND a.system_id = x.system_id;
	
-- 7. arch_ext.idw_arj_pdl_sanlists_buffer
	DELETE FROM arch_ext.idw_arj_pdl_sanlists_buffer a
	USING arch_ext.idw_arj_interfax_pdl_buffer x
	INNER JOIN eor.test_eor_subject_id t ON t.id = x.id
	WHERE a.load_id = x.load_id
	  AND a.system_id = x.system_id;
	
	-- 8. arch_ext.idw_arj_pdl_translit_names_buffer
	DELETE FROM arch_ext.idw_arj_pdl_translit_names_buffer a
	USING arch_ext.idw_arj_interfax_pdl_buffer x
	INNER JOIN eor.test_eor_subject_id t ON t.id = x.id
	WHERE a.load_id = x.load_id
	  AND a.system_id = x.system_id;
	
-- 9. Очистка основной таблицы буфера
	DELETE FROM arch_ext.idw_arj_interfax_pdl_buffer x
	USING eor.test_eor_subject_id t
	WHERE x.id = t.id;

-- srr.sr_subject
	delete from sr.sr_subject x
	where sr_subject_id in (select sr_subject_id from arch_ext.idw_arj_interfax_pdl_load_buffer  );
		
-- 11. Очистка опорной таблицы буфера
	delete from arch_ext.idw_arj_interfax_pdl_load_buffer;

-- 11 удаление опорных объектов показа
	drop  table if exists  eor.test_eor_subject_id;
	drop  table if exists eor.test_eor_subject_process;
	
-- Необходимо выполнить очистку тестовых данных архивного слоя
	-- Выполнение скрипта (test/archi_pr_eor_pdl_clear_data_test.sql )

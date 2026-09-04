-- host 10.10.12.11
-- database fors_pg
-- shema eor

-- ЕОР: Обновление КО РФ из справочника КГРКО eor.pr_eor_rko_er_kgrko_load
-- Обработка новых идентификатором версии данных КО РФ из справочника КГРКО
-- Формирование упоминаний\атрибутов субъектов\адресов\документов, очередей дальнейшей обработки 

-------------------------------------------------------------------
-- 1. Подготовка данных
-------------------------------------------------------------------
	
	-- 1.4. создание опорной таблицы расчета
	create table if not exists eor.test_eor_id(
		id int8, 
		constraint test_eor_id_pk primary key (id)
	);

	insert into eor.test_eor_id(id)
	values
		(567799839),
		(567799840)
	;

	-- 1.5. !!! если сделан откат в EOR_RKO_ER_KGRKO_SYNC_PG.sql, добавляем в очередь обработки. 
	insert into arch_ext.idw_sy_workflow_info(
		workflow_id, state_id, object_id, error_sign, priority, create_date, state_date
	)
	select 258, 2581, id::text, '0', 50, clock_timestamp(), clock_timestamp()
	from eor.test_eor_id
	;
	
	-- 1.6. опорная таблица процесса расчета
	create table if not exists eor.test_eor_process(
		id int8, 
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
	
		select process_manage.start_process(
			 p_p_process_type => 'EOR_RKO_ER_KGRKO_LOAD_PG'
			,p_p_id_main_process => null
			,p_p_process_plan_id => null
			,p_p_msg => null
			,p_p_comments => null
		) 
		into l_process_id;
	
		insert into eor.test_eor_process(id, dt_bgn)
		values (l_process_id, clock_timestamp());
	
		call eor.pr_eor_rko_er_kgrko_load(
			 p_process_log_id => l_process_id
			,p_cnt_flow => NULL::smallint
			,p_num_flow => NULL::smallint
		);
	
		call process_manage.finish_process(l_process_id, null);
	
		update eor.test_eor_process set 
			dt_end = clock_timestamp()
		where id = l_process_id;
	
	end $$;

-------------------------------------------------------------------
-- 3. Показ. Результаты.
-------------------------------------------------------------------

	select t.* -- логирование
	from process_info.tbltracer t
	inner join eor.test_eor_process tt on 
		tt.id::text = t.msg2
	order by t.seqnum	
	;
	
	select * -- данные для расчета
	from eor.test_eor_id;
	
	select * -- настройки процесса обработки
	from process_info.process_state 
	where process_alias = 'EOR_RKO_ER_KGRKO_LOAD_PG'
	;
	
	select * -- упоминания субъектов
	from eor.idw_mr_subject_mention m
	where 
			(m.external_h_id, m.source_id) in (
				select b.opr_message_id::text, 1058
				from eor.test_eor_id t
				inner join arch_ext.idw_arj_kgrko_banc b on
						b.load_id = t.id::int8
				union all
				select f.opr_message_id::text, 1059
				from eor.test_eor_id t
				inner join arch_ext.idw_arj_kgrko_fil f on
						f.load_id = t.id::int8
			)
	;
	
	select a.* -- атрибуты субъектов
	from eor.idw_mr_subject_mention m 
	inner join eor.idw_mr_rko_attr_src a on 
		a.mention_attribute_id = m.mention_attribute_id
	where
			(m.external_h_id, m.source_id) in (
				select b.opr_message_id::text, 1058
				from eor.test_eor_id t
				inner join arch_ext.idw_arj_kgrko_banc b on
						b.load_id = t.id::int8
				union all
				select f.opr_message_id::text, 1059
				from eor.test_eor_id t
				inner join arch_ext.idw_arj_kgrko_fil f on
						f.load_id = t.id::int8
			)
	;
	
	select a.* -- атрибуты субъектов md5
	from eor.idw_mr_subject_mention m 
	inner join eor.idw_mr_mention_attribute a on 
		a.mention_attribute_id = m.mention_attribute_id
	where
			(m.external_h_id, m.source_id) in (
				select b.opr_message_id::text, 1058
				from eor.test_eor_id t
				inner join arch_ext.idw_arj_kgrko_banc b on
						b.load_id = t.id::int8
				union all 
				select f.opr_message_id::text, 1059
				from eor.test_eor_id t
				inner join arch_ext.idw_arj_kgrko_fil f on
						f.load_id = t.id::int8
			)
	;
	
	select sam.* -- связь упоминания субъекта и упоминания адреса
	from eor.idw_mr_subject_mention m 
	inner join eor.idw_mr_subj_address_mention sam on 
		sam.eor_subject_mention_id = m.eor_subject_mention_id 
	where
			(m.external_h_id, m.source_id) in (
				select b.opr_message_id::text, 1058
				from eor.test_eor_id t
				inner join arch_ext.idw_arj_kgrko_banc b on
						b.load_id = t.id::int8
				union all
				select f.opr_message_id::text, 1059
				from eor.test_eor_id t
				inner join arch_ext.idw_arj_kgrko_fil f on
						f.load_id = t.id::int8
			)
	;
	
	select am.* -- упоминание адреса субъекта
	from eor.idw_mr_subject_mention m 
	inner join eor.idw_mr_subj_address_mention sam on 
		sam.eor_subject_mention_id = m.eor_subject_mention_id 
	inner join eor.idw_mr_address_mention am on 
		am.eor_address_mention_id = sam.eor_address_mention_id 
	where
			(m.external_h_id, m.source_id) in (
				select b.opr_message_id::text, 1058
				from eor.test_eor_id t
				inner join arch_ext.idw_arj_kgrko_banc b on
						b.load_id = t.id::int8
				union all
				select f.opr_message_id::text, 1059
				from eor.test_eor_id t
				inner join arch_ext.idw_arj_kgrko_fil f on
						f.load_id = t.id::int8
			)
	;
	
	select wi.* -- упоминание адреса субъекта в очереди на обработку
	from eor.idw_mr_subject_mention m 
	inner join eor.idw_mr_subj_address_mention sam on 
		sam.eor_subject_mention_id = m.eor_subject_mention_id 
	inner join process_info.idw_sy_workflow_info wi on
			wi.workflow_id = 11
		and wi.state_id = 111
		and wi.object_id = sam.eor_address_mention_id::text 
	where
			(m.external_h_id, m.source_id) in (
				select b.opr_message_id::text, 1058
				from eor.test_eor_id t
				inner join arch_ext.idw_arj_kgrko_banc b on
						b.load_id = t.id::int8
				union all
				select f.opr_message_id::text, 1059
				from eor.test_eor_id t
				inner join arch_ext.idw_arj_kgrko_fil f on
						f.load_id = t.id::int8
			)
	;
	
	select a.* -- атрибуты адреса субъекта
	from eor.idw_mr_subject_mention m 
	inner join eor.idw_mr_subj_address_mention sam on 
		sam.eor_subject_mention_id = m.eor_subject_mention_id 
	inner join eor.idw_mr_address_mention am on 
		am.eor_address_mention_id = sam.eor_address_mention_id 
	inner join eor.idw_mr_address_attr_src a on
		a.mention_attribute_id = am.mention_attribute_id 
	where
			(m.external_h_id, m.source_id) in (
				select b.opr_message_id::text, 1058
				from eor.test_eor_id t
				inner join arch_ext.idw_arj_kgrko_banc b on
						b.load_id = t.id::int8
				union all
				select f.opr_message_id::text, 1059
				from eor.test_eor_id t
				inner join arch_ext.idw_arj_kgrko_fil f on
						f.load_id = t.id::int8
			)
	;
	
	select a.* -- атрибуты адреса субъекта md5
	from eor.idw_mr_subject_mention m 
	inner join eor.idw_mr_subj_address_mention sam on 
		sam.eor_subject_mention_id = m.eor_subject_mention_id 
	inner join eor.idw_mr_address_mention am on 
		am.eor_address_mention_id = sam.eor_address_mention_id 
	inner join eor.idw_mr_mention_attribute a on
		a.mention_attribute_id = am.mention_attribute_id 
	where
			(m.external_h_id, m.source_id) in (
				select b.opr_message_id::text, 1058
				from eor.test_eor_id t
				inner join arch_ext.idw_arj_kgrko_banc b on
						b.load_id = t.id::int8
				union all
				select f.opr_message_id::text, 1059
				from eor.test_eor_id t
				inner join arch_ext.idw_arj_kgrko_fil f on
						f.load_id = t.id::int8
			)
	;
	
	select * -- атрибуты процесса обработки
	from eor.test_eor_process
	;
	
	select wi.* -- очередь обработки
	from process_info.idw_sy_workflow_info wi 
	where 
		(
				wi.workflow_id = 258
			and wi.state_id = 2581
			and wi.object_id in (
				select t.id::text
				from eor.test_eor_id t
					)
		)
		or
		(
				wi.workflow_id = 258
			and wi.state_id = 2582
			and wi.object_id in (
				select m.eor_subject_mention_id::text
				from eor.idw_mr_subject_mention m
				where 
					(m.external_h_id, m.source_id) in (
						select b.opr_message_id::text, 1058
						from eor.test_eor_id t
						inner join arch_ext.idw_arj_kgrko_banc b on
								b.load_id = t.id::int8
					)
			)
		)
		or
		(
				wi.workflow_id = 259
			and wi.state_id = 2592
			and wi.object_id in (
				select m.eor_subject_mention_id::text
				from eor.idw_mr_subject_mention m
				where 
					(m.external_h_id, m.source_id) in (
						select f.opr_message_id::text, 1059
						from eor.test_eor_id t
						inner join arch_ext.idw_arj_kgrko_fil f on
								f.load_id = t.id::int8
					)
			)
		);
	
	select we.* -- ошибки обработки
	from process_info.idw_sy_workflow_error we 
	where 
			we.workflow_id = 258
		and we.state_id = 2581
	;

-------------------------------------------------------------------
-- 4. Откат. Очистка данных предыдущего расчета
-------------------------------------------------------------------		
/*
	-- упоминание адреса субъекта в очереди на обработку
	delete from process_info.idw_sy_workflow_info wi
	where
			wi.workflow_id = 11
		and wi.state_id = 111
		and wi.object_id in (
			select sam.eor_address_mention_id::text 
			from eor.idw_mr_subject_mention m 
			inner join eor.idw_mr_subj_address_mention sam on 
				sam.eor_subject_mention_id = m.eor_subject_mention_id 
			where
				(m.external_h_id, m.source_id) in (
					select b.opr_message_id::text, 1058
					from eor.test_eor_id t
					inner join arch_ext.idw_arj_kgrko_banc b on
							b.load_id = t.id::int8
					union all
					select f.opr_message_id::text, 1059
					from eor.test_eor_id t
					inner join arch_ext.idw_arj_kgrko_fil f on
							f.load_id = t.id::int8
				)
		)
	;
	
	-- упоминание адреса субъекта
	delete from eor.idw_mr_address_mention am
	where 
			exists(
				select 'x'
				from eor.idw_mr_subject_mention m 
				inner join eor.idw_mr_subj_address_mention sam on 
					sam.eor_subject_mention_id = m.eor_subject_mention_id 
	 			where
						(m.external_h_id, m.source_id) in (
							select b.opr_message_id::text, 1058
							from eor.test_eor_id t
							inner join arch_ext.idw_arj_kgrko_banc b on
									b.load_id = t.id::int8
							union all
							select f.opr_message_id::text, 1059
							from eor.test_eor_id t
							inner join arch_ext.idw_arj_kgrko_fil f on
									f.load_id = t.id::int8
						)
					and sam.eor_address_mention_id = am.eor_address_mention_id 
			)
	;
	
	-- связь упоминания субъекта и упоминания адреса
	delete from eor.idw_mr_subj_address_mention sam  
	where
			exists(
				select 'x'
				from eor.idw_mr_subject_mention m 
				where
						(m.external_h_id, m.source_id) in (
							select b.opr_message_id::text, 1058
							from eor.test_eor_id t
							inner join arch_ext.idw_arj_kgrko_banc b on
									b.load_id = t.id::int8
							union all
							select f.opr_message_id::text, 1059
							from eor.test_eor_id t
							inner join arch_ext.idw_arj_kgrko_fil f on
									f.load_id = t.id::int8
						)
					and m.eor_subject_mention_id = sam.eor_subject_mention_id
			)
	;

	-- очередь ошибок предыдущего расчета
	delete from process_info.idw_sy_workflow_error we
	where 
			we.workflow_id = 258
		and we.state_id  = 2581
		and we.object_id in (
			select t.id::text
			from eor.test_eor_id t
		)
	;

	-- очередь обработки предыдущего расчета
	delete from process_info.idw_sy_workflow_info wi
	where 
			wi.workflow_id = 258
		and (
				(
						wi.state_id = 2581
					and wi.object_id in (
						select t.id::text
						from eor.test_eor_id t
					)
				)
				or 
				(
						wi.state_id = 2582
					and wi.object_id in (
						select m.eor_subject_mention_id::text
						from eor.idw_mr_subject_mention m
						where 
							(m.external_h_id, m.source_id) in (
								select b.opr_message_id::text, 1058
								from eor.test_eor_id t
								inner join arch_ext.idw_arj_kgrko_banc b on
										b.load_id = t.id::int8
							)
					)
				)
		)
	;
	
	delete from process_info.idw_sy_workflow_info wi
	where 
			wi.state_id = 2592
		and wi.object_id in (
			select m.eor_subject_mention_id::text
			from eor.idw_mr_subject_mention m
			where 
				(m.external_h_id, m.source_id) in (
					select f.opr_message_id::text, 1059
					from eor.test_eor_id t
					inner join arch_ext.idw_arj_kgrko_fil f on
							f.load_id = t.id::int8
				)
		)
	;
	
	-- упоминания субъектов 
	delete from eor.idw_mr_subject_mention m
	where 
			(m.external_h_id, m.source_id) in (
				select b.opr_message_id::text, 1058
				from eor.test_eor_id t
				inner join arch_ext.idw_arj_kgrko_banc b on
						b.load_id = t.id::int8
				union all
				select f.opr_message_id::text, 1059
				from eor.test_eor_id t
				inner join arch_ext.idw_arj_kgrko_fil f on
						f.load_id = t.id::int8
			)
	;	
	
	delete from arch_ext.idw_sy_workflow_info
	where 
			workflow_id = 258
		and state_id = 2581
		and object_id in (select id::text from eor.test_eor_id)
	;
	
	delete from arch_ext.idwh2_load_buffer
	where load_id in (select id from eor.test_eor_id)
	;
	
	delete from arch_ext.idw_arj_kgrko_banc_buffer
	where load_id in (select id from eor.test_eor_id)
	;
	
	delete from arch_ext.idw_arj_kgrko_fil_buffer
	where load_id in (select id from eor.test_eor_id)
	;
	
	delete from arch_ext.arj_rko_kgrko_load_buffer
	where load_id in (select id from eor.test_eor_id)
	;
	
	drop table eor.test_eor_id;
	
	drop table eor.test_eor_process;
*/	
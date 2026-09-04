-- host 10.10.22.40
-- database arch_pg
-- shema kgrko

-- ЕОР: Обновление КО РФ из справочника КГРКО kgrko.pr_eor_rko_er_kgrko_sync
-- Обработка новых данных архивного слоя КО РФ из справочника КГРКО
-- Заполнение очереди обработки идентификатором версии данных КО РФ из справочника КГРКО

-------------------------------------------------------------------
-- 1. Подготовка данных
-------------------------------------------------------------------

	-- 1.1. исходные данные. загрузки. 
	insert into virj.idwh2_load (
		load_id, type_load_id, date_load, description, type_data_id, 
		file_requisites, file_name, file_size, file_creation_date, os_user, 
		machine, terminal, proc_id
	)
	values 
		(
			567799839, 4, '2020-09-04 00:00:00.000', 'Загрузка КГРКО в архивный слой (КО)', 1058, 
			null, 'BANC.XML\KR200901.ARJ', null, '2020-09-01 00:00:00.000', 
			'Comp', 'WORKGROUP\COMPTM', 'COMPTM', null
		),
		(
			567799840, 4, '2020-09-04 00:00:00.000', 'Загрузка КГРКО в архивный слой (Филиалы КО)', 1059, 
			null, 'FIL.XML\KR200901.ARJ', null, '2020-09-01 00:00:00.000', 'Comp', 
			'WORKGROUP\COMPTM', 'COMPTM', null
		)
	on conflict on constraint idwh2_load_pk do nothing
	;
	
	-- 1.2. исходные данные. КО.
	insert into kgrko.idw_arj_kgrko_banc (
		opr_message_id, load_id, rownumber, bvkey, cp, 
		p, num, u_o, gap, status, 
		tip, namemax, namemax1, "name", namer, 
		uf_old, ust_f, ust_fi, ust_fb, kol_i, 
		kol_b, kolf, kolfd, data_reg, mesto, 
		data_preg, data_izmud, regn, priz, qq, lic_gold, 
		lic_gold1, lic_rub, ogran, ogran1, ogran2, 
		lic_val, vv, rei, "no", opp, 
		ko, kp, adres, adres1, telefon, 
		fax, fio_pr_pr, fio_gl_b, fio_zam_p, fio_zam_g, 
		data_otz, pric_otz, data_pri, date_prb, type_prb, 
		date_nam, date_adr, date_fiz, numsrf, okpo, 
		dat_zayv, egr, kliring, cb_date, fiz_end, 
		num_ssv, data_ssv, cnlic, type_ko, name_en, 
		ann, tip_lic, inn, date_inn, is_proceeded, 
		err_msg, inn_pr_pr, bd_pr_pr, doc_pr_pr, inn_gl_b, 
		bd_gl_b, doc_gl_b, is_load
	)
	values (
		201613317, 567799839, 152, '[V6KeJ-F', 45, 
		null, 16, 'С', null, 'АКЦ', 
		'Н', 'КОММЕРЧЕСКИЙ ТОПЛИВНО-ЭНЕРГЕТИЧЕСКИЙ МЕЖРЕГИОНАЛЬНЫЙ БАНК РЕКОНСТРУКЦИИ И РАЗВИТИЯ (акционерное общество)', NULL, 'ТЭМБР-БАНК', 'АО "ТЭМБР-БАНК"', 
		1000, 1329776.163, NULL, NULL, NULL, 
		NULL, 2, 2, '1994-03-28', NULL, 
		NULL, '2013-12-19', 2764, NULL, '2016-02-12', 
		NULL, '2016-03-03', '2016-03-03', NULL, NULL, 
		NULL, '2016-03-03', 'G', 'E', 'N', 
		'L', 'C', NULL, '127473,  г. Москва, 1-й Волконский пер., д. 10', '127473,  г. Москва, 1-й Волконский пер., д. 10', 
		'(495) 363-44-99, (495) 775-62-82', NULL, 'Сучилина Елена Дмитриевна', 'Гусейнова Ариза Афиндиевна', NULL, 
		NULL, NULL, NULL, NULL, '2000-02-21', 'АКЦ', 
		'2016-02-20', '2004-08-06', '2016-03-03', '45000', '29293916', 
		'1993-11-03', '1027739282581', NULL, NULL, NULL, 
		875, '2005-09-01', '2764', 1, 'Commercial Fuel & Energy Interregional Bank for Reconstruction and Development (joint-stock company), TEMBR-BANK (JSC)', 
		NULL, 1, '7707283980', '2017-01-05', 0, 
		NULL, NULL, NULL, NULL, NULL, 
		NULL, NULL, false
	)
	on conflict on constraint kgrko_idw_arj_kgrko_banc_pk do update set
		is_proceeded = 0
	;

	-- 1.3. исходные данные. Филиалы КО.
	insert into kgrko.idw_arj_kgrko_fil (
		opr_message_id, load_id, rownumber, fvkey, rnbn, 
		data_reg, rnfl, namef, namespr, num, 
		num_f, adres, fio_pr_fl, fio_gl_b, fio_zam_p, 
		fio_zam_g, telefon1, fax, nam, otz, 
		cp, cp_f, adresp, numpsrf, numpsrb, 
		adresf, okpo, country, is_proceeded, err_msg, 
		inn_pr_fl, bd_pr_fl, doc_pr_fl, inn_gl_b, bd_gl_b, 
		doc_gl_b, is_load
	)
	values 
		(
			201614396, 567799840, 421, 'F5512', 2764, 
			'1996-07-02', 1, '"Амурский"', '"Амурский"', 16, 
			68, '675000, Амурская обл., г. Благовещенск, ул. Шевченко, 28', 'Аршинова Ольга Сергеевна', 'Гроо Елена Юрьевна', NULL, 
			null, '(4162)22-05-01, (4162)22-05-02', '(4162)22-05-07', 'ТЭМБР-БАНК', null, 
			45, 10, '675000, Амурская обл., г. Благовещенск, ул. Шевченко, 28', '10000', '45000', 
			'675000, Амурская обл., г. Благовещенск, ул. Шевченко, 28', '44082186', 643, 0, null, 
			null, null, null, null, null, 
			null, true
		),
		(
			201614397, 567799840, 422, 'F15869', 2764, 
			'2010-06-09', 3, '"Калининградский"', '"Калининградский"', 16, 
			73, '236008, Калининградская область, г. Калининград, ул. Лени Голикова, д. 4', 'Чернокоз Виталий Васильевич', 'Михайлова Наталья Юрьевна', NULL, 
			NULL, '/4012/37-03-01, /4012/37-03-02', NULL, 'ТЭМБР-БАНК', NULL, 
			45, 27, '236008, Калининградская область, г. Калининград, ул. Лени Голикова, д. 4', '27000', '45000', 
			'236008, Калининградская область, г. Калининград, ул. Лени Голикова, д. 4', NULL, 643, 0, NULL, 
			NULL, NULL, NULL, NULL, NULL, 
			NULL, true
		)
	on conflict on constraint kgrko_idw_arj_kgrko_fil_pk do update set
		is_proceeded = 0
	;
	
	-- 1.4. создание опорной таблицы расчета
	create table if not exists kgrko.test_eor_id(
		id int8, 
		constraint test_eor_id_pk primary key (id)
	);

	insert into kgrko.test_eor_id(id)
	values
		(567799839),
		(567799840)
	;

	-- 1.5. добавляем в очередь обработки 
	insert into process_info.idw_sy_workflow_info(
		workflow_id, state_id, object_id, priority, create_date, state_date
	)
	select 258, 2580, id::text, 50, clock_timestamp(), clock_timestamp()
	from kgrko.test_eor_id
	;
	
	-- 1.6. опорная таблица процесса расчета
	create table if not exists kgrko.test_eor_process(
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
			 p_p_process_type => 'EOR_RKO_ER_KGRKO_SYNC_PG'
			,p_p_id_main_process => null
			,p_p_process_plan_id => null
			,p_p_msg => null
			,p_p_comments => null
		) 
		into l_process_id;
	
		insert into kgrko.test_eor_process(id, dt_bgn)
		values (l_process_id, clock_timestamp());
	
		call kgrko.pr_eor_rko_er_kgrko_sync(
			 p_process_log_id => l_process_id
			,p_cnt_flow => NULL::smallint
			,p_num_flow => NULL::smallint
		);
	
		call process_manage.finish_process(l_process_id, null);
	
		update kgrko.test_eor_process set 
			dt_end = clock_timestamp()
		where id = l_process_id;
	
	end $$;

-------------------------------------------------------------------
-- 3. Показ. Результаты.
-------------------------------------------------------------------
	
	select * -- логирование процесса обработки 
	from process_info.tbltracer t
	inner join kgrko.test_eor_process tt on 
		tt.id::text = msg2
	order by seqnum	
	;

	select * -- идентификаторы, обработанных загрузок
	from kgrko.test_eor_id
	;

	select * -- настройки процесса обработки
	from process_info.process_state 
	where process_alias = 'EOR_RKO_ER_KGRKO_SYNC_PG'
	;

	select * -- атрибуты процесса обработки 
	from kgrko.test_eor_process;

	select wi.* -- очередь обработки 
	from process_info.idw_sy_workflow_info wi 
	where
			wi.workflow_id = 258
		and wi.state_id in (2580,2581);
	;

	select wi.* -- ошибки обработки
	from process_info.idw_sy_workflow_error wi 
	where 
			wi.workflow_id = 258
		and wi.state_id in (2580);
	;
	
-------------------------------------------------------------------
-- 4. Откат. Очистка данных предыдущего расчета
-------------------------------------------------------------------
/*	
	-- очередь ошибок
	delete from process_info.idw_sy_workflow_error
	where 
			workflow_id = 258
		and state_id = 2580
		and object_id in (select id::text from kgrko.test_eor_id)
	;
	
	-- очередь обработки
	delete from process_info.idw_sy_workflow_info
	where 
			workflow_id = 258
		and state_id in (2580, 2581)
		and object_id in (select id::text from kgrko.test_eor_id)
	;
	
	drop table kgrko.test_eor_id;
	
	drop table kgrko.test_eor_process;
*/
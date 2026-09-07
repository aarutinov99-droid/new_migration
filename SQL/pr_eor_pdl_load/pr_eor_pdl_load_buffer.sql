-- DROP PROCEDURE eor.pr_eor_pdl_load_buffer(_text, int8);

CREATE OR REPLACE PROCEDURE eor.pr_eor_pdl_load_buffer(IN p_ids text[], IN p_process_log_id bigint)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $procedure$ 
declare
	c_workflow_id constant process_info.idw_sy_workflow_info.workflow_id%type := 104;
	c_state_id constant process_info.idw_sy_workflow_info.state_id%type := 1041;
	l_ids text[];
	c_procedure constant text := 'fors_pg.eor.pr_eor_pdl_load_buffer';
	rows_count bigint;
	
begin

	-- переносим данные по очереди обработки из arch_pg в fors_pg
	insert into process_info.idw_sy_workflow_info(
		 workflow_id
		,state_id
		,object_id
		,priority
		,create_date
		,state_date
	)
	select
		 workflow_id
		,state_id
		,object_id
		,priority
		,create_date
		,state_date 
	from arch_ext.idw_sy_workflow_info 
	where
			workflow_id = c_workflow_id
		and state_id = c_state_id
		and object_id in (select unnest(p_ids));

	-- удаляем данные по очереди обработки в arch_pg
	delete from arch_ext.idw_sy_workflow_info
	where 
			workflow_id = c_workflow_id
		and state_id = c_state_id
		and object_id in (select unnest(p_ids));

	-- исключаем из загрузки, ранее загруженные
	select array_agg(a.id)
	into l_ids
	from (select unnest(p_ids) as id) a
	where not exists(
		select 'x'
		from arch_ext.idwh2_arj_contract_gov_load_buffer b -- TODO
		where b.id = a.id
	);

	if coalesce(cardinality(l_ids),0) = 0 then
		return;
	end if;

	-- 1. Буферизация основной таблицы
    RAISE NOTICE 'Начало буферизации основной таблицы idw_arj_interfax_pdl...';
    -- Копирование данных из исходной таблицы в буферную
    INSERT INTO arch_ext.idw_arj_interfax_pdl_buffer (
        load_id,
        updated_at,
        system_id,
        full_name,
        date_birthday,
        date_death,
        birth_place,
        dead,
        gender,
        names,
        translit_names,
        countries,
        categories,
        category407,
        jobs,
        incomes,
        ownerships,
        sanlists,
        sanctions,
        relatives,
        biography,
        create_date,
        err_msg,
        sr_subject_id,
        date_load,
        "position",
        authority,
        country_names,
        names_err,
        translit_names_err,
        countries_err,
        categories_err,
        category407_err,
        jobs_err,
        incomes_err,
        ownerships_err,
        sanlists_err,
        sanctions_err,
        relatives_err,
        biography_err,
        persdocs,
        addresses,
        contact_infos,
        persdocs_err,
        addresses_err,
        contact_infos_err,
        is_load,
		id
    )
    SELECT 
        load_id,
        updated_at,
        system_id,
        full_name,
        date_birthday,
        date_death,
        birth_place,
        dead,
        gender,
        names,
        translit_names,
        countries,
        categories,
        category407,
        jobs,
        incomes,
        ownerships,
        sanlists,
        sanctions,
        relatives,
        biography,
        create_date,
        err_msg,
        sr_subject_id,
        date_load,
        position,
        authority,
        country_names,
        names_err,
        translit_names_err,
        countries_err,
        categories_err,
        category407_err,
        jobs_err,
        incomes_err,
        ownerships_err,
        sanlists_err,
        sanctions_err,
        relatives_err,
        biography_err,
        persdocs,
        addresses,
        contact_infos,
        persdocs_err,
        addresses_err,
        contact_infos_err,
        is_load,
		id
    FROM arch_ext.idw_arj_interfax_pdl
	WHERE id IN (SELECT unnest(l_ids)::bigint)
	ON CONFLICT ON CONSTRAINT idw_arj_interfax_pdl_buffer_pk DO NOTHING;
    GET DIAGNOSTICS rows_count = ROW_COUNT;
	RAISE NOTICE 'Буферизация основной таблицы завершена. Скопировано % записей.', rows_count;
	
	-- Буферизация дочерних таблиц
    RAISE NOTICE 'Начало буферизации дочерних таблиц...';
    
    --  Буферизация категорий
    RAISE NOTICE '  Буферизация idw_arj_pdl_categories...';
    INSERT INTO arch_ext.idw_arj_pdl_categories_buffer (
        id, load_id, system_id, category_code, create_date, create_user, is_load
    )
	select distinct sa.id,
		 sa.load_id,
		 sa.system_id,
		 sa.category_code,
		 sa.create_date,
		 sa.create_user,
		 sa.is_load
	from arch_ext.idw_arj_pdl_categories sa
	inner join  arch_ext.idw_arj_interfax_pdl_buffer a on  sa.load_id = a.load_id    and sa.system_id = a.system_id
    inner join  arch_ext.idw_pdl_ref r  on r.code = sa.category_code and r.ref_name = 'CATEGORIES'
	ON CONFLICT ON CONSTRAINT idw_arj_pdl_categories_buffer_pk DO NOTHING;
    GET DIAGNOSTICS rows_count = ROW_COUNT;
    RAISE NOTICE '    Скопировано % записей.', rows_count;

    -- Буферизация категорий 407
    RAISE NOTICE '  Буферизация idw_arj_pdl_category407...';
    INSERT INTO arch_ext.idw_arj_pdl_category407_buffer (
        id, load_id, system_id, category_code, create_date, create_user, is_load
    )
     select distinct sa.id,
			sa.load_id,
			sa.system_id,
			sa.category_code,
			sa.create_date,
			sa.create_user,
			sa.is_load
		from arch_ext.idw_arj_pdl_category407 sa
		inner join  arch_ext.idw_arj_interfax_pdl_buffer a on  sa.load_id = a.load_id    and sa.system_id = a.system_id
        inner join  arch_ext.idw_pdl_ref r  on r.code = sa.category_code and r.ref_name = 'CATEGORIES407'
	ON CONFLICT ON CONSTRAINT idw_arj_pdl_category407_buffer_pk DO NOTHING;
    GET DIAGNOSTICS rows_count = ROW_COUNT;
    RAISE NOTICE '    Скопировано % записей.', rows_count;

    -- Буферизация стран
    RAISE NOTICE '  Буферизация idw_arj_pdl_countries...';
    INSERT INTO arch_ext.idw_arj_pdl_countries_buffer (
        id, load_id, system_id, updated_at, iso, en, country_name,
        create_date, create_user, is_load
    )
	select ca.id, ca.load_id, ca.system_id, ca.updated_at, ca.iso, ca.en, ca.country_name, ca.create_date, ca.create_user, ca.is_load
	from arch_ext.idw_arj_pdl_countries ca
	inner join  arch_ext.idw_arj_interfax_pdl_buffer a on  ca.load_id = a.load_id    and ca.system_id = a.system_id
	ON CONFLICT ON CONSTRAINT idw_arj_pdl_countries_buffer_pk DO NOTHING;
    GET DIAGNOSTICS rows_count = ROW_COUNT;
    RAISE NOTICE '    Скопировано % записей.', rows_count;

    -- Буферизация должностей
    RAISE NOTICE '  Буферизация idw_arj_pdl_jobs...';
    INSERT INTO arch_ext.idw_arj_pdl_jobs_buffer (
        id, load_id, system_id, updated_at, date_start, date_end,
        source, main, unactive, name, authority, reg_id,
        create_date, create_user, is_load
    )
    select ja.id, ja.load_id, ja.system_id, ja.updated_at, ja.date_start, ja.date_end,
           	ja.source, ja.main, ja.unactive, ja.name, ja.authority, ja.reg_id,
           	ja.create_date, ja.create_user, ja.is_load
    from arch_ext.idw_arj_pdl_jobs ja
    inner join  arch_ext.idw_arj_interfax_pdl_buffer a on  ja.load_id = a.load_id    and ja.system_id = a.system_id
	ON CONFLICT ON CONSTRAINT idw_arj_pdl_jobs_buffer_pk DO NOTHING;
    GET DIAGNOSTICS rows_count = ROW_COUNT;
    RAISE NOTICE '    Скопировано % записей.', rows_count;

    -- Буферизация имен
    RAISE NOTICE '  Буферизация idw_arj_pdl_names...';
    INSERT INTO arch_ext.idw_arj_pdl_names_buffer (
        id, load_id, system_id, locale, updated_at,
        last_name, first_name, middle_name, full_name,
        create_date, create_user, is_load
    )
    select  sa.id, sa.load_id, sa.system_id, sa.locale, sa.updated_at,
        	sa.last_name, sa.first_name, sa.middle_name, sa.full_name,
        	sa.create_date, sa.create_user, sa.is_load
	from  arch_ext.idw_arj_pdl_names sa
    inner join  arch_ext.idw_arj_interfax_pdl_buffer a on  sa.load_id = a.load_id  and sa.system_id = a.system_id
	ON CONFLICT ON CONSTRAINT idw_arj_pdl_names_buffer_pk DO NOTHING;
    GET DIAGNOSTICS rows_count = ROW_COUNT;
    RAISE NOTICE '    Скопировано % записей.', rows_count;

    -- Буферизация санкций
    RAISE NOTICE '  Буферизация idw_arj_pdl_sanctions...';
    INSERT INTO arch_ext.idw_arj_pdl_sanctions_buffer (
        id, load_id, system_id, sanction, date_start, date_end,
        source, reason_inclusion, sanlist, country, extra_informations,
        uidd, last_update_in_source, create_date, create_user, is_load
    )
	SELECT sa.id, sa.load_id, sa.system_id, sa.sanction, sa.date_start, sa.date_end,
	        sa.source, sa.reason_inclusion, sa.sanlist, sa.country, sa.extra_informations,
    	    sa.uidd, sa.last_update_in_source, sa.create_date, sa.create_user, sa.is_load
    FROM arch_ext.idw_arj_pdl_sanctions sa
    inner join  arch_ext.idw_arj_interfax_pdl_buffer a on  sa.load_id = a.load_id and sa.system_id = a.system_id
	ON CONFLICT ON CONSTRAINT idw_arj_pdl_sanctions_buffer_pk DO NOTHING;
    GET DIAGNOSTICS rows_count = ROW_COUNT;
    RAISE NOTICE '    Скопировано % записей.', rows_count;

    -- Буферизация санкционных листов
    RAISE NOTICE '  Буферизация idw_arj_pdl_sanlists...';
    INSERT INTO arch_ext.idw_arj_pdl_sanlists_buffer (
        id, load_id, system_id, updated_at, sanlist_id, sanlist,
        create_date, create_user, is_load
    )
	SELECT sa.id, sa.load_id, sa.system_id, sa.updated_at, sa.sanlist_id, sa.sanlist,
    		sa.create_date, sa.create_user, sa.is_load
    FROM arch_ext.idw_arj_pdl_sanlists sa
    inner join  arch_ext.idw_arj_interfax_pdl_buffer a on  sa.load_id = a.load_id    and sa.system_id = a.system_id
	ON CONFLICT ON CONSTRAINT idw_arj_pdl_sanlists_buffer_pk DO NOTHING;
    GET DIAGNOSTICS rows_count = ROW_COUNT;
    RAISE NOTICE '    Скопировано % записей.', rows_count;

    -- Буферизация транслитерированных имен
    RAISE NOTICE '  Буферизация idw_arj_pdl_translit_names...';
    INSERT INTO arch_ext.idw_arj_pdl_translit_names_buffer (
        id, load_id, system_id, translit_names,
        create_date, create_user, is_load
    )
    SELECT distinct sa.id, sa.load_id, sa.system_id, sa.translit_names,
           sa.create_date, sa.create_user, sa.is_load
    FROM arch_ext.idw_arj_pdl_translit_names sa
	inner join  arch_ext.idw_arj_interfax_pdl_buffer a on  sa.load_id = a.load_id    and sa.system_id = a.system_id
	ON CONFLICT ON CONSTRAINT idw_arj_pdl_translit_names_buffer_pk DO NOTHING;
    GET DIAGNOSTICS rows_count = ROW_COUNT;
    RAISE NOTICE '    Скопировано % записей.', rows_count;

    RAISE NOTICE 'Буферизация дочерних таблиц завершена.';

	-- признак загрузки данных архивного слоя arch_pg в fors_pg -- TODO
	insert into arch_ext.idw_arj_interfax_pdl_load_buffer(
		 id
		,create_date
	)
	select 
		 a.id,
		 clock_timestamp()
	from (select unnest(l_ids)::bigint as id) a
	ON CONFLICT ON CONSTRAINT idw_arj_interfax_pdl_load_buffer_pk DO NOTHING;

exception
when others
then 
	declare
    	v_err_code text;
    	v_msg_text text;
    	v_context text;
    	v_detail text;
    	v_hint text;
   	begin
		get stacked diagnostics
			 v_err_code = RETURNED_SQLSTATE
		  	,v_msg_text = MESSAGE_TEXT
    	  	,v_context  = PG_EXCEPTION_CONTEXT
    	  	,v_detail   = PG_EXCEPTION_DETAIL
          	,v_hint     = PG_EXCEPTION_HINT;
 
     	call process_info.pr_helper_log(
			 p_funcname => c_procedure
			,p_msg1 => 
				process_info.get_err_text(
					 p_state => v_err_code
					,p_msg => v_msg_text
					,p_detail => v_detail
					,p_hint => v_hint
					,p_context => v_context
				)
			,p_msg2 => p_process_log_id::text
			,p_msg3 => null::text
			,p_msg4 => null::text
		);
		raise;
	end;
end;
$procedure$;

-- Permissions
ALTER PROCEDURE eor.pr_eor_pdl_load_buffer(text[], bigint) OWNER TO r_fors_db_owner;
GRANT ALL ON PROCEDURE eor.pr_eor_pdl_load_buffer(text[], bigint) TO r_fors_db_owner;
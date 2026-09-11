-- =============================================================================
-- ЕДИНЫЙ СКРИПТ ИЗМЕНЕНИЙ К БД
-- =============================================================================
-- Описание: Скрипт обновления БД для регламентных процессов EOR PDL LOAD и
--           EOR PDL IDENT. Включает создание/обновление функций, процедур
--           и временной таблицы для идентификации кандидатов.
-- =============================================================================

-- =============================================================================
-- 1. ФУНКЦИЯ eor.is_date
-- =============================================================================
-- Назначение: Проверка корректности даты в текстовом формате по заданному шаблону.
-- Возвращает: 1 - дата корректна, 0 - дата некорректна или NULL.
-- Параметры:
--   p_date   - текстовая дата для проверки
--   p_format - формат даты (например, 'dd.mm.yyyy', 'yyyy-mm-dd')
-- =============================================================================

CREATE OR REPLACE FUNCTION eor.is_date(
	p_date text,
	p_format text)
    RETURNS smallint
    LANGUAGE 'plpgsql'
    COST 100
    IMMUTABLE PARALLEL UNSAFE
AS $BODY$

DECLARE
  l_dt timestamp;
begin
  if p_date is null then
    return 0;
  end if;

  l_dt := to_timestamp(p_date, p_format);
  return 1;
exception
  when others then
    return 0;
END;
$BODY$;

ALTER FUNCTION eor.is_date(text, text)
    OWNER TO fors_idwh2_owner;
GRANT EXECUTE ON FUNCTION eor.is_date(text, text) TO PUBLIC;
GRANT EXECUTE ON FUNCTION eor.is_date(text, text) TO fors_idwh2_owner;

-- =============================================================================
-- 2. ПРОЦЕДУРА eor.pr_eor_pdl_load
-- =============================================================================
-- Назначение: Регламентный процесс "ЕОР: загрузка ПДЛ из архивного в буферный
--             слой" (аналог ORION_38). Управляет процессом загрузки:
--             запускает процесс, читает настройки, обрабатывает пачки записей,
--             обрабатывает ошибки, завершает процесс.
-- Параметры:
--   p_process_log_id - ИД лога процесса (NULL для старта нового процесса)
--   p_cnt_flow       - количество потоков (по умолчанию 1)
--   p_num_flow       - номер текущего потока (по умолчанию 1)
-- =============================================================================

CREATE OR REPLACE PROCEDURE eor.pr_eor_pdl_load(IN p_process_log_id bigint, IN p_cnt_flow smallint DEFAULT NULL::smallint, IN p_num_flow smallint DEFAULT NULL::smallint)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $procedure$ 
declare
	l_process process_info.process_state.process_alias%type := 'PR_EOR_PDL_LOAD_PG';
	l_procedure text := 'eor.pr_eor_pdl_load';

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
			 l_proc_id
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

	case
	when 
			l_cnt_flow < 1
		or  l_cnt_flow > 100
		or  l_num_flow < 1
		or  l_num_flow > l_cnt_flow
	then
		
		call process_info.pr_helper_log(l_procedure, 'Неверное значение количества потоков\текущий поток [' || l_cnt_flow::text || '''' || l_num_flow || ']! Выход.', l_proc_id::text); 
        
		call process_manage.write_error(
			 l_proc_id
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
					 l_proc_id
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

				select 
					 array_agg(object_id)
					,count(8)
				into 
					 l_array_id
					,l_cnt
				from (
					select wi.object_id
					from arch_ext.idw_sy_workflow_info wi
					inner join arch_ext.idw_arj_interfax_pdl a on
						wi.object_id = a.id::text
					where 
							wi.workflow_id = l_process_data.workflow_id
						and wi.state_id = l_process_data.state_id
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

				select 
					 array_agg(object_id)
					,count(8)
				into 
					 l_array_id
					,l_cnt
				from (
					select wi.object_id
					from process_info.idw_sy_workflow_info wi
					inner join arch_ext.idw_arj_interfax_pdl_buffer a on 
						wi.object_id = a.id::text
					where 
							wi.workflow_id = l_process_data.workflow_id
						and wi.state_id = l_process_data.state_id
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

					call eor.pr_eor_pdl_load_buffer(
						 p_ids => l_array_id
						,p_process_log_id => l_proc_id
					);
					
					call eor.pr_eor_pdl_load_batch(
						 p_ids => l_array_id
						,p_process_data => l_process_data
						,p_process_log_id => l_proc_id
					);
	
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
				 
				     	call process_info.pr_helper_log(l_procedure, process_info.get_err_text(v_err_code, v_msg_text, v_detail, v_hint, v_context), l_proc_id::text);
				
					   	call process_manage.write_error(
							 l_proc_id
							,'Ошибка обработки' 	
							,process_info.get_err_text(v_err_code, v_msg_text, v_detail, v_hint, v_context)
							,'Ошибки'
						);
					
						exit main_loop;
					end;

				end;
					   
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
 
     	call process_info.pr_helper_log(l_procedure, process_info.get_err_text(v_err_code, v_msg_text, v_detail, v_hint, v_context), l_proc_id::text);

	   	call process_manage.write_error(
			 l_proc_id
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
$procedure$
;

ALTER PROCEDURE eor.pr_eor_pdl_load(bigint, smallint, smallint) OWNER TO r_fors_db_owner;
GRANT ALL ON PROCEDURE eor.pr_eor_pdl_load(bigint, smallint, smallint) TO r_fors_db_owner;

-- =============================================================================
-- 3. ПРОЦЕДУРА eor.pr_eor_pdl_load_batch
-- =============================================================================
-- Назначение: Обработка пачки записей ПДЛ. Для каждого ИД из p_ids:
--             - ищет субъект в спецреестре ПДЛ по system_id;
--             - обновляет или создаёт запись в sr.sr_subject_pdl;
--             - проставляет ИД субъекта в таблицу загрузки;
--             - очищает буферные таблицы;
--             - продвигает запись по очереди обработки;
--             - при ошибке сохраняет её в idw_sy_workflow_error.
-- Параметры:
--   p_ids            - массив ИД записей для обработки
--   p_process_data   - rowtype с настройками процесса
--   p_process_log_id - ИД лога процесса
-- =============================================================================

CREATE OR REPLACE PROCEDURE eor.pr_eor_pdl_load_batch(
	IN p_ids text[],
	IN p_process_data process_info.process_state,
	IN p_process_log_id bigint)
LANGUAGE 'plpgsql'
    SECURITY DEFINER 
AS $BODY$
 

DECLARE
	c_workflow_id CONSTANT process_info.idw_sy_workflow_info.workflow_id%type := 225;
    c_state_id CONSTANT process_info.idw_sy_workflow_info.state_id%type := 2251;
	c_procedure constant text := 'fors_pg.eor.pr_eor_pdl_load_batch';
    l_process CONSTANT text := 'PR_EOR_PDL_LOAD_PG';
    l_sr_type_id CONSTANT bigint := 145;
	
    c RECORD;
	l_cnt bigint := 0;
    l_err_cnt bigint := 0;
    l_id bigint;
    l_sr_subject_id bigint;
    l_sr_subject_count bigint;
	l_error_sign varchar(1);
   
    l_error_sqlstate text;
    l_error_message text;
    l_error_backtrace text;
    l_error_object_id bigint;

begin
    l_cnt := 0;
    l_err_cnt := 0;
	RAISE NOTICE 'Стартуем процесс обработки батча';

	call pkg_eor_contract_load.log_level_2(
			 p_msg => 'Запуск загрузки ПДЛ'
			,p_process_log_id => p_process_log_id::text
			,p_procedure => c_procedure
			,p_proc_data => p_process_data
	);

    for c in (
		WITH source AS (
			SELECT 
				a.id,
				a.load_id,
				a.updated_at,
				a.system_id,
				UPPER(TRIM(BOTH a.full_name)) AS full_name,
				a.date_birthday,
				a.date_death,
				a.birth_place,
				a.dead,
				a.gender,
				a.position,
				a.authority,
				a.country_names,
				a.countries,
				a.sr_subject_id,
				a.err_msg
			FROM arch_ext.idw_arj_interfax_pdl_buffer a
			WHERE a.sr_subject_id = 0
				AND COALESCE(a.err_msg, '0') = CASE WHEN l_error_sign = '1' THEN '1' ELSE '0' END
				AND TRIM(BOTH a.full_name) NOT IN ('Child', 'Husb')
				AND TRIM(BOTH a.full_name) IS NOT NULL
				and a.id::text = ANY(p_ids)
				AND NOT EXISTS (
					SELECT 1 
					FROM process_info.idw_sy_workflow_error we
					WHERE we.object_id = a.id::text
						AND we.workflow_id = p_process_data.workflow_id
						AND we.state_id = p_process_data.state_id
				)
		),
		aggregated AS (
			SELECT 
				s.id,
				s.load_id,
				s.updated_at,
				s.system_id,
				s.full_name,
				CASE
					WHEN eor.is_date(s.date_birthday, 'dd.mm.yyyy') = 1 
						THEN TO_DATE(s.date_birthday, 'dd.mm.yyyy')
					WHEN eor.is_date(s.date_birthday, 'yyyy-mm-dd') = 1 
						THEN TO_DATE(s.date_birthday, 'yyyy-mm-dd')
					ELSE NULL
				END AS date_birthday,
				CASE
					WHEN eor.is_date(s.date_death, 'dd.mm.yyyy') = 1 
						THEN TO_DATE(s.date_death, 'dd.mm.yyyy')
					WHEN eor.is_date(s.date_death, 'yyyy-mm-dd') = 1 
						THEN TO_DATE(s.date_death, 'yyyy-mm-dd')
					ELSE NULL
				END AS date_death,
				s.birth_place,
				CASE WHEN UPPER(s.dead) = 'TRUE' THEN 1 ELSE 0 END AS is_dead,
				CASE 
					WHEN UPPER(s.gender) = 'M' THEN 'M'
					WHEN UPPER(s.gender) = 'F' THEN 'F'
					ELSE NULL
				END AS gender,
				s.position,
				s.authority,
				s.country_names,
				s.countries,
				COALESCE(n.c_names, '') AS c_names,
				COALESCE(t.c_translit_names, '') AS c_translit_names,
				COALESCE(cat.c_categories, '') AS c_categories,
				COALESCE(cat407.c_categories407, '') AS c_categories407,
				COALESCE(j.c_jobs, '') AS c_jobs,
				COALESCE(sl.c_sanlists, '') AS c_sanlists,
				COALESCE(san.c_sanctions, '') AS c_sanctions,
				COALESCE(cnt.c_countries, '') AS c_countries
			FROM source s
			LEFT JOIN LATERAL (
				SELECT SUBSTR(UPPER(STRING_AGG(COALESCE(sa.full_name, sa.first_name || ' ' || sa.last_name || ' ' || sa.middle_name), '; ' ORDER BY COALESCE(sa.full_name, sa.first_name || ' ' || sa.last_name || ' ' || sa.middle_name))), 1, 4000) AS c_names
				FROM arch_ext.idw_arj_pdl_names_buffer sa
				WHERE sa.load_id = s.load_id AND sa.system_id = s.system_id
			) n ON TRUE
			LEFT JOIN LATERAL (
				SELECT SUBSTR(UPPER(STRING_AGG(sa.translit_names, '; ' ORDER BY sa.translit_names)), 1, 4000) AS c_translit_names
				FROM arch_ext.idw_arj_pdl_translit_names_buffer sa
				WHERE sa.load_id = s.load_id AND sa.system_id = s.system_id
			) t ON TRUE
			LEFT JOIN LATERAL (
				SELECT SUBSTR(UPPER(STRING_AGG(r.name, '; ' ORDER BY r.name)), 1, 4000) AS c_categories
				FROM arch_ext.idw_arj_pdl_categories_buffer sa
				INNER JOIN arch_ext.idw_pdl_ref_buffer r ON r.code = sa.category_code AND r.ref_name = 'CATEGORIES'
				WHERE sa.load_id = s.load_id AND sa.system_id = s.system_id
			) cat ON TRUE
			LEFT JOIN LATERAL (
				SELECT SUBSTR(UPPER(STRING_AGG(r.name, '; ' ORDER BY r.name)), 1, 4000) AS c_categories407
				FROM arch_ext.idw_arj_pdl_category407_buffer sa
				INNER JOIN arch_ext.idw_pdl_ref_buffer r ON r.code = sa.category_code AND r.ref_name = 'CATEGORIES407'
				WHERE sa.load_id = s.load_id AND sa.system_id = s.system_id
			) cat407 ON TRUE
			LEFT JOIN LATERAL (
				SELECT SUBSTR(UPPER(STRING_AGG(sa.authority, '; ' ORDER BY sa.authority)), 1, 4000) AS c_jobs
				FROM arch_ext.idw_arj_pdl_jobs_buffer sa
				WHERE sa.load_id = s.load_id AND sa.system_id = s.system_id
			) j ON TRUE
			LEFT JOIN LATERAL (
				SELECT SUBSTR(UPPER(STRING_AGG(sa.sanlist, '; ' ORDER BY sa.sanlist)), 1, 4000) AS c_sanlists
				FROM arch_ext.idw_arj_pdl_sanlists_buffer sa
				WHERE sa.load_id = s.load_id AND sa.system_id = s.system_id
			) sl ON TRUE
			LEFT JOIN LATERAL (
				SELECT SUBSTR(UPPER(STRING_AGG(sa.sanction, '; ' ORDER BY sa.sanction)), 1, 4000) AS c_sanctions
				FROM arch_ext.idw_arj_pdl_sanctions_buffer sa
				WHERE sa.load_id = s.load_id AND sa.system_id = s.system_id
			) san ON TRUE
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
		
		<<record_block>>
		begin
			l_id := c.object_id;
			
			CALL eor.rco_helper__log(c_procedure || 'Загрузка system_id = ' || c.system_id || '  l_id = '|| l_id, c_procedure);
			
			select count(1)
			  into l_sr_subject_count
			  from sr.sr_subject_pdl dst
			  join sr.sr_subject s on s.sr_subject_id = dst.sr_subject_id
			 where dst.system_id = c.system_id
			   and s.sr_type_id = l_sr_type_id;

			if l_sr_subject_count > 0 then
				select dst.sr_subject_id
				  into STRICT l_sr_subject_id
				  from sr.sr_subject_pdl dst
				 where dst.system_id = c.system_id LIMIT 1; 

				update sr.sr_subject_pdl dst
				  set is_eor_ident_process = 0,
					  update_date = clock_timestamp(),
					  death_date = coalesce(c.date_death, dst.death_date),
					  is_death = coalesce(c.is_dead, dst.is_death),
					  birth_place = coalesce(c.birth_place, dst.birth_place),
					  gender = coalesce(c.gender, dst.gender),
					  names = coalesce(c.c_names, dst.names),
					  translit_names = coalesce(c.c_translit_names, dst.translit_names),
					  countries = coalesce(c.c_countries, dst.countries),
					  categories = coalesce(c.c_categories, dst.categories),
					  categories407 = coalesce(c.c_categories407, dst.categories407),
					  jobs = coalesce(c.c_jobs, dst.jobs),
					  sanlists = coalesce(c.c_sanlists, dst.sanlists),
					  sanctions = coalesce(c.c_sanctions, dst.sanctions),
					  position = coalesce(c.position, dst.position),
					  authority = coalesce(c.authority, dst.authority),
					  date_birthday = coalesce(c.date_birthday, dst.date_birthday),
					  full_name = coalesce(c.full_name, dst.full_name)
				where dst.sr_subject_id = l_sr_subject_id;
				
				CALL eor.rco_helper__log(c_procedure || 'Обновление system_id = ' || c.system_id || '  l_id = '|| l_id || ' l_sr_subject_id = ' || l_sr_subject_id, c_procedure);
		   else
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
					nextval('sr.sr_subject_seq'),
					to_date(c.updated_at, 'yyyy-mm-dd hh24:mi:ss" UTC"'),
					c.date_death,
					c.is_dead,
					c.birth_place,
					c.gender,
					c.c_names,
					c.c_translit_names,
					c.c_countries,
					c.c_categories,
					c.c_categories407,
					c.c_jobs,
					c.c_sanlists,
					c.c_sanctions,
					c.position,
					c.authority,
					c.system_id,
					c.date_birthday,
					c.full_name,
					0
				) returning sr_subject_id into l_sr_subject_id;
				
				CALL eor.rco_helper__log(c_procedure || 'Вставка system_id = ' || c.system_id || '  l_id = '|| l_id || ' l_sr_subject_id = ' || l_sr_subject_id, c_procedure);
		   end if;

			update arch_ext.idw_arj_interfax_pdl_load_buffer a
			   set sr_subject_id = coalesce(l_sr_subject_id, 0),
				   create_date = clock_timestamp()                   
			 where a.id = l_id and a.sr_subject_id = 0;
			
			l_cnt := l_cnt + 1;

			delete from process_info.idw_sy_workflow_error
				  where workflow_id = p_process_data.workflow_id
					and state_id = p_process_data.state_id
					and object_id = l_id::text;
					
			CALL eor.pr_eor_pdl_load_buffer_del( p_id => l_id);
			
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
			
			DELETE FROM arch_ext.idw_sy_workflow_info
			where workflow_id = c_workflow_id  and state_id = c_state_id
  		    and object_id = l_id::text;			

			CALL eor.rco_helper__log(c_procedure || 'выполнено system_id = ' || c.system_id || '  l_id = '|| l_id || ' l_sr_subject_id = ' || l_sr_subject_id, c_procedure);
		   
		exception
			when others then
				l_error_sqlstate := SQLSTATE;
				l_error_message := SQLERRM;
				GET STACKED DIAGNOSTICS   l_error_backtrace = PG_EXCEPTION_CONTEXT;
				call process_info.save_error(
					p_object_id=>l_id::text,
					p_workflow_id=>c_workflow_id,
					p_state_id=>c_state_id,
					p_sqlcode=>l_error_sqlstate,
					p_sqlerrm=>l_error_message,
					p_sqlerr_stack=>l_error_backtrace);
				
				l_err_cnt := l_err_cnt + 1;
				
				RAISE NOTICE 'Ошибка при обработке записи id=%: %', l_id, l_error_message;
		end record_block;
	end loop;

end;
$BODY$;

ALTER PROCEDURE eor.pr_eor_pdl_load_batch(text[], process_info.process_state, bigint)
    OWNER TO r_fors_db_owner;
GRANT ALL ON PROCEDURE eor.pr_eor_pdl_load_batch(text[], process_info.process_state, bigint) TO r_fors_db_owner;

-- =============================================================================
-- 4. ПРОЦЕДУРА eor.pr_eor_pdl_load_buffer
-- =============================================================================
-- Назначение: Буферизация данных ПДЛ для регламентного процесса EOR_PDL_LOAD_PG.
--             Переносит очередь обработки из arch_ext в process_info, копирует
--             основную запись и все дочерние записи из архивных таблиц в
--             буферные, помечает загрузку в idw_arj_interfax_pdl_load_buffer.
-- Параметры:
--   p_ids            - массив ИД записей для буферизации
--   p_process_log_id - ИД лога процесса
-- =============================================================================

CREATE OR REPLACE PROCEDURE eor.pr_eor_pdl_load_buffer(IN p_ids text[], IN p_process_log_id bigint)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $procedure$ 
declare
	c_workflow_id constant process_info.idw_sy_workflow_info.workflow_id%type := 225;
	c_state_id constant process_info.idw_sy_workflow_info.state_id%type := 2251;
	l_ids text[];
	c_procedure constant text := 'fors_pg.eor.pr_eor_pdl_load_buffer';
	rows_count bigint;
	v_missing_tables text[];
	
begin

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

	delete from arch_ext.idw_sy_workflow_info
	where 
			workflow_id = c_workflow_id
		and state_id = c_state_id
		and object_id in (select unnest(p_ids));

	select array_agg(a.id)
	into l_ids
	from (select unnest(p_ids) as id) a
	where not exists(
		select 'x'
		from arch_ext.idwh2_arj_contract_gov_load_buffer b
		where b.id = a.id
	);

	if coalesce(cardinality(l_ids),0) = 0 then
		return;
	end if;

    PERFORM 1 FROM information_schema.tables 
    WHERE table_schema = 'arch_ext' AND table_name = 'idw_arj_interfax_pdl';
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Основная таблица arch_ext.idw_arj_interfax_pdl не существует';
    END IF;	
    RAISE NOTICE 'Начало буферизации основной таблицы idw_arj_interfax_pdl...';
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
	
    SELECT array_agg(table_name) INTO v_missing_tables
		FROM (
			SELECT unnest(ARRAY[
				'idw_arj_interfax_pdl_buffer',
				'idw_arj_pdl_categories_buffer',
				'idw_arj_pdl_category407_buffer',
				'idw_arj_pdl_countries_buffer',
				'idw_arj_pdl_jobs_buffer',
				'idw_arj_pdl_names_buffer',
				'idw_arj_pdl_sanctions_buffer',
				'idw_arj_pdl_sanlists_buffer',
				'idw_arj_pdl_translit_names_buffer',
				'idw_arj_interfax_pdl_load_buffer'
			]) AS table_name
		) t
		WHERE NOT EXISTS (
			SELECT 1 FROM information_schema.tables 
			WHERE table_schema = 'arch_ext' AND table_name = t.table_name
		);
		
	IF array_length(v_missing_tables, 1) > 0 THEN
		RAISE EXCEPTION 'Отсутствуют буферные таблицы: %', 
			array_to_string(v_missing_tables, ', ');
	END IF;	
	RAISE NOTICE 'Начало буферизации дочерних таблиц...';
    
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

ALTER PROCEDURE eor.pr_eor_pdl_load_buffer(text[], bigint) OWNER TO r_fors_db_owner;
GRANT ALL ON PROCEDURE eor.pr_eor_pdl_load_buffer(text[], bigint) TO r_fors_db_owner;

-- =============================================================================
-- 5. ПРОЦЕДУРА eor.pr_eor_pdl_load_buffer_del
-- =============================================================================
-- Назначение: Очистка буферных таблиц ПДЛ по ИД записи. Проверяет наличие
--             ошибок и других записей в очереди; если запись единственная -
--             удаляет дочерние буферные записи по load_id/system_id, затем
--             удаляет основную запись из буфера.
-- Параметры:
--   p_id - ИД записи в arch_ext.idw_arj_interfax_pdl_buffer
-- =============================================================================

CREATE OR REPLACE PROCEDURE eor.pr_eor_pdl_load_buffer_del(IN p_id bigint)
LANGUAGE plpgsql
SECURITY DEFINER
AS $procedure$ 
DECLARE
    c_workflow_id CONSTANT process_info.idw_sy_workflow_info.workflow_id%type := 225;
    c_state_id CONSTANT process_info.idw_sy_workflow_info.state_id%type := 2251;
    l_cnt int4;
    l_system_id arch_ext.idw_arj_interfax_pdl_buffer.system_id%type;
    l_load_id arch_ext.idw_arj_interfax_pdl_buffer.load_id%type;
BEGIN
    SELECT COUNT(8)
    INTO l_cnt
    FROM process_info.idw_sy_workflow_error
    WHERE workflow_id = c_workflow_id
      AND state_id = c_state_id
      AND object_id = p_id::text;
    
    IF l_cnt > 0 THEN
        RETURN;
    END IF;

	select system_id,load_id into l_system_id,l_load_id from arch_ext.idw_arj_interfax_pdl_buffer a where id=p_id;
	
	SELECT SUM(cnt)
    INTO l_cnt
    FROM (
        SELECT COUNT(8) AS cnt
        FROM process_info.idw_sy_workflow_error
        WHERE workflow_id = c_workflow_id
          AND state_id = c_state_id
          AND object_id = p_id::text
        UNION ALL
        SELECT COUNT(8)
        FROM arch_ext.idw_sy_workflow_info
        WHERE workflow_id = c_workflow_id
          AND state_id = c_state_id
          AND object_id = p_id::text
    ) t;

    IF l_cnt = 0 THEN
        DELETE FROM arch_ext.idw_arj_pdl_categories_buffer
        WHERE load_id = l_load_id
          AND system_id = l_system_id;

        DELETE FROM arch_ext.idw_arj_pdl_category407_buffer
        WHERE load_id = l_load_id
          AND system_id = l_system_id;

        DELETE FROM arch_ext.idw_arj_pdl_countries_buffer
        WHERE load_id = l_load_id
          AND system_id = l_system_id;

        DELETE FROM arch_ext.idw_arj_pdl_jobs_buffer
        WHERE load_id = l_load_id
          AND system_id = l_system_id;

        DELETE FROM arch_ext.idw_arj_pdl_names_buffer
        WHERE load_id = l_load_id
          AND system_id = l_system_id;

        DELETE FROM arch_ext.idw_arj_pdl_sanctions_buffer
        WHERE load_id = l_load_id
          AND system_id = l_system_id;

        DELETE FROM arch_ext.idw_arj_pdl_sanlists_buffer
        WHERE load_id = l_load_id
          AND system_id = l_system_id;

        DELETE FROM arch_ext.idw_arj_pdl_translit_names_buffer
        WHERE load_id = l_load_id
          AND system_id = l_system_id;

    ELSE
        NULL;
    END IF;

    DELETE FROM arch_ext.idw_arj_interfax_pdl_buffer a
    WHERE a.id=p_id	;

END;
$procedure$;

ALTER PROCEDURE eor.pr_eor_pdl_load_buffer_del(bigint) OWNER TO r_fors_db_owner;
GRANT ALL ON PROCEDURE eor.pr_eor_pdl_load_buffer_del(bigint) TO r_fors_db_owner;

-- =============================================================================
-- 6. ТАБЛИЦА eor.tmp_eor_ident_candidate
-- =============================================================================
-- Назначение: Временная таблица для хранения кандидатов при идентификации
--             EOR для регламентного процесса EOR_PDL_IDENT.
-- Структура:
--   FIND_CANDIDATE_ID  - ИД найденного кандидата (из seq_find_candidate)
--   ETALON_REGISTRY_ID - ИД эталонного реестра
--   EOR_H_ID           - ИД EOR
--   WEIGHT             - вес/степень соответствия кандидата
-- =============================================================================

CREATE TABLE IF NOT EXISTS eor.TMP_EOR_IDENT_CANDIDATE
(
    FIND_CANDIDATE_ID NUMERIC,
    ETALON_REGISTRY_ID NUMERIC,
    EOR_H_ID NUMERIC,
    WEIGHT NUMERIC
);

COMMENT ON TABLE eor.TMP_EOR_IDENT_CANDIDATE IS 'Временная таблица для хранения кандидатов при идентификации EOR для регламентного процесса EOR_PDL_IDENT';
COMMENT ON COLUMN eor.TMP_EOR_IDENT_CANDIDATE.FIND_CANDIDATE_ID IS 'Идентификатор найденного кандидата';
COMMENT ON COLUMN eor.TMP_EOR_IDENT_CANDIDATE.ETALON_REGISTRY_ID IS 'Идентификатор эталонного реестра';
COMMENT ON COLUMN eor.TMP_EOR_IDENT_CANDIDATE.EOR_H_ID IS 'Идентификатор EOR ';
COMMENT ON COLUMN eor.TMP_EOR_IDENT_CANDIDATE.WEIGHT IS 'Вес или степень соответствия кандидата (коэффициент)';

ALTER TABLE IF EXISTS eor.tmp_eor_ident_candidate
    ADD CONSTRAINT tmp_eor_ident_candidate_pk PRIMARY KEY (etalon_registry_id, find_candidate_id);

COMMENT ON CONSTRAINT tmp_eor_ident_candidate_pk ON eor.tmp_eor_ident_candidate
    IS 'Уникальный ключ';

-- =============================================================================
-- 7. ФУНКЦИЯ eor.pr_eor_pdl_ident_find_rfl_candidate_func
-- =============================================================================
-- Назначение: Поиск кандидатов РФЛ (российских физических лиц) в ЕОР.
--             Ищет совпадения по ФИО + дате рождения (точное) и по ФИО,
--             записывает кандидатов во временную таблицу tmp_eor_ident_candidate
--             с рассчитанным весом.
-- Возвращает: ИД запуска поиска (l_find_id)
-- Параметры:
--   p_full_name  - полное имя
--   p_birth_date - дата рождения
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

    DELETE FROM eor.tmp_eor_ident_candidate;

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
-- 8. ФУНКЦИЯ eor.pr_eor_pdl_ident_find_nr_fl_candidate_func
-- =============================================================================
-- Назначение: Поиск кандидатов НР ФЛ (нерезидентов физических лиц) в ЕОР.
--             Ищет совпадения по ФИО + дате рождения (точное) и по ФИО,
--             записывает кандидатов во временную таблицу tmp_eor_ident_candidate
--             с рассчитанным весом.
-- Возвращает: ИД запуска поиска (l_find_id)
-- Параметры:
--   p_full_name  - полное имя
--   p_birth_date - дата рождения
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

    DELETE FROM eor.tmp_eor_ident_candidate;

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
-- 9. ПРОЦЕДУРА eor.pr_pdl_ident_batch
-- =============================================================================
-- Назначение: Обработка пачки записей идентификации ПДЛ. Для каждого ИД:
--             - определяет гражданство (РФЛ/НР ФЛ);
--             - ищет кандидатов через соответствующие функции;
--             - при однозначном совпадении проставляет etalon_registry_id
--               и/или eor_subject_mention_id в eor.sr_subject;
--             - обновляет очередь обработки;
--             - при ошибке сохраняет её в idw_sy_workflow_error.
-- Параметры:
--   p_ids            - массив ИД записей для обработки
--   p_process_data   - rowtype с настройками процесса
--   p_process_log_id - ИД лога процесса
-- =============================================================================

CREATE OR REPLACE PROCEDURE eor.pr_pdl_ident_batch(
	IN p_ids text[],
	IN p_process_data process_info.process_state,
	IN p_process_log_id bigint)
LANGUAGE 'plpgsql'
AS $BODY$

DECLARE
    c_workflow_id CONSTANT process_info.idw_sy_workflow_info.workflow_id%type := 225;
    c_state_id CONSTANT process_info.idw_sy_workflow_info.state_id%type := 2252;
	c_procedure constant text := 'fors_pg.eor.pr_pdl_ident_batch';
    c_process CONSTANT text := 'PR_EOR_PDL_IDENT';
    c_sr_type_id CONSTANT INTEGER := 145;
	c_source_id  CONSTANT INTEGER := 2070;
    
	c record;
    l_sr_subject_count         INTEGER;
    l_sr_subject_id            INTEGER;
    l_etalon_registry_id       INTEGER;
    l_is_rfl                   INTEGER;
    l_eor_subject_mention_id   INTEGER;
    l_sr_event_id              INTEGER;
    l_id                       TEXT;
	l_rfl_attr   eor.idw_mr_rfl_attr_src%rowtype;
   	l_ifl_attr   eor.idw_mr_ifl_attr_src%rowtype;
	
	l_cnt INTEGER := 0;
	l_err_cnt INTEGER := 0;
	
BEGIN

    FOR c IN (
        SELECT p.date_birthday,
               p.full_name,
               p.sr_subject_id,
               p.system_id,
               p.countries,
               bf.id AS rid,
               p.update_date
          FROM sr.sr_subject_pdl p
		  join (select * from arch_ext.idw_arj_interfax_pdl_load_buffer where id = ANY(p_ids::bigint[])) bf on bf.sr_subject_id = p.sr_subject_id
          LEFT JOIN eor.sr_subject s ON s.sr_subject_id = p.sr_subject_id
         WHERE p.is_eor_ident_process = 0
           AND s.etalon_registry_id IS NULL
    ) LOOP

        BEGIN
			
            l_id := c.sr_subject_id::TEXT;
            RAISE DEBUG '% загрузка system_id = %  l_id = %', c_process, c.system_id, l_id;

            l_etalon_registry_id := NULL;
            l_sr_subject_id := NULL;
			l_eor_subject_mention_id := NULL;
			l_is_rfl := NULL; 
			
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

            IF UPPER(c.countries) LIKE '%РОССИЯ%' OR c.countries IS NULL THEN
                l_is_rfl := 1;
            ELSE
                l_is_rfl := 0;
            END IF;

            IF l_is_rfl = 1 AND c.full_name IS NOT NULL THEN
                PERFORM eor.pr_eor_pdl_ident_find_rfl_candidate_func(c.full_name, c.date_birthday::date);
				IF EXISTS (SELECT 1 FROM eor.tmp_eor_ident_candidate) THEN

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

            IF l_is_rfl = 0 AND c.full_name IS NOT NULL THEN
                PERFORM eor.pr_eor_pdl_ident_find_nr_fl_candidate_func(c.full_name, c.date_birthday::date);

                IF EXISTS (SELECT 1 FROM eor.tmp_eor_ident_candidate) THEN
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
                l_err_cnt := l_err_cnt + 1;
        END;
    END LOOP;

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        RAISE;
END;
$BODY$;

ALTER PROCEDURE eor.pr_pdl_ident_batch(text[], process_info.process_state, bigint)
    OWNER TO r_fors_db_owner;
GRANT ALL ON PROCEDURE eor.pr_pdl_ident_batch(text[], process_info.process_state, bigint) TO r_fors_db_owner;

-- =============================================================================
-- 10. ПРОЦЕДУРА eor.pr_eor_pdl_ident
-- =============================================================================
-- Назначение: Регламентный процесс "ЕОР: идентификация ПДЛ" (PR_EOR_PDL_IDENT).
--             Управляет процессом идентификации: запускает процесс, читает
--             настройки, обрабатывает пачки записей через pr_pdl_ident_batch,
--             обрабатывает ошибки, завершает процесс.
-- Параметры:
--   p_process_log_id - ИД лога процесса (NULL для старта нового процесса)
--   p_cnt_flow       - количество потоков (по умолчанию 1)
--   p_num_flow       - номер текущего потока (по умолчанию 1)
-- =============================================================================

CREATE OR REPLACE PROCEDURE eor.pr_eor_pdl_ident(
	IN p_process_log_id bigint,
	IN p_cnt_flow smallint DEFAULT NULL::smallint,
	IN p_num_flow smallint DEFAULT NULL::smallint)
LANGUAGE 'plpgsql'
    SECURITY DEFINER 
AS $BODY$

 
declare
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
			 l_proc_id
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

	case
	when 
			l_cnt_flow < 1
		or  l_cnt_flow > 100
		or  l_num_flow < 1
		or  l_num_flow > l_cnt_flow
	then
		
		call process_info.pr_helper_log(l_procedure, 'Неверное значение количества потоков\текущий поток [' || l_cnt_flow::text || '''' || l_num_flow || ']! Выход.', l_proc_id::text); 
        
		call process_manage.write_error(
			 l_proc_id
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
					 l_proc_id
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
				 
				     	call process_info.pr_helper_log(l_procedure, process_info.get_err_text(v_err_code, v_msg_text, v_detail, v_hint, v_context), l_proc_id::text);
				
					   	call process_manage.write_error(
							 l_proc_id
							,'Ошибка обработки' 	
							,process_info.get_err_text(v_err_code, v_msg_text, v_detail, v_hint, v_context)
							,'Ошибки'
						);
					
						exit main_loop;

					end;

				end;
					   
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
 
     	call process_info.pr_helper_log(l_procedure, process_info.get_err_text(v_err_code, v_msg_text, v_detail, v_hint, v_context), l_proc_id::text);

	   	call process_manage.write_error(
			 l_proc_id
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
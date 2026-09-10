-- DROP PROCEDURE eor.pr_eor_ba_contract_ins_load(int8, int2, int2);

CREATE OR REPLACE PROCEDURE eor.pr_eor_pdl_load(IN p_process_log_id bigint, IN p_cnt_flow smallint DEFAULT NULL::smallint, IN p_num_flow smallint DEFAULT NULL::smallint)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $procedure$ 
declare
	-- Регламентеый процесс "ЕОР: загрузка контрактов из архивного в буферный слой" в PG" (аналог ORION_38)
	-- 44.EXD.2026.

	-- использовать параметры p_cnt_flow, p_null_flow по default!!!
 
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
			 l_proc_id -- p_process_log_id 	-- ИД процесса
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
					from arch_ext.idw_sy_workflow_info wi
					inner join arch_ext.idw_arj_interfax_pdl a on ---------- TODO адоптация 
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
					inner join arch_ext.idw_arj_interfax_pdl_buffer a on 
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
$procedure$
;

-- Permissions

ALTER PROCEDURE eor.pr_eor_ba_contract_ins_load(int8, int2, int2) OWNER TO r_fors_db_owner;
GRANT ALL ON PROCEDURE eor.pr_eor_ba_contract_ins_load(int8, int2, int2) TO r_fors_db_owner;

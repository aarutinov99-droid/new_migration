-- DROP PROCEDURE eor.pr_eor_ba_contract_ins_load_batch(_text, process_info.process_state, int8);

CREATE OR REPLACE PROCEDURE eor.pr_eor_ba_contract_ins_load_batch(IN p_ids text[], IN p_process_data process_info.process_state, IN p_process_log_id bigint)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $procedure$ 
declare
	-- Регламентеый процесс "ЕОР: загрузка контрактов из архивного в буферный слой" в PG" (аналог ORION_38)
	-- 44.EXD.2026.
	arj_contract record;
	arj_supplier record;
	r_arj_supplier record;
	arj_product record;
	arj_budgetary record;
	arj_extrabudgetary record;
	c_procedure constant text := 'fors_pg.eor.pr_eor_ba_contract_ins_load_batch';
	c_id_source constant eor.idw_mr_subject_mention.source_id%type := 28; -- eor.idw_sr_data_kind "Муниципальные и федеральные контракты (zakupki.gov.ru)"
	c_source_etalon_id constant eor.idw_mr_subject_mention.source_etalon_id%type:= 0; -- eor.idw_sr_eor_source "Не эталонный источник"
	l_id_obj text;
	l_noerror int2;
	l_id_extrabudgetary arch_ext.idwh2_arj_finances_gov_buffer.id_extrabudgetary%type;
	l_id_extrabudget arch_ext.idwh2_arj_finances_gov_buffer.id_extrabudget%type;
	l_id_budgetary arch_ext.idwh2_arj_finances_gov_buffer.id_budgetary%type;
	l_id_budget arch_ext.idwh2_arj_finances_gov_buffer.id_budget%type;
	l_id_budgetlevel arch_ext.idwh2_arj_finances_gov_buffer.id_budgetlevel%type;
	l_budget_code arch_ext.idwh2_arj_budget_gov_buffer.code%type;
	l_budget_name arch_ext.idwh2_arj_budget_gov_buffer.name%type;
	l_budgetlevel_code arch_ext.idwh2_arj_budgetlevel_gov_buffer.code%type;
	l_id_ba_budget eor.eor_ba_budget.id_ba_budget%type;
	l_extrabudget_code arch_ext.idwh2_arj_extrabudget_gov_buffer.code%type;
	l_extrabudget_name arch_ext.idwh2_arj_extrabudget_gov_buffer.name%type;
	l_id_nsi_sr_list eor.external_dict_link.id_nsi_sr_list%type;
	l_currency_code_from_source arch_ext.idwh2_arj_currency_gov_buffer.code%type;
	l_currency_name_from_source arch_ext.idwh2_arj_currency_gov_buffer.name%type;
	l_currency_rate arch_ext.idwh2_arj_currency_gov_buffer.currency_rate%type;
	l_currency_raiting arch_ext.idwh2_arj_currency_gov_buffer.currency_raiting%type;
	l_id_currency eor.idw_dr_currency.code%type;
	l_sngl_code arch_ext.idwh2_arj_singlecust_rsn_gov_buffer.id%type;
	l_sngl_name arch_ext.idwh2_arj_singlecust_rsn_gov_buffer.name%type;
	l_id_order arch_ext.idwh2_arj_foundation_gov_buffer.id_order%type;
	l_placing arch_ext.idwh2_arj_order_gov_buffer.placing%type;
	l_mod_type arch_ext.idwh2_arj_modification_gov_buffer.type%type;
	l_mod_desc arch_ext.idwh2_arj_modification_gov_buffer.description%type;
	l_attr_contract eor.eor_ba_contract%rowtype;
	l_id_ba_contract eor.eor_ba_contract.id_ba_contract%type;
	c_attr_ifl_init constant eor.idw_mr_ifl_attr_src%rowtype;
	c_attr_rul_init constant eor.idw_mr_rul_attr_src%rowtype;
	c_attr_iul_init constant eor.idw_mr_iul_attr_src%rowtype;
	c_attr_rfl_init constant eor.idw_mr_rfl_attr_src%rowtype;
	l_attr_rfl eor.idw_mr_rfl_attr_src%rowtype;
	l_attr_ifl eor.idw_mr_ifl_attr_src%rowtype;
	l_attr_rul eor.idw_mr_rul_attr_src%rowtype;
	l_attr_iul eor.idw_mr_iul_attr_src%rowtype;
	l_id_mention eor.idw_mr_subject_mention.eor_subject_mention_id%type;
	l_address_mention_id eor.idw_mr_address_mention.eor_address_mention_id%type;
	l_subj_addr_mention_id eor.idw_mr_subj_address_mention.eor_subj_address_mention_id%type;
	l_phone_mention_id eor.idw_mr_telephone_mention.eor_telephone_mention_id%type;
	l_subj_phone_mention_id eor.idw_mr_subj_telephone_mention.eor_subj_telephone_mention_id%type;
	l_addr_attr eor.idw_mr_address_attr_src%rowtype;
	l_phone_attr eor.idw_mr_telephone_attr_src%rowtype;
	l_fullname eor.idw_mr_rul_attr_src.name_full%type;
	l_inn eor.idw_mr_rul_attr_src.inn%type;
	l_kpp eor.idw_mr_rul_attr_src.kpp%type;
	l_customer_code eor.eor_ba_contract_member_link.customer_code%type;
	l_cust_h_id eor.idw_mr_subject_mention.external_id%type;
	l_okei_code eor.external_dict_link.id_from_source%type;
	l_priority process_info.idw_sy_workflow_info.priority%type;
	l_sup_type int2; -- 2 - РЮЛ, 3 - РФЛ, 5 - ИЮЛ, 6 ИФЛ, 0 - получен признак "Информация не будет размещена на официальном сайте ЕИС в соответствии с ч. 5 ст. 103 Федерального закона № 44-ФЗ"
	c_raise_notice constant boolean := true;
	
begin autonomous
	
	call pkg_eor_contract_load.log_level_2(
			 p_msg => '01. Запуск курсора "Контракты"'
			,p_process_log_id => p_process_log_id::text
			,p_procedure => c_procedure
			,p_proc_data => p_process_data
	);

	l_priority := p_process_data.last_id_2; -- В этом поле хранится приоритет!!! Чем больше, тем выше, в первую очередь.

	for arj_contract in (
		select
			 iac.id_contract as l_id_contract
			,iac.number_ as contract_number
			,iac.regnum as registry_contract_number
			,to_date(substr(iac.signdate, 1, 10), 'yyyy-mm-dd') as contract_date
			,iac.price as price
			,iac.currentcontractstage as contract_status_code
			,iac.id::text as id_from_source
			,iac.actual_date
			,iac.id_contract::text || '.' || iac.load_id::text as id_from_arj
			,iac.href as url
			,iac.load_id
			,1 as cust_id_member_role
			,iac.fz
			,iac.versionnumber
			----------------------
            ,iac.id_finances
			,iac.id_execution
			,iac.id_currency
			,iac.id_pricechangereason
			,iac.id_singlecustomerreason
			,iac.id_foundation
			,iac.id_modification
			,iac.id_customer
			,iac.id_suppliers
			,iac.id_products
			,replace(iac.schemeversion, ',', '.') schemeversion
			,iac.price_currency
			,iac.defensecontractnumber
            -------------------------- 30.09.2020
            ,to_date(replace(substr(iac.publishdate, 1, 19),'T',' '), 'yyyy-mm-dd hh24:mi:ss') as publishdate
            ,to_date(replace(substr(iac.protocoldate, 1, 19),'T',' '), 'yyyy-mm-dd hh24:mi:ss') as protocoldate
            ,iac.bsupp_contr_reqinfo
            ,iac.contract_subject
            ,iac.priceinfo_pricetype
            ,iac.priceinfo_pricevat
            ,iac.subcontractors_pricevaluerur
            ,iac.subcontractors_suminpercents
            ,iac.enf_ca_amountrur
            ,to_date(replace(substr(iac.qgi_fromdate, 1, 19),'T',' '), 'yyyy-mm-dd hh24:mi:ss') as qgi_fromdate
            ,to_date(replace(substr(iac.qgi_todate, 1, 19),'T',' '), 'yyyy-mm-dd hh24:mi:ss') as qgi_todate
            ,iac.qgi_otherperiodtext
            ,iac.qgi_warrantyreqstext
            ,iac.st14_npainfo
            ,iac.st14_requirementtype
		from arch_ext.idwh2_arj_contract_gov_buffer iac
		where 
				(iac.id_contract, iac.load_id) in (
					select
						 (regexp_substr(id,'[^.]+',1,1))::int8 
						,(regexp_substr(id,'[^.]+',1,2))::int8
					from (
						select unnest(p_ids) as id
					)
				)
		for update skip locked
	)
	loop

		begin

			l_id_obj := arj_contract.id_from_arj;
			
			call pkg_eor_contract_load.log_level_2(
				 p_msg => '02. Начало обработки l_id_obj:=[' || l_id_obj || ']'
				,p_process_log_id => p_process_log_id::text
				,p_procedure => c_procedure
				,p_proc_data => p_process_data
			);

			--считаем что участники установлены верно
			l_noerror := 1::int2;

			case
			when 
				coalesce(arj_contract.schemeversion, '1.0') in (
					'1.0', '1', '4.1', '4.2', '4.3',
					'4.3.100', '4.4', '4.4.2', '4.5', '4.6'
				)
			then 
				
				call pkg_eor_contract_load.log_level_2(
					 p_msg => '03. Проверка участников контракта'
					,p_process_log_id => p_process_log_id::text
					,p_procedure => c_procedure
					,p_proc_data => p_process_data
				);

                for arj_supplier in (
					select
                		 2::int4 as id_member_role
						,c.id_supplier as id_from_source
						,c.participanttype
						,c.organizationname as name
						,c.inn
						,c.kpp
						,c.postaddress as pocht_adres
						,c.factualaddress
						,c.contactphone as phone
						,d.lastname
						,d.firstname
						,d.middlename
						,e.countrycode
						,c_id_source::text || c.load_id::text || c.id_supplier::text as external_h_id
            		from arch_ext.idwh2_arj_suppliers_gov_buffer b
             		inner join arch_ext.idwh2_arj_supplier_gov_buffer c on 
							b.id_supplier = c.id_supplier 
						and b.load_id = c.load_id
             		left join arch_ext.idwh2_arj_contactinfo_gov_buffer d on 
							c.id_contactinfo = d.id_contactinfo 
						and c.load_id = d.load_id
             		left join arch_ext.idwh2_arj_country_gov_buffer e on 
							c.id_country = e.id_country 
						and c.load_id = e.load_id
            		where 
							b.id_suppliers = arj_contract.id_suppliers 
						and b.load_id = arj_contract.load_id
				)
                loop
                
                    case 
                    --рфл
                    when upper(arj_supplier.participanttype) = upper('P') 
                    then
                        case
						when  pkg_norm.like_inn12(trim(arj_supplier.inn), 0) = 0 
                        then
                            l_noerror := 0;
                            exit;
						else null;
                        end case;
                    --ИФЛ
                    when upper(arj_supplier.participanttype) = upper('PF') 
                    then
                        case
						when pkg_norm.like_inn12(trim(arj_supplier.inn), 0) = 0 
						then
                            l_noerror := 0;
                            exit;
						else null;
                        end case;
                    --РЮЛ
                    when upper(arj_supplier.participanttype) = upper('U') 
                    then
                        case
						when pkg_norm.like_inn10(trim(arj_supplier.inn), 0) = 0 
                        then
                            l_noerror := 0;
                            exit;
						else null;
                        end case;
                    --ИЮЛ
                    when upper(arj_supplier.participanttype) = upper('UF') 
                    then
                        case
						when pkg_norm.like_inn10(trim(arj_supplier.inn), 0) = 0 
                        then
                            l_noerror := 0;
                            exit;
						else null;
                        end case;
                    else

						call process_info.save_error(
							 p_object_id => arj_contract.id_from_arj
							,p_workflow_id => p_process_data.workflow_id
							,p_state_id => p_process_data.state_id
							,p_sqlcode => '-20003'
							,p_sqlerrm => 'Неизвестный тип исполнителя'
							,p_sqlerr_stack => 'id_contract := [' || arj_contract.l_id_contract::text || '], load_id := [' || arj_contract.load_id::text || ']'
						);
		
		                update arch_ext.idwh2_arj_contract_gov_buffer set 
		                    is_proceeded = 2
		                where 
		                        id_contract = arj_contract.l_id_contract 
		                    and load_id = arj_contract.load_id
		                ;
		
		                continue;

                    end case;

                end loop;

			when 
				arj_contract.schemeversion in (
					'5', '5.0', '5.1', '5.2', '6', 
					'6.0', '6.1', '6.2', '6.2.100', '6.3', 
					'6.4', '7', '7.0', '7.1', '7.2', 
					'7.3', '7.4', '7.5', '8', '8.0', 
					'8.1', '8.2', '8.3', '8.4', '8.5',
					'9', '9.0', '9.1', '9.2', '9.3', 
					'9.4', '9.5', '10', '10.0', '10.1', 
					'10.2', '10.3', '10.4', '10.5', '11',
					'11.0', '11.1', '11.2', '11.3', '11.4', 
					'11.5', '12', '12.0', '12.1', '12.2', 
					'12.3', '12.4', '12.5', '13.0', '13.1', 
					'13.2', '13.3', '14.0', '14.1' , '14.2', 
					'14.3', '15.0', '15.1', '15.2', '15.3', 
					'16.0'
				)
                or arj_contract.schemeversion like '8.2%'
   				or arj_contract.schemeversion like '8.3%'
				or arj_contract.schemeversion like '8.4%'
				or arj_contract.schemeversion like '8.5%'
				or arj_contract.schemeversion like '9.2%'
				or arj_contract.schemeversion like '9.3%'
				or arj_contract.schemeversion like '9.4%'
				or arj_contract.schemeversion like '9.5%'
				or arj_contract.schemeversion like '10.2%'
				or arj_contract.schemeversion like '10.3%'
				or arj_contract.schemeversion like '10.4%'
				or arj_contract.schemeversion like '10.5%'
				or arj_contract.schemeversion like '11.2%'
				or arj_contract.schemeversion like '11.3%'
				or arj_contract.schemeversion like '11.4%'
				or arj_contract.schemeversion like '11.5%'
				or arj_contract.schemeversion like '12.2%'
				or arj_contract.schemeversion like '12.3%'
				or arj_contract.schemeversion like '12.4%'
				or arj_contract.schemeversion like '12.5%'
				or arj_contract.schemeversion like '13.0%'
				or arj_contract.schemeversion like '13.1%'
				or arj_contract.schemeversion like '13.2%'
				or arj_contract.schemeversion like '13.3%'
				or arj_contract.schemeversion like '14.0%'
				or arj_contract.schemeversion like '14.1%'
				or arj_contract.schemeversion like '14.2%'
				or arj_contract.schemeversion like '14.3%'
				or arj_contract.schemeversion like '15.0%'
				or arj_contract.schemeversion like '15.1%'
				or arj_contract.schemeversion like '15.2%'
				or arj_contract.schemeversion like '15.3%'
				or arj_contract.schemeversion like '16.0%'
			then 

				-- Формат представления сведений об исполнителе с 5.0 следующий
                -- Набор атрибутов зависит от типа исполнителя
                -- Исполнители лежат в таблицах:
                -- IDWH2_ARJ_SUP_UL_GOV - РЮЛ
                -- IDWH2_ARJ_SUP_FL_GOV - РФЛ
                -- IDWH2_ARJ_SUP_ULNR_GOV - ИЮЛ
                -- IDWH2_ARJ_SUP_FLNR_GOV - ИФЛ
				
				call pkg_eor_contract_load.log_level_2(
					 p_msg => '04. Начало проверки участников, id_contract:=[' || arj_contract.l_id_contract::text || '], load_id:=[' || arj_contract.load_id::text || ']'
					,p_process_log_id => p_process_log_id::text
					,p_procedure => c_procedure
					,p_proc_data => p_process_data
				);

                declare
                    l_cnt_sup int4;
                begin

                    -- проверяем признак "Информация не будет размещена на официальном сайте ЕИС в соответствии с ч. 5 ст. 103 Федерального закона № 44-ФЗ"
                    select count(8) 
					into l_cnt_sup
                    from arch_ext.idwh2_arj_contract_gov_buffer
                    where
                            load_id = arj_contract.load_id 
                        and id_contract = arj_contract.l_id_contract 
                        and coalesce(is_not_published_suppliers,true)
                    ;

                    case
					when l_cnt_sup = 1 
					then l_sup_type := 0;
					else null; 
                    end case;

                    case
					when l_cnt_sup = 0 
					then
                        
						-- ищем в РЮЛ
                        select count(8) 
						into l_cnt_sup
                        from arch_ext.idwh2_arj_sup_ul_gov_buffer u
                        where 
                                u.load_id = arj_contract.load_id
                            and u.id_contract = arj_contract.l_id_contract
                        ;
						
						call pkg_eor_contract_load.log_level_2(
							 p_msg => '04.01. в РЮЛ, l_cnt_sup=[' || l_cnt_sup::text || ']'
							,p_process_log_id => p_process_log_id::text
							,p_procedure => c_procedure
							,p_proc_data => p_process_data
						);

                        case
						when l_cnt_sup = 0 
						then

                            -- ищем в РФЛ
                            select count(8) 
							into l_cnt_sup
                            from arch_ext.idwh2_arj_sup_fl_gov_buffer f
                            where 
                                    f.load_id = arj_contract.load_id
                                and f.id_contract = arj_contract.l_id_contract
                            ;
							
							call pkg_eor_contract_load.log_level_2(
								 p_msg => '04.02. в РФЛ, l_cnt_sup=[' || l_cnt_sup::text || ']'
								,p_process_log_id => p_process_log_id::text
								,p_procedure => c_procedure
								,p_proc_data => p_process_data
							);

                            case
							when l_cnt_sup = 0 
							then

                                -- ищем в ИЮЛ
                                select count(8) 
								into l_cnt_sup
                                from arch_ext.idwh2_arj_sup_ulnr_gov_buffer u
                                where 
                                        u.load_id = arj_contract.load_id
                                    and u.id_contract = arj_contract.l_id_contract
                                ;
								
								call pkg_eor_contract_load.log_level_2(
									 p_msg => '04.03. в ИЮЛ, l_cnt_sup=[' || l_cnt_sup::text || ']'
									,p_process_log_id => p_process_log_id::text
									,p_procedure => c_procedure
									,p_proc_data => p_process_data
								);

                                case
								when l_cnt_sup = 0 
								then

                                    -- Ищем в ИФЛ
                                    select count(8) 
									into l_cnt_sup
                                    from arch_ext.idwh2_arj_sup_flnr_gov_buffer f
                                    where 
                                            f.load_id = arj_contract.load_id
                                        and f.id_contract = arj_contract.l_id_contract
                                    ;
									
									call pkg_eor_contract_load.log_level_2(
										 p_msg => '04.05. в ИФЛ, l_cnt_sup=[' || l_cnt_sup::text || ']'
										,p_process_log_id => p_process_log_id::text
										,p_procedure => c_procedure
										,p_proc_data => p_process_data
									);

                                    case
									when l_cnt_sup > 0 
									then l_sup_type := 6;
									else null;
                                    end case;
                                
                                else l_sup_type := 5;
                                end case;

                            else l_sup_type := 3;
                            end case;

                        else 
                        	-- РЮЛ
                            l_sup_type := 2;
                        end case;
                
					else null;
                    end case;

                    case
					when l_cnt_sup = 0 
					then l_noerror := 0;
					else null;
                    end case;
            
                end;

			else
				
				call pkg_eor_contract_load.log_level_2(
					 p_msg => '04.05. Не определена версия формата'
					,p_process_log_id => p_process_log_id::text
					,p_procedure => c_procedure
					,p_proc_data => p_process_data
				);

			end case;
			
			call pkg_eor_contract_load.log_level_2(
				 p_msg => '05. Проверка участников контракта завершена'
				,p_process_log_id => p_process_log_id::text
				,p_procedure => c_procedure
				,p_proc_data => p_process_data
			);		

			case
			when 
                
				l_noerror = 0 
                or
                (
                 		arj_contract.id_suppliers is null 
                	and arj_contract.schemeversion in (
						'1.0', '1', '4.1', '4.2', '4.3', '4.3.100', '4.4', '4.4.2', '4.5', '4.6'
					)
				)

            then	

				call process_info.save_error(
					 p_object_id => arj_contract.id_from_arj
					,p_workflow_id => p_process_data.workflow_id
					,p_state_id => p_process_data.state_id
					,p_sqlcode => '-100500'
					,p_sqlerrm => 'Неверные типы участников контракта. Нет данных о поставщиках (id_suppliers)'
					,p_sqlerr_stack => 'id_contract := [' || arj_contract.l_id_contract::text || '], load_id := [' || arj_contract.load_id::text || ']'
				);

                update arch_ext.idwh2_arj_contract_gov_buffer set 
                    is_proceeded = 2
                where 
                        id_contract = arj_contract.l_id_contract 
                    and load_id = arj_contract.load_id
                ;

                continue;

			else null;
			end case;
			
			call pkg_eor_contract_load.log_level_2(
				 p_msg => '06. Типы участников контракта указаны верно'
				,p_process_log_id => p_process_log_id::text
				,p_procedure => c_procedure
				,p_proc_data => p_process_data
			);	

            --определение id_ba_budget (Выделить в функцию)
            l_id_ba_budget := null;
            l_id_budgetlevel := null;
            l_id_budget := null;
            l_budget_code := null;
			l_currency_code_from_source := 'RUB'; --по умолчанию считаем, что валюта контракта Российски рубль
			l_id_currency := null;
            l_id_extrabudget := null;
            l_extrabudget_code := null;
			l_sngl_code := null;
			l_id_order := null;
			l_placing := null;
            l_budgetlevel_code := null;
			l_mod_type := null;
			l_currency_rate := null;
			l_currency_raiting := null;
			
			call pkg_eor_contract_load.log_level_2(
				 p_msg => '07. Вставка бюджета контракта'
				,p_process_log_id => p_process_log_id::text
				,p_procedure => c_procedure
				,p_proc_data => p_process_data
			);	

			case
			when arj_contract.id_finances is not null 
            then
                    
                select id_extrabudgetary, id_extrabudget, id_budgetary, id_budget, id_budgetlevel 
                into strict l_id_extrabudgetary, l_id_extrabudget, l_id_budgetary, l_id_budget, l_id_budgetlevel
                from arch_ext.idwh2_arj_finances_gov_buffer
                where 
                        id_finances = arj_contract.id_finances 
                    and load_id = arj_contract.load_id
                ;

                case
				when l_id_budget is not null 
                then
                
                    select code, name 
                    into strict l_budget_code, l_budget_name
                    from arch_ext.idwh2_arj_budget_gov_buffer
                    where 
                            id_budget = l_id_budget 
                        and load_id = arj_contract.load_id
                    ;

                    case
					when l_id_budgetlevel is not null 
                    then
                    
                        select code 
                        into strict l_budgetlevel_code
                        from arch_ext.idwh2_arj_budgetlevel_gov_buffer
                        where 
                                id_budgetlevel = l_id_budgetlevel 
                            and load_id = arj_contract.load_id
                        ;
                        
					else null;
					end case;

                    case
					when l_budget_code is not null 
                    then
                    
                        begin
                            
							--Образовались дубли в EOR.EOR_BA_BUDGET, временно поставим выбор первой строки
                            select t.id_ba_budget
                            into strict l_id_ba_budget
                            from (
                                select 
									 id_ba_budget
									,row_number() over(
										partition by id_from_source, id_source, budget_type_code 
										order by id_ba_budget) as rn
                                from eor.eor_ba_budget
                                where 
                                        id_from_source = l_budget_code::int4 
                                    and id_source = 28
                                    and (
                                        budget_type_code = l_budgetlevel_code 
                                        or (
                                                budget_type_code is null 
                                            and l_budgetlevel_code is null
                                            )
                                    )
                            ) t
                            where t.rn = 1;
                            
                        exception
                        when no_data_found 
                        then
                        
                            --проверка на существование кода в справочнике (выделить в проведуру)
                            case
							when l_budgetlevel_code is not null 
                            then
                                	
								l_id_nsi_sr_list := 162;
								
                                call pkg_eor_contract_load.check_external_dict_link_prc(
									 p_code => l_budgetlevel_code
									,p_id_source => c_id_source
									,p_id_nsi_sr_list => l_id_nsi_sr_list
									,p_name => null::text
								);

                            else null;
							end case;

                            insert into eor.eor_ba_budget(budget_name, id_source, id_from_source, budget_type_code)
                            values(l_budget_name, c_id_source, l_budget_code::int4, l_budgetlevel_code)
                            returning id_ba_budget into l_id_ba_budget;
                            
                        end;
                        
                    else null;
					end case;
                    
                else null;
				end case;

                case
				when l_id_extrabudget is not null 
                then
                
                    select code, name 
                    into strict l_extrabudget_code, l_extrabudget_name
                    from arch_ext.idwh2_arj_extrabudget_gov_buffer
                    where 
                            id_extrabudget = l_id_extrabudget 
                        and load_id = arj_contract.load_id
                    ;

                    case
					when l_extrabudget_code is not null 
                    then
                    
                        l_id_nsi_sr_list := 181;
						
                        call pkg_eor_contract_load.check_external_dict_link_prc(
							 p_code => l_extrabudget_code::text
							,p_id_source => c_id_source
							,p_id_nsi_sr_list => l_id_nsi_sr_list
							,p_name => l_extrabudget_name
						);
                        
					else null;
					end case;
                    
                else null;
				end case;
                
            else null;
			end case;

			case
			when arj_contract.id_currency is not null 
            then
            
                select coalesce(code, 'RUB'),name,currency_rate,currency_raiting
                into strict l_currency_code_from_source,l_currency_name_from_source,l_currency_rate,l_currency_raiting
                from arch_ext.idwh2_arj_currency_gov_buffer
                where 
                        id_currency = arj_contract.id_currency 
                    and load_id = arj_contract.load_id
                ;
                
            else null;
			end case;

            select code 
            into l_id_currency
            from eor.idw_dr_currency
            where 
                    code_a1 = l_currency_code_from_source 
                and is_actual = 1
            ;

            l_id_nsi_sr_list := 68;
			
			call pkg_eor_contract_load.check_external_dict_link_prc(
				 p_code => l_id_currency
				,p_id_source => c_id_source
				,p_id_nsi_sr_list => l_id_nsi_sr_list
				,p_name => l_currency_name_from_source
			);

            case
			when arj_contract.id_singlecustomerreason is not null 
            then
            
                select id, name 
                into strict l_sngl_code, l_sngl_name
                from arch_ext.idwh2_arj_singlecust_rsn_gov_buffer
                where 
                        id_singlecustomerreason = arj_contract.id_singlecustomerreason 
                    and load_id = arj_contract.load_id
                ;

                case
				when l_sngl_code is not null 
                then
                
                    l_id_nsi_sr_list := 248;
					
					call pkg_eor_contract_load.check_external_dict_link_prc(
						 p_code => l_sngl_code::text
						,p_id_source => c_id_source
						,p_id_nsi_sr_list => l_id_nsi_sr_list
						,p_name => l_sngl_name
					);

				else null;
				end case;

			else null;
			end case;

            case
			when arj_contract.id_foundation is not null 
            then
            
                select id_order 
                into strict l_id_order
                from arch_ext.idwh2_arj_foundation_gov_buffer
                where 
                        id_foundation = arj_contract.id_foundation 
                    and load_id = arj_contract.load_id
                ;

                case
				when l_id_order is not null 
                then
                
                    select "placing" 
                    into strict l_placing
                    from arch_ext.idwh2_arj_order_gov_buffer
                    where 
                            id_order = l_id_order 
                        and load_id = arj_contract.load_id
                    ;

                    case
					when l_placing is not null 
                    then
                    
                        l_id_nsi_sr_list := 249;
						
						call pkg_eor_contract_load.check_external_dict_link_prc(
							 p_code => l_placing
							,p_id_source => c_id_source
							,p_id_nsi_sr_list => l_id_nsi_sr_list
							,p_name => null::text
						);

					else null;
					end case;

				else null;
				end case;

			else null;
			end case;

            case
			when arj_contract.id_modification is not null 
            then
            
                select type, description 
                into strict l_mod_type, l_mod_desc
                from arch_ext.idwh2_arj_modification_gov_buffer
                where 
                        id_modification = arj_contract.id_modification 
                    and load_id = arj_contract.load_id
                ;

                case
				when l_mod_type is not null 
                then
                
                    l_id_nsi_sr_list := 250;
					
					call pkg_eor_contract_load.check_external_dict_link_prc(
						 p_code => l_mod_type
						,p_id_source => c_id_source
						,p_id_nsi_sr_list => l_id_nsi_sr_list
						,p_name => l_mod_desc
					);

				else null;
				end case;

			else null;
			end case;

            case
			when arj_contract.fz is not null 
            then
            
                l_id_nsi_sr_list := 251;
				
				call pkg_eor_contract_load.check_external_dict_link_prc(
					 p_code => arj_contract.fz::text
					,p_id_source => c_id_source
					,p_id_nsi_sr_list => l_id_nsi_sr_list
					,p_name => null::text
				);

			else null;
			end case;

			l_attr_contract.id_eor_contract := null;
            l_attr_contract.contract_number := arj_contract.contract_number;
            l_attr_contract.registry_number := arj_contract.registry_contract_number;
            l_attr_contract.gozuid := arj_contract.defensecontractnumber; --6.2.100
            l_attr_contract.contract_date := arj_contract.contract_date;

            case
			when arj_contract.id_execution is not null 
            then
            
                SELECT
					coalesce(
						 to_date(execdate, 'yyyy-mm-dd')
						,
						(
							to_date(lpad(month::text,2,'0') || year::text,'mmyyyy') 
								+ interval '1 month' 
								- interval '1 day'
						)::timestamp
					) 
                into strict l_attr_contract.contract_execution_date 
                from arch_ext.idwh2_arj_execution_gov_buffer
                where 
                        id_execution = arj_contract.id_execution 
                    and load_id = arj_contract.load_id
                ;
                
            else l_attr_contract.contract_execution_date := null;
			end case;

            l_attr_contract.price := arj_contract.price;

            case
			when l_currency_code_from_source is not null 
            then l_attr_contract.id_currency := l_id_currency::int4; -- plpgsql_check_function: Detail: cast "text" value to "integer" type
            else l_attr_contract.id_currency := null;
			end case;

            l_attr_contract.paid := null;
            l_attr_contract.id_contract_status := null;
            l_attr_contract.termination_reason := null;

            case
			when arj_contract.id_pricechangereason is not null 
            then
            
                select name 
                into strict l_attr_contract.price_change_reason
                from arch_ext.idwh2_arj_pricechange_rsn_gov_buffer
                where 
                        id_pricechangereason = arj_contract.id_pricechangereason 
                    and load_id = arj_contract.load_id
                ;
                
            else l_attr_contract.price_change_reason := null;
            end case;

            l_attr_contract.id_rec_status := 0;
            l_attr_contract.id_contract_type := null;
            l_attr_contract.id_source := c_id_source;
            l_attr_contract.id_from_source := arj_contract.id_from_source::int4; -- plpgsql_check_function: Detail: cast "text" value to "integer" type
            l_attr_contract.id_contract_load := null;
            l_attr_contract.contract_start_date := null;
            l_attr_contract.id_contract_status_ext := null;
            l_attr_contract.id_company_ext := null;
            l_attr_contract.id_contragent_ext := null;
            l_attr_contract.contract_subject := null;
            l_attr_contract.is_last := null;
            l_attr_contract.max_version_id := arj_contract.versionnumber::int2; -- plpgsql_check_function: Detail: cast "character varying" value to "smallint" type
            l_attr_contract.actual_finish_date := null;
            l_attr_contract.actual_date := arj_contract.actual_date;
            l_attr_contract.contract_status_code := arj_contract.contract_status_code;
            l_attr_contract.id_from_arj := arj_contract.id_from_ARJ;

            case
			when 
                    arj_contract.id_finances is not null 
                and l_id_extrabudget is not null 
            then l_attr_contract.code_extrabudget := l_extrabudget_code;
            else l_attr_contract.code_extrabudget := null;
            end case;

            l_attr_contract.url := arj_contract.url;

            case
			when arj_contract.id_singlecustomerreason is not null 
            then l_attr_contract.code_singlecustomer := l_sngl_code;
            else l_attr_contract.code_singlecustomer := null;
            end case;

            case
			when 
                    arj_contract.id_foundation is not null 
                and l_id_order is not null 
            then l_attr_contract.placing := l_placing::int4; -- plpgsql_check_function: Detail: cast "character varying" value to "integer" type
            else l_attr_contract.placing := null;
            end case;

            case
            when
                    l_attr_contract.placing is null 
                and l_attr_contract.code_singlecustomer is not null
            then l_attr_contract.placing := 20000;
            else null;
            end case;

            case
			when arj_contract.id_modification is not null 
            then
            
                l_attr_contract.mod_type := l_mod_type;
                l_attr_contract.mod_description := l_mod_desc;
                
            else 
                
                l_attr_contract.mod_type := null;
                l_attr_contract.mod_description := null;
                
            end case;

            l_attr_contract.fz := arj_contract.fz;
            l_attr_contract.code_budget := l_id_ba_budget;
            --------------------------------------------------------------------------------------------
            l_attr_contract.currency_rate := l_currency_rate;
            l_attr_contract.currency_raiting := l_currency_raiting;
            l_attr_contract.currency := l_currency_code_from_source;
            l_attr_contract.price_currency := arj_contract.price_currency;
            --------------------------------------------------------------------------------------------
            --30.09.2020
            l_attr_contract.publishdate := arj_contract.publishdate;
            l_attr_contract.protocoldate := arj_contract.protocoldate;
            l_attr_contract.bsupp_contr_reqinfo := arj_contract.bsupp_contr_reqinfo;
            l_attr_contract.contract_subject := arj_contract.contract_subject;
            l_attr_contract.priceinfo_pricetype := arj_contract.priceinfo_pricetype;
            l_attr_contract.priceinfo_pricevat := arj_contract.priceinfo_pricevat;
            l_attr_contract.subcontractors_pricevaluerur := arj_contract.subcontractors_pricevaluerur;
            l_attr_contract.subcontractors_suminpercents := arj_contract.subcontractors_suminpercents;
            l_attr_contract.enf_ca_amountrur := arj_contract.enf_ca_amountrur;
            l_attr_contract.qgi_fromdate := arj_contract.qgi_fromdate;
            l_attr_contract.qgi_todate := arj_contract.qgi_todate;
            l_attr_contract.qgi_otherperiodtext := arj_contract.qgi_otherperiodtext;
            l_attr_contract.qgi_warrantyreqstext := arj_contract.qgi_warrantyreqstext;
            l_attr_contract.st14_npainfo := arj_contract.st14_npainfo;
            l_attr_contract.st14_requirementtype := arj_contract.st14_requirementtype;
            --------------------------------------------------------------------------------------------
			
			call pkg_eor_contract_load.log_level_2(
				 p_msg => '08. Вставка контракта'
				,p_process_log_id => p_process_log_id::text
				,p_procedure => c_procedure
				,p_proc_data => p_process_data
			);
 
			l_id_ba_contract := 
                pkg_eor_contract_load.add_contract_mention( 
					 p_id_source => c_id_source
					,p_id_from_source => arj_contract.id_from_source
					,p_actual_date => arj_contract.actual_date
					,p_contract_attr => l_attr_contract
                );

			call pkg_eor_contract_load.add_contract_mention_dbg(l_id_ba_contract, c_raise_notice);

			-- members
			call pkg_eor_contract_load.log_level_2(
				 p_msg => '09. Создание упоминаний исполнителей контракта'
				,p_process_log_id => p_process_log_id::text
				,p_procedure => c_procedure
				,p_proc_data => p_process_data
			);

			case
            when 
				coalesce(arj_contract.schemeversion, '1.0') in (
					'1.0', '1', '4.1', '4.2', '4.3', '4.3.100', '4.4', '4.4.2', '4.5', '4.6'
				) 
            then

                for arj_supplier in (
					select
			             2::int4 as id_member_role
						,c.id_supplier as id_from_source
						,c.participanttype
						,c.organizationname as name
						,c.inn
						,c.kpp
						,c.postaddress as pocht_adres
						,c.factualaddress
						,c.contactphone as phone
						,d.lastname
						,d.firstname
						,d.middlename
						,e.countrycode
						,c_id_source::text || c.load_id::text || c.id_supplier::text as external_h_id
			        from arch_ext.idwh2_arj_suppliers_gov_buffer b
			        inner join arch_ext.idwh2_arj_supplier_gov_buffer c on
							b.id_supplier = c.id_supplier 
						and b.load_id = c.load_id
					left join arch_ext.idwh2_arj_contactinfo_gov_buffer d on
							c.id_contactinfo = d.id_contactinfo 
						and c.load_id = d.load_id
					left join arch_ext.idwh2_arj_country_gov_buffer e on
							c.id_country = e.id_country 
						and c.load_id = e.load_id
			        where 
							b.id_suppliers = arj_contract.id_suppliers 
						and b.load_id = arj_contract.load_id
				)
                loop
                
                    case
                    --РФЛ
                    when upper(arj_supplier.participanttype) = upper('P') 
                    then
                    
                        l_attr_rfl.inn := substr(trim(arj_supplier.inn), 1, 12);
                        l_attr_rfl.full_name := substr(trim(arj_supplier.lastname || ' ' || arj_supplier.firstname || ' ' || arj_supplier.middlename), 1, 255);
                        l_attr_rfl.family_name := substr(trim(arj_supplier.lastname), 1, 255);
                        l_attr_rfl.second_name := substr(trim(arj_supplier.middlename), 1, 255);
                        l_attr_rfl.first_name := substr(trim(arj_supplier.firstname), 1, 255);
                        l_attr_rfl.address := substr(trim(arj_supplier.factualaddress), 1, 255);

                        begin
                        
                            select a.eor_subject_mention_id 
                            into strict l_id_mention
                            from eor.idw_mr_subject_mention a
                            where 
                                    a.source_id = c_id_source 
                                and a.external_h_id = arj_supplier.external_h_id
                            ;
                            
                        exception
                        when no_data_found 
                        then
                        
                            l_id_mention := 
                                pkg_eor_api.add_subj_rfl_mention(
                                     p_source_id => c_id_source::int4
                                    ,p_source_etalon_id => c_source_etalon_id::int4
                                    ,p_external_id => arj_supplier.external_h_id
                                    ,p_external_h_id => arj_supplier.external_h_id --???
                                    ,p_actual_date => arj_contract.actual_date::date
                                    ,p_attributes => l_attr_rfl
                                    ,p_priority => l_priority::int2
                            );

							call pkg_eor_contract_load.add_subj_rfl_mention_dbg(l_id_mention, c_raise_notice);
                            
                        end;

                    --ИФЛ
                    when upper(arj_supplier.participanttype) = upper('PF') 
                    then
                    
                        -- очищаем
                        l_attr_ifl := c_attr_ifl_init;

                        l_attr_ifl.inn := substr(trim(arj_supplier.inn), 1, 12);
                        l_attr_ifl.full_name := substr(trim(arj_supplier.lastname || ' ' || arj_supplier.firstname || ' ' || arj_supplier.middlename), 1, 255);
                        l_attr_ifl.family_name := substr(trim(arj_supplier.lastname), 1, 255);
                        l_attr_ifl.first_name := substr(trim(arj_supplier.firstname), 1, 255);
                        l_attr_ifl.second_name := substr(trim(arj_supplier.middlename), 1, 255);
                        l_attr_ifl.address := substr(trim(arj_supplier.factualaddress), 1, 255);

                        begin
                        
                            select a.eor_subject_mention_id 
                            into strict l_id_mention
                            from eor.idw_mr_subject_mention a
                            where 
                                    a.source_id = c_id_source 
                                and a.external_h_id = arj_supplier.external_h_id
                            ;
                            
                        exception
                        when no_data_found 
                        then
                        
                            l_id_mention := 
                                pkg_eor_api.add_subj_ifl_mention(
                                     p_source_id => c_id_source::int4
                                    ,p_source_etalon_id => c_source_etalon_id::int4
                                    ,p_external_id => arj_supplier.external_h_id
                                    ,p_external_h_id => arj_supplier.external_h_id --???
                                    ,p_actual_date => arj_contract.actual_date::date
                                    ,p_attributes => l_attr_ifl
                                    ,p_priority => l_priority::int2
                            );

							call pkg_eor_contract_load.add_subj_ifl_mention_dbg(l_id_mention, c_raise_notice);
                            
                        end;

                    --РЮЛ
                    when upper(arj_supplier.participanttype) = upper('U') 
					then
                       	
						-- очищаем
                        l_attr_rul := c_attr_rul_init;

                        l_attr_rul.name_full := substr(arj_supplier.name, 1, 1000);
                        l_attr_rul.name_short := substr(arj_supplier.name, 1, 255);
                        l_attr_rul.inn := substr(trim(arj_supplier.inn), 1, 255);
                        l_attr_rul.kpp := substr(trim(arj_supplier.kpp), 1, 255);
                        l_attr_rul.pocht_adres := substr(arj_supplier.pocht_adres, 1, 1000);
                        l_attr_rul.fio_pr_pr := substr(trim(arj_supplier.lastname || ' ' || arj_supplier.firstname || ' ' || arj_supplier.middlename), 1, 255);
                        l_attr_rul.phone_num := SUBSTR(ARJ_SUPPLIER.PHONE, 1, 255);

                        begin

                            select a.eor_subject_mention_id 
							into strict l_id_mention
                            from idwh2.idw_mr_subject_mention a
                            where 
									a.source_id = c_id_source 
								and a.external_h_id = arj_supplier.external_h_id;

                        exception
                       	when no_data_found 
						then

							l_id_mention := 
								pkg_eor_api.add_subj_rul_mention( 
									 p_source_id => c_id_source::int4
									,p_source_etalon_id => c_source_etalon_id::int4
									,p_external_id => arj_supplier.external_h_id
									,p_external_h_id => arj_supplier.external_h_id --???
									,p_actual_date => arj_contract.actual_date::date
									,p_attributes => l_attr_rul
									,p_priority => l_priority::int2
								);

							call pkg_eor_contract_load.add_subj_rul_mention_dbg(l_id_mention, c_raise_notice);

                        end;

                    --ИЮЛ
                    when upper(arj_supplier.participanttype) = upper('UF') 
                    then
                        
						-- очищаем
                        l_attr_iul := c_attr_iul_init;

                        l_attr_iul.inn := substr(trim(arj_supplier.inn), 1, 255);
                        l_attr_iul.kpp := substr(trim(arj_supplier.kpp), 1, 255);
                        l_attr_iul.full_name := substr(arj_supplier.name, 1, 1000);
                        l_attr_iul.short_name := substr(arj_supplier.name, 1, 255);
                        l_attr_iul.oksm_code := arj_supplier.countrycode;

                        begin
                    
                            select a.eor_subject_mention_id 
                            into strict l_id_mention
                            from eor.idw_mr_subject_mention a
                            where 
                                    a.source_id = c_id_source 
                                and a.external_h_id = arj_supplier.external_h_id
                            ;
                            
                        exception
                        when no_data_found 
                        then
                        
                            l_id_mention := 
                                pkg_eor_api.add_subj_iul_mention( 
                                     p_source_id => c_id_source::int4
                                    ,p_source_etalon_id => c_source_etalon_id::int4
                                    ,p_external_id => arj_supplier.external_h_id
                                    ,p_external_h_id => arj_supplier.external_h_id --???
                                    ,p_actual_date => arj_contract.actual_date::date
                                    ,p_attributes => l_attr_iul
                                    ,p_priority => l_priority::int2
                            );

							call pkg_eor_contract_load.add_subj_iul_mention_dbg(l_id_mention, c_raise_notice);
                            
                        end;
                        
                    end case;

                    -- если упоминание создано, то
                    -- создаем упоминания адресов
                    -- добавляем упоминание связи
                    case 
					when l_id_mention > 0 
                    then

                        --создаем для почтового адреса
                        case
						when arj_supplier.pocht_adres is not null  
                        then
                        
                            l_address_mention_id := 0;
                            l_addr_attr.address := arj_supplier.pocht_adres;
                            l_address_mention_id := 
                                pkg_eor_api.add_address_mention( 
                                     p_source_id => c_id_source::int4
                                    ,p_source_etalon_id => c_source_etalon_id::int4
                                    ,p_actual_date => arj_contract.actual_date::date
                                    ,p_attributes => l_addr_attr
                                    ,p_priority => l_priority::int2
                            );

							call pkg_eor_contract_load.add_address_mention_dbg(l_address_mention_id, c_raise_notice);

                            -- добавляем упоминание связи
                            case
							when l_address_mention_id is not null
                            then
                            
                                l_subj_addr_mention_id := 
									pkg_eor_api.add_subj_address_mention( 
                                         p_source_id => c_id_source::int4
                                        ,p_source_etalon_id => c_source_etalon_id::int4
                                        ,p_actual_date => arj_contract.actual_date::date
                                        ,p_eor_subject_mention_id => l_id_mention
                                        ,p_eor_address_mention_id => l_address_mention_id
                                        ,p_address_type_id => 4::int4 -- почтовый
                                        ,p_begin_date => null::date
                                        ,p_end_date => null::date
                                	);
					
								call pkg_eor_contract_load.add_subj_address_mention_dbg(l_subj_addr_mention_id, c_raise_notice);

                            else null;
							end case;
                            
                        else null;
						end case;

                        -- создаем для FACTUALADDRESS
                        case
						when arj_supplier.factualaddress is not null 
                        then
                        
                            l_addr_attr.address := arj_supplier.factualaddress;
                            l_address_mention_id := 0;
                            l_address_mention_id := 
                                pkg_eor_api.add_address_mention( 
                                     p_source_id => c_id_source::int4
                                    ,p_source_etalon_id => c_source_etalon_id::int4
                                    ,p_actual_date => arj_contract.actual_date::date
                                    ,p_attributes => l_addr_attr
                                    ,p_priority => l_priority::int2
                            );

							call pkg_eor_contract_load.add_address_mention_dbg(l_address_mention_id, c_raise_notice);

                            case 
							when l_address_mention_id is not null  
                            then
                                
								-- добавляем упоминание связи
                                l_subj_addr_mention_id := 
                                    pkg_eor_api.add_subj_address_mention( 
                                         p_source_id => c_id_source::int4
                                        ,p_source_etalon_id => c_source_etalon_id::int4
                                        ,p_actual_date => arj_contract.actual_date::date
                                        ,p_eor_subject_mention_id => l_id_mention
                                        ,p_eor_address_mention_id => l_address_mention_id
                                        ,p_address_type_id => 5::int4 -- фактический
                                        ,p_begin_date => null::date
                                        ,p_end_date => null::date
                                	);

								call pkg_eor_contract_load.add_subj_address_mention_dbg(l_subj_addr_mention_id, c_raise_notice);
                                
                            else null;
							end case;
                            
                        else null;
						end case;

                        --создаем для телефонов
                        case
						when arj_supplier.phone is not null  
                        then
                        
                            l_phone_mention_id := 0;
                            l_phone_attr.phone_number := arj_supplier.phone;
                            l_phone_mention_id := 
                                pkg_eor_api.add_telephone_mention( 
                                     p_source_id => c_id_source::int4
                                    ,p_source_etalon_id => c_source_etalon_id::int4
                                    ,p_actual_date => arj_contract.actual_date::date
                                    ,p_attributes => l_phone_attr
                                    ,p_priority => l_priority::int2
                            );

							call pkg_eor_contract_load.add_telephone_mention_dbg(l_phone_mention_id, c_raise_notice);

                            case
							when l_phone_mention_id is not null 
                            then
                            
                                l_subj_phone_mention_id := 
                                    pkg_eor_api.add_subj_telephone_mention(
                                         p_source_id => c_id_source::int4
                                        ,p_source_etalon_id => c_source_etalon_id::int4
                                        ,p_actual_date => arj_contract.actual_date::date
                                        ,p_eor_subject_mention_id => l_id_mention
                                        ,p_eor_telephone_mention_id => l_phone_mention_id
                                );

								call pkg_eor_contract_load.add_subj_telephone_mention_dbg(l_subj_phone_mention_id, c_raise_notice);

                            else null;
							end case;
                            
                        else null;
						end case;

                        call pkg_eor_contract_load.add_contract_subj_mention(
							 p_id_ba_contract => l_id_ba_contract
							,p_id_member_role => arj_supplier.id_member_role::int4
							,p_id_from_source => arj_supplier.external_h_id::int4
							,p_subject_mention => l_id_mention
							,p_source_id => c_id_source::int4
							,p_customer_code => ''::text
							,p_etalon_registry_id => 0::int8
						);

						call pkg_eor_contract_load.add_contract_subj_mention_dbg(l_id_mention, c_raise_notice);
                        
                    else null;
					end case;
                    
                end loop;
                
            when 
				arj_contract.schemeversion in (
					'5', '5.0', '5.1', '5.2',
					'6', '6.0', '6.1', '6.2', '6.2.100', '6.3', '6.4',
					'7', '7.0', '7.1', '7.2', '7.3', '7.4', '7.5',
					'8', '8.0', '8.1', '8.2', '8.3', '8.4', '8.5',
					'9', '9.0', '9.1', '9.2', '9.3', '9.4', '9.5',
					'10', '10.0', '10.1', '10.2', '10.3', '10.4', '10.5',
					'11', '11.0', '11.1', '11.2', '11.3', '11.4', '11.5',
					'12', '12.0', '12.1', '12.2', '12.3', '12.4', '12.5', '13.0', '13.1', '13.2',  '13.3',
					'14', '14.0', '14.1', '14.2',  '14.3', '15.0', '15.1', '15.2', '15.3', '16.0'
					)
				or ARJ_CONTRACT.schemeVersion like '8.2%'
                or ARJ_CONTRACT.schemeVersion like '8.3%'
                or ARJ_CONTRACT.schemeVersion like '8.4%'
                or ARJ_CONTRACT.schemeVersion like '8.5%'
                or ARJ_CONTRACT.schemeVersion like '9.2%'
               	or ARJ_CONTRACT.schemeVersion like '9.3%'
               	or ARJ_CONTRACT.schemeVersion like '9.4%'
               	or ARJ_CONTRACT.schemeVersion like '9.5%'
               	or ARJ_CONTRACT.schemeVersion like '10.2%'
               	or ARJ_CONTRACT.schemeVersion like '10.3%'
               	or ARJ_CONTRACT.schemeVersion like '10.4%'
               	or ARJ_CONTRACT.schemeVersion like '10.5%'
               	or ARJ_CONTRACT.schemeVersion like '11.2%'
               	or ARJ_CONTRACT.schemeVersion like '11.3%'
               	or ARJ_CONTRACT.schemeVersion like '11.4%'
               	or ARJ_CONTRACT.schemeVersion like '11.5%'
               	or ARJ_CONTRACT.schemeVersion like '12.2%'
               	or ARJ_CONTRACT.schemeVersion like '12.3%'
               	or ARJ_CONTRACT.schemeVersion like '12.4%'
               	or ARJ_CONTRACT.schemeVersion like '12.5%'
               	or ARJ_CONTRACT.schemeVersion like '13.0%'
               	or ARJ_CONTRACT.schemeVersion like '13.1%'
               	or ARJ_CONTRACT.schemeVersion like '13.2%'
               	or ARJ_CONTRACT.schemeVersion like '13.3%'
               	or ARJ_CONTRACT.schemeVersion like '14.0%'
               	or ARJ_CONTRACT.schemeVersion like '14.1%'
               	or ARJ_CONTRACT.schemeVersion like '14.2%'
               	or ARJ_CONTRACT.schemeVersion like '14.3%'
               	or ARJ_CONTRACT.schemeVersion like '15.0%'
               	or ARJ_CONTRACT.schemeVersion like '15.1%'
               	or ARJ_CONTRACT.schemeVersion like '15.2%'
               	or ARJ_CONTRACT.schemeVersion like '15.3%'
               	or ARJ_CONTRACT.schemeVersion like '16.0%'

            then
            
                case
                -- РЮЛ
                when l_sup_type = 2 
                then
                	
                    for r_arj_supplier in (
                        select 
                             a.*
                            ,id_legalentityrf::text || '.' || load_id::text ext_id
                        from arch_ext.idwh2_arj_sup_ul_gov_buffer a 
                        where 
                                load_id = arj_contract.load_id
                            and id_contract = arj_contract.l_id_contract
					)
                    loop
                    
                        -- очищаем
                        l_attr_rul := c_attr_rul_init;

                        l_attr_rul.name_full := substr(r_arj_supplier.fullname, 1, 1000);
                        l_attr_rul.name_short := substr(r_arj_supplier.shortname, 1, 255);
                        l_attr_rul.name_firm := substr(r_arj_supplier.firmname, 1, 255);
                        l_attr_rul.okopf_code := substr(r_arj_supplier.legalform_code, 1, 255);
                        l_attr_rul.okopf_name := substr(r_arj_supplier.legalform_singularname, 1, 510);
                          
                        begin

                            l_attr_rul.start_date := 
								to_date(substr(r_arj_supplier.registrationdate, 1, 10), 'yyyy-mm-dd');

                        exception
                        when others 
                        then null;
                        end;
                        
                        l_attr_rul.inn := substr(trim(r_arj_supplier.inn), 1, 255);
                        l_attr_rul.kpp := substr(trim(r_arj_supplier.kpp), 1, 255);
                        l_attr_rul.pocht_adres := substr(r_arj_supplier.address, 1, 1000);
                        l_attr_rul.phone_num := substr(r_arj_supplier.contactphone, 1, 255);
                        l_attr_rul.okpo := substr(r_arj_supplier.okpo, 1, 255);

                        l_id_mention := 
                            pkg_eor_api.add_subj_rul_mention( 
								 p_source_id => c_id_source::int4
                                ,p_source_etalon_id => c_source_etalon_id::int4
                                ,p_external_id =>   r_arj_supplier.ext_id
                                ,p_external_h_id => r_arj_supplier.ext_id
                                ,p_actual_date => arj_contract.actual_date::date
                                ,p_attributes => l_attr_rul
                                ,p_priority => l_priority::int2
                            );

						call pkg_eor_contract_load.add_subj_rul_mention_dbg(l_id_mention, c_raise_notice);

                        case
						when l_id_mention > 0 
                        then

                            -- связь унотракта с исполнителем
                            call pkg_eor_contract_load.add_contract_subj_mention( 
								 p_id_ba_contract => l_id_ba_contract
								,p_id_member_role => 2::int4
								,p_id_from_source => r_arj_supplier.ext_id::int4
								,p_subject_mention => l_id_mention
								,p_source_id => c_id_source::int4
								,p_customer_code => ''::text
								,p_etalon_registry_id => 0::int8
                            );
							
							call pkg_eor_contract_load.add_contract_subj_mention_dbg(l_id_mention, c_raise_notice);

                            --создаем упоминание адреса места нахождения
                            case
							when r_arj_supplier.address is not null  
                            then
                            
                                l_addr_attr.address := r_arj_supplier.address;
                                l_address_mention_id := 0;
                                l_address_mention_id := 
                                    pkg_eor_api.add_address_mention( 
                                         p_source_id => c_id_source::int4
                                        ,p_source_etalon_id => c_source_etalon_id::int4
                                        ,p_actual_date => arj_contract.actual_date::date
                                        ,p_attributes => l_addr_attr
                                        ,p_priority => l_priority::int2
                                    );

								call pkg_eor_contract_load.add_address_mention_dbg(l_address_mention_id, c_raise_notice);

                                -- добавляем упоминание связи
                                case
								when l_address_mention_id is not null 
                                then
                                
                                    l_subj_addr_mention_id := 
                                        pkg_eor_api.add_subj_address_mention( 
                                             p_source_id => c_id_source::int4
                                            ,p_source_etalon_id => c_source_etalon_id::int4
                                            ,p_actual_date => arj_contract.actual_date::date
                                            ,p_eor_subject_mention_id => l_id_mention
                                            ,p_eor_address_mention_id => l_address_mention_id
                                            ,p_address_type_id => 5::int4 -- адреса места нахождения
                                            ,p_begin_date => null::date
                                            ,p_end_date => null::date
                                        );

									call pkg_eor_contract_load.add_subj_address_mention_dbg(l_subj_addr_mention_id, c_raise_notice);

                                else null;
								end case;
                                
                            else null;
							end case;
                            
                        else null;
						end case;

                    end loop;
                    
                -- РФЛ
                when l_sup_type = 3 
                then
                
                    for r_arj_supplier in (
                        select 
                             a.*
                            ,id_individualpersonrf::text || '.' || load_id::text ext_id
                        from arch_ext.idwh2_arj_sup_fl_gov_buffer a 
                        where 
                                load_id = arj_contract.load_id
                            and id_contract = arj_contract.l_id_contract
                    )
                    loop
                    
                        -- очищаем
                        l_attr_rfl := c_attr_rfl_init;

                        l_attr_rfl.inn := substr(trim(r_arj_supplier.inn), 1, 12);
                        l_attr_rfl.full_name := substr(trim(r_arj_supplier.lastname || ' ' || r_arj_supplier.firstname || ' ' || r_arj_supplier.middlename), 1, 255);
                        l_attr_rfl.family_name := substr(trim(r_arj_supplier.lastname), 1, 255);
                        l_attr_rfl.second_name := substr(trim(r_arj_supplier.middlename), 1, 255);
                        l_attr_rfl.first_name := substr(trim(r_arj_supplier.firstname), 1, 255);
                        l_attr_rfl.address := substr(trim(r_arj_supplier.address), 1, 255);
                        l_attr_rfl.ogrnip := substr(trim(r_arj_supplier.ogrnip), 1, 255);

                        l_id_mention := 
                            pkg_eor_api.add_subj_rfl_mention( 
                                 p_source_id => c_id_source::int4
                                ,p_source_etalon_id => c_source_etalon_id::int4
                                ,p_external_id =>   r_arj_supplier.ext_id
                                ,p_external_h_id => r_arj_supplier.ext_id
                                ,p_actual_date => arj_contract.actual_date::date
                                ,p_attributes => l_attr_rfl
                                ,p_priority => l_priority::int2
                            );

						call pkg_eor_contract_load.add_subj_rfl_mention_dbg(l_id_mention, c_raise_notice);

                        case
						when l_id_mention > 0 
                        then
                            
							-- связь котракта с исполнителем
                            call pkg_eor_contract_load.add_contract_subj_mention(
								 p_id_ba_contract => l_id_ba_contract
								,p_id_member_role => 2::int4
								,p_id_from_source => r_arj_supplier.ext_id::int4
								,p_subject_mention => l_id_mention
								,p_source_id => c_id_source::int4
								,p_customer_code => ''::text
								,p_etalon_registry_id => 0::int8
                            );

							call pkg_eor_contract_load.add_contract_subj_mention_dbg(l_id_mention, c_raise_notice);

                            --создаем упоминание адреса места нахождения
                            case
							when r_arj_supplier.address is not null  
                            then
                            
                                l_addr_attr.address := r_arj_supplier.address;
                                l_address_mention_id := 0;
                                l_address_mention_id := 
                                    pkg_eor_api.add_address_mention( 
                                         p_source_id => c_id_source::int4
                                        ,p_source_etalon_id => c_source_etalon_id::int4
                                        ,p_actual_date => arj_contract.actual_date::date
                                        ,p_attributes => l_addr_attr
                                        ,p_priority => l_priority::int2
                                    );

								call pkg_eor_contract_load.add_address_mention_dbg(l_address_mention_id, c_raise_notice);

                                -- добавляем упоминание связи
                                case
								when l_address_mention_id is not null 
                                then
                                
                                    l_subj_addr_mention_id := 
                                        pkg_eor_api.add_subj_address_mention( 
                                             p_source_id => c_id_source::int4
                                            ,p_source_etalon_id => c_source_etalon_id::int4
                                            ,p_actual_date => arj_contract.actual_date::date
                                            ,p_eor_subject_mention_id => l_id_mention
                                            ,p_eor_address_mention_id => l_address_mention_id
                                            ,p_address_type_id => 5::int4 -- адреса места нахождения
                                            ,p_begin_date => null::date
                                            ,p_end_date => null::date
                                        );
									
									call pkg_eor_contract_load.add_subj_address_mention_dbg(l_subj_addr_mention_id, c_raise_notice);
                                        
                                else null;
								end case;
                                
                            else null;
							end case;
                            
                        else null;
						end case;
                        
                    end loop;
                      
                -- ИЮЛ
                when l_sup_type = 5 
                then
                
                    for r_arj_supplier in (
                        select 
                             a.*
                            ,id_legalentityforeignstate::text || '.' || load_id::text ext_id
                        from arch_ext.idwh2_arj_sup_ulnr_gov_buffer a 
                        where 
                                load_id = arj_contract.load_id
                            and id_contract = arj_contract.l_id_contract
                    )
                    loop
                    
                        -- очищаем
                        l_attr_iul := c_attr_iul_init;

                        l_attr_iul.inn := substr(trim(r_arj_supplier.reginrf_inn), 1, 255);
                        l_attr_iul.kpp := substr(trim(r_arj_supplier.reginrf_kpp), 1, 255);
                        l_attr_iul.full_name := substr(r_arj_supplier.fullname, 1, 1000);
                        l_attr_iul.short_name := substr(r_arj_supplier.shortname, 1, 255);
                        l_attr_iul.full_name_lat := substr(r_arj_supplier.fullnamelat, 1, 1000);
                        l_attr_iul.full_name_foreign := r_arj_supplier.firmname;
                        l_attr_iul.oksm_code := r_arj_supplier.placeinreg_country_code;
                        l_attr_iul.taxpayer_code := r_arj_supplier.taxpayercode;

                        l_id_mention := 
                            pkg_eor_api.add_subj_iul_mention(
                                 p_source_id => c_id_source::int4
                                ,p_source_etalon_id => c_source_etalon_id::int4
                                ,p_external_id =>   r_arj_supplier.ext_id
                                ,p_external_h_id => r_arj_supplier.ext_id
                                ,p_actual_date => arj_contract.actual_date::date
                                ,p_attributes => l_attr_iul
                                ,p_priority => l_priority::int2
                            );
						
						call pkg_eor_contract_load.add_subj_iul_mention_dbg(l_id_mention, c_raise_notice);

                        case
                        when l_id_mention > 0 
                        then
                            
                        	-- связь котракта с исполнителем
                            call pkg_eor_contract_load.add_contract_subj_mention( 
								 p_id_ba_contract => l_id_ba_contract
								,p_id_member_role => 2::int4
								,p_id_from_source => r_arj_supplier.ext_id::int4
								,p_subject_mention => l_id_mention
								,p_source_id => c_id_source::int4
								,p_customer_code => ''::text
								,p_etalon_registry_id => 0::int8
                            );
							
							call pkg_eor_contract_load.add_contract_subj_mention_dbg(l_id_mention, c_raise_notice);

                            --создаем упоминание Адреса места нахождения на территории РФ
                            case 
                            when r_arj_supplier.placeinrf_address is not null  
                            then
                            
                                l_addr_attr.address := r_arj_supplier.placeinrf_address;
                                l_address_mention_id := 
                                    pkg_eor_api.add_address_mention( 
                                         p_source_id => c_id_source::int4
                                        ,p_source_etalon_id => c_source_etalon_id::int4
                                        ,p_actual_date => arj_contract.actual_date::date
                                        ,p_attributes => l_addr_attr
                                        ,p_priority => l_priority::int2
                                    );
								
								call pkg_eor_contract_load.add_address_mention_dbg(l_address_mention_id, c_raise_notice);

                                -- добавляем упоминание связи
                                case 
                               	when l_address_mention_id is not null 
                                then
                                
                                    l_subj_addr_mention_id := 
                                        pkg_eor_api.add_subj_address_mention( 
                                             p_source_id => c_id_source::int4
                                            ,p_source_etalon_id => c_source_etalon_id::int4
                                            ,p_actual_date => arj_contract.actual_date::date
                                            ,p_eor_subject_mention_id => l_id_mention
                                            ,p_eor_address_mention_id => l_address_mention_id
                                            ,p_address_type_id => 1::int4 -- адреса места проживания
                                            ,p_begin_date => null::date
                                            ,p_end_date => null::date
                                        );
									
									call pkg_eor_contract_load.add_subj_address_mention_dbg(l_subj_addr_mention_id, c_raise_notice);

                                else null;
                                end case;
                                
                            else null;
                            end case;

                            --создаем упоминание Адреса места нахождения в стране регистрации
                            case 
							when r_arj_supplier.placeinrf_address is not null  
                            then
                            
                                l_addr_attr.address := r_arj_supplier.placeinrf_address;
                                l_address_mention_id := 
                                    pkg_eor_api.add_address_mention( 
                                         p_source_id => c_id_source::int4
                                        ,p_source_etalon_id => c_source_etalon_id::int4
                                        ,p_actual_date => arj_contract.actual_date::date
                                        ,p_attributes => l_addr_attr
                                        ,p_priority => l_priority::int2
                                    );
								
								call pkg_eor_contract_load.add_address_mention_dbg(l_address_mention_id, c_raise_notice);

                                -- добавляем упоминание связи
                                case 
                                when l_address_mention_id is not null 
                                then
                                
                                    l_subj_addr_mention_id := 
                                        pkg_eor_api.add_subj_address_mention( 
                                             p_source_id => c_id_source::int4
                                            ,p_source_etalon_id => c_source_etalon_id::int4
                                            ,p_actual_date => arj_contract.actual_date::date
                                            ,p_eor_subject_mention_id => l_id_mention
                                            ,p_eor_address_mention_id => l_address_mention_id
                                            ,p_address_type_id => 2::int4 -- адрес места регистрации в стране регистрации
                                            ,p_begin_date => null::date
                                            ,p_end_date => null::date
                                        );
									
									call pkg_eor_contract_load.add_subj_address_mention_dbg(l_subj_addr_mention_id, c_raise_notice);
                                        
                                else null;
                                end case;
                                
                            else null;
                            end case;
                            
                        else null;
                        end case;

                    end loop;
                      
                -- ИФЛ
                when l_sup_type = 6 
                then
                
                    for r_arj_supplier in (
                        select 
                             a.*
                            ,id_ipforeignstate::text || '.' || load_id::text ext_id
                        from arch_ext.idwh2_arj_sup_flnr_gov_buffer a 
                        where 
                                load_id = arj_contract.load_id
                            and id_contract = arj_contract.l_id_contract
                    )
                    loop
                    
                        -- очищаем
                        l_attr_ifl := c_attr_ifl_init;

                        l_attr_ifl.inn := substr(trim(r_arj_supplier.reginrf_inn), 1, 12);
                        l_attr_ifl.full_name := substr(trim(r_arj_supplier.lastname || ' ' || r_arj_supplier.firstname || ' ' || r_arj_supplier.middlename), 1, 255);
                        l_attr_ifl.family_name := substr(trim(r_arj_supplier.lastname), 1, 255);
                        l_attr_ifl.first_name := substr(trim(r_arj_supplier.firstname), 1, 255);
                        l_attr_ifl.second_name := substr(trim(r_arj_supplier.middlename), 1, 255);
                        l_attr_ifl.address := substr(trim(r_arj_supplier.placeinrf_address), 1, 255);
                        l_attr_ifl.full_name_lat := substr(trim(r_arj_supplier.lastnamelat || ' ' || r_arj_supplier.firstnamelat || ' ' || r_arj_supplier.middlenamelat), 1, 255);
                        l_attr_ifl.family_name_lat := substr(trim(r_arj_supplier.lastnamelat), 1, 255);
                        l_attr_ifl.first_name_lat := substr(trim(r_arj_supplier.firstnamelat), 1, 255);
                        l_attr_ifl.second_name_lat := substr(trim(r_arj_supplier.middlenamelat), 1, 255);
                        l_attr_ifl.oksm_code := r_arj_supplier.placeinreg_country_code;

                        l_id_mention := 
                            pkg_eor_api.add_subj_ifl_mention(
                                 p_source_id => c_id_source::int4
                                ,p_source_etalon_id => c_source_etalon_id::int4
                                ,p_external_id =>   r_arj_supplier.ext_id
                                ,p_external_h_id => r_arj_supplier.ext_id
                                ,p_actual_date => arj_contract.actual_date::date
                                ,p_attributes => l_attr_ifl
                                ,p_priority => l_priority::int2
                            );
						
						call pkg_eor_contract_load.add_subj_ifl_mention_dbg(l_id_mention, c_raise_notice);

                        case
						when l_id_mention > 0 
						then

                            -- связь контракта с исполнителем
                            call pkg_eor_contract_load.add_contract_subj_mention( 
								 p_id_ba_contract => l_id_ba_contract
								,p_id_member_role => 2::int4
								,p_id_from_source => r_arj_supplier.ext_id::int4
								,p_subject_mention => l_id_mention
								,p_source_id => c_id_source::int4
								,p_customer_code => ''::text
								,p_etalon_registry_id => 0::int8
                            );
							
							call pkg_eor_contract_load.add_contract_subj_mention_dbg(l_id_mention, c_raise_notice);

                            --создаем упоминание адреса места проживания в РФ
                            case
							when r_arj_supplier.placeinrf_address is not null  
                            then
                            
                                l_addr_attr.address := r_arj_supplier.placeinrf_address;
                                l_address_mention_id := 
                                    pkg_eor_api.add_address_mention( 
                                         p_source_id => c_id_source::int4
                                        ,p_source_etalon_id => c_source_etalon_id::int4
                                        ,p_actual_date => arj_contract.actual_date::date
                                        ,p_attributes => l_addr_attr
                                        ,p_priority => l_priority::int2
                                    );
								
								call pkg_eor_contract_load.add_address_mention_dbg(l_address_mention_id, c_raise_notice);

                                -- добавляем упоминание связи
                                case
								when l_address_mention_id is not null 
                                then
                                
                                    l_subj_addr_mention_id := 
                                        pkg_eor_api.add_subj_address_mention( 
                                             p_source_id => c_id_source::int4
                                            ,p_source_etalon_id => c_source_etalon_id::int4
                                            ,p_actual_date => arj_contract.actual_date::date
                                            ,p_eor_subject_mention_id => l_id_mention
                                            ,p_eor_address_mention_id => l_address_mention_id
                                            ,p_address_type_id => 1::int4 -- адреса места проживания
                                            ,p_begin_date => null::date
                                            ,p_end_date => null::date
                                        );
									
									call pkg_eor_contract_load.add_subj_address_mention_dbg(l_subj_addr_mention_id, c_raise_notice);

								else null;
								end case;
                                
							else null;
							end case;

                            --создаем упоминание адреса места регистрации в стране регистрации
                            case
							when r_arj_supplier.placeinrf_address is not null  
                            then
                            
                                l_addr_attr.address := r_arj_supplier.placeinrf_address;
                                l_address_mention_id := 
                                    pkg_eor_api.add_address_mention( 
                                         p_source_id => c_id_source::int4
                                        ,p_source_etalon_id => c_source_etalon_id::int4
                                        ,p_actual_date => arj_contract.actual_date::date
                                        ,p_attributes => l_addr_attr
                                        ,p_priority => l_priority::int2
                                    );
								
								call pkg_eor_contract_load.add_address_mention_dbg(l_address_mention_id, c_raise_notice);

                                -- добавляем упоминание связи
                                case
								when l_address_mention_id is not null 
                                then
                                
                                    l_subj_addr_mention_id := 
                                        pkg_eor_api.add_subj_address_mention( 
                                             p_source_id => c_id_source::int4
                                            ,p_source_etalon_id => c_source_etalon_id::int4
                                            ,p_actual_date => arj_contract.actual_date::date
                                            ,p_eor_subject_mention_id => l_id_mention
                                            ,p_eor_address_mention_id => l_address_mention_id
                                            ,p_address_type_id => 2::int4 -- адрес места регистрации в стране регистрации
                                            ,p_begin_date => null::date
                                            ,p_end_date => null::date
                                    	);
									
									call pkg_eor_contract_load.add_subj_address_mention_dbg(l_subj_addr_mention_id, c_raise_notice);

								else null;
								end case;

							else null;
							end case;
                            
						else null;
						end case;

                    end loop;
                    
                when l_sup_type = 0 
                then
                    -- получен признак "Информация не будет размещена на официальном сайте ЕИС в соответствии с ч. 5 ст. 103 Федерального закона № 44-ФЗ"
                    null;
                else

					call process_info.save_error(
						 p_object_id => arj_contract.id_from_arj
						,p_workflow_id => p_process_data.workflow_id
						,p_state_id => p_process_data.state_id
						,p_sqlcode => '-20002'
						,p_sqlerrm => 'Неизвестный тип лица (исполнителя)'
						,p_sqlerr_stack => 'id_contract := [' || arj_contract.l_id_contract::text || '], load_id := [' || arj_contract.load_id::text || ']'
					);
	
	                update arch_ext.idwh2_arj_contract_gov_buffer set 
	                    is_proceeded = 2
	                where 
	                        id_contract = arj_contract.l_id_contract 
	                    and load_id = arj_contract.load_id
	                ;
	
	                continue;

                end case;
                
            else

				call process_info.save_error(
					 p_object_id => arj_contract.id_from_arj
					,p_workflow_id => p_process_data.workflow_id
					,p_state_id => p_process_data.state_id
					,p_sqlcode => '-20001'
					,p_sqlerrm => 'Версия XML ' || arj_contract.schemeversion::text || ' не поддерживается.'
					,p_sqlerr_stack => 'id_contract := [' || arj_contract.l_id_contract::text || '], load_id := [' || arj_contract.load_id::text || ']'
				);

                update arch_ext.idwh2_arj_contract_gov_buffer set 
                    is_proceeded = 2
                where 
                        id_contract = arj_contract.l_id_contract 
                    and load_id = arj_contract.load_id
                ;

                continue;

            end case;

			-- customer
			call pkg_eor_contract_load.log_level_2(
				 p_msg => '10. Создание упоминаний заказчика'
				,p_process_log_id => p_process_log_id::text
				,p_procedure => c_procedure
				,p_proc_data => p_process_data
			);
            
            case
			when arj_contract.id_customer is not null 
            then
            
                select 
					 fullname
					,inn
					,kpp
					,customer_code
					,c_id_source::text || load_id::text || id_customer::text as cust_external_h_id
                into strict 	
					 l_fullname
					,l_inn
					,l_kpp
					,l_customer_code
					,l_cust_h_id
                from arch_ext.idwh2_arj_customer_gov_buffer
                where 
                        id_customer = arj_contract.id_customer 
                    and load_id = arj_contract.load_id
                ;

                -- очищаем
                l_attr_rul := c_attr_rul_init;

                l_attr_rul.name_full := substr(l_fullname, 1, 1000);
                l_attr_rul.name_short := substr(l_fullname, 1, 1000);
                l_attr_rul.inn := substr(trim(l_inn), 1, 12);
                l_attr_rul.kpp := trim(l_kpp);

                begin
                
                    select a.eor_subject_mention_id 
                    into strict l_id_mention
                    from eor.idw_mr_subject_mention a
                    where 
                            a.source_id = c_id_source 
                        and a.external_h_id = l_cust_h_id
                    ;
                        
                exception
                when no_data_found 
                then
						
                        call pkg_eor_contract_load.log_level_2(
							 p_msg => '10.01. Создание упоминаний заказчика.'
							,p_process_log_id => p_process_log_id::text
							,p_procedure => c_procedure
							,p_proc_data => p_process_data
						);
                        
                        l_id_mention := 
                            pkg_eor_api.add_subj_rul_mention( 
                                 p_source_id => c_id_source::int4
                                ,p_source_etalon_id => c_source_etalon_id::int4
                                ,p_external_id => l_cust_h_id
                                ,p_external_h_id => l_cust_h_id --???
                                ,p_actual_date => arj_contract.actual_date::date
                                ,p_attributes => l_attr_rul
                                ,p_priority => l_priority::int2
                            );
						
						call pkg_eor_contract_load.add_subj_rul_mention_dbg(l_id_mention, c_raise_notice);
						    
                        call pkg_eor_contract_load.log_level_2(
							 p_msg => '10.02. Создание упоминаний заказчика.'
							,p_process_log_id => p_process_log_id::text
							,p_procedure => c_procedure
							,p_proc_data => p_process_data
						);
                        
                end;

                case
				when l_id_mention > 0 
                then
                
                    call pkg_eor_contract_load.add_contract_subj_mention( 
						 p_id_ba_contract => l_id_ba_contract
						,p_id_member_role => arj_contract.cust_id_member_role::int4
						,p_id_from_source => l_cust_h_id::int4
						,p_subject_mention => l_id_mention
						,p_source_id => c_id_source::int4
						,p_customer_code => l_customer_code
						,p_etalon_registry_id => (0)::bigint
                    );
					
					call pkg_eor_contract_load.add_contract_subj_mention_dbg(l_id_mention, c_raise_notice);
					
                    call pkg_eor_contract_load.log_level_2(
						 p_msg => '10.03. Создание упоминаний заказчика.'
						,p_process_log_id => p_process_log_id::text
						,p_procedure => c_procedure
						,p_proc_data => p_process_data
					);
                    
                else null;
				end case;
                
            else null;
			end case;

            -- subjects
            call pkg_eor_contract_load.log_level_2(
				 p_msg => '11. Вставка предметов контракта'
				,p_process_log_id => p_process_log_id::text
				,p_procedure => c_procedure
				,p_proc_data => p_process_data
			);
            
            for arj_product in (
				select
		             c.name as subject_name
					,d.code as okdp_code
					,d.name as okdp_name
					,f.code as okpd_code
					,f.name as okpd_name
					,e.code as okei_code
					,e.name as okei_name
					,c.price as unit_price
					,c.quantity
					,c.sum as amount
					,b.id_product as id_from_source
					,g.code as okpd2_code
					,g.name as okpd2_name
				from arch_ext.idwh2_arj_products_gov_buffer b
				inner join arch_ext.idwh2_arj_product_gov_buffer c on
						b.id_product = c.id_product 
					and b.load_id = c.load_id
				left join arch_ext.idwh2_arj_okdp_gov_buffer d on 
						c.id_okdp = d.id_okdp 
					and c.load_id = d.load_id
				left join arch_ext.idwh2_arj_okei_gov_buffer e on
						c.id_okei = e.id_okei 
					and c.load_id = e.load_id
				left join arch_ext.idwh2_arj_okpd_gov_buffer f on
						c.id_okpd = f.id_okpd 
					and c.load_id = f.load_id
				left join arch_ext.idwh2_arj_okpd_gov_buffer g on 
						c.id_okpd2 = g.id_okpd 
					and c.load_id = g.load_id
				where 
						b.id_products = arj_contract.id_products 
					and b.load_id = arj_contract.load_id
			)
            loop
            
                l_okei_code := 
					regexp_replace(arj_product.okei_code,'[^0-9]', '', 'g'); -- убираем не цифры
                
                case
				when l_okei_code is not null 
                then
                
                    l_id_nsi_sr_list := 183;
					
					call pkg_eor_contract_load.check_external_dict_link_prc(
						 p_code => l_okei_code
						,p_id_source => c_id_source
						,p_id_nsi_sr_list => l_id_nsi_sr_list
						,p_name => arj_product.okei_name
					);
                    
                else null;
				end case;

                case
				when arj_product.okdp_code is not null 
                then
                
                    l_id_nsi_sr_list := 182;
					
					call pkg_eor_contract_load.check_external_dict_link_prc(
						 p_code => arj_product.okdp_code
						,p_id_source => c_id_source
						,p_id_nsi_sr_list => l_id_nsi_sr_list
						,p_name => arj_product.okdp_name
					);
                    
                else null;
				end case;

                case
				when arj_product.okpd_code is not null 
                then
                
                    l_id_nsi_sr_list := 222;
					
					call pkg_eor_contract_load.check_external_dict_link_prc(
						 p_code => arj_product.okpd_code
						,p_id_source => c_id_source
						,p_id_nsi_sr_list => l_id_nsi_sr_list
						,p_name =>arj_product.okpd_name
					);
                    
                else null;
				end case;

                --начиная с версии 6.0 в предмете контракта указывается код ОКПД2 взамен устаревшему ОКПД
                --далее проводится перекодировка кода ОКПД в код ОКПД2
                case
				when 
						arj_product.okpd2_code is null 
					and arj_product.okpd_code is not null 
                then
                
                    begin
                            
                        select okpd2_code, okpd2_name 
                        into strict arj_product.okpd2_code, arj_product.okpd2_name
                        from (
                            select 
								 okpd2_code
								,okpd2_name
								,row_number() over(order by okpd2_id) as cnt
                            from eor.eor_okpd2_to_okpd2007_v
                            where okpd2007_code = arj_product.okpd_code
                        ) t
                        where cnt = 1
                        ;
                        
                    exception
                    when no_data_found 
                    then null;
                    end;
                    
                else null;
				end case;

                case
				when arj_product.okpd2_code is not null 
                then
                
                    l_id_nsi_sr_list := 304;
					
					call pkg_eor_contract_load.check_external_dict_link_prc(
						 p_code => arj_product.okpd2_code
						,p_id_source => c_id_source
						,p_id_nsi_sr_list => l_id_nsi_sr_list
						,p_name => arj_product.okpd2_name
					);
                    
                else null;
				end case;

                insert into eor.eor_ba_contract_subject(
                    subject_name, okdp_code, okdp_name, id_ba_contract,
                    id_measure, unit_price, quantity, amount,
                    id_from_source, okpd_code, okpd2_code
                )
                values(
                    arj_product.subject_name, arj_product.okdp_code, arj_product.okdp_name, l_id_ba_contract
                    ,l_okei_code::int8, arj_product.unit_price, arj_product.quantity, arj_product.amount
                    ,arj_product.id_from_source, arj_product.okpd_code, arj_product.okpd2_code
                );
                
            end loop;

            -- budgetary
            call pkg_eor_contract_load.log_level_2(
				 p_msg => '12. Вставка бюджетных вредств контракта'
				,p_process_log_id => p_process_log_id::text
				,p_procedure => c_procedure
				,p_proc_data => p_process_data
			);
            
            case
			when 
					arj_contract.id_finances is not null 
				and l_id_budgetary is not null 
            then
            
                for arj_budgetary in (
					select
			            a.kbk,
			            a.year,
			            a.month,
			            a.price,
			            a.comment_,
			            a.substageyear,
			            a.substagemonth,
			            a.id_budgetary as id_from_source,
			            a.kbk2016
			        from arch_ext.idwh2_arj_budgetary_gov_buffer a
			        where 
							a.id_budgetary = l_id_budgetary 
						and load_id = arj_contract.load_id
				)
                loop
                
                    insert into eor.eor_ba_budgetary(
                        id_ba_contract, kbk, year, month, price,
                        comment_, substageyear, substagemonth, id_from_source, kbk2016
                    )
                    values(
                        l_id_ba_contract, arj_budgetary.kbk, arj_budgetary.year, arj_budgetary.month, arj_budgetary.price,
                        arj_budgetary.comment_, arj_budgetary.substageyear, arj_budgetary.substagemonth, arj_budgetary.id_from_source, arj_budgetary.kbk2016
                    );
                    
                end loop;
                
            else null;
			end case;

            -- extrabudgetary
            call pkg_eor_contract_load.log_level_2(
				 p_msg => '13. Вставка внебюджетных вредств контракта'
				,p_process_log_id => p_process_log_id::text
				,p_procedure => c_procedure
				,p_proc_data => p_process_data
			);
            
            case
			when 
					arj_contract.id_finances is not null 
				and l_id_extrabudgetary is not null 
            then
            
                for arj_extrabudgetary in (
					select
			             a.kosgu
						,a.year
						,a.price
						,a.month
						,a.substagemonth
						,a.substageyear
						,a.id_extrabudgetary as id_from_source
						,a.kvr
			        from arch_ext.idwh2_arj_extrabudgetary_gov_buffer a
			        where 
							a.id_extrabudgetary = l_id_extrabudgetary 
						and load_id = arj_contract.load_id
				)
                loop
                
                    insert into eor.eor_ba_extrabudgetary(
                        id_ba_contract, kosgu, year, price,
                        month, substagemonth, substageyear, id_from_source, kvr
                    )
                    values(
                        l_id_ba_contract, arj_extrabudgetary.kosgu, arj_extrabudgetary.year, arj_extrabudgetary.price,
                        arj_extrabudgetary.month, arj_extrabudgetary.substagemonth, arj_extrabudgetary.substageyear, arj_extrabudgetary.id_from_source, arj_extrabudgetary.kvr
                    );
                    
                end loop;
                
            else null;
			end case;

			-- не нужно, чистим буфер
--            call pkg_eor_contract_load.log_level_2(
--				 p_msg => 'Обновление записи контракта в архивном слое'
--				,p_process_log_id => p_process_log_id::text
--				,p_procedure => c_procedure
--				,p_proc_data => p_process_data
--			);
			
			-- не нужно, чистим буфер
--            UPDATE IDWH2.IDWH2_ARJ_CONTRACT_GOV SET 
--                IS_PROCEEDED = 1
--            WHERE 
--                    LOAD_ID = ARJ_CONTRACT.LOAD_ID 
--                AND ID_CONTRACT = ARJ_CONTRACT.L_ID_CONTRACT
--            ;
			
            call pkg_eor_contract_load.log_level_2(
				 p_msg => '14. Переход к следующему контракту'
				,p_process_log_id => p_process_log_id::text
				,p_procedure => c_procedure
				,p_proc_data => p_process_data
			);

			-- удаляем запись о ошыбке... если она есть, если нет - издержки. удаление в общей процедуре - необходима доработка.
			delete from process_info.idw_sy_workflow_error e
	      	where 
					e.workflow_id = p_process_data.workflow_id
	        	and e.state_id  = p_process_data.state_id
	        	and e.object_id = arj_contract.id_from_arj
			;
			
			-- удаляем запись. завершено: "ЕОР: загрузка контрактов из архивного в буферный слой"
			delete from process_info.idw_sy_workflow_info 
			where 
					workflow_id = p_process_data.workflow_id
	        	and state_id  = p_process_data.state_id
	        	and object_id = arj_contract.id_from_arj
			;

			-- чистим буфер данных
			call eor.pr_eor_ba_contract_ins_load_buffer_del(
				p_id => arj_contract.id_from_arj
			);

		exception
		when others 
		then
		
			declare
		    	v_err_code text; -- SQLSTATE - код ошибки
		    	v_msg_text text; -- SQLERRM - текст ошибки
		    	v_context  text; -- стек вызовов
		    	v_detail   text;
		    	v_hint     text;
		   	begin
		    	
				GET STACKED DIAGNOSTICS
		    		v_err_code = RETURNED_SQLSTATE,    -- SQLSTATE - код ошибки
				 	v_msg_text = MESSAGE_TEXT,         -- SQLERRM - текст ошибки
		    	  	v_context  = PG_EXCEPTION_CONTEXT, -- стек вызовов
		    	  	v_detail   = PG_EXCEPTION_DETAIL,
		          	v_hint     = PG_EXCEPTION_HINT; 
		     
				call process_info.pr_helper_log(c_procedure , process_info.get_err_text(v_err_code, v_msg_text, v_detail, v_hint, v_context), p_process_log_id::text);
		     	call process_info.save_error(arj_contract.id_from_arj, p_process_data.workflow_id, p_process_data.state_id,  v_err_code, v_msg_text, v_context);

		   	end;

		end;

	end loop;

exception
when others 
then

	declare
    	v_err_code text; -- SQLSTATE - код ошибки
    	v_msg_text text; -- SQLERRM - текст ошибки
    	v_context  text; -- стек вызовов
    	v_detail   text;
    	v_hint     text;
   	begin
    	
		GET STACKED DIAGNOSTICS
    		v_err_code = RETURNED_SQLSTATE,    -- SQLSTATE - код ошибки
		 	v_msg_text = MESSAGE_TEXT,         -- SQLERRM - текст ошибки
    	  	v_context  = PG_EXCEPTION_CONTEXT, -- стек вызовов
    	  	v_detail   = PG_EXCEPTION_DETAIL,
          	v_hint     = PG_EXCEPTION_HINT; 
     
		call process_info.pr_helper_log(
			 c_procedure 
			,process_info.get_err_text(v_err_code, v_msg_text, v_detail, v_hint, v_context)
			,p_process_log_id::text
		);

     	call process_manage.write_error(
			 p_process_log_id 	-- ИД процесса
			,'Ошибка обработки пачки' 	
			,process_info.get_err_text(v_err_code, v_msg_text, v_detail, v_hint, v_context)
			,'Ошибки'
		);
	
	end;

	raise;

end;
$procedure$
;

-- Permissions

ALTER PROCEDURE eor.pr_eor_ba_contract_ins_load_batch(_text, process_info.process_state, int8) OWNER TO r_fors_db_owner;
GRANT ALL ON PROCEDURE eor.pr_eor_ba_contract_ins_load_batch(_text, process_info.process_state, int8) TO r_fors_db_owner;

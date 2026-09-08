-- DROP PROCEDURE eor.pr_eor_ba_contract_ins_load_buffer(_text, int8);

CREATE OR REPLACE PROCEDURE eor.pr_eor_ba_contract_ins_load_buffer(IN p_ids text[], IN p_process_log_id bigint)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $procedure$ 
declare
	c_workflow_id constant process_info.idw_sy_workflow_info.workflow_id%type := 104;
	c_state_id constant process_info.idw_sy_workflow_info.state_id%type := 1041;
	l_ids text[];
	c_procedure constant text := 'fors_pg.eor.pr_eor_ba_contract_ins_load_buffer';
begin autonomous

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

	case
	when coalesce(cardinality(l_ids),0) = 0
	then return;
	else null;
	end case;

	-- arch_pg.zakupkigov.idwh2_arj_contract_gov
	insert into arch_ext.idwh2_arj_contract_gov_buffer(
		id_contract, id_currency, id_finances, protocoldate, id_suppliers,
		id_customer, publishdate, documentbase, id_printform, id_products,
		id, id_foundation, signdate, regnum, id_execution, 
		id_modification, number_, versionnumber, price, load_id,
		id_pricechangereason, id_singlecustomerreason, id_scandocuments, href, currentcontractstage,
		regnum807, is_proceeded, fz, actual_date, create_date,
		fileid, price_currency, schemeversion, defensecontractnumber, bsupp_contr_reqinfo,
		contract_subject, priceinfo_pricetype, priceinfo_pricevat, subcontractors_pricevaluerur, subcontractors_suminpercents,
		enf_ca_amountrur, qgi_fromdate, qgi_todate, qgi_otherperiodtext, qgi_warrantyreqstext,
		st14_npainfo, st14_requirementtype, st14_npainfo_xlm, is_not_published_suppliers, is_closed,
		is_load
	)
	select  
		id_contract, id_currency, id_finances, protocoldate, id_suppliers,
		id_customer, publishdate, documentbase, id_printform, id_products,
		id, id_foundation, signdate, regnum, id_execution, 
		id_modification, number_, versionnumber, price, load_id,
		id_pricechangereason, id_singlecustomerreason, id_scandocuments, href, currentcontractstage,
		regnum807, is_proceeded, fz, actual_date, create_date,
		fileid, price_currency, schemeversion, defensecontractnumber, bsupp_contr_reqinfo,
		contract_subject, priceinfo_pricetype, priceinfo_pricevat, subcontractors_pricevaluerur, subcontractors_suminpercents,
		enf_ca_amountrur, qgi_fromdate, qgi_todate, qgi_otherperiodtext, qgi_warrantyreqstext,
		st14_npainfo, st14_requirementtype, st14_npainfo_xlm, is_not_published_suppliers, is_closed,
		is_load
	from arch_ext.idwh2_arj_contract_gov
	where 
			(id_contract, load_id) in (
				select
					 (regexp_substr(id,'[^.]+',1,1))::int8 
					,(regexp_substr(id,'[^.]+',1,2))::int8
				from (select unnest(l_ids) as id)
			)
	on conflict on constraint idwh2_arj_contract_gov_buffer_pk do nothing;

	-- arch_ext.idwh2_arj_finances_gov_buffer
	insert into arch_ext.idwh2_arj_finances_gov_buffer(
		id_finances, id_extrabudgetary, financesource, id_extrabudget, id_budgetary,
		id_budget, load_id, id_budgetlevel, is_load
	)
	select distinct
		g.id_finances, g.id_extrabudgetary, g.financesource, g.id_extrabudget, g.id_budgetary,
		g.id_budget, g.load_id, g.id_budgetlevel, g.is_load
	from arch_ext.idwh2_arj_contract_gov_buffer gb
	inner join arch_ext.idwh2_arj_finances_gov g on
			g.id_finances = gb.id_finances
		and g.load_id = gb.load_id
	where
			(gb.id_contract, gb.load_id) in (
				select
					 (regexp_substr(id,'[^.]+',1,1))::int8 
					,(regexp_substr(id,'[^.]+',1,2))::int8
				from (select unnest(l_ids) as id)
			)
	on conflict on constraint idwh2_arj_finances_gov_buffer_pk do nothing;

	-- arch_ext.idwh2_arj_budget_gov_buffer
	insert into arch_ext.idwh2_arj_budget_gov_buffer(
		id_budget, code, name, load_id, level_,
		fin_bf_oktmo_code, fin_bf_oktmo_name, is_load
	)
	select distinct
		g.id_budget, g.code, g.name, g.load_id, g.level_,
		g.fin_bf_oktmo_code, g.fin_bf_oktmo_name, g.is_load
	from arch_ext.idwh2_arj_contract_gov_buffer gb
	inner join arch_ext.idwh2_arj_finances_gov_buffer t on
			t.id_finances = gb.id_finances
		and t.load_id = gb.load_id
	inner join arch_ext.idwh2_arj_budget_gov g on
			g.id_budget = t.id_budget
		and g.load_id = t.load_id
	where
			(gb.id_contract, gb.load_id) in (
				select
					 (regexp_substr(id,'[^.]+',1,1))::int8 
					,(regexp_substr(id,'[^.]+',1,2))::int8
				from (select unnest(l_ids) as id)
			)
	on conflict on constraint idwh2_arj_budget_gov_buffer_pk do nothing;

	-- arch_ext.idwh2_arj_budgetlevel_gov_buffer
	insert into arch_ext.idwh2_arj_budgetlevel_gov_buffer(
		id_budgetlevel, code, name, load_id, is_load
	)
	select distinct
		g.id_budgetlevel, g.code, g.name, g.load_id, g.is_load
	from arch_ext.idwh2_arj_contract_gov_buffer gb
	inner join arch_ext.idwh2_arj_finances_gov_buffer t on
			t.id_finances = gb.id_finances
		and t.load_id = gb.load_id
	inner join arch_ext.idwh2_arj_budgetlevel_gov g on
			g.id_budgetlevel = t.id_budgetlevel
		and g.load_id = t.load_id
	where
			(gb.id_contract, gb.load_id) in (
				select
					 (regexp_substr(id,'[^.]+',1,1))::int8 
					,(regexp_substr(id,'[^.]+',1,2))::int8
				from (select unnest(l_ids) as id)
			)
	on conflict on constraint idwh2_arj_budgetlevel_gov_buffer_pk do nothing;

	-- arch_ext.idwh2_arj_extrabudget_gov_buffer
	insert into arch_ext.idwh2_arj_extrabudget_gov_buffer(
		id_extrabudget, name, code, load_id, is_load
	)
	select distinct
		g.id_extrabudget, g.name, g.code, g.load_id, g.is_load
	from arch_ext.idwh2_arj_contract_gov_buffer gb
	inner join arch_ext.idwh2_arj_finances_gov_buffer t on
			t.id_finances = gb.id_finances
		and t.load_id = gb.load_id
	inner join arch_ext.idwh2_arj_extrabudget_gov g on
			g.id_extrabudget = t.id_extrabudget
		and g.load_id = t.load_id
	where
			(gb.id_contract, gb.load_id) in (
				select
					 (regexp_substr(id,'[^.]+',1,1))::int8 
					,(regexp_substr(id,'[^.]+',1,2))::int8
				from (select unnest(l_ids) as id)
			)
	on conflict on constraint idwh2_arj_extrabudget_gov_buffer_pk do nothing;

	--arch_ext.idwh2_arj_modification_gov_buffer
	insert into arch_ext.idwh2_arj_modification_gov_buffer(
		id_modification, description, type, base, load_id,
		is_load
	)
	select distinct
		g.id_modification, g.description, g.type, g.base, g.load_id,
		g.is_load
	from arch_ext.idwh2_arj_contract_gov_buffer gb
	inner join arch_ext.idwh2_arj_modification_gov g on
			g.id_modification = gb.id_modification
		and g.load_id = gb.load_id
	where
			(gb.id_contract, gb.load_id) in (
				select
					 (regexp_substr(id,'[^.]+',1,1))::int8 
					,(regexp_substr(id,'[^.]+',1,2))::int8
				from (select unnest(l_ids) as id)
			)
	on conflict on constraint idwh2_arj_modification_gov_buffer_pk do nothing;

	--arch_ext.idwh2_arj_foundation_gov_buffer
	insert into arch_ext.idwh2_arj_foundation_gov_buffer(
		id_foundation, singlecustomer, other, id_order, load_id,
		id_other, is_load
	)
	select distinct
		g.id_foundation, g.singlecustomer, g.other, g.id_order, g.load_id,
		g.id_other, g.is_load
	from arch_ext.idwh2_arj_contract_gov_buffer gb
	inner join arch_ext.idwh2_arj_foundation_gov g on
			g.id_foundation = gb.id_foundation
		and g.load_id = gb.load_id
	where
			(gb.id_contract, gb.load_id) in (
				select
					 (regexp_substr(id,'[^.]+',1,1))::int8 
					,(regexp_substr(id,'[^.]+',1,2))::int8
				from (select unnest(l_ids) as id)
			)
	on conflict on constraint idwh2_arj_foundation_gov_buffer_pk do nothing;

	--arch_ext.idwh2_arj_order_gov_buffer
	insert into arch_ext.idwh2_arj_order_gov_buffer(
		id_order, notificationnumber, lotnumber, "placing", id_foundation,
		load_id, is_load
	)
	select distinct
		g.id_order, g.notificationnumber, g.lotnumber, g.placing, g.id_foundation,
		g.load_id, g.is_load
	from arch_ext.idwh2_arj_contract_gov_buffer gb
	inner join arch_ext.idwh2_arj_foundation_gov_buffer t on
			t.id_foundation = gb.id_foundation
		and t.load_id = gb.load_id
	inner join arch_ext.idwh2_arj_order_gov g on
			g.id_order = t.id_order
		and g.load_id = t.load_id
	where
			(gb.id_contract, gb.load_id) in (
				select
					 (regexp_substr(id,'[^.]+',1,1))::int8 
					,(regexp_substr(id,'[^.]+',1,2))::int8
				from (select unnest(l_ids) as id)
			)
	on conflict on constraint idwh2_arj_order_gov_buffer_unique do nothing;

	--arch_ext.idwh2_arj_singlecust_rsn_gov_buffer
	insert into arch_ext.idwh2_arj_singlecust_rsn_gov_buffer(
		id_singlecustomerreason, id, name, load_id, is_load
	)
	select distinct
		g.id_singlecustomerreason, g.id, g.name, g.load_id, g.is_load
	from arch_ext.idwh2_arj_contract_gov_buffer gb
	inner join arch_ext.idwh2_arj_singlecust_rsn_gov g on
			g.id_singlecustomerreason = gb.id_singlecustomerreason
		and g.load_id = gb.load_id
	where
			(gb.id_contract, gb.load_id) in (
				select
					 (regexp_substr(id,'[^.]+',1,1))::int8 
					,(regexp_substr(id,'[^.]+',1,2))::int8
				from (select unnest(l_ids) as id)
			)
	on conflict on constraint idwh2_arj_singlecust_rsn_gov_buffer_pk do nothing;

	--arch_ext.idwh2_arj_currency_gov_buffer
	insert into arch_ext.idwh2_arj_currency_gov_buffer(
		id_currency, code, name, load_id, currency_rate,
		currency_raiting, is_load
	)
	select distinct
		g.id_currency, g.code, g.name, g.load_id, g.currency_rate,
		g.currency_raiting, g.is_load
	from arch_ext.idwh2_arj_contract_gov_buffer gb
	inner join arch_ext.idwh2_arj_currency_gov g on
			g.id_currency = gb.id_currency
		and g.load_id = gb.load_id
	where
			(gb.id_contract, gb.load_id) in (
				select
					 (regexp_substr(id,'[^.]+',1,1))::int8 
					,(regexp_substr(id,'[^.]+',1,2))::int8
				from (select unnest(l_ids) as id)
			)
	on conflict on constraint idwh2_arj_currency_gov_buffer_pk do nothing;

	-- arch_ext.idwh2_arj_execution_gov_buffer
	insert into arch_ext.idwh2_arj_execution_gov_buffer(
		id_execution, month, year, load_id, execdate,
		documentname, documentnum, documentdate, paid, product,
		id_q_cntr_sbjcts, is_load
	)
	select distinct
		g.id_execution, g.month, g.year, g.load_id, g.execdate,
		g.documentname, g.documentnum, g.documentdate, g.paid, g.product,
		g.id_q_cntr_sbjcts, g.is_load
	from arch_ext.idwh2_arj_contract_gov_buffer gb
	inner join arch_ext.idwh2_arj_execution_gov g on
			g.id_execution = gb.id_execution
		and g.load_id = gb.load_id
	where
			(gb.id_contract, gb.load_id) in (
				select
					 (regexp_substr(id,'[^.]+',1,1))::int8 
					,(regexp_substr(id,'[^.]+',1,2))::int8
				from (select unnest(l_ids) as id)
			)
	on conflict on constraint idwh2_arj_execution_gov_buffer_pk do nothing;

	-- arch_ext.idwh2_arj_pricechange_rsn_gov_buffer
	insert into arch_ext.idwh2_arj_pricechange_rsn_gov_buffer(
		id_pricechangereason, id, name, comment_, load_id, 
		is_load
	)
	select distinct
		g.id_pricechangereason, g.id, g.name, g.comment_, g.load_id, 
		g.is_load
	from arch_ext.idwh2_arj_contract_gov_buffer gb
	inner join arch_ext.idwh2_arj_pricechange_rsn_gov g on
			g.id_pricechangereason = gb.id_pricechangereason
		and g.load_id = gb.load_id
	where
			(gb.id_contract, gb.load_id) in (
				select
					 (regexp_substr(id,'[^.]+',1,1))::int8 
					,(regexp_substr(id,'[^.]+',1,2))::int8
				from (select unnest(l_ids) as id)
			)
	on conflict on constraint idwh2_arj_pricechange_rsn_gov_buffer_pk do nothing;

	--arch_ext.idwh2_arj_sup_ul_gov_buffer
	insert into arch_ext.idwh2_arj_sup_ul_gov_buffer(
		id_legalentityrf, id_contract, load_id, legalform_code, legalform_singularname,
		fullname, shortname, firmname, status, contractprice,
		okpo, inn, kpp, registrationdate, oktmo_code,
		oktmo_name, address, contactinfo_lastname, contactinfo_firstname, contactinfo_middlename,
		contactemail, contactphone, is_load
	)
	select distinct
		g.id_legalentityrf, g.id_contract, g.load_id, g.legalform_code, g.legalform_singularname,
		g.fullname, g.shortname, g.firmname, g.status, g.contractprice,
		g.okpo, g.inn, g.kpp, g.registrationdate, g.oktmo_code,
		g.oktmo_name, g.address, g.contactinfo_lastname, g.contactinfo_firstname, g.contactinfo_middlename,
		g.contactemail, g.contactphone, g.is_load
	from arch_ext.idwh2_arj_contract_gov_buffer gb
	inner join arch_ext.idwh2_arj_sup_ul_gov g on
			g.id_contract = gb.id_contract
		and g.load_id = gb.load_id
	where
			(gb.id_contract, gb.load_id) in (
				select
					 (regexp_substr(id,'[^.]+',1,1))::int8 
					,(regexp_substr(id,'[^.]+',1,2))::int8
				from (select unnest(l_ids) as id)
			)
	on conflict on constraint idwh2_arj_sup_ul_gov_buffer_pk do nothing;

	--arch_ext.idwh2_arj_sup_fl_gov_buffer 
	insert into arch_ext.idwh2_arj_sup_fl_gov_buffer(
		id_individualpersonrf, id_contract, load_id, lastname, firstname,
		middlename, inn, isip, registrationdate, oktmo_code,
		oktmo_name, address, contactemail, contactphone, ogrnip,
		is_culture, is_load
	)
	select distinct
		g.id_individualpersonrf, g.id_contract, g.load_id, g.lastname, g.firstname,
		g.middlename, g.inn, g.isip, g.registrationdate, g.oktmo_code,
		g.oktmo_name, g.address, g.contactemail, g.contactphone, g.ogrnip,
		g.is_culture, g.is_load
	from arch_ext.idwh2_arj_contract_gov_buffer gb
	inner join arch_ext.idwh2_arj_sup_fl_gov g on
			g.id_contract = gb.id_contract
		and g.load_id = gb.load_id
	where
			(gb.id_contract, gb.load_id) in (
				select
					 (regexp_substr(id,'[^.]+',1,1))::int8 
					,(regexp_substr(id,'[^.]+',1,2))::int8
				from (select unnest(l_ids) as id)
			)
	on conflict on constraint idwh2_arj_sup_fl_gov_buffer_pk do nothing;

	--arch_ext.idwh2_arj_sup_ulnr_gov_buffer
	insert into arch_ext.idwh2_arj_sup_ulnr_gov_buffer(
		id_legalentityforeignstate, id_contract, load_id, fullname, shortname,
		firmname, fullnamelat, taxpayercode, reginrf_inn, reginrf_kpp,
		reginrf_regdate, placeinreg_country_code, placeinreg_country_name, placeinreg_address, placeinreg_contactemail,
		placeinreg_contactphone, placeinrf_oktmo_code, placeinrf_oktmo_name, placeinrf_address, placeinrf_contactemail,
		placeinrf_contactphone, is_load
	)
	select distinct
		g.id_legalentityforeignstate, g.id_contract, g.load_id, g.fullname, g.shortname,
		g.firmname, g.fullnamelat, g.taxpayercode, g.reginrf_inn, g.reginrf_kpp,
		g.reginrf_regdate, g.placeinreg_country_code, g.placeinreg_country_name, g.placeinreg_address, g.placeinreg_contactemail,
		g.placeinreg_contactphone, g.placeinrf_oktmo_code, g.placeinrf_oktmo_name, g.placeinrf_address, g.placeinrf_contactemail,
		g.placeinrf_contactphone, g.is_load
	from arch_ext.idwh2_arj_contract_gov_buffer gb
	inner join arch_ext.idwh2_arj_sup_ulnr_gov g on
			g.id_contract = gb.id_contract
		and g.load_id = gb.load_id
	where
			(gb.id_contract, gb.load_id) in (
				select
					 (regexp_substr(id,'[^.]+',1,1))::int8 
					,(regexp_substr(id,'[^.]+',1,2))::int8
				from (select unnest(l_ids) as id)
			)
	on conflict on constraint idwh2_arj_sup_ulnr_gov_buffer_pk do nothing;

	--arch_ext.idwh2_arj_sup_flnr_gov_buffer
	insert into arch_ext.idwh2_arj_sup_flnr_gov_buffer(
		id_ipforeignstate, id_contract, load_id, lastname, firstname,
		middlename, lastnamelat, firstnamelat, middlenamelat, taxpayercode,
		reginrf_inn, reginrf_regdate, placeinreg_country_code, placeinreg_country_name, placeinreg_address,
		placeinreg_contactemail, placeinreg_contactphone, placeinrf_oktmo_code, placeinrf_oktmo_name, placeinrf_address,
		placeinrf_contactemail, placeinrf_contactphone, is_load
	)
	select distinct
		g.id_ipforeignstate, g.id_contract, g.load_id, g.lastname, g.firstname,
		g.middlename, g.lastnamelat, g.firstnamelat, g.middlenamelat, g.taxpayercode,
		g.reginrf_inn, g.reginrf_regdate, g.placeinreg_country_code, g.placeinreg_country_name, g.placeinreg_address,
		g.placeinreg_contactemail, g.placeinreg_contactphone, g.placeinrf_oktmo_code, g.placeinrf_oktmo_name, g.placeinrf_address,
		g.placeinrf_contactemail, g.placeinrf_contactphone, g.is_load
	from arch_ext.idwh2_arj_contract_gov_buffer gb
	inner join arch_ext.idwh2_arj_sup_flnr_gov g on
			g.id_contract = gb.id_contract
		and g.load_id = gb.load_id
	where
			(gb.id_contract, gb.load_id) in (
				select
					 (regexp_substr(id,'[^.]+',1,1))::int8 
					,(regexp_substr(id,'[^.]+',1,2))::int8
				from (select unnest(l_ids) as id)
			)
	on conflict on constraint idwh2_arj_sup_flnr_gov_buffer_pk do nothing;

	--arch_ext.idwh2_arj_suppliers_gov_buffer
	insert into arch_ext.idwh2_arj_suppliers_gov_buffer (
		id_suppliers, id_supplier, load_id, is_load
	)
	select distinct
		g.id_suppliers, g.id_supplier, g.load_id, g.is_load
	from arch_ext.idwh2_arj_contract_gov_buffer gb
	inner join arch_ext.idwh2_arj_suppliers_gov g on
			g.id_suppliers = gb.id_suppliers
		and g.load_id = gb.load_id
	where
			(gb.id_contract, gb.load_id) in (
				select
					 (regexp_substr(id,'[^.]+',1,1))::int8 
					,(regexp_substr(id,'[^.]+',1,2))::int8
				from (select unnest(l_ids) as id)
			)
	on conflict on constraint idwh2_arj_suppliers_gov_buffer_pk do nothing;

	--arch_ext.idwh2_arj_supplier_gov_buffer
	insert into arch_ext.idwh2_arj_supplier_gov_buffer (
		id_supplier, id_contactinfo, organizationform, id_country, factualaddress,
		contactphone, postaddress, contactemail, inn, organizationname,
		contactfax, participanttype, kpp, additionalinfo, load_id,
		id_number, id_numberextension, person_id, paddress_id, faddress_id,
		id_legalform, status, is_load
	)
	select distinct
		g.id_supplier, g.id_contactinfo, g.organizationform, g.id_country, g.factualaddress,
		g.contactphone, g.postaddress, g.contactemail, g.inn, g.organizationname,
		g.contactfax, g.participanttype, g.kpp, g.additionalinfo, g.load_id,
		g.id_number, g.id_numberextension, g.person_id, g.paddress_id, g.faddress_id,
		g.id_legalform, g.status, g.is_load
	from arch_ext.idwh2_arj_contract_gov_buffer gb
	inner join arch_ext.idwh2_arj_suppliers_gov_buffer s on
			s.id_suppliers = gb.id_suppliers
		and s.load_id = gb.load_id
	inner join arch_ext.idwh2_arj_supplier_gov g on
			g.id_supplier = s.id_supplier
		and g.load_id = s.load_id
	where
			(gb.id_contract, gb.load_id) in (
				select
					 (regexp_substr(id,'[^.]+',1,1))::int8 
					,(regexp_substr(id,'[^.]+',1,2))::int8
				from (select unnest(l_ids) as id)
			)
	on conflict on constraint idwh2_arj_supplier_gov_buffer_pk do nothing;
 
	--arch_ext.idwh2_arj_contactinfo_gov_buffer
	insert into arch_ext.idwh2_arj_contactinfo_gov_buffer (
		id_contactinfo, firstname, middlename, lastname, load_id,
		person_id, is_load
	)
	select distinct
		g.id_contactinfo, g.firstname, g.middlename, g.lastname, g.load_id,
		g.person_id, g.is_load
	from arch_ext.idwh2_arj_contract_gov_buffer gb
	inner join arch_ext.idwh2_arj_suppliers_gov_buffer s on
			s.id_suppliers = gb.id_suppliers
		and s.load_id = gb.load_id
	inner join arch_ext.idwh2_arj_supplier_gov_buffer t on
			t.id_supplier = s.id_supplier
		and t.load_id = s.load_id
	inner join arch_ext.idwh2_arj_contactinfo_gov g on
			g.id_contactinfo = t.id_contactinfo
		and g.load_id = t.load_id
	where
			(gb.id_contract, gb.load_id) in (
				select
					 (regexp_substr(id,'[^.]+',1,1))::int8 
					,(regexp_substr(id,'[^.]+',1,2))::int8
				from (select unnest(l_ids) as id)
			)
	on conflict on constraint idwh2_arj_contactinfo_gov_buffer_pk do nothing;

	--arch_ext.idwh2_arj_country_gov_buffer
	insert into arch_ext.idwh2_arj_country_gov_buffer (
		id_country, countrycode, countryfullname, load_id, is_load
	)
	select distinct
		g.id_country, g.countrycode, g.countryfullname, g.load_id, g.is_load
	from arch_ext.idwh2_arj_contract_gov_buffer gb
	inner join arch_ext.idwh2_arj_suppliers_gov_buffer s on
			s.id_suppliers = gb.id_suppliers
		and s.load_id = gb.load_id
	inner join arch_ext.idwh2_arj_supplier_gov_buffer t on
			t.id_supplier = s.id_supplier
		and t.load_id = s.load_id
	inner join arch_ext.idwh2_arj_country_gov g on
			g.id_country = t.id_country
		and g.load_id = t.load_id
	where
			(gb.id_contract, gb.load_id) in (
				select
					 (regexp_substr(id,'[^.]+',1,1))::int8 
					,(regexp_substr(id,'[^.]+',1,2))::int8
				from (select unnest(l_ids) as id)
			)
	on conflict on constraint idwh2_arj_country_gov_buffer_pk do nothing;	

	-- arch_ext.idwh2_arj_customer_gov_buffer
	insert into arch_ext.idwh2_arj_customer_gov_buffer (
		id_customer, regnum, kpp, fullname, tofk,
		inn, load_id, person_id, customer_code, is_load
	)
	select distinct
		g.id_customer, g.regnum, g.kpp, g.fullname, g.tofk,
		g.inn, g.load_id, g.person_id, g.customer_code, g.is_load
	from arch_ext.idwh2_arj_contract_gov_buffer gb
	inner join arch_ext.idwh2_arj_customer_gov g on
			g.id_customer = gb.id_customer
		and g.load_id = gb.load_id
	where
			(gb.id_contract, gb.load_id) in (
				select
					 (regexp_substr(id,'[^.]+',1,1))::int8 
					,(regexp_substr(id,'[^.]+',1,2))::int8
				from (select unnest(l_ids) as id)
			)
	on conflict on constraint idwh2_arj_customer_gov_buffer_pk do nothing;

	-- arch_ext.idwh2_arj_products_gov_buffer
	insert into arch_ext.idwh2_arj_products_gov_buffer (
		id_products, id_product, load_id, is_load
	)
	select distinct
		g.id_products, g.id_product, g.load_id, g.is_load
	from arch_ext.idwh2_arj_contract_gov_buffer gb
	inner join arch_ext.idwh2_arj_products_gov g on
			g.id_products = gb.id_products
		and g.load_id = gb.load_id
	where
			(gb.id_contract, gb.load_id) in (
				select
					 (regexp_substr(id,'[^.]+',1,1))::int8 
					,(regexp_substr(id,'[^.]+',1,2))::int8
				from (select unnest(l_ids) as id)
			)
	on conflict on constraint idwh2_arj_products_gov_buffer_pk do nothing;

	-- arch_ext.idwh2_arj_product_gov_buffer
	insert into arch_ext.idwh2_arj_product_gov_buffer (
		id_product, name, quantity, id_country, id_okdp,
		sum, price, id_okei, load_id, sid,
		id_okpd, fullname, id_okpd2, is_load
	)
	select distinct
		g.id_product, g.name, g.quantity, g.id_country, g.id_okdp,
		g.sum, g.price, g.id_okei, g.load_id, g.sid,
		g.id_okpd, g.fullname, g.id_okpd2, g.is_load
	from arch_ext.idwh2_arj_contract_gov_buffer gb
	inner join arch_ext.idwh2_arj_products_gov t on
			t.id_products = gb.id_products
		and t.load_id = gb.load_id
	inner join arch_ext.idwh2_arj_product_gov g on
			g.id_product = t.id_product
		and g.load_id = t.load_id
	where
			(gb.id_contract, gb.load_id) in (
				select
					 (regexp_substr(id,'[^.]+',1,1))::int8 
					,(regexp_substr(id,'[^.]+',1,2))::int8
				from (select unnest(l_ids) as id)
			)
	on conflict on constraint idwh2_arj_product_gov_buffer_pk do nothing;

	-- arch_ext.idwh2_arj_okdp_gov_buffer
	insert into arch_ext.idwh2_arj_okdp_gov_buffer (
		id_okdp, code, name, load_id
	)
	select distinct
		g.id_okdp, g.code, g.name, g.load_id
	from arch_ext.idwh2_arj_contract_gov_buffer gb
	inner join arch_ext.idwh2_arj_products_gov t on
			t.id_products = gb.id_products
		and t.load_id = gb.load_id
	inner join arch_ext.idwh2_arj_product_gov tt on
			tt.id_product = t.id_product
		and tt.load_id = t.load_id
	inner join arch_ext.idwh2_arj_okdp_gov g on
			g.id_okdp = tt.id_okdp
		and g.load_id = tt.load_id
	where
			(gb.id_contract, gb.load_id) in (
				select
					 (regexp_substr(id,'[^.]+',1,1))::int8 
					,(regexp_substr(id,'[^.]+',1,2))::int8
				from (select unnest(l_ids) as id)
			)
	on conflict on constraint idwh2_arj_okdp_gov_buffer_pk do nothing;

	-- arch_ext.idwh2_arj_okei_gov_buffer
	insert into arch_ext.idwh2_arj_okei_gov_buffer (
		id_okei, name, code, load_id, is_load
	)
	select distinct
		g.id_okei, g.name, g.code, g.load_id, g.is_load
	from arch_ext.idwh2_arj_contract_gov_buffer gb
	inner join arch_ext.idwh2_arj_products_gov t on
			t.id_products = gb.id_products
		and t.load_id = gb.load_id
	inner join arch_ext.idwh2_arj_product_gov tt on
			tt.id_product = t.id_product
		and tt.load_id = t.load_id
	inner join arch_ext.idwh2_arj_okei_gov g on
			g.id_okei = tt.id_okei
		and g.load_id = tt.load_id
	where
			(gb.id_contract, gb.load_id) in (
				select
					 (regexp_substr(id,'[^.]+',1,1))::int8 
					,(regexp_substr(id,'[^.]+',1,2))::int8
				from (select unnest(l_ids) as id)
			)
	on conflict on constraint idwh2_arj_okei_gov_buffer_pk do nothing;

	-- arch_ext.idwh2_arj_okpd_gov_buffer
	insert into arch_ext.idwh2_arj_okpd_gov_buffer (
		id_okpd, code, name, load_id, is_load
	)
	select distinct
		g.id_okpd, g.code, g.name, g.load_id, g.is_load
	from arch_ext.idwh2_arj_contract_gov_buffer gb
	inner join arch_ext.idwh2_arj_products_gov t on
			t.id_products = gb.id_products
		and t.load_id = gb.load_id
	inner join arch_ext.idwh2_arj_product_gov tt on
			tt.id_product = t.id_product
		and tt.load_id = t.load_id
	inner join arch_ext.idwh2_arj_okpd_gov g on
			g.id_okpd = tt.id_okpd
		and g.load_id = tt.load_id
	where
			(gb.id_contract, gb.load_id) in (
				select
					 (regexp_substr(id,'[^.]+',1,1))::int8 
					,(regexp_substr(id,'[^.]+',1,2))::int8
				from (select unnest(l_ids) as id)
			)
	on conflict on constraint idwh2_arj_okpd_gov_buffer_pk do nothing;

	-- arch_ext.idwh2_arj_extrabudgetary_gov_buffer
	insert into arch_ext.idwh2_arj_extrabudgetary_gov_buffer(
		id_extrabudgetary, year, price, month, kosgu,
		load_id, substagemonth, substageyear, kvr, is_load
	)
	select distinct
		g.id_extrabudgetary, g.year, g.price, g.month, g.kosgu,
		g.load_id, g.substagemonth, g.substageyear, g.kvr, g.is_load
	from arch_ext.idwh2_arj_contract_gov_buffer gb
	inner join arch_ext.idwh2_arj_finances_gov_buffer t on
			t.id_finances = gb.id_finances
		and t.load_id = gb.load_id
	inner join arch_ext.idwh2_arj_extrabudgetary_gov g on
			g.id_extrabudgetary = t.id_extrabudgetary
		and g.load_id = t.load_id
	where
			(gb.id_contract, gb.load_id) in (
				select
					 (regexp_substr(id,'[^.]+',1,1))::int8 
					,(regexp_substr(id,'[^.]+',1,2))::int8
				from (select unnest(l_ids) as id)
			)
	on conflict on constraint idwh2_arj_extrabudgetary_gov_buffer_pk do nothing;

	-- arch_ext.idwh2_arj_budgetary_gov_buffer
	insert into arch_ext.idwh2_arj_budgetary_gov_buffer(
		id_budgetary, kbk, year, month, price,
		comment_, load_id, substageyear, substagemonth, kbk2016,
		is_load
	)
	select distinct
		g.id_budgetary, g.kbk, g.year, g.month, g.price,
		g.comment_, g.load_id, g.substageyear, g.substagemonth, g.kbk2016,
		g.is_load
	from arch_ext.idwh2_arj_contract_gov_buffer gb
	inner join arch_ext.idwh2_arj_finances_gov_buffer t on
			t.id_finances = gb.id_finances
		and t.load_id = gb.load_id
	inner join arch_ext.idwh2_arj_budgetary_gov g on
			g.id_budgetary = t.id_budgetary
		and g.load_id = t.load_id
	where
			(gb.id_contract, gb.load_id) in (
				select
					 (regexp_substr(id,'[^.]+',1,1))::int8 
					,(regexp_substr(id,'[^.]+',1,2))::int8
				from (select unnest(l_ids) as id)
			)
	on conflict on constraint idwh2_arj_budgetary_gov_buffer_pk do nothing;

	-- TODO

	-- признак загрузки данных архивного слоя arch_pg в fors_pg -- TODO
	insert into arch_ext.idwh2_arj_contract_gov_load_buffer(
		 id
		,create_date
	)
	select 
		 a.id
		,clock_timestamp()
	from (select unnest(l_ids) as id) a
	on conflict on constraint idwh2_arj_fl_egrn_load_buffer_pk do nothing;

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
$procedure$
;

-- Permissions

ALTER PROCEDURE eor.pr_eor_ba_contract_ins_load_buffer(_text, int8) OWNER TO r_fors_db_owner;
GRANT ALL ON PROCEDURE eor.pr_eor_ba_contract_ins_load_buffer(_text, int8) TO r_fors_db_owner;

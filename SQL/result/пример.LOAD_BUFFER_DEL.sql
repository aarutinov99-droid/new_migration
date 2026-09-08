-- DROP PROCEDURE eor.pr_eor_ba_contract_ins_load_buffer_del(text);

CREATE OR REPLACE PROCEDURE eor.pr_eor_ba_contract_ins_load_buffer_del(IN p_id text)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $procedure$ 
declare
	c_workflow_id constant process_info.idw_sy_workflow_info.workflow_id%type := 104;
	c_state_id constant process_info.idw_sy_workflow_info.state_id%type := 1041;
	l_cnt int4;
	l_id_contract arch_ext.idwh2_arj_contract_gov_buffer.id_contract%type;
	l_load_id arch_ext.idwh2_arj_contract_gov_buffer.load_id%type;
begin

	select count(8)
	into l_cnt
	from process_info.idw_sy_workflow_error
	where
			workflow_id = c_workflow_id
		and state_id = c_state_id
		and object_id = p_id
	;

	case
	when l_cnt = 0
	then null;
	else return;
	end case;

	l_id_contract := (regexp_substr(p_id,'[^.]+',1,1))::int8;
	l_load_id := (regexp_substr(p_id,'[^.]+',1,2))::int8;

	select sum(cnt)
	into l_cnt
	from(
		select count(8) as cnt
		from process_info.idw_sy_workflow_error
		where
				workflow_id = c_workflow_id
			and state_id = c_state_id
			and (regexp_substr(object_id,'[^.]+',1,2))::int8 = l_load_id
		union all
		select count(8)
		from process_info.idw_sy_workflow_info
		where
				workflow_id = c_workflow_id
			and state_id = c_state_id
			and (regexp_substr(object_id,'[^.]+',1,2))::int8 = l_load_id
	);
	
	case
	when l_cnt = 0
	then

		-- arch_ext.idwh2_arj_extrabudget_gov_buffer
		delete from arch_ext.idwh2_arj_extrabudget_gov_buffer
		where load_id = l_load_id;
 
		-- arch_ext.idwh2_arj_budgetlevel_gov_buffer
		delete from arch_ext.idwh2_arj_budgetlevel_gov_buffer
		where load_id = l_load_id;

		-- arch_ext.idwh2_arj_budget_gov_buffer
		delete from arch_ext.idwh2_arj_budget_gov_buffer
		where load_id = l_load_id;

		-- arch_ext.idwh2_arj_finances_gov_buffer
		delete from arch_ext.idwh2_arj_finances_gov_buffer
		where load_id = l_load_id;

		-- arch_ext.idwh2_arj_modification_gov_buffer
		delete from arch_ext.idwh2_arj_modification_gov_buffer
		where load_id = l_load_id;

		-- arch_ext.idwh2_arj_order_gov_buffer
		delete from arch_ext.idwh2_arj_order_gov_buffer 
		where load_id = l_load_id;

		-- arch_ext.idwh2_arj_foundation_gov_buffer
		delete from arch_ext.idwh2_arj_foundation_gov_buffer 
		where load_id = l_load_id;

		-- arch_ext.idwh2_arj_singlecust_rsn_gov_buffer
		delete from arch_ext.idwh2_arj_singlecust_rsn_gov_buffer 
		where load_id = l_load_id;

		-- arch_ext.idwh2_arj_currency_gov_buffer
		delete from arch_ext.idwh2_arj_currency_gov_buffer 
		where load_id = l_load_id;

		-- arch_ext.idwh2_arj_execution_gov_buffer
		delete from arch_ext.idwh2_arj_execution_gov_buffer
		where load_id = l_load_id;

		-- arch_ext.idwh2_arj_pricechange_rsn_gov_buffer
		delete from arch_ext.idwh2_arj_pricechange_rsn_gov_buffer
		where load_id = l_load_id;

		-- arch_ext.idwh2_arj_supplier_gov_buffer
		delete from arch_ext.idwh2_arj_supplier_gov_buffer
		where load_id = l_load_id;

		-- arch_ext.idwh2_arj_suppliers_gov_buffer
		delete from arch_ext.idwh2_arj_suppliers_gov_buffer
		where load_id = l_load_id;
 
		-- arch_ext.idwh2_arj_contactinfo_gov_buffer
		delete from arch_ext.idwh2_arj_contactinfo_gov_buffer
		where load_id = l_load_id;

		-- arch_ext.idwh2_arj_country_gov_buffer
		delete from arch_ext.idwh2_arj_country_gov_buffer
		where load_id = l_load_id;

		-- arch_ext.idwh2_arj_customer_gov_buffer
		delete from arch_ext.idwh2_arj_customer_gov_buffer
		where load_id = l_load_id;

		-- arch_ext.idwh2_arj_products_gov_buffer
		delete from arch_ext.idwh2_arj_products_gov_buffer
		where load_id = l_load_id;

		-- arch_ext.idwh2_arj_product_gov_buffer
		delete from arch_ext.idwh2_arj_product_gov_buffer
		where load_id = l_load_id;

		-- arch_ext.idwh2_arj_okdp_gov_buffer
		delete from arch_ext.idwh2_arj_okdp_gov_buffer
		where load_id = l_load_id;

		-- arch_ext.idwh2_arj_okei_gov_buffer
		delete from arch_ext.idwh2_arj_okei_gov_buffer
		where load_id = l_load_id;

		-- arch_ext.idwh2_arj_okpd_gov_buffer
		delete from arch_ext.idwh2_arj_okpd_gov_buffer
		where load_id = l_load_id;

		-- arch_ext.idwh2_arj_extrabudgetary_gov_buffer
		delete from arch_ext.idwh2_arj_extrabudgetary_gov_buffer
		where load_id = l_load_id;

		-- arch_ext.idwh2_arj_budgetary_gov_buffer
		delete from arch_ext.idwh2_arj_budgetary_gov_buffer
		where load_id = l_load_id;

	else null;
	end case;

	--	arch_ext.idwh2_arj_sup_ul_gov_buffer
	delete from arch_ext.idwh2_arj_sup_ul_gov_buffer
	where 
			id_contract = l_id_contract
		and load_id = l_load_id
	;

	--	arch_ext.idwh2_arj_sup_fl_gov_buffer 
	delete from arch_ext.idwh2_arj_sup_fl_gov_buffer
	where 
			id_contract = l_id_contract
		and load_id = l_load_id
	;

	--	arch_ext.idwh2_arj_sup_ulnr_gov_buffer
	delete from arch_ext.idwh2_arj_sup_ulnr_gov_buffer
	where 
			id_contract = l_id_contract
		and load_id = l_load_id
	;

	--	arch_ext.idwh2_arj_sup_flnr_gov_buffer
	delete from arch_ext.idwh2_arj_sup_flnr_gov_buffer
	where 
			id_contract = l_id_contract
		and load_id = l_load_id
	;

	-- TODO

	delete from arch_ext.idwh2_arj_contract_gov_buffer
	where 
			id_contract = l_id_contract
		and load_id = l_load_id
	;

	delete from arch_ext.idwh2_arj_contract_gov_load_buffer
	where id = p_id
	;

end;
$procedure$
;

-- Permissions

ALTER PROCEDURE eor.pr_eor_ba_contract_ins_load_buffer_del(text) OWNER TO r_fors_db_owner;
GRANT ALL ON PROCEDURE eor.pr_eor_ba_contract_ins_load_buffer_del(text) TO r_fors_db_owner;

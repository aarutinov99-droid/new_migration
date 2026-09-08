-- DROP PROCEDURE eor.pr_eor_pdl_load_buffer_del(text);

CREATE OR REPLACE PROCEDURE eor.pr_eor_pdl_load_buffer_del(IN p_id bigint)
LANGUAGE plpgsql
SECURITY DEFINER
AS $procedure$ 
DECLARE
    c_workflow_id CONSTANT process_info.idw_sy_workflow_info.workflow_id%type := 255;
    c_state_id CONSTANT process_info.idw_sy_workflow_info.state_id%type := 2551;
    l_cnt int4;
    l_system_id arch_ext.idw_arj_interfax_pdl_buffer.system_id%type;
    l_load_id arch_ext.idw_arj_interfax_pdl_buffer.load_id%type;
BEGIN
    -- Проверка наличия ошибок в workflow
    SELECT COUNT(8)
    INTO l_cnt
    FROM process_info.idw_sy_workflow_error
    WHERE workflow_id = c_workflow_id
      AND state_id = c_state_id
      AND object_id = p_id::text;
    
    -- Если есть ошибки, выходим
    IF l_cnt > 0 THEN
        RETURN;
    END IF;

    -- Чтение system_id и load_id
	select system_id,load_id into l_system_id,l_load_id from arch_ext.idw_arj_interfax_pdl_buffer a where id=p_id;
	
    -- Проверка наличия других записей с таким же id
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

    -- Если нет других записей с таким load_id, очищаем все дочерние таблицы
    IF l_cnt = 0 THEN
        -- Очистка дочерних таблиц PDL
        -- arch_ext.idw_arj_pdl_categories_buffer
        DELETE FROM arch_ext.idw_arj_pdl_categories_buffer
        WHERE load_id = l_load_id
          AND system_id = l_system_id;

        -- arch_ext.idw_arj_pdl_category407_buffer
        DELETE FROM arch_ext.idw_arj_pdl_category407_buffer
        WHERE load_id = l_load_id
          AND system_id = l_system_id;

        -- arch_ext.idw_arj_pdl_countries_buffer
        DELETE FROM arch_ext.idw_arj_pdl_countries_buffer
        WHERE load_id = l_load_id
          AND system_id = l_system_id;

        -- arch_ext.idw_arj_pdl_jobs_buffer
        DELETE FROM arch_ext.idw_arj_pdl_jobs_buffer
        WHERE load_id = l_load_id
          AND system_id = l_system_id;

        -- arch_ext.idw_arj_pdl_names_buffer
        DELETE FROM arch_ext.idw_arj_pdl_names_buffer
        WHERE load_id = l_load_id
          AND system_id = l_system_id;

        -- arch_ext.idw_arj_pdl_sanctions_buffer
        DELETE FROM arch_ext.idw_arj_pdl_sanctions_buffer
        WHERE load_id = l_load_id
          AND system_id = l_system_id;

        -- arch_ext.idw_arj_pdl_sanlists_buffer
        DELETE FROM arch_ext.idw_arj_pdl_sanlists_buffer
        WHERE load_id = l_load_id
          AND system_id = l_system_id;

        -- arch_ext.idw_arj_pdl_translit_names_buffer
        DELETE FROM arch_ext.idw_arj_pdl_translit_names_buffer
        WHERE load_id = l_load_id
          AND system_id = l_system_id;

    ELSE
        NULL;
    END IF;

    -- Очистка основной таблицы буфера
    DELETE FROM arch_ext.idw_arj_interfax_pdl_buffer a
    WHERE a.id=p_id	;

END;
$procedure$;

-- Права доступа
ALTER PROCEDURE eor.pr_eor_pdl_load_buffer_del(text) OWNER TO r_fors_db_owner;
GRANT ALL ON PROCEDURE eor.pr_eor_pdl_load_buffer_del(text) TO r_fors_db_owner;


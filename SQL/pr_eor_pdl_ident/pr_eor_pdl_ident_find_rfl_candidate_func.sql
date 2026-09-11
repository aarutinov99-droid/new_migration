-- =============================================================================
-- Функция поиска кандидатов РФЛ (бывшая встроенная процедура find_rfl_candidate)
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

    -- Очистка временной таблицы
    DELETE FROM eor.tmp_eor_ident_candidate;

    -- По ФИО и дате рождения (точное совпадение)
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
	 
    -- По ФИО (точное совпадение)
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

SELECT *  FROM plpgsql_check_function('eor.pr_eor_pdl_ident_find_rfl_candidate_func(TEXT,DATE)');

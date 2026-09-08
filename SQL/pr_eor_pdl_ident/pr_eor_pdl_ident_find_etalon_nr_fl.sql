
-- =============================================================================
-- Функция поиска эталонной записи для НР ФЛ
-- =============================================================================
CREATE OR REPLACE FUNCTION IDWH2.pr_eor_pdl_ident_find_etalon_nr_fl(
    p_full_name      TEXT,
    p_birth_date     DATE,
    p_etalon_sign    CHAR(1)
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    l_etalon_registry_id INTEGER;
BEGIN
    BEGIN
        SELECT m.etalon_registry_id INTO l_etalon_registry_id
          FROM (
                SELECT MAX(m.etalon_registry_id) AS etalon_registry_id,
                       COUNT(1) AS c
                  FROM tmp_eor_ident_candidate t
                  JOIN idwh2.idwh2_etalon_nr_fl m ON t.etalon_registry_id = m.etalon_registry_id
                  JOIN idwh2.idw_mr_master mm ON m.etalon_registry_id = mm.etalon_registry_id
                 WHERE m.full_name = TRIM(UPPER(p_full_name))
                   AND (p_birth_date IS NULL OR m.birth_date = p_birth_date)
                   AND mm.etalon_sign = p_etalon_sign
               ) sub
         WHERE sub.c = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            l_etalon_registry_id := NULL;
    END;
    
    RETURN l_etalon_registry_id;
END;
$$;
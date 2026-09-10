-- =============================================================================
-- Функция поиска кандидатов РФЛ (бывшая встроенная процедура find_rfl_candidate)
-- =============================================================================
CREATE OR REPLACE FUNCTION IDWH2.pr_eor_pdl_ident_find_rfl_candidate_func(
    p_full_name        TEXT,
    p_birth_date       DATE
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    l_max_cnt   CONSTANT INTEGER := 1000;
    p_find_id   INTEGER;
BEGIN
    p_find_id := nextval('seq_find_candidate');

    -- Очистка временной таблицы
    DELETE FROM eor.tmp_eor_ident_candidate;

    -- По ФИО и дате рождения (точное совпадение)
    INSERT INTO eor.tmp_eor_ident_candidate (
        find_candidate_id,
        etalon_registry_id,
        eor_h_id,
        weight
    )
    SELECT p_find_id,
           res.etalon_registry_id,
           res.eor_h_id,
           1.0 / (1 + log(10, res.cnt))
      FROM (
            SELECT m.etalon_registry_id,
                   m.eor_h_id,
                   COUNT(1) OVER () AS cnt
              FROM idwh2.idw_mr_master m
              JOIN idwh2.idwh2_etalon_flrn f ON f.etalon_registry_id = m.etalon_registry_id
             WHERE f.birth_date = p_birth_date
               AND f.full_name = p_full_name
               AND m.deleted_sign = '0'
           ) res
     WHERE res.cnt <= l_max_cnt
    ON CONFLICT (find_candidate_id, etalon_registry_id) DO UPDATE
       SET weight = EXCLUDED.weight + 1.0 / (1 + log(10, EXCLUDED.cnt));

    -- По ФИО (точное совпадение)
    INSERT INTO eor.tmp_eor_ident_candidate (
        find_candidate_id,
        etalon_registry_id,
        eor_h_id,
        weight
    )
    SELECT p_find_id,
           res.etalon_registry_id,
           res.eor_h_id,
           1.0 / (1 + log(10, res.cnt))
      FROM (
            SELECT m.etalon_registry_id,
                   m.eor_h_id,
                   COUNT(1) OVER () AS cnt
              FROM idwh2.idw_mr_master m
              JOIN idwh2.idwh2_etalon_flrn f ON f.etalon_registry_id = m.etalon_registry_id
             WHERE f.full_name = p_full_name
               AND m.deleted_sign = '0'
           ) res
     WHERE res.cnt <= l_max_cnt
    ON CONFLICT (find_candidate_id, etalon_registry_id) DO UPDATE
       SET weight = EXCLUDED.weight + 1.0 / (1 + log(10, EXCLUDED.cnt));

    RETURN p_find_id;

EXCEPTION
    WHEN OTHERS THEN
        RAISE;
END;
$$;
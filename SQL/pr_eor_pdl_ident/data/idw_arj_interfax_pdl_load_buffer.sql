-- =============================================================================
-- Тестовые данные для arch_ext.idw_arj_interfax_pdl_load_buffer
-- Контроль наличия: WHERE NOT EXISTS по id
-- =============================================================================

INSERT INTO arch_ext.idw_arj_interfax_pdl_load_buffer (
    id,
    sr_subject_id,
    create_date
)
SELECT v.*
FROM (VALUES
	 (5,2830258,'2026-09-11 12:13:29.568018'::timestamp),
	 (6,2830259,'2026-09-11 12:13:29.586687'::timestamp),
	 (1,2830260,'2026-09-11 12:13:29.588961'::timestamp),
	 (2,2830261,'2026-09-11 12:13:29.591059'::timestamp),
	 (3,2830262,'2026-09-11 12:13:29.595232'::timestamp),
	 (4,2830263,'2026-09-11 12:13:29.597316'::timestamp)
) AS v(id, sr_subject_id, create_date)
WHERE NOT EXISTS (
    SELECT 1 FROM arch_ext.idw_arj_interfax_pdl_load_buffer t
     WHERE t.id = v.id
);


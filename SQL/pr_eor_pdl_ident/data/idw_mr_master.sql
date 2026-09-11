-- =============================================================================
-- 1. Тестовые данные для eor.idw_mr_master
-- =============================================================================
INSERT INTO eor.idw_mr_master (
    master_id, etalon_registry_id, name, status, er_type_id, is_actual,
    risk_level, attention_level, feature_count, subject_type,
    ko_sign, ip_sign, nr_sign, filial_sign, head_org_id,
    name_full, name_short, inn, ogrn, bic, swift, start_date,
    eor_h_id, eor_h_date, etalon_sign, manual_sign, deleted_sign,
    eor_change_id, object_change_role_id, local_change_type_id,
    rating, rating_date
)
SELECT v.*
FROM (VALUES
-- 2830258: МИФТАХЕТДИНОВ РАШИТ МИДХАТОВИЧ (эталонная)
(1000019, 2830258, 'МИФТАХЕТДИНОВ РАШИТ МИДХАТОВИЧ', 1, 1, 1, 65, 75, 35, 2,
 '0','0','0','0', NULL::bigint,
 'МИФТАХЕТДИНОВ РАШИТ МИДХАТОВИЧ','МИФТАХЕТДИНОВ Р.М.','051234567912',
 NULL::text,NULL::text,NULL::text, '1982-07-09 00:00:00'::timestamp,
 9000019, '2026-09-11 12:13:29.567797'::timestamp, '1','0','0',
 5000019, 1, 1, 82, '2026-09-11 12:13:29.567797'::timestamp),

-- 2830259: МИХАЙЛЯНЦ АЛЕКСАНДР АНАТОЛЬЕВИЧ (неэталонная)
(1000020, 2830259, 'МИХАЙЛЯНЦ АЛЕКСАНДР АНАТОЛЬЕВИЧ', 1, 1, 1, 70, 85, 40, 2,
 '0','0','0','0', NULL::bigint,
 'МИХАЙЛЯНЦ АЛЕКСАНДР АНАТОЛЬЕВИЧ','МИХАЙЛЯНЦ А.А.','051234567913',
 NULL::text,NULL::text,NULL::text, '1971-01-30 00:00:00'::timestamp,
 9000020, '2026-09-11 12:13:29.586583'::timestamp, '0','0','0',
 5000020, 1, 1, 78, '2026-09-11 12:13:29.586583'::timestamp),

-- 2830260: МИРЗАХАНОВ ФИЗУЛИ МАГОМЕДКЕРИМОВИЧ (эталонная)
(1000021, 2830260, 'МИРЗАХАНОВ ФИЗУЛИ МАГОМЕДКЕРИМОВИЧ', 1, 1, 1, 75, 80, 45, 2,
 '0','0','0','0', NULL::bigint,
 'МИРЗАХАНОВ ФИЗУЛИ МАГОМЕДКЕРИМОВИЧ','МИРЗАХАНОВ Ф.М.','051234567914',
 NULL::text,NULL::text,NULL::text, '1978-10-26 00:00:00'::timestamp,
 9000021, '2026-09-11 12:13:29.588865'::timestamp, '1','0','0',
 5000021, 1, 1, 85, '2026-09-11 12:13:29.588865'::timestamp),

-- 2830261: МИРЗОЕВ ФЕЙРУЗ МУРАДОВИЧ (эталонная)
(1000022, 2830261, 'МИРЗОЕВ ФЕЙРУЗ МУРАДОВИЧ', 1, 1, 1, 60, 70, 30, 2,
 '0','0','0','0', NULL::bigint,
 'МИРЗОЕВ ФЕЙРУЗ МУРАДОВИЧ','МИРЗОЕВ Ф.М.','051234567915',
 NULL::text,NULL::text,NULL::text, '1989-11-25 00:00:00'::timestamp,
 9000022, '2026-09-11 12:13:29.590968'::timestamp, '1','0','0',
 5000022, 1, 1, 80, '2026-09-11 12:13:29.590968'::timestamp),

-- 2830262: МИТАЛАЕВ ЛЕЧИ ЖАНАДИЕВИЧ (неэталонная)
(1000023, 2830262, 'МИТАЛАЕВ ЛЕЧИ ЖАНАДИЕВИЧ', 1, 1, 1, 55, 65, 25, 2,
 '0','0','0','0', NULL::bigint,
 'МИТАЛАЕВ ЛЕЧИ ЖАНАДИЕВИЧ','МИТАЛАЕВ Л.Ж.','051234567916',
 NULL::text,NULL::text,NULL::text, '1955-09-25 00:00:00'::timestamp,
 9000023, '2026-09-11 12:13:29.592997'::timestamp, '0','0','0',
 5000023, 1, 1, 75, '2026-09-11 12:13:29.592997'::timestamp),

-- 2830263: МИТАЛАЕВ ХУСЕЙН УМАРОВИЧ (неэталонная)
(1000024, 2830263, 'МИТАЛАЕВ ХУСЕЙН УМАРОВИЧ', 1, 1, 1, 50, 60, 20, 2,
 '0','0','0','0', NULL::bigint,
 'МИТАЛАЕВ ХУСЕЙН УМАРОВИЧ','МИТАЛАЕВ Х.У.','051234567917',
 NULL::text,NULL::text,NULL::text, '1977-02-13 00:00:00'::timestamp,
 9000024, '2026-09-11 12:13:29.597226'::timestamp, '0','0','0',
 5000024, 1, 1, 70, '2026-09-11 12:13:29.597226'::timestamp)
) AS v(
    master_id, etalon_registry_id, name, status, er_type_id, is_actual,
    risk_level, attention_level, feature_count, subject_type,
    ko_sign, ip_sign, nr_sign, filial_sign, head_org_id,
    name_full, name_short, inn, ogrn, bic, swift, start_date,
    eor_h_id, eor_h_date, etalon_sign, manual_sign, deleted_sign,
    eor_change_id, object_change_role_id, local_change_type_id,
    rating, rating_date
)
WHERE NOT EXISTS (
    SELECT 1 FROM eor.idw_mr_master t
     WHERE t.etalon_registry_id = v.etalon_registry_id
);

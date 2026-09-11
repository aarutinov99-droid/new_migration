-- =============================================================================
-- 4. Тестовые данные для eor.sr_subject
-- Создаём только 3 записи — для покрытия ветки UPDATE.
-- Остальные 3 (2830259, 2830261, 2830263) процедура вставит сама.
-- =============================================================================
INSERT INTO eor.sr_subject (
    sr_subject_id, etalon_registry_id, eor_subject_mention_id,
    incl_first_date, incl_date, incl_reason, excl_reason,
    deleted_sign, sr_type_id, actual_sign, checked_sign, sr_event_id
)
SELECT v.*
FROM (VALUES
(2830258, NULL::bigint, NULL::bigint,
 '2026-09-11 12:13:29.567797'::timestamp, '2026-09-11 12:13:29.567797'::timestamp,
 'X-Complince', NULL::text, '0', 145, '1', '0', NULL::bigint),

(2830260, NULL::bigint, NULL::bigint,
 '2026-09-11 12:13:29.588865'::timestamp, '2026-09-11 12:13:29.588865'::timestamp,
 'X-Complince', NULL::text, '0', 145, '1', '0', NULL::bigint),

(2830262, NULL::bigint, NULL::bigint,
 '2026-09-11 12:13:29.592997'::timestamp, '2026-09-11 12:13:29.592997'::timestamp,
 'X-Complince', NULL::text, '0', 145, '1', '0', NULL::bigint)
) AS v(
    sr_subject_id, etalon_registry_id, eor_subject_mention_id,
    incl_first_date, incl_date, incl_reason, excl_reason,
    deleted_sign, sr_type_id, actual_sign, checked_sign, sr_event_id
)
WHERE NOT EXISTS (
    SELECT 1 FROM eor.sr_subject t
     WHERE t.sr_subject_id = v.sr_subject_id
       AND t.sr_type_id    = v.sr_type_id
);
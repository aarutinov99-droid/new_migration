-- =====================================================
-- ТЕСТОВЫЕ ДАННЫЕ ДЛЯ pdl.idw_arj_pdl_sanlists
-- С проверкой на существование через NOT EXISTS
-- Контроль по create_user = 'test_user'
-- =====================================================

INSERT INTO pdl.idw_arj_pdl_sanlists (
    load_id,
    system_id,
    updated_at,
    sanlist_id,
    sanlist,
    create_date,
    create_user,
    is_load
)
SELECT
    load_id,
    system_id,
    updated_at,
    sanlist_id,
    sanlist,
    create_date,
    create_user,
    is_load
FROM (
    VALUES
        (
            1567806034,
            '736867',
            '2015-05-24 12:52:10 UTC'::timestamp,
            4,
            'Росфинмониторинг (Россия)',
            now(),
            'test_user',
            false
        ),
        (
            1567806034,
            '736868',
            '2015-05-24 12:52:11 UTC'::timestamp,
            4,
            'Росфинмониторинг (Россия)',
            now(),
            'test_user',
            false
        ),
        (
            1567806034,
            '736872',
            '2015-05-24 12:52:13 UTC'::timestamp,
            4,
            'Росфинмониторинг (Россия)',
            now(),
            'test_user',
            false
        ),
        (
            1567806034,
            '736873',
            '2015-05-24 12:52:13 UTC'::timestamp,
            4,
            'Росфинмониторинг (Россия)',
            now(),
            'test_user',
            false
        ),
        (
            1567806034,
            '736875',
            '2015-06-19 12:16:30 UTC'::timestamp,
            4,
            'Росфинмониторинг (Россия)',
            now(),
            'test_user',
            false
        ),
        (
            1567806034,
            '736876',
            '2015-06-19 12:16:31 UTC'::timestamp,
            4,
            'Росфинмониторинг (Россия)',
            now(),
            'test_user',
            false
        )
) AS src (
    load_id,
    system_id,
    updated_at,
    sanlist_id,
    sanlist,
    create_date,
    create_user,
    is_load
)
WHERE NOT EXISTS (
    SELECT 1
    FROM pdl.idw_arj_pdl_sanlists t
    WHERE t.load_id = src.load_id
      AND t.system_id = src.system_id
      AND COALESCE(t.updated_at::text, '') = COALESCE(src.updated_at::text, '')
      AND COALESCE(t.sanlist_id::text, '') = COALESCE(src.sanlist_id::text, '')
      AND COALESCE(t.sanlist, '') = COALESCE(src.sanlist, '')
      AND t.create_user = 'test_user'
);


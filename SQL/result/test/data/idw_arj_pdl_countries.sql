-- =====================================================
-- ТЕСТОВЫЕ ДАННЫЕ ДЛЯ pdl.idw_arj_pdl_countries
-- С проверкой на существование через NOT EXISTS
-- Контроль по create_user = 'test_user'
-- =====================================================

INSERT INTO pdl.idw_arj_pdl_countries (
    load_id,
    system_id,
    updated_at,
    iso,
    en,
    country_name,
    create_date,
    create_user,
    is_load
)
SELECT
    load_id,
    system_id,
    updated_at,
    iso,
    en,
    country_name,
    create_date,
    create_user,
    is_load
FROM (
    VALUES
        (
            1567806034,
            '736867',
            '2020-04-01 14:28:12 UTC'::timestamp,
            'RU',
            'Russia',
            'Россия',
            now(),
            'test_user',
            false
        ),
        (
            1567806034,
            '736868',
            '2020-04-01 14:17:09 UTC'::timestamp,
            'RU',
            'Russia',
            'Россия',
            now(),
            'test_user',
            false
        ),
        (
            1567806034,
            '736872',
            '2015-05-24 12:52:13 UTC'::timestamp,
            'RU',
            'Russia',
            'Россия',
            now(),
            'test_user',
            false
        ),
        (
            1567806034,
            '736873',
            '2020-04-01 14:36:41 UTC'::timestamp,
            'RU',
            'Russia',
            'Россия',
            now(),
            'test_user',
            false
        ),
        (
            1567806034,
            '736875',
            '2015-05-24 12:52:14 UTC'::timestamp,
            'RU',
            'Russia',
            'Россия',
            now(),
            'test_user',
            false
        ),
        (
            1567806034,
            '736876',
            '2015-05-24 12:52:15 UTC'::timestamp,
            'RU',
            'Russia',
            'Россия',
            now(),
            'test_user',
            false
        )
) AS src (
    load_id,
    system_id,
    updated_at,
    iso,
    en,
    country_name,
    create_date,
    create_user,
    is_load
)
WHERE NOT EXISTS (
    SELECT 1
    FROM pdl.idw_arj_pdl_countries t
    WHERE t.load_id = src.load_id
      AND t.system_id = src.system_id
      AND COALESCE(t.updated_at::text, '') = COALESCE(src.updated_at::text, '')
      AND COALESCE(t.iso, '') = COALESCE(src.iso, '')
      AND COALESCE(t.en, '') = COALESCE(src.en, '')
      AND COALESCE(t.country_name, '') = COALESCE(src.country_name, '')
      AND t.create_user = 'test_user'
);


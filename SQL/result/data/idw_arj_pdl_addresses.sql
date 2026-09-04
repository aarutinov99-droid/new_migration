-- =====================================================
-- ТЕСТОВЫЕ ДАННЫЕ ДЛЯ pdl.idw_arj_pdl_addresses
-- С проверкой на существование через NOT EXISTS
-- Контроль по create_user = 'test_user'
-- =====================================================

INSERT INTO pdl.idw_arj_pdl_addresses (
    load_id,
    system_id,
    updated_at,
    city,
    address,
    create_date,
    create_user,
    is_load
)
SELECT
    load_id,
    system_id,
    updated_at,
    city,
    address,
    create_date,
    create_user,
    is_load
FROM (
    VALUES
        (
            1567806034,
            '736867',
            '2020-01-01 00:00:00'::timestamp,
            'Москва',
            'ул. Тверская, д. 10, кв. 5',
            now(),
            'test_user',
            false
        ),
        (
            1567806034,
            '736867',
            '2020-01-01 00:00:00'::timestamp,
            'Московская область',
            'г. Красногорск, ул. Ленина, д. 15, кв. 78',
            now(),
            'test_user',
            false
        ),
        (
            1567806034,
            '736868',
            '2023-03-17 17:08:27 UTC'::timestamp,
            'Санкт-Петербург',
            'Невский пр., д. 20, кв. 15',
            now(),
            'test_user',
            false
        ),
        (
            1567806034,
            '736872',
            '2015-05-24 12:52:13 UTC'::timestamp,
            'Москва',
            'ул. Арбат, д. 5, кв. 12',
            now(),
            'test_user',
            false
        ),
        (
            1567806034,
            '736873',
            '2020-04-01 14:36:41 UTC'::timestamp,
            'Грозный',
            'ул. Победы, д. 10, кв. 3',
            now(),
            'test_user',
            false
        ),
        (
            1567806034,
            '736875',
            '2015-05-24 12:52:14 UTC'::timestamp,
            'Уфа',
            'ул. Ленина, д. 25, кв. 7',
            now(),
            'test_user',
            false
        ),
        (
            1567806034,
            '736876',
            '2015-05-24 12:52:15 UTC'::timestamp,
            'Москва',
            'ул. Большая Дмитровка, д. 15, кв. 42',
            now(),
            'test_user',
            false
        )
) AS src (
    load_id,
    system_id,
    updated_at,
    city,
    address,
    create_date,
    create_user,
    is_load
)
WHERE NOT EXISTS (
    SELECT 1
    FROM pdl.idw_arj_pdl_addresses t
    WHERE t.load_id = src.load_id
      AND t.system_id = src.system_id
      AND COALESCE(t.updated_at::text, '') = COALESCE(src.updated_at::text, '')
      AND COALESCE(t.city, '') = COALESCE(src.city, '')
      AND COALESCE(t.address, '') = COALESCE(src.address, '')
      AND t.create_user = 'test_user'
);

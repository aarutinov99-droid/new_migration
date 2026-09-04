-- =====================================================
-- ТЕСТОВЫЕ ДАННЫЕ ДЛЯ pdl.idw_arj_pdl_contact_infos
-- С проверкой на существование через NOT EXISTS
-- Контроль по create_user = 'test_user'
-- =====================================================

INSERT INTO pdl.idw_arj_pdl_contact_infos (
    load_id,
    system_id,
    updated_at,
    type,
    contact_infos,
    create_date,
    create_user,
    is_load
)
SELECT
    load_id,
    system_id,
    updated_at,
    type,
    contact_infos,
    create_date,
    create_user,
    is_load
FROM (
    VALUES
        (
            1567806034,
            '736867',
            '2020-01-01 00:00:00'::timestamp,
            'Телефон',
            '+7 495 123-45-67',
            now(),
            'test_user',
            false
        ),
        (
            1567806034,
            '736867',
            '2020-01-01 00:00:00'::timestamp,
            'Email',
            'mirzakhanov@example.com',
            now(),
            'test_user',
            false
        ),
        (
            1567806034,
            '736868',
            '2023-03-17 17:08:27 UTC'::timestamp,
            'Телефон',
            '+7 812 987-65-43',
            now(),
            'test_user',
            false
        ),
        (
            1567806034,
            '736872',
            '2015-05-24 12:52:13 UTC'::timestamp,
            'Телефон',
            '+7 495 555-12-34',
            now(),
            'test_user',
            false
        ),
        (
            1567806034,
            '736873',
            '2020-04-01 14:36:41 UTC'::timestamp,
            'Телефон',
            '+7 871 222-33-44',
            now(),
            'test_user',
            false
        ),
        (
            1567806034,
            '736875',
            '2015-05-24 12:52:14 UTC'::timestamp,
            'Email',
            'miftakhetdinov@example.com',
            now(),
            'test_user',
            false
        ),
        (
            1567806034,
            '736876',
            '2015-05-24 12:52:15 UTC'::timestamp,
            'Телефон',
            '+7 495 777-88-99',
            now(),
            'test_user',
            false
        )
) AS src (
    load_id,
    system_id,
    updated_at,
    type,
    contact_infos,
    create_date,
    create_user,
    is_load
)
WHERE NOT EXISTS (
    SELECT 1
    FROM pdl.idw_arj_pdl_contact_infos t
    WHERE t.load_id = src.load_id
      AND t.system_id = src.system_id
      AND COALESCE(t.updated_at::text, '') = COALESCE(src.updated_at::text, '')
      AND COALESCE(t.type, '') = COALESCE(src.type, '')
      AND COALESCE(t.contact_infos, '') = COALESCE(src.contact_infos, '')
      AND t.create_user = 'test_user'
);


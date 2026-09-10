-- =====================================================
-- ТЕСТОВЫЕ ДАННЫЕ ДЛЯ pdl.idw_arj_pdl_persdocs
-- С проверкой на существование через NOT EXISTS
-- Контроль по create_user = 'test_user'
-- =====================================================

INSERT INTO pdl.idw_arj_pdl_persdocs (
    load_id,
    system_id,
    updated_at,
    date_start,
    date_end,
    name,
    doc_serial,
    doc_number,
    common,
    issuing_country,
    issue,
    create_date,
    create_user,
    is_load
)
SELECT
    load_id,
    system_id,
    updated_at,
    date_start,
    date_end,
    name,
    doc_serial,
    doc_number,
    common,
    issuing_country,
    issue,
    create_date,
    create_user,
    is_load
FROM (
    VALUES
        (
            1567806034,
            '736867',
            '2020-01-01 00:00:00'::timestamp,
            '2000-01-01 00:00:00'::timestamp,
            NULL::timestamp,
            'Паспорт гражданина РФ',
            '1234',
            '567890',
            'Паспорт',
            'Россия',
            'УВД г. Москвы',
            now(),
            'test_user',
            false
        ),
        (
            1567806034,
            '736868',
            '2005-06-15 00:00:00'::timestamp,
            '2005-06-15 00:00:00'::timestamp,
            NULL::timestamp,
            'Паспорт гражданина РФ',
            '2345',
            '678901',
            'Паспорт',
            'Россия',
            'УВД г. Санкт-Петербурга',
            now(),
            'test_user',
            false
        ),
        (
            1567806034,
            '736872',
            '2015-05-24 12:52:13 UTC'::timestamp,
            '2000-01-01 00:00:00'::timestamp,
            NULL::timestamp,
            'Паспорт гражданина РФ',
            '3456',
            '789012',
            'Паспорт',
            'Россия',
            'УВД г. Москвы',
            now(),
            'test_user',
            false
        ),
        (
            1567806034,
            '736873',
            '2020-04-01 14:36:41 UTC'::timestamp,
            '2005-01-01 00:00:00'::timestamp,
            NULL::timestamp,
            'Паспорт гражданина РФ',
            '4567',
            '890123',
            'Паспорт',
            'Россия',
            'УВД г. Грозного',
            now(),
            'test_user',
            false
        ),
        (
            1567806034,
            '736875',
            '2015-05-24 12:52:14 UTC'::timestamp,
            '2010-01-01 00:00:00'::timestamp,
            NULL::timestamp,
            'Паспорт гражданина РФ',
            '5678',
            '901234',
            'Паспорт',
            'Россия',
            'УВД г. Уфы',
            now(),
            'test_user',
            false
        ),
        (
            1567806034,
            '736876',
            '2015-05-24 12:52:15 UTC'::timestamp,
            '2015-01-01 00:00:00'::timestamp,
            NULL::timestamp,
            'Паспорт гражданина РФ',
            '6789',
            '012345',
            'Паспорт',
            'Россия',
            'УВД г. Москвы',
            now(),
            'test_user',
            false
        )
) AS src (
    load_id,
    system_id,
    updated_at,
    date_start,
    date_end,
    name,
    doc_serial,
    doc_number,
    common,
    issuing_country,
    issue,
    create_date,
    create_user,
    is_load
)
WHERE NOT EXISTS (
    SELECT 1
    FROM pdl.idw_arj_pdl_persdocs t
    WHERE t.load_id = src.load_id
      AND t.system_id = src.system_id
      AND COALESCE(t.updated_at::text, '') = COALESCE(src.updated_at::text, '')
      AND COALESCE(t.date_start::text, '') = COALESCE(src.date_start::text, '')
      AND COALESCE(t.date_end::text, '') = COALESCE(src.date_end::text, '')
      AND COALESCE(t.name, '') = COALESCE(src.name, '')
      AND COALESCE(t.doc_serial, '') = COALESCE(src.doc_serial, '')
      AND COALESCE(t.doc_number, '') = COALESCE(src.doc_number, '')
      AND COALESCE(t.common, '') = COALESCE(src.common, '')
      AND COALESCE(t.issuing_country, '') = COALESCE(src.issuing_country, '')
      AND COALESCE(t.issue, '') = COALESCE(src.issue, '')
      AND t.create_user = 'test_user'
);

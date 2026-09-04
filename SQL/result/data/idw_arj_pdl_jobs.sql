-- =====================================================
-- ТЕСТОВЫЕ ДАННЫЕ ДЛЯ pdl.idw_arj_pdl_jobs
-- С проверкой на существование через NOT EXISTS
-- Контроль по create_user = 'test_user'
-- =====================================================

INSERT INTO pdl.idw_arj_pdl_jobs (
    load_id,
    system_id,
    updated_at,
    date_start,
    date_end,
    source,
    main,
    unactive,
    name,
    authority,
    reg_id,
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
    source,
    main,
    unactive,
    name,
    authority,
    reg_id,
    create_date,
    create_user,
    is_load
FROM (
    VALUES
        -- Для system_id = 736867
        (
            1567806034,
            '736867',
            '2023-05-10 11:45:48 UTC'::timestamp,
            '2010-01-01 00:00:00'::timestamp,
            NULL,
            'https://example.com/source1',
            'true',
            'false',
            'Директор департамента',
            'МВД России',
            'REG001',
            now(),
            'test_user',
            false
        ),
        (
            1567806034,
            '736867',
            '2023-05-10 11:45:48 UTC'::timestamp,
            '2005-01-01 00:00:00'::timestamp,
            '2009-12-31 00:00:00'::timestamp,
            'https://example.com/source2',
            'false',
            'true',
            'Начальник отдела',
            'УВД',
            'REG002',
            now(),
            'test_user',
            false
        ),
        -- Для system_id = 736868
        (
            1567806034,
            '736868',
            '2023-05-10 11:45:48 UTC'::timestamp,
            '2015-06-01 00:00:00'::timestamp,
            NULL,
            'https://example.com/source3',
            'true',
            'false',
            'Начальник управления',
            'ФСБ России',
            'REG003',
            now(),
            'test_user',
            false
        ),
        -- Для system_id = 736872
        (
            1567806034,
            '736872',
            '2023-05-10 11:45:48 UTC'::timestamp,
            '2010-01-01 00:00:00'::timestamp,
            NULL,
            'https://example.com/source4',
            'true',
            'false',
            'Директор',
            'МВД России',
            'REG004',
            now(),
            'test_user',
            false
        ),
        -- Для system_id = 736873
        (
            1567806034,
            '736873',
            '2023-05-10 11:45:48 UTC'::timestamp,
            '2015-01-01 00:00:00'::timestamp,
            NULL,
            'https://example.com/source5',
            'true',
            'false',
            'Начальник отдела',
            'ФСБ России',
            'REG005',
            now(),
            'test_user',
            false
        ),
        -- Для system_id = 736875
        (
            1567806034,
            '736875',
            '2023-05-10 11:45:48 UTC'::timestamp,
            '2018-03-01 00:00:00'::timestamp,
            '2023-01-01 00:00:00'::timestamp,
            'https://example.com/source6',
            'true',
            'false',
            'Главный специалист',
            'Минфин России',
            'REG006',
            now(),
            'test_user',
            false
        ),
        -- Для system_id = 736876
        (
            1567806034,
            '736876',
            '2023-05-10 11:45:48 UTC'::timestamp,
            '2020-01-15 00:00:00'::timestamp,
            NULL,
            'https://example.com/source7',
            'true',
            'false',
            'Заместитель начальника',
            'Генпрокуратура',
            'REG007',
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
    source,
    main,
    unactive,
    name,
    authority,
    reg_id,
    create_date,
    create_user,
    is_load
)
WHERE NOT EXISTS (
    SELECT 1
    FROM pdl.idw_arj_pdl_jobs t
    WHERE t.load_id = src.load_id
      AND t.system_id = src.system_id
      AND COALESCE(t.updated_at::text, '') = COALESCE(src.updated_at::text, '')
      AND COALESCE(t.date_start::text, '') = COALESCE(src.date_start::text, '')
      AND COALESCE(t.date_end::text, '') = COALESCE(src.date_end::text, '')
      AND COALESCE(t.source, '') = COALESCE(src.source, '')
      AND COALESCE(t.main, '') = COALESCE(src.main, '')
      AND COALESCE(t.unactive, '') = COALESCE(src.unactive, '')
      AND COALESCE(t.name, '') = COALESCE(src.name, '')
      AND COALESCE(t.authority, '') = COALESCE(src.authority, '')
      AND COALESCE(t.reg_id, '') = COALESCE(src.reg_id, '')
      AND t.create_user = 'test_user'
);


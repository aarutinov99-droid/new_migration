-- =====================================================
-- ТЕСТОВЫЕ ДАННЫЕ ДЛЯ pdl.idw_arj_pdl_sanctions
-- С проверкой на существование через NOT EXISTS
-- Контроль по create_user = 'test_user'
-- =====================================================

INSERT INTO pdl.idw_arj_pdl_sanctions (
    load_id,
    system_id,
    sanction,
    date_start,
    date_end,
    source,
    reason_inclusion,
    sanlist,
    country,
    extra_informations,
    uidd,
    last_update_in_source,
    create_date,
    create_user,
    is_load
)
SELECT
    load_id,
    system_id,
    sanction,
    date_start,
    date_end,
    source,
    reason_inclusion,
    sanlist,
    country,
    extra_informations,
    uidd,
    last_update_in_source,
    create_date,
    create_user,
    is_load
FROM (
    VALUES
        -- Для system_id = 736867
        (
            1567806034,
            '736867',
            'Перечень организаций и физических лиц, в отношении которых имеются сведения об их причастности к экстремистской деятельности или терроризму',
            NULL::timestamp,
            '2022-02-22 00:00:00'::timestamp,
            'https://www.fedsfm.ru/',
            'Причастность к террористической деятельности',
            'Росфинмониторинг (Россия)',
            'Россия',
            '',
            '',
            NULL::timestamp,
            now(),
            'test_user',
            false
        ),
        -- Для system_id = 736868
        (
            1567806034,
            '736868',
            'Перечень организаций и физических лиц, в отношении которых имеются сведения об их причастности к экстремистской деятельности или терроризму',
            NULL::timestamp,
            NULL::timestamp,
            'https://www.fedsfm.ru/',
            'Экстремистская деятельность',
            'Росфинмониторинг (Россия)',
            'Россия',
            '',
            '',
            NULL::timestamp,
            now(),
            'test_user',
            false
        ),
        -- Для system_id = 736872
        (
            1567806034,
            '736872',
            'Перечень организаций и физических лиц, в отношении которых имеются сведения об их причастности к экстремистской деятельности или терроризму',
            NULL::timestamp,
            '2019-10-24 00:00:00'::timestamp,
            'https://www.fedsfm.ru/',
            '',
            'Росфинмониторинг (Россия)',
            'Россия',
            '',
            '',
            NULL::timestamp,
            now(),
            'test_user',
            false
        ),
        -- Для system_id = 736873
        (
            1567806034,
            '736873',
            'Перечень организаций и физических лиц, в отношении которых имеются сведения об их причастности к экстремистской деятельности или терроризму',
            NULL::timestamp,
            NULL::timestamp,
            'https://www.fedsfm.ru/',
            '',
            'Росфинмониторинг (Россия)',
            'Россия',
            '',
            '',
            NULL::timestamp,
            now(),
            'test_user',
            false
        ),
        -- Для system_id = 736875
        (
            1567806034,
            '736875',
            'Перечень организаций и физических лиц, в отношении которых имеются сведения об их причастности к экстремистской деятельности или терроризму',
            NULL::timestamp,
            '2015-06-19 00:00:00'::timestamp,
            'https://www.fedsfm.ru/',
            '',
            'Росфинмониторинг (Россия)',
            'Россия',
            '',
            '',
            NULL::timestamp,
            now(),
            'test_user',
            false
        ),
        -- Для system_id = 736876
        (
            1567806034,
            '736876',
            'Перечень организаций и физических лиц, в отношении которых имеются сведения об их причастности к экстремистской деятельности или терроризму',
            NULL::timestamp,
            '2015-06-19 00:00:00'::timestamp,
            'https://www.fedsfm.ru/',
            '',
            'Росфинмониторинг (Россия)',
            'Россия',
            '',
            '',
            NULL::timestamp,
            now(),
            'test_user',
            false
        )
) AS src (
    load_id,
    system_id,
    sanction,
    date_start,
    date_end,
    source,
    reason_inclusion,
    sanlist,
    country,
    extra_informations,
    uidd,
    last_update_in_source,
    create_date,
    create_user,
    is_load
)
WHERE NOT EXISTS (
    SELECT 1
    FROM pdl.idw_arj_pdl_sanctions t
    WHERE t.load_id = src.load_id
      AND t.system_id = src.system_id
      AND COALESCE(t.sanction, '') = COALESCE(src.sanction, '')
      AND COALESCE(t.date_start::text, '') = COALESCE(src.date_start::text, '')
      AND COALESCE(t.date_end::text, '') = COALESCE(src.date_end::text, '')
      AND COALESCE(t.source, '') = COALESCE(src.source, '')
      AND COALESCE(t.reason_inclusion, '') = COALESCE(src.reason_inclusion, '')
      AND COALESCE(t.sanlist, '') = COALESCE(src.sanlist, '')
      AND COALESCE(t.country, '') = COALESCE(src.country, '')
      AND t.create_user = 'test_user'
);

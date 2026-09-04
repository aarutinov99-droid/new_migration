-- =====================================================
-- ТЕСТОВЫЕ ДАННЫЕ ДЛЯ pdl.idw_arj_pdl_names
-- С проверкой на существование через NOT EXISTS
-- Контроль по полному набору полей (включая last_name, create_user)
-- =====================================================

INSERT INTO pdl.idw_arj_pdl_names (
    load_id,
    system_id,
    locale,
    updated_at,
    last_name,
    first_name,
    middle_name,
    full_name,
    create_date,
    create_user,
    is_load
)
SELECT
    load_id,
    system_id,
    locale,
    updated_at,
    last_name,
    first_name,
    middle_name,
    full_name,
    create_date,
    create_user,
    is_load
FROM (
    VALUES
        -- Для system_id = 736867
        (
            1567806034,
            '736867',
            'ru',
            '2020-04-01 14:28:12 UTC'::timestamp,
            'Мирзаханов',
            'Физули',
            'Магомедкеримович',
            'Мирзаханов Физули Магомедкеримович',
            now(),
            'test_user',
            false
        ),
        (
            1567806034,
            '736867',
            'ru',
            '2015-07-01 14:19:11 UTC'::timestamp,
            NULL,
            NULL,
            NULL,
            'Мирзаханов Физули Магомедкеримович',
            now(),
            'test_user',
            false
        ),
        -- Для system_id = 736868
        (
            1567806034,
            '736868',
            'ru',
            '2023-03-17 17:08:27 UTC'::timestamp,
            'Мирзоев',
            'Фейруз',
            'Мурадович',
            'Мирзоев Фейруз Мурадович',
            now(),
            'test_user',
            false
        ),
        (
            1567806034,
            '736868',
            'ru',
            '2015-07-01 14:09:10 UTC'::timestamp,
            NULL,
            NULL,
            NULL,
            'Мирзоев Фейруз Мурадович',
            now(),
            'test_user',
            false
        ),
        -- Для system_id = 736872
        (
            1567806034,
            '736872',
            'ru',
            '2015-05-24 12:52:13 UTC'::timestamp,
            'Миталаев',
            'Лечи',
            'Жанадиевич',
            'Миталаев Лечи Жанадиевич',
            now(),
            'test_user',
            false
        ),
        (
            1567806034,
            '736872',
            'ru',
            '2015-07-01 14:02:12 UTC'::timestamp,
            NULL,
            NULL,
            NULL,
            'Миталаев Лечи Жанадиевич',
            now(),
            'test_user',
            false
        ),
        -- Для system_id = 736873
        (
            1567806034,
            '736873',
            'ru',
            '2023-03-17 15:31:47 UTC'::timestamp,
            'Миталаев',
            'Хусейн',
            'Умарович',
            'Миталаев Хусейн Умарович',
            now(),
            'test_user',
            false
        ),
        (
            1567806034,
            '736873',
            'ru',
            '2015-07-01 13:43:32 UTC'::timestamp,
            NULL,
            NULL,
            NULL,
            'Миталаев Хусейн Умарович',
            now(),
            'test_user',
            false
        ),
        -- Для system_id = 736875
        (
            1567806034,
            '736875',
            'ru',
            '2015-05-24 12:52:14 UTC'::timestamp,
            'Мифтахетдинов',
            'Рашит',
            'Мидхатович',
            'Мифтахетдинов Рашит Мидхатович',
            now(),
            'test_user',
            false
        ),
        (
            1567806034,
            '736875',
            'ru',
            '2015-07-01 14:20:20 UTC'::timestamp,
            NULL,
            NULL,
            NULL,
            'Мифтахетдинов Рашит Мидхатович',
            now(),
            'test_user',
            false
        ),
        -- Для system_id = 736876
        (
            1567806034,
            '736876',
            'ru',
            '2015-05-24 12:52:15 UTC'::timestamp,
            'Михайлянц',
            'Александр',
            'Анатольевич',
            'Михайлянц Александр Анатольевич',
            now(),
            'test_user',
            false
        ),
        (
            1567806034,
            '736876',
            'ru',
            '2015-07-01 13:53:34 UTC'::timestamp,
            NULL,
            NULL,
            NULL,
            'Михайлянц Александр Анатольевич',
            now(),
            'test_user',
            false
        )
) AS src (
    load_id,
    system_id,
    locale,
    updated_at,
    last_name,
    first_name,
    middle_name,
    full_name,
    create_date,
    create_user,
    is_load
)
WHERE NOT EXISTS (
    SELECT 1
    FROM pdl.idw_arj_pdl_names t
    WHERE t.load_id = src.load_id
      AND t.system_id = src.system_id
      AND COALESCE(t.last_name, '') = COALESCE(src.last_name, '')
      AND COALESCE(t.first_name, '') = COALESCE(src.first_name, '')
      AND COALESCE(t.middle_name, '') = COALESCE(src.middle_name, '')
      AND COALESCE(t.full_name, '') = COALESCE(src.full_name, '')
      AND COALESCE(t.locale, '') = COALESCE(src.locale, '')
      AND COALESCE(t.create_user, '') = 'test_user'
);


-- =====================================================
-- ТЕСТОВЫЕ ДАННЫЕ ДЛЯ pdl.idw_arj_pdl_categories
-- Коды из справочника idw_pdl_ref
-- С проверкой на существование через NOT EXISTS
-- Контроль по create_user = 'test_user'
-- =====================================================

INSERT INTO pdl.idw_arj_pdl_categories (
    load_id,
    system_id,
    category_code,
    create_date,
    create_user,
    is_load
)
SELECT
    load_id,
    system_id,
    category_code,
    create_date,
    create_user,
    is_load
FROM (
    VALUES
        -- Для system_id = 736867
        (
            1567806034,
            '736867',
            'sanction',
            now(),
            'test_user',
            false
        ),
        -- Для system_id = 736868
        (
            1567806034,
            '736868',
            'sanction',
            now(),
            'test_user',
            false
        ),
        -- Для system_id = 736872
        (
            1567806034,
            '736872',
            'sanction',
            now(),
            'test_user',
            false
        ),
        -- Для system_id = 736873
        (
            1567806034,
            '736873',
            'sanction',
            now(),
            'test_user',
            false
        ),
        -- Для system_id = 736875
        (
            1567806034,
            '736875',
            'sanction',
            now(),
            'test_user',
            false
        ),
        -- Для system_id = 736876
        (
            1567806034,
            '736876',
            'sanction',
            now(),
            'test_user',
            false
        )
) AS src (
    load_id,
    system_id,
    category_code,
    create_date,
    create_user,
    is_load
)
WHERE NOT EXISTS (
    SELECT 1
    FROM pdl.idw_arj_pdl_categories t
    WHERE t.load_id = src.load_id
      AND t.system_id = src.system_id
      AND t.category_code = src.category_code
      AND t.create_user = 'test_user'
);

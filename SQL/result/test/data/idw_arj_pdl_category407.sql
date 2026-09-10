-- =====================================================
-- ТЕСТОВЫЕ ДАННЫЕ ДЛЯ pdl.idw_arj_pdl_category407
-- Коды из справочника idw_pdl_ref
-- С проверкой на существование через NOT EXISTS
-- Контроль по create_user = 'test_user'
-- =====================================================

INSERT INTO pdl.idw_arj_pdl_category407 (
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
            '1',
            now(),
            'test_user',
            false
        ),
        -- Для system_id = 736868
        (
            1567806034,
            '736868',
            '2',
            now(),
            'test_user',
            false
        ),
        -- Для system_id = 736872
        (
            1567806034,
            '736872',
            '0',
            now(),
            'test_user',
            false
        ),
        -- Для system_id = 736873
        (
            1567806034,
            '736873',
            '4',
            now(),
            'test_user',
            false
        ),
        -- Для system_id = 736875
        (
            1567806034,
            '736875',
            '99',
            now(),
            'test_user',
            false
        ),
        -- Для system_id = 736876
        (
            1567806034,
            '736876',
            '0',
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
    FROM pdl.idw_arj_pdl_category407 t
    WHERE t.load_id = src.load_id
      AND t.system_id = src.system_id
      AND t.category_code = src.category_code
      AND t.create_user = 'test_user'
);


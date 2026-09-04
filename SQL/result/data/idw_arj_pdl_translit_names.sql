-- =====================================================
-- ТЕСТОВЫЕ ДАННЫЕ ДЛЯ pdl.idw_arj_pdl_translit_names
-- С проверкой на существование через NOT EXISTS
-- =====================================================

-- =====================================================
-- ВСТАВКА ТЕСТОВЫХ ДАННЫХ
-- =====================================================

INSERT INTO pdl.idw_arj_pdl_translit_names (
    load_id,
    system_id,
    translit_names,
    create_date,
    create_user,
    is_load
)
SELECT
    load_id,
    system_id,
    translit_names,
    create_date,
    create_user,
    is_load
FROM (
    VALUES
        -- Для system_id = 736867
        (
            1567806034,
            '736867',
            'Mirzakhanov Fizuli Magomedkerimovich',
            now(),
            'test_user',
            false
        ),
        (
            1567806034,
            '736867',
            'Mirzakhanov Fizuli Magomedcherimovich',
            now(),
            'test_user',
            false
        ),
        (
            1567806034,
            '736867',
            'Mirzakhanov Fizuli Mahomedkerimovich',
            now(),
            'test_user',
            false
        ),
        (
            1567806034,
            '736867',
            'Mirzakhanov Fizuli Maguomedkerimovich',
            now(),
            'test_user',
            false
        ),
        -- Для system_id = 736868
        (
            1567806034,
            '736868',
            'Mirzoev Feyruz Muradovich',
            now(),
            'test_user',
            false
        ),
        (
            1567806034,
            '736868',
            'Mirzoyev Fyeyruz Muradovich',
            now(),
            'test_user',
            false
        ),
        (
            1567806034,
            '736868',
            'Mirzoew Feyruz Muradowich',
            now(),
            'test_user',
            false
        ),
        -- Для system_id = 736872
        (
            1567806034,
            '736872',
            'Mitalaev Lechi Zhanadievich',
            now(),
            'test_user',
            false
        ),
        (
            1567806034,
            '736872',
            'Mitalaew Lechi Zhanadiewich',
            now(),
            'test_user',
            false
        ),
        (
            1567806034,
            '736872',
            'Mitalayev Lyechi Zhanadiyevich',
            now(),
            'test_user',
            false
        ),
        -- Для system_id = 736873
        (
            1567806034,
            '736873',
            'Mitalaev Khuseyn Umarovich',
            now(),
            'test_user',
            false
        ),
        (
            1567806034,
            '736873',
            'Mitalaew Khuseyn Umarowich',
            now(),
            'test_user',
            false
        ),
        (
            1567806034,
            '736873',
            'Mitalayev Khusyeyn Umarovich',
            now(),
            'test_user',
            false
        ),
        -- Для system_id = 736875
        (
            1567806034,
            '736875',
            'Miftakhetdinov Rashit Midkhatovich',
            now(),
            'test_user',
            false
        ),
        (
            1567806034,
            '736875',
            'Miftakhetdinow Rashit Midkhatowich',
            now(),
            'test_user',
            false
        ),
        (
            1567806034,
            '736875',
            'Miftakhyetdinov Rashit Midkhatovich',
            now(),
            'test_user',
            false
        ),
        -- Для system_id = 736876
        (
            1567806034,
            '736876',
            'Mikhaylyants Aleksandr Anatolevich',
            now(),
            'test_user',
            false
        ),
        (
            1567806034,
            '736876',
            'Mikhaylyants Alexandr Anatolevich',
            now(),
            'test_user',
            false
        ),
        (
            1567806034,
            '736876',
            'Mikhaylyants Aleksandr Anatolewich',
            now(),
            'test_user',
            false
        )
) AS src (
    load_id,
    system_id,
    translit_names,
    create_date,
    create_user,
    is_load
)
WHERE NOT EXISTS (
    SELECT 1
    FROM pdl.idw_arj_pdl_translit_names t
    WHERE t.load_id = src.load_id
      AND t.system_id = src.system_id
      AND t.translit_names = src.translit_names
      AND COALESCE(t.create_user, '') = COALESCE(src.create_user, '')
);


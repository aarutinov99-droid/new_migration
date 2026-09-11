-- =============================================================================
-- ЕДИНЫЙ СКРИПТ ТЕСТИРОВАНИЯ
-- Функция: eor.pr_eor_pdl_ident_find_rfl_candidate_func(TEXT, DATE)
--
-- Сценарии:
--   Т1.  ФИО + ДР — точное совпадение
--   Т2.  Только ФИО
--   Т3.  Только ДР
--   Т4.  Нет совпадений
--   Т5.  Несколько кандидатов по ФИО
--   Т6.  NULL в p_birth_date
--   Т7.  NULL в p_full_name
--   Т8.  deleted_sign = '1'
--   Т9.  Превышение l_max_cnt (> 1000)
--   Т10. Очистка tmp_eor_ident_candidate между вызовами
--
-- Все вспомогательные объекты удаляются по завершении.
-- =============================================================================


-- =============================================================================
-- ПРЕДВАРИТЕЛЬНАЯ ПРОВЕРКА: наличие тестовых данных
-- =============================================================================
DO $$
DECLARE
    l_flrn   INTEGER;
    l_master INTEGER;
BEGIN
    SELECT COUNT(*) INTO l_flrn
      FROM eor.idwh2_etalon_flrn
     WHERE etalon_registry_id BETWEEN 2830234 AND 2830239;

    SELECT COUNT(*) INTO l_master
      FROM eor.idw_mr_master
     WHERE etalon_registry_id BETWEEN 2830234 AND 2830239
       AND deleted_sign = '0';

    IF l_flrn < 6 OR l_master < 6 THEN
        RAISE EXCEPTION 'Тестовые данные не подготовлены: flrn=%, master=%', l_flrn, l_master;
    END IF;

    -- Проверка согласованности ФИО/ДР между pdl и flrn
    SELECT COUNT(*) INTO l_flrn
      FROM sr.sr_subject_pdl p
      JOIN eor.idwh2_etalon_flrn f ON f.etalon_registry_id = p.sr_subject_id
     WHERE p.sr_subject_id BETWEEN 2830234 AND 2830239
       AND f.full_name  = TRIM(UPPER(p.full_name))
       AND f.birth_date = p.date_birthday;

    IF l_flrn < 6 THEN
        RAISE EXCEPTION 'ФИО/ДР в idwh2_etalon_flrn не согласованы с sr_subject_pdl: % из 6', l_flrn;
    END IF;

    RAISE NOTICE 'Предварительная проверка пройдена: flrn=6, master=6, ФИО/ДР согласованы';
END $$;


-- =============================================================================
-- СВОДНЫЙ ПРОГОН ВСЕХ ТЕСТОВ
-- =============================================================================
DO $$
DECLARE
    l_passed  INTEGER := 0;
    l_failed  INTEGER := 0;

    l_name    TEXT;
    l_find_id INTEGER;
    l_cnt     INTEGER;
    l_weight  DOUBLE PRECISION;
    l_min_w   DOUBLE PRECISION;
    l_max_w   DOUBLE PRECISION;
BEGIN
    RAISE NOTICE '===== СТАРТ ТЕСТИРОВАНИЯ find_rfl_candidate =====';

    -------------------------------------------------------------------------
    -- Т1. Точное совпадение ФИО + ДР
    -- Ожидание: 1 кандидат (2830234), weight ≈ 2.0
    -------------------------------------------------------------------------
    l_name := 'Т1: ФИО + ДР';
    BEGIN
        l_find_id := eor.pr_eor_pdl_ident_find_rfl_candidate_func(
            'МИРЗАХАНОВ ФИЗУЛИ МАГОМЕДКЕРИМОВИЧ', '1978-10-26'::date);

        SELECT COUNT(*), MAX(weight) INTO l_cnt, l_weight
          FROM eor.tmp_eor_ident_candidate
         WHERE find_candidate_id = l_find_id;

        IF l_cnt = 1 AND l_weight BETWEEN 1.9 AND 2.1 THEN
            RAISE NOTICE '[PASS] % (кандидатов=%, weight=%)', l_name, l_cnt, l_weight;
            l_passed := l_passed + 1;
        ELSE
            RAISE WARNING '[FAIL] % (кандидатов=%, weight=%)', l_name, l_cnt, l_weight;
            l_failed := l_failed + 1;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING '[FAIL] % — %', l_name, SQLERRM;
        l_failed := l_failed + 1;
    END;

    -------------------------------------------------------------------------
    -- Т2. Совпадение только по ФИО
    -- Ожидание: 1 кандидат, weight ≈ 1.0
    -------------------------------------------------------------------------
    l_name := 'Т2: только ФИО';
    BEGIN
        l_find_id := eor.pr_eor_pdl_ident_find_rfl_candidate_func(
            'МИРЗАХАНОВ ФИЗУЛИ МАГОМЕДКЕРИМОВИЧ', '1900-01-01'::date);

        SELECT COUNT(*), MAX(weight) INTO l_cnt, l_weight
          FROM eor.tmp_eor_ident_candidate
         WHERE find_candidate_id = l_find_id;

        IF l_cnt = 1 AND l_weight BETWEEN 0.9 AND 1.1 THEN
            RAISE NOTICE '[PASS] % (кандидатов=%, weight=%)', l_name, l_cnt, l_weight;
            l_passed := l_passed + 1;
        ELSE
            RAISE WARNING '[FAIL] % (кандидатов=%, weight=%)', l_name, l_cnt, l_weight;
            l_failed := l_failed + 1;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING '[FAIL] % — %', l_name, SQLERRM;
        l_failed := l_failed + 1;
    END;

    -------------------------------------------------------------------------
    -- Т3. Совпадение только по ДР
    -- Ожидание: 0 кандидатов
    -------------------------------------------------------------------------
    l_name := 'Т3: только ДР';
    BEGIN
        l_find_id := eor.pr_eor_pdl_ident_find_rfl_candidate_func(
            'НЕСУЩЕСТВУЮЩИЙ ЧЕЛОВЕК', '1978-10-26'::date);

        SELECT COUNT(*) INTO l_cnt
          FROM eor.tmp_eor_ident_candidate
         WHERE find_candidate_id = l_find_id;

        IF l_cnt = 0 THEN
            RAISE NOTICE '[PASS] % (кандидатов=%)', l_name, l_cnt;
            l_passed := l_passed + 1;
        ELSE
            RAISE WARNING '[FAIL] % (кандидатов=%)', l_name, l_cnt;
            l_failed := l_failed + 1;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING '[FAIL] % — %', l_name, SQLERRM;
        l_failed := l_failed + 1;
    END;

    -------------------------------------------------------------------------
    -- Т4. Полное отсутствие совпадений
    -- Ожидание: 0 кандидатов
    -------------------------------------------------------------------------
    l_name := 'Т4: нет совпадений';
    BEGIN
        l_find_id := eor.pr_eor_pdl_ident_find_rfl_candidate_func(
            'X Y Z', '1900-01-01'::date);

        SELECT COUNT(*) INTO l_cnt
          FROM eor.tmp_eor_ident_candidate
         WHERE find_candidate_id = l_find_id;

        IF l_cnt = 0 THEN
            RAISE NOTICE '[PASS] % (кандидатов=%)', l_name, l_cnt;
            l_passed := l_passed + 1;
        ELSE
            RAISE WARNING '[FAIL] % (кандидатов=%)', l_name, l_cnt;
            l_failed := l_failed + 1;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING '[FAIL] % — %', l_name, SQLERRM;
        l_failed := l_failed + 1;
    END;

    -------------------------------------------------------------------------
    -- Т5. Несколько кандидатов по ФИО
    -- Создаём дубликат ФИО (id 9900001), ожидаем 2 кандидата.
    -- По завершении удаляем дубликат.
    -------------------------------------------------------------------------
    l_name := 'Т5: несколько кандидатов';
    BEGIN
        -- 5.1. Дубликат в эталонной таблице РФЛ
        INSERT INTO eor.idwh2_etalon_flrn (
            etalon_registry_id, inn, snils, full_name, family_name, first_name,
            second_name, gender, birth_date, birth_place, doc_type_id,
            doc_number, doc_who, doc_code, oksm_code, address, address_reg
        ) VALUES (
            9900001, '051234567999', '999-999-999 99',
            'МИРЗАХАНОВ ФИЗУЛИ МАГОМЕДКЕРИМОВИЧ',
            'МИРЗАХАНОВ', 'ФИЗУЛИ', 'МАГОМЕДКЕРИМОВИЧ',
            'M', '1978-10-26 00:00:00'::timestamp, 'ДУБЛИКАТ ДЛЯ ТЕСТА',
            1, '9999 999999', 'ТЕСТ', '999-999', '643',
            'ТЕСТ', 'ТЕСТ'
        )
        ON CONFLICT (etalon_registry_id) DO NOTHING;

        -- 5.2. Карточка ЕОР для дубликата (иначе JOIN не сработает)
        INSERT INTO eor.idw_mr_master (
            master_id, etalon_registry_id, name, status, er_type_id, is_actual,
            subject_type, ko_sign, ip_sign, nr_sign, filial_sign,
            name_full, start_date, eor_h_id, eor_h_date, etalon_sign,
            manual_sign, deleted_sign
        ) VALUES (
            9900001, 9900001,
            'МИРЗАХАНОВ ФИЗУЛИ МАГОМЕДКЕРИМОВИЧ',
            1, 1, 1, 2, '0', '0', '0', '0',
            'МИРЗАХАНОВ ФИЗУЛИ МАГОМЕДКЕРИМОВИЧ',
            '1978-10-26 00:00:00'::timestamp,
            9900001, now()::timestamp, '0', '0', '0'
        )
        ON CONFLICT (etalon_registry_id) DO NOTHING;

        -- 5.3. Вызов
        l_find_id := eor.pr_eor_pdl_ident_find_rfl_candidate_func(
            'МИРЗАХАНОВ ФИЗУЛИ МАГОМЕДКЕРИМОВИЧ', '1978-10-26'::date);

        SELECT COUNT(*), MIN(weight), MAX(weight)
          INTO l_cnt, l_min_w, l_max_w
          FROM eor.tmp_eor_ident_candidate
         WHERE find_candidate_id = l_find_id;

        -- 5.4. Очистка
        DELETE FROM eor.idw_mr_master      WHERE etalon_registry_id = 9900001;
        DELETE FROM eor.idwh2_etalon_flrn  WHERE etalon_registry_id = 9900001;

        IF l_cnt = 2 THEN
            RAISE NOTICE '[PASS] % (кандидатов=%, weight=[%, %])',
                l_name, l_cnt, l_min_w, l_max_w;
            l_passed := l_passed + 1;
        ELSE
            RAISE WARNING '[FAIL] % (кандидатов=%, ожидалось 2)', l_name, l_cnt;
            l_failed := l_failed + 1;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        -- Гарантированная очистка
        BEGIN
            DELETE FROM eor.idw_mr_master      WHERE etalon_registry_id = 9900001;
            DELETE FROM eor.idwh2_etalon_flrn  WHERE etalon_registry_id = 9900001;
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
        RAISE WARNING '[FAIL] % — %', l_name, SQLERRM;
        l_failed := l_failed + 1;
    END;

    -------------------------------------------------------------------------
    -- Т6. NULL в p_birth_date
    -- Ожидание: 1 кандидат (сработает только ветка по ФИО)
    -------------------------------------------------------------------------
    l_name := 'Т6: NULL в p_birth_date';
    BEGIN
        l_find_id := eor.pr_eor_pdl_ident_find_rfl_candidate_func(
            'МИРЗАХАНОВ ФИЗУЛИ МАГОМЕДКЕРИМОВИЧ', NULL);

        SELECT COUNT(*) INTO l_cnt
          FROM eor.tmp_eor_ident_candidate
         WHERE find_candidate_id = l_find_id;

        IF l_cnt = 1 THEN
            RAISE NOTICE '[PASS] % (кандидатов=%)', l_name, l_cnt;
            l_passed := l_passed + 1;
        ELSE
            RAISE WARNING '[FAIL] % (кандидатов=%, ожидалось 1)', l_name, l_cnt;
            l_failed := l_failed + 1;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING '[FAIL] % — %', l_name, SQLERRM;
        l_failed := l_failed + 1;
    END;

    -------------------------------------------------------------------------
    -- Т7. NULL в p_full_name
    -- Ожидание: 0 кандидатов
    -------------------------------------------------------------------------
    l_name := 'Т7: NULL в p_full_name';
    BEGIN
        l_find_id := eor.pr_eor_pdl_ident_find_rfl_candidate_func(
            NULL, '1978-10-26'::date);

        SELECT COUNT(*) INTO l_cnt
          FROM eor.tmp_eor_ident_candidate
         WHERE find_candidate_id = l_find_id;

        IF l_cnt = 0 THEN
            RAISE NOTICE '[PASS] % (кандидатов=%)', l_name, l_cnt;
            l_passed := l_passed + 1;
        ELSE
            RAISE WARNING '[FAIL] % (кандидатов=%, ожидалось 0)', l_name, l_cnt;
            l_failed := l_failed + 1;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING '[FAIL] % — %', l_name, SQLERRM;
        l_failed := l_failed + 1;
    END;

    -------------------------------------------------------------------------
    -- Т8. deleted_sign = '1'
    -- Временно помечаем карточку 2830234 удалённой. Ожидание: 0 кандидатов.
    -------------------------------------------------------------------------
    l_name := 'Т8: deleted_sign=1';
    BEGIN
        UPDATE eor.idw_mr_master
           SET deleted_sign = '1'
         WHERE etalon_registry_id = 2830234;

        l_find_id := eor.pr_eor_pdl_ident_find_rfl_candidate_func(
            'МИРЗАХАНОВ ФИЗУЛИ МАГОМЕДКЕРИМОВИЧ', '1978-10-26'::date);

        SELECT COUNT(*) INTO l_cnt
          FROM eor.tmp_eor_ident_candidate
         WHERE find_candidate_id = l_find_id;

        UPDATE eor.idw_mr_master
           SET deleted_sign = '0'
         WHERE etalon_registry_id = 2830234;

        IF l_cnt = 0 THEN
            RAISE NOTICE '[PASS] % (кандидатов=%)', l_name, l_cnt;
            l_passed := l_passed + 1;
        ELSE
            RAISE WARNING '[FAIL] % (кандидатов=%, ожидалось 0)', l_name, l_cnt;
            l_failed := l_failed + 1;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        BEGIN
            UPDATE eor.idw_mr_master
               SET deleted_sign = '0'
             WHERE etalon_registry_id = 2830234;
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
        RAISE WARNING '[FAIL] % — %', l_name, SQLERRM;
        l_failed := l_failed + 1;
    END;

    -------------------------------------------------------------------------
    -- Т9. Превышение l_max_cnt (1001 запись)
    -- Ожидание: 0 кандидатов. Все временные записи удаляются.
    -------------------------------------------------------------------------
    l_name := 'Т9: превышение l_max_cnt';
    BEGIN
        -- 9.1. Массовая вставка
        INSERT INTO eor.idwh2_etalon_flrn (
            etalon_registry_id, inn, snils, full_name, family_name, first_name,
            second_name, gender, birth_date, birth_place, doc_type_id,
            doc_number, doc_who, doc_code, oksm_code, address, address_reg
        )
        SELECT 9800000 + g,
               '051234560' || LPAD(g::text, 3, '0'),
               '000-000-000 ' || LPAD(g::text, 2, '0'),
               'ТЕСТ ПЕРЕПОЛНЕНИЕ ПЕРЕПОЛНЕНИЕ',
               'ТЕСТ', 'ПЕРЕПОЛНЕНИЕ', 'ПЕРЕПОЛНЕНИЕ',
               'M', '1970-01-01 00:00:00'::timestamp, 'BULK TEST',
               1, '0000 000000', 'ТЕСТ', '000-000', '643',
               'ТЕСТ', 'ТЕСТ'
          FROM generate_series(1, 1001) g
        ON CONFLICT (etalon_registry_id) DO NOTHING;

        INSERT INTO eor.idw_mr_master (
            master_id, etalon_registry_id, name, status, er_type_id, is_actual,
            subject_type, ko_sign, ip_sign, nr_sign, filial_sign,
            name_full, start_date, eor_h_id, eor_h_date, etalon_sign,
            manual_sign, deleted_sign
        )
        SELECT 9800000 + g,
               9800000 + g,
               'ТЕСТ ПЕРЕПОЛНЕНИЕ ПЕРЕПОЛНЕНИЕ',
               1, 1, 1, 2, '0', '0', '0', '0',
               'ТЕСТ ПЕРЕПОЛНЕНИЕ ПЕРЕПОЛНЕНИЕ',
               '1970-01-01 00:00:00'::timestamp,
               9800000 + g, now()::timestamp, '0', '0', '0'
          FROM generate_series(1, 1001) g
        ON CONFLICT (etalon_registry_id) DO NOTHING;

        -- 9.2. Вызов
        l_find_id := eor.pr_eor_pdl_ident_find_rfl_candidate_func(
            'ТЕСТ ПЕРЕПОЛНЕНИЕ ПЕРЕПОЛНЕНИЕ', '1970-01-01'::date);

        SELECT COUNT(*) INTO l_cnt
          FROM eor.tmp_eor_ident_candidate
         WHERE find_candidate_id = l_find_id;

        -- 9.3. Очистка
        DELETE FROM eor.idw_mr_master
         WHERE etalon_registry_id BETWEEN 9800001 AND 9801001;
        DELETE FROM eor.idwh2_etalon_flrn
         WHERE etalon_registry_id BETWEEN 9800001 AND 9801001;

        IF l_cnt = 0 THEN
            RAISE NOTICE '[PASS] % (кандидатов=%, ожидалось 0)', l_name, l_cnt;
            l_passed := l_passed + 1;
        ELSE
            RAISE WARNING '[FAIL] % (кандидатов=%, ожидалось 0)', l_name, l_cnt;
            l_failed := l_failed + 1;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        BEGIN
            DELETE FROM eor.idw_mr_master
             WHERE etalon_registry_id BETWEEN 9800001 AND 9801001;
            DELETE FROM eor.idwh2_etalon_flrn
             WHERE etalon_registry_id BETWEEN 9800001 AND 9801001;
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
        RAISE WARNING '[FAIL] % — %', l_name, SQLERRM;
        l_failed := l_failed + 1;
    END;

    -------------------------------------------------------------------------
    -- Т10. Очистка tmp_eor_ident_candidate между вызовами
    -- После второго вызова кандидатов первого вызова быть не должно.
    -------------------------------------------------------------------------
    l_name := 'Т10: очистка tmp-таблицы';
    BEGIN
        -- 10.1. Первый вызов
        l_find_id := eor.pr_eor_pdl_ident_find_rfl_candidate_func(
            'МИРЗАХАНОВ ФИЗУЛИ МАГОМЕДКЕРИМОВИЧ', '1978-10-26'::date);

        SELECT COUNT(*) INTO l_cnt
          FROM eor.tmp_eor_ident_candidate
         WHERE find_candidate_id = l_find_id;

        -- 10.2. Второй вызов
        PERFORM eor.pr_eor_pdl_ident_find_rfl_candidate_func(
            'МИРЗОЕВ ФЕЙРУЗ МУРАДОВИЧ', '1989-11-25'::date);

        -- 10.3. Записи 1-го вызова должны исчезнуть
        SELECT COUNT(*) INTO l_weight   -- переиспользуем как счётчик
          FROM eor.tmp_eor_ident_candidate
         WHERE find_candidate_id = l_find_id;

        IF l_cnt >= 1 AND l_weight = 0 THEN
            RAISE NOTICE '[PASS] % (1-й вызов=%, после 2-го=%)',
                l_name, l_cnt, l_weight;
            l_passed := l_passed + 1;
        ELSE
            RAISE WARNING '[FAIL] % (1-й вызов=%, после 2-го=%)',
                l_name, l_cnt, l_weight;
            l_failed := l_failed + 1;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING '[FAIL] % — %', l_name, SQLERRM;
        l_failed := l_failed + 1;
    END;

    -------------------------------------------------------------------------
    -- ИТОГ
    -------------------------------------------------------------------------
    RAISE NOTICE '===== ИТОГ: пройдено %, провалено % =====', l_passed, l_failed;

    IF l_failed > 0 THEN
        RAISE WARNING 'Есть проваленные тесты: % из %', l_failed, l_passed + l_failed;
    ELSE
        RAISE NOTICE 'Все тесты пройдены успешно';
    END IF;
END $$;


-- =============================================================================
-- ФИНАЛЬНАЯ ОЧИСТКА ВСПОМОГАТЕЛЬНЫХ ДАННЫХ
-- (страховка на случай, если предыдущие блоки не очистили всё)
-- =============================================================================
DO $$
DECLARE
    l_del_master INTEGER;
    l_del_flrn   INTEGER;
BEGIN
    -- Дубликат Т5
    DELETE FROM eor.idw_mr_master      WHERE etalon_registry_id = 9900001;
    GET DIAGNOSTICS l_del_master = ROW_COUNT;
    DELETE FROM eor.idwh2_etalon_flrn  WHERE etalon_registry_id = 9900001;
    GET DIAGNOSTICS l_del_flrn = ROW_COUNT;
    IF l_del_master > 0 OR l_del_flrn > 0 THEN
        RAISE NOTICE 'Финал: удалён дубликат Т5 (master=%, flrn=%)', l_del_master, l_del_flrn;
    END IF;

    -- Массовые записи Т9
    DELETE FROM eor.idw_mr_master
     WHERE etalon_registry_id BETWEEN 9800001 AND 9801001;
    GET DIAGNOSTICS l_del_master = ROW_COUNT;
    DELETE FROM eor.idwh2_etalon_flrn
     WHERE etalon_registry_id BETWEEN 9800001 AND 9801001;
    GET DIAGNOSTICS l_del_flrn = ROW_COUNT;
    IF l_del_master > 0 OR l_del_flrn > 0 THEN
        RAISE NOTICE 'Финал: удалён массовый набор Т9 (master=%, flrn=%)', l_del_master, l_del_flrn;
    END IF;

    RAISE NOTICE 'Финал: очистка вспомогательных данных завершена';
END $$;


-- =============================================================================
-- КОНТРОЛЬ: что вспомогательные данные действительно удалены
-- =============================================================================
DO $$
DECLARE
    l_leftover INTEGER;
BEGIN
    SELECT
        (SELECT COUNT(*) FROM eor.idw_mr_master
          WHERE etalon_registry_id = 9900001
             OR etalon_registry_id BETWEEN 9800001 AND 9801001)
      + (SELECT COUNT(*) FROM eor.idwh2_etalon_flrn
          WHERE etalon_registry_id = 9900001
             OR etalon_registry_id BETWEEN 9800001 AND 9801001)
      INTO l_leftover;

    IF l_leftover > 0 THEN
        RAISE WARNING 'Контроль: осталось % вспомогательных записей', l_leftover;
    ELSE
        RAISE NOTICE 'Контроль: вспомогательные данные полностью удалены';
    END IF;
END $$;


-- =============================================================================
-- КОНЕЦ СКРИПТА
-- =============================================================================
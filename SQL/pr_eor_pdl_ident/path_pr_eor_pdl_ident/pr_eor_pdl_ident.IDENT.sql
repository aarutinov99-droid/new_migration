

-- =============================================================================
-- host 10.10.12.11
-- database fors_pg
-- shema eor
--
-- EOR: (ПДЛ). Запись ПДЛ в спецреестре ЕОР не имеет связи с субъектом ЕОР.
-- Требуется установить связь.
-- Добавление / изменение данных в Спецреестр ПДЛ
-- =============================================================================

-- =============================================================================
-- 1. ПОДГОТОВКА ДАННЫХ
-- =============================================================================
-- Условия выполнения:
--   Произведена настройка опер. слоя (fors_pg):
--     Применены изменения к опер. слою (fors_pg)
--     Выполнить скрипт изменений к функционалу fors_change_db_func.sql
-- =============================================================================


-- -----------------------------------------------------------------------------
-- 1.1. Исходные данные для идентификации
-- -----------------------------------------------------------------------------

-- =============================================================================
-- ПОЛНЫЙ СКРИПТ ЗАГРУЗКИ ТЕСТОВЫХ ДАННЫХ
-- Набор: sr_subject_id 2830258..2830263
-- Процедура: eor.pr_pdl_ident_batch / IDWH2.pr_eor_pdl_ident
--
-- Состав:
--   1. sr.sr_subject_pdl                         — опорные (6)
--   2. UPDATE sr.sr_subject_pdl                  — countries='КАЗАХСТАН' для 2830259
--   3. arch_ext.idw_arj_interfax_pdl_load_buffer — опорные (6)
--   4. sr.sr_subject                             — производные (3, для UPDATE)
--   5. sr.sr_event + sr.sr_subject_h             — события + история (3 + 3)
--   6. eor.idw_mr_master                         — карточки ЕОР (6)
--   7. eor.idwh2_etalon_flrn                     — эталон РФЛ (6)
--   8. eor.idwh2_etalon_nr_fl                    — эталон ИФЛ (6)
--   9. Контроль полноты
--
-- Идемпотентность: повторный запуск не создаёт дублей.
-- =============================================================================


-- =============================================================================
-- 1. ОПОРНЫЕ ДАННЫЕ: sr.sr_subject_pdl (6 записей)
-- =============================================================================
INSERT INTO sr.sr_subject_pdl (
    sr_subject_id, update_date, death_date, is_death, birth_place, gender,
    names, translit_names, countries, categories, categories407, jobs,
    sanlists, sanctions, "position", authority, create_date, create_user,
    system_id, is_eor_ident_process, full_name, date_birthday
)
SELECT v.*
FROM (VALUES
(2830258,'2026-09-11 12:13:29.567797'::timestamp,NULL::timestamp,0,
 'Д. МЕРЯСОВО БАЙМАКСКОГО РАЙОНА РЕСПУБЛИКИ БАШКОРТОСТАН','M',
 'МИФТАХЕТДИНОВ РАШИТ МИДХАТОВИЧ; МИФТАХЕТДИНОВ РАШИТ МИДХАТОВИЧ',
 'MIFTAKHETDINOV RASHIT MIDKHATOVICH; MIFTAKHETDINOW RASHIT MIDKHATOWICH; MIFTAKHYETDINOV RASHIT MIDKHATOVICH',
 'РОССИЯ','','','МИНФИН РОССИИ','РОСФИНМОНИТОРИНГ (РОССИЯ)',
 'ПЕРЕЧЕНЬ ОРГАНИЗАЦИЙ И ФИЗИЧЕСКИХ ЛИЦ, В ОТНОШЕНИИ КОТОРЫХ ИМЕЮТСЯ СВЕДЕНИЯ ОБ ИХ ПРИЧАСТНОСТИ К ЭКСТРЕМИСТСКОЙ ДЕЯТЕЛЬНОСТИ ИЛИ ТЕРРОРИЗМУ',
 NULL::text, NULL::text,'2026-09-11 10:07:12.277896'::timestamp,'arutinov.a','736875',0,
 'МИФТАХЕТДИНОВ РАШИТ МИДХАТОВИЧ','1982-07-09 00:00:00'::timestamp),

(2830259,'2026-09-11 12:13:29.586583'::timestamp,NULL::timestamp,0,
 'г. Ленинск Кзылординской Области Республики Казахстан','M',
 'МИХАЙЛЯНЦ АЛЕКСАНДР АНАТОЛЬЕВИЧ; МИХАЙЛЯНЦ АЛЕКСАНДР АНАТОЛЬЕВИЧ',
 'MIKHAYLYANTS ALEKSANDR ANATOLEVICH; MIKHAYLYANTS ALEKSANDR ANATOLEWICH; MIKHAYLYANTS ALEXANDR ANATOLEVICH',
 'РОССИЯ','','','ГЕНПРОКУРАТУРА','РОСФИНМОНИТОРИНГ (РОССИЯ)',
 'ПЕРЕЧЕНЬ ОРГАНИЗАЦИЙ И ФИЗИЧЕСКИХ ЛИЦ, В ОТНОШЕНИИ КОТОРЫХ ИМЕЮТСЯ СВЕДЕНИЯ ОБ ИХ ПРИЧАСТНОСТИ К ЭКСТРЕМИСТСКОЙ ДЕЯТЕЛЬНОСТИ ИЛИ ТЕРРОРИЗМУ',
 NULL::text, NULL::text,'2026-09-11 10:07:12.277896'::timestamp,'arutinov.a','736876',0,
 'МИХАЙЛЯНЦ АЛЕКСАНДР АНАТОЛЬЕВИЧ','1971-01-30 00:00:00'::timestamp),

(2830260,'2026-09-11 12:13:29.588865'::timestamp,NULL::timestamp,0,
 'С. АККА ТАБАСАРАНСКОГО РАЙОНА РЕСПУБЛИКИ ДАГЕСТАН','M',
 'МИРЗАХАНОВ ФИЗУЛИ МАГОМЕДКЕРИМОВИЧ; МИРЗАХАНОВ ФИЗУЛИ МАГОМЕДКЕРИМОВИЧ',
 'MIRZAKHANOV FIZULI MAGOMEDCHERIMOVICH; MIRZAKHANOV FIZULI MAGOMEDKERIMOVICH; MIRZAKHANOV FIZULI MAGUOMEDKERIMOVICH; MIRZAKHANOV FIZULI MAHOMEDKERIMOVICH',
 'РОССИЯ','','','МВД РОССИИ; УВД','РОСФИНМОНИТОРИНГ (РОССИЯ)',
 'ПЕРЕЧЕНЬ ОРГАНИЗАЦИЙ И ФИЗИЧЕСКИХ ЛИЦ, В ОТНОШЕНИИ КОТОРЫХ ИМЕЮТСЯ СВЕДЕНИЯ ОБ ИХ ПРИЧАСТНОСТИ К ЭКСТРЕМИСТСКОЙ ДЕЯТЕЛЬНОСТИ ИЛИ ТЕРРОРИЗМУ',
 NULL::text, NULL::text,'2026-09-11 10:07:12.277896'::timestamp,'arutinov.a','736867',0,
 'МИРЗАХАНОВ ФИЗУЛИ МАГОМЕДКЕРИМОВИЧ','1978-10-26 00:00:00'::timestamp),

(2830261,'2026-09-11 12:13:29.590968'::timestamp,NULL::timestamp,0,
 'г. Мубарек Республики Узбекистан','M',
 'МИРЗОЕВ ФЕЙРУЗ МУРАДОВИЧ; МИРЗОЕВ ФЕЙРУЗ МУРАДОВИЧ',
 'MIRZOEV FEYRUZ MURADOVICH; MIRZOEW FEYRUZ MURADOWICH; MIRZOYEV FYEYRUZ MURADOVICH',
 'РОССИЯ','','','ФСБ РОССИИ','РОСФИНМОНИТОРИНГ (РОССИЯ)',
 'ПЕРЕЧЕНЬ ОРГАНИЗАЦИЙ И ФИЗИЧЕСКИХ ЛИЦ, В ОТНОШЕНИИ КОТОРЫХ ИМЕЮТСЯ СВЕДЕНИЯ ОБ ИХ ПРИЧАСТНОСТИ К ЭКСТРЕМИСТСКОЙ ДЕЯТЕЛЬНОСТИ ИЛИ ТЕРРОРИЗМУ',
 NULL::text, NULL::text,'2026-09-11 10:07:12.277896'::timestamp,'arutinov.a','736868',0,
 'МИРЗОЕВ ФЕЙРУЗ МУРАДОВИЧ','1989-11-25 00:00:00'::timestamp),

(2830262,'2026-09-11 12:13:29.592997'::timestamp,NULL::timestamp,0,
 'Г. ЛЕНИНОГОРСК ВОСТОЧНО-КАЗАХСТАНСКОЙ ОБЛАСТИ КССР','M',
 'МИТАЛАЕВ ЛЕЧИ ЖАНАДИЕВИЧ; МИТАЛАЕВ ЛЕЧИ ЖАНАДИЕВИЧ',
 'MITALAEV LECHI ZHANADIEVICH; MITALAEW LECHI ZHANADIEWICH; MITALAYEV LYECHI ZHANADIYEVICH',
 'РОССИЯ','','','МВД РОССИИ','РОСФИНМОНИТОРИНГ (РОССИЯ)',
 'ПЕРЕЧЕНЬ ОРГАНИЗАЦИЙ И ФИЗИЧЕСКИХ ЛИЦ, В ОТНОШЕНИИ КОТОРЫХ ИМЕЮТСЯ СВЕДЕНИЯ ОБ ИХ ПРИЧАСТНОСТИ К ЭКСТРЕМИСТСКОЙ ДЕЯТЕЛЬНОСТИ ИЛИ ТЕРРОРИЗМУ',
 NULL::text, NULL::text,'2026-09-11 10:07:12.277896'::timestamp,'arutinov.a','736872',0,
 'МИТАЛАЕВ ЛЕЧИ ЖАНАДИЕВИЧ','1955-09-25 00:00:00'::timestamp),

(2830263,'2026-09-11 12:13:29.597226'::timestamp,NULL::timestamp,0,
 'С. ВЕДЕНО ВЕДЕНСКОГО РАЙОНА ЧЕЧЕНСКОЙ РЕСПУБЛИКИ','M',
 'МИТАЛАЕВ ХУСЕЙН УМАРОВИЧ; МИТАЛАЕВ ХУСЕЙН УМАРОВИЧ',
 'MITALAEV KHUSEYN UMAROVICH; MITALAEW KHUSEYN UMAROWICH; MITALAYEV KHUSYEYN UMAROVICH',
 'РОССИЯ','','','ФСБ РОССИИ','РОСФИНМОНИТОРИНГ (РОССИЯ)',
 'ПЕРЕЧЕНЬ ОРГАНИЗАЦИЙ И ФИЗИЧЕСКИХ ЛИЦ, В ОТНОШЕНИИ КОТОРЫХ ИМЕЮТСЯ СВЕДЕНИЯ ОБ ИХ ПРИЧАСТНОСТИ К ЭКСТРЕМИСТСКОЙ ДЕЯТЕЛЬНОСТИ ИЛИ ТЕРРОРИЗМУ',
 NULL::text, NULL::text,'2026-09-11 10:07:12.277896'::timestamp,'arutinov.a','736873',0,
 'МИТАЛАЕВ ХУСЕЙН УМАРОВИЧ','1977-02-13 00:00:00'::timestamp)
) AS v(
    sr_subject_id, update_date, death_date, is_death, birth_place, gender,
    names, translit_names, countries, categories, categories407, jobs,
    sanlists, sanctions, "position", authority, create_date, create_user,
    system_id, is_eor_ident_process, full_name, date_birthday
)
WHERE NOT EXISTS (
    SELECT 1 FROM sr.sr_subject_pdl t
     WHERE t.sr_subject_id = v.sr_subject_id
        OR t.full_name    = v.full_name
);


-- =============================================================================
-- 2. UPDATE: 2830259 → ветка l_is_rfl = 0
-- Переводим субъект 2830259 (МИХАЙЛЯНЦ А.А.) из ветки РФЛ в ветку ИФЛ,
-- изменяя countries на 'КАЗАХСТАН'.
-- =============================================================================
DO $$
DECLARE
    l_updated INTEGER;
BEGIN
    UPDATE sr.sr_subject_pdl
       SET countries = 'КАЗАХСТАН'
     WHERE sr_subject_id = 2830259
       AND COALESCE(countries, '') <> 'КАЗАХСТАН';

    GET DIAGNOSTICS l_updated = ROW_COUNT;

    IF l_updated > 0 THEN
        RAISE NOTICE '[2] 2830259: countries → ''КАЗАХСТАН'' (ветка l_is_rfl = 0)';
    ELSE
        RAISE NOTICE '[2] 2830259: countries уже ''КАЗАХСТАН'' (пропуск)';
    END IF;
END $$;


-- =============================================================================
-- 3. ОПОРНЫЕ ДАННЫЕ: arch_ext.idw_arj_interfax_pdl_load_buffer (6 записей)
-- =============================================================================
INSERT INTO arch_ext.idw_arj_interfax_pdl_load_buffer (
    id, sr_subject_id, create_date
)
SELECT v.*
FROM (VALUES
    (5, 2830258, '2026-09-11 12:13:29.568018'::timestamp),
    (6, 2830259, '2026-09-11 12:13:29.586687'::timestamp),
    (1, 2830260, '2026-09-11 12:13:29.588961'::timestamp),
    (2, 2830261, '2026-09-11 12:13:29.591059'::timestamp),
    (3, 2830262, '2026-09-11 12:13:29.595232'::timestamp),
    (4, 2830263, '2026-09-11 12:13:29.597316'::timestamp)
) AS v(id, sr_subject_id, create_date)
WHERE NOT EXISTS (
    SELECT 1 FROM arch_ext.idw_arj_interfax_pdl_load_buffer t
     WHERE t.id = v.id
);


-- =============================================================================
-- 4. sr.sr_subject — субъекты спецреестра (3 записи, для ветки UPDATE)
-- =============================================================================
INSERT INTO sr.sr_subject (
    sr_subject_id, etalon_registry_id, eor_subject_mention_id,
    incl_first_date, incl_date, incl_reason, excl_reason,
    deleted_sign, sr_type_id, actual_sign, checked_sign,
    sr_event_id, reg_num_ext_reestr
)
SELECT v.*
FROM (VALUES
    (2830258::bigint, NULL::bigint, NULL::bigint,
     '2026-09-11 12:13:29.567797'::timestamp,
     '2026-09-11 12:13:29.567797'::timestamp,
     'X-Complince', NULL::text, '0', 145, '1', '0',
     NULL::bigint, NULL::text),

    (2830260::bigint, NULL::bigint, NULL::bigint,
     '2026-09-11 12:13:29.588865'::timestamp,
     '2026-09-11 12:13:29.588865'::timestamp,
     'X-Complince', NULL::text, '0', 145, '1', '0',
     NULL::bigint, NULL::text),

    (2830262::bigint, NULL::bigint, NULL::bigint,
     '2026-09-11 12:13:29.592997'::timestamp,
     '2026-09-11 12:13:29.592997'::timestamp,
     'X-Complince', NULL::text, '0', 145, '1', '0',
     NULL::bigint, NULL::text)
) AS v(
    sr_subject_id, etalon_registry_id, eor_subject_mention_id,
    incl_first_date, incl_date, incl_reason, excl_reason,
    deleted_sign, sr_type_id, actual_sign, checked_sign,
    sr_event_id, reg_num_ext_reestr
)
WHERE NOT EXISTS (
    SELECT 1 FROM sr.sr_subject t
     WHERE t.sr_subject_id = v.sr_subject_id
       AND t.sr_type_id    = v.sr_type_id
);


-- =============================================================================
-- 5. sr.sr_event + sr.sr_subject_h — предзаполнение истории
--
-- Используем ту же последовательность, что и продакшн-функция
-- sr_common_pkg__sr_event_add: sr.sr_event_seq.
-- =============================================================================
DO $$
DECLARE
    l_event_id    BIGINT;
    l_subject_id  BIGINT;
    l_subject_ids BIGINT[] := ARRAY[2830258, 2830260, 2830262];
    l_created     INTEGER := 0;
    l_max_id      BIGINT;
    l_curr_val    BIGINT;
BEGIN
    -- Проверяем, что последовательность существует
    IF to_regclass('sr.sr_event_seq') IS NULL THEN
        RAISE EXCEPTION 'Последовательность sr.sr_event_seq не найдена';
    END IF;

    -- Синхронизируем последовательность с фактическим максимумом sr_event_id,
    -- чтобы избежать коллизий, если она «отстала» от данных.
    SELECT COALESCE(MAX(sr_event_id), 0) INTO l_max_id FROM sr.sr_event;
    SELECT last_value INTO l_curr_val FROM sr.sr_event_seq;

    IF l_curr_val < l_max_id THEN
        PERFORM setval('sr.sr_event_seq', l_max_id, true);
        RAISE NOTICE '[5] sr_event_seq: last_value % → % (синхронизация с MAX)',
            l_curr_val, l_max_id;
    ELSE
        RAISE NOTICE '[5] sr_event_seq: last_value = % (синхронизация не требуется)', l_curr_val;
    END IF;

    FOREACH l_subject_id IN ARRAY l_subject_ids LOOP
        -- Проверяем, есть ли уже история
        IF EXISTS (
            SELECT 1 FROM sr.sr_subject_h
             WHERE sr_subject_id = l_subject_id
               AND sr_type_id    = 145
        ) THEN
            RAISE NOTICE '[5] субъект %: история уже существует, пропуск', l_subject_id;
            CONTINUE;
        END IF;

        -- 1. Генерируем sr_event_id из sr.sr_event_seq
        l_event_id := nextval('sr.sr_event_seq');

        -- 2. Вставляем событие
        INSERT INTO sr.sr_event (
            sr_event_id, sr_event_type_id, sr_subject_id,
            sr_event_date, sr_event_user, description, manual_sign,
            sr_type_id, object_id, sr_event_user_os
        ) VALUES (
            l_event_id, 100, l_subject_id,
            CURRENT_TIMESTAMP, CURRENT_USER,
            'Тестовая предзаполненная история', '0',
            145, NULL, CURRENT_USER
        );

        -- 3. Обновляем sr.sr_subject.sr_event_id
        UPDATE sr.sr_subject
           SET sr_event_id = l_event_id
         WHERE sr_subject_id = l_subject_id
           AND sr_type_id    = 145;

        -- 4. Вставляем запись истории
		/*
        INSERT INTO sr.sr_subject_h (
            sr_event_id, sr_subject_id, etalon_registry_id,
            eor_subject_mention_id, incl_first_date, incl_date,
            incl_reason, excl_date, excl_reason, deleted_sign,
            sr_type_id, actual_sign, checked_sign, reg_num_ext_reestr
        ) VALUES (
            l_event_id, l_subject_id, NULL, NULL,
            '2026-09-11 12:13:29.567797'::timestamp,
            '2026-09-11 12:13:29.567797'::timestamp,
            'X-Complince', NULL, NULL, '0',
            145, '1', '0', NULL
        );*/

        l_created := l_created + 1;
        RAISE NOTICE '[5] субъект %: sr_event_id = %', l_subject_id, l_event_id;
    END LOOP;

    RAISE NOTICE '[5] предзаполнено % записей истории (из 3)', l_created;
END $$;


-- =============================================================================
-- 6. eor.idw_mr_master — карточки субъектов ЕОР (6 записей)
-- =============================================================================
INSERT INTO eor.idw_mr_master (
    master_id, etalon_registry_id, name, status, er_type_id, is_actual,
    risk_level, attention_level, feature_count, subject_type,
    ko_sign, ip_sign, nr_sign, filial_sign, head_org_id,
    name_full, name_short, inn, ogrn, bic, swift, start_date,
    eor_h_id, eor_h_date, etalon_sign, manual_sign, deleted_sign,
    eor_change_id, object_change_role_id, local_change_type_id,
    rating, rating_date
)
SELECT v.*
FROM (VALUES
    (1000019, 2830258, 'МИФТАХЕТДИНОВ РАШИТ МИДХАТОВИЧ', 1, 1, 1, 65, 75, 35, 2,
     '0', '0', '0', '0', NULL::bigint,
     'МИФТАХЕТДИНОВ РАШИТ МИДХАТОВИЧ', 'МИФТАХЕТДИНОВ Р.М.', '051234567912',
     NULL::text, NULL::text, NULL::text, '1982-07-09 00:00:00'::timestamp,
     9000019, '2026-09-11 12:13:29.567797'::timestamp, '1', '0', '0',
     5000019, 1, 1, 82, '2026-09-11 12:13:29.567797'::timestamp),

    (1000020, 2830259, 'МИХАЙЛЯНЦ АЛЕКСАНДР АНАТОЛЬЕВИЧ', 1, 1, 1, 70, 85, 40, 2,
     '0', '0', '0', '0', NULL::bigint,
     'МИХАЙЛЯНЦ АЛЕКСАНДР АНАТОЛЬЕВИЧ', 'МИХАЙЛЯНЦ А.А.', '051234567913',
     NULL::text, NULL::text, NULL::text, '1971-01-30 00:00:00'::timestamp,
     9000020, '2026-09-11 12:13:29.586583'::timestamp, '0', '0', '0',
     5000020, 1, 1, 78, '2026-09-11 12:13:29.586583'::timestamp),

    (1000021, 2830260, 'МИРЗАХАНОВ ФИЗУЛИ МАГОМЕДКЕРИМОВИЧ', 1, 1, 1, 75, 80, 45, 2,
     '0', '0', '0', '0', NULL::bigint,
     'МИРЗАХАНОВ ФИЗУЛИ МАГОМЕДКЕРИМОВИЧ', 'МИРЗАХАНОВ Ф.М.', '051234567914',
     NULL::text, NULL::text, NULL::text, '1978-10-26 00:00:00'::timestamp,
     9000021, '2026-09-11 12:13:29.588865'::timestamp, '1', '0', '0',
     5000021, 1, 1, 85, '2026-09-11 12:13:29.588865'::timestamp),

    (1000022, 2830261, 'МИРЗОЕВ ФЕЙРУЗ МУРАДОВИЧ', 1, 1, 1, 60, 70, 30, 2,
     '0', '0', '0', '0', NULL::bigint,
     'МИРЗОЕВ ФЕЙРУЗ МУРАДОВИЧ', 'МИРЗОЕВ Ф.М.', '051234567915',
     NULL::text, NULL::text, NULL::text, '1989-11-25 00:00:00'::timestamp,
     9000022, '2026-09-11 12:13:29.590968'::timestamp, '1', '0', '0',
     5000022, 1, 1, 80, '2026-09-11 12:13:29.590968'::timestamp),

    (1000023, 2830262, 'МИТАЛАЕВ ЛЕЧИ ЖАНАДИЕВИЧ', 1, 1, 1, 55, 65, 25, 2,
     '0', '0', '0', '0', NULL::bigint,
     'МИТАЛАЕВ ЛЕЧИ ЖАНАДИЕВИЧ', 'МИТАЛАЕВ Л.Ж.', '051234567916',
     NULL::text, NULL::text, NULL::text, '1955-09-25 00:00:00'::timestamp,
     9000023, '2026-09-11 12:13:29.592997'::timestamp, '0', '0', '0',
     5000023, 1, 1, 75, '2026-09-11 12:13:29.592997'::timestamp),

    (1000024, 2830263, 'МИТАЛАЕВ ХУСЕЙН УМАРОВИЧ', 1, 1, 1, 50, 60, 20, 2,
     '0', '0', '0', '0', NULL::bigint,
     'МИТАЛАЕВ ХУСЕЙН УМАРОВИЧ', 'МИТАЛАЕВ Х.У.', '051234567917',
     NULL::text, NULL::text, NULL::text, '1977-02-13 00:00:00'::timestamp,
     9000024, '2026-09-11 12:13:29.597226'::timestamp, '0', '0', '0',
     5000024, 1, 1, 70, '2026-09-11 12:13:29.597226'::timestamp)
) AS v(
    master_id, etalon_registry_id, name, status, er_type_id, is_actual,
    risk_level, attention_level, feature_count, subject_type,
    ko_sign, ip_sign, nr_sign, filial_sign, head_org_id,
    name_full, name_short, inn, ogrn, bic, swift, start_date,
    eor_h_id, eor_h_date, etalon_sign, manual_sign, deleted_sign,
    eor_change_id, object_change_role_id, local_change_type_id,
    rating, rating_date
)
WHERE NOT EXISTS (
    SELECT 1 FROM eor.idw_mr_master t
     WHERE t.etalon_registry_id = v.etalon_registry_id
);


-- =============================================================================
-- 7. eor.idwh2_etalon_flrn — эталон РФЛ (ОСНОВНОЙ источник кандидатов)
-- =============================================================================
INSERT INTO eor.idwh2_etalon_flrn (
    etalon_registry_id, inn, snils, full_name, family_name, first_name, second_name,
    gender, birth_date, birth_place, doc_type_id, doc_number, doc_date,
    doc_who, doc_code, oksm_code, address, address_reg_date, address_close_date,
    address_reason_close_id, ogrnip, inn_close_date, death_date, death_year,
    birth_year, full_name_lat, family_name_lat, first_name_lat, second_name_lat,
    doc_type_id_fns, address_reg
)
SELECT v.*
FROM (VALUES
    (2830258, '051234567912', '912-912-912 12',
     'МИФТАХЕТДИНОВ РАШИТ МИДХАТОВИЧ', 'МИФТАХЕТДИНОВ', 'РАШИТ', 'МИДХАТОВИЧ',
     'M', '1982-07-09 00:00:00'::timestamp,
     'Д. МЕРЯСОВО БАЙМАКСКОГО РАЙОНА РЕСПУБЛИКИ БАШКОРТОСТАН',
     1, '8207 567912', '2007-05-25 00:00:00'::timestamp,
     'ОВД БАЙМАКСКОГО РАЙОНА', '050-012', '643',
     'РЕСПУБЛИКА БАШКОРТОСТАН, Д. МЕРЯСОВО',
     '2007-06-01 00:00:00'::timestamp, NULL::timestamp, NULL::bigint,
     NULL::text, NULL::timestamp, NULL::timestamp, NULL::smallint, 1982::smallint,
     'MIFTAKHETDINOV RASHIT MIDKHATOVICH', 'MIFTAKHETDINOV', 'RASHIT', 'MIDKHATOVICH',
     1, 'РЕСПУБЛИКА БАШКОРТОСТАН, Д. МЕРЯСОВО'),

    (2830259, '051234567913', '913-913-913 13',
     'МИХАЙЛЯНЦ АЛЕКСАНДР АНАТОЛЬЕВИЧ', 'МИХАЙЛЯНЦ', 'АЛЕКСАНДР', 'АНАТОЛЬЕВИЧ',
     'M', '1971-01-30 00:00:00'::timestamp,
     'Г. ЛЕНИНСК КЗЫЛОРДИНСКОЙ ОБЛАСТИ РЕСПУБЛИКИ КАЗАХСТАН',
     1, '7101 678913', '2001-11-30 00:00:00'::timestamp,
     'ОВД Г. ЛЕНИНСК', '050-013', '643',
     'РОССИЯ, Г. МОСКВА',
     '2001-12-01 00:00:00'::timestamp, NULL::timestamp, NULL::bigint,
     NULL::text, NULL::timestamp, NULL::timestamp, NULL::smallint, 1971::smallint,
     'MIKHAYLYANTS ALEKSANDR ANATOLEVICH', 'MIKHAYLYANTS', 'ALEKSANDR', 'ANATOLEVICH',
     1, 'РОССИЯ, Г. МОСКВА'),

    (2830260, '051234567914', '914-914-914 14',
     'МИРЗАХАНОВ ФИЗУЛИ МАГОМЕДКЕРИМОВИЧ', 'МИРЗАХАНОВ', 'ФИЗУЛИ', 'МАГОМЕДКЕРИМОВИЧ',
     'M', '1978-10-26 00:00:00'::timestamp,
     'С. АККА ТАБАСАРАНСКОГО РАЙОНА РЕСПУБЛИКИ ДАГЕСТАН',
     1, '8205 123914', '2005-06-15 00:00:00'::timestamp,
     'ОВД ТАБАСАРАНСКОГО РАЙОНА', '050-014', '643',
     'РЕСПУБЛИКА ДАГЕСТАН, С. АККА',
     '2005-06-20 00:00:00'::timestamp, NULL::timestamp, NULL::bigint,
     NULL::text, NULL::timestamp, NULL::timestamp, NULL::smallint, 1978::smallint,
     'MIRZAKHANOV FIZULI MAGOMEDCHERIMOVICH', 'MIRZAKHANOV', 'FIZULI', 'MAGOMEDCHERIMOVICH',
     1, 'РЕСПУБЛИКА ДАГЕСТАН, С. АККА'),

    (2830261, '051234567915', '915-915-915 15',
     'МИРЗОЕВ ФЕЙРУЗ МУРАДОВИЧ', 'МИРЗОЕВ', 'ФЕЙРУЗ', 'МУРАДОВИЧ',
     'M', '1989-11-25 00:00:00'::timestamp,
     'Г. МУБАРЕК РЕСПУБЛИКИ УЗБЕКИСТАН',
     1, '8210 234915', '2010-03-20 00:00:00'::timestamp,
     'ОВД Г. МУБАРЕК', '050-015', '643',
     'РОССИЯ, Г. МОСКВА',
     '2010-04-01 00:00:00'::timestamp, NULL::timestamp, NULL::bigint,
     NULL::text, NULL::timestamp, NULL::timestamp, NULL::smallint, 1989::smallint,
     'MIRZOEV FEYRUZ MURADOVICH', 'MIRZOEV', 'FEYRUZ', 'MURADOVICH',
     1, 'РОССИЯ, Г. МОСКВА'),

    (2830262, '051234567916', '916-916-916 16',
     'МИТАЛАЕВ ЛЕЧИ ЖАНАДИЕВИЧ', 'МИТАЛАЕВ', 'ЛЕЧИ', 'ЖАНАДИЕВИЧ',
     'M', '1955-09-25 00:00:00'::timestamp,
     'Г. ЛЕНИНОГОРСК ВОСТОЧНО-КАЗАХСТАНСКОЙ ОБЛАСТИ КССР',
     1, '5509 345916', '2000-01-10 00:00:00'::timestamp,
     'ОВД Г. ЛЕНИНОГОРСК', '050-016', '643',
     'РОССИЯ, Г. МОСКВА',
     '2000-02-01 00:00:00'::timestamp, NULL::timestamp, NULL::bigint,
     NULL::text, NULL::timestamp, NULL::timestamp, NULL::smallint, 1955::smallint,
     'MITALAEV LECHI ZHANADIEVICH', 'MITALAEV', 'LECHI', 'ZHANADIEVICH',
     1, 'РОССИЯ, Г. МОСКВА'),

    (2830263, '051234567917', '917-917-917 17',
     'МИТАЛАЕВ ХУСЕЙН УМАРОВИЧ', 'МИТАЛАЕВ', 'ХУСЕЙН', 'УМАРОВИЧ',
     'M', '1977-02-13 00:00:00'::timestamp,
     'С. ВЕДЕНО ВЕДЕНСКОГО РАЙОНА ЧЕЧЕНСКОЙ РЕСПУБЛИКИ',
     1, '9702 456917', '2002-08-12 00:00:00'::timestamp,
     'ОВД ВЕДЕНСКОГО РАЙОНА', '050-017', '643',
     'ЧЕЧЕНСКАЯ РЕСПУБЛИКА, С. ВЕДЕНО',
     '2002-09-01 00:00:00'::timestamp, NULL::timestamp, NULL::bigint,
     NULL::text, NULL::timestamp, NULL::timestamp, NULL::smallint, 1977::smallint,
     'MITALAEV KHUSEYN UMAROVICH', 'MITALAEV', 'KHUSEYN', 'UMAROVICH',
     1, 'ЧЕЧЕНСКАЯ РЕСПУБЛИКА, С. ВЕДЕНО')
) AS v(
    etalon_registry_id, inn, snils, full_name, family_name, first_name, second_name,
    gender, birth_date, birth_place, doc_type_id, doc_number, doc_date,
    doc_who, doc_code, oksm_code, address, address_reg_date, address_close_date,
    address_reason_close_id, ogrnip, inn_close_date, death_date, death_year,
    birth_year, full_name_lat, family_name_lat, first_name_lat, second_name_lat,
    doc_type_id_fns, address_reg
)
WHERE NOT EXISTS (
    SELECT 1 FROM eor.idwh2_etalon_flrn t
     WHERE t.etalon_registry_id = v.etalon_registry_id
);


-- =============================================================================
-- 8. eor.idwh2_etalon_nr_fl — эталон ИФЛ (вспомогательный)
-- =============================================================================
INSERT INTO eor.idwh2_etalon_nr_fl (
    etalon_registry_id, full_name, family_name, first_name, second_name,
    birth_date, doc_number, doc_date, address_reg, address_fakt,
    inn, snils, gender, birth_place, doc_type_id, doc_who, doc_code,
    oksm_code, address_reg_date, address_close_date, address_reason_close_id,
    ogrnip, inn_close_date, death_date, death_year, birth_year,
    full_name_lat, family_name_lat, first_name_lat, second_name_lat,
    doc_type_id_fns
)
SELECT v.*
FROM (VALUES
    (2830258, 'МИФТАХЕТДИНОВ РАШИТ МИДХАТОВИЧ', 'МИФТАХЕТДИНОВ', 'РАШИТ', 'МИДХАТОВИЧ',
     '1982-07-09 00:00:00'::timestamp, '8207 567912', '2007-05-25 00:00:00'::timestamp,
     'РЕСПУБЛИКА БАШКОРТОСТАН, Д. МЕРЯСОВО', 'РЕСПУБЛИКА БАШКОРТОСТАН, Д. МЕРЯСОВО',
     '051234567912', '912-912-912 12', 'M', 'Д. МЕРЯСОВО БАЙМАКСКОГО РАЙОНА РЕСПУБЛИКИ БАШКОРТОСТАН',
     1, 'ОВД БАЙМАКСКОГО РАЙОНА', '050-012', '643',
     '2007-06-01 00:00:00'::timestamp, NULL::timestamp, NULL::bigint,
     NULL::text, NULL::timestamp, NULL::timestamp, NULL::smallint, 1982::smallint,
     'MIFTAKHETDINOV RASHIT MIDKHATOVICH', 'MIFTAKHETDINOV', 'RASHIT', 'MIDKHATOVICH', 1),

    (2830259, 'МИХАЙЛЯНЦ АЛЕКСАНДР АНАТОЛЬЕВИЧ', 'МИХАЙЛЯНЦ', 'АЛЕКСАНДР', 'АНАТОЛЬЕВИЧ',
     '1971-01-30 00:00:00'::timestamp, '7101 678913', '2001-11-30 00:00:00'::timestamp,
     'КАЗАХСТАН, КЗЫЛОРДИНСКАЯ ОБЛ., Г. ЛЕНИНСК', 'РОССИЯ, Г. МОСКВА',
     '051234567913', '913-913-913 13', 'M', 'Г. ЛЕНИНСК КЗЫЛОРДИНСКОЙ ОБЛАСТИ РЕСПУБЛИКИ КАЗАХСТАН',
     1, 'ОВД Г. ЛЕНИНСК', '050-013', '398',
     '2001-12-01 00:00:00'::timestamp, NULL::timestamp, NULL::bigint,
     NULL::text, NULL::timestamp, NULL::timestamp, NULL::smallint, 1971::smallint,
     'MIKHAYLYANTS ALEKSANDR ANATOLEVICH', 'MIKHAYLYANTS', 'ALEKSANDR', 'ANATOLEVICH', 1),

    (2830260, 'МИРЗАХАНОВ ФИЗУЛИ МАГОМЕДКЕРИМОВИЧ', 'МИРЗАХАНОВ', 'ФИЗУЛИ', 'МАГОМЕДКЕРИМОВИЧ',
     '1978-10-26 00:00:00'::timestamp, '8205 123914', '2005-06-15 00:00:00'::timestamp,
     'РЕСПУБЛИКА ДАГЕСТАН, С. АККА', 'РЕСПУБЛИКА ДАГЕСТАН, С. АККА',
     '051234567914', '914-914-914 14', 'M', 'С. АККА ТАБАСАРАНСКОГО РАЙОНА РЕСПУБЛИКИ ДАГЕСТАН',
     1, 'ОВД ТАБАСАРАНСКОГО РАЙОНА', '050-014', '643',
     '2005-06-20 00:00:00'::timestamp, NULL::timestamp, NULL::bigint,
     NULL::text, NULL::timestamp, NULL::timestamp, NULL::smallint, 1978::smallint,
     'MIRZAKHANOV FIZULI MAGOMEDCHERIMOVICH', 'MIRZAKHANOV', 'FIZULI', 'MAGOMEDCHERIMOVICH', 1),

    (2830261, 'МИРЗОЕВ ФЕЙРУЗ МУРАДОВИЧ', 'МИРЗОЕВ', 'ФЕЙРУЗ', 'МУРАДОВИЧ',
     '1989-11-25 00:00:00'::timestamp, '8210 234915', '2010-03-20 00:00:00'::timestamp,
     'РЕСПУБЛИКА УЗБЕКИСТАН, Г. МУБАРЕК', 'РОССИЯ, Г. МОСКВА',
     '051234567915', '915-915-915 15', 'M', 'Г. МУБАРЕК РЕСПУБЛИКИ УЗБЕКИСТАН',
     1, 'ОВД Г. МУБАРЕК', '050-015', '860',
     '2010-04-01 00:00:00'::timestamp, NULL::timestamp, NULL::bigint,
     NULL::text, NULL::timestamp, NULL::timestamp, NULL::smallint, 1989::smallint,
     'MIRZOEV FEYRUZ MURADOVICH', 'MIRZOEV', 'FEYRUZ', 'MURADOVICH', 1),

    (2830262, 'МИТАЛАЕВ ЛЕЧИ ЖАНАДИЕВИЧ', 'МИТАЛАЕВ', 'ЛЕЧИ', 'ЖАНАДИЕВИЧ',
     '1955-09-25 00:00:00'::timestamp, '5509 345916', '2000-01-10 00:00:00'::timestamp,
     'КАЗАХСТАН, ВОСТОЧНО-КАЗАХСТАНСКАЯ ОБЛ., Г. ЛЕНИНОГОРСК', 'РОССИЯ, Г. МОСКВА',
     '051234567916', '916-916-916 16', 'M', 'Г. ЛЕНИНОГОРСК ВОСТОЧНО-КАЗАХСТАНСКОЙ ОБЛАСТИ КССР',
     1, 'ОВД Г. ЛЕНИНОГОРСК', '050-016', '398',
     '2000-02-01 00:00:00'::timestamp, NULL::timestamp, NULL::bigint,
     NULL::text, NULL::timestamp, NULL::timestamp, NULL::smallint, 1955::smallint,
     'MITALAEV LECHI ZHANADIEVICH', 'MITALAEV', 'LECHI', 'ZHANADIEVICH', 1),

    (2830263, 'МИТАЛАЕВ ХУСЕЙН УМАРОВИЧ', 'МИТАЛАЕВ', 'ХУСЕЙН', 'УМАРОВИЧ',
     '1977-02-13 00:00:00'::timestamp, '9702 456917', '2002-08-12 00:00:00'::timestamp,
     'ЧЕЧЕНСКАЯ РЕСПУБЛИКА, С. ВЕДЕНО', 'ЧЕЧЕНСКАЯ РЕСПУБЛИКА, С. ВЕДЕНО',
     '051234567917', '917-917-917 17', 'M', 'С. ВЕДЕНО ВЕДЕНСКОГО РАЙОНА ЧЕЧЕНСКОЙ РЕСПУБЛИКИ',
     1, 'ОВД ВЕДЕНСКОГО РАЙОНА', '050-017', '643',
     '2002-09-01 00:00:00'::timestamp, NULL::timestamp, NULL::bigint,
     NULL::text, NULL::timestamp, NULL::timestamp, NULL::smallint, 1977::smallint,
     'MITALAEV KHUSEYN UMAROVICH', 'MITALAEV', 'KHUSEYN', 'UMAROVICH', 1)
) AS v(
    etalon_registry_id, full_name, family_name, first_name, second_name,
    birth_date, doc_number, doc_date, address_reg, address_fakt,
    inn, snils, gender, birth_place, doc_type_id, doc_who, doc_code,
    oksm_code, address_reg_date, address_close_date, address_reason_close_id,
    ogrnip, inn_close_date, death_date, death_year, birth_year,
    full_name_lat, family_name_lat, first_name_lat, second_name_lat,
    doc_type_id_fns
)
WHERE NOT EXISTS (
    SELECT 1 FROM eor.idwh2_etalon_nr_fl t
     WHERE t.etalon_registry_id = v.etalon_registry_id
);


-- =============================================================================
-- 9. КОНТРОЛЬ ПОЛНОТЫ
-- =============================================================================
-- =============================================================================
-- КОНТРОЛЬ ПОЛНОТЫ ТЕСТОВЫХ ДАННЫХ
-- Набор: sr_subject_id 2830258..2830263
--
-- Ожидаемое состояние после загрузки (до прогона процедуры):
--   sr_subject_pdl               — 6
--   idw_arj_interfax_pdl_load_buffer — 6
--   idw_mr_master                — 6
--   idwh2_etalon_flrn            — 6
--   idwh2_etalon_nr_fl           — 6
--   sr_subject                   — 3 (для UPDATE)
--   sr_event                     — 3 (созданы блоком 5)
--   sr_subject_h                 — 0 (предзаполнение закомментировано)
--   sr_subject.sr_event_id       — заполнен для 2830258, 2830260, 2830262
-- =============================================================================
DO $$
DECLARE
    l_pdl              INTEGER;
    l_buf              INTEGER;
    l_master           INTEGER;
    l_missing_master   INTEGER;
    l_flrn             INTEGER;
    l_missing_flrn     INTEGER;
    l_flrn_name_ok     INTEGER;
    l_flrn_birth_ok    INTEGER;
    l_nr_fl            INTEGER;

    l_subject          INTEGER;
    l_event            INTEGER;
    l_h_total          INTEGER;

    l_subject_event_ok INTEGER;   -- sr_subject.sr_event_id заполнен
    l_event_fk_ok      INTEGER;   -- sr_event.sr_event_id валидны в sr_event

    l_etalon_1         INTEGER;
    l_etalon_0         INTEGER;
    l_rfl_count        INTEGER;
    l_ifl_count        INTEGER;

    l_fail             INTEGER := 0;
BEGIN
    RAISE NOTICE '===== КОНТРОЛЬ ПОЛНОТЫ ТЕСТОВЫХ ДАННЫХ =====';

    -------------------------------------------------------------------------
    -- 1. ОПОРНЫЕ ДАННЫЕ
    -------------------------------------------------------------------------

    -- 1.1. sr_subject_pdl
    SELECT COUNT(*) INTO l_pdl
      FROM sr.sr_subject_pdl
     WHERE sr_subject_id BETWEEN 2830258 AND 2830263;
    IF l_pdl = 6 THEN
        RAISE NOTICE '[OK]   sr_subject_pdl: 6 записей';
    ELSE
        RAISE WARNING '[FAIL] sr_subject_pdl: ожидалось 6, найдено %', l_pdl;
        l_fail := l_fail + 1;
    END IF;

    -- 1.2. arch_ext.idw_arj_interfax_pdl_load_buffer
    SELECT COUNT(*) INTO l_buf
      FROM arch_ext.idw_arj_interfax_pdl_load_buffer
     WHERE sr_subject_id BETWEEN 2830258 AND 2830263;
    IF l_buf = 6 THEN
        RAISE NOTICE '[OK]   idw_arj_interfax_pdl_load_buffer: 6 записей';
    ELSE
        RAISE WARNING '[FAIL] idw_arj_interfax_pdl_load_buffer: ожидалось 6, найдено %', l_buf;
        l_fail := l_fail + 1;
    END IF;

    -------------------------------------------------------------------------
    -- 2. ПРОИЗВОДНЫЕ ОБЪЕКТЫ ЕОР
    -------------------------------------------------------------------------

    -- 2.1. idw_mr_master
    SELECT COUNT(*) INTO l_master
      FROM eor.idw_mr_master
     WHERE etalon_registry_id BETWEEN 2830258 AND 2830263;

    SELECT COUNT(*) INTO l_missing_master
      FROM sr.sr_subject_pdl p
     WHERE p.sr_subject_id BETWEEN 2830258 AND 2830263
       AND NOT EXISTS (
           SELECT 1 FROM eor.idw_mr_master m
            WHERE m.etalon_registry_id = p.sr_subject_id
       );
    IF l_master = 6 AND l_missing_master = 0 THEN
        RAISE NOTICE '[OK]   idw_mr_master: 6 записей (не хватает 0)';
    ELSE
        RAISE WARNING '[FAIL] idw_mr_master: %, не хватает %', l_master, l_missing_master;
        l_fail := l_fail + 1;
    END IF;

    -- 2.2. idwh2_etalon_flrn
    SELECT COUNT(*) INTO l_flrn
      FROM eor.idwh2_etalon_flrn
     WHERE etalon_registry_id BETWEEN 2830258 AND 2830263;

    SELECT COUNT(*) INTO l_missing_flrn
      FROM sr.sr_subject_pdl p
     WHERE p.sr_subject_id BETWEEN 2830258 AND 2830263
       AND NOT EXISTS (
           SELECT 1 FROM eor.idwh2_etalon_flrn f
            WHERE f.etalon_registry_id = p.sr_subject_id
       );

    SELECT COUNT(*) INTO l_flrn_name_ok
      FROM sr.sr_subject_pdl p
      JOIN eor.idwh2_etalon_flrn f ON f.etalon_registry_id = p.sr_subject_id
     WHERE p.sr_subject_id BETWEEN 2830258 AND 2830263
       AND f.full_name = TRIM(UPPER(p.full_name));

    SELECT COUNT(*) INTO l_flrn_birth_ok
      FROM sr.sr_subject_pdl p
      JOIN eor.idwh2_etalon_flrn f ON f.etalon_registry_id = p.sr_subject_id
     WHERE p.sr_subject_id BETWEEN 2830258 AND 2830263
       AND f.birth_date = p.date_birthday;

    IF l_flrn = 6 AND l_missing_flrn = 0 AND l_flrn_name_ok = 6 AND l_flrn_birth_ok = 6 THEN
        RAISE NOTICE '[OK]   idwh2_etalon_flrn: 6 записей (ФИО 6/6, ДР 6/6)';
    ELSE
        RAISE WARNING '[FAIL] idwh2_etalon_flrn: %, не хватает %, ФИО %/6, ДР %/6',
            l_flrn, l_missing_flrn, l_flrn_name_ok, l_flrn_birth_ok;
        l_fail := l_fail + 1;
    END IF;

    -- 2.3. idwh2_etalon_nr_fl
    SELECT COUNT(*) INTO l_nr_fl
      FROM eor.idwh2_etalon_nr_fl
     WHERE etalon_registry_id BETWEEN 2830258 AND 2830263;
    IF l_nr_fl = 6 THEN
        RAISE NOTICE '[OK]   idwh2_etalon_nr_fl: 6 записей';
    ELSE
        RAISE WARNING '[FAIL] idwh2_etalon_nr_fl: ожидалось 6, найдено %', l_nr_fl;
        l_fail := l_fail + 1;
    END IF;

    -------------------------------------------------------------------------
    -- 3. СПЕЦРЕЕСТР: sr_subject / sr_event / sr_subject_h
    -------------------------------------------------------------------------

    -- 3.1. sr_subject — 3 записи (для ветки UPDATE)
    SELECT COUNT(*) INTO l_subject
      FROM sr.sr_subject
     WHERE sr_subject_id IN (2830258, 2830260, 2830262)
       AND sr_type_id = 145;
    IF l_subject = 3 THEN
        RAISE NOTICE '[OK]   sr_subject: 3 записи (для UPDATE-ветки)';
    ELSE
        RAISE WARNING '[FAIL] sr_subject: ожидалось 3, найдено %', l_subject;
        l_fail := l_fail + 1;
    END IF;

    -- 3.2. sr_event — 3 записи (созданы блоком 5)
    SELECT COUNT(*) INTO l_event
      FROM sr.sr_event
     WHERE sr_subject_id IN (2830258, 2830260, 2830262)
       AND sr_type_id = 145;
    IF l_event = 3 THEN
        RAISE NOTICE '[OK]   sr_event: 3 записи';
    ELSE
        RAISE WARNING '[FAIL] sr_event: ожидалось 3, найдено %', l_event;
        l_fail := l_fail + 1;
    END IF;

    -- 3.3. sr_subject_h — 0 записей (предзаполнение закомментировано)
    SELECT COUNT(*) INTO l_h_total
      FROM sr.sr_subject_h
     WHERE sr_subject_id IN (2830258, 2830260, 2830262)
       AND sr_type_id = 145;
    IF l_h_total = 0 THEN
        RAISE NOTICE '[OK]   sr_subject_h: 0 записей (предзаполнение отключено)';
    ELSE
        RAISE WARNING '[INFO] sr_subject_h: найдено % записей (ожидалось 0)', l_h_total;
        -- Не считаем это провалом — процедура может их добавить при прогоне
    END IF;

    -- 3.4. sr_subject.sr_event_id заполнен для всех 3
    SELECT COUNT(*) INTO l_subject_event_ok
      FROM sr.sr_subject
     WHERE sr_subject_id IN (2830258, 2830260, 2830262)
       AND sr_type_id = 145
       AND sr_event_id IS NOT NULL;
    IF l_subject_event_ok = 3 THEN
        RAISE NOTICE '[OK]   sr_subject.sr_event_id: заполнен для всех 3';
    ELSE
        RAISE WARNING '[FAIL] sr_subject.sr_event_id: заполнен только для %',
            l_subject_event_ok;
        l_fail := l_fail + 1;
    END IF;

    -- 3.5. sr_subject.sr_event_id ссылается на существующие sr_event
    SELECT COUNT(*) INTO l_event_fk_ok
      FROM sr.sr_subject s
      JOIN sr.sr_event  e ON e.sr_event_id = s.sr_event_id
     WHERE s.sr_subject_id IN (2830258, 2830260, 2830262)
       AND s.sr_type_id = 145;
    IF l_event_fk_ok = 3 THEN
        RAISE NOTICE '[OK]   sr_subject.sr_event_id → sr_event: FK валидны (3)';
    ELSE
        RAISE WARNING '[FAIL] sr_subject.sr_event_id → sr_event: % из 3',
            l_event_fk_ok;
        l_fail := l_fail + 1;
    END IF;

    -------------------------------------------------------------------------
    -- 4. ПОКРЫТИЕ ВЕТОК
    -------------------------------------------------------------------------

    -- 4.1. etalon_sign='1'
    SELECT COUNT(*) INTO l_etalon_1
      FROM eor.idw_mr_master
     WHERE etalon_registry_id BETWEEN 2830258 AND 2830263
       AND etalon_sign = '1';

    -- 4.2. etalon_sign='0'
    SELECT COUNT(*) INTO l_etalon_0
      FROM eor.idw_mr_master
     WHERE etalon_registry_id BETWEEN 2830258 AND 2830263
       AND etalon_sign = '0';

    IF l_etalon_1 > 0 AND l_etalon_0 > 0 THEN
        RAISE NOTICE '[OK]   etalon_sign: ''1''=%, ''0''=%', l_etalon_1, l_etalon_0;
    ELSE
        RAISE WARNING '[FAIL] etalon_sign: ''1''=%, ''0''=% (не покрыты обе ветки)',
            l_etalon_1, l_etalon_0;
        l_fail := l_fail + 1;
    END IF;

    -- 4.3. l_is_rfl=1
    SELECT COUNT(*) INTO l_rfl_count
      FROM sr.sr_subject_pdl
     WHERE sr_subject_id BETWEEN 2830258 AND 2830263
       AND (UPPER(countries) LIKE '%РОССИЯ%' OR countries IS NULL);

    -- 4.4. l_is_rfl=0
    SELECT COUNT(*) INTO l_ifl_count
      FROM sr.sr_subject_pdl
     WHERE sr_subject_id BETWEEN 2830258 AND 2830263
       AND NOT (UPPER(countries) LIKE '%РОССИЯ%' OR countries IS NULL);

    IF l_rfl_count > 0 AND l_ifl_count > 0 THEN
        RAISE NOTICE '[OK]   l_is_rfl: РФЛ(1)=%, ИФЛ(0)=%', l_rfl_count, l_ifl_count;
    ELSE
        RAISE WARNING '[FAIL] l_is_rfl: РФЛ=%, ИФЛ=% (не покрыты обе ветки)',
            l_rfl_count, l_ifl_count;
        l_fail := l_fail + 1;
    END IF;

    -- 4.5. Покрытие веток sr_subject
    RAISE NOTICE '[INFO] sr_subject: UPDATE=% (2830258, 2830260, 2830262), INSERT=3 (2830259, 2830261, 2830263)',
        l_subject;

    -------------------------------------------------------------------------
    -- 5. ДУБЛИ
    -------------------------------------------------------------------------

    DECLARE
        l_dups INTEGER;
    BEGIN
        -- Дубли full_name в sr_subject_pdl
        SELECT COUNT(*) INTO l_dups FROM (
            SELECT full_name FROM sr.sr_subject_pdl
             WHERE sr_subject_id BETWEEN 2830258 AND 2830263
             GROUP BY full_name HAVING COUNT(*) > 1
        ) d;
        IF l_dups = 0 THEN
            RAISE NOTICE '[OK]   sr_subject_pdl: нет дублей full_name';
        ELSE
            RAISE WARNING '[FAIL] sr_subject_pdl: дублей full_name = %', l_dups;
            l_fail := l_fail + 1;
        END IF;

        -- Дубли id в буфере
        SELECT COUNT(*) INTO l_dups FROM (
            SELECT id FROM arch_ext.idw_arj_interfax_pdl_load_buffer
             WHERE sr_subject_id BETWEEN 2830258 AND 2830263
             GROUP BY id HAVING COUNT(*) > 1
        ) d;
        IF l_dups = 0 THEN
            RAISE NOTICE '[OK]   буфер: нет дублей id';
        ELSE
            RAISE WARNING '[FAIL] буфер: дублей id = %', l_dups;
            l_fail := l_fail + 1;
        END IF;
    END;

    -------------------------------------------------------------------------
    -- ИТОГ
    -------------------------------------------------------------------------
    IF l_fail = 0 THEN
        RAISE NOTICE '===== КОНТРОЛЬ ПРОЙДЕН: ВСЁ OK =====';
    ELSE
        RAISE WARNING '===== КОНТРОЛЬ ЗАВЕРШЁН: ПРОВАЛЕНО % ПРОВЕРОК =====', l_fail;
    END IF;
END $$;

-- =============================================================================
-- 1.4. Создание опорных таблиц расчёта
-- =============================================================================
CREATE TABLE IF NOT EXISTS eor.test_eor_subject_id(
    id bigint,
    CONSTRAINT test_eor_subject_id_pk PRIMARY KEY (id)
);

INSERT INTO eor.test_eor_subject_id(id)
VALUES
    (1),
    (2),
    (3),
    (4),
    (5),
    (6)
ON CONFLICT (id) DO NOTHING;

-- Формирование очереди
INSERT INTO process_info.idw_sy_workflow_info(
    workflow_id, state_id, object_id, error_sign, priority, create_date, state_date
)
SELECT 225, 2252, ts.id::text, '0', 50, clock_timestamp(), clock_timestamp()
FROM eor.test_eor_subject_id ts
WHERE NOT EXISTS (
    SELECT *
    FROM process_info.idw_sy_workflow_info
    WHERE (workflow_id, state_id, object_id) = (225, 2252, ts.id::text)
);

-- 1.6. Опорная таблица процесса расчёта
CREATE TABLE IF NOT EXISTS eor.test_eor_subject_process(
    id bigint,
    dt_bgn timestamp,
    dt_end timestamp
);


-- =============================================================================
-- 2. ПОКАЗ. ЗАПУСК.
-- =============================================================================
DO $$
DECLARE
    l_process_id int8;
BEGIN
    -- Test
    SELECT process_manage.start_process(
         p_p_process_type    => 'PR_EOR_PDL_IDENT'
        ,p_p_id_main_process => NULL
        ,p_p_process_plan_id => NULL
        ,p_p_msg             => NULL
        ,p_p_comments        => NULL
    )
    INTO l_process_id;

    INSERT INTO eor.test_eor_subject_process(id, dt_bgn)
    VALUES (l_process_id, clock_timestamp());

    CALL eor.pr_eor_pdl_ident(
         p_process_log_id => l_process_id
        ,p_cnt_flow       => NULL::smallint
        ,p_num_flow       => NULL::smallint
    );

    CALL process_manage.finish_process(l_process_id, NULL);

    UPDATE eor.test_eor_subject_process
       SET dt_end = clock_timestamp()
     WHERE id = l_process_id;
END $$;


-- =============================================================================
-- 3. ПОКАЗ. РЕЗУЛЬТАТЫ.
-- =============================================================================

-- Логирование
SELECT t.*
FROM process_info.tbltracer t
INNER JOIN eor.test_eor_subject_process tt
    ON tt.id::text = t.msg2
ORDER BY t.seqnum;

-- Данные для расчёта
SELECT *
FROM eor.test_eor_subject_id;

-- Настройки процесса обработки
SELECT *
FROM process_info.process_state
WHERE process_alias = 'PR_EOR_PDL_IDENT';

-- Атрибуты процесса обработки
SELECT *
FROM eor.test_eor_subject_process;

-- Опорная таблица буфера изменений субъектов
SELECT *
FROM arch_ext.idw_arj_interfax_pdl_load_buffer;

-- Список субъектов в подвале на основе опорной таблицы (6)
SELECT *
FROM sr.sr_subject_pdl dst
WHERE dst.sr_subject_id IN (
    SELECT sr_subject_id
    FROM arch_ext.idw_arj_interfax_pdl_load_buffer
);

-- Список субъектов в подвале на основе опорной таблицы
SELECT *
FROM sr.sr_subject dst
WHERE dst.sr_subject_id IN (
    SELECT sr_subject_id
    FROM arch_ext.idw_arj_interfax_pdl_load_buffer
);
-- Очередь (должна отсутствовать) записи процесса (225/2252)
SELECT *
FROM process_info.idw_sy_workflow_info
WHERE workflow_id = 225
  AND state_id    = 2252
  AND object_id IN (
      SELECT t.id::text
      FROM eor.test_eor_subject_id t
  );

-- Ошибки обработки (0)
SELECT we.*
FROM process_info.idw_sy_workflow_error we
WHERE we.workflow_id = 225
  AND we.state_id    = 2252
  AND we.object_id IN (
      SELECT t.id::text
      FROM eor.test_eor_subject_id t
  );

-- Упоминания (5)
SELECT *
FROM eor.idw_mr_subject_mention
WHERE source_id = 2070
  AND eor_mention_type_id = 3
  AND external_h_id IN (
      SELECT t.id::text
      FROM arch_ext.idw_arj_interfax_pdl_load_buffer t
  );

-- Атрибуты idw_mr_subject_mention (РФЛ) (5- записей)
WITH mention_rfl AS (
    SELECT *
    FROM eor.idw_mr_subject_mention
    WHERE source_id = 2070
      AND eor_mention_type_id = 3
      AND external_h_id IN (
          SELECT t.id::text
          FROM arch_ext.idw_arj_interfax_pdl_load_buffer t
      )
)
SELECT *
FROM eor.idw_mr_rfl_attr_src
WHERE mention_attribute_id IN (
    SELECT mention_attribute_id
    FROM mention_rfl
);

-- Атрибуты idw_mr_ifl_attr_src (ИФЛ) должна быть одна запись)
WITH mention_ifl AS (
    SELECT *
    FROM eor.idw_mr_subject_mention
    WHERE source_id = 2070
      AND eor_mention_type_id = 7
      AND external_h_id IN (
          SELECT t.id::text
          FROM arch_ext.idw_arj_interfax_pdl_load_buffer t
      )
)
SELECT *
FROM eor.idw_mr_ifl_attr_src
WHERE mention_attribute_id IN (
    SELECT mention_attribute_id
    FROM mention_ifl
);

-- sr.sr_subject (должно быть 6 записей)
SELECT *
FROM sr.sr_subject
WHERE sr_type_id = 145
  AND sr_subject_id IN (
      SELECT t.sr_subject_id
      FROM arch_ext.idw_arj_interfax_pdl_load_buffer t
  );

-- sr.sr_event (6)
SELECT *
FROM sr.sr_event
WHERE sr_type_id = 145
  AND sr_subject_id IN (
      SELECT t.sr_subject_id
      FROM arch_ext.idw_arj_interfax_pdl_load_buffer t
  )and description is null;

-- sr.sr_subject_h (3 записи)
SELECT *
FROM sr.sr_subject_h
WHERE sr_type_id = 145 and sr_subject_id IN (
      SELECT t.sr_subject_id
      FROM arch_ext.idw_arj_interfax_pdl_load_buffer t
  ) ;

-- sr.sr_subject_pdl (контроль is_eor_ident_process = 1 6 записей)
SELECT is_eor_ident_process, x.*
FROM sr.sr_subject_pdl x
WHERE sr_subject_id IN (
    SELECT t.sr_subject_id
    FROM arch_ext.idw_arj_interfax_pdl_load_buffer t
);


-- =============================================================================
-- 4. ОТКАТ. ОЧИСТКА ДАННЫХ ПРЕДЫДУЩЕГО РАСЧЁТА
-- =============================================================================

-- =============================================================================
-- 4.0. ДИАГНОСТИКА: состояние ДО зачистки
-- =============================================================================
DO $$
DECLARE
    l_err     INTEGER;
    l_wi      INTEGER;
    l_wi_men  INTEGER;
    l_men     INTEGER;
    l_rfl     INTEGER;
    l_ifl     INTEGER;
    l_subj    INTEGER;
    l_subj_h  INTEGER;
    l_event   INTEGER;
    l_pdl     INTEGER;
BEGIN
    RAISE NOTICE '===== ДИАГНОСТИКА ДО ЗАЧИСТКИ =====';

    SELECT COUNT(*) INTO l_err FROM process_info.idw_sy_workflow_error
     WHERE workflow_id = 225 AND state_id = 2252;

    SELECT COUNT(*) INTO l_wi FROM process_info.idw_sy_workflow_info
     WHERE workflow_id = 225 AND state_id = 2252;

    SELECT COUNT(*) INTO l_wi_men FROM process_info.idw_sy_workflow_info
     WHERE workflow_id IN (93, 96) AND state_id IN (931, 961);

    SELECT COUNT(*) INTO l_men FROM eor.idw_mr_subject_mention
     WHERE source_id = 2070
       AND external_h_id IN (
           SELECT t.id::text FROM arch_ext.idw_arj_interfax_pdl_load_buffer t
       );

    SELECT COUNT(*) INTO l_rfl FROM eor.idw_mr_rfl_attr_src;
    SELECT COUNT(*) INTO l_ifl FROM eor.idw_mr_ifl_attr_src;

    SELECT COUNT(*) INTO l_subj FROM sr.sr_subject
     WHERE sr_type_id = 145
       AND sr_subject_id IN (SELECT t.sr_subject_id FROM arch_ext.idw_arj_interfax_pdl_load_buffer t);

    SELECT COUNT(*) INTO l_subj_h FROM sr.sr_subject_h
     WHERE sr_type_id = 145
       AND sr_subject_id IN (SELECT t.sr_subject_id FROM arch_ext.idw_arj_interfax_pdl_load_buffer t);

    SELECT COUNT(*) INTO l_event FROM sr.sr_event
     WHERE sr_type_id = 145
       AND sr_subject_id IN (SELECT t.sr_subject_id FROM arch_ext.idw_arj_interfax_pdl_load_buffer t);

    SELECT COUNT(*) INTO l_pdl FROM sr.sr_subject_pdl
     WHERE sr_subject_id IN (SELECT t.sr_subject_id FROM arch_ext.idw_arj_interfax_pdl_load_buffer t)
       AND is_eor_ident_process = 1;

    RAISE NOTICE '[4.0] idw_sy_workflow_error (225/2252):            %', l_err;
    RAISE NOTICE '[4.0] idw_sy_workflow_info (225/2252):             %', l_wi;
    RAISE NOTICE '[4.0] idw_sy_workflow_info (93/931, 96/961):       %', l_wi_men;
    RAISE NOTICE '[4.0] idw_mr_subject_mention (2070):              %', l_men;
    RAISE NOTICE '[4.0] idw_mr_rfl_attr_src (всего):                %', l_rfl;
    RAISE NOTICE '[4.0] idw_mr_ifl_attr_src (всего):                %', l_ifl;
    RAISE NOTICE '[4.0] sr_subject:                                  %', l_subj;
    RAISE NOTICE '[4.0] sr_subject_h:                                %', l_subj_h;
    RAISE NOTICE '[4.0] sr_event:                                    %', l_event;
    RAISE NOTICE '[4.0] sr_subject_pdl (is_eor_ident_process=1):     %', l_pdl;
END $$;


-- =============================================================================
-- 4.1. Удаление ошибок расчёта
-- =============================================================================
DO $$
DECLARE
    l_del INTEGER;
BEGIN
    DELETE FROM process_info.idw_sy_workflow_error we
    WHERE we.workflow_id = 225
      AND we.state_id    = 2252
      AND we.object_id IN (
          SELECT t.id::text
          FROM eor.test_eor_subject_id t
      );

    GET DIAGNOSTICS l_del = ROW_COUNT;
    RAISE NOTICE '[4.1] idw_sy_workflow_error (225/2252): удалено %', l_del;
END $$;


-- =============================================================================
-- 4.2. Очистка очереди fors
-- =============================================================================
DO $$
DECLARE
    l_del INTEGER;
BEGIN
    DELETE FROM process_info.idw_sy_workflow_info
    WHERE workflow_id = 225
      AND state_id    = 2252
      AND object_id IN (
          SELECT id::text
          FROM eor.test_eor_subject_id
      );

    GET DIAGNOSTICS l_del = ROW_COUNT;
    RAISE NOTICE '[4.2] idw_sy_workflow_info (225/2252): удалено %', l_del;
END $$;


-- =============================================================================
-- 4.3. Очистка очереди упоминаний (93/931, 96/961)
-- =============================================================================
DO $$
DECLARE
    l_del INTEGER;
BEGIN
    DELETE FROM process_info.idw_sy_workflow_info
    WHERE workflow_id IN (93, 96)
      AND state_id    IN (931, 961)
      AND object_id IN (
          SELECT m.eor_subject_mention_id::text
          FROM eor.idw_mr_subject_mention m
          WHERE m.source_id = 2070
            AND m.external_h_id IN (
                SELECT t.id::text
                FROM arch_ext.idw_arj_interfax_pdl_load_buffer t
            )
      );

    GET DIAGNOSTICS l_del = ROW_COUNT;
    RAISE NOTICE '[4.3] idw_sy_workflow_info (93/931, 96/961): удалено %', l_del;
END $$;


-- =============================================================================
-- 4.4. Очистка упоминаний eor.idw_mr_rfl_attr_src
-- =============================================================================
DO $$
DECLARE
    l_del_mention INTEGER;
    l_del_attr    INTEGER;
BEGIN
    WITH del_rfl AS (
        DELETE FROM eor.idw_mr_subject_mention
        WHERE source_id = 2070
          AND eor_mention_type_id = 3
          AND external_h_id IN (
              SELECT t.id::text
              FROM arch_ext.idw_arj_interfax_pdl_load_buffer t
          )
        RETURNING mention_attribute_id
    )
    DELETE FROM eor.idw_mr_rfl_attr_src
    WHERE mention_attribute_id IN (
        SELECT mention_attribute_id FROM del_rfl
    );

    GET DIAGNOSTICS l_del_attr = ROW_COUNT;
    RAISE NOTICE '[4.4] idw_mr_rfl_attr_src: удалено %', l_del_attr;
END $$;


-- =============================================================================
-- 4.5. Очистка упоминаний eor.idw_mr_ifl_attr_src
-- =============================================================================
DO $$
DECLARE
    l_del_attr INTEGER;
BEGIN
    WITH del_ifl AS (
        DELETE FROM eor.idw_mr_subject_mention
        WHERE source_id = 2070
          AND eor_mention_type_id = 7
          AND external_h_id IN (
              SELECT t.id::text
              FROM arch_ext.idw_arj_interfax_pdl_load_buffer t
          )
        RETURNING mention_attribute_id
    )
    DELETE FROM eor.idw_mr_ifl_attr_src
    WHERE mention_attribute_id IN (
        SELECT mention_attribute_id FROM del_ifl
    );

    GET DIAGNOSTICS l_del_attr = ROW_COUNT;
    RAISE NOTICE '[4.5] idw_mr_ifl_attr_src: удалено %', l_del_attr;
END $$;


-- =============================================================================
-- 4.6. sr.sr_subject_h — история субъекта
-- Удаляем ПЕРВОЙ из sr-таблиц (FK на sr_subject).
-- =============================================================================
DO $$
DECLARE
    l_del INTEGER;
BEGIN
    DELETE FROM sr.sr_subject_h
    WHERE sr_type_id = 145
      AND sr_subject_id IN (
          SELECT t.sr_subject_id
          FROM arch_ext.idw_arj_interfax_pdl_load_buffer t
      );

    GET DIAGNOSTICS l_del = ROW_COUNT;
    RAISE NOTICE '[4.6] sr_subject_h: удалено %', l_del;
END $$;


-- =============================================================================
-- 4.7. sr.sr_event — события субъекта
-- Удаляем до sr_subject (FK DEFERRABLE, но безопаснее явно).
-- =============================================================================
DO $$
DECLARE
    l_del INTEGER;
BEGIN
    DELETE FROM sr.sr_event
    WHERE sr_type_id = 145
      AND sr_subject_id IN (
          SELECT t.sr_subject_id
          FROM arch_ext.idw_arj_interfax_pdl_load_buffer t
      );

    GET DIAGNOSTICS l_del = ROW_COUNT;
    RAISE NOTICE '[4.7] sr_event: удалено %', l_del;
END $$;


-- =============================================================================
-- 4.8. sr.sr_subject — субъекты спецреестра
-- Удаляем ПОСЛЕ sr_subject_h и sr_event.
-- =============================================================================
DO $$
DECLARE
    l_del INTEGER;
BEGIN
    DELETE FROM sr.sr_subject
    WHERE sr_type_id = 145
      AND sr_subject_id IN (
          SELECT t.sr_subject_id
          FROM arch_ext.idw_arj_interfax_pdl_load_buffer t
      );

    GET DIAGNOSTICS l_del = ROW_COUNT;
    RAISE NOTICE '[4.8] sr_subject: удалено %', l_del;
END $$;


-- =============================================================================
-- 4.9. sr.sr_subject_pdl — сброс флага обработки
-- =============================================================================
DO $$
DECLARE
    l_upd INTEGER;
BEGIN
    UPDATE sr.sr_subject_pdl
       SET is_eor_ident_process = 0
    WHERE sr_subject_id IN (
        SELECT t.sr_subject_id
        FROM arch_ext.idw_arj_interfax_pdl_load_buffer t
    );

    GET DIAGNOSTICS l_upd = ROW_COUNT;
    RAISE NOTICE '[4.9] sr_subject_pdl: is_eor_ident_process=0 для %', l_upd;
END $$;


-- =============================================================================
-- 4.10. ДИАГНОСТИКА ПОСЛЕ ОЧИСТКИ ОТКАТА
-- =============================================================================
DO $$
DECLARE
    l_err     INTEGER;
    l_wi      INTEGER;
    l_wi_men  INTEGER;
    l_men     INTEGER;
    l_subj    INTEGER;
    l_subj_h  INTEGER;
    l_event   INTEGER;
    l_pdl     INTEGER;
    l_fail    INTEGER := 0;
BEGIN
    RAISE NOTICE '===== ДИАГНОСТИКА ПОСЛЕ ОЧИСТКИ ОТКАТА =====';

    SELECT COUNT(*) INTO l_err FROM process_info.idw_sy_workflow_error
     WHERE workflow_id = 225 AND state_id = 2252
       AND object_id IN (SELECT t.id::text FROM eor.test_eor_subject_id t);

    SELECT COUNT(*) INTO l_wi FROM process_info.idw_sy_workflow_info
     WHERE workflow_id = 225 AND state_id = 2252
       AND object_id IN (SELECT t.id::text FROM eor.test_eor_subject_id t);

    SELECT COUNT(*) INTO l_wi_men FROM process_info.idw_sy_workflow_info
     WHERE workflow_id IN (93, 96) AND state_id IN (931, 961)
       AND object_id IN (
           SELECT m.eor_subject_mention_id::text
           FROM eor.idw_mr_subject_mention m
           WHERE m.source_id = 2070
             AND m.external_h_id IN (
                 SELECT t.id::text FROM arch_ext.idw_arj_interfax_pdl_load_buffer t
             )
       );

    SELECT COUNT(*) INTO l_men FROM eor.idw_mr_subject_mention
     WHERE source_id = 2070
       AND external_h_id IN (
           SELECT t.id::text FROM arch_ext.idw_arj_interfax_pdl_load_buffer t
       );

    SELECT COUNT(*) INTO l_subj FROM sr.sr_subject
     WHERE sr_type_id = 145
       AND sr_subject_id IN (SELECT t.sr_subject_id FROM arch_ext.idw_arj_interfax_pdl_load_buffer t);

    SELECT COUNT(*) INTO l_subj_h FROM sr.sr_subject_h
     WHERE sr_type_id = 145
       AND sr_subject_id IN (SELECT t.sr_subject_id FROM arch_ext.idw_arj_interfax_pdl_load_buffer t);

    SELECT COUNT(*) INTO l_event FROM sr.sr_event
     WHERE sr_type_id = 145
       AND sr_subject_id IN (SELECT t.sr_subject_id FROM arch_ext.idw_arj_interfax_pdl_load_buffer t);

    SELECT COUNT(*) INTO l_pdl FROM sr.sr_subject_pdl
     WHERE sr_subject_id IN (SELECT t.sr_subject_id FROM arch_ext.idw_arj_interfax_pdl_load_buffer t)
       AND is_eor_ident_process = 1;

    -- Ожидаемо: всё 0
    IF l_err    = 0 THEN RAISE NOTICE '[OK]   idw_sy_workflow_error: 0';
                    ELSE RAISE WARNING '[FAIL] idw_sy_workflow_error: %', l_err; l_fail := l_fail + 1; END IF;

    IF l_wi     = 0 THEN RAISE NOTICE '[OK]   idw_sy_workflow_info (225/2252): 0';
                    ELSE RAISE WARNING '[FAIL] idw_sy_workflow_info (225/2252): %', l_wi; l_fail := l_fail + 1; END IF;

    IF l_wi_men = 0 THEN RAISE NOTICE '[OK]   idw_sy_workflow_info (93/96): 0';
                    ELSE RAISE WARNING '[FAIL] idw_sy_workflow_info (93/96): %', l_wi_men; l_fail := l_fail + 1; END IF;

    IF l_men    = 0 THEN RAISE NOTICE '[OK]   idw_mr_subject_mention: 0';
                    ELSE RAISE WARNING '[FAIL] idw_mr_subject_mention: %', l_men; l_fail := l_fail + 1; END IF;

    IF l_subj   = 0 THEN RAISE NOTICE '[OK]   sr_subject: 0';
                    ELSE RAISE WARNING '[FAIL] sr_subject: %', l_subj; l_fail := l_fail + 1; END IF;

    IF l_subj_h = 0 THEN RAISE NOTICE '[OK]   sr_subject_h: 0';
                    ELSE RAISE WARNING '[FAIL] sr_subject_h: %', l_subj_h; l_fail := l_fail + 1; END IF;

    IF l_event  = 0 THEN RAISE NOTICE '[OK]   sr_event: 0';
                    ELSE RAISE WARNING '[FAIL] sr_event: %', l_event; l_fail := l_fail + 1; END IF;

    IF l_pdl    = 0 THEN RAISE NOTICE '[OK]   sr_subject_pdl (is_eor_ident_process=1): 0';
                    ELSE RAISE WARNING '[FAIL] sr_subject_pdl (is_eor_ident_process=1): %', l_pdl; l_fail := l_fail + 1; END IF;

    IF l_fail = 0 THEN
        RAISE NOTICE '===== ОТКАТ ЗАВЕРШЁН УСПЕШНО =====';
    ELSE
        RAISE WARNING '===== ОТКАТ: ПРОВАЛЕНО % ПРОВЕРОК =====', l_fail;
    END IF;
END $$;


-- =============================================================================
-- 5. ОТКАТ ТЕСТОВЫХ ДАННЫХ
-- =============================================================================
-- Набор: sr_subject_id 2830258..2830263
--
-- Удаляет данные, созданные скриптом загрузки:
--   1. eor.tmp_eor_ident_candidate
--   2. eor.idw_mr_master
--   3. eor.idwh2_etalon_flrn
--   4. eor.idwh2_etalon_nr_fl
-- (sr_subject, sr_event, sr_subject_h уже удалены в блоке 4)
-- =============================================================================


-- =============================================================================
-- 5.0. ДИАГНОСТИКА ДО ЗАЧИСТКИ ТЕСТОВЫХ ДАННЫХ
-- =============================================================================
DO $$
DECLARE
    l_tmp     INTEGER;
    l_master  INTEGER;
    l_flrn    INTEGER;
    l_nr_fl   INTEGER;
BEGIN
    RAISE NOTICE '===== ДИАГНОСТИКА ДО ЗАЧИСТКИ ТЕСТОВЫХ ДАННЫХ =====';

    SELECT COUNT(*) INTO l_tmp FROM eor.tmp_eor_ident_candidate
     WHERE etalon_registry_id BETWEEN 2830258 AND 2830263;

    SELECT COUNT(*) INTO l_master FROM eor.idw_mr_master
     WHERE etalon_registry_id BETWEEN 2830258 AND 2830263
        OR master_id          BETWEEN 1000019 AND 1000024
        OR eor_h_id           BETWEEN 9000019 AND 9000024;

    SELECT COUNT(*) INTO l_flrn FROM eor.idwh2_etalon_flrn
     WHERE etalon_registry_id BETWEEN 2830258 AND 2830263;

    SELECT COUNT(*) INTO l_nr_fl FROM eor.idwh2_etalon_nr_fl
     WHERE etalon_registry_id BETWEEN 2830258 AND 2830263;

    RAISE NOTICE '[5.0] tmp_eor_ident_candidate:     %', l_tmp;
    RAISE NOTICE '[5.0] idw_mr_master:               %', l_master;
    RAISE NOTICE '[5.0] idwh2_etalon_flrn:           %', l_flrn;
    RAISE NOTICE '[5.0] idwh2_etalon_nr_fl:          %', l_nr_fl;
END $$;


-- =============================================================================
-- 5.1. Временная таблица кандидатов
-- =============================================================================
DO $$
DECLARE
    l_del INTEGER;
BEGIN
    DELETE FROM eor.tmp_eor_ident_candidate
     WHERE etalon_registry_id BETWEEN 2830258 AND 2830263;

    GET DIAGNOSTICS l_del = ROW_COUNT;
    RAISE NOTICE '[5.1] tmp_eor_ident_candidate: удалено %', l_del;
END $$;


-- =============================================================================
-- 5.2. eor.idw_mr_master — карточки субъектов ЕОР
-- =============================================================================
DO $$
DECLARE
    l_del INTEGER;
BEGIN
    DELETE FROM eor.idw_mr_master
     WHERE etalon_registry_id BETWEEN 2830258 AND 2830263
        OR master_id          BETWEEN 1000019 AND 1000024
        OR eor_h_id           BETWEEN 9000019 AND 9000024
        OR eor_change_id      BETWEEN 5000019 AND 5000024;

    GET DIAGNOSTICS l_del = ROW_COUNT;
    RAISE NOTICE '[5.2] idw_mr_master: удалено %', l_del;
END $$;


-- =============================================================================
-- 5.3. eor.idwh2_etalon_flrn — эталон РФЛ
-- =============================================================================
DO $$
DECLARE
    l_del INTEGER;
BEGIN
    DELETE FROM eor.idwh2_etalon_flrn
     WHERE etalon_registry_id BETWEEN 2830258 AND 2830263;

    GET DIAGNOSTICS l_del = ROW_COUNT;
    RAISE NOTICE '[5.3] idwh2_etalon_flrn: удалено %', l_del;
END $$;


-- =============================================================================
-- 5.4. eor.idwh2_etalon_nr_fl — эталон ИФЛ
-- =============================================================================
DO $$
DECLARE
    l_del INTEGER;
BEGIN
    DELETE FROM eor.idwh2_etalon_nr_fl
     WHERE etalon_registry_id BETWEEN 2830258 AND 2830263;

    GET DIAGNOSTICS l_del = ROW_COUNT;
    RAISE NOTICE '[5.4] idwh2_etalon_nr_fl: удалено %', l_del;
END $$;


-- =============================================================================
-- 5.5. ФИНАЛЬНЫЙ КОНТРОЛЬ ЗАЧИСТКИ
-- =============================================================================
DO $$
DECLARE
    l_tmp     INTEGER;
    l_master  INTEGER;
    l_flrn    INTEGER;
    l_nr_fl   INTEGER;
    l_subj    INTEGER;
    l_event   INTEGER;
    l_h       INTEGER;
    l_men     INTEGER;
    l_total   INTEGER;
BEGIN
    RAISE NOTICE '===== ФИНАЛЬНЫЙ КОНТРОЛЬ ЗАЧИСТКИ =====';

    SELECT COUNT(*) INTO l_tmp FROM eor.tmp_eor_ident_candidate
     WHERE etalon_registry_id BETWEEN 2830258 AND 2830263;

    SELECT COUNT(*) INTO l_master FROM eor.idw_mr_master
     WHERE etalon_registry_id BETWEEN 2830258 AND 2830263
        OR master_id          BETWEEN 1000019 AND 1000024
        OR eor_h_id           BETWEEN 9000019 AND 9000024
        OR eor_change_id      BETWEEN 5000019 AND 5000024;

    SELECT COUNT(*) INTO l_flrn FROM eor.idwh2_etalon_flrn
     WHERE etalon_registry_id BETWEEN 2830258 AND 2830263;

    SELECT COUNT(*) INTO l_nr_fl FROM eor.idwh2_etalon_nr_fl
     WHERE etalon_registry_id BETWEEN 2830258 AND 2830263;

    SELECT COUNT(*) INTO l_subj FROM sr.sr_subject
     WHERE sr_type_id = 145
       AND sr_subject_id IN (SELECT t.sr_subject_id FROM arch_ext.idw_arj_interfax_pdl_load_buffer t);

    SELECT COUNT(*) INTO l_event FROM sr.sr_event
     WHERE sr_type_id = 145
       AND sr_subject_id IN (SELECT t.sr_subject_id FROM arch_ext.idw_arj_interfax_pdl_load_buffer t);

    SELECT COUNT(*) INTO l_h FROM sr.sr_subject_h
     WHERE sr_type_id = 145
       AND sr_subject_id IN (SELECT t.sr_subject_id FROM arch_ext.idw_arj_interfax_pdl_load_buffer t);

    SELECT COUNT(*) INTO l_men FROM eor.idw_mr_subject_mention
     WHERE source_id = 2070
       AND external_h_id IN (
           SELECT t.id::text FROM arch_ext.idw_arj_interfax_pdl_load_buffer t
       );

    l_total := l_tmp + l_master + l_flrn + l_nr_fl
             + l_subj + l_event + l_h + l_men;

    RAISE NOTICE 'tmp_eor_ident_candidate:     %', l_tmp;
    RAISE NOTICE 'idw_mr_master:               %', l_master;
    RAISE NOTICE 'idwh2_etalon_flrn:           %', l_flrn;
    RAISE NOTICE 'idwh2_etalon_nr_fl:          %', l_nr_fl;
    RAISE NOTICE 'sr_subject:                  %', l_subj;
    RAISE NOTICE 'sr_event:                    %', l_event;
    RAISE NOTICE 'sr_subject_h:                %', l_h;
    RAISE NOTICE 'idw_mr_subject_mention:      %', l_men;

    IF l_total = 0 THEN
        RAISE NOTICE '===== ВСЕ ТЕСТОВЫЕ ДАННЫЕ УДАЛЕНЫ =====';
    ELSE
        RAISE WARNING '===== ОСТАЛИСЬ ЗАПИСИ: % =====', l_total;
    END IF;
END $$;


-- =============================================================================
-- 5.6. ОПЦИОНАЛЬНО: удаление опорных данных
-- Раскомментировать, если требуется полная зачистка набора.
-- =============================================================================
DO $$
DECLARE
    l_del_buf INTEGER;
    l_del_pdl INTEGER;
BEGIN
    DELETE FROM arch_ext.idw_arj_interfax_pdl_load_buffer
     WHERE sr_subject_id BETWEEN 2830258 AND 2830263;
    GET DIAGNOSTICS l_del_buf = ROW_COUNT;
    RAISE NOTICE '[5.6] idw_arj_interfax_pdl_load_buffer: удалено %', l_del_buf;

    DELETE FROM sr.sr_subject_pdl
     WHERE sr_subject_id BETWEEN 2830258 AND 2830263
       AND full_name IN (
           'МИФТАХЕТДИНОВ РАШИТ МИДХАТОВИЧ',
           'МИХАЙЛЯНЦ АЛЕКСАНДР АНАТОЛЬЕВИЧ',
           'МИРЗАХАНОВ ФИЗУЛИ МАГОМЕДКЕРИМОВИЧ',
           'МИРЗОЕВ ФЕЙРУЗ МУРАДОВИЧ',
           'МИТАЛАЕВ ЛЕЧИ ЖАНАДИЕВИЧ',
           'МИТАЛАЕВ ХУСЕЙН УМАРОВИЧ'
       );
    GET DIAGNOSTICS l_del_pdl = ROW_COUNT;
    RAISE NOTICE '[5.6] sr_subject_pdl: удалено %', l_del_pdl;
END $$;


-- =============================================================================
-- КОНЕЦ СКРИПТА
-- =============================================================================

-- =============================================================================
-- 6. ФИНАЛЬНАЯ ОЧИСТКА
-- Ожидаемо: везде 0
-- =============================================================================

-- 6.1. Удаление опорных объектов показа
DROP TABLE IF EXISTS eor.test_eor_subject_id;
DROP TABLE IF EXISTS eor.test_eor_subject_process;



-- =============================================================================
-- КОНЕЦ СКРИПТА
-- =============================================================================
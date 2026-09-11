
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
--     Выполнить скрипт изменений к функционалу +++++++++++++++++++++ TODO
-- =============================================================================


-- -----------------------------------------------------------------------------
-- 1.1. Исходные данные для идентификации
-- -----------------------------------------------------------------------------

-- =============================================================================
-- 1.1.1. ОПОРНЫЕ ДАННЫЕ: sr.sr_subject_pdl (6 записей)
-- =============================================================================
INSERT INTO sr.sr_subject_pdl (
    sr_subject_id, update_date, death_date, is_death, birth_place, gender,
    names, translit_names, countries, categories, categories407, jobs,
    sanlists, sanctions, "position", authority, create_date, create_user,
    system_id, is_eor_ident_process, full_name, date_birthday
)
SELECT v.*
FROM (VALUES
    -- 2830258
    (2830258, '2026-09-11 12:13:29.567797'::timestamp, NULL::timestamp, 0,
     'Д. МЕРЯСОВО БАЙМАКСКОГО РАЙОНА РЕСПУБЛИКИ БАШКОРТОСТАН', 'M',
     'МИФТАХЕТДИНОВ РАШИТ МИДХАТОВИЧ; МИФТАХЕТДИНОВ РАШИТ МИДХАТОВИЧ',
     'MIFTAKHETDINOV RASHIT MIDKHATOVICH; MIFTAKHETDINOW RASHIT MIDKHATOWICH; MIFTAKHYETDINOV RASHIT MIDKHATOVICH',
     'РОССИЯ', '', '', 'МИНФИН РОССИИ', 'РОСФИНМОНИТОРИНГ (РОССИЯ)',
     'ПЕРЕЧЕНЬ ОРГАНИЗАЦИЙ И ФИЗИЧЕСКИХ ЛИЦ, В ОТНОШЕНИИ КОТОРЫХ ИМЕЮТСЯ СВЕДЕНИЯ ОБ ИХ ПРИЧАСТНОСТИ К ЭКСТРЕМИСТСКОЙ ДЕЯТЕЛЬНОСТИ ИЛИ ТЕРРОРИЗМУ',
     NULL::text, NULL::text, '2026-09-11 10:07:12.277896'::timestamp, 'arutinov.a', '736875', 0,
     'МИФТАХЕТДИНОВ РАШИТ МИДХАТОВИЧ', '1982-07-09 00:00:00'::timestamp),

    -- 2830259
    (2830259, '2026-09-11 12:13:29.586583'::timestamp, NULL::timestamp, 0,
     'г. Ленинск Кзылординской Области Республики Казахстан', 'M',
     'МИХАЙЛЯНЦ АЛЕКСАНДР АНАТОЛЬЕВИЧ; МИХАЙЛЯНЦ АЛЕКСАНДР АНАТОЛЬЕВИЧ',
     'MIKHAYLYANTS ALEKSANDR ANATOLEVICH; MIKHAYLYANTS ALEKSANDR ANATOLEWICH; MIKHAYLYANTS ALEXANDR ANATOLEVICH',
     'РОССИЯ', '', '', 'ГЕНПРОКУРАТУРА', 'РОСФИНМОНИТОРИНГ (РОССИЯ)',
     'ПЕРЕЧЕНЬ ОРГАНИЗАЦИЙ И ФИЗИЧЕСКИХ ЛИЦ, В ОТНОШЕНИИ КОТОРЫХ ИМЕЮТСЯ СВЕДЕНИЯ ОБ ИХ ПРИЧАСТНОСТИ К ЭКСТРЕМИСТСКОЙ ДЕЯТЕЛЬНОСТИ ИЛИ ТЕРРОРИЗМУ',
     NULL::text, NULL::text, '2026-09-11 10:07:12.277896'::timestamp, 'arutinov.a', '736876', 0,
     'МИХАЙЛЯНЦ АЛЕКСАНДР АНАТОЛЬЕВИЧ', '1971-01-30 00:00:00'::timestamp),

    -- 2830260
    (2830260, '2026-09-11 12:13:29.588865'::timestamp, NULL::timestamp, 0,
     'С. АККА ТАБАСАРАНСКОГО РАЙОНА РЕСПУБЛИКИ ДАГЕСТАН', 'M',
     'МИРЗАХАНОВ ФИЗУЛИ МАГОМЕДКЕРИМОВИЧ; МИРЗАХАНОВ ФИЗУЛИ МАГОМЕДКЕРИМОВИЧ',
     'MIRZAKHANOV FIZULI MAGOMEDCHERIMOVICH; MIRZAKHANOV FIZULI MAGOMEDKERIMOVICH; MIRZAKHANOV FIZULI MAGUOMEDKERIMOVICH; MIRZAKHANOV FIZULI MAHOMEDKERIMOVICH',
     'РОССИЯ', '', '', 'МВД РОССИИ; УВД', 'РОСФИНМОНИТОРИНГ (РОССИЯ)',
     'ПЕРЕЧЕНЬ ОРГАНИЗАЦИЙ И ФИЗИЧЕСКИХ ЛИЦ, В ОТНОШЕНИИ КОТОРЫХ ИМЕЮТСЯ СВЕДЕНИЯ ОБ ИХ ПРИЧАСТНОСТИ К ЭКСТРЕМИСТСКОЙ ДЕЯТЕЛЬНОСТИ ИЛИ ТЕРРОРИЗМУ',
     NULL::text, NULL::text, '2026-09-11 10:07:12.277896'::timestamp, 'arutinov.a', '736867', 0,
     'МИРЗАХАНОВ ФИЗУЛИ МАГОМЕДКЕРИМОВИЧ', '1978-10-26 00:00:00'::timestamp),

    -- 2830261
    (2830261, '2026-09-11 12:13:29.590968'::timestamp, NULL::timestamp, 0,
     'г. Мубарек Республики Узбекистан', 'M',
     'МИРЗОЕВ ФЕЙРУЗ МУРАДОВИЧ; МИРЗОЕВ ФЕЙРУЗ МУРАДОВИЧ',
     'MIRZOEV FEYRUZ MURADOVICH; MIRZOEW FEYRUZ MURADOWICH; MIRZOYEV FYEYRUZ MURADOVICH',
     'РОССИЯ', '', '', 'ФСБ РОССИИ', 'РОСФИНМОНИТОРИНГ (РОССИЯ)',
     'ПЕРЕЧЕНЬ ОРГАНИЗАЦИЙ И ФИЗИЧЕСКИХ ЛИЦ, В ОТНОШЕНИИ КОТОРЫХ ИМЕЮТСЯ СВЕДЕНИЯ ОБ ИХ ПРИЧАСТНОСТИ К ЭКСТРЕМИСТСКОЙ ДЕЯТЕЛЬНОСТИ ИЛИ ТЕРРОРИЗМУ',
     NULL::text, NULL::text, '2026-09-11 10:07:12.277896'::timestamp, 'arutinov.a', '736868', 0,
     'МИРЗОЕВ ФЕЙРУЗ МУРАДОВИЧ', '1989-11-25 00:00:00'::timestamp),

    -- 2830262
    (2830262, '2026-09-11 12:13:29.592997'::timestamp, NULL::timestamp, 0,
     'Г. ЛЕНИНОГОРСК ВОСТОЧНО-КАЗАХСТАНСКОЙ ОБЛАСТИ КССР', 'M',
     'МИТАЛАЕВ ЛЕЧИ ЖАНАДИЕВИЧ; МИТАЛАЕВ ЛЕЧИ ЖАНАДИЕВИЧ',
     'MITALAEV LECHI ZHANADIEVICH; MITALAEW LECHI ZHANADIEWICH; MITALAYEV LYECHI ZHANADIYEVICH',
     'РОССИЯ', '', '', 'МВД РОССИИ', 'РОСФИНМОНИТОРИНГ (РОССИЯ)',
     'ПЕРЕЧЕНЬ ОРГАНИЗАЦИЙ И ФИЗИЧЕСКИХ ЛИЦ, В ОТНОШЕНИИ КОТОРЫХ ИМЕЮТСЯ СВЕДЕНИЯ ОБ ИХ ПРИЧАСТНОСТИ К ЭКСТРЕМИСТСКОЙ ДЕЯТЕЛЬНОСТИ ИЛИ ТЕРРОРИЗМУ',
     NULL::text, NULL::text, '2026-09-11 10:07:12.277896'::timestamp, 'arutinov.a', '736872', 0,
     'МИТАЛАЕВ ЛЕЧИ ЖАНАДИЕВИЧ', '1955-09-25 00:00:00'::timestamp),

    -- 2830263
    (2830263, '2026-09-11 12:13:29.597226'::timestamp, NULL::timestamp, 0,
     'С. ВЕДЕНО ВЕДЕНСКОГО РАЙОНА ЧЕЧЕНСКОЙ РЕСПУБЛИКИ', 'M',
     'МИТАЛАЕВ ХУСЕЙН УМАРОВИЧ; МИТАЛАЕВ ХУСЕЙН УМАРОВИЧ',
     'MITALAEV KHUSEYN UMAROVICH; MITALAEW KHUSEYN UMAROWICH; MITALAYEV KHUSYEYN UMAROVICH',
     'РОССИЯ', '', '', 'ФСБ РОССИИ', 'РОСФИНМОНИТОРИНГ (РОССИЯ)',
     'ПЕРЕЧЕНЬ ОРГАНИЗАЦИЙ И ФИЗИЧЕСКИХ ЛИЦ, В ОТНОШЕНИИ КОТОРЫХ ИМЕЮТСЯ СВЕДЕНИЯ ОБ ИХ ПРИЧАСТНОСТИ К ЭКСТРЕМИСТСКОЙ ДЕЯТЕЛЬНОСТИ ИЛИ ТЕРРОРИЗМУ',
     NULL::text, NULL::text, '2026-09-11 10:07:12.277896'::timestamp, 'arutinov.a', '736873', 0,
     'МИТАЛАЕВ ХУСЕЙН УМАРОВИЧ', '1977-02-13 00:00:00'::timestamp)
) AS v(
    sr_subject_id, update_date, death_date, is_death, birth_place, gender,
    names, translit_names, countries, categories, categories407, jobs,
    sanlists, sanctions, "position", authority, create_date, create_user,
    system_id, is_eor_ident_process, full_name, date_birthday
)
WHERE NOT EXISTS (
    SELECT 1
    FROM sr.sr_subject_pdl t
    WHERE t.sr_subject_id = v.sr_subject_id
       OR t.full_name    = v.full_name
);


-- =============================================================================
-- Логика процедуры pr_pdl_ident_batch:
--   IF UPPER(countries) LIKE '%РОССИЯ%' OR countries IS NULL THEN
--       l_is_rfl := 1;
--   ELSE
--       l_is_rfl := 0;
--   END IF;
--
-- Обоснование выбора 2830259:
--   - birth_place = 'г. Ленинск Кзылординской Области Республики Казахстан';
--   - etalon_sign = '0' (неэталонная ветка);
--   - отсутствует в sr.sr_subject → покрытие INSERT-ветки.
--
-- Идемпотентность: UPDATE выполняется только если countries ещё не 'КАЗАХСТАН'.
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
        RAISE NOTICE '[6a] sr_subject_pdl 2830259: countries → ''КАЗАХСТАН'' (ветка l_is_rfl = 0)';
    ELSE
        RAISE NOTICE '[6a] sr_subject_pdl 2830259: countries уже ''КАЗАХСТАН'' (пропуск)';
    END IF;
END $$;


-- =============================================================================
-- 1.1.2. ОПОРНЫЕ ДАННЫЕ: arch_ext.idw_arj_interfax_pdl_load_buffer (6 записей)
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
    SELECT 1
    FROM arch_ext.idw_arj_interfax_pdl_load_buffer t
    WHERE t.id = v.id
);


-- =============================================================================
-- 1.1.3. eor.idw_mr_master — карточки субъектов ЕОР
-- Часть эталонные (etalon_sign='1'), часть неэталонные (etalon_sign='0')
-- для покрытия обеих веток поиска в процедуре pr_pdl_ident_batch.
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
    -- 2830258: МИФТАХЕТДИНОВ РАШИТ МИДХАТОВИЧ (эталонная)
    (1000019, 2830258, 'МИФТАХЕТДИНОВ РАШИТ МИДХАТОВИЧ', 1, 1, 1, 65, 75, 35, 2,
     '0', '0', '0', '0', NULL::bigint,
     'МИФТАХЕТДИНОВ РАШИТ МИДХАТОВИЧ', 'МИФТАХЕТДИНОВ Р.М.', '051234567912',
     NULL::text, NULL::text, NULL::text, '1982-07-09 00:00:00'::timestamp,
     9000019, '2026-09-11 12:13:29.567797'::timestamp, '1', '0', '0',
     5000019, 1, 1, 82, '2026-09-11 12:13:29.567797'::timestamp),

    -- 2830259: МИХАЙЛЯНЦ АЛЕКСАНДР АНАТОЛЬЕВИЧ (неэталонная)
    (1000020, 2830259, 'МИХАЙЛЯНЦ АЛЕКСАНДР АНАТОЛЬЕВИЧ', 1, 1, 1, 70, 85, 40, 2,
     '0', '0', '0', '0', NULL::bigint,
     'МИХАЙЛЯНЦ АЛЕКСАНДР АНАТОЛЬЕВИЧ', 'МИХАЙЛЯНЦ А.А.', '051234567913',
     NULL::text, NULL::text, NULL::text, '1971-01-30 00:00:00'::timestamp,
     9000020, '2026-09-11 12:13:29.586583'::timestamp, '0', '0', '0',
     5000020, 1, 1, 78, '2026-09-11 12:13:29.586583'::timestamp),

    -- 2830260: МИРЗАХАНОВ ФИЗУЛИ МАГОМЕДКЕРИМОВИЧ (эталонная)
    (1000021, 2830260, 'МИРЗАХАНОВ ФИЗУЛИ МАГОМЕДКЕРИМОВИЧ', 1, 1, 1, 75, 80, 45, 2,
     '0', '0', '0', '0', NULL::bigint,
     'МИРЗАХАНОВ ФИЗУЛИ МАГОМЕДКЕРИМОВИЧ', 'МИРЗАХАНОВ Ф.М.', '051234567914',
     NULL::text, NULL::text, NULL::text, '1978-10-26 00:00:00'::timestamp,
     9000021, '2026-09-11 12:13:29.588865'::timestamp, '1', '0', '0',
     5000021, 1, 1, 85, '2026-09-11 12:13:29.588865'::timestamp),

    -- 2830261: МИРЗОЕВ ФЕЙРУЗ МУРАДОВИЧ (эталонная)
    (1000022, 2830261, 'МИРЗОЕВ ФЕЙРУЗ МУРАДОВИЧ', 1, 1, 1, 60, 70, 30, 2,
     '0', '0', '0', '0', NULL::bigint,
     'МИРЗОЕВ ФЕЙРУЗ МУРАДОВИЧ', 'МИРЗОЕВ Ф.М.', '051234567915',
     NULL::text, NULL::text, NULL::text, '1989-11-25 00:00:00'::timestamp,
     9000022, '2026-09-11 12:13:29.590968'::timestamp, '1', '0', '0',
     5000022, 1, 1, 80, '2026-09-11 12:13:29.590968'::timestamp),

    -- 2830262: МИТАЛАЕВ ЛЕЧИ ЖАНАДИЕВИЧ (неэталонная)
    (1000023, 2830262, 'МИТАЛАЕВ ЛЕЧИ ЖАНАДИЕВИЧ', 1, 1, 1, 55, 65, 25, 2,
     '0', '0', '0', '0', NULL::bigint,
     'МИТАЛАЕВ ЛЕЧИ ЖАНАДИЕВИЧ', 'МИТАЛАЕВ Л.Ж.', '051234567916',
     NULL::text, NULL::text, NULL::text, '1955-09-25 00:00:00'::timestamp,
     9000023, '2026-09-11 12:13:29.592997'::timestamp, '0', '0', '0',
     5000023, 1, 1, 75, '2026-09-11 12:13:29.592997'::timestamp),

    -- 2830263: МИТАЛАЕВ ХУСЕЙН УМАРОВИЧ (неэталонная)
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
    SELECT 1
    FROM eor.idw_mr_master t
    WHERE t.etalon_registry_id = v.etalon_registry_id
);


-- =============================================================================
-- 1.1.4. eor.idwh2_etalon_flrn — эталон РФЛ (ОСНОВНОЙ источник кандидатов)
-- full_name и birth_date должны ТОЧНО совпадать с sr_subject_pdl.
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
    SELECT 1
    FROM eor.idwh2_etalon_flrn t
    WHERE t.etalon_registry_id = v.etalon_registry_id
);


-- =============================================================================
-- 1.1.5. eor.idwh2_etalon_nr_fl — эталон ИФЛ (вспомогательный)
-- Для покрытия ветки l_is_rfl = 0 при изменении countries в опорных данных.
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
    SELECT 1
    FROM eor.idwh2_etalon_nr_fl t
    WHERE t.etalon_registry_id = v.etalon_registry_id
);


-- =============================================================================
-- 1.1.6. sr.sr_subject — субъекты спецреестра
-- Создаём только 3 записи (2830258, 2830260, 2830262) для покрытия
-- ветки UPDATE в процедуре pr_pdl_ident_batch.
-- Остальные 3 (2830259, 2830261, 2830263) процедура вставит сама — это
-- покрытие ветки INSERT.
-- =============================================================================
INSERT INTO sr.sr_subject (
    sr_subject_id, etalon_registry_id, eor_subject_mention_id,
    incl_first_date, incl_date, incl_reason, excl_reason,
    deleted_sign, sr_type_id, actual_sign, checked_sign, sr_event_id
)
SELECT v.*
FROM (VALUES
    (2830258, NULL::bigint, NULL::bigint,
     '2026-09-11 12:13:29.567797'::timestamp, '2026-09-11 12:13:29.567797'::timestamp,
     'X-Complince', NULL::text, '0', 145, '1', '0', NULL::bigint),

    (2830260, NULL::bigint, NULL::bigint,
     '2026-09-11 12:13:29.588865'::timestamp, '2026-09-11 12:13:29.588865'::timestamp,
     'X-Complince', NULL::text, '0', 145, '1', '0', NULL::bigint),

    (2830262, NULL::bigint, NULL::bigint,
     '2026-09-11 12:13:29.592997'::timestamp, '2026-09-11 12:13:29.592997'::timestamp,
     'X-Complince', NULL::text, '0', 145, '1', '0', NULL::bigint)
) AS v(
    sr_subject_id, etalon_registry_id, eor_subject_mention_id,
    incl_first_date, incl_date, incl_reason, excl_reason,
    deleted_sign, sr_type_id, actual_sign, checked_sign, sr_event_id
)
WHERE NOT EXISTS (
    SELECT 1
    FROM sr.sr_subject t
    WHERE t.sr_subject_id = v.sr_subject_id
      AND t.sr_type_id    = v.sr_type_id
);


-- =============================================================================
-- 7. КОНТРОЛЬ ПОЛНОТЫ
-- =============================================================================
DO $$
DECLARE
    l_pdl            INTEGER;
    l_buf            INTEGER;
    l_master         INTEGER;
    l_missing_master INTEGER;
    l_flrn           INTEGER;
    l_missing_flrn   INTEGER;
    l_flrn_name_ok   INTEGER;
    l_flrn_birth_ok  INTEGER;
    l_nr_fl          INTEGER;
    l_subject        INTEGER;
    l_etalon_1       INTEGER;
    l_etalon_0       INTEGER;
BEGIN
    RAISE NOTICE '===== КОНТРОЛЬ ПОЛНОТЫ ТЕСТОВЫХ ДАННЫХ =====';

    -- 7.1. Опорные данные
    SELECT COUNT(*) INTO l_pdl
      FROM sr.sr_subject_pdl
     WHERE sr_subject_id BETWEEN 2830258 AND 2830263;
    RAISE NOTICE 'sr_subject_pdl (опорные):                  %  (ожидалось 6)', l_pdl;

    SELECT COUNT(*) INTO l_buf
      FROM arch_ext.idw_arj_interfax_pdl_load_buffer
     WHERE sr_subject_id BETWEEN 2830258 AND 2830263;
    RAISE NOTICE 'idw_arj_interfax_pdl_load_buffer (опорные): %  (ожидалось 6)', l_buf;

    IF l_pdl <> 6 THEN
        RAISE EXCEPTION 'sr_subject_pdl: ожидалось 6, найдено %', l_pdl;
    END IF;
    IF l_buf <> 6 THEN
        RAISE EXCEPTION 'idw_arj_interfax_pdl_load_buffer: ожидалось 6, найдено %', l_buf;
    END IF;

    -- 7.2. idw_mr_master
    SELECT COUNT(*) INTO l_master
      FROM eor.idw_mr_master
     WHERE etalon_registry_id BETWEEN 2830258 AND 2830263;

    SELECT COUNT(*) INTO l_missing_master
      FROM sr.sr_subject_pdl p
     WHERE p.sr_subject_id BETWEEN 2830258 AND 2830263
       AND NOT EXISTS (
           SELECT 1
           FROM eor.idw_mr_master m
           WHERE m.etalon_registry_id = p.sr_subject_id
       );
    RAISE NOTICE 'idw_mr_master:                   %  (не хватает %)',
        l_master, l_missing_master;
    IF l_missing_master > 0 THEN
        RAISE EXCEPTION 'idw_mr_master: не хватает %', l_missing_master;
    END IF;

    -- 7.3. idwh2_etalon_flrn (основной)
    SELECT COUNT(*) INTO l_flrn
      FROM eor.idwh2_etalon_flrn
     WHERE etalon_registry_id BETWEEN 2830258 AND 2830263;

    SELECT COUNT(*) INTO l_missing_flrn
      FROM sr.sr_subject_pdl p
     WHERE p.sr_subject_id BETWEEN 2830258 AND 2830263
       AND NOT EXISTS (
           SELECT 1
           FROM eor.idwh2_etalon_flrn f
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

    RAISE NOTICE 'idwh2_etalon_flrn:               %  (не хватает %, ФИО OK %/6, ДР OK %/6)',
        l_flrn, l_missing_flrn, l_flrn_name_ok, l_flrn_birth_ok;

    IF l_missing_flrn > 0 THEN
        RAISE EXCEPTION 'idwh2_etalon_flrn: не хватает %', l_missing_flrn;
    END IF;
    IF l_flrn_name_ok <> 6 THEN
        RAISE EXCEPTION 'idwh2_etalon_flrn: несовпадение full_name %/6', l_flrn_name_ok;
    END IF;
    IF l_flrn_birth_ok <> 6 THEN
        RAISE EXCEPTION 'idwh2_etalon_flrn: несовпадение birth_date %/6', l_flrn_birth_ok;
    END IF;

    -- 7.4. idwh2_etalon_nr_fl (вспомогательный)
    SELECT COUNT(*) INTO l_nr_fl
      FROM eor.idwh2_etalon_nr_fl
     WHERE etalon_registry_id BETWEEN 2830258 AND 2830263;
    RAISE NOTICE 'idwh2_etalon_nr_fl:              %', l_nr_fl;
    IF l_nr_fl <> 6 THEN
        RAISE WARNING 'idwh2_etalon_nr_fl: ожидалось 6, найдено % (только для ИФЛ-ветки)', l_nr_fl;
    END IF;

    -- 7.5. sr_subject (только 3 записи — для ветки UPDATE)
    SELECT COUNT(*) INTO l_subject
      FROM sr.sr_subject
     WHERE sr_subject_id BETWEEN 2830258 AND 2830263
       AND sr_type_id = 145;
    RAISE NOTICE 'sr_subject (создано):            %  (ожидалось 3 для ветки UPDATE)', l_subject;
    IF l_subject <> 3 THEN
        RAISE WARNING 'sr_subject: ожидалось 3, найдено %', l_subject;
    END IF;

    -- 7.6. Покрытие обеих веток etalon_sign
    SELECT COUNT(*) INTO l_etalon_1
      FROM eor.idw_mr_master
     WHERE etalon_registry_id BETWEEN 2830258 AND 2830263
       AND etalon_sign = '1';

    SELECT COUNT(*) INTO l_etalon_0
      FROM eor.idw_mr_master
     WHERE etalon_registry_id BETWEEN 2830258 AND 2830263
       AND etalon_sign = '0';

    RAISE NOTICE 'idw_mr_master: etalon_sign=''1'': % / ''0'': %', l_etalon_1, l_etalon_0;
    IF l_etalon_1 = 0 OR l_etalon_0 = 0 THEN
        RAISE WARNING 'idw_mr_master: не покрыты обе ветки etalon_sign';
    END IF;

    -- 7.7. Покрытие обеих веток sr_subject
    RAISE NOTICE 'sr_subject: для UPDATE %, для INSERT (процедурой) %',
        l_subject, 6 - l_subject;

    RAISE NOTICE '===== КОНТРОЛЬ ПОЛНОТЫ ПРОЙДЕН =====';
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

-- Список субъектов в подвале на основе опорной таблицы
SELECT *
FROM sr.sr_subject_pdl dst
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

-- Ошибки обработки
SELECT we.*
FROM process_info.idw_sy_workflow_error we
WHERE we.workflow_id = 225
  AND we.state_id    = 2252
  AND we.object_id IN (
      SELECT t.id::text
      FROM eor.test_eor_subject_id t
  );

-- Упоминания
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

-- sr.sr_event
SELECT *
FROM sr.sr_event
WHERE sr_type_id = 145
  AND sr_subject_id IN (
      SELECT t.sr_subject_id
      FROM arch_ext.idw_arj_interfax_pdl_load_buffer t
  );

-- sr.sr_subject_pdl (контроль is_eor_ident_process = 1)
SELECT is_eor_ident_process, x.*
FROM sr.sr_subject_pdl x
WHERE sr_subject_id IN (
    SELECT t.sr_subject_id
    FROM arch_ext.idw_arj_interfax_pdl_load_buffer t
);


-- =============================================================================
-- 4. ОТКАТ. ОЧИСТКА ДАННЫХ ПРЕДЫДУЩЕГО РАСЧЁТА
-- =============================================================================

-- Удаление ошибок расчёта
DELETE FROM process_info.idw_sy_workflow_error we
WHERE we.workflow_id = 225
  AND we.state_id    = 2252
  AND we.object_id IN (
      SELECT t.id::text
      FROM eor.test_eor_subject_id t
  );

-- Очистка очереди fors
DELETE FROM process_info.idw_sy_workflow_info
WHERE workflow_id = 225
  AND state_id    = 2252
  AND object_id IN (
      SELECT id::text
      FROM eor.test_eor_subject_id
  );

-- Очистка очереди упоминаний (93/931, 96/961)
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

-- Очистка упоминаний eor.idw_mr_rfl_attr_src
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
    SELECT mention_attribute_id
    FROM del_rfl
);

-- Очистка упоминаний eor.idw_mr_ifl_attr_src
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
    SELECT mention_attribute_id
    FROM del_ifl
);

-- sr.sr_subject
DELETE FROM sr.sr_subject
WHERE sr_type_id = 145
  AND sr_subject_id IN (
      SELECT t.sr_subject_id
      FROM arch_ext.idw_arj_interfax_pdl_load_buffer t
  );

-- sr.sr_event
DELETE FROM sr.sr_event
WHERE sr_type_id = 145
  AND sr_subject_id IN (
      SELECT t.sr_subject_id
      FROM arch_ext.idw_arj_interfax_pdl_load_buffer t
  );

-- sr.sr_subject_pdl
UPDATE sr.sr_subject_pdl
   SET is_eor_ident_process = 0
WHERE sr_subject_id IN (
    SELECT t.sr_subject_id
    FROM arch_ext.idw_arj_interfax_pdl_load_buffer t
);


-- =============================================================================
-- 5. ОТКАТ ТЕСТОВЫХ ДАННЫХ
-- =============================================================================
-- ЗАЧИСТКА ТЕСТОВЫХ ДАННЫХ
-- Набор: sr_subject_id 2830258..2830263
--
-- Удаляет данные, созданные скриптом загрузки:
--   1. eor.tmp_eor_ident_candidate
--   2. sr.sr_subject          (3 созданных + 3 возможных от процедуры)
--   3. eor.idw_mr_master       (6)
--   4. eor.idwh2_etalon_flrn   (6)
--   5. eor.idwh2_etalon_nr_fl  (6)
--   6. Контроль
-- Опорные данные (sr.sr_subject_pdl, arch_ext.idw_arj_interfax_pdl_load_buffer)
-- НЕ удаляются — см. опциональный блок 7.
-- =============================================================================

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
    RAISE NOTICE '[1] tmp_eor_ident_candidate: удалено %', l_del;
END $$;


-- =============================================================================
-- 5.2. sr.sr_subject — субъекты спецреестра
-- Удаляем и те 3, что создали вручную, и возможные 3, которые процедура
-- могла вставить при прогоне (2830259, 2830261, 2830263).
-- =============================================================================
DO $$
DECLARE
    l_del INTEGER;
BEGIN
    DELETE FROM sr.sr_subject
    WHERE sr_subject_id BETWEEN 2830258 AND 2830263
      AND sr_type_id = 145;

    GET DIAGNOSTICS l_del = ROW_COUNT;
    RAISE NOTICE '[2] sr_subject: удалено %', l_del;
END $$;


-- =============================================================================
-- 5.3. eor.idw_mr_master — карточки субъектов ЕОР
-- Удаляем по etalon_registry_id + по служебным id (master_id, eor_h_id,
-- eor_change_id) — на случай, если etalon_registry_id был изменён в тестах.
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
    RAISE NOTICE '[3] idw_mr_master: удалено %', l_del;
END $$;


-- =============================================================================
-- 5.4. eor.idwh2_etalon_flrn — эталон РФЛ
-- =============================================================================
DO $$
DECLARE
    l_del INTEGER;
BEGIN
    DELETE FROM eor.idwh2_etalon_flrn
    WHERE etalon_registry_id BETWEEN 2830258 AND 2830263;

    GET DIAGNOSTICS l_del = ROW_COUNT;
    RAISE NOTICE '[4] idwh2_etalon_flrn: удалено %', l_del;
END $$;


-- =============================================================================
-- 5.5. eor.idwh2_etalon_nr_fl — эталон ИФЛ
-- =============================================================================
DO $$
DECLARE
    l_del INTEGER;
BEGIN
    DELETE FROM eor.idwh2_etalon_nr_fl
    WHERE etalon_registry_id BETWEEN 2830258 AND 2830263;

    GET DIAGNOSTICS l_del = ROW_COUNT;
    RAISE NOTICE '[5] idwh2_etalon_nr_fl: удалено %', l_del;
END $$;


-- =============================================================================
-- 5.7. ОПЦИОНАЛЬНО: удаление опорных данных
-- Раскомментировать, если требуется полная зачистка набора
-- =============================================================================
/*
DO $$
DECLARE
    l_del_pdl INTEGER;
    l_del_buf INTEGER;
BEGIN
    -- 5.7.1. Буфер загрузки Интерфакс
    DELETE FROM arch_ext.idw_arj_interfax_pdl_load_buffer
    WHERE sr_subject_id BETWEEN 2830258 AND 2830263;
    GET DIAGNOSTICS l_del_buf = ROW_COUNT;
    RAISE NOTICE '[7] idw_arj_interfax_pdl_load_buffer: удалено %', l_del_buf;

    -- 5.7.2. Опорные данные sr_subject_pdl
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
    RAISE NOTICE '[7] sr_subject_pdl: удалено %', l_del_pdl;
END $$;
*/

-- =============================================================================
-- 5.8. КОНТРОЛЬ УДАЛЕНИЯ ТЕСТОВЫХ ДАННЫХ
-- =============================================================================
-- Проверяет:
--   1. Все тестовые записи удалены (счётчики = 0)
--   2. Опорные данные НЕ удалены (счётчики = 6/6/3, если блок 5.7 не выполнялся)
--   3. Флаги is_eor_ident_process сброшены в 0
-- =============================================================================
DO $$
DECLARE
    -- Счётчики удаления (ожидается 0)
    l_tmp            INTEGER;   -- tmp_eor_ident_candidate
    l_subj           INTEGER;   -- sr.sr_subject
    l_master         INTEGER;   -- eor.idw_mr_master
    l_flrn           INTEGER;   -- eor.idwh2_etalon_flrn
    l_nr_fl          INTEGER;   -- eor.idwh2_etalon_nr_fl

    -- Счётчики опорных данных (ожидается 6/6/3/3)
    l_pdl            INTEGER;   -- sr.sr_subject_pdl
    l_buf            INTEGER;   -- arch_ext.idw_arj_interfax_pdl_load_buffer
    l_pdl_ident_1    INTEGER;   -- sr.sr_subject_pdl с флагом = 1
    l_pdl_ident_0    INTEGER;   -- sr.sr_subject_pdl с флагом = 0

    -- Служебные счётчики
    l_errors         INTEGER;   -- process_info.idw_sy_workflow_error
    l_queue          INTEGER;   -- process_info.idw_sy_workflow_info (225/2252)
    l_mentions       INTEGER;   -- eor.idw_mr_subject_mention

    l_total_bad      INTEGER := 0;
BEGIN
    RAISE NOTICE '===== КОНТРОЛЬ УДАЛЕНИЯ ТЕСТОВЫХ ДАННЫХ =====';

    -- -------------------------------------------------------------------------
    -- 5.8.1. Проверка удаления тестовых данных (ожидается 0)
    -- -------------------------------------------------------------------------
    SELECT COUNT(*) INTO l_tmp
      FROM eor.tmp_eor_ident_candidate
     WHERE etalon_registry_id BETWEEN 2830258 AND 2830263;

    SELECT COUNT(*) INTO l_subj
      FROM sr.sr_subject
     WHERE sr_subject_id BETWEEN 2830258 AND 2830263
       AND sr_type_id = 145;

    SELECT COUNT(*) INTO l_master
      FROM eor.idw_mr_master
     WHERE etalon_registry_id BETWEEN 2830258 AND 2830263
        OR master_id          BETWEEN 1000019 AND 1000024
        OR eor_h_id           BETWEEN 9000019 AND 9000024
        OR eor_change_id      BETWEEN 5000019 AND 5000024;

    SELECT COUNT(*) INTO l_flrn
      FROM eor.idwh2_etalon_flrn
     WHERE etalon_registry_id BETWEEN 2830258 AND 2830263;

    SELECT COUNT(*) INTO l_nr_fl
      FROM eor.idwh2_etalon_nr_fl
     WHERE etalon_registry_id BETWEEN 2830258 AND 2830263;

    RAISE NOTICE '-- Удаление тестовых данных (ожидается 0) --';
    RAISE NOTICE 'tmp_eor_ident_candidate: %', l_tmp;
    RAISE NOTICE 'sr_subject:              %', l_subj;
    RAISE NOTICE 'idw_mr_master:           %', l_master;
    RAISE NOTICE 'idwh2_etalon_flrn:       %', l_flrn;
    RAISE NOTICE 'idwh2_etalon_nr_fl:      %', l_nr_fl;

    IF l_tmp + l_subj + l_master + l_flrn + l_nr_fl > 0 THEN
        RAISE WARNING '❌ Остались тестовые записи: tmp=%, subj=%, master=%, flrn=%, nr_fl=%',
            l_tmp, l_subj, l_master, l_flrn, l_nr_fl;
        l_total_bad := l_total_bad + 1;
    ELSE
        RAISE NOTICE '✅ Все тестовые данные удалены';
    END IF;

    -- -------------------------------------------------------------------------
    -- 5.8.2. Проверка сохранности опорных данных (ожидается 6/6/3)
    -- -------------------------------------------------------------------------
    SELECT COUNT(*) INTO l_pdl
      FROM sr.sr_subject_pdl
     WHERE sr_subject_id BETWEEN 2830258 AND 2830263;

    SELECT COUNT(*) INTO l_buf
      FROM arch_ext.idw_arj_interfax_pdl_load_buffer
     WHERE sr_subject_id BETWEEN 2830258 AND 2830263;

    SELECT COUNT(*) INTO l_pdl_ident_1
      FROM sr.sr_subject_pdl
     WHERE sr_subject_id BETWEEN 2830258 AND 2830263
       AND is_eor_ident_process = 1;

    SELECT COUNT(*) INTO l_pdl_ident_0
      FROM sr.sr_subject_pdl
     WHERE sr_subject_id BETWEEN 2830258 AND 2830263
       AND COALESCE(is_eor_ident_process, 0) = 0;

    RAISE NOTICE '-- Опорные данные (ожидается 6/6) --';
    RAISE NOTICE 'sr_subject_pdl:              %', l_pdl;
    RAISE NOTICE 'idw_arj_interfax_pdl_load_buffer: %', l_buf;

    IF l_pdl <> 6 THEN
        RAISE WARNING '❌ sr_subject_pdl: ожидалось 6, найдено %', l_pdl;
        l_total_bad := l_total_bad + 1;
    END IF;
    IF l_buf <> 6 THEN
        RAISE WARNING '❌ idw_arj_interfax_pdl_load_buffer: ожидалось 6, найдено %', l_buf;
        l_total_bad := l_total_bad + 1;
    END IF;

    -- -------------------------------------------------------------------------
    -- 5.8.3. Проверка сброса флага is_eor_ident_process
    -- -------------------------------------------------------------------------
    RAISE NOTICE '-- Флаг is_eor_ident_process (ожидается 0/6) --';
    RAISE NOTICE 'is_eor_ident_process = 1: %', l_pdl_ident_1;
    RAISE NOTICE 'is_eor_ident_process = 0: %', l_pdl_ident_0;

    IF l_pdl_ident_1 > 0 THEN
        RAISE WARNING '❌ is_eor_ident_process: % записей всё ещё имеют флаг = 1', l_pdl_ident_1;
        l_total_bad := l_total_bad + 1;
    END IF;

    -- -------------------------------------------------------------------------
    -- 5.8.4. Проверка очистки служебных таблиц процесса
    -- -------------------------------------------------------------------------
    SELECT COUNT(*) INTO l_errors
      FROM process_info.idw_sy_workflow_error
     WHERE workflow_id = 225
       AND state_id    = 2252
       AND object_id IN (
           SELECT id::text
           FROM eor.test_eor_subject_id
       );

    SELECT COUNT(*) INTO l_queue
      FROM process_info.idw_sy_workflow_info
     WHERE workflow_id = 225
       AND state_id    = 2252
       AND object_id IN (
           SELECT id::text
           FROM eor.test_eor_subject_id
       );

    SELECT COUNT(*) INTO l_mentions
      FROM eor.idw_mr_subject_mention
     WHERE source_id = 2070
       AND external_h_id IN (
           SELECT t.id::text
           FROM arch_ext.idw_arj_interfax_pdl_load_buffer t
       );

    RAISE NOTICE '-- Служебные таблицы (ожидается 0/0/0) --';
    RAISE NOTICE 'idw_sy_workflow_error (225/2252): %', l_errors;
    RAISE NOTICE 'idw_sy_workflow_info  (225/2252): %', l_queue;
    RAISE NOTICE 'idw_mr_subject_mention (source=2070): %', l_mentions;

    IF l_errors > 0 THEN
        RAISE WARNING '❌ idw_sy_workflow_error: осталось % записей', l_errors;
        l_total_bad := l_total_bad + 1;
    END IF;
    IF l_queue > 0 THEN
        RAISE WARNING '❌ idw_sy_workflow_info: осталось % записей', l_queue;
        l_total_bad := l_total_bad + 1;
    END IF;
    IF l_mentions > 0 THEN
        RAISE WARNING '❌ idw_mr_subject_mention: осталось % записей', l_mentions;
        l_total_bad := l_total_bad + 1;
    END IF;

    -- -------------------------------------------------------------------------
    -- 5.8.5. Итог
    -- -------------------------------------------------------------------------
    RAISE NOTICE '===== ИТОГ КОНТРОЛЯ УДАЛЕНИЯ =====';

    IF l_total_bad > 0 THEN
        RAISE EXCEPTION '❌ Контроль удаления ПРОВАЛЕН: % замечаний', l_total_bad;
    ELSE
        RAISE NOTICE '✅ Контроль удаления ПРОЙДЕН';
    END IF;

    RAISE NOTICE '===== КОНЕЦ КОНТРОЛЯ УДАЛЕНИЯ =====';
END $$;


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
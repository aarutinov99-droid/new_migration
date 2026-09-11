-- =============================================================================
-- ЕДИНЫЙ СКРИПТ ЗАГРУЗКИ ТЕСТОВЫХ ДАННЫХ
-- Набор: sr_subject_id 2830258..2830263
-- Процедура: eor.pr_pdl_ident_batch / IDWH2.pr_eor_pdl_ident
--
-- Состав:
--   1. sr.sr_subject_pdl                         — опорные (6)
--   2. arch_ext.idw_arj_interfax_pdl_load_buffer — опорные (6)
--   3. eor.idw_mr_master                         — производные (6)
--   4. eor.idwh2_etalon_flrn                     — производные (6)
--   5. eor.idwh2_etalon_nr_fl                    — производные (6)
--   6. eor.sr_subject                            — производные (3, для UPDATE)
--   7. Контроль полноты
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
-- Логика процедуры pr_pdl_ident_batch:
--   IF UPPER(countries) LIKE '%РОССИЯ%' OR countries IS NULL THEN l_is_rfl := 1;
--   ELSE l_is_rfl := 0;
--   END IF;
--
-- Обоснование выбора 2830259:
--   - birth_place = 'г. Ленинск Кзылординской Области Республики Казахстан';
--   - etalon_sign = '0' (неэталонная ветка);
--   - отсутствует в eor.sr_subject → покрытие INSERT-ветки.
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
-- 2. ОПОРНЫЕ ДАННЫЕ: arch_ext.idw_arj_interfax_pdl_load_buffer (6 записей)
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
-- 3. eor.idw_mr_master — карточки субъектов ЕОР
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
 '0','0','0','0', NULL::bigint,
 'МИФТАХЕТДИНОВ РАШИТ МИДХАТОВИЧ','МИФТАХЕТДИНОВ Р.М.','051234567912',
 NULL::text,NULL::text,NULL::text, '1982-07-09 00:00:00'::timestamp,
 9000019, '2026-09-11 12:13:29.567797'::timestamp, '1','0','0',
 5000019, 1, 1, 82, '2026-09-11 12:13:29.567797'::timestamp),

-- 2830259: МИХАЙЛЯНЦ АЛЕКСАНДР АНАТОЛЬЕВИЧ (неэталонная)
(1000020, 2830259, 'МИХАЙЛЯНЦ АЛЕКСАНДР АНАТОЛЬЕВИЧ', 1, 1, 1, 70, 85, 40, 2,
 '0','0','0','0', NULL::bigint,
 'МИХАЙЛЯНЦ АЛЕКСАНДР АНАТОЛЬЕВИЧ','МИХАЙЛЯНЦ А.А.','051234567913',
 NULL::text,NULL::text,NULL::text, '1971-01-30 00:00:00'::timestamp,
 9000020, '2026-09-11 12:13:29.586583'::timestamp, '0','0','0',
 5000020, 1, 1, 78, '2026-09-11 12:13:29.586583'::timestamp),

-- 2830260: МИРЗАХАНОВ ФИЗУЛИ МАГОМЕДКЕРИМОВИЧ (эталонная)
(1000021, 2830260, 'МИРЗАХАНОВ ФИЗУЛИ МАГОМЕДКЕРИМОВИЧ', 1, 1, 1, 75, 80, 45, 2,
 '0','0','0','0', NULL::bigint,
 'МИРЗАХАНОВ ФИЗУЛИ МАГОМЕДКЕРИМОВИЧ','МИРЗАХАНОВ Ф.М.','051234567914',
 NULL::text,NULL::text,NULL::text, '1978-10-26 00:00:00'::timestamp,
 9000021, '2026-09-11 12:13:29.588865'::timestamp, '1','0','0',
 5000021, 1, 1, 85, '2026-09-11 12:13:29.588865'::timestamp),

-- 2830261: МИРЗОЕВ ФЕЙРУЗ МУРАДОВИЧ (эталонная)
(1000022, 2830261, 'МИРЗОЕВ ФЕЙРУЗ МУРАДОВИЧ', 1, 1, 1, 60, 70, 30, 2,
 '0','0','0','0', NULL::bigint,
 'МИРЗОЕВ ФЕЙРУЗ МУРАДОВИЧ','МИРЗОЕВ Ф.М.','051234567915',
 NULL::text,NULL::text,NULL::text, '1989-11-25 00:00:00'::timestamp,
 9000022, '2026-09-11 12:13:29.590968'::timestamp, '1','0','0',
 5000022, 1, 1, 80, '2026-09-11 12:13:29.590968'::timestamp),

-- 2830262: МИТАЛАЕВ ЛЕЧИ ЖАНАДИЕВИЧ (неэталонная)
(1000023, 2830262, 'МИТАЛАЕВ ЛЕЧИ ЖАНАДИЕВИЧ', 1, 1, 1, 55, 65, 25, 2,
 '0','0','0','0', NULL::bigint,
 'МИТАЛАЕВ ЛЕЧИ ЖАНАДИЕВИЧ','МИТАЛАЕВ Л.Ж.','051234567916',
 NULL::text,NULL::text,NULL::text, '1955-09-25 00:00:00'::timestamp,
 9000023, '2026-09-11 12:13:29.592997'::timestamp, '0','0','0',
 5000023, 1, 1, 75, '2026-09-11 12:13:29.592997'::timestamp),

-- 2830263: МИТАЛАЕВ ХУСЕЙН УМАРОВИЧ (неэталонная)
(1000024, 2830263, 'МИТАЛАЕВ ХУСЕЙН УМАРОВИЧ', 1, 1, 1, 50, 60, 20, 2,
 '0','0','0','0', NULL::bigint,
 'МИТАЛАЕВ ХУСЕЙН УМАРОВИЧ','МИТАЛАЕВ Х.У.','051234567917',
 NULL::text,NULL::text,NULL::text, '1977-02-13 00:00:00'::timestamp,
 9000024, '2026-09-11 12:13:29.597226'::timestamp, '0','0','0',
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
-- 4. eor.idwh2_etalon_flrn — эталон РФЛ (ОСНОВНОЙ источник кандидатов)
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
    SELECT 1 FROM eor.idwh2_etalon_flrn t
     WHERE t.etalon_registry_id = v.etalon_registry_id
);


-- =============================================================================
-- 5. eor.idwh2_etalon_nr_fl — эталон ИФЛ (вспомогательный)
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
    SELECT 1 FROM eor.idwh2_etalon_nr_fl t
     WHERE t.etalon_registry_id = v.etalon_registry_id
);


-- =============================================================================
-- 6. eor.sr_subject — субъекты спецреестра
-- Создаём только 3 записи (2830258, 2830260, 2830262) для покрытия
-- ветки UPDATE в процедуре pr_pdl_ident_batch.
-- Остальные 3 (2830259, 2830261, 2830263) процедура вставит сама — это
-- покрытие ветки INSERT.
-- =============================================================================
INSERT INTO eor.sr_subject (
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
    SELECT 1 FROM eor.sr_subject t
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
           SELECT 1 FROM eor.idw_mr_master m
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
      FROM eor.sr_subject
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
-- КОНЕЦ СКРИПТА
-- =============================================================================
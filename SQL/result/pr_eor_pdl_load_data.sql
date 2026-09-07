-- =====================================================
-- ЕДИНЫЙ СКРИПТ ТЕСТОВЫХ ДАННЫХ ДЛЯ ВСЕХ ТАБЛИЦ
-- =====================================================
-- С проверкой на существование через NOT EXISTS
-- Контроль по create_user = 'test_user'
-- =====================================================

-- =====================================================
-- 1. pdl.idw_arj_interfax_pdl (основная таблица)
-- =====================================================

INSERT INTO pdl.idw_arj_interfax_pdl (
    id, load_id, updated_at, system_id, full_name, date_birthday, date_death,
    birth_place, dead, gender, names, translit_names, countries,
    categories, category407, jobs, incomes, ownerships, sanlists,
    sanctions, relatives, biography, create_date, err_msg, sr_subject_id,
    date_load, position, authority, country_names, names_err,
    translit_names_err, countries_err, categories_err, category407_err,
    jobs_err, incomes_err, ownerships_err, sanlists_err, sanctions_err,
    relatives_err, biography_err, persdocs, addresses, contact_infos,
    persdocs_err, addresses_err, contact_infos_err, is_load
) VALUES
    -- 1. Мирзаханов Физули Магомедкеримович
    (1, 1567806034, '2023-05-10 11:45:48', '736867', 'Мирзаханов Физули Магомедкеримович', 
     '1978-10-26', NULL, 'С. АККА ТАБАСАРАНСКОГО РАЙОНА РЕСПУБЛИКИ ДАГЕСТАН', 
     FALSE, 'm', 
     '<names>
  <item id="8121960" locale="ru" updated_at="2020-04-01 14:28:12 UTC">
    <last_name>Мирзаханов</last_name>
    <first_name>Физули</first_name>
    <middle_name>Магомедкеримович</middle_name>
    <name>Мирзаханов Физули Магомедкеримович</name>
  </item>
  <item id="8407913" locale="ru" updated_at="2015-07-01 14:19:11 UTC">
    <last_name>Мирзаханов Физули Магомедкеримович</last_name>
    <first_name/>
    <middle_name/>
    <name>Мирзаханов Физули Магомедкеримович</name>
  </item>
</names>',
     '<translit_names>
  <item>Mirzakhanov Fizuli Magomedkerimovich</item>
  <item>Mirzakhanow Fizuli Magomedkerimowich</item>
  <item>Mirzakhanov Fizuli Mahomedkerimovich</item>
  <item>Mirzakhanov Fizuli Maguomedkerimovich</item>
  <item>Mirzakhanov Fizuli Magomyedkyerimovich</item>
  <item>Mirzakhanov Fizuli Magomjedkjerimovich</item>
  <item>Mirzakhanov Fizuli Magomiedkierimovich</item>
  <item>Mirsakhanov Fisuli Magomedkerimovich</item>
  <item>Myrzakhanov Fyzuly Magomedkerymovych</item>
  <item>Mirzakhanov Fizuli Magomedcerimovich</item>
  <item>Mirzakhanov Fizuli Magomedcherimovich</item>
  <item>Mirzakhanov Phizuli Magomedkerimovich</item>
  <item>Mirzahanov Fizuli Magomedkerimovich</item>
</translit_names>',
     '<countries>
  <item id="8121961" updated_at="2020-04-01 14:28:12 UTC" iso="RU" en="Russia">Россия</item>
</countries>',
     '<categories>
  <item>ex_sanction</item>
</categories>',
     '<category407/>',
     '<jobs/>',
     '<incomes/>',
     '<ownerships/>',
     '<sanlists>
  <item id="8121962" updated_at="2015-05-24 12:52:10 UTC" sanlist_id="4">Росфинмониторинг (Россия)</item>
</sanlists>',
     '<sanctions>
  <item id="8121963" date_start="" date_end="2022-02-22">
    <sanction source="https://www.fedsfm.ru/" reason_inclusion="" sanlist="Росфинмониторинг (Россия)" country="Россия" extra_informations="" uid="" last_update_in_source="" reference_number="" program_number="" type_name="Блокирующие" type_tag="1">Перечень организаций и физических лиц, в отношении которых имеются сведения об их причастности к экстремистской деятельности или терроризму</sanction>
  </item>
</sanctions>',
     '<relatives/>',
     '<biography/>',
     '2024-10-30 00:00:00', NULL, 0, NULL, NULL, NULL, 'РОССИЯ', 
     NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
     '<persdocs/>',
     '<addresses/>',
     '<contact_infos/>',
     NULL, NULL, NULL, false),
     
    -- 2. Мирзоев Фейруз Мурадович
    (2, 1567806034, '2023-05-10 11:45:48', '736868', 'Мирзоев Фейруз Мурадович', 
     '1989-11-25', NULL, 'г. Мубарек Республики Узбекистан', 
     FALSE, 'm', 
     '<names>
  <item id="8121967" locale="ru" updated_at="2023-03-17 17:08:27 UTC">
    <last_name>Мирзоев</last_name>
    <first_name>Фейруз</first_name>
    <middle_name>Мурадович</middle_name>
    <name>Мирзоев Фейруз Мурадович</name>
  </item>
  <item id="8403938" locale="ru" updated_at="2015-07-01 14:09:10 UTC">
    <last_name>Мирзоев Фейруз Мурадович</last_name>
    <first_name/>
    <middle_name/>
    <name>Мирзоев Фейруз Мурадович</name>
  </item>
</names>',
     '<translit_names>
  <item>Mirzoev Feyruz Muradovich</item>
  <item>Mirzoew Feyruz Muradowich</item>
  <item>Mirzoyev Fyeyruz Muradovich</item>
  <item>Mirzojev Fjeyruz Muradovich</item>
  <item>Mirzoiev Fieyruz Muradovich</item>
  <item>Mirsoev Feyrus Muradovich</item>
  <item>Myrzoev Feyruz Muradovych</item>
  <item>Mirzoev Feiruz Muradovich</item>
  <item>Mirzoev Pheyruz Muradovich</item>
</translit_names>',
     '<countries>
  <item id="8121968" updated_at="2020-04-01 14:17:09 UTC" iso="RU" en="Russia">Россия</item>
</countries>',
     '<categories>
  <item>sanction</item>
</categories>',
     '<category407/>',
     '<jobs/>',
     '<incomes/>',
     '<ownerships/>',
     '<sanlists>
  <item id="8121969" updated_at="2015-05-24 12:52:11 UTC" sanlist_id="4">Росфинмониторинг (Россия)</item>
</sanlists>',
     '<sanctions>
  <item id="8121970" date_start="" date_end="">
    <sanction source="https://www.fedsfm.ru/" reason_inclusion="" sanlist="Росфинмониторинг (Россия)" country="Россия" extra_informations="" uid="" last_update_in_source="" reference_number="" program_number="" type_name="Блокирующие" type_tag="1">Перечень организаций и физических лиц, в отношении которых имеются сведения об их причастности к экстремистской деятельности или терроризму</sanction>
  </item>
</sanctions>',
     '<relatives/>',
     '<biography/>',
     '2024-10-30 00:00:00', NULL, 0, NULL, NULL, NULL, 'РОССИЯ', 
     NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
     '<persdocs/>',
     '<addresses/>',
     '<contact_infos/>',
     NULL, NULL, NULL, false),
     
    -- 3. Миталаев Лечи Жанадиевич
    (3, 1567806034, '2023-05-10 11:45:48', '736872', 'Миталаев Лечи Жанадиевич', 
     '1955-09-25', NULL, 'Г. ЛЕНИНОГОРСК ВОСТОЧНО-КАЗАХСТАНСКОЙ ОБЛАСТИ КССР', 
     FALSE, 'm', 
     '<names>
  <item id="8121994" locale="ru" updated_at="2015-05-24 12:52:13 UTC">
    <last_name>Миталаев</last_name>
    <first_name>Лечи</first_name>
    <middle_name>Жанадиевич</middle_name>
    <name>Миталаев Лечи Жанадиевич</name>
  </item>
  <item id="8401149" locale="ru" updated_at="2015-07-01 14:02:12 UTC">
    <last_name>Миталаев Лечи Жанадиевич</last_name>
    <first_name/>
    <middle_name/>
    <name>Миталаев Лечи Жанадиевич</name>
  </item>
</names>',
     '<translit_names>
  <item>Mitalaev Lechi Zhanadievich</item>
  <item>Mitalaew Lechi Zhanadiewich</item>
  <item>Mitalayev Lyechi Zhanadiyevich</item>
  <item>Mitalajev Ljechi Zhanadijevich</item>
  <item>Mitalaiev Liechi Zhanadiievich</item>
  <item>Mitalaev Lechi Ganadievich</item>
  <item>Mitalaev Lechi Janadievich</item>
  <item>Mytalaev Lechy Zhanadyevych</item>
  <item>Mithalaev Lechi Zhanadievich</item>
</translit_names>',
     '<countries>
  <item id="8121995" updated_at="2015-05-24 12:52:13 UTC" iso="RU" en="Russia">Россия</item>
</countries>',
     '<categories>
  <item>ex_sanction</item>
</categories>',
     '<category407/>',
     '<jobs/>',
     '<incomes/>',
     '<ownerships/>',
     '<sanlists>
  <item id="8121996" updated_at="2015-05-24 12:52:13 UTC" sanlist_id="4">Росфинмониторинг (Россия)</item>
</sanlists>',
     '<sanctions>
  <item id="8121997" date_start="" date_end="2019-10-24">
    <sanction source="https://www.fedsfm.ru/" reason_inclusion="" sanlist="Росфинмониторинг (Россия)" country="Россия" extra_informations="" uid="" last_update_in_source="" reference_number="" program_number="" type_name="Блокирующие" type_tag="1">Перечень организаций и физических лиц, в отношении которых имеются сведения об их причастности к экстремистской деятельности или терроризму</sanction>
  </item>
</sanctions>',
     '<relatives/>',
     '<biography/>',
     '2024-10-30 00:00:00', NULL, 0, NULL, NULL, NULL, 'РОССИЯ', 
     NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
     '<persdocs/>',
     '<addresses/>',
     '<contact_infos/>',
     NULL, NULL, NULL, false),
     
    -- 4. Миталаев Хусейн Умарович
    (4, 1567806034, '2023-05-10 11:45:48', '736873', 'Миталаев Хусейн Умарович', 
     '1977-02-13', NULL, 'С. ВЕДЕНО ВЕДЕНСКОГО РАЙОНА ЧЕЧЕНСКОЙ РЕСПУБЛИКИ', 
     FALSE, 'm', 
     '<names>
  <item id="8122001" locale="ru" updated_at="2023-03-17 15:31:47 UTC">
    <last_name>Миталаев</last_name>
    <first_name>Хусейн</first_name>
    <middle_name>Умарович</middle_name>
    <name>Миталаев Хусейн Умарович</name>
  </item>
  <item id="8393727" locale="ru" updated_at="2015-07-01 13:43:32 UTC">
    <last_name>Миталаев Хусейн Умарович</last_name>
    <first_name/>
    <middle_name/>
    <name>Миталаев Хусейн Умарович</name>
  </item>
</names>',
     '<translit_names>
  <item>Mitalaev Khuseyn Umarovich</item>
  <item>Mitalaew Khuseyn Umarowich</item>
  <item>Mitalayev Khusyeyn Umarovich</item>
  <item>Mitalajev Khusjeyn Umarovich</item>
  <item>Mitalaiev Khusieyn Umarovich</item>
  <item>Mytalaev Khuseyn Umarovych</item>
  <item>Mitalaev Khusein Umarovich</item>
  <item>Mithalaev Khuseyn Umarovich</item>
  <item>Mitalaev Huseyn Umarovich</item>
</translit_names>',
     '<countries>
  <item id="8122002" updated_at="2020-04-01 14:36:41 UTC" iso="RU" en="Russia">Россия</item>
</countries>',
     '<categories>
  <item>sanction</item>
</categories>',
     '<category407/>',
     '<jobs/>',
     '<incomes/>',
     '<ownerships/>',
     '<sanlists>
  <item id="8122003" updated_at="2015-05-24 12:52:13 UTC" sanlist_id="4">Росфинмониторинг (Россия)</item>
</sanlists>',
     '<sanctions>
  <item id="8122004" date_start="" date_end="">
    <sanction source="https://www.fedsfm.ru/" reason_inclusion="" sanlist="Росфинмониторинг (Россия)" country="Россия" extra_informations="" uid="" last_update_in_source="" reference_number="" program_number="" type_name="Блокирующие" type_tag="1">Перечень организаций и физических лиц, в отношении которых имеются сведения об их причастности к экстремистской деятельности или терроризму</sanction>
  </item>
</sanctions>',
     '<relatives/>',
     '<biography/>',
     '2024-10-30 00:00:00', NULL, 0, NULL, NULL, NULL, 'РОССИЯ', 
     NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
     '<persdocs/>',
     '<addresses/>',
     '<contact_infos/>',
     NULL, NULL, NULL, false),
     
    -- 5. Мифтахетдинов Рашит Мидхатович
    (5, 1567806034, '2023-05-10 11:45:48', '736875', 'Мифтахетдинов Рашит Мидхатович', 
     '1982-07-09', NULL, 'Д. МЕРЯСОВО БАЙМАКСКОГО РАЙОНА РЕСПУБЛИКИ БАШКОРТОСТАН', 
     FALSE, 'm', 
     '<names>
  <item id="8122015" locale="ru" updated_at="2015-05-24 12:52:14 UTC">
    <last_name>Мифтахетдинов</last_name>
    <first_name>Рашит</first_name>
    <middle_name>Мидхатович</middle_name>
    <name>Мифтахетдинов Рашит Мидхатович</name>
  </item>
  <item id="8408331" locale="ru" updated_at="2015-07-01 14:20:20 UTC">
    <last_name>Мифтахетдинов Рашит Мидхатович</last_name>
    <first_name/>
    <middle_name/>
    <name>Мифтахетдинов Рашит Мидхатович</name>
  </item>
</names>',
     '<translit_names>
  <item>Miftakhetdinov Rashit Midkhatovich</item>
  <item>Miftakhetdinow Rashit Midkhatowich</item>
  <item>Miftakhyetdinov Rashit Midkhatovich</item>
  <item>Miftakhjetdinov Rashit Midkhatovich</item>
  <item>Miftakhietdinov Rashit Midkhatovich</item>
  <item>Myftakhetdynov Rashyt Mydkhatovych</item>
  <item>Mifthakhethdinov Rashith Midkhathovich</item>
  <item>Miphtakhetdinov Rashit Midkhatovich</item>
  <item>Miftahetdinov Rashit Midhatovich</item>
</translit_names>',
     '<countries>
  <item id="8122016" updated_at="2015-05-24 12:52:14 UTC" iso="RU" en="Russia">Россия</item>
</countries>',
     '<categories>
  <item>ex_sanction</item>
</categories>',
     '<category407/>',
     '<jobs/>',
     '<incomes/>',
     '<ownerships/>',
     '<sanlists>
  <item id="8122017" updated_at="2015-06-19 12:16:30 UTC" sanlist_id="4">Росфинмониторинг (Россия)</item>
</sanlists>',
     '<sanctions>
  <item id="8122018" date_start="" date_end="2015-06-19">
    <sanction source="https://www.fedsfm.ru/" reason_inclusion="" sanlist="Росфинмониторинг (Россия)" country="Россия" extra_informations="" uid="" last_update_in_source="" reference_number="" program_number="" type_name="Блокирующие" type_tag="1">Перечень организаций и физических лиц, в отношении которых имеются сведения об их причастности к экстремистской деятельности или терроризму</sanction>
  </item>
</sanctions>',
     '<relatives/>',
     '<biography/>',
     '2024-10-30 00:00:00', NULL, 0, NULL, NULL, NULL, 'РОССИЯ', 
     NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
     '<persdocs/>',
     '<addresses/>',
     '<contact_infos/>',
     NULL, NULL, NULL, false),
     
    -- 6. Михайлянц Александр Анатольевич
    (6, 1567806034, '2023-05-10 11:45:48', '736876', 'Михайлянц Александр Анатольевич', 
     '1971-01-30', NULL, 'г. Ленинск Кзылординской Области Республики Казахстан', 
     FALSE, 'm', 
     '<names>
  <item id="8122021" locale="ru" updated_at="2015-05-24 12:52:15 UTC">
    <last_name>Михайлянц</last_name>
    <first_name>Александр</first_name>
    <middle_name>Анатольевич</middle_name>
    <name>Михайлянц Александр Анатольевич</name>
  </item>
  <item id="8397702" locale="ru" updated_at="2015-07-01 13:53:34 UTC">
    <last_name>Михайлянц Александр Анатольевич</last_name>
    <first_name/>
    <middle_name/>
    <name>Михайлянц Александр Анатольевич</name>
  </item>
</names>',
     '<translit_names>
  <item>Mikhaylyants Aleksandr Anatolevich</item>
  <item>Mikhaylyants Alexandr Anatolevich</item>
  <item>Mikhaylyants Aleksandr Anatolewich</item>
  <item>Mikhaylyants Alyeksandr Anatolyevich</item>
  <item>Mikhaylyants Aljeksandr Anatoljevich</item>
  <item>Mikhaylyants Alieksandr Anatolievich</item>
  <item>Mykhaylyants Aleksandr Anatolevych</item>
  <item>Mikhailyants Aleksandr Anatolevich</item>
  <item>Mikhaylyants Alecsandr Anatolevich</item>
  <item>Mikhaylyants Alechsandr Anatolevich</item>
  <item>Mikhaylyants Aleksandr Anatholevich</item>
  <item>Mihaylyants Aleksandr Anatolevich</item>
  <item>Mikhaylyantz Aleksandr Anatolevich</item>
  <item>Mikhayliants Aleksandr Anatolevich</item>
  <item>Mikhaylants Aleksandr Anatolevich</item>
</translit_names>',
     '<countries>
  <item id="8122022" updated_at="2015-05-24 12:52:15 UTC" iso="RU" en="Russia">Россия</item>
</countries>',
     '<categories>
  <item>ex_sanction</item>
</categories>',
     '<category407/>',
     '<jobs/>',
     '<incomes/>',
     '<ownerships/>',
     '<sanlists>
  <item id="8122023" updated_at="2015-06-19 12:16:31 UTC" sanlist_id="4">Росфинмониторинг (Россия)</item>
</sanlists>',
     '<sanctions>
  <item id="8122024" date_start="" date_end="2015-06-19">
    <sanction source="https://www.fedsfm.ru/" reason_inclusion="" sanlist="Росфинмониторинг (Россия)" country="Россия" extra_informations="" uid="" last_update_in_source="" reference_number="" program_number="" type_name="Блокирующие" type_tag="1">Перечень организаций и физических лиц, в отношении которых имеются сведения об их причастности к экстремистской деятельности или терроризму</sanction>
  </item>
</sanctions>',
     '<relatives/>',
     '<biography/>',
     '2024-10-30 00:00:00', NULL, 0, NULL, NULL, NULL, 'РОССИЯ', 
     NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
     '<persdocs/>',
     '<addresses/>',
     '<contact_infos/>',
     NULL, NULL, NULL, false)
ON CONFLICT (id) 
DO NOTHING;

-- =====================================================
-- 2. pdl.idw_arj_pdl_names
-- =====================================================
INSERT INTO pdl.idw_arj_pdl_names (
    load_id, system_id, locale, updated_at, last_name, first_name, middle_name, full_name,
    create_date, create_user, is_load
)
SELECT load_id, system_id, locale, updated_at, last_name, first_name, middle_name, full_name,
       create_date, create_user, is_load
FROM (
    VALUES
        (1567806034, '736867', 'ru', '2020-04-01 14:28:12 UTC'::timestamp, 'Мирзаханов', 'Физули', 'Магомедкеримович', 'Мирзаханов Физули Магомедкеримович', now(), 'test_user', false),
        (1567806034, '736867', 'ru', '2015-07-01 14:19:11 UTC'::timestamp, NULL, NULL, NULL, 'Мирзаханов Физули Магомедкеримович', now(), 'test_user', false),
        (1567806034, '736868', 'ru', '2023-03-17 17:08:27 UTC'::timestamp, 'Мирзоев', 'Фейруз', 'Мурадович', 'Мирзоев Фейруз Мурадович', now(), 'test_user', false),
        (1567806034, '736868', 'ru', '2015-07-01 14:09:10 UTC'::timestamp, NULL, NULL, NULL, 'Мирзоев Фейруз Мурадович', now(), 'test_user', false),
        (1567806034, '736872', 'ru', '2015-05-24 12:52:13 UTC'::timestamp, 'Миталаев', 'Лечи', 'Жанадиевич', 'Миталаев Лечи Жанадиевич', now(), 'test_user', false),
        (1567806034, '736872', 'ru', '2015-07-01 14:02:12 UTC'::timestamp, NULL, NULL, NULL, 'Миталаев Лечи Жанадиевич', now(), 'test_user', false),
        (1567806034, '736873', 'ru', '2023-03-17 15:31:47 UTC'::timestamp, 'Миталаев', 'Хусейн', 'Умарович', 'Миталаев Хусейн Умарович', now(), 'test_user', false),
        (1567806034, '736873', 'ru', '2015-07-01 13:43:32 UTC'::timestamp, NULL, NULL, NULL, 'Миталаев Хусейн Умарович', now(), 'test_user', false),
        (1567806034, '736875', 'ru', '2015-05-24 12:52:14 UTC'::timestamp, 'Мифтахетдинов', 'Рашит', 'Мидхатович', 'Мифтахетдинов Рашит Мидхатович', now(), 'test_user', false),
        (1567806034, '736875', 'ru', '2015-07-01 14:20:20 UTC'::timestamp, NULL, NULL, NULL, 'Мифтахетдинов Рашит Мидхатович', now(), 'test_user', false),
        (1567806034, '736876', 'ru', '2015-05-24 12:52:15 UTC'::timestamp, 'Михайлянц', 'Александр', 'Анатольевич', 'Михайлянц Александр Анатольевич', now(), 'test_user', false),
        (1567806034, '736876', 'ru', '2015-07-01 13:53:34 UTC'::timestamp, NULL, NULL, NULL, 'Михайлянц Александр Анатольевич', now(), 'test_user', false)
) AS src (load_id, system_id, locale, updated_at, last_name, first_name, middle_name, full_name, create_date, create_user, is_load)
WHERE NOT EXISTS (
    SELECT 1 FROM pdl.idw_arj_pdl_names t
    WHERE t.load_id = src.load_id AND t.system_id = src.system_id
      AND COALESCE(t.last_name, '') = COALESCE(src.last_name, '')
      AND COALESCE(t.first_name, '') = COALESCE(src.first_name, '')
      AND COALESCE(t.middle_name, '') = COALESCE(src.middle_name, '')
      AND COALESCE(t.full_name, '') = COALESCE(src.full_name, '')
      AND COALESCE(t.locale, '') = COALESCE(src.locale, '')
      AND t.create_user = 'test_user'
);

-- =====================================================
-- 3. pdl.idw_arj_pdl_translit_names
-- =====================================================
INSERT INTO pdl.idw_arj_pdl_translit_names (load_id, system_id, translit_names, create_date, create_user, is_load)
SELECT load_id, system_id, translit_names, create_date, create_user, is_load
FROM (
    VALUES
        (1567806034, '736867', 'Mirzakhanov Fizuli Magomedkerimovich', now(), 'test_user', false),
        (1567806034, '736867', 'Mirzakhanov Fizuli Magomedcherimovich', now(), 'test_user', false),
        (1567806034, '736867', 'Mirzakhanov Fizuli Mahomedkerimovich', now(), 'test_user', false),
        (1567806034, '736867', 'Mirzakhanov Fizuli Maguomedkerimovich', now(), 'test_user', false),
        (1567806034, '736868', 'Mirzoev Feyruz Muradovich', now(), 'test_user', false),
        (1567806034, '736868', 'Mirzoyev Fyeyruz Muradovich', now(), 'test_user', false),
        (1567806034, '736868', 'Mirzoew Feyruz Muradowich', now(), 'test_user', false),
        (1567806034, '736872', 'Mitalaev Lechi Zhanadievich', now(), 'test_user', false),
        (1567806034, '736872', 'Mitalaew Lechi Zhanadiewich', now(), 'test_user', false),
        (1567806034, '736872', 'Mitalayev Lyechi Zhanadiyevich', now(), 'test_user', false),
        (1567806034, '736873', 'Mitalaev Khuseyn Umarovich', now(), 'test_user', false),
        (1567806034, '736873', 'Mitalaew Khuseyn Umarowich', now(), 'test_user', false),
        (1567806034, '736873', 'Mitalayev Khusyeyn Umarovich', now(), 'test_user', false),
        (1567806034, '736875', 'Miftakhetdinov Rashit Midkhatovich', now(), 'test_user', false),
        (1567806034, '736875', 'Miftakhetdinow Rashit Midkhatowich', now(), 'test_user', false),
        (1567806034, '736875', 'Miftakhyetdinov Rashit Midkhatovich', now(), 'test_user', false),
        (1567806034, '736876', 'Mikhaylyants Aleksandr Anatolevich', now(), 'test_user', false),
        (1567806034, '736876', 'Mikhaylyants Alexandr Anatolevich', now(), 'test_user', false),
        (1567806034, '736876', 'Mikhaylyants Aleksandr Anatolewich', now(), 'test_user', false)
) AS src (load_id, system_id, translit_names, create_date, create_user, is_load)
WHERE NOT EXISTS (
    SELECT 1 FROM pdl.idw_arj_pdl_translit_names t
    WHERE t.load_id = src.load_id AND t.system_id = src.system_id
      AND t.translit_names = src.translit_names
      AND t.create_user = 'test_user'
);

-- =====================================================
-- 4. pdl.idw_arj_pdl_categories
-- =====================================================
INSERT INTO pdl.idw_arj_pdl_categories (load_id, system_id, category_code, create_date, create_user, is_load)
SELECT load_id, system_id, category_code, create_date, create_user, is_load
FROM (
    VALUES
        (1567806034, '736867', 'sanction', now(), 'test_user', false),
        (1567806034, '736868', 'sanction', now(), 'test_user', false),
        (1567806034, '736872', 'sanction', now(), 'test_user', false),
        (1567806034, '736873', 'sanction', now(), 'test_user', false),
        (1567806034, '736875', 'sanction', now(), 'test_user', false),
        (1567806034, '736876', 'sanction', now(), 'test_user', false)
) AS src (load_id, system_id, category_code, create_date, create_user, is_load)
WHERE NOT EXISTS (
    SELECT 1 FROM pdl.idw_arj_pdl_categories t
    WHERE t.load_id = src.load_id AND t.system_id = src.system_id
      AND t.category_code = src.category_code
      AND t.create_user = 'test_user'
);

-- =====================================================
-- 5. pdl.idw_arj_pdl_category407
-- =====================================================
INSERT INTO pdl.idw_arj_pdl_category407 (load_id, system_id, category_code, create_date, create_user, is_load)
SELECT load_id, system_id, category_code, create_date, create_user, is_load
FROM (
    VALUES
        (1567806034, '736867', '1', now(), 'test_user', false),
        (1567806034, '736868', '2', now(), 'test_user', false),
        (1567806034, '736872', '0', now(), 'test_user', false),
        (1567806034, '736873', '4', now(), 'test_user', false),
        (1567806034, '736875', '99', now(), 'test_user', false),
        (1567806034, '736876', '0', now(), 'test_user', false)
) AS src (load_id, system_id, category_code, create_date, create_user, is_load)
WHERE NOT EXISTS (
    SELECT 1 FROM pdl.idw_arj_pdl_category407 t
    WHERE t.load_id = src.load_id AND t.system_id = src.system_id
      AND t.category_code = src.category_code
      AND t.create_user = 'test_user'
);

-- =====================================================
-- 6. pdl.idw_arj_pdl_jobs
-- =====================================================
INSERT INTO pdl.idw_arj_pdl_jobs (
    load_id, system_id, updated_at, date_start, date_end, source, main, unactive,
    name, authority, reg_id, create_date, create_user, is_load
)
SELECT load_id, system_id, updated_at, date_start, date_end, source, main, unactive,
       name, authority, reg_id, create_date, create_user, is_load
FROM (
    VALUES
        (1567806034, '736867', '2023-05-10 11:45:48 UTC'::timestamp, '2010-01-01 00:00:00'::timestamp, NULL, 'https://example.com/source1', 'true', 'false', 'Директор департамента', 'МВД России', 'REG001', now(), 'test_user', false),
        (1567806034, '736867', '2023-05-10 11:45:48 UTC'::timestamp, '2005-01-01 00:00:00'::timestamp, '2009-12-31 00:00:00'::timestamp, 'https://example.com/source2', 'false', 'true', 'Начальник отдела', 'УВД', 'REG002', now(), 'test_user', false),
        (1567806034, '736868', '2023-05-10 11:45:48 UTC'::timestamp, '2015-06-01 00:00:00'::timestamp, NULL, 'https://example.com/source3', 'true', 'false', 'Начальник управления', 'ФСБ России', 'REG003', now(), 'test_user', false),
        (1567806034, '736872', '2023-05-10 11:45:48 UTC'::timestamp, '2010-01-01 00:00:00'::timestamp, NULL, 'https://example.com/source4', 'true', 'false', 'Директор', 'МВД России', 'REG004', now(), 'test_user', false),
        (1567806034, '736873', '2023-05-10 11:45:48 UTC'::timestamp, '2015-01-01 00:00:00'::timestamp, NULL, 'https://example.com/source5', 'true', 'false', 'Начальник отдела', 'ФСБ России', 'REG005', now(), 'test_user', false),
        (1567806034, '736875', '2023-05-10 11:45:48 UTC'::timestamp, '2018-03-01 00:00:00'::timestamp, '2023-01-01 00:00:00'::timestamp, 'https://example.com/source6', 'true', 'false', 'Главный специалист', 'Минфин России', 'REG006', now(), 'test_user', false),
        (1567806034, '736876', '2023-05-10 11:45:48 UTC'::timestamp, '2020-01-15 00:00:00'::timestamp, NULL, 'https://example.com/source7', 'true', 'false', 'Заместитель начальника', 'Генпрокуратура', 'REG007', now(), 'test_user', false)
) AS src (load_id, system_id, updated_at, date_start, date_end, source, main, unactive, name, authority, reg_id, create_date, create_user, is_load)
WHERE NOT EXISTS (
    SELECT 1 FROM pdl.idw_arj_pdl_jobs t
    WHERE t.load_id = src.load_id AND t.system_id = src.system_id
      AND COALESCE(t.updated_at::text, '') = COALESCE(src.updated_at::text, '')
      AND COALESCE(t.date_start::text, '') = COALESCE(src.date_start::text, '')
      AND COALESCE(t.date_end::text, '') = COALESCE(src.date_end::text, '')
      AND COALESCE(t.authority, '') = COALESCE(src.authority, '')
      AND t.create_user = 'test_user'
);

-- =====================================================
-- 7. pdl.idw_arj_pdl_sanlists
-- =====================================================
INSERT INTO pdl.idw_arj_pdl_sanlists (load_id, system_id, updated_at, sanlist_id, sanlist, create_date, create_user, is_load)
SELECT load_id, system_id, updated_at, sanlist_id, sanlist, create_date, create_user, is_load
FROM (
    VALUES
        (1567806034, '736867', '2015-05-24 12:52:10 UTC'::timestamp, 4, 'Росфинмониторинг (Россия)', now(), 'test_user', false),
        (1567806034, '736868', '2015-05-24 12:52:11 UTC'::timestamp, 4, 'Росфинмониторинг (Россия)', now(), 'test_user', false),
        (1567806034, '736872', '2015-05-24 12:52:13 UTC'::timestamp, 4, 'Росфинмониторинг (Россия)', now(), 'test_user', false),
        (1567806034, '736873', '2015-05-24 12:52:13 UTC'::timestamp, 4, 'Росфинмониторинг (Россия)', now(), 'test_user', false),
        (1567806034, '736875', '2015-06-19 12:16:30 UTC'::timestamp, 4, 'Росфинмониторинг (Россия)', now(), 'test_user', false),
        (1567806034, '736876', '2015-06-19 12:16:31 UTC'::timestamp, 4, 'Росфинмониторинг (Россия)', now(), 'test_user', false)
) AS src (load_id, system_id, updated_at, sanlist_id, sanlist, create_date, create_user, is_load)
WHERE NOT EXISTS (
    SELECT 1 FROM pdl.idw_arj_pdl_sanlists t
    WHERE t.load_id = src.load_id AND t.system_id = src.system_id
      AND COALESCE(t.sanlist_id::text, '') = COALESCE(src.sanlist_id::text, '')
      AND COALESCE(t.sanlist, '') = COALESCE(src.sanlist, '')
      AND t.create_user = 'test_user'
);

-- =====================================================
-- 8. pdl.idw_arj_pdl_sanctions
-- =====================================================
INSERT INTO pdl.idw_arj_pdl_sanctions (
    load_id, system_id, sanction, date_start, date_end, source, reason_inclusion,
    sanlist, country, extra_informations, uidd, last_update_in_source,
    create_date, create_user, is_load
)
SELECT load_id, system_id, sanction, date_start, date_end, source, reason_inclusion,
       sanlist, country, extra_informations, uidd, last_update_in_source,
       create_date, create_user, is_load
FROM (
    VALUES
        (1567806034, '736867', 'Перечень организаций и физических лиц, в отношении которых имеются сведения об их причастности к экстремистской деятельности или терроризму', NULL::timestamp, '2022-02-22 00:00:00'::timestamp, 'https://www.fedsfm.ru/', 'Причастность к террористической деятельности', 'Росфинмониторинг (Россия)', 'Россия', '', '', NULL::timestamp, now(), 'test_user', false),
        (1567806034, '736868', 'Перечень организаций и физических лиц, в отношении которых имеются сведения об их причастности к экстремистской деятельности или терроризму', NULL::timestamp, NULL::timestamp, 'https://www.fedsfm.ru/', 'Экстремистская деятельность', 'Росфинмониторинг (Россия)', 'Россия', '', '', NULL::timestamp, now(), 'test_user', false),
        (1567806034, '736872', 'Перечень организаций и физических лиц, в отношении которых имеются сведения об их причастности к экстремистской деятельности или терроризму', NULL::timestamp, '2019-10-24 00:00:00'::timestamp, 'https://www.fedsfm.ru/', '', 'Росфинмониторинг (Россия)', 'Россия', '', '', NULL::timestamp, now(), 'test_user', false),
        (1567806034, '736873', 'Перечень организаций и физических лиц, в отношении которых имеются сведения об их причастности к экстремистской деятельности или терроризму', NULL::timestamp, NULL::timestamp, 'https://www.fedsfm.ru/', '', 'Росфинмониторинг (Россия)', 'Россия', '', '', NULL::timestamp, now(), 'test_user', false),
        (1567806034, '736875', 'Перечень организаций и физических лиц, в отношении которых имеются сведения об их причастности к экстремистской деятельности или терроризму', NULL::timestamp, '2015-06-19 00:00:00'::timestamp, 'https://www.fedsfm.ru/', '', 'Росфинмониторинг (Россия)', 'Россия', '', '', NULL::timestamp, now(), 'test_user', false),
        (1567806034, '736876', 'Перечень организаций и физических лиц, в отношении которых имеются сведения об их причастности к экстремистской деятельности или терроризму', NULL::timestamp, '2015-06-19 00:00:00'::timestamp, 'https://www.fedsfm.ru/', '', 'Росфинмониторинг (Россия)', 'Россия', '', '', NULL::timestamp, now(), 'test_user', false)
) AS src (load_id, system_id, sanction, date_start, date_end, source, reason_inclusion, sanlist, country, extra_informations, uidd, last_update_in_source, create_date, create_user, is_load)
WHERE NOT EXISTS (
    SELECT 1 FROM pdl.idw_arj_pdl_sanctions t
    WHERE t.load_id = src.load_id AND t.system_id = src.system_id
      AND COALESCE(t.sanction, '') = COALESCE(src.sanction, '')
      AND COALESCE(t.sanlist, '') = COALESCE(src.sanlist, '')
      AND COALESCE(t.country, '') = COALESCE(src.country, '')
      AND t.create_user = 'test_user'
);

-- =====================================================
-- 9. pdl.idw_arj_pdl_countries
-- =====================================================
INSERT INTO pdl.idw_arj_pdl_countries (load_id, system_id, updated_at, iso, en, country_name, create_date, create_user, is_load)
SELECT load_id, system_id, updated_at, iso, en, country_name, create_date, create_user, is_load
FROM (
    VALUES
        (1567806034, '736867', '2020-04-01 14:28:12 UTC'::timestamp, 'RU', 'Russia', 'Россия', now(), 'test_user', false),
        (1567806034, '736868', '2020-04-01 14:17:09 UTC'::timestamp, 'RU', 'Russia', 'Россия', now(), 'test_user', false),
        (1567806034, '736872', '2015-05-24 12:52:13 UTC'::timestamp, 'RU', 'Russia', 'Россия', now(), 'test_user', false),
        (1567806034, '736873', '2020-04-01 14:36:41 UTC'::timestamp, 'RU', 'Russia', 'Россия', now(), 'test_user', false),
        (1567806034, '736875', '2015-05-24 12:52:14 UTC'::timestamp, 'RU', 'Russia', 'Россия', now(), 'test_user', false),
        (1567806034, '736876', '2015-05-24 12:52:15 UTC'::timestamp, 'RU', 'Russia', 'Россия', now(), 'test_user', false)
) AS src (load_id, system_id, updated_at, iso, en, country_name, create_date, create_user, is_load)
WHERE NOT EXISTS (
    SELECT 1 FROM pdl.idw_arj_pdl_countries t
    WHERE t.load_id = src.load_id AND t.system_id = src.system_id
      AND COALESCE(t.iso, '') = COALESCE(src.iso, '')
      AND COALESCE(t.en, '') = COALESCE(src.en, '')
      AND COALESCE(t.country_name, '') = COALESCE(src.country_name, '')
      AND t.create_user = 'test_user'
);

-- =====================================================
-- 10. pdl.idw_arj_pdl_persdocs
-- =====================================================
INSERT INTO pdl.idw_arj_pdl_persdocs (
    load_id, system_id, updated_at, date_start, date_end, name, doc_serial, doc_number,
    common, issuing_country, issue, create_date, create_user, is_load
)
SELECT load_id, system_id, updated_at, date_start, date_end, name, doc_serial, doc_number,
       common, issuing_country, issue, create_date, create_user, is_load
FROM (
    VALUES
        (1567806034, '736867', '2020-01-01 00:00:00'::timestamp, '2000-01-01 00:00:00'::timestamp, NULL::timestamp, 'Паспорт гражданина РФ', '1234', '567890', 'Паспорт', 'Россия', 'УВД г. Москвы', now(), 'test_user', false),
        (1567806034, '736868', '2005-06-15 00:00:00'::timestamp, '2005-06-15 00:00:00'::timestamp, NULL::timestamp, 'Паспорт гражданина РФ', '2345', '678901', 'Паспорт', 'Россия', 'УВД г. Санкт-Петербурга', now(), 'test_user', false),
        (1567806034, '736872', '2015-05-24 12:52:13 UTC'::timestamp, '2000-01-01 00:00:00'::timestamp, NULL::timestamp, 'Паспорт гражданина РФ', '3456', '789012', 'Паспорт', 'Россия', 'УВД г. Москвы', now(), 'test_user', false),
        (1567806034, '736873', '2020-04-01 14:36:41 UTC'::timestamp, '2005-01-01 00:00:00'::timestamp, NULL::timestamp, 'Паспорт гражданина РФ', '4567', '890123', 'Паспорт', 'Россия', 'УВД г. Грозного', now(), 'test_user', false),
        (1567806034, '736875', '2015-05-24 12:52:14 UTC'::timestamp, '2010-01-01 00:00:00'::timestamp, NULL::timestamp, 'Паспорт гражданина РФ', '5678', '901234', 'Паспорт', 'Россия', 'УВД г. Уфы', now(), 'test_user', false),
        (1567806034, '736876', '2015-05-24 12:52:15 UTC'::timestamp, '2015-01-01 00:00:00'::timestamp, NULL::timestamp, 'Паспорт гражданина РФ', '6789', '012345', 'Паспорт', 'Россия', 'УВД г. Москвы', now(), 'test_user', false)
) AS src (load_id, system_id, updated_at, date_start, date_end, name, doc_serial, doc_number, common, issuing_country, issue, create_date, create_user, is_load)
WHERE NOT EXISTS (
    SELECT 1 FROM pdl.idw_arj_pdl_persdocs t
    WHERE t.load_id = src.load_id AND t.system_id = src.system_id
      AND COALESCE(t.name, '') = COALESCE(src.name, '')
      AND COALESCE(t.doc_serial, '') = COALESCE(src.doc_serial, '')
      AND COALESCE(t.doc_number, '') = COALESCE(src.doc_number, '')
      AND t.create_user = 'test_user'
);

-- =====================================================
-- 11. pdl.idw_arj_pdl_addresses
-- =====================================================
INSERT INTO pdl.idw_arj_pdl_addresses (load_id, system_id, updated_at, city, address, create_date, create_user, is_load)
SELECT load_id, system_id, updated_at, city, address, create_date, create_user, is_load
FROM (
    VALUES
        (1567806034, '736867', '2020-01-01 00:00:00'::timestamp, 'Москва', 'ул. Тверская, д. 10, кв. 5', now(), 'test_user', false),
        (1567806034, '736867', '2020-01-01 00:00:00'::timestamp, 'Московская область', 'г. Красногорск, ул. Ленина, д. 15, кв. 78', now(), 'test_user', false),
        (1567806034, '736868', '2023-03-17 17:08:27 UTC'::timestamp, 'Санкт-Петербург', 'Невский пр., д. 20, кв. 15', now(), 'test_user', false),
        (1567806034, '736872', '2015-05-24 12:52:13 UTC'::timestamp, 'Москва', 'ул. Арбат, д. 5, кв. 12', now(), 'test_user', false),
        (1567806034, '736873', '2020-04-01 14:36:41 UTC'::timestamp, 'Грозный', 'ул. Победы, д. 10, кв. 3', now(), 'test_user', false),
        (1567806034, '736875', '2015-05-24 12:52:14 UTC'::timestamp, 'Уфа', 'ул. Ленина, д. 25, кв. 7', now(), 'test_user', false),
        (1567806034, '736876', '2015-05-24 12:52:15 UTC'::timestamp, 'Москва', 'ул. Большая Дмитровка, д. 15, кв. 42', now(), 'test_user', false)
) AS src (load_id, system_id, updated_at, city, address, create_date, create_user, is_load)
WHERE NOT EXISTS (
    SELECT 1 FROM pdl.idw_arj_pdl_addresses t
    WHERE t.load_id = src.load_id AND t.system_id = src.system_id
      AND COALESCE(t.city, '') = COALESCE(src.city, '')
      AND COALESCE(t.address, '') = COALESCE(src.address, '')
      AND t.create_user = 'test_user'
);

-- =====================================================
-- 12. pdl.idw_arj_pdl_contact_infos
-- =====================================================
INSERT INTO pdl.idw_arj_pdl_contact_infos (load_id, system_id, updated_at, type, contact_infos, create_date, create_user, is_load)
SELECT load_id, system_id, updated_at, type, contact_infos, create_date, create_user, is_load
FROM (
    VALUES
        (1567806034, '736867', '2020-01-01 00:00:00'::timestamp, 'Телефон', '+7 495 123-45-67', now(), 'test_user', false),
        (1567806034, '736867', '2020-01-01 00:00:00'::timestamp, 'Email', 'mirzakhanov@example.com', now(), 'test_user', false),
        (1567806034, '736868', '2023-03-17 17:08:27 UTC'::timestamp, 'Телефон', '+7 812 987-65-43', now(), 'test_user', false),
        (1567806034, '736872', '2015-05-24 12:52:13 UTC'::timestamp, 'Телефон', '+7 495 555-12-34', now(), 'test_user', false),
        (1567806034, '736873', '2020-04-01 14:36:41 UTC'::timestamp, 'Телефон', '+7 871 222-33-44', now(), 'test_user', false),
        (1567806034, '736875', '2015-05-24 12:52:14 UTC'::timestamp, 'Email', 'miftakhetdinov@example.com', now(), 'test_user', false),
        (1567806034, '736876', '2015-05-24 12:52:15 UTC'::timestamp, 'Телефон', '+7 495 777-88-99', now(), 'test_user', false)
) AS src (load_id, system_id, updated_at, type, contact_infos, create_date, create_user, is_load)
WHERE NOT EXISTS (
    SELECT 1 FROM pdl.idw_arj_pdl_contact_infos t
    WHERE t.load_id = src.load_id AND t.system_id = src.system_id
      AND COALESCE(t.type, '') = COALESCE(src.type, '')
      AND COALESCE(t.contact_infos, '') = COALESCE(src.contact_infos, '')
      AND t.create_user = 'test_user'
);

-- =====================================================
-- ПРОВЕРКА РЕЗУЛЬТАТОВ
-- =====================================================

-- Проверка основной таблицы
SELECT 'idw_arj_interfax_pdl' as table_name, COUNT(*) as total_count
FROM pdl.idw_arj_interfax_pdl
WHERE load_id = 1567806034
UNION ALL

-- Проверка вспомогательных таблиц
SELECT 'idw_arj_pdl_names', COUNT(*) 
FROM pdl.idw_arj_pdl_names WHERE load_id = 1567806034 AND create_user = 'test_user'
UNION ALL
SELECT 'idw_arj_pdl_translit_names', COUNT(*) 
FROM pdl.idw_arj_pdl_translit_names WHERE load_id = 1567806034 AND create_user = 'test_user'
UNION ALL
SELECT 'idw_arj_pdl_categories', COUNT(*) 
FROM pdl.idw_arj_pdl_categories WHERE load_id = 1567806034 AND create_user = 'test_user'
UNION ALL
SELECT 'idw_arj_pdl_category407', COUNT(*) 
FROM pdl.idw_arj_pdl_category407 WHERE load_id = 1567806034 AND create_user = 'test_user'
UNION ALL
SELECT 'idw_arj_pdl_jobs', COUNT(*) 
FROM pdl.idw_arj_pdl_jobs WHERE load_id = 1567806034 AND create_user = 'test_user'
UNION ALL
SELECT 'idw_arj_pdl_sanlists', COUNT(*) 
FROM pdl.idw_arj_pdl_sanlists WHERE load_id = 1567806034 AND create_user = 'test_user'
UNION ALL
SELECT 'idw_arj_pdl_sanctions', COUNT(*) 
FROM pdl.idw_arj_pdl_sanctions WHERE load_id = 1567806034 AND create_user = 'test_user'
UNION ALL
SELECT 'idw_arj_pdl_countries', COUNT(*) 
FROM pdl.idw_arj_pdl_countries WHERE load_id = 1567806034 AND create_user = 'test_user'
UNION ALL
SELECT 'idw_arj_pdl_persdocs', COUNT(*) 
FROM pdl.idw_arj_pdl_persdocs WHERE load_id = 1567806034 AND create_user = 'test_user'
UNION ALL
SELECT 'idw_arj_pdl_addresses', COUNT(*) 
FROM pdl.idw_arj_pdl_addresses WHERE load_id = 1567806034 AND create_user = 'test_user'
UNION ALL
SELECT 'idw_arj_pdl_contact_infos', COUNT(*) 
FROM pdl.idw_arj_pdl_contact_infos WHERE load_id = 1567806034 AND create_user = 'test_user'
ORDER BY table_name;

-- Детальная проверка по system_id
SELECT 
    a.system_id,
    a.full_name,
    (SELECT COUNT(*) FROM pdl.idw_arj_pdl_names n WHERE n.load_id = a.load_id AND n.system_id = a.system_id AND n.create_user = 'test_user') as names_cnt,
    (SELECT COUNT(*) FROM pdl.idw_arj_pdl_categories c WHERE c.load_id = a.load_id AND c.system_id = a.system_id AND c.create_user = 'test_user') as categories_cnt,
    (SELECT COUNT(*) FROM pdl.idw_arj_pdl_jobs j WHERE j.load_id = a.load_id AND j.system_id = a.system_id AND j.create_user = 'test_user') as jobs_cnt,
    (SELECT COUNT(*) FROM pdl.idw_arj_pdl_countries cnt WHERE cnt.load_id = a.load_id AND cnt.system_id = a.system_id AND cnt.create_user = 'test_user') as countries_cnt
FROM pdl.idw_arj_interfax_pdl a
WHERE a.load_id = 1567806034
ORDER BY a.system_id;

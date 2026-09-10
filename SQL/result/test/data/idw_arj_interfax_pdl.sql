-- =====================================================================
-- Вставка данных в таблицу pdl.idw_arj_interfax_pdl (PostgreSQL)
-- Контроль уникальности по первичному ключу (id)
-- При конфликте по id - ничего не делать
-- С инициализацией последовательности id
-- =====================================================================

-- =====================================================================
-- 1. Инициализация последовательности для id (если используется SEQUENCE)
-- =====================================================================
-- Альтернативный вариант прямой установки последовательности
-- SELECT setval('pdl.idw_arj_interfax_pdl_id_seq', COALESCE((SELECT MAX(id) FROM pdl.idw_arj_interfax_pdl), 0));

-- =====================================================================
-- 2. Вставка данных с явным указанием id
-- =====================================================================

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

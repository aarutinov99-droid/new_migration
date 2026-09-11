-- =============================================================================
-- 3. Тестовые данные для eor.idwh2_etalon_nr_fl
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

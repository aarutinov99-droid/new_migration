-- =============================================================================
-- 2. Тестовые данные для eor.idwh2_etalon_flrn
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


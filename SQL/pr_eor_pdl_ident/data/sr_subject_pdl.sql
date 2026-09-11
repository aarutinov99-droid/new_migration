-- =============================================================================
-- 1. ОПОРНЫЕ ДАННЫЕ: sr.sr_subject_pdl
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

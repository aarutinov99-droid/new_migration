-- =============================================================================
-- СКРИПТ ЗАЧИСТКИ ТЕСТОВЫХ ДАННЫХ
-- Набор: sr_subject_id 2830258..2830263
--
-- Удаляет данные, созданные скриптом загрузки:
--   1. eor.tmp_eor_ident_candidate
--   2. eor.sr_subject          (3 созданных + 3 возможных от процедуры)
--   3. eor.idw_mr_master       (6)
--   4. eor.idwh2_etalon_flrn   (6)
--   5. eor.idwh2_etalon_nr_fl  (6)
--   6. Контроль
--
-- Опорные данные (sr.sr_subject_pdl, arch_ext.idw_arj_interfax_pdl_load_buffer)
-- НЕ удаляются — см. опциональный блок 7.
-- =============================================================================


-- =============================================================================
-- 1. Временная таблица кандидатов
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
-- 2. eor.sr_subject — субъекты спецреестра
-- Удаляем и те 3, что создали вручную, и возможные 3, которые процедура
-- могла вставить при прогоне (2830259, 2830261, 2830263).
-- =============================================================================
DO $$
DECLARE
    l_del INTEGER;
BEGIN
    DELETE FROM eor.sr_subject
     WHERE sr_subject_id BETWEEN 2830258 AND 2830263
       AND sr_type_id = 145;
    GET DIAGNOSTICS l_del = ROW_COUNT;
    RAISE NOTICE '[2] sr_subject: удалено %', l_del;
END $$;


-- =============================================================================
-- 3. eor.idw_mr_master — карточки субъектов ЕОР
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
-- 4. eor.idwh2_etalon_flrn — эталон РФЛ
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
-- 5. eor.idwh2_etalon_nr_fl — эталон ИФЛ
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
-- 6. КОНТРОЛЬ: проверка, что всё удалено
-- =============================================================================
DO $$
DECLARE
    l_tmp     INTEGER;
    l_subj    INTEGER;
    l_master  INTEGER;
    l_flrn    INTEGER;
    l_nr_fl   INTEGER;
BEGIN
    SELECT COUNT(*) INTO l_tmp
      FROM eor.tmp_eor_ident_candidate
     WHERE etalon_registry_id BETWEEN 2830258 AND 2830263;

    SELECT COUNT(*) INTO l_subj
      FROM eor.sr_subject
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

    RAISE NOTICE '===== КОНТРОЛЬ ЗАЧИСТКИ =====';
    RAISE NOTICE 'tmp_eor_ident_candidate: %', l_tmp;
    RAISE NOTICE 'sr_subject:              %', l_subj;
    RAISE NOTICE 'idw_mr_master:           %', l_master;
    RAISE NOTICE 'idwh2_etalon_flrn:       %', l_flrn;
    RAISE NOTICE 'idwh2_etalon_nr_fl:      %', l_nr_fl;

    IF l_tmp + l_subj + l_master + l_flrn + l_nr_fl > 0 THEN
        RAISE WARNING 'Остались записи: tmp=%, subj=%, master=%, flrn=%, nr_fl=%',
            l_tmp, l_subj, l_master, l_flrn, l_nr_fl;
    ELSE
        RAISE NOTICE 'Все тестовые данные удалены';
    END IF;
END $$;


-- =============================================================================
-- 7. ОПЦИОНАЛЬНО: удаление опорных данных
-- Раскомментировать, если требуется полная зачистка набора
-- =============================================================================
/*
DO $$
DECLARE
    l_del_pdl INTEGER;
    l_del_buf INTEGER;
BEGIN
    -- 7.1. Буфер загрузки Интерфакс
    DELETE FROM arch_ext.idw_arj_interfax_pdl_load_buffer
     WHERE sr_subject_id BETWEEN 2830258 AND 2830263;
    GET DIAGNOSTICS l_del_buf = ROW_COUNT;
    RAISE NOTICE '[7] idw_arj_interfax_pdl_load_buffer: удалено %', l_del_buf;

    -- 7.2. Опорные данные sr_subject_pdl
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
-- КОНЕЦ СКРИПТА
-- =============================================================================-- Ожидаемо: везде 0
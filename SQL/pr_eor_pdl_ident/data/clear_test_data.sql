-- =============================================================================
-- СКРИПТ ЗАЧИСТКИ ТЕСТОВЫХ ДАННЫХ
-- Набор: sr_subject_id 2830258..2830263
--
-- Удаляет данные, созданные скриптом загрузки:
--   1. sr.sr_subject_h                 (3 записи)
--   2. sr.sr_event                     (3 записи)
--   3. sr.sr_subject                   (3 + возможные 3, созданные процедурой)
--   4. eor.idw_mr_master               (6 записей)
--   5. eor.idwh2_etalon_flrn           (6 записей)
--   6. eor.idwh2_etalon_nr_fl          (6 записей)
--   7. arch_ext.idw_arj_interfax_pdl_load_buffer (опционально)
--   8. sr.sr_subject_pdl               (опционально)
--   9. Контроль зачистки
--
-- Порядок удаления критичен из-за FK:
--   sr_subject_h → sr_subject
--   sr_event     → sr_subject
-- =============================================================================


-- =============================================================================
-- 1. sr.sr_subject_h — история субъекта спецреестра
-- Удаляем ПЕРВОЙ — FK на sr_subject.
-- Удаляем все записи по нашим субъектам, включая возможные от процедуры.
-- =============================================================================
DO $$
DECLARE
    l_del INTEGER;
BEGIN
    DELETE FROM sr.sr_subject_h
     WHERE sr_subject_id BETWEEN 2830258 AND 2830263
       AND sr_type_id = 145;
    GET DIAGNOSTICS l_del = ROW_COUNT;
    RAISE NOTICE '[1] sr_subject_h: удалено %', l_del;
END $$;


-- =============================================================================
-- 2. sr.sr_event — события спецреестра
-- Удаляем ВТОРОЙ — FK на sr_subject (DEFERRABLE, но лучше явно).
-- =============================================================================
DO $$
DECLARE
    l_del INTEGER;
BEGIN
    DELETE FROM sr.sr_event
     WHERE sr_subject_id BETWEEN 2830258 AND 2830263
       AND sr_type_id = 145;
    GET DIAGNOSTICS l_del = ROW_COUNT;
    RAISE NOTICE '[2] sr_event: удалено %', l_del;
END $$;


-- =============================================================================
-- 3. sr.sr_subject — субъекты спецреестра
-- Удаляем ТРЕТЬИМ — FK на sr_type, но уже ни от кого не зависит.
-- =============================================================================
DO $$
DECLARE
    l_del INTEGER;
BEGIN
    DELETE FROM sr.sr_subject
     WHERE sr_subject_id BETWEEN 2830258 AND 2830263
       AND sr_type_id = 145;
    GET DIAGNOSTICS l_del = ROW_COUNT;
    RAISE NOTICE '[3] sr_subject: удалено %', l_del;
END $$;


-- =============================================================================
-- 4. eor.idw_mr_master — карточки субъектов ЕОР
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
    RAISE NOTICE '[4] idw_mr_master: удалено %', l_del;
END $$;


-- =============================================================================
-- 5. eor.idwh2_etalon_flrn — эталон РФЛ
-- =============================================================================
DO $$
DECLARE
    l_del INTEGER;
BEGIN
    DELETE FROM eor.idwh2_etalon_flrn
     WHERE etalon_registry_id BETWEEN 2830258 AND 2830263;
    GET DIAGNOSTICS l_del = ROW_COUNT;
    RAISE NOTICE '[5] idwh2_etalon_flrn: удалено %', l_del;
END $$;


-- =============================================================================
-- 6. eor.idwh2_etalon_nr_fl — эталон ИФЛ
-- =============================================================================
DO $$
DECLARE
    l_del INTEGER;
BEGIN
    DELETE FROM eor.idwh2_etalon_nr_fl
     WHERE etalon_registry_id BETWEEN 2830258 AND 2830263;
    GET DIAGNOSTICS l_del = ROW_COUNT;
    RAISE NOTICE '[6] idwh2_etalon_nr_fl: удалено %', l_del;
END $$;


-- =============================================================================
-- 7. КОНТРОЛЬ ЗАЧИСТКИ (промежуточный)
-- Проверяем, что производные объекты удалены.
-- =============================================================================
DO $$
DECLARE
    l_h        INTEGER;
    l_event    INTEGER;
    l_subject  INTEGER;
    l_master   INTEGER;
    l_flrn     INTEGER;
    l_nr_fl    INTEGER;
BEGIN
    SELECT COUNT(*) INTO l_h
      FROM sr.sr_subject_h
     WHERE sr_subject_id BETWEEN 2830258 AND 2830263
       AND sr_type_id = 145;

    SELECT COUNT(*) INTO l_event
      FROM sr.sr_event
     WHERE sr_subject_id BETWEEN 2830258 AND 2830263
       AND sr_type_id = 145;

    SELECT COUNT(*) INTO l_subject
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

    RAISE NOTICE '===== КОНТРОЛЬ ЗАЧИСТКИ (производные) =====';
    RAISE NOTICE 'sr_subject_h:      %', l_h;
    RAISE NOTICE 'sr_event:          %', l_event;
    RAISE NOTICE 'sr_subject:        %', l_subject;
    RAISE NOTICE 'idw_mr_master:     %', l_master;
    RAISE NOTICE 'idwh2_etalon_flrn: %', l_flrn;
    RAISE NOTICE 'idwh2_etalon_nr_fl:%', l_nr_fl;

    IF l_h + l_event + l_subject + l_master + l_flrn + l_nr_fl > 0 THEN
        RAISE WARNING 'Остались производные записи: h=%, event=%, subj=%, master=%, flrn=%, nr_fl=%',
            l_h, l_event, l_subject, l_master, l_flrn, l_nr_fl;
    ELSE
        RAISE NOTICE 'Производные данные удалены';
    END IF;
END $$;


-- =============================================================================
-- 8. ОПЦИОНАЛЬНО: удаление опорных данных
-- Раскомментировать, если требуется полная зачистка набора.
-- =============================================================================
/*
DO $$
DECLARE
    l_del_buf INTEGER;
    l_del_pdl INTEGER;
BEGIN
    -- 8.1. Буфер загрузки Интерфакс
    DELETE FROM arch_ext.idw_arj_interfax_pdl_load_buffer
     WHERE sr_subject_id BETWEEN 2830258 AND 2830263;
    GET DIAGNOSTICS l_del_buf = ROW_COUNT;
    RAISE NOTICE '[8] idw_arj_interfax_pdl_load_buffer: удалено %', l_del_buf;

    -- 8.2. Опорные данные sr_subject_pdl
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
    RAISE NOTICE '[8] sr_subject_pdl: удалено %', l_del_pdl;
END $$;
*/


-- =============================================================================
-- 9. ФИНАЛЬНЫЙ КОНТРОЛЬ
-- Проверка, что ничего из тестового набора не осталось.
-- =============================================================================
DO $$
DECLARE
    l_h        INTEGER;
    l_event    INTEGER;
    l_subject  INTEGER;
    l_master   INTEGER;
    l_flrn     INTEGER;
    l_nr_fl    INTEGER;
    l_total    INTEGER;
BEGIN
    SELECT COUNT(*) INTO l_h
      FROM sr.sr_subject_h
     WHERE sr_subject_id BETWEEN 2830258 AND 2830263;

    SELECT COUNT(*) INTO l_event
      FROM sr.sr_event
     WHERE sr_subject_id BETWEEN 2830258 AND 2830263;

    SELECT COUNT(*) INTO l_subject
      FROM sr.sr_subject
     WHERE sr_subject_id BETWEEN 2830258 AND 2830263;

    SELECT COUNT(*) INTO l_master
      FROM eor.idw_mr_master
     WHERE etalon_registry_id BETWEEN 2830258 AND 2830263
        OR master_id          BETWEEN 1000019 AND 1000024
        OR eor_h_id           BETWEEN 9000019 AND 9000024;

    SELECT COUNT(*) INTO l_flrn
      FROM eor.idwh2_etalon_flrn
     WHERE etalon_registry_id BETWEEN 2830258 AND 2830263;

    SELECT COUNT(*) INTO l_nr_fl
      FROM eor.idwh2_etalon_nr_fl
     WHERE etalon_registry_id BETWEEN 2830258 AND 2830263;

    l_total := l_h + l_event + l_subject + l_master + l_flrn + l_nr_fl;

    RAISE NOTICE '===== ФИНАЛЬНЫЙ КОНТРОЛЬ =====';
    RAISE NOTICE 'sr_subject_h:       %', l_h;
    RAISE NOTICE 'sr_event:           %', l_event;
    RAISE NOTICE 'sr_subject:         %', l_subject;
    RAISE NOTICE 'idw_mr_master:      %', l_master;
    RAISE NOTICE 'idwh2_etalon_flrn:  %', l_flrn;
    RAISE NOTICE 'idwh2_etalon_nr_fl: %', l_nr_fl;

    IF l_total > 0 THEN
        RAISE WARNING 'Не всё удалено: % записей осталось', l_total;
    ELSE
        RAISE NOTICE 'Все производные тестовые данные удалены';
    END IF;
END $$;


-- =============================================================================
-- КОНЕЦ СКРИПТА
-- =============================================================================
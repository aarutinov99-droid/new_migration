
-- =============================================================================
-- Функция обработки одного субъекта
-- =============================================================================
CREATE OR REPLACE FUNCTION eor.pr_eor_pdl_ident_process_pdl_subject(
    p_sr_subject_id    INTEGER,
    p_full_name        TEXT,
    p_birth_date       DATE,
    p_system_id        TEXT,
    p_countries        TEXT,
    p_rid              TEXT,
    p_update_date      TIMESTAMP,
    p_process_data     RECORD
)
RETURNS RECORD
LANGUAGE plpgsql
AS $$
DECLARE
    l_sr_type_id               INTEGER := 145;
    l_source_id                INTEGER := 2070;
    l_sr_subject_count         INTEGER;
    l_sr_subject_id            INTEGER;
    l_etalon_registry_id       INTEGER;
    l_is_rfl                   INTEGER;
    l_find_id                  INTEGER;
    l_eor_subject_mention_id   INTEGER;
    l_sr_event_id              INTEGER;
    l_rfl_attr                 RECORD;
    l_ifl_attr                 RECORD;
    l_result                   RECORD;
BEGIN
    l_etalon_registry_id := NULL;
    l_sr_subject_id := NULL;

    -- Проверка наличия в спецреестре
    SELECT COUNT(1) INTO l_sr_subject_count
      FROM eor.sr_subject s
     WHERE s.sr_subject_id = p_sr_subject_id
       AND s.sr_type_id = l_sr_type_id;

    IF l_sr_subject_count > 0 THEN
        SELECT s.sr_subject_id INTO l_sr_subject_id
          FROM eor.sr_subject s
         WHERE s.sr_subject_id = p_sr_subject_id
           AND s.sr_type_id = l_sr_type_id;
    END IF;

    -- Определение гражданства
    IF UPPER(p_countries) LIKE '%РОССИЯ%' OR p_countries IS NULL THEN
        l_is_rfl := 1;
    ELSE
        l_is_rfl := 0;
    END IF;

    -- Поиск в ЕОР для РФЛ
    IF l_is_rfl = 1 AND p_full_name IS NOT NULL THEN
        l_find_id := IDWH2.find_rfl_candidate(p_full_name, p_birth_date);

        -- ФИО + ДатаРождения, Эталонная запись
        IF l_etalon_registry_id IS NULL AND p_full_name IS NOT NULL AND p_birth_date IS NOT NULL THEN
            l_etalon_registry_id := IDWH2.find_etalon_rfl(p_full_name, p_birth_date, '1');
        END IF;

        -- ФИО + ДатаРождения, Неэталонная запись
        IF l_etalon_registry_id IS NULL AND p_full_name IS NOT NULL AND p_birth_date IS NOT NULL THEN
            l_etalon_registry_id := IDWH2.find_etalon_rfl(p_full_name, p_birth_date, '0');
        END IF;

        -- ФИО, Эталонная запись
        IF l_etalon_registry_id IS NULL AND p_full_name IS NOT NULL THEN
            l_etalon_registry_id := IDWH2.find_etalon_rfl(p_full_name, NULL, '1');
        END IF;

        -- ФИО, Неэталонная запись
        IF l_etalon_registry_id IS NULL AND p_full_name IS NOT NULL THEN
            l_etalon_registry_id := IDWH2.find_etalon_rfl(p_full_name, NULL, '0');
        END IF;
    END IF;

    -- Поиск в ЕОР для ИФЛ
    IF l_is_rfl = 0 AND p_full_name IS NOT NULL THEN
        l_find_id := IDWH2.find_nr_fl_candidate(p_full_name, p_birth_date);

        -- ФИО + ДатаРождения, Эталонная запись
        IF l_etalon_registry_id IS NULL AND p_full_name IS NOT NULL AND p_birth_date IS NOT NULL THEN
            l_etalon_registry_id := IDWH2.find_etalon_nr_fl(p_full_name, p_birth_date, '1');
        END IF;

        -- ФИО + ДатаРождения, Неэталонная запись
        IF l_etalon_registry_id IS NULL AND p_full_name IS NOT NULL AND p_birth_date IS NOT NULL THEN
            l_etalon_registry_id := IDWH2.find_etalon_nr_fl(p_full_name, p_birth_date, '0');
        END IF;

        -- ФИО, Эталонная запись
        IF l_etalon_registry_id IS NULL AND p_full_name IS NOT NULL THEN
            l_etalon_registry_id := IDWH2.find_etalon_nr_fl(p_full_name, NULL, '1');
        END IF;

        -- ФИО, Неэталонная запись
        IF l_etalon_registry_id IS NULL AND p_full_name IS NOT NULL THEN
            l_etalon_registry_id := IDWH2.find_etalon_nr_fl(p_full_name, NULL, '0');
        END IF;
    END IF;

    -- ИДЕНТИФИЦИРОВАН
    IF l_etalon_registry_id IS NOT NULL AND l_sr_subject_id > 0 THEN
        l_sr_event_id := idwh2.sr_common_pkg.sr_event_add(101, l_sr_type_id, p_sr_subject_id, l_etalon_registry_id, NULL, '0', CURRENT_USER);
        PERFORM idwh2.sr_common_pkg.sr_subject_save_h(p_sr_subject_id);

        UPDATE eor.sr_subject s
           SET etalon_registry_id = l_etalon_registry_id,
               sr_event_id = l_sr_event_id
         WHERE s.sr_subject_id = p_sr_subject_id
           AND s.sr_type_id = l_sr_type_id;

    ELSIF l_etalon_registry_id IS NOT NULL AND l_sr_subject_id IS NULL THEN
        l_sr_event_id := idwh2.sr_common_pkg.sr_event_add(100, l_sr_type_id, p_sr_subject_id, l_etalon_registry_id, NULL, '0', CURRENT_USER);

        INSERT INTO eor.sr_subject (
            sr_subject_id,
            etalon_registry_id,
            incl_first_date,
            incl_date,
            incl_reason,
            excl_reason,
            deleted_sign,
            sr_type_id,
            actual_sign,
            checked_sign,
            sr_event_id
        ) VALUES (
            p_sr_subject_id,
            l_etalon_registry_id,
            CURRENT_TIMESTAMP,
            CURRENT_TIMESTAMP,
            'X-Complince',
            NULL,
            '0',
            l_sr_type_id,
            '1',
            '0',
            l_sr_event_id
        );
    END IF;

    -- СОЗДАНИЕ УПОМИНАНИЯ
    l_eor_subject_mention_id := NULL;

    IF l_etalon_registry_id IS NULL THEN
        BEGIN
            SELECT t.eor_subject_mention_id INTO l_eor_subject_mention_id
              FROM idwh2.idw_mr_subject_mention t
             WHERE source_id = l_source_id
               AND external_h_id = p_rid;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
        END;

        IF l_is_rfl = 1 AND l_eor_subject_mention_id IS NULL THEN
            l_rfl_attr.full_name := p_full_name;
            l_rfl_attr.birth_date := p_birth_date;
            l_eor_subject_mention_id := pkg_eor_api.add_subj_rfl_mention(
                l_source_id,
                0,
                p_system_id,
                p_rid,
                p_update_date,
                l_rfl_attr,
                10,
                0
            );
        END IF;

        IF l_is_rfl = 1 AND l_eor_subject_mention_id IS NULL THEN
            l_ifl_attr.full_name := p_full_name;
            l_ifl_attr.birth_date := p_birth_date;
            l_eor_subject_mention_id := pkg_eor_api.add_subj_ifl_mention(
                l_source_id,
                0,
                p_system_id,
                p_rid,
                p_update_date,
                l_ifl_attr,
                10,
                0
            );
        END IF;

        IF l_sr_subject_id IS NULL AND l_eor_subject_mention_id IS NOT NULL THEN
            l_sr_event_id := idwh2.sr_common_pkg.sr_event_add(100, l_sr_type_id, p_sr_subject_id, l_etalon_registry_id, NULL, '0', CURRENT_USER);

            INSERT INTO eor.sr_subject (
                sr_subject_id,
                eor_subject_mention_id,
                incl_first_date,
                incl_date,
                incl_reason,
                excl_reason,
                deleted_sign,
                sr_type_id,
                actual_sign,
                checked_sign,
                sr_event_id
            ) VALUES (
                p_sr_subject_id,
                l_eor_subject_mention_id,
                CURRENT_TIMESTAMP,
                CURRENT_TIMESTAMP,
                'X-Complince',
                NULL,
                '0',
                l_sr_type_id,
                '1',
                '0',
                l_sr_event_id
            );
        ELSE
            PERFORM idwh2.sr_common_pkg.sr_subject_save_h(p_sr_subject_id);
            l_sr_event_id := idwh2.sr_common_pkg.sr_event_add(101, l_sr_type_id, p_sr_subject_id, l_etalon_registry_id, NULL, '0', CURRENT_USER);

            UPDATE eor.sr_subject s
               SET eor_subject_mention_id = l_eor_subject_mention_id,
                   sr_event_id = l_sr_event_id,
                   deleted_sign = '0',
                   actual_sign = '1',
                   checked_sign = '4',
                   excl_date = NULL,
                   excl_reason = NULL
             WHERE s.sr_subject_id = p_sr_subject_id
               AND s.sr_type_id = l_sr_type_id;
        END IF;
    END IF;

    -- Удаление ошибок
    DELETE FROM idw_sy_workflow_error
     WHERE workflow_id = p_process_data.workflow_id
       AND state_id = p_process_data.state_id
       AND object_id = p_sr_subject_id::TEXT;

    UPDATE eor.sr_subject_pdl p
       SET is_eor_ident_process = 1
     WHERE p.sr_subject_id = p_sr_subject_id;

    -- Возвращаем результат
    SELECT p_sr_subject_id, 1 AS processed, 0 AS error_count INTO l_result;
    RETURN l_result;

EXCEPTION
    WHEN OTHERS THEN
        PERFORM idwh2.pkg_eor_aux.save_error(
            p_sr_subject_id::TEXT,
            p_process_data.workflow_id,
            p_process_data.state_id,
            SQLSTATE,
            SQLERRM,
            'Backtrace not available in PostgreSQL'
        );
        SELECT p_sr_subject_id, 0 AS processed, 1 AS error_count INTO l_result;
        RETURN l_result;
END;
$$;
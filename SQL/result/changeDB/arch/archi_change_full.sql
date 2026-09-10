-- =====================================================================
-- ЕДИНЫЙ СКРИПТ ИЗМЕНЕНИЙ БАЗЫ ДАННЫХ arch_pg
-- Дата: 2026-09-09
-- Содержит изменения из файлов:
--   - idw_arj_interfax_pdl.sql (добавление колонки id и PK)
--   - idw_pdl_ref.sql (создание таблицы справочника)
--   - workflow.sql (вставка workflow, состояний и process_state)
-- =====================================================================

BEGIN;

-- =====================================================================
-- ЧАСТЬ 1: ИЗМЕНЕНИЯ В ТАБЛИЦЕ pdl.idw_arj_interfax_pdl
-- =====================================================================

DO $$
BEGIN
    -- Добавление колонки id
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'pdl' 
          AND table_name = 'idw_arj_interfax_pdl' 
          AND column_name = 'id'
    ) THEN
        ALTER TABLE pdl.idw_arj_interfax_pdl ADD COLUMN id bigserial NOT NULL;
        RAISE NOTICE 'Колонка id добавлена';
    ELSE
        RAISE NOTICE 'Колонка id уже существует';
    END IF;
    
    -- Добавление комментария к колонке
    COMMENT ON COLUMN pdl.idw_arj_interfax_pdl.id IS 'Уникальный идентификатор записи';
    
    -- Добавление первичного ключа
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE table_schema = 'pdl' 
          AND table_name = 'idw_arj_interfax_pdl' 
          AND constraint_name = 'idw_arj_interfax_pdl_pkey'
    ) THEN
        -- Проверяем, нет ли другого первичного ключа
        IF EXISTS (
            SELECT 1 FROM information_schema.table_constraints 
            WHERE table_schema = 'pdl' 
              AND table_name = 'idw_arj_interfax_pdl' 
              AND constraint_type = 'PRIMARY KEY'
        ) THEN
            RAISE WARNING 'В таблице уже есть первичный ключ. Добавление пропущено';
        ELSE
            ALTER TABLE pdl.idw_arj_interfax_pdl 
            ADD CONSTRAINT idw_arj_interfax_pdl_pkey PRIMARY KEY (id);
            RAISE NOTICE 'Первичный ключ добавлен';
        END IF;
    ELSE
        RAISE NOTICE 'Первичный ключ уже существует';
    END IF;
    
    -- Добавление комментария к констрейнту
    COMMENT ON CONSTRAINT idw_arj_interfax_pdl_pkey ON pdl.idw_arj_interfax_pdl 
    IS 'Контроль уникальности';
    
    RAISE NOTICE 'Все операции по idw_arj_interfax_pdl завершены';
END $$;

-- =====================================================================
-- ЧАСТЬ 2: СОЗДАНИЕ ТАБЛИЦЫ СПРАВОЧНИКА pdl.idw_pdl_ref
-- =====================================================================

-- Создание таблицы
CREATE TABLE IF NOT EXISTS pdl.idw_pdl_ref (
    code     VARCHAR(512) NOT NULL,
    name     VARCHAR(512) NOT NULL,
    ref_name VARCHAR(30)  NOT NULL,
    CONSTRAINT pk_idw_pdl_ref PRIMARY KEY (code, ref_name)
);

-- Комментарии к таблице
COMMENT ON TABLE pdl.idw_pdl_ref IS 'Справочник переименований кодовых значений сообщений Интерфакса по ПДЛ';

-- Комментарии к колонкам
COMMENT ON COLUMN pdl.idw_pdl_ref.code IS 'Кодовое значение';
COMMENT ON COLUMN pdl.idw_pdl_ref.name IS 'Переименованное значение';
COMMENT ON COLUMN pdl.idw_pdl_ref.ref_name IS 'Наименование раздела кода';

-- Создание уникального индекса
CREATE UNIQUE INDEX IF NOT EXISTS idx_idw_pdl_ref_u1 ON pdl.idw_pdl_ref (code, ref_name);

-- =====================================================================
-- ЧАСТЬ 3: ПРАВА ДОСТУПА ДЛЯ ТАБЛИЦЫ pdl.idw_pdl_ref
-- =====================================================================

-- Владелец таблицы
ALTER TABLE IF EXISTS pdl.idw_pdl_ref OWNER TO r_arch_db_owner;

-- Отзыв всех прав у ролей
REVOKE ALL ON TABLE pdl.idw_pdl_ref FROM arch_pg_db_reader;
REVOKE ALL ON TABLE pdl.idw_pdl_ref FROM r_arch_db_reader;

-- Права на SELECT для читателей
GRANT SELECT ON TABLE pdl.idw_pdl_ref TO arch_pg_db_reader;
GRANT SELECT ON TABLE pdl.idw_pdl_ref TO r_arch_db_reader;

-- Все права для владельца
GRANT ALL ON TABLE pdl.idw_pdl_ref TO r_arch_db_owner;

-- =====================================================================
-- ЧАСТЬ 4: ВСТАВКА ДАННЫХ В СПРАВОЧНИК pdl.idw_pdl_ref
-- =====================================================================

INSERT INTO pdl.idw_pdl_ref (code, name, ref_name) VALUES
    ('mother', 'мать', 'RELATIONS'),
    ('brother', 'брат', 'RELATIONS'),
    ('uncle', 'дядя', 'RELATIONS'),
    ('niece', 'племянница', 'RELATIONS'),
    ('parent', 'родитель', 'RELATIONS'),
    ('ex_husb', 'бывший муж', 'RELATIONS'),
    ('son', 'сын', 'RELATIONS'),
    ('father', 'отец', 'RELATIONS'),
    ('nephew', 'племянник', 'RELATIONS'),
    ('cousin_male', 'двоюродный брат', 'RELATIONS'),
    ('husb', 'муж', 'RELATIONS'),
    ('wife', 'жена', 'RELATIONS'),
    ('ex_wife', 'бывшая жена', 'RELATIONS'),
    ('granddaughter', 'внучка', 'RELATIONS'),
    ('child', 'ребенок', 'RELATIONS'),
    ('daughter', 'дочь', 'RELATIONS'),
    ('partner', 'партнер', 'RELATIONS'),
    ('sister', 'сестра', 'RELATIONS'),
    ('cousin_female', 'двоюродная сестра', 'RELATIONS'),
    ('civil_service', 'Госслужащий', 'CATEGORIES'),
    ('rpdl', 'Российское публичное должностное лицо', 'CATEGORIES'),
    ('mpdl', 'Международное публичное должностное лицо', 'CATEGORIES'),
    ('idpl', 'Иностранное публичное должностное лицо', 'CATEGORIES'),
    ('sanction', 'Лицо входящее в санкционные списки', 'CATEGORIES'),
    ('closest', 'Близкое окружение должностного лица', 'CATEGORIES'),
    ('closest_gov', 'Близкое окружение госслужащего', 'CATEGORIES'),
    ('closest_rpdl', 'Близкое окружение российского ПДЛ', 'CATEGORIES'),
    ('closest_mpdl', 'Близкое окружение международного ПДЛ', 'CATEGORIES'),
    ('closest_ipdl', 'Близкое окружение иноcтранного ПДЛ', 'CATEGORIES'),
    ('closest_san', 'Близкое окружение лица входящего в санкционные списки', 'CATEGORIES'),
    ('ex_civil_service', 'Бывший госслужащий', 'CATEGORIES'),
    ('ex_rpdl', 'Бывшее российское публичное должностное лицо', 'CATEGORIES'),
    ('ex_mpdl', 'Бывшее международное публичное должностное лицо', 'CATEGORIES'),
    ('ex_idpl', 'Бывшее иностранное публичное должностное лицо', 'CATEGORIES'),
    ('0', 'Присваивается физическим лица, которые не являются лицами, категорий <1>, <2>, <3>, <4>, <5>, <6>, <7>, <8>.', 'CATEGORIES407'),
    ('1', 'Присваивается физическим лицам, которые являются иностранными публичными должностными лицами.', 'CATEGORIES407'),
    ('2', 'Присваивается физическим лицам, являющимся супругом/супругой или близким родственником иностранного публичного должностного лица.', 'CATEGORIES407'),
    ('3', 'Присваивается физическим лицам, которые являются должностными лицами публичной международной организации.', 'CATEGORIES407'),
    ('4', 'Присваивается физическим лицам, которые замещают (занимают) государственную должность Российской Федерации.', 'CATEGORIES407'),
    ('5', 'Присваивается физическим лицам, которые замещают (занимают) должность члена Совета директоров Банка России.', 'CATEGORIES407'),
    ('6', 'Присваивается физическим лицам, замещающим (занимающим) должность федеральной государственной службы, назначение на которую и освобождение от которой осуществляются Президентом Российской Федерации или Правительством Российской Федерации.', 'CATEGORIES407'),
    ('7', 'Присваивается физическим лицам, замещающим (занимающим) должность в Банке России.', 'CATEGORIES407'),
    ('8', 'Присваивается физическим лицам, которые замещают (занимают) должность в государственной корпорации и иной организации, созданной Российской Федерацией на основании федеральных законов.', 'CATEGORIES407'),
    ('99', 'Присваивается физическим лицам c неопределенной категорией.', 'CATEGORIES407')
ON CONFLICT (code, ref_name) 
DO UPDATE SET 
    name = EXCLUDED.name
WHERE 
    pdl.idw_pdl_ref.name IS DISTINCT FROM EXCLUDED.name;

-- =====================================================================
-- ЧАСТЬ 5: ВСТАВКА ДАННЫХ В WORKFLOW
-- =====================================================================

-- Вставка workflow (процесса)
INSERT INTO process_info.idw_sr_workflow (
    id,
    parent_id,
    code,
    "name",
    note,
    date_from,
    date_to,
    is_actual,
    is_deleted,
    create_date,
    create_user,
    update_date,
    update_user,
    delete_date,
    delete_user
) VALUES (
    225,
    NULL,
    'EOR_PDL_LOAD',
    'EOR: (ПДЛ).Пополнение спецреестра ЕОР из архивного слоя ПДЛ (ИНТЕРФАКС X-Complience))',
    'EOR: (ПДЛ).Пополнение спецреестра ЕОР из архивного слоя ПДЛ (ИНТЕРФАКС X-Complience))',
    '1900-01-01 00:00:00',
    '2099-01-01 00:00:00',
    '1',
    '0',
    '2018-03-26 16:06:19',
    'IDWH2',
    NULL,
    NULL,
    NULL,
    NULL
)
ON CONFLICT (id) DO NOTHING;

-- Вставка состояний процесса (order_by = 1)
INSERT INTO process_info.idw_sr_workflow_state (
    id,
    parent_id,
    code,
    "name",
    note,
    date_from,
    date_to,
    is_actual,
    is_deleted,
    create_date,
    create_user,
    update_date,
    update_user,
    delete_date,
    delete_user,
    workflow_id,
    order_by,
    object_descr,
    state_proc
) VALUES (
    2251,
    NULL,
    'EOR_PDL_LOAD',
    'EOR: (ПДЛ).Новая запись архивного слоя ПДЛ. Требуется загрузка в  спецреестр ЕОР.',
    'EOR: (ПДЛ).Новая запись архивного слоя ПДЛ. Требуется загрузка в  спецреестр ЕОР.',
    '1900-01-01 00:00:00',
    '2099-01-01 00:00:00',
    '1',
    '0',
    '2018-03-26 16:06:19',
    'IDWH2',
    NULL,
    NULL,
    NULL,
    NULL,
    225,
    1,
    NULL,
    NULL
)
ON CONFLICT (id) DO NOTHING;

-- Вставка в process_state
INSERT INTO process_info.process_state (
    process_alias,
    last_id,
    last_time,
    can_run,
    before_last_time,
    last_id_2,
    workflow_id,
    state_id,
    batch_size,
    max_attempt,
    max_error,
    newest_first,
    log_level,
    parallel_level,
    load_size,
    change_user,
    change_date
) VALUES
    (
        'PR_EOR_PDL_LOAD_PG',
        0,
        '2026-08-13 14:13:54.466195',
        '1',
        '2026-08-13 14:13:54.466197',
        85,
        225,
        2251,
        1000,
        5,
        1500000,
        '1',
        0,
        1,
        1000,
        'timonov.d',
        '2026-08-13 14:13:54.466198'
    )
ON CONFLICT (process_alias) DO NOTHING;

-- =====================================================================
-- ЧАСТЬ 6: ПРОВЕРКА ВСТАВЛЕННЫХ ЗАПИСЕЙ (опционально)
-- =====================================================================

-- Проверка workflow
SELECT 'WORKFLOW:' as check_type, id, code, "name" 
FROM process_info.idw_sr_workflow WHERE id = 225;

-- Проверка состояний
SELECT 'WORKFLOW_STATES:' as check_type, id, code, "name", order_by 
FROM process_info.idw_sr_workflow_state 
WHERE workflow_id = 225 ORDER BY order_by;

-- Проверка process_state
SELECT 'PROCESS_STATES:' as check_type, process_alias, workflow_id, state_id, can_run
FROM process_info.process_state 
WHERE workflow_id = 225 ORDER BY process_alias;

-- Проверка связки
SELECT 
    w.id AS workflow_id,
    w.code AS workflow_code,
    s.id AS state_id,
    s.code AS state_code,
    s.order_by,
    p.process_alias,
    p.can_run
FROM process_info.idw_sr_workflow w
LEFT JOIN process_info.idw_sr_workflow_state s ON w.id = s.workflow_id
LEFT JOIN process_info.process_state p ON p.workflow_id = w.id AND p.state_id = s.id
WHERE w.id = 225
ORDER BY s.order_by;

COMMIT;

-- =====================================================================
-- ИТОГОВОЕ СООБЩЕНИЕ
-- =====================================================================
DO $$
BEGIN
    RAISE NOTICE '============================================================';
    RAISE NOTICE 'ЕДИНЫЙ СКРИПТ ИЗМЕНЕНИЙ УСПЕШНО ВЫПОЛНЕН';
    RAISE NOTICE '============================================================';
    RAISE NOTICE 'Выполнены операции:';
    RAISE NOTICE '  1. Добавлена колонка id в pdl.idw_arj_interfax_pdl';
    RAISE NOTICE '  2. Добавлен первичный ключ для pdl.idw_arj_interfax_pdl';
    RAISE NOTICE '  3. Создана таблица pdl.idw_pdl_ref';
    RAISE NOTICE '  4. Настроены права доступа для pdl.idw_pdl_ref';
    RAISE NOTICE '  5. Загружены справочные данные в pdl.idw_pdl_ref';
    RAISE NOTICE '  6. Добавлен workflow EOR_PDL_LOAD';
    RAISE NOTICE '  7. Добавлено состояние workflow (state_id=2251)';
    RAISE NOTICE '  8. Добавлена запись в process_state';
    RAISE NOTICE '============================================================';
END $$;
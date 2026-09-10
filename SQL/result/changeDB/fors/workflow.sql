-- =====================================================
-- 1. ВСТАВКА ДАННЫХ
-- =====================================================

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

-- Вставка состояний процесса (order_by = 2)
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
    2252,
    NULL,
    'EOR_PDL_IDENT',
    'EOR: (ПДЛ).Запись ПДЛ в спецреестре ЕОР не имеет связи с субъектом ЕОР. Требуется установить связь.',
    'EOR: (ПДЛ).Запись ПДЛ в спецреестре ЕОР не имеет связи с субъектом ЕОР. Требуется установить связь.',
    '1900-01-01 00:00:00',
    '2099-01-01 00:00:00',
    '1',
    '0',
    '2018-03-26 16:06:21',
    'IDWH2',
    NULL,
    NULL,
    NULL,
    NULL,
    225,
    2,
    NULL,
    NULL
)
ON CONFLICT (id) DO NOTHING;
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
        'PR_EOR_PDL_IDENT',
        0,
        NULL,
        '1',
        NULL,
        0,
        225,
        2252,
        1000,
        3,
        5,
        '1',
        0,
        1,
        1000,
        'IDWH2',
        '2026-09-08 13:07:22.244567'
    ),
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

-- =====================================================
-- 2. ПРОВЕРКА ВСТАВЛЕННЫХ ЗАПИСЕЙ
-- =====================================================

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
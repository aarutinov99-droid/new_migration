-- =====================================================================
-- Таблица справочника переименований кодовых значений сообщений Интерфакса по ПДЛ
-- Конвертировано из Oracle в PostgreSQL
-- Схема: pdl
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

-- Создание уникального индекса (первичный ключ уже создан, но если нужен отдельный индекс)
CREATE UNIQUE INDEX IF NOT EXISTS idx_idw_pdl_ref_u1 ON pdl.idw_pdl_ref (code, ref_name);

-- =====================================================================
-- ПРАВА ДОСТУПА
-- =====================================================================
-- =====================================================================
-- ПРАВА ДОСТУПА ДЛЯ ТАБЛИЦЫ pdl.idw_pdl_ref
-- По аналогии с pdl.idw_arj_pdl_addresses
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
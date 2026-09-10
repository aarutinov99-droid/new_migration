-- =====================================================
-- СКРИПТ ЗАЧИСТКИ ТЕСТОВЫХ ДАННЫХ
-- =====================================================
-- Удаление всех записей, вставленных с create_user = 'test_user'
-- для load_id = 1567806034
-- =====================================================

-- =====================================================
-- 1. Удаление из вспомогательных таблиц (дочерних)
-- =====================================================

-- Удаление из pdl.idw_arj_pdl_contact_infos
DELETE FROM pdl.idw_arj_pdl_contact_infos
WHERE load_id = 1567806034 
  AND create_user = 'test_user';

-- Удаление из pdl.idw_arj_pdl_addresses
DELETE FROM pdl.idw_arj_pdl_addresses
WHERE load_id = 1567806034 
  AND create_user = 'test_user';

-- Удаление из pdl.idw_arj_pdl_persdocs
DELETE FROM pdl.idw_arj_pdl_persdocs
WHERE load_id = 1567806034 
  AND create_user = 'test_user';

-- Удаление из pdl.idw_arj_pdl_countries
DELETE FROM pdl.idw_arj_pdl_countries
WHERE load_id = 1567806034 
  AND create_user = 'test_user';

-- Удаление из pdl.idw_arj_pdl_sanctions
DELETE FROM pdl.idw_arj_pdl_sanctions
WHERE load_id = 1567806034 
  AND create_user = 'test_user';

-- Удаление из pdl.idw_arj_pdl_sanlists
DELETE FROM pdl.idw_arj_pdl_sanlists
WHERE load_id = 1567806034 
  AND create_user = 'test_user';

-- Удаление из pdl.idw_arj_pdl_jobs
DELETE FROM pdl.idw_arj_pdl_jobs
WHERE load_id = 1567806034 
  AND create_user = 'test_user';

-- Удаление из pdl.idw_arj_pdl_category407
DELETE FROM pdl.idw_arj_pdl_category407
WHERE load_id = 1567806034 
  AND create_user = 'test_user';

-- Удаление из pdl.idw_arj_pdl_categories
DELETE FROM pdl.idw_arj_pdl_categories
WHERE load_id = 1567806034 
  AND create_user = 'test_user';

-- Удаление из pdl.idw_arj_pdl_translit_names
DELETE FROM pdl.idw_arj_pdl_translit_names
WHERE load_id = 1567806034 
  AND create_user = 'test_user';

-- Удаление из pdl.idw_arj_pdl_names
DELETE FROM pdl.idw_arj_pdl_names
WHERE load_id = 1567806034 
  AND create_user = 'test_user';

-- =====================================================
-- 2. Удаление из основной таблицы (родительской)
-- =====================================================

-- Удаление из pdl.idw_arj_interfax_pdl
DELETE FROM pdl.idw_arj_interfax_pdl
WHERE load_id = 1567806034;
-- Примечание: в основной таблице нет поля create_user,
-- поэтому удаляем по load_id
-- =====================================================
-- 3. ПРОВЕРКА РЕЗУЛЬТАТОВ ЗАЧИСТКИ
-- =====================================================
-- Проверка, что все данные удалены
SELECT 
    'idw_arj_interfax_pdl' as table_name, 
    COUNT(*) as remaining_count
FROM pdl.idw_arj_interfax_pdl
WHERE load_id = 1567806034

UNION ALL

SELECT 'idw_arj_pdl_names', COUNT(*)
FROM pdl.idw_arj_pdl_names
WHERE load_id = 1567806034 AND create_user = 'test_user'

UNION ALL

SELECT 'idw_arj_pdl_translit_names', COUNT(*)
FROM pdl.idw_arj_pdl_translit_names
WHERE load_id = 1567806034 AND create_user = 'test_user'

UNION ALL

SELECT 'idw_arj_pdl_categories', COUNT(*)
FROM pdl.idw_arj_pdl_categories
WHERE load_id = 1567806034 AND create_user = 'test_user'

UNION ALL

SELECT 'idw_arj_pdl_category407', COUNT(*)
FROM pdl.idw_arj_pdl_category407
WHERE load_id = 1567806034 AND create_user = 'test_user'

UNION ALL

SELECT 'idw_arj_pdl_jobs', COUNT(*)
FROM pdl.idw_arj_pdl_jobs
WHERE load_id = 1567806034 AND create_user = 'test_user'

UNION ALL

SELECT 'idw_arj_pdl_sanlists', COUNT(*)
FROM pdl.idw_arj_pdl_sanlists
WHERE load_id = 1567806034 AND create_user = 'test_user'

UNION ALL

SELECT 'idw_arj_pdl_sanctions', COUNT(*)
FROM pdl.idw_arj_pdl_sanctions
WHERE load_id = 1567806034 AND create_user = 'test_user'

UNION ALL

SELECT 'idw_arj_pdl_countries', COUNT(*)
FROM pdl.idw_arj_pdl_countries
WHERE load_id = 1567806034 AND create_user = 'test_user'

UNION ALL

SELECT 'idw_arj_pdl_persdocs', COUNT(*)
FROM pdl.idw_arj_pdl_persdocs
WHERE load_id = 1567806034 AND create_user = 'test_user'

UNION ALL

SELECT 'idw_arj_pdl_addresses', COUNT(*)
FROM pdl.idw_arj_pdl_addresses
WHERE load_id = 1567806034 AND create_user = 'test_user'

UNION ALL

SELECT 'idw_arj_pdl_contact_infos', COUNT(*)
FROM pdl.idw_arj_pdl_contact_infos
WHERE load_id = 1567806034 AND create_user = 'test_user'

ORDER BY table_name;


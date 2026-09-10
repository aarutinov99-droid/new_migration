-- DROP TABLE eor.TMP_EOR_IDENT_CANDIDATE;

CREATE TABLE IF NOT EXISTS eor.TMP_EOR_IDENT_CANDIDATE
(
    FIND_CANDIDATE_ID NUMERIC,
    ETALON_REGISTRY_ID NUMERIC,
    EOR_H_ID NUMERIC,
    WEIGHT NUMERIC
);

-- Добавление комментариев к таблице
COMMENT ON TABLE eor.TMP_EOR_IDENT_CANDIDATE IS 'Временная таблица для хранения кандидатов при идентификации EOR для регламентного процесса EOR_PDL_IDENT';

-- Добавление комментариев к колонкам
COMMENT ON COLUMN eor.TMP_EOR_IDENT_CANDIDATE.FIND_CANDIDATE_ID IS 'Идентификатор найденного кандидата';
COMMENT ON COLUMN eor.TMP_EOR_IDENT_CANDIDATE.ETALON_REGISTRY_ID IS 'Идентификатор эталонного реестра';
COMMENT ON COLUMN eor.TMP_EOR_IDENT_CANDIDATE.EOR_H_ID IS 'Идентификатор EOR ';
COMMENT ON COLUMN eor.TMP_EOR_IDENT_CANDIDATE.WEIGHT IS 'Вес или степень соответствия кандидата (коэффициент)';
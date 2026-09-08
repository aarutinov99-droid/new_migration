-- FUNCTION: idwh2.is_date(text, text)

-- DROP FUNCTION IF EXISTS idwh2.is_date(text, text);

CREATE OR REPLACE FUNCTION eor.is_date(
	p_date text,
	p_format text)
    RETURNS smallint
    LANGUAGE 'plpgsql'
    COST 100
    IMMUTABLE PARALLEL UNSAFE
AS $BODY$

DECLARE
  l_dt timestamp;
begin
  if p_date is null then
    return 0;
  end if;

  l_dt := to_timestamp(p_date, p_format);
  return 1;
exception
  when others then
    return 0;
END;
$BODY$;

ALTER FUNCTION eor.is_date(text, text)
    OWNER TO fors_idwh2_owner;
GRANT EXECUTE ON FUNCTION eor.is_date(text, text) TO PUBLIC;
GRANT EXECUTE ON FUNCTION eor.is_date(text, text) TO fors_idwh2_owner;


--------------------------------------------------------
--  DDL for Function SP_LAST_DAY_OF_DATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "USR_TSI_SUITE"."SP_LAST_DAY_OF_DATE" (
    pin_periodo  INTEGER,
    pin_mes      INTEGER
) RETURN DATE AS
    v_fecha DATE;
BEGIN
    SELECT
        last_day(to_date(01
                         || '/'
                         || pin_mes
                         || '/'
                         || pin_periodo, 'DD/MM/YYYY'))
    INTO v_fecha
    FROM
        dual;
  RETURN v_fecha;
END;

/

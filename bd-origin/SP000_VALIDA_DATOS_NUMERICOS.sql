--------------------------------------------------------
--  DDL for Function SP000_VALIDA_DATOS_NUMERICOS
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP000_VALIDA_DATOS_NUMERICOS" (
    v_valor IN VARCHAR2
) RETURN NUMBER IS
    v_numero NUMBER;
BEGIN
    v_numero := to_number(v_valor);
    IF v_numero IS NULL THEN
        RETURN 0;
    ELSE
        RETURN 1;
    END IF;
EXCEPTION
    WHEN value_error THEN
        RETURN 0;
END;

/

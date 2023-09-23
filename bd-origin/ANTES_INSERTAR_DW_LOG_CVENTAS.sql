--------------------------------------------------------
--  DDL for Trigger ANTES_INSERTAR_DW_LOG_CVENTAS
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_DW_LOG_CVENTAS" BEFORE
    INSERT ON "USR_TSI_SUITE"."DW_LOG_CVENTAS"
    FOR EACH ROW
DECLARE
    v_conteo NUMBER;
BEGIN
BEGIN
    SELECT
        NVL(id_log,0)
    INTO v_conteo
    FROM
        dw_log_cventas
    WHERE
        id_cia = :new.id_cia
    ORDER BY
        id_log DESC
    FETCH NEXT 1 ROWS ONLY;

EXCEPTION
    WHEN no_data_found THEN
        v_conteo := 0;
END;

:new.id_log := v_conteo + 1;

end;


/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_DW_LOG_CVENTAS" ENABLE;

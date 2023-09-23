--------------------------------------------------------
--  DDL for Trigger ANTES_INSERTAR_LOG_VERSIONES
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_LOG_VERSIONES" BEFORE
    INSERT ON "USR_TSI_SUITE"."LOG_VERSIONES"
    FOR EACH ROW
DECLARE
    v_conteo NUMBER;
BEGIN

    BEGIN
        SELECT
            id_log
        INTO v_conteo
        FROM
            log_versiones
        ORDER BY
            id_log DESC
        FETCH NEXT 1 ROWS ONLY;

    EXCEPTION
        WHEN no_data_found THEN
            v_conteo := 0;
    END;

    :new.id_log := v_conteo + 1;
END;


/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_LOG_VERSIONES" ENABLE;

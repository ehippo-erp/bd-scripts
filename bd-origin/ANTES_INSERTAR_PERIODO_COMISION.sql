--------------------------------------------------------
--  DDL for Trigger ANTES_INSERTAR_PERIODO_COMISION
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_PERIODO_COMISION" BEFORE
    INSERT ON "USR_TSI_SUITE"."PERIODO_COMISION"
    FOR EACH ROW
DECLARE
    v_conteo NUMBER;
BEGIN
    :new.fcreac := current_date;
    :new.factua := current_date;
    BEGIN
        SELECT
            NVL(id_periodo,0)
        INTO v_conteo
        FROM
            periodo_comision
        WHERE
                id_cia = :new.id_cia
        ORDER BY
            id_periodo DESC
        FETCH NEXT 1 ROWS ONLY;

    EXCEPTION
        WHEN no_data_found THEN
            v_conteo := 0;
    END;

    :new.id_periodo := v_conteo + 1;
END;
/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_PERIODO_COMISION" ENABLE;

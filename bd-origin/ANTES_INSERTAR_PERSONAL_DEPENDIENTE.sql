--------------------------------------------------------
--  DDL for Trigger ANTES_INSERTAR_PERSONAL_DEPENDIENTE
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_PERSONAL_DEPENDIENTE" BEFORE
    INSERT ON "USR_TSI_SUITE"."PERSONAL_DEPENDIENTE"
    FOR EACH ROW
DECLARE
    v_conteo NUMBER;
BEGIN
    :new.fcreac := current_date;
    :new.factua := current_date;
    BEGIN
        SELECT
            item
        INTO v_conteo
        FROM
            personal_dependiente
        WHERE
                id_cia = :new.id_cia
            AND codper = :new.codper
        ORDER BY
            item DESC
        FETCH NEXT 1 ROWS ONLY;

    EXCEPTION
        WHEN no_data_found THEN
            v_conteo := 0;
    END;

    :new.item := v_conteo + 1;
END;
/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_PERSONAL_DEPENDIENTE" ENABLE;

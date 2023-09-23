--------------------------------------------------------
--  DDL for Trigger ANTES_INSERTAR_COMPR011
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_COMPR011" BEFORE
    INSERT ON "USR_TSI_SUITE".compr011
    FOR EACH ROW
DECLARE
    v_item NUMBER;
BEGIN
    IF ( :new.item IS NULL ) THEN
        BEGIN
            SELECT
                trunc((MAX(item) / 1))
            INTO v_item
            FROM
                compr011
            WHERE
                    id_cia = :new.id_cia
                AND tipo = :new.tipo
                AND docume = :new.docume;

        EXCEPTION
            WHEN no_data_found THEN
                v_item := 0;
        END;

        :new.item := v_item + 1;
    END IF;
END;


/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_COMPR011" ENABLE;

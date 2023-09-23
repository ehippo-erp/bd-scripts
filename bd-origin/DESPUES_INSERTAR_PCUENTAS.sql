--------------------------------------------------------
--  DDL for Trigger DESPUES_INSERTAR_PCUENTAS
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."DESPUES_INSERTAR_PCUENTAS" AFTER
    INSERT ON "USR_TSI_SUITE".pcuentas
    FOR EACH ROW
DECLARE
    v_conteo INTEGER := 0;
BEGIN
    BEGIN
        SELECT
            COUNT(0)
        INTO v_conteo
        FROM
            pcuentas_clase
        WHERE
                id_cia = :new.id_cia
            AND cuenta = :new.cuenta
            AND clase = 11;

    EXCEPTION
        WHEN no_data_found THEN
            v_conteo := NULL;
    END;

    IF ( v_conteo IS NULL ) THEN
        v_conteo := 0;
    END IF;
    IF ( v_conteo = 0 ) THEN
        INSERT INTO pcuentas_clase (
            id_cia,
            cuenta,
            clase,
            codigo
        ) VALUES (
            :new.id_cia,
            :new.cuenta,
            11,
            '1'
        );

    ELSE
        UPDATE pcuentas_clase
        SET
            codigo = '1'
        WHERE
                id_cia = :new.id_cia
            AND cuenta = :new.cuenta
            AND clase = 11;

    END IF;

END;


/
ALTER TRIGGER "USR_TSI_SUITE"."DESPUES_INSERTAR_PCUENTAS" ENABLE;

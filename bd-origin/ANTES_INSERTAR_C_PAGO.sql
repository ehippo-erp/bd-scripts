--------------------------------------------------------
--  DDL for Trigger ANTES_INSERTAR_C_PAGO
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_C_PAGO" BEFORE
    INSERT ON "USR_TSI_SUITE".c_pago
    FOR EACH ROW
DECLARE
    v_conteo1  INTEGER := 0;
    v_conteo2  INTEGER := 0;
BEGIN
    BEGIN
        SELECT
            COUNT(0)
        INTO v_conteo1
        FROM
            c_pago_clase
        WHERE
                id_cia = :new.id_cia
            AND codpag = :new.codpag
            AND codigo = 1;

    EXCEPTION
        WHEN no_data_found THEN
            v_conteo1 := 0;
    END;

    IF v_conteo1 = 0 THEN
        INSERT INTO c_pago_clase (
            id_cia,
            codpag,
            codigo,
            descri,
            valor
        ) VALUES (
            :new.id_cia,
            :new.codpag,
            1,
            'Envía a Cta. Cte.',
            'S'
        );

    END IF;

    BEGIN
        SELECT
            COUNT(0)
        INTO v_conteo2
        FROM
            c_pago_clase
        WHERE
                id_cia = :new.id_cia
            AND codpag = :new.codpag
            AND codigo = 2;

    EXCEPTION
        WHEN no_data_found THEN
            v_conteo2 := 0;
    END;

    IF v_conteo2 = 0 THEN
        INSERT INTO c_pago_clase (
            id_cia,
            codpag,
            codigo,
            descri,
            valor
        ) VALUES (
            :new.id_cia,
            :new.codpag,
            2,
            'Verifíca Límite de Crédito',
            'S'
        );

    END IF;

END;


/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_C_PAGO" ENABLE;

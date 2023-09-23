--------------------------------------------------------
--  DDL for Trigger ANTES_ACTUALIZAR_TCCOSTOS
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_ACTUALIZAR_TCCOSTOS" BEFORE
    UPDATE ON "USR_TSI_SUITE".tccostos
    FOR EACH ROW
DECLARE
    v_conteo1  NUMBER := 0;
    v_conteo2  NUMBER := 0;
BEGIN
    :new.factua := current_date;
    IF ( ( :new.swacti IS NULL ) OR ( upper(:new.swacti) <> 'S' ) ) THEN
        :new.swacti := 'N';
    END IF;

    BEGIN
        SELECT
            COUNT(cuenta)
        INTO v_conteo1
        FROM
            pcuentas
        WHERE
                id_cia = :new.id_cia
            AND cuenta = :new.codigo;

    EXCEPTION
        WHEN no_data_found THEN
            v_conteo1 := NULL;
    END;

    IF ( ( v_conteo1 IS NULL ) OR ( v_conteo1 = 0 ) ) THEN
        RAISE pkg_exceptionuser.ex_codigo_no_existe_pcuentas;
    END IF;

    IF (
        ( :new.destin IS NOT NULL ) AND ( :new.destin <> '' )
    ) THEN
        BEGIN
            SELECT
                COUNT(cuenta)
            INTO v_conteo2
            FROM
                pcuentas
            WHERE
                    id_cia = :new.id_cia
                AND cuenta = :new.destin;

        EXCEPTION
            WHEN no_data_found THEN
                v_conteo2 := 0;
        END;

        IF ( ( v_conteo2 IS NULL ) OR ( v_conteo2 = 0 ) ) THEN
            RAISE pkg_exceptionuser.ex_destin_no_existe_pcuentas;
        END IF;

    END IF;

EXCEPTION
    WHEN pkg_exceptionuser.ex_codigo_no_existe_pcuentas THEN
        raise_application_error(pkg_exceptionuser.codigo_no_existe_pcuentas, ' Codigo no existe en el plan de cuentas.');
    WHEN pkg_exceptionuser.ex_destin_no_existe_pcuentas THEN
        raise_application_error(pkg_exceptionuser.destin_no_existe_pcuentas, ' Destino no existe en el plan de cuentas.');
END;


/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_ACTUALIZAR_TCCOSTOS" ENABLE;

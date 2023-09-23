--------------------------------------------------------
--  DDL for Trigger ANTES_ELIMINAR_CUENTA
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_ELIMINAR_CUENTA" BEFORE
    DELETE ON "USR_TSI_SUITE".pcuentas
    FOR EACH ROW
DECLARE
    v_conteo              NUMBER;
BEGIN
    BEGIN
        SELECT
            COUNT(d.cuenta)
        INTO v_conteo
        FROM
            cuentas_cchica d
        WHERE
                d.id_cia = :old.id_cia
            AND d.cuenta = :old.cuenta;

    EXCEPTION
        WHEN no_data_found THEN
            v_conteo := NULL;
    END;

    IF ( v_conteo IS NULL ) THEN
        v_conteo := 0;
    END IF;
    IF ( v_conteo > 0 ) THEN
        RAISE pkg_exceptionuser.ex_cuenta_relacionada_01;
    END IF;
    BEGIN
        SELECT
            COUNT(d.codigo)
        INTO v_conteo
        FROM
            tccostos d
        WHERE
                d.id_cia = :old.id_cia
            AND (d.codigo = :old.cuenta OR d.destin = :old.cuenta);

    EXCEPTION
        WHEN no_data_found THEN
            v_conteo := NULL;
    END;

    IF ( v_conteo IS NULL ) THEN
        v_conteo := 0;
    END IF;
    IF ( v_conteo > 0 ) THEN
        RAISE pkg_exceptionuser.ex_cuenta_relacionada_02;
    END IF;
    BEGIN
        SELECT
            COUNT(d.cuenta)
        INTO v_conteo
        FROM
            asiendet d
        WHERE
                d.id_cia = :old.id_cia
            AND d.cuenta = :old.cuenta;

    EXCEPTION
        WHEN no_data_found THEN
            v_conteo := NULL;
    END;

    IF ( v_conteo IS NULL ) THEN
        v_conteo := 0;
    END IF;
    IF ( v_conteo > 0 ) THEN
        RAISE pkg_exceptionuser.ex_cuenta_relacionada_03;
    END IF;
    BEGIN
        SELECT
            COUNT(m.cuenta)
        INTO v_conteo
        FROM
            movimientos m
        WHERE
                m.id_cia = :old.id_cia
            AND m.cuenta = :old.cuenta;

    EXCEPTION
        WHEN no_data_found THEN
            v_conteo := NULL;
    END;

    IF ( v_conteo IS NULL ) THEN
        v_conteo := 0;
    END IF;
    IF ( v_conteo > 0 ) THEN
        RAISE pkg_exceptionuser.ex_cuenta_relacionada_04;
    END IF;
EXCEPTION
    WHEN pkg_exceptionuser.ex_cuenta_relacionada_01 THEN
        raise_application_error(pkg_exceptionuser.cuenta_relacionada_01, ' Cuenta '
                                                                         || :old.cuenta
                                                                         || ' relacionada en cuentas por libros.');
    WHEN pkg_exceptionuser.ex_cuenta_relacionada_02 THEN
        raise_application_error(pkg_exceptionuser.cuenta_relacionada_02, ' Cuenta '
                                                                         || :old.cuenta
                                                                         || ' relacionada en centro de costos.');
    WHEN pkg_exceptionuser.ex_cuenta_relacionada_03 THEN
        raise_application_error(pkg_exceptionuser.cuenta_relacionada_03, ' Cuenta '
                                                                         || :old.cuenta
                                                                         || ' relacionada en detalle de asiento.');
    WHEN pkg_exceptionuser.ex_cuenta_relacionada_04 THEN
        raise_application_error(pkg_exceptionuser.cuenta_relacionada_04, ' Cuenta '
                                                                         || :old.cuenta
                                                                         || ' relacionada en movimientos contabilizados.');
END;
/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_ELIMINAR_CUENTA" ENABLE;

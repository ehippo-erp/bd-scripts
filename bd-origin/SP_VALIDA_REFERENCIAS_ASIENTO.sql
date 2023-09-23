--------------------------------------------------------
--  DDL for Procedure SP_VALIDA_REFERENCIAS_ASIENTO
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_VALIDA_REFERENCIAS_ASIENTO" (
    pin_id_cia       IN    INTEGER,
    pin_periodo      IN    INTEGER,
    pin_mes          IN    INTEGER,
    pin_libro        IN    VARCHAR2,
    pin_asiento      IN    INTEGER,
    pout_resultado   OUT   VARCHAR2,
    pout_mensaje     OUT   VARCHAR2
) AS
    v_nreg INTEGER := 0;
BEGIN
    pout_resultado := 'N';
    pout_mensaje := '';
    BEGIN
      /* Se esta dejando asi por motivo que NO debe haber mas de 1 Libro x vez.. */
        SELECT
            COUNT(0) AS nreg
        INTO v_nreg
        FROM
            dcta102
        WHERE
            id_cia = pin_id_cia
            AND libro = pin_libro
            AND periodo = pin_periodo
            AND mes = pin_mes
            AND secuencia = pin_asiento;

    EXCEPTION
        WHEN no_data_found THEN
            v_nreg := 0;
    END;

    IF ( v_nreg > 0 ) THEN
        pout_resultado := 'S';
        pout_mensaje := 'EXISTE RELACIONES EN LIBRO:'
                        || pin_libro
                        || ' PERIODO:'
                        || pin_periodo
                        || ' MES:'
                        || pin_mes
                        || ' ASIENTO:'
                        || pin_asiento;

    END IF;

    BEGIN
      /* Se esta dejando asi por motivo que NO debe haber mas de 1 Libro x vez.. */
        SELECT
            COUNT(0) AS nreg
        INTO v_nreg
        FROM
            prov102
        WHERE
            id_cia = pin_id_cia
            AND libro = pin_libro
            AND periodo = pin_periodo
            AND mes = pin_mes
            AND secuencia = pin_asiento;

    EXCEPTION
        WHEN no_data_found THEN
            v_nreg := 0;
    END;

    IF ( v_nreg > 0 ) THEN
        pout_resultado := 'S';
        pout_mensaje := 'EXISTE RELACIONES EN LIBRO:'
                        || pin_libro
                        || ' PERIODO:'
                        || pin_periodo
                        || ' MES:'
                        || pin_mes
                        || ' ASIENTO:'
                        || pin_asiento;

    END IF;

    BEGIN
      /* Se esta dejando asi por motivo que NO debe haber mas de 1 Libro x vez.. */
        SELECT
            COUNT(0) AS nreg
        INTO v_nreg
        FROM
            compr010
        WHERE
            id_cia = pin_id_cia
            AND libro = pin_libro
            AND periodo = pin_periodo
            AND mes = pin_mes
            AND asiento = pin_asiento;

    EXCEPTION
        WHEN no_data_found THEN
            v_nreg := 0;
    END;

    IF ( v_nreg > 0 ) THEN
        pout_resultado := 'S';
        pout_mensaje := 'EXISTE RELACIONES EN LIBRO:'
                        || pin_libro
                        || ' PERIODO:'
                        || pin_periodo
                        || ' MES:'
                        || pin_mes
                        || ' ASIENTO:'
                        || pin_asiento;

    END IF;

END sp_valida_referencias_asiento;

/

--------------------------------------------------------
--  DDL for Procedure SP_GRABA_CONCILIACION
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_GRABA_CONCILIACION" (
    pin_id_cia       IN  NUMBER,
    pin_periodo      IN  VARCHAR2,
    pin_mes          IN  VARCHAR2,
    pin_libro        IN  VARCHAR2,
    pin_asiento      IN  NUMBER,
    pin_witem        IN  NUMBER,
    pin_wsitem       IN  NUMBER,
    pin_periodo_cob  IN  NUMBER,
    pin_mes_cob      IN  NUMBER
) AS
    v_conteo NUMBER;
BEGIN
    BEGIN
        SELECT
            COUNT(0) AS conteo
        INTO v_conteo
        FROM
            movimientos_conciliacion
        WHERE
                id_cia = pin_id_cia
            AND periodo = pin_periodo
            AND mes = pin_mes
            AND libro = pin_libro
            AND asiento = pin_asiento
            AND item = pin_witem
            AND sitem = pin_wsitem;

    EXCEPTION
        WHEN no_data_found THEN
            v_conteo := NULL;
    END;

    IF ( v_conteo IS NULL ) OR ( v_conteo = 0 ) THEN
        INSERT INTO movimientos_conciliacion (
            id_cia,
            periodo,
            mes,
            libro,
            asiento,
            item,
            sitem,
            periodocob,
            mescob
        ) VALUES (
            pin_id_cia,
            pin_periodo,
            pin_mes,
            pin_libro,
            pin_asiento,
            pin_witem,
            pin_wsitem,
            pin_periodo_cob,
            pin_mes_cob
        );

    ELSE
        UPDATE movimientos_conciliacion
        SET
            periodocob = pin_periodo_cob,
            mescob = pin_mes_cob
        WHERE
                id_cia = pin_id_cia
            AND periodo = pin_periodo
            AND mes = pin_mes
            AND libro = pin_libro
            AND asiento = pin_asiento
            AND item = pin_witem
            AND sitem = pin_wsitem;

    END IF;

    UPDATE movimientos
    SET
        swchkconcilia = 'S'
    WHERE
            id_cia = pin_id_cia
        AND periodo = pin_periodo
        AND mes = pin_mes
        AND libro = pin_libro
        AND asiento = pin_asiento
        AND item = pin_witem
        AND sitem = pin_wsitem;

END sp_graba_conciliacion;

/

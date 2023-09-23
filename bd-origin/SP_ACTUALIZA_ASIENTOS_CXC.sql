--------------------------------------------------------
--  DDL for Procedure SP_ACTUALIZA_ASIENTOS_CXC
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_ACTUALIZA_ASIENTOS_CXC" (
    pin_id_cia  IN INTEGER,
    pin_periodo IN INTEGER
) AS
    v_msj VARCHAR2(1000);
BEGIN
    FOR reg IN (
        SELECT DISTINCT
            d.libro,
            d.periodo,
            d.mes,
            d.secuencia
        FROM
            dcta102     d
            LEFT OUTER JOIN movimientos m ON m.libro = d.libro
                                             AND m.periodo = d.periodo
                                             AND m.mes = d.mes
                                             AND m.asiento = d.secuencia
                                             AND m.item = 1
        WHERE
                d.id_cia = pin_id_cia
            AND d.periodo = pin_periodo
            AND d.situac = 'B'
            AND m.cuenta IS NULL
        ORDER BY
            d.libro,
            d.periodo,
            d.mes,
            d.secuencia
    ) LOOP
        sp_genera_asientos_cxcobrar(pin_id_cia, reg.libro, reg.periodo, reg.mes, reg.secuencia,
                                   'admin',v_msj);
    END LOOP;
END;

/

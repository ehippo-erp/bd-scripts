--------------------------------------------------------
--  DDL for Package Body PACK_CUENTAS_CCHICA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_CUENTAS_CCHICA" AS

    FUNCTION sp_movimientos_asignar_costeo (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER,
        pin_libro   VARCHAR2
    ) RETURN datatable_movimientos_asignar_costeo
        PIPELINED
    AS
        v_table datatable_movimientos_asignar_costeo;
    BEGIN
        SELECT DISTINCT
            m.cuenta,
            p.nombre             AS descuenta,
            m.codigo,
            m.razon,
            m.periodo,
            m.mes,
            m.fecha,
            m.libro,
            m.asiento,
            m.item,
            m.sitem,
            m.tdocum,
            m.numero,
            p.moneda01,
            m.concep,
            pr.descri            AS proyecto,
            m.swgasoper,
            a.referencia         AS refere,
            a.girara             AS razonc_cr,
            m.debe01,
            m.haber01,
            m.debe01 - m.haber01 AS saldo01,
            m.debe02,
            m.haber02,
            m.debe02 - m.haber02 AS saldo02
        BULK COLLECT
        INTO v_table
        FROM
                 cuentas_cchica cu
            INNER JOIN pcuentas                     p ON p.id_cia = pin_id_cia
                                     AND p.cuenta = cu.cuenta
            INNER JOIN movimientos                  m ON m.id_cia = pin_id_cia
                                        AND m.periodo >= pin_periodo
                                        AND m.libro <> pin_libro
                                        AND m.cuenta = p.cuenta
            LEFT OUTER JOIN asienhea                     a ON a.id_cia = pin_id_cia
                                          AND a.periodo = m.periodo
                                          AND a.mes = m.mes
                                          AND a.libro = m.libro
                                          AND a.asiento = m.asiento
            LEFT OUTER JOIN movimientos_relacion         c ON c.id_cia = pin_id_cia
                                                      AND c.periodo = m.periodo
                                                      AND c.mes = m.mes
                                                      AND c.libro = m.libro
                                                      AND c.asiento = m.asiento
                                                      AND c.item = m.item
                                                      AND c.sitem = m.sitem
            LEFT OUTER JOIN movimientos_relacion_asiento ra ON ra.id_cia = pin_id_cia
                                                               AND ra.periodo = m.periodo
                                                               AND ra.mes = m.mes
                                                               AND ra.libro = m.libro
                                                               AND ra.asiento = m.asiento
            LEFT OUTER JOIN tproyecto                    pr ON pr.id_cia = pin_id_cia
                                            AND pr.codigo = m.proyec
        WHERE
                cu.id_cia = pin_id_cia
            AND cu.motivo = 5
            AND c.numint IS NULL
            AND ra.numint IS NULL
        ORDER BY
            m.periodo,
            m.mes,
            m.libro,
            m.asiento,
            m.item,
            m.sitem;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_movimientos_asignar_costeo;

END;

/

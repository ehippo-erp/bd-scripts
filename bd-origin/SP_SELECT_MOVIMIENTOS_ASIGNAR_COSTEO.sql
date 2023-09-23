--------------------------------------------------------
--  DDL for Function SP_SELECT_MOVIMIENTOS_ASIGNAR_COSTEO
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP_SELECT_MOVIMIENTOS_ASIGNAR_COSTEO" (
    pin_id_cia   IN  NUMBER,
    pin_periodo  IN  NUMBER,
    pin_libro    IN  VARCHAR2
) RETURN tbl_movimientos_asignar_costeo
    PIPELINED
AS

    reg_movimientos_asignar_costeo rec_movimientos_asignar_costeo := rec_movimientos_asignar_costeo(NULL, NULL, NULL, NULL, NULL,
                               NULL, NULL, NULL, NULL, NULL,
                               NULL, NULL, NULL, NULL, NULL,
                               NULL, NULL, NULL, NULL, NULL,
                               NULL, NULL);
    CURSOR cur_select_cchica IS
    SELECT DISTINCT
        m.cuenta,
        p.nombre                  AS descuenta,
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
        m.debe01                  AS debe,
        m.haber01                 AS haber,
        m.debe01 - m.haber01      AS saldo,
        m.concep,
        pr.descri                 AS proyecto,
        m.swgasoper,
        a.referencia              AS refere,
        a.girara                  AS razonc_cr
    FROM
             cuentas_cchica cu
        INNER JOIN pcuentas                      p ON p.id_cia = pin_id_cia
                                 AND p.cuenta = cu.cuenta
        INNER JOIN movimientos                   m ON m.id_cia = pin_id_cia
                                    AND m.periodo >= pin_periodo
                                    AND m.libro <> pin_libro
                                    AND m.cuenta = p.cuenta
        LEFT OUTER JOIN asienhea                      a ON a.id_cia = pin_id_cia
                                      AND a.periodo = m.periodo
                                      AND a.mes = m.mes
                                      AND a.libro = m.libro
                                      AND a.asiento = m.asiento
        LEFT OUTER JOIN movimientos_relacion          c ON c.id_cia = pin_id_cia
                                                  AND c.periodo = m.periodo
                                                  AND c.mes = m.mes
                                                  AND c.libro = m.libro
                                                  AND c.asiento = m.asiento
                                                  AND c.item = m.item
                                                  AND c.sitem = m.sitem
        LEFT OUTER JOIN movimientos_relacion_asiento  ra ON ra.id_cia = pin_id_cia
                                                           AND ra.periodo = m.periodo
                                                           AND ra.mes = m.mes
                                                           AND ra.libro = m.libro
                                                           AND ra.asiento = m.asiento
        LEFT OUTER JOIN tproyecto                     pr ON pr.id_cia = pin_id_cia
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

BEGIN
    FOR registro IN cur_select_cchica LOOP
        reg_movimientos_asignar_costeo.descuenta := registro.descuenta;
        reg_movimientos_asignar_costeo.cuenta := registro.cuenta;
        reg_movimientos_asignar_costeo.codigo := registro.codigo;
        reg_movimientos_asignar_costeo.razon := registro.razon;
        reg_movimientos_asignar_costeo.periodo := registro.periodo;
        reg_movimientos_asignar_costeo.mes := registro.mes;
        reg_movimientos_asignar_costeo.fecha := registro.fecha;
        reg_movimientos_asignar_costeo.libro := registro.libro;
        reg_movimientos_asignar_costeo.asiento := registro.asiento;
        reg_movimientos_asignar_costeo.item := registro.item;
        reg_movimientos_asignar_costeo.sitem := registro.sitem;
        reg_movimientos_asignar_costeo.tdocum := registro.tdocum;
        reg_movimientos_asignar_costeo.numero := registro.numero;
        reg_movimientos_asignar_costeo.moneda01 := registro.moneda01;
        reg_movimientos_asignar_costeo.debe := registro.debe;
        reg_movimientos_asignar_costeo.haber := registro.haber;
        reg_movimientos_asignar_costeo.saldo := registro.saldo;
        reg_movimientos_asignar_costeo.concep := registro.concep;
        reg_movimientos_asignar_costeo.proyecto := registro.proyecto;
        reg_movimientos_asignar_costeo.swgasoper := registro.swgasoper;
        reg_movimientos_asignar_costeo.refere := registro.refere;
        reg_movimientos_asignar_costeo.razonc_cr := registro.razonc_cr;
        PIPE ROW ( reg_movimientos_asignar_costeo );
    END LOOP;
END sp_select_movimientos_asignar_costeo;

/

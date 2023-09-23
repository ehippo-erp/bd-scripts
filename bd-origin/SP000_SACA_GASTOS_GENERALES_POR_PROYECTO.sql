--------------------------------------------------------
--  DDL for Function SP000_SACA_GASTOS_GENERALES_POR_PROYECTO
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP000_SACA_GASTOS_GENERALES_POR_PROYECTO" (
    pin_id_cia  NUMBER,
    pin_periodo NUMBER,
    pin_mesdes  NUMBER,
    pin_meshas  NUMBER,
    pin_codproy VARCHAR2
) RETURN tbl_gastos_generales_por_proyecto
    PIPELINED
AS

    v_gastos_generales_por_proyecto rec_gastos_generales_por_proyecto := rec_gastos_generales_por_proyecto(NULL, NULL, NULL, NULL, NULL
    ,
                                                                                                          NULL, NULL, NULL, NULL, NULL
                                                                                                          );
    CURSOR cur_select IS
    SELECT
        m.proyec                  AS codproy,
        p.descri                  AS desproy,
        c.tipgas,
        g.descri                  AS destipgas,
        m.cuenta,
        c.nombre                  AS descuenta,
        m.periodo,
        m.mes,
        SUM(m.debe01 - m.haber01) AS saldo01,
        SUM(m.debe02 - m.haber02) AS saldo02
    FROM
        movimientos m
        LEFT OUTER JOIN pcuentas    c ON c.id_cia = m.id_cia
                                      AND c.cuenta = m.cuenta
        INNER JOIN tproyecto   p ON p.id_cia = m.id_cia
                                  AND p.codigo = m.proyec
        LEFT OUTER JOIN tgastos     g ON g.id_cia = c.id_cia
                                     AND g.codigo = c.tipgas
    WHERE
            m.id_cia = pin_id_cia
        AND m.sitem = 0
        AND m.periodo = pin_periodo
        AND m.mes >= pin_mesdes
        AND m.mes <= pin_meshas
        AND nvl(m.proyec, '0') <> '0'
        AND ( pin_codproy = '0'
              OR pin_codproy IS NULL
              OR m.proyec = pin_codproy )
    GROUP BY
        m.proyec,
        p.descri,
        c.tipgas,
        g.descri,
        m.cuenta,
        c.nombre,
        m.periodo,
        m.mes
    ORDER BY
        m.proyec,
        p.descri,
        c.tipgas,
        g.descri,
        m.cuenta,
        c.nombre,
        m.periodo,
        m.mes;

BEGIN
    FOR registro IN cur_select LOOP
        v_gastos_generales_por_proyecto.codproy := registro.codproy;
        v_gastos_generales_por_proyecto.desproy := registro.desproy;
        v_gastos_generales_por_proyecto.tipgas := registro.tipgas;
        v_gastos_generales_por_proyecto.desgas := registro.destipgas;
        v_gastos_generales_por_proyecto.cuenta := registro.cuenta;
        v_gastos_generales_por_proyecto.descuenta := registro.descuenta;
        v_gastos_generales_por_proyecto.periodo := registro.periodo;
        v_gastos_generales_por_proyecto.mespro := registro.mes;
        v_gastos_generales_por_proyecto.saldo01 := registro.saldo01;
        v_gastos_generales_por_proyecto.saldo02 := registro.saldo02;
        PIPE ROW ( v_gastos_generales_por_proyecto );
    END LOOP;
END sp000_saca_gastos_generales_por_proyecto;

/

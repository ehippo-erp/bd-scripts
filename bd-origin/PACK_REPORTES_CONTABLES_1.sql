--------------------------------------------------------
--  DDL for Package Body PACK_REPORTES_CONTABLES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_REPORTES_CONTABLES" AS

    FUNCTION sp_movimientos_por_cuenta (
        pin_id_cia  IN NUMBER,
        pin_periodo IN NUMBER,
        pin_mes_ini IN NUMBER,
        pin_mes_fin IN NUMBER,
        pin_moneda  IN VARCHAR2,
        pin_cuentas IN VARCHAR2
    ) RETURN datatable_movimientos_por_cuenta
        PIPELINED
    AS
        v_table datatable_movimientos_por_cuenta;
    BEGIN
        SELECT
            c.cuenta,
            c.nombre,
            m.ccosto,
            tc.descri                                    AS desccosto,
            m.subcco,
            ts.razonc                                    AS dessubccosto,
            m.ctaalternativa,
            CAST(substr(c.cuenta, 1, 2) AS VARCHAR(20))  AS cuentan1,
            c1.nombre                                    AS nombren1,
            CAST(substr(c.cuenta, 1, 4) AS VARCHAR(20))  AS cuentan2,
            c2.nombre                                    AS nombren2,
            CAST(substr(c.cuenta, 1, 6) AS VARCHAR(20))  AS cuentan3,
            c3.nombre                                    AS nombren3,
            CAST(substr(c.cuenta, 1, 8) AS VARCHAR(20))  AS cuentan4,
            c4.nombre                                    AS nombren4,
            CAST(substr(c.cuenta, 1, 10) AS VARCHAR(20)) AS cuentan5,
            c5.nombre                                    AS nombren5,
            CAST(substr(c.cuenta, 1, 12) AS VARCHAR(20)) AS cuentan6,
            c6.nombre                                    AS nombren6,
            m.fecha,
            m.libro,
            m.asiento,
            m.concep                                     AS concepto,
            CASE
                WHEN cl.razonc IS NULL THEN
                    m.razon
                ELSE
                    cl.razonc
            END                                          razonc,
            cl.tident,
            cl.dident,
            m.tdocum,
            m.serie,
            m.numero,
            m.fdocum,
            m.moneda,
            m.mes,
            CASE
                WHEN pin_moneda = 'PEN' THEN
                    m.debe01
                ELSE
                    m.debe02
            END                                          AS debe,
            CASE
                WHEN pin_moneda = 'PEN' THEN
                    m.haber01
                ELSE
                    m.haber02
            END                                          AS haber
        BULK COLLECT
        INTO v_table
        FROM
            pcuentas    c
            LEFT OUTER JOIN movimientos m ON m.id_cia = c.id_cia
                                             AND ( m.cuenta = c.cuenta )
                                             AND ( m.periodo = pin_periodo )
                                             AND ( m.mes >= pin_mes_ini )
                                             AND ( m.mes <= pin_mes_fin )
            LEFT OUTER JOIN tccostos    tc ON tc.id_cia = m.id_cia
                                           AND tc.codigo = m.ccosto
            LEFT OUTER JOIN cliente     ts ON ts.id_cia = m.id_cia
                                          AND ts.codcli = m.subcco
            LEFT OUTER JOIN cliente     cl ON cl.id_cia = m.id_cia
                                          AND cl.codcli = m.codigo
            LEFT OUTER JOIN pcuentas    c1 ON c1.id_cia = c.id_cia
                                           AND c1.cuenta = substr(c.cuenta, 1, 2)
            LEFT OUTER JOIN pcuentas    c2 ON c2.id_cia = c.id_cia
                                           AND c2.cuenta = substr(c.cuenta, 1, 4)
            LEFT OUTER JOIN pcuentas    c3 ON c3.id_cia = c.id_cia
                                           AND c3.cuenta = substr(c.cuenta, 1, 6)
            LEFT OUTER JOIN pcuentas    c4 ON c4.id_cia = c.id_cia
                                           AND c4.cuenta = substr(c.cuenta, 1, 8)
            LEFT OUTER JOIN pcuentas    c5 ON c5.id_cia = c.id_cia
                                           AND c5.cuenta = substr(c.cuenta, 1, 10)
            LEFT OUTER JOIN pcuentas    c6 ON c6.id_cia = c.id_cia
                                           AND c6.cuenta = substr(c.cuenta, 1, 12)
        WHERE
                c.id_cia = pin_id_cia
            AND c.cuenta IN (
                SELECT
                    *
                FROM
                    TABLE ( convert_in(pin_cuentas) )
            )
        ORDER BY
            m.mes,
            c.cuenta,
            m.libro,
            m.asiento;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_movimientos_por_cuenta;

END;

/

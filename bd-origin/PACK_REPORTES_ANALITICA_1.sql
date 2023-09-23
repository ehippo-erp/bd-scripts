--------------------------------------------------------
--  DDL for Package Body PACK_REPORTES_ANALITICA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_REPORTES_ANALITICA" AS

    FUNCTION sp_detalle_saldo (
        pin_id_cia  NUMBER,
        pin_codtana NUMBER,
        pin_periodo NUMBER,
        pin_mes     NUMBER
    ) RETURN datatable_detalle_saldo
        PIPELINED
    AS
        v_codtana VARCHAR2(1000);
        v_titulo  VARCHAR2(20 CHAR);
        v_table   datatable_detalle_saldo;
    BEGIN
        v_codtana := to_char(pin_codtana);
        SELECT
            t.cuenta,
            t.nombre,
            t.tident,
            t.abrent,
            t.dident,
            t.codigo,
            t.razonc,
            t.debe01 - t.haber01,
            t.debe02 - t.haber02
        BULK COLLECT
        INTO v_table
        FROM
            (
                SELECT
                    p.cuenta,
                    p.nombre,
                    c.tident,
                    i.abrevi       AS abrent,
                    c.dident,
                    m.codigo,
                    c.razonc,
                    pc.swflag,
                    SUM(m.debe01)  AS debe01,
                    SUM(m.haber01) AS haber01,
                    SUM(m.debe02)  AS debe02,
                    SUM(m.haber02) AS haber02
                FROM
                         movimientos m
                    INNER JOIN pcuentas       p ON p.id_cia = m.id_cia
                                             AND p.cuenta = m.cuenta
                    LEFT OUTER JOIN pcuentas_clase pc ON pc.id_cia = m.id_cia
                                                         AND pc.cuenta = m.cuenta
                                                         AND pc.clase = 1
                    LEFT OUTER JOIN cliente        c ON c.id_cia = m.id_cia
                                                 AND c.codcli = m.codigo
                    LEFT OUTER JOIN identidad      i ON i.id_cia = c.id_cia
                                                   AND i.tident = c.tident
                WHERE
                        m.id_cia = pin_id_cia
                    AND m.periodo = pin_periodo
                    AND m.mes <= pin_mes
                    AND p.codtana IN (
                        SELECT
                            *
                        FROM
                            TABLE ( convert_in(pin_codtana) )
                    )
                GROUP BY
                    p.cuenta,
                    p.nombre,
                    c.tident,
                    i.abrevi,
                    c.dident,
                    m.codigo,
                    c.razonc,
                    pc.swflag
                HAVING ( ( SUM(m.debe01) - SUM(m.haber01) ) <> 0 )
                       OR ( ( ( SUM(m.debe02) - SUM(m.haber02) ) <> 0 )
                            AND ( upper(pc.swflag) = 'S' ) )
                ORDER BY
                    m.cuenta ASC,
                    m.codigo ASC
            ) t
        WHERE
            t.debe01 - t.haber01 <> 0
        ORDER BY
            t.cuenta,
            t.codigo;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_detalle_saldo;

    FUNCTION sp_detalle_documento_saldo (
        pin_id_cia  NUMBER,
        pin_codtana NUMBER,
        pin_periodo NUMBER,
        pin_mes     NUMBER,
        pin_codcli  VARCHAR2
    ) RETURN datatable_detalle_documento_saldo
        PIPELINED
    AS
        v_codtana VARCHAR2(1000);
        v_titulo  VARCHAR2(20 CHAR);
        v_table   datatable_detalle_documento_saldo;
    BEGIN
        SELECT
            t.cuenta,
            t.nombre,
            t.tident,
            t.abrent,
            t.dident,
            t.codigo,
            t.razonc,
            t.tdocum,
            t.documento_tipo,
            t.serie,
            t.numero,
            to_char(t.fecha, 'DD/MM/YY') AS fecha,
            t.debe01,
            t.haber01,
            t.debe02,
            t.haber02,
            t.debe01 - t.haber01,
            t.debe02 - t.haber02
        BULK COLLECT
        INTO v_table
        FROM
            (
                SELECT
                    p.cuenta,
                    p.nombre,
                    c.tident,
                    i.abrevi         AS abrent,
                    c.dident,
                    m.codigo,
                    c.razonc,
                    m.tdocum,
                    upper(dt.descri) AS documento_tipo,
                    m.serie,
                    m.numero,
                    MIN(m.fecha)     AS fecha,
                    pc.swflag,
                    SUM(m.debe01)    AS debe01,
                    SUM(m.haber01)   AS haber01,
                    SUM(m.debe02)    AS debe02,
                    SUM(m.haber02)   AS haber02
                FROM
                         movimientos m
                    INNER JOIN pcuentas       p ON p.id_cia = m.id_cia
                                             AND p.cuenta = m.cuenta
                    LEFT OUTER JOIN pcuentas_clase pc ON pc.id_cia = m.id_cia
                                                         AND pc.cuenta = m.cuenta
                                                         AND pc.clase = 1
                    LEFT OUTER JOIN cliente        c ON c.id_cia = m.id_cia
                                                 AND c.codcli = m.codigo
                    LEFT OUTER JOIN identidad      i ON i.id_cia = c.id_cia
                                                   AND i.tident = c.tident
                    LEFT OUTER JOIN tdocume        dt ON dt.id_cia = m.id_cia
                                                  AND dt.codigo = m.tdocum
                WHERE
                        m.id_cia = pin_id_cia
                    AND m.periodo = pin_periodo
                    AND m.mes <= pin_mes
                    AND p.codtana = pin_codtana
                    AND ( pin_codcli IS NULL
                          OR pin_codcli = '-1'
                          OR m.codigo = pin_codcli )
                GROUP BY
                    p.cuenta,
                    p.nombre,
                    c.tident,
                    i.abrevi,
                    c.dident,
                    m.codigo,
                    c.razonc,
                    m.tdocum,
                    dt.descri,
                    m.serie,
                    m.numero,
                    pc.swflag
                HAVING ( ( SUM(m.debe01) - SUM(m.haber01) ) <> 0 )
                       OR ( ( ( SUM(m.debe02) - SUM(m.haber02) ) <> 0 )
                            AND ( upper(pc.swflag) = 'S' ) )
                ORDER BY
                    m.cuenta ASC,
                    m.codigo ASC
            ) t
        WHERE
            t.debe01 - t.haber01 <> 0
        ORDER BY
            t.cuenta,
            t.codigo;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_detalle_documento_saldo;

    FUNCTION sp_detalle_documento_movimientos_saldo (
        pin_id_cia  NUMBER,
        pin_codtana NUMBER,
        pin_periodo NUMBER,
        pin_mes     NUMBER,
        pin_codcli  VARCHAR2
    ) RETURN datatable_detalle_movimientos
        PIPELINED
    AS
        v_table datatable_detalle_movimientos;
    BEGIN
        FOR i IN (
            SELECT
                cuenta,
                codigo,
                tdocum,
                serie,
                numero
            FROM
                sp_detalle_documento_saldo(pin_id_cia, pin_codtana, pin_periodo, pin_mes, pin_codcli)
        ) LOOP
            SELECT
                p.cuenta,
                p.nombre,
                c.tident,
                i.abrevi         AS abrent,
                c.dident,
                m.codigo,
                c.razonc,
                m.periodo,
                m.mes,
                m.libro,
                m.asiento,
                m.tdocum,
                upper(dt.descri) AS documento_tipo,
                m.serie,
                m.numero,
                m.fecha          AS fecha,
                m.concep,
                m.debe01,
                m.haber01,
                m.debe02,
                m.haber02
            BULK COLLECT
            INTO v_table
            FROM
                     movimientos m
                INNER JOIN pcuentas  p ON p.id_cia = m.id_cia
                                         AND p.cuenta = m.cuenta
                LEFT OUTER JOIN cliente   c ON c.id_cia = m.id_cia
                                             AND c.codcli = m.codigo
                LEFT OUTER JOIN identidad i ON i.id_cia = c.id_cia
                                               AND i.tident = c.tident
                LEFT OUTER JOIN tdocume   dt ON dt.id_cia = m.id_cia
                                              AND dt.codigo = m.tdocum
            WHERE
                    m.id_cia = pin_id_cia
                AND m.periodo = pin_periodo
                AND m.mes <= pin_mes
                AND p.codtana = pin_codtana
            -- DETALLE
                AND nvl(m.cuenta, 'XXXXXX') = nvl(i.cuenta, 'XXXXXX')
                AND nvl(m.codigo, 'XXXXXXXXX') = nvl(i.codigo, 'XXXXXXXXX')
                AND nvl(m.tdocum, 'XX') = nvl(i.tdocum, 'XX')
                AND nvl(m.serie, 'XXXX') = nvl(i.serie, 'XXXX')
                AND nvl(m.numero, 'XXXXXXXXXX') = nvl(i.numero, 'XXXXXXXXXX')
            ORDER BY
                p.cuenta ASC,
                p.nombre ASC,
                m.codigo ASC,
                m.tdocum ASC,
                m.serie ASC,
                m.numero ASC,
                m.periodo ASC,
                m.mes ASC,
                m.libro ASC,
                m.asiento ASC,
                m.item ASC;

            FOR registro IN 1..v_table.count LOOP
                PIPE ROW ( v_table(registro) );
            END LOOP;

        END LOOP;

        RETURN;
    END sp_detalle_documento_movimientos_saldo;

    FUNCTION sp_detalle_movimientos (
        pin_id_cia  NUMBER,
        pin_codtana NUMBER,
        pin_periodo NUMBER,
        pin_mes     NUMBER,
        pin_codcli  VARCHAR2
    ) RETURN datatable_detalle_movimientos
        PIPELINED
    AS
        v_table datatable_detalle_movimientos;
    BEGIN
        SELECT
            p.cuenta,
            p.nombre,
            c.tident,
            i.abrevi         AS abrent,
            c.dident,
            m.codigo,
            c.razonc,
            m.periodo,
            m.mes,
            m.libro,
            m.asiento,
            m.tdocum,
            upper(dt.descri) AS documento_tipo,
            m.serie,
            m.numero,
            m.fecha          AS fecha,
            m.concep,
            m.debe01,
            m.haber01,
            m.debe02,
            m.haber02
        BULK COLLECT
        INTO v_table
        FROM
                 movimientos m
            INNER JOIN pcuentas  p ON p.id_cia = m.id_cia
                                     AND p.cuenta = m.cuenta
            LEFT OUTER JOIN cliente   c ON c.id_cia = m.id_cia
                                         AND c.codcli = m.codigo
            LEFT OUTER JOIN identidad i ON i.id_cia = c.id_cia
                                           AND i.tident = c.tident
            LEFT OUTER JOIN tdocume   dt ON dt.id_cia = m.id_cia
                                          AND dt.codigo = m.tdocum
        WHERE
                m.id_cia = pin_id_cia
            AND m.periodo = pin_periodo
            AND m.mes <= pin_mes
            AND p.codtana = pin_codtana
            AND ( pin_codcli IS NULL
                  OR pin_codcli = '-1'
                  OR m.codigo = pin_codcli )
        ORDER BY
            p.cuenta ASC,
            p.nombre ASC,
            m.codigo ASC,
            m.tdocum ASC,
            m.serie ASC,
            m.numero ASC,
            m.periodo ASC,
            m.mes ASC,
            m.libro ASC,
            m.asiento ASC,
            m.item ASC;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_detalle_movimientos;

    FUNCTION sp_saldo (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER,
        pin_mes     NUMBER
    ) RETURN datatable_saldo
        PIPELINED
    AS
        v_table datatable_saldo;
    BEGIN
        SELECT
            '10',
            '3.2. Inventarios Balances: Cuenta 10 Caja y Bancos',
            cuenta,
            denominacion,
            SUM(saldo_pen),
            SUM(saldo_usd)
        BULK COLLECT
        INTO v_table
        FROM
            pack_reportes_analitica.sp_cajban_saldo(pin_id_cia, NULL, pin_periodo, pin_mes)
        GROUP BY
            '10',
            '3.2. Inventarios Balances: Cuenta 10 Caja y Bancos',
            cuenta,
            denominacion
        ORDER BY
            cuenta;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        FOR i IN (
            SELECT
                *
            FROM
                tanalitica
            WHERE
                    id_cia = pin_id_cia
                AND swacti = 'S'
        ) LOOP
            SELECT
                i.codtana,
                i.descri,
                ds.cuenta,
                ds.denominacion,
                SUM(ds.saldo_pen),
                SUM(ds.saldo_usd)
            BULK COLLECT
            INTO v_table
            FROM
                pack_reportes_analitica.sp_detalle_saldo(pin_id_cia, i.codtana, pin_periodo, pin_mes) ds
            GROUP BY
                i.codtana,
                i.descri,
                ds.cuenta,
                ds.denominacion
            ORDER BY
                ds.cuenta;

            FOR registro IN 1..v_table.count LOOP
                PIPE ROW ( v_table(registro) );
            END LOOP;

        END LOOP;

--        FOR i IN (
--            SELECT
--                *
--            FROM
--                numero
--            WHERE
--                id_numero IN ( 1, 2, 3, 4 )
--        ) LOOP
--            SELECT
--                titulo,
--                destitulo,
--                NULL,
--                NULL,
--                SUM(costo_pen),
--                SUM(costo_usd)
--            BULK COLLECT
--            INTO v_table
--            FROM
--                pack_reportes_analitica.sp_estado_saldo2(pin_id_cia, i.id_numero, pin_periodo, pin_mes)
--            GROUP BY
--                titulo,
--                destitulo,
--                NULL,
--                NULL;
--
--            FOR registro IN 1..v_table.count LOOP
--                PIPE ROW ( v_table(registro) );
--            END LOOP;
--
--    END loop;

        RETURN;
    END sp_saldo;

    FUNCTION sp_estado_saldo (
        pin_id_cia  NUMBER,
        pin_tipo    INTEGER,
        pin_periodo INTEGER,
        pin_mes     INTEGER
    ) RETURN datatable_estado_saldo
        PIPELINED
    AS
        v_table      datatable_estado_saldo;
        v_inventario VARCHAR2(200);
        v_titulo     VARCHAR2(20 CHAR);
        v_periodo    NUMBER;
    BEGIN
        v_periodo := pin_periodo * 100 + pin_mes;
        CASE
            WHEN ( pin_tipo = 1 ) THEN
                v_inventario := '01,02,99';/*FORMATO 3.7 - DETALLE DEL SALDO DE LA CUENTA 20 - MERCADERIAS Y DE LA CUENTA 21 - PRODUCTOS TERMINADOS */
                v_titulo := '20 y 21';
            WHEN ( pin_tipo = 2 ) THEN
                v_inventario := '03';/*FORMATO 3.7 - DETALLE DEL SALDO DE LA CUENTA 24 - MATERIAS PRIMAS'*/
                v_titulo := '24';
            WHEN ( pin_tipo = 3 ) THEN
                v_inventario := '04';/*FORMATO 3.7 - DETALLE DEL SALDO DE LA CUENTA 25 - ENVASES Y EMBALAJES */
                v_titulo := '25';
            WHEN ( pin_tipo = 4 ) THEN
                v_inventario := '05';/*FORMATO 3.7 - DETALLE DEL SALDO DE LA CUENTA 26 - SUMINISTROS DIVERSOS */
                v_titulo := '26';
            ELSE
                v_titulo := ' ';
                v_inventario := ' ';/*FORMATO 3.7 - DETALLE DEL SALDO DE LA CUENTA*/
        END CASE;

        SELECT
            c.tipinv,
            t.codsunat AS codtinvsunat,
            t.dtipinv,
            c.codart,
            a.descri   AS desart,
            u.coduni,
            u.codsunat AS codunisunat,
            c.cantid,
            CASE
                WHEN c.cantid IS NULL
                     OR c.cantid = 0 THEN
                    0
                ELSE
                    c.costo01 / c.cantid
            END        AS cosuni01,
            CASE
                WHEN c.cantid IS NULL
                     OR c.cantid = 0 THEN
                    0
                ELSE
                    c.costo02 / c.cantid
            END        AS cosuni02,
            c.costo01,
            c.costo02
        BULK COLLECT
        INTO v_table
        FROM
            articulos_costo c
            LEFT OUTER JOIN t_inventario    t ON t.id_cia = c.id_cia
                                              AND t.tipinv = c.tipinv
            LEFT OUTER JOIN articulos       a ON a.id_cia = c.id_cia
                                           AND a.tipinv = c.tipinv
                                           AND a.codart = c.codart
            LEFT OUTER JOIN unidad          u ON u.id_cia = a.id_cia
                                        AND u.coduni = a.coduni
        WHERE
                c.id_cia = pin_id_cia
            AND t.codsunat IN (
                SELECT
                    *
                FROM
                    TABLE ( convert_in(v_inventario) )
            )
            AND c.periodo = v_periodo
            AND c.costo01 <> 0
        ORDER BY
            t.codsunat,
            c.tipinv,
            c.codart;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_estado_saldo;

    FUNCTION sp_estado_saldo2 (
        pin_id_cia  NUMBER,
        pin_tipo    INTEGER,
        pin_periodo INTEGER,
        pin_mes     INTEGER
    ) RETURN datatable_estado_saldo2
        PIPELINED
    AS
        v_table      datatable_estado_saldo2;
        v_inventario VARCHAR2(200);
        v_titulo     VARCHAR2(20 CHAR);
        v_periodo    NUMBER;
    BEGIN
        v_periodo := pin_periodo * 100 + pin_mes;
        CASE
            WHEN ( pin_tipo = 1 ) THEN
                v_inventario := '01,02,99';/*FORMATO 3.7 - DETALLE DEL SALDO DE LA CUENTA 20 - MERCADERIAS Y DE LA CUENTA 21 - PRODUCTOS TERMINADOS */
                v_titulo := '20 y 21';
            WHEN ( pin_tipo = 2 ) THEN
                v_inventario := '03';/*FORMATO 3.7 - DETALLE DEL SALDO DE LA CUENTA 24 - MATERIAS PRIMAS'*/
                v_titulo := '24';
            WHEN ( pin_tipo = 3 ) THEN
                v_inventario := '04';/*FORMATO 3.7 - DETALLE DEL SALDO DE LA CUENTA 25 - ENVASES Y EMBALAJES */
                v_titulo := '25';
            WHEN ( pin_tipo = 4 ) THEN
                v_inventario := '05';/*FORMATO 3.7 - DETALLE DEL SALDO DE LA CUENTA 26 - SUMINISTROS DIVERSOS */
                v_titulo := '26';
            ELSE
                v_titulo := ' ';
                v_inventario := ' ';/*FORMATO 3.7 - DETALLE DEL SALDO DE LA CUENTA*/
        END CASE;

        SELECT
            v_titulo,
            CASE
                WHEN pin_tipo = 1 THEN
                    upper(p20.nombre)
                    || ' Y '
                    || upper(p21.nombre)
                ELSE
                    upper(p.nombre)
            END        AS destitulo,
            c.tipinv,
            t.codsunat AS codtinvsunat,
            t.dtipinv,
            c.codart,
            a.descri   AS desart,
            u.coduni,
            u.codsunat AS codunisunat,
            c.cantid,
            CASE
                WHEN c.cantid IS NULL
                     OR c.cantid = 0 THEN
                    0
                ELSE
                    c.costo01 / c.cantid
            END        AS cosuni01,
            CASE
                WHEN c.cantid IS NULL
                     OR c.cantid = 0 THEN
                    0
                ELSE
                    c.costo02 / c.cantid
            END        AS cosuni02,
            c.costo01,
            c.costo02
        BULK COLLECT
        INTO v_table
        FROM
            articulos_costo c
            LEFT OUTER JOIN pcuentas        p ON p.id_cia = c.id_cia
                                          AND p.cuenta = v_titulo
            LEFT OUTER JOIN pcuentas        p20 ON p20.id_cia = c.id_cia
                                            AND p20.cuenta = '20'
            LEFT OUTER JOIN pcuentas        p21 ON p21.id_cia = c.id_cia
                                            AND p21.cuenta = '21'
            LEFT OUTER JOIN t_inventario    t ON t.id_cia = c.id_cia
                                              AND t.tipinv = c.tipinv
            LEFT OUTER JOIN articulos       a ON a.id_cia = c.id_cia
                                           AND a.tipinv = c.tipinv
                                           AND a.codart = c.codart
            LEFT OUTER JOIN unidad          u ON u.id_cia = a.id_cia
                                        AND u.coduni = a.coduni
        WHERE
                c.id_cia = pin_id_cia
            AND t.codsunat IN (
                SELECT
                    *
                FROM
                    TABLE ( convert_in(v_inventario) )
            )
            AND c.periodo = v_periodo
            AND c.costo01 <> 0
        ORDER BY
            t.codsunat,
            c.tipinv,
            c.codart;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_estado_saldo2;

    FUNCTION sp_cajban_saldo (
        pin_id_cia  NUMBER,
        pin_codban  VARCHAR2,
        pin_periodo INTEGER,
        pin_mes     INTEGER
    ) RETURN datatable_cajban_saldo
        PIPELINED
    AS
        v_table  datatable_cajban_saldo;
        v_titulo VARCHAR2(20 CHAR) := '10';
    BEGIN
        SELECT
            t.cuenta,
            t.nombre,
            t.codban,
            tb.codsunat               AS codbansunat,
            tb.cuenta                 AS numero_cuenta,
            tm.codmon                 AS tipmon,
            tm.codsunat               AS tipmonsunat,
            CASE
                WHEN tm.codmon = 'PEN' THEN
                    t.deudor01
                ELSE
                    t.deudor02
            END                       AS deudor,
            CASE
                WHEN tm.codmon = 'PEN' THEN
                    t.acreedor01
                ELSE
                    t.acreedor02
            END                       AS acreedor,
            t.deudor01 - t.acreedor01 AS saldo_pen,
            t.deudor02 - t.acreedor02 AS saldo_usd
        BULK COLLECT
        INTO v_table
        FROM
            (
                SELECT
                    p.cuenta,
                    p.nombre,
                    p.moneda01 AS tipmon,
                    pc.vstrg   AS codban,
                    SUM(
                        CASE
                            WHEN m.debe01 IS NULL THEN
                                0
                            ELSE
                                m.debe01
                        END
                    )          AS deudor01,
                    SUM(
                        CASE
                            WHEN m.haber01 IS NULL THEN
                                0
                            ELSE
                                m.haber01
                        END
                    )          AS acreedor01,
                    SUM(
                        CASE
                            WHEN m.debe02 IS NULL THEN
                                0
                            ELSE
                                m.debe02
                        END
                    )          AS deudor02,
                    SUM(
                        CASE
                            WHEN m.haber02 IS NULL THEN
                                0
                            ELSE
                                m.haber02
                        END
                    )          AS acreedor02
                FROM
                         pcuentas p
                    INNER JOIN pcuentas_clase pc ON pc.id_cia = p.id_cia
                                                    AND pc.cuenta = p.cuenta
                                                    AND pc.clase = 2  /*2-caja bancos - cuenta corriente*/
                                                    AND pc.swflag = 'S'
                    LEFT OUTER JOIN movimientos    m ON m.id_cia = p.id_cia
                                                     AND m.periodo = pin_periodo
                                                     AND m.mes <= pin_mes
                                                     AND m.cuenta = p.cuenta
                WHERE
                    p.id_cia = pin_id_cia
                GROUP BY
                    p.cuenta,
                    p.nombre,
                    p.moneda01,
                    pc.vstrg
            )       t
            LEFT OUTER JOIN tbancos tb ON tb.id_cia = pin_id_cia
                                          AND tb.codban = t.codban
            LEFT OUTER JOIN tmoneda tm ON tm.id_cia = pin_id_cia
                                          AND tm.codmon = t.tipmon;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_cajban_saldo;

END;

/

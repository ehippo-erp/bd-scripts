--------------------------------------------------------
--  DDL for Package Body PACK_ANALITICA_CUENTAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_ANALITICA_CUENTAS" AS

    FUNCTION sp_detallado_movimientos (
        pin_id_cia  IN INTEGER,
        pin_periodo IN INTEGER,
        pin_mes     IN INTEGER,
        pin_codtana IN INTEGER,
        pin_codigo  IN VARCHAR2
    ) RETURN datatable_detallado_movimientos
        PIPELINED
    AS

        v_n01    INTEGER := 0;
        v_n02    INTEGER := 0;
        v_n03    INTEGER := 0;
        v_nivel1 INTEGER := 0;
        v_nivel2 INTEGER := 0;
        v_nivel3 INTEGER := 0;
        v_table  datatable_detallado_movimientos;
    BEGIN
        BEGIN
            SELECT
                ventero
            INTO v_n01
            FROM
                factor
            WHERE
                    id_cia = pin_id_cia
                AND codfac = 200;

        EXCEPTION
            WHEN no_data_found THEN
                v_n01 := 0;
        END;

        BEGIN
            SELECT
                ventero
            INTO v_n02
            FROM
                factor
            WHERE
                    id_cia = pin_id_cia
                AND codfac = 201;

        EXCEPTION
            WHEN no_data_found THEN
                v_n02 := 0;
        END;

        BEGIN
            SELECT
                ventero
            INTO v_n03
            FROM
                factor
            WHERE
                    id_cia = pin_id_cia
                AND codfac = 202;

        EXCEPTION
            WHEN no_data_found THEN
                v_n03 := 0;
        END;

        v_nivel1 := v_n01;
        v_nivel2 := v_n01 + v_n02;
        v_nivel3 := v_n01 + v_n02 + v_n03;
        FOR i IN (
            SELECT
                cuenta,
                codigo,
                tdocum,
                serie,
                numero
            FROM
                pack_reportes_analitica.sp_detalle_documento_saldo(pin_id_cia, pin_codtana, pin_periodo, pin_mes, pin_codigo)
        ) LOOP
            SELECT
                substr(p.cuenta, 1, v_nivel1)             AS n01,
                substr(p.cuenta, 1, v_nivel2)             AS n02,
                substr(p.cuenta, 1, v_nivel3)             AS n03,
                p.cuenta,
                p.nombre,
                m.codigo,
                m.concep,
                c.razonc,
                m.tdocum,
                d.descri                                  AS desdoc,
                d.abrevi,
                m.serie,
                m.numero,
                CAST(m.serie || m.numero AS VARCHAR2(30)) AS xnrodoc,
                m.debe01,
                m.haber01,
                m.debe02,
                m.haber02,
                m.libro,
                l.descri                                  AS deslib,
                m.asiento,
                m.fecha,
                m.periodo,
                m.mes,
                m.item,
                m.sitem,
                0                                         AS saldoc
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
                LEFT OUTER JOIN tdocume   d ON d.id_cia = m.id_cia
                                             AND d.codigo = m.tdocum
                LEFT OUTER JOIN tlibro    l ON l.id_cia = m.id_cia
                                            AND l.codlib = m.libro
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

    END sp_detallado_movimientos;

    FUNCTION sp_detallado_movimientos_tsi (
        pin_id_cia  INTEGER,
        pin_periodo INTEGER,
        pin_mes     INTEGER,
        pin_codtana VARCHAR2,
        pin_codigo  VARCHAR2
    ) RETURN datatable_detallado_movimientos_tsi
        PIPELINED
    AS

        v_n01    INTEGER := 0;
        v_n02    INTEGER := 0;
        v_n03    INTEGER := 0;
        v_nivel1 INTEGER := 0;
        v_nivel2 INTEGER := 0;
        v_nivel3 INTEGER := 0;
        v_table  datatable_detallado_movimientos_tsi;
    BEGIN
        BEGIN
            SELECT
                ventero
            INTO v_n01
            FROM
                factor
            WHERE
                    id_cia = pin_id_cia
                AND codfac = 200;

        EXCEPTION
            WHEN no_data_found THEN
                v_n01 := 0;
        END;

        BEGIN
            SELECT
                ventero
            INTO v_n02
            FROM
                factor
            WHERE
                    id_cia = pin_id_cia
                AND codfac = 201;

        EXCEPTION
            WHEN no_data_found THEN
                v_n02 := 0;
        END;

        BEGIN
            SELECT
                ventero
            INTO v_n03
            FROM
                factor
            WHERE
                    id_cia = pin_id_cia
                AND codfac = 202;

        EXCEPTION
            WHEN no_data_found THEN
                v_n03 := 0;
        END;

        v_nivel1 := v_n01;
        v_nivel2 := v_n01 + v_n02;
        v_nivel3 := v_n01 + v_n02 + v_n03;
        SELECT
            substr(p.cuenta, 1, v_nivel1)                             AS n01,
            substr(p.cuenta, 1, v_nivel2)                             AS n02,
            substr(p.cuenta, 1, v_nivel3)                             AS n03,
            p.cuenta,
            p.nombre,
            m.codigo,
            m.concep,
            c.tident,
            i.abrevi                                                  AS abrent,
            c.dident,
            c.razonc,
            m.tdocum,
            d.descri                                                  AS desdoc,
            d.abrevi,
            m.serie,
            m.numero,
            CAST(m.serie || m.numero AS VARCHAR2(30))                 AS xnrodoc,
            m.debe01,
            m.haber01,
            m.debe02,
            m.haber02,
            m.libro,
            l.descri                                                  AS deslib,
            m.asiento,
            m.fecha,
            m.periodo,
            m.mes,
            m.item,
            m.sitem,
            sp_saldo_analitica(pin_id_cia, pin_periodo, pin_mes, p.codtana, p.cuenta,
                               m.codigo, m.tdocum, m.serie, m.numero) AS saldoc
        BULK COLLECT
        INTO v_table
        FROM
                 movimientos m
            INNER JOIN pcuentas  p ON p.id_cia = m.id_cia
                                     AND p.cuenta = m.cuenta
            LEFT OUTER JOIN cliente   c ON c.id_cia = p.id_cia
                                         AND m.codigo = c.codcli
            LEFT OUTER JOIN tdocume   d ON d.id_cia = p.id_cia
                                         AND m.tdocum = d.codigo
            LEFT OUTER JOIN tlibro    l ON l.id_cia = p.id_cia
                                        AND m.libro = l.codlib
            LEFT OUTER JOIN identidad i ON i.id_cia = c.id_cia
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
            AND ( pin_codigo = '-1'
                  OR m.codigo = pin_codigo )
        ORDER BY
            1,
            2,
            3,
            p.cuenta,
            p.nombre,
            m.codigo,
            m.tdocum,
            m.serie,
            m.numero,
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
    END sp_detallado_movimientos_tsi;

    FUNCTION sp_saldo (
        pin_id_cia  IN INTEGER,
        pin_periodo IN INTEGER,
        pin_mes     IN INTEGER,
        pin_codtana IN INTEGER,
        pin_codigo  IN VARCHAR2
    ) RETURN datatable_saldo
        PIPELINED
    AS
        v_table datatable_saldo;
    BEGIN
        SELECT
            a.n01,
            a.n02,
            a.n03,
            a.cuenta,
            a.nombre,
            a.codigo,
            a.razonc,
            a.dident,
            a.tdocum,
            a.desdoc,
            a.abrevi,
            a.serie,
            a.numero,
            a.tipdoc,
            a.femisi,
            a.fvenci,
            a.referencia,
            a.debe01,
            a.haber01,
            ( a.debe01 - a.haber01 ) AS saldo01,
            a.debe02,
            a.haber02,
            ( a.debe02 - a.haber02 ) AS saldo02,
            CASE
                WHEN ( a.debe01 - a.haber01 ) > 0 THEN
                    abs(a.debe01 - a.haber01)
                ELSE
                    0
            END                      AS debe01sal,
            CASE
                WHEN ( a.debe01 - a.haber01 ) < 0 THEN
                    abs(a.debe01 - a.haber01)
                ELSE
                    0
            END                      AS haber01sal,
            CASE
                WHEN ( a.debe02 - a.haber02 ) > 0 THEN
                    abs(a.debe02 - a.haber02)
                ELSE
                    0
            END                      AS debe02sal,
            CASE
                WHEN ( a.debe02 - a.haber02 ) < 0 THEN
                    abs(a.debe02 - a.haber02)
                ELSE
                    0
            END                      AS haber02sal
        BULK COLLECT
        INTO v_table
        FROM
            TABLE ( sp00_select_analitica(pin_id_cia, pin_periodo, pin_mes, pin_codtana, pin_codigo) ) a
        ORDER BY
            a.cuenta,
            a.nombre,
            a.codigo,
            a.tdocum,
            a.serie,
            a.numero,
            a.tipdoc;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_saldo;

    PROCEDURE sp_actualiza_saldos_det (
        pin_id_cia  IN INTEGER,
        pin_periodo IN INTEGER,
        pin_mes     IN INTEGER,
        pin_codtana IN INTEGER,
        pin_cuenta  IN VARCHAR2,
        pin_codigo  IN VARCHAR2,
        pin_tdocum  IN VARCHAR2,
        pin_serie   IN VARCHAR2,
        pin_numero  IN VARCHAR2
    ) AS

        CURSOR numero IS
        SELECT
            n.id_numero
        FROM
            numero n
        WHERE
            n.id_numero = pin_mes
            OR ( pin_mes = - 1
                 AND n.id_numero BETWEEN 0 AND 12 );

    BEGIN
        DELETE FROM saldos_tanalitica s
        WHERE
                s.id_cia = pin_id_cia
            AND s.periodo = pin_periodo
            AND s.mes = pin_mes
            AND ( ( pin_codtana = - 1
                    AND ( pin_cuenta IS NULL
                          OR pin_cuenta = '-1'
                          OR s.cuenta = pin_cuenta ) )
                  OR ( pin_codtana > - 1
                       AND ( ( pin_cuenta IS NULL
                               OR pin_cuenta = '-1' )
                             AND EXISTS (
                SELECT
                    c.cuenta
                FROM
                    pcuentas c
                WHERE
                        c.id_cia = pin_id_cia
                    AND c.cuenta = s.cuenta
                    AND c.codtana = pin_codtana
            )
                             OR s.cuenta = pin_cuenta ) ) )
            AND ( ( pin_codigo IS NULL
                    OR pin_codigo = '-1' )
                  OR s.codigo = pin_codigo )
            AND ( ( pin_tdocum IS NULL
                    OR pin_tdocum = '-1' )
                  OR s.tdocum = pin_tdocum )
            AND ( ( pin_serie IS NULL
                    OR pin_serie = '-1' )
                  OR s.serie = pin_serie )
            AND ( ( pin_numero IS NULL
                    OR pin_numero = '-1' )
                  OR s.numero = pin_numero );

        COMMIT;
        FOR num IN numero LOOP
            INSERT INTO saldos_tanalitica
                SELECT
                    m.id_cia,
                    m.periodo,
                    num.id_numero,
                    m.cuenta,
                    c.codtana,
                    m.codigo,
                    m.tdocum,
                    m.serie,
                    m.numero,
                    SUM(
                        CASE
                            WHEN debe01 IS NULL THEN
                                0
                            ELSE
                                debe01
                        END
                    ),
                    SUM(
                        CASE
                            WHEN debe02 IS NULL THEN
                                0
                            ELSE
                                debe02
                        END
                    ),
                    SUM(
                        CASE
                            WHEN haber01 IS NULL THEN
                                0
                            ELSE
                                haber01
                        END
                    ),
                    SUM(
                        CASE
                            WHEN haber02 IS NULL THEN
                                0
                            ELSE
                                haber02
                        END
                    )
                FROM
                         movimientos m
                    INNER JOIN pcuentas c ON c.id_cia = m.id_cia
                                             AND c.cuenta = m.cuenta
                                             AND ( pin_codtana = - 1
                                                   OR c.codtana = pin_codtana )
                WHERE
                        m.id_cia = pin_id_cia
                    AND ( m.periodo = pin_periodo )
                    AND ( m.mes <= pin_mes )
                    AND  /*(STRLEN(M.CODIGO)>=1) AND */ ( ( m.cuenta IS NOT NULL )
                          AND ( ( pin_cuenta IS NULL )
                                OR ( upper(pin_cuenta) = '-1' )
                                OR ( m.cuenta = pin_cuenta ) ) )
                    AND ( ( m.codigo IS NOT NULL )
                          AND ( ( pin_codigo IS NULL )
                                OR ( upper(pin_codigo) = '-1' )
                                OR ( m.codigo = pin_codigo ) ) )
                    AND ( ( m.tdocum IS NOT NULL )
                          AND ( ( pin_tdocum IS NULL )
                                OR ( upper(pin_tdocum) = '-1' )
                                OR ( m.tdocum = pin_tdocum ) ) )
                    AND ( ( m.serie IS NOT NULL )
                          AND ( ( pin_serie IS NULL )
                                OR ( upper(pin_serie) = '-1' )
                                OR ( m.serie = pin_serie ) ) )
                    AND ( ( m.numero IS NOT NULL )
                          AND ( ( pin_numero IS NULL )
                                OR ( upper(pin_numero) = '-1' )
                                OR ( m.numero = pin_numero ) ) )
                GROUP BY
                    m.id_cia,
                    m.periodo,
                    num.id_numero,
                    m.cuenta,
                    c.codtana,
                    m.codigo,
                    m.tdocum,
                    m.serie,
                    m.numero
                HAVING ( ( SUM(
                    CASE
                        WHEN m.debe01 IS NULL THEN
                            0
                        ELSE
                            m.debe01
                    END
                ) <> SUM(
                    CASE
                        WHEN m.haber01 IS NULL THEN
                            0
                        ELSE
                            m.haber01
                    END
                ) )
                         OR ( SUM(
                    CASE
                        WHEN m.debe02 IS NULL THEN
                            0
                        ELSE
                            m.debe02
                    END
                ) <> SUM(
                    CASE
                        WHEN m.haber02 IS NULL THEN
                            0
                        ELSE
                            m.haber02
                    END
                ) ) );

            COMMIT;
        END LOOP;

    END sp_actualiza_saldos_det;

    PROCEDURE sp_actualiza_saldos (
        pin_id_cia  IN INTEGER,
        pin_periodo IN INTEGER,
        pin_mes     IN INTEGER,
        pin_codtana IN INTEGER,
        pin_codigo  IN VARCHAR2
    ) AS

        CURSOR numero IS
        SELECT
            n.id_numero
        FROM
            numero n
        WHERE
            n.id_numero = pin_mes
            OR ( pin_mes = - 1
                 AND n.id_numero BETWEEN 0 AND 12 );

--        pin_cuenta VARCHAR2(10) := '-1';
    BEGIN
    -- ELIMINANDO REGISTROS SALDOS_TANALITICA 
        DELETE FROM saldos_tanalitica s
        WHERE
                s.id_cia = pin_id_cia
            AND s.periodo = pin_periodo
            AND s.mes = pin_mes
            AND ( pin_codtana = - 1
                  OR ( pin_codtana > - 1
                       AND EXISTS (
                SELECT
                    c.cuenta
                FROM
                    pcuentas c
                WHERE
                        c.id_cia = pin_id_cia
                    AND c.cuenta = s.cuenta
                    AND c.codtana = pin_codtana
            ) ) )
            AND ( ( pin_codigo IS NULL
                    OR pin_codigo = '-1' )
                  OR s.codigo = pin_codigo );

        COMMIT;
    -- GENERANDO NUEVOS REGISTROS SALDOS_TANALITICA 
        FOR num IN numero LOOP
            INSERT INTO saldos_tanalitica
                SELECT
                    m.id_cia,
                    m.periodo,
                    num.id_numero,
                    m.cuenta,
                    c.codtana,
                    m.codigo,
                    m.tdocum,
                    m.serie,
                    m.numero,
                    SUM(
                        CASE
                            WHEN debe01 IS NULL THEN
                                0
                            ELSE
                                debe01
                        END
                    ),
                    SUM(
                        CASE
                            WHEN debe02 IS NULL THEN
                                0
                            ELSE
                                debe02
                        END
                    ),
                    SUM(
                        CASE
                            WHEN haber01 IS NULL THEN
                                0
                            ELSE
                                haber01
                        END
                    ),
                    SUM(
                        CASE
                            WHEN haber02 IS NULL THEN
                                0
                            ELSE
                                haber02
                        END
                    )
                FROM
                         movimientos m
                    INNER JOIN pcuentas c ON c.id_cia = m.id_cia
                                             AND c.cuenta = m.cuenta
                                             AND ( pin_codtana = - 1
                                                   OR c.codtana = pin_codtana )
                WHERE
                        m.id_cia = pin_id_cia
                    AND m.periodo = pin_periodo
                    AND m.mes <= pin_mes
                    AND ( pin_codigo IS NULL
                          OR pin_codigo = '-1'
                          OR m.codigo = pin_codigo )
                GROUP BY
                    m.id_cia,
                    m.periodo,
                    num.id_numero,
                    m.cuenta,
                    c.codtana,
                    m.codigo,
                    m.tdocum,
                    m.serie,
                    m.numero
                HAVING ( ( SUM(
                    CASE
                        WHEN m.debe01 IS NULL THEN
                            0
                        ELSE
                            m.debe01
                    END
                ) <> SUM(
                    CASE
                        WHEN m.haber01 IS NULL THEN
                            0
                        ELSE
                            m.haber01
                    END
                ) )
                         OR ( SUM(
                    CASE
                        WHEN m.debe02 IS NULL THEN
                            0
                        ELSE
                            m.debe02
                    END
                ) <> SUM(
                    CASE
                        WHEN m.haber02 IS NULL THEN
                            0
                        ELSE
                            m.haber02
                    END
                ) ) );

            COMMIT;
        END LOOP;

    END sp_actualiza_saldos;

    FUNCTION sp_resumen_codigo (
        pin_id_cia  IN INTEGER,
        pin_periodo IN INTEGER,
        pin_mes     IN INTEGER,
        pin_codtana IN INTEGER,
        pin_codigo  IN VARCHAR2,
        pin_cheack  IN INTEGER
    ) RETURN datatable_resumen_codigo
        PIPELINED
    AS
        v_table datatable_resumen_codigo;
    BEGIN
        SELECT
            tt.codtana,
            tt.descri            AS destana,
            t.codigo,
            t.razonc,
            t.debe01             AS debe01,
            t.debe02             AS debe02,
            t.haber01            AS haber01,
            t.haber02            AS haber02,
            t.debe01 - t.haber01 AS saldo01,
            t.debe02 - t.haber02 AS saldo02
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
                    AND p.codtana = pin_codtana
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
            )          t
            LEFT OUTER JOIN tanalitica tt ON tt.id_cia = pin_id_cia
                                             AND tt.codtana = pin_codtana
        ORDER BY
            t.cuenta,
            t.codigo;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_resumen_codigo;

    FUNCTION sp_select_analitica (
        pin_id_cia  INTEGER,
        pin_periodo INTEGER,
        pin_mes     INTEGER,
        pin_codtana VARCHAR2,
        pin_codigo  VARCHAR2
    ) RETURN datatable_analitica_de_cuentas
        PIPELINED
    AS

        r_analitica datarecord_analitica_de_cuentas := datarecord_analitica_de_cuentas(NULL, NULL, NULL, NULL, NULL,
                                                                                      NULL, NULL, NULL, NULL, NULL,
                                                                                      NULL, NULL, NULL, NULL, NULL,
                                                                                      NULL, NULL, NULL, NULL, NULL,
                                                                                      NULL);
        v_n01       INTEGER := 0;
        v_n02       INTEGER := 0;
        v_n03       INTEGER := 0;
        v_nivel1    INTEGER := 0;
        v_nivel2    INTEGER := 0;
        v_nivel3    INTEGER := 0;
    BEGIN
        FOR registro IN (
            SELECT
                substr(p.cuenta, 1, 2)  AS n01,
                substr(p.cuenta, 1, 6)  AS n02,
                substr(p.cuenta, 1, 12) AS n03,
                p.cuenta,
                p.nombre,
                m.codigo,
                c.razonc,
                c.dident,
                m.tdocum,
                MAX(m.fecha)            AS fecha,
                d.descri                AS desdoc,
                d.abrevi,
                m.serie,
                m.numero,
                tc.tipdoc,
                pc.swflag,
                SUM(m.debe01)           AS debe01,
                SUM(m.haber01)          AS haber01,
                SUM(m.debe02)           AS debe02,
                SUM(m.haber02)          AS haber02
            FROM
                     movimientos m
                INNER JOIN pcuentas       p ON p.id_cia = m.id_cia
                                         AND p.cuenta = m.cuenta
                LEFT JOIN cliente        c ON c.id_cia = m.id_cia
                                       AND c.codcli = m.codigo
                LEFT OUTER JOIN tdocume        d ON d.id_cia = m.id_cia
                                             AND d.codigo = m.tdocum
                LEFT OUTER JOIN tdoccobranza   tc ON tc.id_cia = m.id_cia
                                                   AND tc.codsunat IS NOT NULL
                                                   AND tc.codsunat = m.tdocum
                LEFT OUTER JOIN pcuentas_clase pc ON pc.id_cia = m.id_cia
                                                     AND pc.cuenta = m.cuenta
                                                     AND pc.clase = 1
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
                AND ( pin_codigo = '-1'
                      OR m.codigo = pin_codigo )
            GROUP BY
                p.cuenta,
                p.nombre,
                m.codigo,
                c.razonc,
                c.dident,
                m.tdocum,
                d.descri,
                d.abrevi,
                m.serie,
                m.numero,
                tc.tipdoc,
                pc.swflag
            HAVING ( ( SUM(m.debe01) - SUM(m.haber01) ) <> 0 )
                   OR ( ( ( SUM(m.debe02) - SUM(m.haber02) ) <> 0 )
                        AND ( upper(pc.swflag) = 'S' ) )
        ) LOOP
            r_analitica.tipdoc := registro.tipdoc;
            r_analitica.dident := registro.dident;
            r_analitica.femisi := NULL;
            r_analitica.fvenci := NULL;
            r_analitica.referencia := NULL;
            IF ( registro.tipdoc > 0 ) THEN
                BEGIN
                    SELECT
                        femisi,
                        fvenci,
                        refere01
                        || ' '
                        || refere02
                    INTO
                        r_analitica.femisi,
                        r_analitica.fvenci,
                        r_analitica.referencia
                    FROM
                        dcta100
                    WHERE
                            id_cia = pin_id_cia
                        AND codcli = registro.codigo
                        AND tipdoc = registro.tipdoc
                        AND serie = registro.serie
                        AND numero = registro.numero
                    FETCH FIRST 1 ROW ONLY;

                EXCEPTION
                    WHEN no_data_found THEN
                        r_analitica.femisi := NULL;
                        r_analitica.fvenci := NULL;
                        r_analitica.referencia := NULL;
                END;
            END IF;

            IF (
                ( registro.tdocum IS NOT NULL )
                AND ( r_analitica.femisi IS NULL )
            ) THEN
                BEGIN
                    SELECT
                        femisi,
                        fvenci,
                        concep
                    INTO
                        r_analitica.femisi,
                        r_analitica.fvenci,
                        r_analitica.referencia
                    FROM
                        compr010
                    WHERE
                            id_cia = pin_id_cia
                        AND codpro = registro.codigo
                        AND tdocum = registro.tdocum
                        AND nserie || numero = registro.serie || registro.numero
                    FETCH FIRST 1 ROW ONLY;

                EXCEPTION
                    WHEN no_data_found THEN
                        r_analitica.femisi := NULL;
                        r_analitica.fvenci := NULL;
                        r_analitica.referencia := NULL;
                END;

                IF ( r_analitica.femisi IS NULL ) THEN
                    BEGIN
                        SELECT
                            femisi,
                            fvenci,
                            refere01
                            || ' '
                            || refere02
                        INTO
                            r_analitica.femisi,
                            r_analitica.fvenci,
                            r_analitica.referencia
                        FROM
                            prov100
                        WHERE
                                id_cia = pin_id_cia
                            AND codcli = registro.codigo
                            AND tipdoc = registro.tdocum
                            AND docume = registro.serie || registro.numero
                        FETCH FIRST 1 ROW ONLY;

                    EXCEPTION
                        WHEN no_data_found THEN
                            r_analitica.femisi := NULL;
                            r_analitica.fvenci := NULL;
                            r_analitica.referencia := NULL;
                    END;

                END IF;

                IF ( r_analitica.femisi IS NULL ) THEN
                    r_analitica.femisi := registro.fecha;
                END IF;

            END IF;

            r_analitica.n01 := registro.n01;
            r_analitica.n02 := registro.n02;
            r_analitica.n03 := registro.n03;
            r_analitica.cuenta := registro.cuenta;
            r_analitica.nombre := registro.nombre;
            r_analitica.codigo := registro.codigo;
            r_analitica.razonc := registro.razonc;
            r_analitica.tdocum := registro.tdocum;
            r_analitica.desdoc := registro.desdoc;
            r_analitica.abrevi := registro.abrevi;
            r_analitica.serie := registro.serie;
            r_analitica.numero := registro.numero;
            r_analitica.debe01 := registro.debe01;
            r_analitica.haber01 := registro.haber01;
            r_analitica.debe02 := registro.debe02;
            r_analitica.haber02 := registro.haber02;
            PIPE ROW ( r_analitica );
        END LOOP;
    END sp_select_analitica;

END;

/

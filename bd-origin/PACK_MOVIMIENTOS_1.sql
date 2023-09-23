--------------------------------------------------------
--  DDL for Package Body PACK_MOVIMIENTOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_MOVIMIENTOS" AS

    FUNCTION sp_sel_saldo_cuenta4 (
        pin_id_cia  IN NUMBER,
        pin_cuenta  IN VARCHAR2,
        pin_codigo  IN VARCHAR2,
        pin_tdocum  IN VARCHAR2,
        pin_periodo IN INTEGER,
        pin_mes     IN INTEGER,
        pin_serie   IN VARCHAR2,
        pin_numero  IN VARCHAR2
    ) RETURN tbl_sp_sel_saldo_cuenta4
        PIPELINED
    AS

        rec rec_sp_sel_saldo_cuenta4 := rec_sp_sel_saldo_cuenta4(NULL, NULL, NULL, NULL, NULL,
                                                                NULL, NULL, NULL, NULL, NULL,
                                                                NULL, NULL, NULL, NULL, NULL);
    BEGIN
        FOR i IN (
            SELECT
                m.cuenta,
                p.nombre,
                m.codigo,
                m.tdocum,
                m.serie,
                m.numero,
                SUM(m.debe01) - SUM(m.haber01) AS saldo01,
                SUM(m.debe02) - SUM(m.haber02) AS saldo02,
                c.razonc                       AS razon,
                d.abrevi,
                p.moneda01                     AS moneda,
                mo.simbolo
            FROM
                movimientos m
                LEFT OUTER JOIN pcuentas    p ON p.id_cia = m.id_cia
                                              AND p.cuenta = m.cuenta
                LEFT OUTER JOIN tdocume     d ON d.id_cia = m.id_cia
                                             AND d.codigo = m.tdocum
                LEFT OUTER JOIN cliente     c ON c.id_cia = m.id_cia
                                             AND c.codcli = m.codigo
                LEFT OUTER JOIN tmoneda     mo ON mo.id_cia = p.id_cia
                                              AND mo.codmon = p.moneda01
            WHERE
                    m.id_cia = pin_id_cia
                AND m.periodo = pin_periodo
                AND m.mes <= pin_mes
                AND m.cuenta = pin_cuenta
                AND ( ( pin_codigo IS NULL )
                      OR ( pin_codigo = '' )
                      OR ( m.codigo = pin_codigo ) )
                AND ( ( pin_tdocum IS NULL )
                      OR ( pin_tdocum = '' )
                      OR ( m.tdocum = pin_tdocum ) )
                AND ( ( pin_serie IS NULL )
                      OR ( pin_serie = '' )
                      OR ( m.serie = pin_serie ) )
                AND ( ( pin_numero IS NULL )
                      OR ( pin_numero = '' )
                      OR ( m.numero = pin_numero ) )
            GROUP BY
                m.cuenta,
                m.codigo,
                c.razonc,
                p.moneda01,
                mo.simbolo,
                p.nombre,
                d.abrevi,
                m.tdocum,
                m.serie,
                m.numero
            HAVING ( SUM(m.debe01) - SUM(m.haber01) <> 0 )
                   OR ( SUM(m.debe02) - SUM(m.haber02) <> 0 )
        ) LOOP
            rec.cuenta := i.cuenta;
            rec.nombre := i.nombre;
            rec.codigo := i.codigo;
            rec.tdocum := i.tdocum;
            rec.serie := i.serie;
            rec.numero := i.numero;
            rec.saldo01 := i.saldo01;
            rec.saldo02 := i.saldo02;
            rec.razon := i.razon;
            rec.abrevi := i.abrevi;
            rec.moneda := i.moneda;
            rec.simbolo := i.simbolo;
            rec.tcambio01 := 1.0;
            rec.tcambio02 := 1.0;
            rec.dh := 'D';
            IF
                ( rec.moneda = 'PEN' )
                AND ( rec.saldo01 < 0 )
            THEN
                rec.dh := 'H';
            ELSIF
                ( rec.moneda <> 'PEN' )
                AND ( rec.saldo02 < 0 )
            THEN
                rec.dh := 'H';
            END IF;

            IF
                ( rec.saldo01 <> 0 )
                AND ( rec.saldo02 <> 0 )
            THEN
                rec.tcambio01 := 1 / ( rec.saldo01 / rec.saldo02 );
            END IF;

            rec.saldo01 := abs(rec.saldo01);
            rec.saldo02 := abs(rec.saldo02);
            PIPE ROW ( rec );
        END LOOP;
    END sp_sel_saldo_cuenta4;

    FUNCTION sp_saldos_por_cuenta (
        pin_id_cia    IN NUMBER,
        pin_periodo   IN NUMBER,
        pin_mes_desde IN NUMBER,
        pin_mes_hasta IN NUMBER,
        pin_cuenta    IN VARCHAR2,
        pin_codmon    IN VARCHAR2
    ) RETURN tbl_saldos
        PIPELINED
    AS

        rec           rec_saldos := rec_saldos(NULL, NULL);
        saldoanterior NUMBER(16, 5) := 0.0;
        saldoactual   NUMBER(16, 5) := 0.0;
    BEGIN
        DECLARE BEGIN
            SELECT
                CASE
                    WHEN pin_codmon = 'PEN' THEN
                        ( SUM(debe01) - SUM(haber01) )
                    ELSE
                        SUM(debe02) - SUM(haber02)
                END AS saldo
            INTO saldoanterior
            FROM
                movimientos
            WHERE
                    id_cia = pin_id_cia
                AND periodo = pin_periodo
                AND mes < pin_mes_desde
                AND cuenta = pin_cuenta;

        EXCEPTION
            WHEN no_data_found THEN
                saldoanterior := 0;
        END;

        DECLARE BEGIN
            SELECT
                CASE
                    WHEN pin_codmon = 'PEN' THEN
                        ( SUM(debe01) - SUM(haber01) )
                    ELSE
                        SUM(debe02) - SUM(haber02)
                END AS saldo
            INTO saldoactual
            FROM
                movimientos
            WHERE
                    id_cia = pin_id_cia
                AND periodo = pin_periodo
                AND mes <= pin_mes_hasta
                AND cuenta = pin_cuenta;

        EXCEPTION
            WHEN no_data_found THEN
                saldoactual := 0;
        END;

        rec.saldoanterior := saldoanterior;
        rec.saldoactual := saldoactual;
        PIPE ROW ( rec );
    END sp_saldos_por_cuenta;

    FUNCTION sp_saldos_por_periodo_cuenta (
        pin_id_cia    IN NUMBER,
        pin_periodo   IN NUMBER,
        pin_mes_desde IN NUMBER,
        pin_mes_hasta IN NUMBER,
        pin_cuenta    IN VARCHAR2,
        pin_codmon    IN VARCHAR2
    ) RETURN datatable_saldos_periodo_cuenta
        PIPELINED
    AS

        rec           rec_saldos_periodo_cuenta := rec_saldos_periodo_cuenta(NULL, NULL, NULL, NULL, NULL);
        saldoanterior NUMBER(16, 5) := 0.0;
        saldoactual   NUMBER(16, 5) := 0.0;
    BEGIN
        FOR i IN (
            SELECT
                regexp_substr(pin_cuenta, '[^,]+', 1, level) AS cuenta
            FROM
                dual
            CONNECT BY
                regexp_substr(pin_cuenta, '[^,]+', 1, level) IS NOT NULL
        ) LOOP
            rec.cuenta := i.cuenta;
            FOR j IN pin_mes_desde..pin_mes_hasta LOOP
                rec.periodo := pin_periodo;
                rec.mes := j;
                BEGIN
                    SELECT
                        CASE
                            WHEN pin_codmon = 'PEN' THEN
                                SUM(debe01) - SUM(haber01)
                            ELSE
                                SUM(debe02) - SUM(haber02)
                        END AS saldo
                    INTO saldoanterior
                    FROM
                        movimientos
                    WHERE
                            id_cia = pin_id_cia
                        AND periodo = pin_periodo
                        AND mes < j
                        AND cuenta = i.cuenta;

                EXCEPTION
                    WHEN no_data_found THEN
                        saldoanterior := 0;
                END;

                BEGIN
                    SELECT
                        CASE
                            WHEN pin_codmon = 'PEN' THEN
                                SUM(debe01) - SUM(haber01)
                            ELSE
                                SUM(debe02) - SUM(haber02)
                        END AS saldo
                    INTO saldoactual
                    FROM
                        movimientos
                    WHERE
                            id_cia = pin_id_cia
                        AND periodo = pin_periodo
                        AND mes <= j
                        AND cuenta = i.cuenta;

                EXCEPTION
                    WHEN no_data_found THEN
                        saldoactual := 0;
                END;

                rec.saldoanterior := saldoanterior;
                rec.saldoactual := saldoactual;
                PIPE ROW ( rec );
            END LOOP;

        END LOOP;
    END sp_saldos_por_periodo_cuenta;

    FUNCTION sp_ranking_por_proveedor_daot (
        pin_id_cia     IN NUMBER,
        pin_periodo    IN NUMBER,
        pin_mes_desde  IN NUMBER,
        pin_mes_hasta  IN NUMBER,
        pin_codmon     IN VARCHAR2,
        pin_tipocompra IN NUMBER,
        pin_topmin     IN NUMBER
    ) RETURN tbl_sp_ranking_por_proveedor_daot
        PIPELINED
    AS

        rec        rec_sp_ranking_por_proveedor_daot := rec_sp_ranking_por_proveedor_daot(NULL, NULL, NULL, NULL, NULL,
                                                                                  NULL, NULL, NULL, NULL, NULL,
                                                                                  NULL, NULL, NULL, NULL, NULL,
                                                                                  NULL, NULL, NULL, NULL, NULL,
                                                                                  NULL, NULL, NULL, NULL, NULL,
                                                                                  NULL, NULL, NULL, NULL, NULL,
                                                                                  NULL, NULL, NULL);
        wstrtipven VARCHAR2(3);
    BEGIN
        FOR i IN (
            SELECT
                a1.tipo,
                a1.docume,
                t.signo,
                a1.fecha,
                t.descri    AS desdoc,
                a1.tdocum,
                a1.serie,
                a1.numero   AS numdoc,
                a1.codigo,
                a1.razon,
                c.tident,
                c.dident,
                a1.mes,
                a1.fdocum   AS femisi,
                a1.concep,
                SUM(
                    CASE
                        WHEN(a1.regcomcol BETWEEN 1 AND 3) THEN
                            (
                                CASE
                                    WHEN pin_codmon = 'PEN' THEN
                                        a1.debe01 + a1.haber01
                                    ELSE
                                        a1.debe02 + a1.haber02
                                END
                            )
                        ELSE
                            0
                    END
                ) * t.signo AS tcrefis,
                SUM(
                    CASE
                        WHEN a1.regcomcol = 4 THEN
                            (
                                CASE
                                    WHEN pin_codmon = 'PEN' THEN
                                        a1.debe01 + a1.haber01
                                    ELSE
                                        a1.debe02 + a1.haber02
                                END
                            )
                        ELSE
                            0
                    END
                ) * t.signo AS tinafecto,
                SUM(
                    CASE
                        WHEN a1.regcomcol = 5 THEN
                            (
                                CASE
                                    WHEN pin_codmon = 'PEN' THEN
                                        a1.debe01 + a1.haber01
                                    ELSE
                                        a1.debe02 + a1.haber02
                                END
                            )
                        ELSE
                            0
                    END
                ) * t.signo AS tncrefis,
                SUM(
                    CASE
                        WHEN(a1.regcomcol BETWEEN 1 AND 3) THEN
                            (
                                CASE
                                    WHEN pin_codmon = 'PEN' THEN
                                        a1.debe01 + a1.haber01
                                    ELSE
                                        a1.debe02 + a1.haber02
                                END
                            )
                        ELSE
                            0
                    END
                ) * t.signo AS tbaseimp,
                SUM(
                    CASE
                        WHEN a1.regcomcol = 6 THEN
                            (
                                CASE
                                    WHEN pin_codmon = 'PEN' THEN
                                        a1.debe01 + a1.haber01
                                    ELSE
                                        a1.debe02 + a1.haber02
                                END
                            )
                        ELSE
                            0
                    END
                ) * t.signo AS timpuesto,
                SUM(
                    CASE
                        WHEN a1.regcomcol = 9 THEN
                            (
                                CASE
                                    WHEN pin_codmon = 'PEN' THEN
                                        a1.debe01 + a1.haber01
                                    ELSE
                                        a1.debe02 + a1.haber02
                                END
                            )
                        ELSE
                            0
                    END
                ) * t.signo AS tgeneral,
                SUM(
                    CASE
                        WHEN a1.regcomcol = 9
                             AND a1.moneda = 'USD' THEN
                            a1.debe02 + a1.haber02
                        ELSE
                            0
                    END
                ) * t.signo AS tgeneral2
            FROM
                     movimientos a1
                INNER JOIN cliente                     c ON c.id_cia = a1.id_cia
                                        AND ( c.codcli = a1.codigo )
                                        AND ( ( pin_tipocompra IS NULL
                                                OR pin_tipocompra = 0 )
                                              OR ( ( pin_tipocompra = 1 )
                                                   AND c.codtpe IN ( 1, 2 ) )
                                              OR ( ( pin_tipocompra = 2 )
                                                   AND c.codtpe = 3 ) )
                LEFT OUTER JOIN tdocume                     t ON t.id_cia = a1.id_cia
                                             AND ( t.codigo = a1.tdocum )
                INNER JOIN pack_movimientos.daotprovedor_txt(pin_id_cia, pin_periodo, pin_mes_desde, pin_mes_hasta, pin_codmon,
                                                             pin_tipocompra, pin_topmin) pp ON pp.codigo = a1.codigo -- AQUI SOLO SALEN LOS CLIENTES, CON EL TOPE FIJADO
            WHERE
                    a1.id_cia = pin_id_cia
                AND ( a1.periodo = pin_periodo )
                AND ( a1.mes >= pin_mes_desde )
                AND ( a1.mes <= pin_mes_hasta )
                AND ( a1.libro = '04' )
                AND ( a1.sitem = 0 )
            GROUP BY
                a1.tipo,
                a1.docume,
                t.signo,
                t.descri,
                a1.fecha,
                a1.tdocum,
                a1.serie,
                a1.numero,
                a1.codigo,
                a1.razon,
                c.tident,
                c.dident,
                a1.mes,
                a1.fdocum,
                a1.concep
        ) LOOP
            rec.tipo := i.tipo;
            rec.docume := i.docume;
            rec.signo := i.signo;
            rec.fecha := i.fecha;
            rec.desdoc := i.desdoc;
            rec.tdocum := i.tdocum;
            rec.serie := i.serie;
            rec.numdoc := i.numdoc;
            rec.codigo := i.codigo;
            rec.razon := i.razon;
            rec.tident := i.tident;
            rec.dident := i.dident;
            rec.mes := i.mes;
            rec.femisi := i.femisi;
            rec.concep := i.concep;
            rec.tcrefis := i.tcrefis;
            rec.tinafecto := NVL(i.tinafecto,0);
            rec.tncrefis := i.tncrefis;
            rec.tbaseimp := NVL(i.tbaseimp,0);
            rec.timpuesto := NVL(i.timpuesto,0);
            rec.tgeneral := NVL(i.tgeneral,0);
            rec.tgeneral2 := NVL(i.tgeneral2,0);
            PIPE ROW ( rec );
        END LOOP;
    END sp_ranking_por_proveedor_daot;

    FUNCTION daotprovedor_txt (
        pin_id_cia     IN NUMBER,
        pin_periodo    IN NUMBER,
        pin_mes_desde  IN NUMBER,
        pin_mes_hasta  IN NUMBER,
        pin_codmon     IN VARCHAR2,
        pin_tipocompra IN NUMBER,
        pin_topmin     IN NUMBER
    ) RETURN tbl_sp_ranking_por_proveedor_daot
        PIPELINED
    AS

        rec rec_sp_ranking_por_proveedor_daot := rec_sp_ranking_por_proveedor_daot(NULL, NULL, NULL, NULL, NULL,
                                                                                  NULL, NULL, NULL, NULL, NULL,
                                                                                  NULL, NULL, NULL, NULL, NULL,
                                                                                  NULL, NULL, NULL, NULL, NULL,
                                                                                  NULL, NULL, NULL, NULL, NULL,
                                                                                  NULL, NULL, NULL, NULL, NULL,
                                                                                  NULL, NULL, NULL);
    BEGIN
        FOR i IN (
            SELECT
                t.codigo,
                t.razonc,
                t.tident,
                t.dident,
                t.codtpe,
                t.apepat,
                t.apemat,
                t.nombre,
                SUM(t.tdcrefis)   AS tdcrefis,
                SUM(t.tdinafecto) AS tdinafecto,
                SUM(t.tdncrefis)  AS tdncrefis,
                SUM(t.tdbaseimp)  AS tdbaseimp,
                SUM(t.tdimpuesto) AS tdimpuesto,
                SUM(t.tdgeneral)  AS tdgeneral,
                SUM(t.tdgeneral2) AS tdgeneral2,
                SUM(t.ttotaldaot) AS ttotaldaot
            FROM
                (
                    SELECT
                        a1.codigo,
                        c.razonc,
                        c.tident,
                        c.dident,
                        c.codtpe,
                        p.apepat,
                        p.apemat,
                        p.nombre,
                        SUM(
                            CASE
                                WHEN(a1.regcomcol BETWEEN 1 AND 3) THEN
                                    (
                                        CASE
                                            WHEN pin_codmon = 'PEN' THEN
                                                a1.debe01 + a1.haber01
                                            ELSE
                                                a1.debe02 + a1.haber02
                                        END
                                    )
                                ELSE
                                    0
                            END
                        ) * t.signo   AS tdcrefis,
                        SUM(
                            CASE
                                WHEN a1.regcomcol = 4 THEN
                                    (
                                        CASE
                                            WHEN pin_codmon = 'PEN' THEN
                                                a1.debe01 + a1.haber01
                                            ELSE
                                                a1.debe02 + a1.haber02
                                        END
                                    )
                                ELSE
                                    0
                            END
                        ) * t.signo   AS tdinafecto,
                        SUM(
                            CASE
                                WHEN a1.regcomcol = 5 THEN
                                    (
                                        CASE
                                            WHEN pin_codmon = 'PEN' THEN
                                                a1.debe01 + a1.haber01
                                            ELSE
                                                a1.debe02 + a1.haber02
                                        END
                                    )
                                ELSE
                                    0
                            END
                        ) * t.signo   AS tdncrefis,
                        SUM(
                            CASE
                                WHEN(a1.regcomcol BETWEEN 1 AND 3) THEN
                                    (
                                        CASE
                                            WHEN pin_codmon = 'PEN' THEN
                                                a1.debe01 + a1.haber01
                                            ELSE
                                                a1.debe02 + a1.haber02
                                        END
                                    )
                                ELSE
                                    0
                            END
                        ) * t.signo   AS tdbaseimp,
                        SUM(
                            CASE
                                WHEN a1.regcomcol BETWEEN 1 AND 4 THEN
                                    (
                                        CASE
                                            WHEN pin_codmon = 'PEN' THEN
                                                a1.debe01 + a1.haber01
                                            ELSE
                                                a1.debe02 + a1.haber02
                                        END
                                    )
                                ELSE
                                    0
                            END
                        ) * t.signo   AS tdneto,
                        SUM(
                            CASE
                                WHEN a1.regcomcol = 6 THEN
                                    (
                                        CASE
                                            WHEN pin_codmon = 'PEN' THEN
                                                a1.debe01 + a1.haber01
                                            ELSE
                                                a1.debe02 + a1.haber02
                                        END
                                    )
                                ELSE
                                    0
                            END
                        ) * t.signo   AS tdimpuesto,
                        SUM(
                            CASE
                                WHEN a1.regcomcol = 9 THEN
                                    (
                                        CASE
                                            WHEN pin_codmon = 'PEN' THEN
                                                a1.debe01 + a1.haber01
                                            ELSE
                                                a1.debe02 + a1.haber02
                                        END
                                    )
                                ELSE
                                    0
                            END
                        ) * t.signo   AS tdgeneral,
                        SUM(
                            CASE
                                WHEN a1.regcomcol = 9
                                     AND a1.moneda = 'USD' THEN
                                    a1.debe02 + a1.haber02
                                ELSE
                                    0
                            END
                        ) * t.signo   AS tdgeneral2,
                        ( SUM(
                            CASE
                                WHEN a1.regcomcol IN(4, 5) THEN
                                    (
                                        CASE
                                            WHEN pin_codmon = 'PEN' THEN
                                                a1.debe01 + a1.haber01
                                            ELSE
                                                a1.debe02 + a1.haber02
                                        END
                                    )
                                ELSE
                                    0
                            END
                        ) * t.signo ) + ( SUM(
                            CASE
                                WHEN(a1.regcomcol BETWEEN 1 AND 3) THEN
                                    (
                                        CASE
                                            WHEN pin_codmon = 'PEN' THEN
                                                a1.debe01 + a1.haber01
                                            ELSE
                                                a1.debe02 + a1.haber02
                                        END
                                    )
                                ELSE
                                    0
                            END
                        ) * t.signo ) AS ttotaldaot
                    FROM
                             movimientos a1
                        INNER JOIN cliente          c ON c.id_cia = a1.id_cia
                                                AND ( c.codcli = a1.codigo )
                                                AND ( ( pin_tipocompra IS NULL
                                                        OR pin_tipocompra = 0 )
                                                      OR ( ( pin_tipocompra = 1 )
                                                           AND c.codtpe IN ( 1, 2 ) )
                                                      OR ( ( pin_tipocompra = 2 )
                                                           AND c.codtpe = 3 ) )
                        LEFT OUTER JOIN cliente_tpersona p ON p.id_cia = c.id_cia
                                                              AND ( p.codcli = c.codcli )
                        LEFT OUTER JOIN tdocume          t ON t.id_cia = a1.id_cia
                                                     AND ( t.codigo = a1.tdocum )
                    WHERE
                            a1.id_cia = pin_id_cia
                        AND ( a1.periodo = pin_periodo )
                        AND ( a1.mes >= pin_mes_desde )
                        AND ( a1.mes <= pin_mes_hasta )
                        AND ( a1.libro = '04' )
                        AND ( a1.sitem = 0 )
                    GROUP BY
                        a1.codigo,
                        c.razonc,
                        c.tident,
                        c.dident,
                        c.codtpe,
                        p.apepat,
                        p.apemat,
                        p.nombre,
                        t.signo
                    ORDER BY
                        ttotaldaot DESC
                ) t
            GROUP BY
                t.codigo,
                t.razonc,
                t.tident,
                t.dident,
                t.codtpe,
                t.apepat,
                t.apemat,
                t.nombre
            HAVING
                SUM(t.ttotaldaot) > pin_topmin
        ) LOOP
            rec.codigo := i.codigo;
            rec.razon := i.razonc;
            rec.apepat := i.apepat;
            rec.apemat := i.apemat;
            rec.nombre := i.nombre;
            rec.codtpe := i.codtpe;
            rec.tident := i.tident;
            rec.dident := i.dident;
            rec.tdcrefis := i.tdcrefis;
            rec.tdinafecto := i.tdinafecto;
            rec.tdncrefis := i.tdncrefis;
            rec.tdbaseimp := i.tdbaseimp;
            rec.tdimpuesto := i.tdimpuesto;
            rec.tdgeneral := i.tdgeneral;
            rec.tdgeneral2 := i.tdgeneral2;
            PIPE ROW ( rec );
        END LOOP;

        RETURN;
    END daotprovedor_txt;

END pack_movimientos;

/

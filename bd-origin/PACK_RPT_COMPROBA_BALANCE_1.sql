--------------------------------------------------------
--  DDL for Package Body PACK_RPT_COMPROBA_BALANCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_RPT_COMPROBA_BALANCE" AS

    FUNCTION sp_buscar_317 (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER,
        pin_mes     NUMBER,
        pin_tipmon  VARCHAR2
    ) RETURN datatable_buscar_317
        PIPELINED
    AS
        v_table datatable_buscar_317;
    BEGIN
        IF pin_tipmon IS NULL OR pin_tipmon = 'PEN' THEN
            SELECT
                p1.id_cia,
                p1.cuenta      AS cuenta,
                p1.nombre      AS nombre,
                m.cuenta       AS subcuenta,
                p.nombre       AS subnombre,
                p.balancecol,
                SUM(
                    CASE
                        WHEN m.dh = 'D'
                             AND m.mes < pin_mes THEN
                            m.debe01
                        ELSE
                            0
                    END
                )              AS debeant,
                SUM(
                    CASE
                        WHEN m.dh = 'H'
                             AND m.mes < pin_mes THEN
                            m.haber01
                        ELSE
                            0
                    END
                )              AS haberant,
                SUM(
                    CASE
                        WHEN m.dh = 'D'
                             AND m.mes = pin_mes THEN
                            m.debe01
                        ELSE
                            0
                    END
                )              AS debeact,
                SUM(
                    CASE
                        WHEN m.dh = 'H'
                             AND m.mes = pin_mes THEN
                            m.haber01
                        ELSE
                            0
                    END
                )              AS haberact,
                SUM(m.debe01)  AS debeacu,
                SUM(m.haber01) AS haberacu
            BULK COLLECT
            INTO v_table
            FROM
                movimientos m
                LEFT OUTER JOIN pcuentas    p ON ( p.id_cia = m.id_cia )
                                              AND ( p.cuenta = m.cuenta )
                LEFT OUTER JOIN pcuentas    p1 ON ( p1.id_cia = m.id_cia )
                                               AND ( p1.cuenta = substr(m.cuenta, 1, 2) )
            WHERE
                    m.id_cia = pin_id_cia
                AND m.periodo = pin_periodo
                AND m.mes <= pin_mes
                AND upper(p.balance) = 'S'
            GROUP BY
                p1.id_cia,
                p1.cuenta,
                p1.nombre,
                m.cuenta,
                p.nombre,
                p.balancecol
            ORDER BY
                p1.cuenta;

            FOR registro IN 1..v_table.count LOOP
                PIPE ROW ( v_table(registro) );
            END LOOP;

            RETURN;
        ELSIF pin_tipmon = 'USD' THEN
            SELECT
                p1.id_cia,
                p1.cuenta      AS cuenta,
                p1.nombre      AS nombre,
                m.cuenta       AS subcuenta,
                p.nombre       AS subnombre,
                p.balancecol,
                SUM(
                    CASE
                        WHEN m.dh = 'D'
                             AND m.mes < pin_mes THEN
                            m.debe02
                        ELSE
                            0
                    END
                )              AS debeant,
                SUM(
                    CASE
                        WHEN m.dh = 'H'
                             AND m.mes < pin_mes THEN
                            m.haber02
                        ELSE
                            0
                    END
                )              AS haberant,
                SUM(
                    CASE
                        WHEN m.dh = 'D'
                             AND m.mes = pin_mes THEN
                            m.debe02
                        ELSE
                            0
                    END
                )              AS debeact,
                SUM(
                    CASE
                        WHEN m.dh = 'H'
                             AND m.mes = pin_mes THEN
                            m.haber02
                        ELSE
                            0
                    END
                )              AS haberact,
                SUM(m.debe02)  AS debeacu,
                SUM(m.haber02) AS haberacu
            BULK COLLECT
            INTO v_table
            FROM
                movimientos m
                LEFT OUTER JOIN pcuentas    p ON ( p.id_cia = m.id_cia )
                                              AND ( p.cuenta = m.cuenta )
                LEFT OUTER JOIN pcuentas    p1 ON ( p1.id_cia = m.id_cia )
                                               AND ( p1.cuenta = substr(m.cuenta, 1, 2) )
            WHERE
                    m.id_cia = pin_id_cia
                AND m.periodo = pin_periodo
                AND m.mes <= pin_mes
                AND upper(p.balance) = 'S'
            GROUP BY
                p1.id_cia,
                p1.cuenta,
                p1.nombre,
                m.cuenta,
                p.nombre,
                p.balancecol
            ORDER BY
                p1.cuenta;

            FOR registro IN 1..v_table.count LOOP
                PIPE ROW ( v_table(registro) );
            END LOOP;

            RETURN;
        END IF;
    END sp_buscar_317;

    FUNCTION sp_buscar_txt (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER,
        pin_mes     NUMBER,
        pin_tipmon  VARCHAR2,
        pin_codrent VARCHAR2
    ) RETURN datatable_buscar_txt
        PIPELINED
    AS
        v_table datatable_buscar_txt;
        v_rec   datarecord_buscar_txt;
    BEGIN
        FOR i IN (
            SELECT
                c.ruc,
                pc.codigo AS cuenta_sunat,
                p.balancecol,
                SUM(
                    CASE
                        WHEN m.dh = 'D'
                             AND m.mes = 0 THEN
                                CASE
                                    WHEN pin_tipmon = 'PEN' THEN
                                        m.debe01
                                    ELSE
                                        m.debe02
                                END
                        ELSE
                            0
                    END
                )         AS saldos_ini_d,
                SUM(
                    CASE
                        WHEN m.dh = 'H'
                             AND m.mes = 0 THEN
                                CASE
                                    WHEN pin_tipmon = 'PEN' THEN
                                        m.haber01
                                    ELSE
                                        m.haber02
                                END
                        ELSE
                            0
                    END
                )         AS saldos_ini_h,
                SUM(
                    CASE
                        WHEN m.dh = 'D'
                             AND m.mes > 0
                             AND m.mes <= 12 THEN
                                CASE
                                    WHEN pin_tipmon = 'PEN' THEN
                                        m.debe01
                                    ELSE
                                        m.debe02
                                END
                        ELSE
                            0
                    END
                )         AS movi_ejer_d,
                SUM(
                    CASE
                        WHEN m.dh = 'H'
                             AND m.mes > 0
                             AND m.mes <= 12 THEN
                                CASE
                                    WHEN pin_tipmon = 'PEN' THEN
                                        m.haber01
                                    ELSE
                                        m.haber02
                                END
                        ELSE
                            0
                    END
                )         AS movi_ejer_h,
                SUM(
                    CASE
                        WHEN pin_tipmon = 'PEN' THEN
                            m.debe01
                        ELSE
                            m.debe02
                    END
                )         AS debeacu,
                SUM(
                    CASE
                        WHEN pin_tipmon = 'PEN' THEN
                            m.haber01
                        ELSE
                            m.haber02
                    END
                )         AS haberacu
            FROM
                movimientos    m
                LEFT OUTER JOIN pcuentas_clase pc ON pc.id_cia = m.id_cia
                                                     AND pc.cuenta = m.cuenta
                                                     AND pc.swflag = 'S'
                                                     AND pc.clase = 5
                LEFT OUTER JOIN pcuentas       p ON p.id_cia = m.id_cia
                                              AND p.cuenta = m.cuenta
                LEFT OUTER JOIN pcuentas       p1 ON p1.id_cia = m.id_cia
                                               AND p1.cuenta = substr(m.cuenta, 1, 2)
                LEFT OUTER JOIN companias      c ON c.cia = m.id_cia
            WHERE
                    m.id_cia = pin_id_cia
                AND m.periodo = pin_periodo
                AND m.mes <= 12
                AND p.balance = 'S'
            GROUP BY
                c.ruc,
                pc.codigo,
                p1.nombre,
                p.balancecol,
                p1.cuenta
        ) LOOP
            v_rec.titulo := pin_codrent
                            || i.ruc
                            || trim(to_char(pin_periodo));

            v_rec.cuenta_sunat := i.cuenta_sunat;
            v_rec.colum01 := ' ';
            v_rec.colum02 := ' ';
            v_rec.colum03 := ' ';
            v_rec.colum04 := ' ';
            v_rec.colum05 := '0';
            v_rec.colum06 := '0';
            v_rec.colum07 := '0';
            v_rec.colum08 := '0';
            IF
                i.saldos_ini_d = 0
                AND i.balancecol = 'I'
            THEN
                v_rec.colum01 := '0';
            ELSE
                v_rec.colum01 := to_char(round(i.saldos_ini_d, 0));
            END IF;

            IF
                i.saldos_ini_h = 0
                AND i.balancecol = 'I'
            THEN
                v_rec.colum02 := '0';
            ELSE
                v_rec.colum02 := to_char(round(i.saldos_ini_h, 0));
            END IF;

            IF i.movi_ejer_d = 0 THEN
                v_rec.colum03 := '0';
            ELSE
                v_rec.colum03 := to_char(round(i.movi_ejer_d, 0));
            END IF;

            IF i.movi_ejer_h = 0 THEN
                v_rec.colum04 := '0';
            ELSE
                v_rec.colum04 := to_char(round(i.movi_ejer_h, 0));
            END IF;

            IF i.balancecol IN ( 'N', 'R' ) THEN
                v_rec.colum01 := ' ';
                v_rec.colum02 := ' ';
            END IF;

            v_rec.colum05 := '0';
            v_rec.colum06 := '0';
            v_rec.colum07 := '0';
            v_rec.colum08 := '0';
            PIPE ROW ( v_rec );
        END LOOP;

        RETURN;
    END sp_buscar_txt;

END;

/

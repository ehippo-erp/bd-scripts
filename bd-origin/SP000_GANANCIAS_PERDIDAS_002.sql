--------------------------------------------------------
--  DDL for Function SP000_GANANCIAS_PERDIDAS_002
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP000_GANANCIAS_PERDIDAS_002" (
    pin_id_cia    NUMBER,
    pin_periodo   NUMBER,
    pin_verccosto VARCHAR2
) RETURN tbl_ganancias_perdidas_002
    PIPELINED
AS

    v_ganancias_perdidas_002 rec_ganancias_perdidas_002 := rec_ganancias_perdidas_002(NULL, NULL, NULL, NULL, NULL,
                                                                                     NULL, NULL, NULL, NULL, NULL,
                                                                                     NULL, NULL, NULL, NULL, NULL,
                                                                                     NULL, NULL, NULL, NULL);
    CURSOR cur_select IS
    SELECT
        h.codigo,
        h.titulo,
        h.tipo,
        h.signo,
        d.cuenta,
        p.nombre AS descuenta,
        SUM(
            CASE
                WHEN m.dh = 'D' THEN
                        CASE
                            WHEN m.mes <= 01 THEN
                                m.debe01
                            ELSE
                                0
                        END
                ELSE
                    0
            END
        ) - SUM(
            CASE
                WHEN m.dh = 'H' THEN
                        CASE
                            WHEN m.mes <= 01 THEN
                                m.haber01
                            ELSE
                                0
                        END
                ELSE
                    0
            END
        )        AS saldo01,
        SUM(
            CASE
                WHEN m.dh = 'D' THEN
                        CASE
                            WHEN m.mes <= 02 THEN
                                m.debe01
                            ELSE
                                0
                        END
                ELSE
                    0
            END
        ) - SUM(
            CASE
                WHEN m.dh = 'H' THEN
                        CASE
                            WHEN m.mes <= 02 THEN
                                m.haber01
                            ELSE
                                0
                        END
                ELSE
                    0
            END
        )        AS saldo02,
        SUM(
            CASE
                WHEN m.dh = 'D' THEN
                        CASE
                            WHEN m.mes <= 03 THEN
                                m.debe01
                            ELSE
                                0
                        END
                ELSE
                    0
            END
        ) - SUM(
            CASE
                WHEN m.dh = 'H' THEN
                        CASE
                            WHEN m.mes <= 03 THEN
                                m.haber01
                            ELSE
                                0
                        END
                ELSE
                    0
            END
        )        AS saldo03,
        SUM(
            CASE
                WHEN m.dh = 'D' THEN
                        CASE
                            WHEN m.mes <= 04 THEN
                                m.debe01
                            ELSE
                                0
                        END
                ELSE
                    0
            END
        ) - SUM(
            CASE
                WHEN m.dh = 'H' THEN
                        CASE
                            WHEN m.mes <= 04 THEN
                                m.haber01
                            ELSE
                                0
                        END
                ELSE
                    0
            END
        )        AS saldo04,
        SUM(
            CASE
                WHEN m.dh = 'D' THEN
                        CASE
                            WHEN m.mes <= 05 THEN
                                m.debe01
                            ELSE
                                0
                        END
                ELSE
                    0
            END
        ) - SUM(
            CASE
                WHEN m.dh = 'H' THEN
                        CASE
                            WHEN m.mes <= 05 THEN
                                m.haber01
                            ELSE
                                0
                        END
                ELSE
                    0
            END
        )        AS saldo05,
        SUM(
            CASE
                WHEN m.dh = 'D' THEN
                        CASE
                            WHEN m.mes <= 06 THEN
                                m.debe01
                            ELSE
                                0
                        END
                ELSE
                    0
            END
        ) - SUM(
            CASE
                WHEN m.dh = 'H' THEN
                        CASE
                            WHEN m.mes <= 06 THEN
                                m.haber01
                            ELSE
                                0
                        END
                ELSE
                    0
            END
        )        AS saldo06,
        SUM(
            CASE
                WHEN m.dh = 'D' THEN
                        CASE
                            WHEN m.mes <= 07 THEN
                                m.debe01
                            ELSE
                                0
                        END
                ELSE
                    0
            END
        ) - SUM(
            CASE
                WHEN m.dh = 'H' THEN
                        CASE
                            WHEN m.mes <= 07 THEN
                                m.haber01
                            ELSE
                                0
                        END
                ELSE
                    0
            END
        )        AS saldo07,
        SUM(
            CASE
                WHEN m.dh = 'D' THEN
                        CASE
                            WHEN m.mes <= 08 THEN
                                m.debe01
                            ELSE
                                0
                        END
                ELSE
                    0
            END
        ) - SUM(
            CASE
                WHEN m.dh = 'H' THEN
                        CASE
                            WHEN m.mes <= 08 THEN
                                m.haber01
                            ELSE
                                0
                        END
                ELSE
                    0
            END
        )        AS saldo08,
        SUM(
            CASE
                WHEN m.dh = 'D' THEN
                        CASE
                            WHEN m.mes <= 09 THEN
                                m.debe01
                            ELSE
                                0
                        END
                ELSE
                    0
            END
        ) - SUM(
            CASE
                WHEN m.dh = 'H' THEN
                        CASE
                            WHEN m.mes <= 09 THEN
                                m.haber01
                            ELSE
                                0
                        END
                ELSE
                    0
            END
        )        AS saldo09,
        SUM(
            CASE
                WHEN m.dh = 'D' THEN
                        CASE
                            WHEN m.mes <= 10 THEN
                                m.debe01
                            ELSE
                                0
                        END
                ELSE
                    0
            END
        ) - SUM(
            CASE
                WHEN m.dh = 'H' THEN
                        CASE
                            WHEN m.mes <= 10 THEN
                                m.haber01
                            ELSE
                                0
                        END
                ELSE
                    0
            END
        )        AS saldo10,
        SUM(
            CASE
                WHEN m.dh = 'D' THEN
                        CASE
                            WHEN m.mes <= 11 THEN
                                m.debe01
                            ELSE
                                0
                        END
                ELSE
                    0
            END
        ) - SUM(
            CASE
                WHEN m.dh = 'H' THEN
                        CASE
                            WHEN m.mes <= 11 THEN
                                m.haber01
                            ELSE
                                0
                        END
                ELSE
                    0
            END
        )        AS saldo11,
        SUM(
            CASE
                WHEN m.dh = 'D' THEN
                        CASE
                            WHEN m.mes <= 12 THEN
                                m.debe01
                            ELSE
                                0
                        END
                ELSE
                    0
            END
        ) - SUM(
            CASE
                WHEN m.dh = 'H' THEN
                        CASE
                            WHEN m.mes <= 12 THEN
                                m.haber01
                            ELSE
                                0
                        END
                ELSE
                    0
            END
        )        AS saldo12,
        SUM(
            CASE
                WHEN m.dh = 'D' THEN
                        CASE
                            WHEN m.mes >= 00 THEN
                                m.debe01
                            ELSE
                                0
                        END
                ELSE
                    0
            END
        ) - SUM(
            CASE
                WHEN m.dh = 'H' THEN
                        CASE
                            WHEN m.mes >= 00 THEN
                                m.haber01
                            ELSE
                                0
                        END
                ELSE
                    0
            END
        )        AS saldo99
    FROM
        ganaperdihea h
        LEFT OUTER JOIN ganaperdidet d ON d.id_cia = pin_id_cia
                                          AND d.codigo = h.codigo
        LEFT OUTER JOIN movimientos  m ON m.id_cia = pin_id_cia
                                         AND m.periodo = pin_periodo
                                         AND m.cuenta = d.cuenta
        LEFT OUTER JOIN pcuentas     p ON p.id_cia = pin_id_cia
                                      AND p.cuenta = d.cuenta
    WHERE
        h.id_cia = pin_id_cia                             
   /*    Where H.Codigo>=:CodDes And H.Codigo<=:CodHas */
    GROUP BY
        h.codigo,
        h.titulo,
        h.tipo,
        h.signo,
        d.cuenta,
        p.nombre
    ORDER BY
        h.codigo;

    CURSOR cur_select01 (
        pccosto VARCHAR2
    ) IS
    SELECT
        m.cuenta
        || ' - '
        || p.nombre AS descuenta,
        SUM(
            CASE
                WHEN m.dh = 'D' THEN
                        CASE
                            WHEN m.mes <= 01 THEN
                                m.debe01
                            ELSE
                                0
                        END
                ELSE
                    0
            END
        ) - SUM(
            CASE
                WHEN m.dh = 'H' THEN
                        CASE
                            WHEN m.mes <= 01 THEN
                                m.haber01
                            ELSE
                                0
                        END
                ELSE
                    0
            END
        )           AS saldo01,
        SUM(
            CASE
                WHEN m.dh = 'D' THEN
                        CASE
                            WHEN m.mes <= 02 THEN
                                m.debe01
                            ELSE
                                0
                        END
                ELSE
                    0
            END
        ) - SUM(
            CASE
                WHEN m.dh = 'H' THEN
                        CASE
                            WHEN m.mes <= 02 THEN
                                m.haber01
                            ELSE
                                0
                        END
                ELSE
                    0
            END
        )           AS saldo02,
        SUM(
            CASE
                WHEN m.dh = 'D' THEN
                        CASE
                            WHEN m.mes <= 03 THEN
                                m.debe01
                            ELSE
                                0
                        END
                ELSE
                    0
            END
        ) - SUM(
            CASE
                WHEN m.dh = 'H' THEN
                        CASE
                            WHEN m.mes <= 03 THEN
                                m.haber01
                            ELSE
                                0
                        END
                ELSE
                    0
            END
        )           AS saldo03,
        SUM(
            CASE
                WHEN m.dh = 'D' THEN
                        CASE
                            WHEN m.mes <= 04 THEN
                                m.debe01
                            ELSE
                                0
                        END
                ELSE
                    0
            END
        ) - SUM(
            CASE
                WHEN m.dh = 'H' THEN
                        CASE
                            WHEN m.mes <= 04 THEN
                                m.haber01
                            ELSE
                                0
                        END
                ELSE
                    0
            END
        )           AS saldo04,
        SUM(
            CASE
                WHEN m.dh = 'D' THEN
                        CASE
                            WHEN m.mes <= 05 THEN
                                m.debe01
                            ELSE
                                0
                        END
                ELSE
                    0
            END
        ) - SUM(
            CASE
                WHEN m.dh = 'H' THEN
                        CASE
                            WHEN m.mes <= 05 THEN
                                m.haber01
                            ELSE
                                0
                        END
                ELSE
                    0
            END
        )           AS saldo05,
        SUM(
            CASE
                WHEN m.dh = 'D' THEN
                        CASE
                            WHEN m.mes <= 06 THEN
                                m.debe01
                            ELSE
                                0
                        END
                ELSE
                    0
            END
        ) - SUM(
            CASE
                WHEN m.dh = 'H' THEN
                        CASE
                            WHEN m.mes <= 06 THEN
                                m.haber01
                            ELSE
                                0
                        END
                ELSE
                    0
            END
        )           AS saldo06,
        SUM(
            CASE
                WHEN m.dh = 'D' THEN
                        CASE
                            WHEN m.mes <= 07 THEN
                                m.debe01
                            ELSE
                                0
                        END
                ELSE
                    0
            END
        ) - SUM(
            CASE
                WHEN m.dh = 'H' THEN
                        CASE
                            WHEN m.mes <= 07 THEN
                                m.haber01
                            ELSE
                                0
                        END
                ELSE
                    0
            END
        )           AS saldo07,
        SUM(
            CASE
                WHEN m.dh = 'D' THEN
                        CASE
                            WHEN m.mes <= 08 THEN
                                m.debe01
                            ELSE
                                0
                        END
                ELSE
                    0
            END
        ) - SUM(
            CASE
                WHEN m.dh = 'H' THEN
                        CASE
                            WHEN m.mes <= 08 THEN
                                m.haber01
                            ELSE
                                0
                        END
                ELSE
                    0
            END
        )           AS saldo08,
        SUM(
            CASE
                WHEN m.dh = 'D' THEN
                        CASE
                            WHEN m.mes <= 09 THEN
                                m.debe01
                            ELSE
                                0
                        END
                ELSE
                    0
            END
        ) - SUM(
            CASE
                WHEN m.dh = 'H' THEN
                        CASE
                            WHEN m.mes <= 09 THEN
                                m.haber01
                            ELSE
                                0
                        END
                ELSE
                    0
            END
        )           AS saldo09,
        SUM(
            CASE
                WHEN m.dh = 'D' THEN
                        CASE
                            WHEN m.mes <= 10 THEN
                                m.debe01
                            ELSE
                                0
                        END
                ELSE
                    0
            END
        ) - SUM(
            CASE
                WHEN m.dh = 'H' THEN
                        CASE
                            WHEN m.mes <= 10 THEN
                                m.haber01
                            ELSE
                                0
                        END
                ELSE
                    0
            END
        )           AS saldo10,
        SUM(
            CASE
                WHEN m.dh = 'D' THEN
                        CASE
                            WHEN m.mes <= 11 THEN
                                m.debe01
                            ELSE
                                0
                        END
                ELSE
                    0
            END
        ) - SUM(
            CASE
                WHEN m.dh = 'H' THEN
                        CASE
                            WHEN m.mes <= 11 THEN
                                m.haber01
                            ELSE
                                0
                        END
                ELSE
                    0
            END
        )           AS saldo11,
        SUM(
            CASE
                WHEN m.dh = 'D' THEN
                        CASE
                            WHEN m.mes <= 12 THEN
                                m.debe01
                            ELSE
                                0
                        END
                ELSE
                    0
            END
        ) - SUM(
            CASE
                WHEN m.dh = 'H' THEN
                        CASE
                            WHEN m.mes <= 12 THEN
                                m.haber01
                            ELSE
                                0
                        END
                ELSE
                    0
            END
        )           AS saldo12,
        SUM(
            CASE
                WHEN m.dh = 'D' THEN
                        CASE
                            WHEN m.mes >= 00 THEN
                                m.debe01
                            ELSE
                                0
                        END
                ELSE
                    0
            END
        ) - SUM(
            CASE
                WHEN m.dh = 'H' THEN
                        CASE
                            WHEN m.mes >= 00 THEN
                                m.haber01
                            ELSE
                                0
                        END
                ELSE
                    0
            END
        )           AS saldo99
    FROM
        movimientos m
        LEFT OUTER JOIN pcuentas    p ON p.id_cia = m.id_cia
                                      AND p.cuenta = m.cuenta
    WHERE
            m.id_cia = pin_id_cia
        AND m.ccosto = pccosto
        AND m.periodo = pin_periodo
    GROUP BY
        m.cuenta,
        p.nombre
    ORDER BY
        m.cuenta,
        p.nombre;

    v_ccosto                 VARCHAR(20);
    v_salio                  VARCHAR(1);
    v_total01                NUMERIC(16, 2) := 0;
    v_total02                NUMERIC(16, 2) := 0;
    v_total03                NUMERIC(16, 2) := 0;
    v_total04                NUMERIC(16, 2) := 0;
    v_total05                NUMERIC(16, 2) := 0;
    v_total06                NUMERIC(16, 2) := 0;
    v_total07                NUMERIC(16, 2) := 0;
    v_total08                NUMERIC(16, 2) := 0;
    v_total09                NUMERIC(16, 2) := 0;
    v_total10                NUMERIC(16, 2) := 0;
    v_total11                NUMERIC(16, 2) := 0;
    v_total12                NUMERIC(16, 2) := 0;
    v_total99                NUMERIC(16, 2) := 0;
BEGIN
    FOR registro IN cur_select LOOP
        v_ganancias_perdidas_002.codigo := registro.codigo;
        v_ganancias_perdidas_002.titulo := registro.titulo;
        v_ganancias_perdidas_002.tipo := registro.tipo;
        v_ganancias_perdidas_002.signo := registro.signo;
        v_ganancias_perdidas_002.cuenta := registro.cuenta;
        v_ganancias_perdidas_002.descuenta := registro.descuenta;
        v_ganancias_perdidas_002.saldo01 := abs(registro.saldo01);
        v_ganancias_perdidas_002.saldo02 := abs(registro.saldo02);
        v_ganancias_perdidas_002.saldo03 := abs(registro.saldo03);
        v_ganancias_perdidas_002.saldo04 := abs(registro.saldo04);
        v_ganancias_perdidas_002.saldo05 := abs(registro.saldo05);
        v_ganancias_perdidas_002.saldo06 := abs(registro.saldo06);
        v_ganancias_perdidas_002.saldo07 := abs(registro.saldo07);
        v_ganancias_perdidas_002.saldo08 := abs(registro.saldo08);
        v_ganancias_perdidas_002.saldo09 := abs(registro.saldo09);
        v_ganancias_perdidas_002.saldo10 := abs(registro.saldo10);
        v_ganancias_perdidas_002.saldo11 := abs(registro.saldo11);
        v_ganancias_perdidas_002.saldo12 := abs(registro.saldo12);
        v_ganancias_perdidas_002.saldo99 := abs(registro.saldo99);
        IF ( registro.signo = 'N' ) THEN
            v_ganancias_perdidas_002.saldo01 := v_ganancias_perdidas_002.saldo01 * -1;
            v_ganancias_perdidas_002.saldo02 := v_ganancias_perdidas_002.saldo02 * -1;
            v_ganancias_perdidas_002.saldo03 := v_ganancias_perdidas_002.saldo03 * -1;
            v_ganancias_perdidas_002.saldo04 := v_ganancias_perdidas_002.saldo04 * -1;
            v_ganancias_perdidas_002.saldo05 := v_ganancias_perdidas_002.saldo05 * -1;
            v_ganancias_perdidas_002.saldo06 := v_ganancias_perdidas_002.saldo06 * -1;
            v_ganancias_perdidas_002.saldo07 := v_ganancias_perdidas_002.saldo07 * -1;
            v_ganancias_perdidas_002.saldo08 := v_ganancias_perdidas_002.saldo08 * -1;
            v_ganancias_perdidas_002.saldo09 := v_ganancias_perdidas_002.saldo09 * -1;
            v_ganancias_perdidas_002.saldo10 := v_ganancias_perdidas_002.saldo10 * -1;
            v_ganancias_perdidas_002.saldo11 := v_ganancias_perdidas_002.saldo11 * -1;
            v_ganancias_perdidas_002.saldo12 := v_ganancias_perdidas_002.saldo12 * -1;
            v_ganancias_perdidas_002.saldo99 := v_ganancias_perdidas_002.saldo99 * -1;
        END IF;

        v_total01 := v_total01 + v_ganancias_perdidas_002.saldo01;
        v_total02 := v_total02 + v_ganancias_perdidas_002.saldo02;
        v_total03 := v_total03 + v_ganancias_perdidas_002.saldo03;
        v_total04 := v_total04 + v_ganancias_perdidas_002.saldo04;
        v_total05 := v_total05 + v_ganancias_perdidas_002.saldo05;
        v_total06 := v_total06 + v_ganancias_perdidas_002.saldo06;
        v_total07 := v_total07 + v_ganancias_perdidas_002.saldo07;
        v_total08 := v_total08 + v_ganancias_perdidas_002.saldo08;
        v_total09 := v_total09 + v_ganancias_perdidas_002.saldo09;
        v_total10 := v_total10 + v_ganancias_perdidas_002.saldo10;
        v_total11 := v_total11 + v_ganancias_perdidas_002.saldo11;
        v_total12 := v_total12 + v_ganancias_perdidas_002.saldo12;
        v_total99 := v_total99 + v_ganancias_perdidas_002.saldo99;
        IF ( upper(v_ganancias_perdidas_002.tipo) = 'T' ) THEN
            v_ganancias_perdidas_002.saldo01 := v_total01;
            v_ganancias_perdidas_002.saldo02 := v_total02;
            v_ganancias_perdidas_002.saldo03 := v_total03;
            v_ganancias_perdidas_002.saldo04 := v_total04;
            v_ganancias_perdidas_002.saldo05 := v_total05;
            v_ganancias_perdidas_002.saldo06 := v_total06;
            v_ganancias_perdidas_002.saldo07 := v_total07;
            v_ganancias_perdidas_002.saldo08 := v_total08;
            v_ganancias_perdidas_002.saldo09 := v_total09;
            v_ganancias_perdidas_002.saldo10 := v_total10;
            v_ganancias_perdidas_002.saldo11 := v_total11;
            v_ganancias_perdidas_002.saldo12 := v_total12;
            v_ganancias_perdidas_002.saldo99 := v_total99;
        END IF;

        PIPE ROW ( v_ganancias_perdidas_002 );
        v_ccosto := v_ganancias_perdidas_002.cuenta;
        v_salio := 'N';
        v_ganancias_perdidas_002.descuenta := NULL;
        v_ganancias_perdidas_002.cuenta := NULL;
        IF ( upper(pin_verccosto) = 'S' ) THEN
            FOR reg IN cur_select01(v_ccosto) LOOP
                v_ganancias_perdidas_002.descuenta := reg.descuenta;
                v_ganancias_perdidas_002.saldo01 := reg.saldo01;
                v_ganancias_perdidas_002.saldo02 := reg.saldo02;
                v_ganancias_perdidas_002.saldo03 := reg.saldo03;
                v_ganancias_perdidas_002.saldo04 := reg.saldo04;
                v_ganancias_perdidas_002.saldo05 := reg.saldo05;
                v_ganancias_perdidas_002.saldo06 := reg.saldo06;
                v_ganancias_perdidas_002.saldo07 := reg.saldo07;
                v_ganancias_perdidas_002.saldo08 := reg.saldo08;
                v_ganancias_perdidas_002.saldo09 := reg.saldo09;
                v_ganancias_perdidas_002.saldo10 := reg.saldo10;
                v_ganancias_perdidas_002.saldo11 := reg.saldo11;
                v_ganancias_perdidas_002.saldo12 := reg.saldo12;
                v_ganancias_perdidas_002.saldo99 := reg.saldo99;
                IF ( registro.signo = 'N' ) THEN
                    v_ganancias_perdidas_002.saldo01 := v_ganancias_perdidas_002.saldo01 * -1;
                    v_ganancias_perdidas_002.saldo02 := v_ganancias_perdidas_002.saldo02 * -1;
                    v_ganancias_perdidas_002.saldo03 := v_ganancias_perdidas_002.saldo03 * -1;
                    v_ganancias_perdidas_002.saldo04 := v_ganancias_perdidas_002.saldo04 * -1;
                    v_ganancias_perdidas_002.saldo05 := v_ganancias_perdidas_002.saldo05 * -1;
                    v_ganancias_perdidas_002.saldo06 := v_ganancias_perdidas_002.saldo06 * -1;
                    v_ganancias_perdidas_002.saldo07 := v_ganancias_perdidas_002.saldo07 * -1;
                    v_ganancias_perdidas_002.saldo08 := v_ganancias_perdidas_002.saldo08 * -1;
                    v_ganancias_perdidas_002.saldo09 := v_ganancias_perdidas_002.saldo09 * -1;
                    v_ganancias_perdidas_002.saldo10 := v_ganancias_perdidas_002.saldo10 * -1;
                    v_ganancias_perdidas_002.saldo11 := v_ganancias_perdidas_002.saldo11 * -1;
                    v_ganancias_perdidas_002.saldo12 := v_ganancias_perdidas_002.saldo12 * -1;
                    v_ganancias_perdidas_002.saldo99 := v_ganancias_perdidas_002.saldo99 * -1;
                END IF;

                v_salio := 'S';
                PIPE ROW ( v_ganancias_perdidas_002 );
            END LOOP;
        END IF;
------

        IF ( upper(v_ganancias_perdidas_002.tipo) = 'T' ) THEN
            v_ganancias_perdidas_002.descuenta := NULL;
            v_ganancias_perdidas_002.codigo := NULL;
            v_ganancias_perdidas_002.titulo := '';
            v_ganancias_perdidas_002.tipo := '';
            v_ganancias_perdidas_002.saldo01 := NULL;
            v_ganancias_perdidas_002.saldo02 := NULL;
            v_ganancias_perdidas_002.saldo03 := NULL;
            v_ganancias_perdidas_002.saldo04 := NULL;
            v_ganancias_perdidas_002.saldo05 := NULL;
            v_ganancias_perdidas_002.saldo06 := NULL;
            v_ganancias_perdidas_002.saldo07 := NULL;
            v_ganancias_perdidas_002.saldo08 := NULL;
            v_ganancias_perdidas_002.saldo09 := NULL;
            v_ganancias_perdidas_002.saldo10 := NULL;
            v_ganancias_perdidas_002.saldo11 := NULL;
            v_ganancias_perdidas_002.saldo12 := NULL;
            v_ganancias_perdidas_002.saldo99 := NULL;
            PIPE ROW ( v_ganancias_perdidas_002 );
        END IF;
----

    END LOOP;
END sp000_ganancias_perdidas_002;

/

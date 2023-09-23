--------------------------------------------------------
--  DDL for Package Body PACK_RPT_INVENTA_BALANCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_RPT_INVENTA_BALANCE" AS

    FUNCTION sp000_balance_general (
        pin_id_cia  INTEGER,
        pin_periodo INTEGER,
        pin_meshas  INTEGER,
        pin_coddes  SMALLINT,
        pin_codhas  SMALLINT
    ) RETURN tbl_balance_general
        PIPELINED
    AS

        v_cuenta  VARCHAR2(16);
        v_total1  NUMERIC(16, 2) := 0;
        v_total2  NUMERIC(16, 2) := 0;
        v_tdebe   NUMERIC(16, 2);
        v_thaber  NUMERIC(16, 2);
        v_saldo   NUMERIC(16, 2);
        v_codadic SMALLINT;
        v_consig  VARCHAR2(1);
        registro  rec_balance_general := rec_balance_general(NULL, NULL, NULL, NULL);
        CURSOR cur_bgeneralhea IS
        SELECT
            h.codigo,
            h.titulo,
            h.tipo,
            h.codadic,
            upper(h.consig) AS consig
        FROM
            bgeneralhea h
        WHERE
                h.id_cia = pin_id_cia
            AND h.codigo >= pin_coddes
            AND h.codigo <= pin_codhas
        ORDER BY
            h.codigo;

    BEGIN
        v_total1 := 0;
        v_total2 := 0;
        FOR rec_bgeneralhea IN cur_bgeneralhea LOOP
            registro.codigo := rec_bgeneralhea.codigo;
            registro.titulo := rec_bgeneralhea.titulo;
            registro.tipo := rec_bgeneralhea.tipo;
            v_codadic := rec_bgeneralhea.codadic;
            v_consig := rec_bgeneralhea.consig;
            v_cuenta := '';
            v_saldo := 0;
            --;
            v_tdebe := 0;
            v_thaber := 0;
            registro.saldo := 0;
            FOR rec_bgeneraldet IN (
                SELECT
                    d.cuenta
                FROM
                    bgeneraldet d
                WHERE
                        d.id_cia = pin_id_cia
                    AND d.codigo = registro.codigo
            ) LOOP
                v_cuenta := rec_bgeneraldet.cuenta;
                v_tdebe := 0;
                v_thaber := 0;
                --registro.saldo:=0;
                BEGIN
                    SELECT
                        SUM(
                            CASE
                                WHEN m.dh = 'D' THEN
                                    nvl(m.debe01, 0)
                                ELSE
                                    0
                            END
                        ),
                        SUM(
                            CASE
                                WHEN m.dh = 'H' THEN
                                    nvl(m.haber01, 0)
                                ELSE
                                    0
                            END
                        )
                    INTO
                        v_tdebe,
                        v_thaber
                    FROM
                        movimientos m
                    WHERE
                            m.id_cia = pin_id_cia
                        AND m.periodo = pin_periodo
                        AND m.mes <= pin_meshas
                        AND m.cuenta = v_cuenta;

--                    dbms_output.put_line(v_tdebe
--                                         || ' - '
--                                         || v_thaber
--                                         || ' - '
--                                         || v_cuenta
--                                         || ' - ');

                EXCEPTION
                    WHEN no_data_found THEN
                        v_tdebe := NULL;
                        v_thaber := NULL;
                END;

                IF ( v_tdebe IS NULL ) THEN
                    v_tdebe := 0;
                END IF;
                IF ( v_thaber IS NULL ) THEN
                    v_thaber := 0;
                END IF;
         /* 2011-04-13 - Carlos - para el Activo el Saldo= D-H .. para el Pasivo el Saldo = H-D */
                IF ( registro.codigo < 2000 ) THEN
                    v_saldo := v_tdebe - v_thaber;
                ELSE
                    v_saldo := v_thaber - v_tdebe;
                END IF;

         /* 2011-05-17 - Carlos - si el SALDO es NEGATIVO entonces sera CERO */
                IF (
                    ( v_saldo < 0 )
                    AND ( v_consig = 'S' )
                ) THEN
                    v_saldo := 0;
                END IF;

                registro.saldo := registro.saldo + v_saldo;
            END LOOP;

            v_total1 := v_total1 + registro.saldo;
            v_total2 := v_total2 + registro.saldo;
            IF ( upper(registro.tipo) = 'D' ) THEN
                registro.titulo := '   ' || registro.titulo;
            END IF;

            IF ( upper(registro.tipo) = 'C' ) THEN
                IF ( registro.codigo - ( ( registro.codigo / 100 ) * 100 ) = 99 ) THEN
                    v_total1 := 0;
                END IF;

                IF ( registro.codigo - ( ( registro.codigo / 1000 ) * 1000 ) = 999 ) THEN
                    v_total2 := 0;
                END IF;

            END IF;

            IF ( upper(registro.tipo) = 'T' ) THEN
                IF MOD(registro.codigo, 100) = 99 THEN
                    registro.saldo := v_total1;
                    v_total1 := 0;
                END IF;

                -- TOTAL PASIVO NO CORRIENTE 2250
                IF registro.codigo = 2250 THEN
                    registro.saldo := v_total1;
                    v_total1 := 0;
                END IF;

                -- TOTAL NO CORRIENTE 2299
                IF registro.codigo = 2299 THEN
                    registro.saldo := v_total2;
                    v_total1 := 0;
                END IF;

                IF MOD(registro.codigo, 1000) = 999 THEN
                    registro.saldo := v_total2;
                    v_total2 := 0;
                END IF;

--                dbms_output.put_line(v_total1
--                                     || ' - '
--                                     || v_total2
--                                     || ' [ '
--                                     || registro.saldo
--                                     || ' ]'
--                                     || ' - '
--                                     || rec_bgeneralhea.codigo);

            END IF;

            dbms_output.put_line(v_total1
                                 || ' - '
                                 || v_total2
                                 || ' [ '
                                 || registro.saldo
                                 || ' ]'
                                 || ' - '
                                 || rec_bgeneralhea.codigo
                                 || ' - '
                                 || rec_bgeneralhea.titulo
                                 || '- '
                                 || v_codadic);

            IF v_codadic IS NULL OR v_codadic = 0 THEN
                PIPE ROW ( registro );
            ELSE
                FOR rec_ganancias_perdidas IN (
                    SELECT
                        titulo,
                        saldo
                    FROM
                        pack_rpt_inventa_balance.sp_formato_320v2(pin_id_cia, pin_periodo, pin_meshas, v_codadic)
                    WHERE
                        codigo = v_codadic
                ) LOOP
                -- DEBE ADAPTASE A LA CONFIGURACION DEL SISTEMA
--                    registro.titulo := rec_ganancias_perdidas.titulo;
--                    registro.saldo := rec_ganancias_perdidas.saldo;
                    registro.saldo := rec_ganancias_perdidas.saldo;
                    v_total1 := v_total1 + registro.saldo;
                    v_total2 := v_total2 + registro.saldo;
                    PIPE ROW ( registro );
                END LOOP;
            END IF;

            IF ( upper(registro.tipo) = 'T' ) THEN
                registro.codigo := NULL;
                registro.titulo := '';
                registro.tipo := '';
                registro.saldo := 0;
                PIPE ROW ( registro );
            END IF;

        END LOOP;

    END sp000_balance_general;

    FUNCTION sp000_formato_302 (
        pin_id_cia  IN NUMBER,
        pin_periodo IN NUMBER,
        pin_mes     IN NUMBER
    ) RETURN tbl_formato_302
        PIPELINED
    AS

        registro rec_formato_302 := rec_formato_302(NULL, NULL, NULL, NULL, NULL,
                                                   NULL);
        CURSOR cursor_sp IS
        SELECT
            p.cuenta,
            p.nombre,
            p.moneda01,
            pc.vstrg AS codban,
            SUM((
                CASE
                    WHEN m.debe01 IS NULL THEN
                        0
                    ELSE
                        m.debe01
                END
            ))       AS debe01,
            SUM((
                CASE
                    WHEN m.haber01 IS NULL THEN
                        0
                    ELSE
                        m.haber01
                END
            ))       AS haber01
        FROM
                 pcuentas p
            INNER JOIN pcuentas_clase pc ON ( pc.id_cia = pin_id_cia )
                                            AND pc.cuenta = p.cuenta
                                            AND pc.clase = 2
                                            AND /*2-CAJA BANCOS - CUENTA CORRIENTE*/ pc.swflag = 'S'
            LEFT OUTER JOIN movimientos    m ON ( m.id_cia = pin_id_cia )
                                             AND ( m.periodo = pin_periodo )
                                             AND ( m.mes <= pin_mes )
                                             AND m.cuenta = p.cuenta
        WHERE
            ( p.id_cia = pin_id_cia )
        GROUP BY
            p.cuenta,
            p.nombre,
            p.moneda01,
            pc.vstrg;

    BEGIN
        FOR rec IN cursor_sp LOOP
            registro.cuenta := rec.cuenta;
            registro.nombre := rec.nombre;
            registro.moneda := rec.moneda01;
            registro.codban := rec.codban;
            registro.debe01 := rec.debe01;
            registro.haber01 := rec.haber01;
            PIPE ROW ( registro );
        END LOOP;
    END sp000_formato_302;

    FUNCTION sp_formato_320 (
        pin_id_cia  INTEGER,
        pin_periodo INTEGER,
        pin_meshas  INTEGER
    ) RETURN tbl_rec_formato_320
        PIPELINED
    AS

        v_saldo  NUMERIC(16, 2) := 0;
        v_total1 NUMERIC(16, 2) := 0;
        v_cuenta VARCHAR2(16) := '';
        registro rec_formato_320 := rec_formato_320(NULL, NULL, NULL, NULL, NULL);
    BEGIN
        FOR rec_ganaperdihea IN (
            SELECT
                h.codigo,
                h.titulo,
                h.tipo,
                h.signo /*,D.Cuenta*/
            FROM
                ganaperdihea h
            WHERE
                h.id_cia = pin_id_cia
            ORDER BY
                h.codigo
        ) LOOP
            registro.codigo := rec_ganaperdihea.codigo;
            registro.titulo := rec_ganaperdihea.titulo;
            registro.tipo := rec_ganaperdihea.tipo;
            registro.signo := rec_ganaperdihea.signo;
            v_saldo := 0;
            registro.saldo := 0;
            FOR rec_ganaperdidet IN (
                SELECT
                    d.cuenta
                FROM
                    ganaperdidet d
                WHERE
                        d.id_cia = pin_id_cia
                    AND d.codigo = registro.codigo
                ORDER BY
                    cuenta
            ) LOOP
                v_cuenta := rec_ganaperdidet.cuenta;
                SELECT
                    SUM(
                        CASE
                            WHEN m.dh = 'H' THEN
                                m.haber01
                            ELSE
                                0
                        END
                    ) - SUM(
                        CASE
                            WHEN m.dh = 'D' THEN
                                m.debe01
                            ELSE
                                0
                        END
                    ) AS saldo
                INTO v_saldo
                FROM
                    movimientos m
                WHERE
                        m.id_cia = pin_id_cia
                    AND m.periodo = pin_periodo
                    AND m.mes <= pin_meshas
                    AND m.cuenta = v_cuenta;

                IF ( v_saldo IS NULL ) THEN
                    v_saldo := 0;
                END IF;
                registro.saldo := registro.saldo + v_saldo;
            END LOOP;

            v_total1 := v_total1 + registro.saldo;
            IF ( upper(registro.tipo) = 'D' ) THEN
                registro.titulo := '   ' || registro.titulo;
            END IF;

            IF ( upper(registro.tipo) = 'T' ) THEN
                registro.saldo := v_total1;
            END IF;

            PIPE ROW ( registro );
            IF ( upper(registro.tipo) = 'T' ) THEN
                registro.codigo := NULL;
                registro.titulo := '';
                registro.tipo := '';
                registro.saldo := 0;
                PIPE ROW ( registro );
            END IF;

        END LOOP;
    END sp_formato_320;

    FUNCTION sp_formato_320v2 (
        pin_id_cia  INTEGER,
        pin_periodo INTEGER,
        pin_meshas  INTEGER,
        pin_codigo  INTEGER
    ) RETURN tbl_rec_formato_320
        PIPELINED
    AS

        v_saldo  NUMERIC(16, 2) := 0;
        v_total1 NUMERIC(16, 2) := 0;
        v_cuenta VARCHAR2(16) := '';
        registro rec_formato_320 := rec_formato_320(NULL, NULL, NULL, NULL, NULL);
    BEGIN
        FOR rec_ganaperdihea IN (
            SELECT
                h.codigo,
                h.titulo,
                h.tipo,
                h.signo /*,D.Cuenta*/
            FROM
                ganaperdihea h
            WHERE
                    h.id_cia = pin_id_cia
                AND h.codigo <= pin_codigo
            ORDER BY
                h.codigo
        ) LOOP
            registro.codigo := rec_ganaperdihea.codigo;
            registro.titulo := rec_ganaperdihea.titulo;
            registro.tipo := rec_ganaperdihea.tipo;
            registro.signo := rec_ganaperdihea.signo;
            v_saldo := 0;
            registro.saldo := 0;
            FOR rec_ganaperdidet IN (
                SELECT
                    d.cuenta
                FROM
                    ganaperdidet d
                WHERE
                        d.id_cia = pin_id_cia
                    AND d.codigo = registro.codigo
                ORDER BY
                    cuenta
            ) LOOP
                v_cuenta := rec_ganaperdidet.cuenta;
                SELECT
                    SUM(
                        CASE
                            WHEN m.dh = 'H' THEN
                                m.haber01
                            ELSE
                                0
                        END
                    ) - SUM(
                        CASE
                            WHEN m.dh = 'D' THEN
                                m.debe01
                            ELSE
                                0
                        END
                    ) AS saldo
                INTO v_saldo
                FROM
                    movimientos m
                WHERE
                        m.id_cia = pin_id_cia
                    AND m.periodo = pin_periodo
                    AND m.mes <= pin_meshas
                    AND m.cuenta = v_cuenta;

                IF ( v_saldo IS NULL ) THEN
                    v_saldo := 0;
                END IF;
                registro.saldo := registro.saldo + v_saldo;
            END LOOP;

            v_total1 := v_total1 + registro.saldo;
            IF ( upper(registro.tipo) = 'D' ) THEN
                registro.titulo := '   ' || registro.titulo;
            END IF;

            IF ( upper(registro.tipo) = 'T' ) THEN
                registro.saldo := v_total1;
            END IF;

            IF registro.codigo = pin_codigo THEN
                PIPE ROW ( registro );
            END IF;
        END LOOP;
    END sp_formato_320v2;

    FUNCTION sp_formato_320v3 (
        pin_id_cia  INTEGER,
        pin_periodo INTEGER,
        pin_meshas  INTEGER,
        pin_codigo  INTEGER
    ) RETURN NUMBER AS
        v_resultado NUMBER;
    BEGIN
        BEGIN
            SELECT
                saldo
            INTO v_resultado
            FROM
                sp_formato_320(pin_id_cia, pin_periodo, pin_meshas)
            WHERE
                codigo = pin_codigo;

        EXCEPTION
            WHEN no_data_found THEN
                v_resultado := 0;
        END;

        RETURN v_resultado;
    END sp_formato_320v3;

END;

/

--------------------------------------------------------
--  DDL for Package Body PACK_ASIENTO_CIERRE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_ASIENTO_CIERRE" AS

    FUNCTION sp_buscar (
        pin_id_cia     NUMBER,
        pin_periodo    NUMBER,
        pin_tipocierre NUMBER
    ) RETURN datatable_buscar
        PIPELINED
    AS
        v_table datatable_buscar;
    BEGIN
        CASE
            WHEN pin_tipocierre = 0 THEN /* CLASE 9*/
                SELECT
                    p.cuenta,
                    p.nombre,
                    SUM(m.debe01) - SUM(m.haber01) AS saldo01,
                    SUM(m.debe02) - SUM(m.haber02) AS saldo02
                BULK COLLECT
                INTO v_table
                FROM
                    pcuentas       p
                    LEFT OUTER JOIN pcuentas_clase pc ON pc.id_cia = p.id_cia
                                                         AND pc.cuenta = p.cuenta
                                                         AND pc.clase = 1
                    INNER JOIN movimientos    m ON m.id_cia = p.id_cia
                                                AND p.cuenta = m.cuenta
                WHERE
                        p.id_cia = pin_id_cia
                    AND m.periodo = pin_periodo
                    AND ( substr(p.cuenta, 1, 1) = 9 )
                GROUP BY
                    p.cuenta,
                    p.nombre,
                    pc.swflag
                HAVING ( SUM(m.debe01) - SUM(m.haber01) ) <> 0
                       OR ( ( SUM(m.debe02) - SUM(m.haber02) ) <> 0
                            AND upper(pc.swflag) = 'S' )
                ORDER BY
                    p.cuenta;

                FOR registro IN 1..v_table.count LOOP
                    PIPE ROW ( v_table(registro) );
                END LOOP;

                RETURN;
            WHEN pin_tipocierre = 1 THEN /* COSTO DE VENTAS */
                SELECT
                    p.cuenta,
                    p.nombre,
                    SUM(m.debe01) - SUM(m.haber01) AS saldo01,
                    SUM(m.debe02) - SUM(m.haber02) AS saldo02
                BULK COLLECT
                INTO v_table
                FROM
                    pcuentas       p
                    LEFT OUTER JOIN pcuentas_clase pc ON pc.id_cia = p.id_cia
                                                         AND pc.cuenta = p.cuenta
                                                         AND pc.clase = 1
                    INNER JOIN movimientos    m ON m.id_cia = p.id_cia
                                                AND p.cuenta = m.cuenta
                WHERE
                        p.id_cia = pin_id_cia
                    AND m.periodo = pin_periodo
                    AND ( substr(p.cuenta, 1, 2) = 69 )
                GROUP BY
                    p.cuenta,
                    p.nombre,
                    pc.swflag
                HAVING ( SUM(m.debe01) - SUM(m.haber01) ) <> 0
                       OR ( ( SUM(m.debe02) - SUM(m.haber02) ) <> 0
                            AND upper(pc.swflag) = 'S' )
                ORDER BY
                    p.cuenta;

                FOR registro IN 1..v_table.count LOOP
                    PIPE ROW ( v_table(registro) );
                END LOOP;

                RETURN;
            WHEN pin_tipocierre = 2 THEN /* CUENTAS DE GASTOS */
                SELECT
                    p.cuenta,
                    p.nombre,
                    SUM(m.debe01) - SUM(m.haber01) AS saldo01,
                    SUM(m.debe02) - SUM(m.haber02) AS saldo02
                BULK COLLECT
                INTO v_table
                FROM
                    pcuentas       p
                    LEFT OUTER JOIN pcuentas_clase pc ON pc.id_cia = p.id_cia
                                                         AND pc.cuenta = p.cuenta
                                                         AND pc.clase = 1
                    INNER JOIN movimientos    m ON m.id_cia = p.id_cia
                                                AND p.cuenta = m.cuenta
                WHERE
                        p.id_cia = pin_id_cia
                    AND m.periodo = pin_periodo
                    AND ( substr(p.cuenta, 1, 2) BETWEEN 60 AND 68 )
                GROUP BY
                    p.cuenta,
                    p.nombre,
                    pc.swflag
                HAVING ( SUM(m.debe01) - SUM(m.haber01) ) <> 0
                       OR ( ( SUM(m.debe02) - SUM(m.haber02) ) <> 0
                            AND upper(pc.swflag) = 'S' )
                ORDER BY
                    p.cuenta;

                FOR registro IN 1..v_table.count LOOP
                    PIPE ROW ( v_table(registro) );
                END LOOP;

                RETURN;
            WHEN pin_tipocierre = 3 THEN /* CUENTAS DE INGRESO */
                SELECT
                    p.cuenta,
                    p.nombre,
                    SUM(m.debe01) - SUM(m.haber01) AS saldo01,
                    SUM(m.debe02) - SUM(m.haber02) AS saldo02
                BULK COLLECT
                INTO v_table
                FROM
                    pcuentas       p
                    LEFT OUTER JOIN pcuentas_clase pc ON pc.id_cia = p.id_cia
                                                         AND pc.cuenta = p.cuenta
                                                         AND pc.clase = 1
                    INNER JOIN movimientos    m ON m.id_cia = p.id_cia
                                                AND p.cuenta = m.cuenta
                WHERE
                        p.id_cia = pin_id_cia
                    AND m.periodo = pin_periodo
                    AND ( substr(p.cuenta, 1, 2) BETWEEN 70 AND 78 )
                GROUP BY
                    p.cuenta,
                    p.nombre,
                    pc.swflag
                HAVING ( SUM(m.debe01) - SUM(m.haber01) ) <> 0
                       OR ( ( SUM(m.debe02) - SUM(m.haber02) ) <> 0
                            AND upper(pc.swflag) = 'S' )
                ORDER BY
                    p.cuenta;

                FOR registro IN 1..v_table.count LOOP
                    PIPE ROW ( v_table(registro) );
                END LOOP;

                RETURN;
            WHEN pin_tipocierre = 4 THEN /* CUENTAS DE BALANCE */
                SELECT
                    p.cuenta,
                    p.nombre,
                    SUM(m.debe01) - SUM(m.haber01) AS saldo01,
                    SUM(m.debe02) - SUM(m.haber02) AS saldo02
                BULK COLLECT
                INTO v_table
                FROM
                    pcuentas       p
                    LEFT OUTER JOIN pcuentas_clase pc ON pc.id_cia = p.id_cia
                                                         AND pc.cuenta = p.cuenta
                                                         AND pc.clase = 1
                    INNER JOIN movimientos    m ON m.id_cia = p.id_cia
                                                AND p.cuenta = m.cuenta
                WHERE
                        p.id_cia = pin_id_cia
                    AND m.periodo = pin_periodo
                    AND ( substr(p.cuenta, 1, 2) BETWEEN 10 AND 59 )
                GROUP BY
                    p.cuenta,
                    p.nombre,
                    pc.swflag
                HAVING ( SUM(m.debe01) - SUM(m.haber01) ) <> 0
                       OR ( ( SUM(m.debe02) - SUM(m.haber02) ) <> 0
                            AND upper(pc.swflag) = 'S' )
                ORDER BY
                    p.cuenta;

                FOR registro IN 1..v_table.count LOOP
                    PIPE ROW ( v_table(registro) );
                END LOOP;

                RETURN;
        END CASE;
    END sp_buscar;

    PROCEDURE sp_genera_asiento (
        pin_id_cia    IN NUMBER,
        pin_periodo   IN NUMBER,
        pin_mes       IN NUMBER,
        pin_libro     IN VARCHAR2,
        pin_femisi    IN DATE,
        pin_coduser   IN VARCHAR2,
        pin_concep    IN VARCHAR2,
        pin_secuencia IN NUMBER,
        pin_tipcam    IN NUMBER,
        pin_cuenta    IN NUMBER,
        pin_moneda    IN VARCHAR2,
        pin_saldo01   IN NUMBER,
        pin_saldo02   IN NUMBER,
        pin_item      IN OUT INTEGER,
        pin_invierte  IN VARCHAR2,
        pout_message  OUT VARCHAR2
    ) AS

        v_importe NUMBER := 0;
        v_dh      VARCHAR2(1);
        v_item    INTEGER;
        v_tcamb01 NUMBER(16, 5);
        v_tcamb02 NUMBER(16, 5);
        v_debe    NUMBER(16, 2);
        v_debe01  NUMBER(16, 2);
        v_debe02  NUMBER(16, 2);
        v_haber   NUMBER(16, 2);
        v_haber01 NUMBER(16, 2);
        v_haber02 NUMBER(16, 2);
        v_impor01 NUMBER(16, 2);
        v_impor02 NUMBER(16, 2);
    BEGIN
        v_impor01 := 0;
        v_impor02 := 0;
        IF pin_moneda = 'PEN' THEN
            v_importe := pin_saldo01;
        ELSE
            v_importe := pin_saldo02;
        END IF;

        v_impor01 := pin_saldo01;
        v_impor02 := pin_saldo02;
        IF v_importe > 0 THEN
            v_dh := 'D';
        ELSE
            v_dh := 'H';
            v_importe := v_importe * -1;
            v_impor01 := v_impor01 * -1;
            v_impor02 := v_impor02 * -1;
        END IF;

        v_debe := 0;
        v_haber := 0;
        v_debe01 := 0;
        v_haber01 := 0;
        v_debe02 := 0;
        v_haber02 := 0;
        IF pin_invierte = 'S' THEN
            IF v_dh = 'D' THEN
                v_dh := 'H';
            ELSIF v_dh = 'H' THEN
                v_dh := 'D';
            END IF;
        END IF;

        IF v_dh = 'D' THEN
            IF pin_moneda = 'PEN' THEN
                v_debe := v_impor01;
            ELSE
                v_debe := v_impor02; -- SALDO USD
            END IF;

            v_debe01 := v_impor01;
            v_debe02 := v_impor02;
        ELSIF v_dh = 'H' THEN
            IF pin_moneda = 'PEN' THEN
                v_haber := v_impor01;
            ELSE
                v_haber := v_impor02; -- SALDO USD
            END IF;

            v_haber01 := v_impor01;
            v_haber02 := v_impor02;
        END IF;

        pin_item := pin_item + 1;
        IF pin_moneda = 'PEN' THEN
            v_tcamb01 := 1;
            IF pin_tipcam > 0 THEN
                v_tcamb02 := 1 / pin_tipcam;
            END IF;
        ELSE
            v_tcamb01 := pin_tipcam;
            v_tcamb02 := 1;
        END IF;

        INSERT INTO asiendet (
            id_cia,--01
            periodo,--02
            mes,--03
            libro,--04
            asiento,--05
            item,--06
            sitem,--07
            concep,--08
            fecha,--09
            tasien,--10
            topera,--11
            cuenta,--12
            dh,--13
            moneda,--14
            importe,--15
            impor01,--16
            impor02,--17
            debe,--18
            debe01,--19
            debe02,--20
            haber,--21
            haber01,--22
            haber02,--23
            tcambio01,--24
            tcambio02,--25
            ccosto,--26
            proyec,--27
            subcco,--28
            ctaalternativa,--29
            tipo,--30
            docume,--31
            codigo,--32
            razon,--33
            tident,--34
            dident,--35
            tdocum,--36
            serie,--37
            numero,--38
            fdocum,--39
            usuari,--40
            fcreac,--41
            factua,--42
            regcomcol,--43
            swprovicion,--44
            saldo,--45
            swgasoper,--46
            codporret,--47
            swchkconcilia--48
        ) VALUES (
            pin_id_cia,
            pin_periodo,
            pin_mes,
            pin_libro,
            pin_secuencia,
            pin_item,
            0,
            pin_concep,
            pin_femisi,
            66,
            '',
            pin_cuenta,
            v_dh,
            pin_moneda,
            abs(v_importe),
            abs(v_impor01),
            abs(v_impor02),
            v_debe,
            v_debe01,
            v_debe02,
            v_haber,
            v_haber01,
            v_haber02,
            v_tcamb01,
            v_tcamb02,
            '',
            '',
            '',
            '',
            0,
            - 1,
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            NULL,
            pin_coduser,
            current_timestamp,
            current_timestamp,
            0,
            '',
            abs(v_importe),
            0,
            '',
            ''
        );

        COMMIT;
        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'SUCCESS'
            )
        INTO pout_message
        FROM
            dual;

    EXCEPTION
        WHEN OTHERS THEN
            pout_message := 'mensaje : '
                            || sqlerrm
                            || ' codigo :'
                            || sqlcode;
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pout_message
                )
            INTO pout_message
            FROM
                dual;

    END sp_genera_asiento;

    PROCEDURE sp_genera (
        pin_id_cia     IN NUMBER,
        pin_libro      IN VARCHAR2,
        pin_femisi     IN DATE,
        pin_coduser    IN VARCHAR2,
        pin_tccompra   IN NUMBER,
        pin_tcventa    IN NUMBER,
        pin_tipocierre IN NUMBER,
        pout_message   OUT VARCHAR2
    ) AS

        pin_mes          NUMBER := extract(MONTH FROM pin_femisi);
        pin_periodo      NUMBER := extract(YEAR FROM pin_femisi);
        pout_mensaje     VARCHAR2(1000 CHAR);
        CURSOR cur_detalleasiento IS
        SELECT
            cuenta,
            nombre,
            saldo01,
            saldo02
        FROM
            TABLE ( pack_asiento_cierre.sp_buscar(pin_id_cia, pin_periodo, pin_tipocierre) );

        v_mensaje        VARCHAR2(1000 CHAR) := '';
        o                json_object_t;
        v_secuencia      NUMBER := 0;
        v_maximo         NUMBER := 0;
        v_razonc         VARCHAR2(100);
        v_tipmon         VARCHAR2(5);
        v_series         VARCHAR2(5);
        v_numdoc         NUMBER;
        v_descri         VARCHAR2(100);
        v_importe        NUMBER(16, 5) := 0;
        v_tc             NUMBER(16, 5) := 0;
        v_dh             VARCHAR2(1);
        v_concepto       VARCHAR2(70) := '';
        v_tipcam         NUMBER := 0;
        v_item           NUMBER;
        v_cta_acu01      NUMBER(16, 2);
        v_cta_acu02      NUMBER(16, 2);
        v_cta_des01      NUMBER(16, 2);
        v_cta_des02      NUMBER(16, 2);
        v_f226           VARCHAR2(20);
        v_f227           VARCHAR2(160);
        v_f228           VARCHAR2(160);
        v_f229           VARCHAR2(20);
        v_f230           VARCHAR2(20);
        v_f231           VARCHAR2(20);
        v_f232           VARCHAR2(20);
        v_genera_asiento VARCHAR2(1 CHAR) := 'N';
        pin_item         NUMBER;
        v_nro_cuenta     NUMBER;
    BEGIN
        pout_message := '';
        v_descri :=
            CASE
                WHEN pin_tipocierre = 0 THEN
                    'Cierre de la Clase 9'
                WHEN pin_tipocierre = 1 THEN
                    'Cierre de Costo de Ventas'
                WHEN pin_tipocierre = 2 THEN
                    'Cierre de Cuentas de Gastos'
                WHEN pin_tipocierre = 3 THEN
                    'Cierre de Cuentas de Ingresos'
                WHEN pin_tipocierre = 4 THEN
                    'Cierre de Balance'
            END;

        -- 1 : MODULO CONTABILIDAD
        sp_chequea_mes_proceso(pin_id_cia, pin_periodo, pin_mes, 1, v_mensaje);
        o := json_object_t.parse(v_mensaje);
        IF ( o.get_number('status') <> 1.0 ) THEN
            pout_mensaje := o.get_string('message');
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;

        sp00_saca_secuencia_libro(pin_id_cia, pin_libro, pin_periodo, pin_mes, pin_coduser,
                                 1, v_secuencia);
        dbms_output.put_line('v_secuencia ==> ' || v_secuencia);
        DELETE FROM movimientos
        WHERE
                id_cia = pin_id_cia
            AND periodo = pin_periodo
            AND mes = pin_mes
            AND libro = pin_libro
            AND asiento = v_secuencia;

        DELETE FROM asiendet
        WHERE
                id_cia = pin_id_cia
            AND periodo = pin_periodo
            AND mes = pin_mes
            AND libro = pin_libro
            AND asiento = v_secuencia;

        DELETE FROM asienhea
        WHERE
                id_cia = pin_id_cia
            AND periodo = pin_periodo
            AND mes = pin_mes
            AND libro = pin_libro
            AND asiento = v_secuencia;

        COMMIT;
        v_concepto := 'Asiento de ' || v_descri;
        INSERT INTO asienhea (
            id_cia,
            periodo,
            mes,
            libro,
            asiento,
            concep,
            tasien,
            moneda,
            fecha,
            tcamb01,
            tcamb02,
            situac,
            usuari,
            fcreac,
            factua
        ) VALUES (
            pin_id_cia,
            pin_periodo,
            pin_mes,
            pin_libro,
            v_secuencia,
            v_concepto,
            66,
            'PEN',
            pin_femisi,
            0,
            0,
            1,
            pin_coduser,
            current_timestamp,
            current_timestamp
        );

        v_item := 0;
        pin_item := 0;
        FOR reg_asiendet IN cur_detalleasiento LOOP
            v_genera_asiento := 'S';
            v_tc := 0;
            IF reg_asiendet.saldo02 = 0 THEN
                v_tc := 0;
            ELSE
                v_tc := reg_asiendet.saldo01 / reg_asiendet.saldo02;
            END IF;

            -- GENERA LOS ITEMS DEL ASIENTO
            pack_asiento_cierre.sp_genera_asiento(pin_id_cia, pin_periodo, pin_mes, pin_libro, pin_femisi,
                                                 pin_coduser, v_concepto, v_secuencia, v_tc, reg_asiendet.cuenta,
                                                 'PEN', reg_asiendet.saldo01, reg_asiendet.saldo02, pin_item, 'S',
                                                 v_mensaje);

            o := json_object_t.parse(v_mensaje);
            IF ( o.get_number('status') <> 1.0 ) THEN
                pout_mensaje := o.get_string('message');
                RAISE pkg_exceptionuser.ex_error_inesperado;
            END IF;

        END LOOP;

        CASE
            WHEN
                pin_tipocierre = 0
                AND v_genera_asiento = 'S'
            THEN
                dbms_output.put_line('INICIANDO CIERRE DE LA CUENTA 9');
                BEGIN
                    SELECT
                        nvl(f.cuenta, 'ND')
                    INTO v_f226
                    FROM
                        factor f
                    WHERE
                            f.id_cia = pin_id_cia
                        AND f.codfac = 226
                        AND EXISTS (
                            SELECT
                                p.*
                            FROM
                                pcuentas p
                            WHERE
                                    p.id_cia = f.id_cia
                                AND p.cuenta = f.cuenta
                        );

                EXCEPTION
                    WHEN no_data_found THEN
                        pout_mensaje := 'NO EXISTE UNA CUENTA CONTABLE DE DESTINO VALIDA ( QUE EXISTA EN EL PLAN DE CUENTAS ), PARA GENERAR EL ASIENTO DE CIERRE DE LA CLASE 9 - '
                        || 'REVISAR, EL FACTOR 226';
                        RAISE pkg_exceptionuser.ex_error_inesperado;
                END;

                v_cta_acu01 := 0;
                v_cta_acu02 := 0;
                v_cta_des01 := 0;
                v_cta_des02 := 0;
                BEGIN
                    SELECT
                        SUM(nvl(saldo01, 0)),
                        SUM(nvl(saldo02, 0))
                    INTO
                        v_cta_acu01,
                        v_cta_acu02
                    FROM
                        pack_asiento_cierre.sp_buscar(pin_id_cia, pin_periodo, pin_tipocierre)
                    WHERE
                        cuenta NOT IN ( v_f226 );

                EXCEPTION
                    WHEN no_data_found THEN
                        v_cta_acu01 := 0;
                        v_cta_acu02 := 0;
                END;

                BEGIN
                    SELECT
                        SUM(nvl(saldo01, 0)),
                        SUM(nvl(saldo02, 0))
                    INTO
                        v_cta_des01,
                        v_cta_des02
                    FROM
                        pack_asiento_cierre.sp_buscar(pin_id_cia, pin_periodo, pin_tipocierre)
                    WHERE
                        cuenta IN ( v_f226 );

                EXCEPTION
                    WHEN no_data_found THEN
                        v_cta_des01 := 0;
                        v_cta_des02 := 0;
                END;

                v_cta_des01 := nvl(v_cta_des01, 0) + nvl(v_cta_acu01, 0);
                v_cta_des02 := nvl(v_cta_des02, 0) + nvl(v_cta_acu02, 0);
                IF v_cta_des02 = 0 THEN
                    v_tipcam := 0;
                ELSE
                    v_tipcam := v_cta_des01 / v_cta_des02;
                END IF;

                pack_asiento_cierre.sp_genera_asiento(pin_id_cia, pin_periodo, pin_mes, pin_libro, pin_femisi,
                                                     pin_coduser, v_concepto, v_secuencia, v_tipcam, v_f226,
                                                     'PEN', v_cta_des01, v_cta_des02, pin_item, 'N',
                                                     v_mensaje);

                o := json_object_t.parse(v_mensaje);
                IF ( o.get_number('status') <> 1.0 ) THEN
                    pout_mensaje := o.get_string('message');
                    RAISE pkg_exceptionuser.ex_error_inesperado;
                END IF;

            WHEN
                pin_tipocierre = 1
                AND v_genera_asiento = 'S'
            THEN
                dbms_output.put_line('INICIANDO CIERRE DE COSTO DE VENTA');
                BEGIN
                    SELECT
                        nvl(f.vstrg, 'ND')
                    INTO v_f227
                    FROM
                        factor f
                    WHERE
                            f.id_cia = pin_id_cia
                        AND f.codfac = 227
                        AND EXISTS (
                            SELECT
                                p.*
                            FROM
                                pcuentas p
                            WHERE
                                    p.id_cia = f.id_cia
                                AND p.cuenta IN (
                                    SELECT
                                        regexp_substr(f.vstrg, '[^ ]+', 1, level)
                                    FROM
                                        dual
                                    CONNECT BY
                                        regexp_substr(f.vstrg, '[^ ]+', 1, level) IS NOT NULL
                                )
                        );

                EXCEPTION
                    WHEN no_data_found THEN
                        pout_mensaje := 'NO EXISTE UNA CUENTA CONTABLE DE ACUMULADA VALIDA ( QUE EXISTA EN EL PLAN DE CUENTAS ), PARA GENERAR EL ASIENTO DE CIERRE DEL COSTO DE VENTA - '
                        || 'REVISAR, EL FACTOR 227';
                        RAISE pkg_exceptionuser.ex_error_inesperado;
                END;

                BEGIN
                    SELECT
                        nvl(f.vstrg, 'ND')
                    INTO v_f228
                    FROM
                        factor f
                    WHERE
                            f.id_cia = pin_id_cia
                        AND f.codfac = 228
                        AND EXISTS (
                            SELECT
                                p.*
                            FROM
                                pcuentas p
                            WHERE
                                    p.id_cia = f.id_cia
                                AND p.cuenta IN (
                                    SELECT
                                        regexp_substr(f.vstrg, '[^ ]+', 1, level)
                                    FROM
                                        dual
                                    CONNECT BY
                                        regexp_substr(f.vstrg, '[^ ]+', 1, level) IS NOT NULL
                                )
                        );

                EXCEPTION
                    WHEN no_data_found THEN
                        pout_mensaje := 'NO EXISTE UNA CUENTA CONTABLE DE DESTINO VALIDA ( QUE EXISTA EN EL PLAN DE CUENTAS ), PARA GENERAR EL ASIENTO DE CIERRE DEL COSTO DE VENTA '
                        || 'REVISAR, EL FACTOR 228';
                        RAISE pkg_exceptionuser.ex_error_inesperado;
                END;

                v_cta_acu01 := 0;
                v_cta_acu02 := 0;
                v_cta_des01 := 0;
                v_cta_des02 := 0;
                BEGIN
                    SELECT
                        SUM(nvl(saldo01, 0)),
                        SUM(nvl(saldo02, 0))
                    INTO
                        v_cta_acu01,
                        v_cta_acu02
                    FROM
                        pack_asiento_cierre.sp_buscar(pin_id_cia, pin_periodo, pin_tipocierre)
                    WHERE
                        cuenta IN (
                            SELECT
                                regexp_substr(v_f227, '[^ ]+', 1, level)
                            FROM
                                dual
                            CONNECT BY
                                regexp_substr(v_f227, '[^ ]+', 1, level) IS NOT NULL
                        );

                EXCEPTION
                    WHEN no_data_found THEN
                        v_cta_acu01 := 0;
                        v_cta_acu02 := 0;
                END;

                BEGIN
                    SELECT
                        SUM(nvl(saldo01, 0)),
                        SUM(nvl(saldo02, 0))
                    INTO
                        v_cta_des01,
                        v_cta_des02
                    FROM
                        pack_asiento_cierre.sp_buscar(pin_id_cia, pin_periodo, pin_tipocierre)
                    WHERE
                        cuenta IN (
                            SELECT
                                regexp_substr(v_f228, '[^ ]+', 1, level)
                            FROM
                                dual
                            CONNECT BY
                                regexp_substr(v_f228, '[^ ]+', 1, level) IS NOT NULL
                        );

                EXCEPTION
                    WHEN no_data_found THEN
                        v_cta_des01 := 0;
                        v_cta_des02 := 0;
                END;

                -- PARTIENDO SEGUN LAS CUENTA DE DESTINO
                BEGIN
                    SELECT
                        COUNT(0)
                    INTO v_nro_cuenta
                    FROM
                        (
                            SELECT
                                regexp_substr(v_f228, '[^ ]+', 1, level) AS cuenta
                            FROM
                                dual
                            CONNECT BY
                                regexp_substr(v_f228, '[^ ]+', 1, level) IS NOT NULL
                        );

                END;

                v_cta_des01 := nvl(v_cta_des01, 0) + nvl(v_cta_acu01, 0);
                v_cta_des02 := nvl(v_cta_des02, 0) + nvl(v_cta_acu02, 0);
                IF v_cta_des01 <> 0 THEN
                    v_cta_des01 := v_cta_des01 / v_nro_cuenta;
                END IF;
                IF v_cta_des02 <> 0 THEN
                    v_cta_des02 := v_cta_des02 / v_nro_cuenta;
                END IF;
                IF v_cta_des02 = 0 THEN
                    v_tipcam := 0;
                ELSE
                    v_tipcam := v_cta_des01 / v_cta_des02;
                END IF;

                FOR i IN (
                    SELECT
                        regexp_substr(v_f228, '[^ ]+', 1, level) AS cuenta
                    FROM
                        dual
                    CONNECT BY
                        regexp_substr(v_f228, '[^ ]+', 1, level) IS NOT NULL
                ) LOOP
                    pack_asiento_cierre.sp_genera_asiento(pin_id_cia, pin_periodo, pin_mes, pin_libro, pin_femisi,
                                                         pin_coduser, v_concepto, v_secuencia, v_tipcam, i.cuenta,
                                                         'PEN', v_cta_des01, v_cta_des02, pin_item, 'N',
                                                         v_mensaje);

                    o := json_object_t.parse(v_mensaje);
                    IF ( o.get_number('status') <> 1.0 ) THEN
                        pout_mensaje := o.get_string('message');
                        RAISE pkg_exceptionuser.ex_error_inesperado;
                    END IF;

                END LOOP;

            WHEN
                pin_tipocierre = 2
                AND v_genera_asiento = 'S'
            THEN
                BEGIN
                    SELECT
                        f.cuenta
                    INTO v_f229
                    FROM
                        factor f
                    WHERE
                            f.id_cia = pin_id_cia
                        AND f.codfac = 229
                        AND EXISTS (
                            SELECT
                                p.*
                            FROM
                                pcuentas p
                            WHERE
                                    p.id_cia = f.id_cia
                                AND p.cuenta = f.cuenta
                        );

                EXCEPTION
                    WHEN no_data_found THEN
                        pout_mensaje := 'NO EXISTE UNA CUENTA CONTABLE DE DESTINO VALIDA ( QUE EXISTA EN EL PLAN DE CUENTAS ), PARA GENERAR EL ASIENTO DE CIERRE DEL GASTOS DE VENTA '
                                        || chr(13)
                                        || 'REVISAR, EL FACTOR 229';
                        RAISE pkg_exceptionuser.ex_error_inesperado;
                END;

                v_cta_acu01 := 0;
                v_cta_acu02 := 0;
                v_cta_des01 := 0;
                v_cta_des02 := 0;
                BEGIN
                    SELECT
                        SUM(nvl(saldo01, 0)),
                        SUM(nvl(saldo02, 0))
                    INTO
                        v_cta_acu01,
                        v_cta_acu02
                    FROM
                        pack_asiento_cierre.sp_buscar(pin_id_cia, pin_periodo, pin_tipocierre)
                    WHERE
                        cuenta NOT IN ( v_f229 );

                EXCEPTION
                    WHEN no_data_found THEN
                        v_cta_acu01 := 0;
                        v_cta_acu02 := 0;
                END;

                BEGIN
                    SELECT
                        SUM(nvl(saldo01, 0)),
                        SUM(nvl(saldo02, 0))
                    INTO
                        v_cta_des01,
                        v_cta_des02
                    FROM
                        pack_asiento_cierre.sp_buscar(pin_id_cia, pin_periodo, pin_tipocierre)
                    WHERE
                        cuenta IN ( v_f229 );

                EXCEPTION
                    WHEN no_data_found THEN
                        v_cta_des01 := 0;
                        v_cta_des02 := 0;
                END;

                v_cta_des01 := nvl(v_cta_des01, 0) + nvl(v_cta_acu01, 0);
                v_cta_des02 := nvl(v_cta_des02, 0) + nvl(v_cta_acu02, 0);
                IF v_cta_des02 = 0 THEN
                    v_tipcam := 0;
                ELSE
                    v_tipcam := v_cta_des01 / v_cta_des02;
                END IF;

                pack_asiento_cierre.sp_genera_asiento(pin_id_cia, pin_periodo, pin_mes, pin_libro, pin_femisi,
                                                     pin_coduser, v_concepto, v_secuencia, v_tipcam, v_f229,
                                                     'PEN', v_cta_des01, v_cta_des02, pin_item, 'N',
                                                     v_mensaje);

                o := json_object_t.parse(v_mensaje);
                IF ( o.get_number('status') <> 1.0 ) THEN
                    pout_mensaje := o.get_string('message');
                    RAISE pkg_exceptionuser.ex_error_inesperado;
                END IF;

            WHEN
                pin_tipocierre = 3
                AND v_genera_asiento = 'S'
            THEN
                BEGIN
                    SELECT
                        f.cuenta
                    INTO v_f230
                    FROM
                        factor f
                    WHERE
                            f.id_cia = pin_id_cia
                        AND f.codfac = 230
                        AND EXISTS (
                            SELECT
                                p.*
                            FROM
                                pcuentas p
                            WHERE
                                    p.id_cia = f.id_cia
                                AND p.cuenta = f.cuenta
                        );

                EXCEPTION
                    WHEN no_data_found THEN
                        pout_mensaje := 'NO EXISTE UNA CUENTA CONTABLE DE DESTINO VALIDA ( QUE EXISTA EN EL PLAN DE CUENTAS ), PARA GENERAR EL ASIENTO DE CIERRE DE CUENTAS DE INGRESOS '
                                        || chr(13)
                                        || 'REVISAR, EL FACTOR 230';
                        RAISE pkg_exceptionuser.ex_error_inesperado;
                END;

                v_cta_acu01 := 0;
                v_cta_acu02 := 0;
                v_cta_des01 := 0;
                v_cta_des02 := 0;
                BEGIN
                    SELECT
                        SUM(nvl(saldo01, 0)),
                        SUM(nvl(saldo02, 0))
                    INTO
                        v_cta_acu01,
                        v_cta_acu02
                    FROM
                        pack_asiento_cierre.sp_buscar(pin_id_cia, pin_periodo, pin_tipocierre)
                    WHERE
                        cuenta NOT IN ( v_f230 );

                EXCEPTION
                    WHEN no_data_found THEN
                        v_cta_acu01 := 0;
                        v_cta_acu02 := 0;
                END;

                BEGIN
                    SELECT
                        SUM(nvl(saldo01, 0)),
                        SUM(nvl(saldo02, 0))
                    INTO
                        v_cta_des01,
                        v_cta_des02
                    FROM
                        pack_asiento_cierre.sp_buscar(pin_id_cia, pin_periodo, pin_tipocierre)
                    WHERE
                        cuenta IN ( v_f230 );

                EXCEPTION
                    WHEN no_data_found THEN
                        v_cta_des01 := 0;
                        v_cta_des02 := 0;
                END;

                v_cta_des01 := nvl(v_cta_des01, 0) + nvl(v_cta_acu01, 0);
                v_cta_des02 := nvl(v_cta_des02, 0) + nvl(v_cta_acu02, 0);
                IF v_cta_des02 = 0 THEN
                    v_tipcam := 0;
                ELSE
                    v_tipcam := v_cta_des01 / v_cta_des02;
                END IF;

                pack_asiento_cierre.sp_genera_asiento(pin_id_cia, pin_periodo, pin_mes, pin_libro, pin_femisi,
                                                     pin_coduser, v_concepto, v_secuencia, v_tipcam, v_f230,
                                                     'PEN', v_cta_des01, v_cta_des02, pin_item, 'N',
                                                     v_mensaje);

                o := json_object_t.parse(v_mensaje);
                IF ( o.get_number('status') <> 1.0 ) THEN
                    pout_mensaje := o.get_string('message');
                    RAISE pkg_exceptionuser.ex_error_inesperado;
                END IF;

            WHEN
                pin_tipocierre = 4
                AND v_genera_asiento = 'S'
            THEN
                BEGIN
                    SELECT
                        f.cuenta
                    INTO v_f231
                    FROM
                        factor f
                    WHERE
                            f.id_cia = pin_id_cia
                        AND f.codfac = 231
                        AND EXISTS (
                            SELECT
                                p.*
                            FROM
                                pcuentas p
                            WHERE
                                    p.id_cia = f.id_cia
                                AND p.cuenta = f.cuenta
                        );

                EXCEPTION
                    WHEN no_data_found THEN
                        pout_mensaje := 'NO EXISTE UNA CUENTA CONTABLE DE DESTINO VALIDA ( QUE EXISTA EN EL PLAN DE CUENTAS ), PARA GENERAR EL ASIENTO DE CIERRE DE CUENTAS DE BALANCES '
                                        || chr(13)
                                        || 'REVISAR, EL FACTOR 231';
                        RAISE pkg_exceptionuser.ex_error_inesperado;
                END;

                v_cta_acu01 := 0;
                v_cta_acu02 := 0;
                v_cta_des01 := 0;
                v_cta_des02 := 0;
                BEGIN
                    SELECT
                        SUM(nvl(saldo01, 0)),
                        SUM(nvl(saldo02, 0))
                    INTO
                        v_cta_acu01,
                        v_cta_acu02
                    FROM
                        pack_asiento_cierre.sp_buscar(pin_id_cia, pin_periodo, pin_tipocierre)
                    WHERE
                        cuenta NOT IN ( v_f231 );

                EXCEPTION
                    WHEN no_data_found THEN
                        v_cta_acu01 := 0;
                        v_cta_acu02 := 0;
                END;

                BEGIN
                    SELECT
                        SUM(nvl(saldo01, 0)),
                        SUM(nvl(saldo02, 0))
                    INTO
                        v_cta_des01,
                        v_cta_des02
                    FROM
                        pack_asiento_cierre.sp_buscar(pin_id_cia, pin_periodo, pin_tipocierre)
                    WHERE
                        cuenta IN ( v_f231 );

                EXCEPTION
                    WHEN no_data_found THEN
                        v_cta_des01 := 0;
                        v_cta_des02 := 0;
                END;

                v_cta_des01 := nvl(v_cta_des01, 0) + nvl(v_cta_acu01, 0);
                v_cta_des02 := nvl(v_cta_des02, 0) + nvl(v_cta_acu02, 0);
                IF v_cta_des02 = 0 THEN
                    v_tipcam := 0;
                ELSE
                    v_tipcam := v_cta_des01 / v_cta_des02;
                END IF;

                pack_asiento_cierre.sp_genera_asiento(pin_id_cia, pin_periodo, pin_mes, pin_libro, pin_femisi,
                                                     pin_coduser, v_concepto, v_secuencia, v_tipcam, v_f231,
                                                     'PEN', v_cta_des01, v_cta_des02, pin_item, 'N',
                                                     v_mensaje);

                o := json_object_t.parse(v_mensaje);
                IF ( o.get_number('status') <> 1.0 ) THEN
                    pout_mensaje := o.get_string('message');
                    RAISE pkg_exceptionuser.ex_error_inesperado;
                END IF;

            ELSE
                SELECT
                    JSON_OBJECT(
                        'status' VALUE 1.0,
                                'message' VALUE 'EL ASIENTO DE '
                                                || upper(v_descri)
                                                || ' NO SE HA GENERADO, PORQUE NO HAY CUENTAS POR SALDAR'
                    )
                INTO pout_message
                FROM
                    dual;

                DELETE FROM asienhea
                WHERE
                        id_cia = pin_id_cia
                    AND periodo = pin_periodo
                    AND mes = pin_mes
                    AND libro = pin_libro
                    AND asiento = v_secuencia;

                RETURN;
        END CASE;

        sp_contabilizar_asiento(pin_id_cia, pin_libro, pin_periodo, pin_mes, v_secuencia,
                               pin_coduser, v_mensaje);
        o := json_object_t.parse(v_mensaje);
        dbms_output.put_line(v_mensaje);
        IF ( o.get_number('status') <> 1.0 ) THEN
            pout_mensaje := o.get_string('message');
            RAISE pkg_exceptionuser.ex_error_inesperado;
        ELSE
            UPDATE asienhea
            SET
                situac = 2
            WHERE
                    id_cia = pin_id_cia
                AND periodo = pin_periodo
                AND mes = pin_mes
                AND libro = pin_libro
                AND asiento = v_secuencia;

        END IF;

        pout_mensaje := 'ASIENTO DE '
                        || upper(v_descri)
                        || ' SE GENERO Y CONTABILIZO CORRECTAMENTE '
                        || pin_libro
                        || '-'
                        || pin_periodo
                        || '-'
                        || pin_mes
                        || '-'
                        || pin_libro
                        || '-'
                        || v_secuencia;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE pout_mensaje
            )
        INTO pout_message
        FROM
            dual;
        COMMIT;

    EXCEPTION
        WHEN pkg_exceptionuser.ex_error_inesperado THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE pout_mensaje
                )
            INTO pout_message
            FROM
                dual;

        WHEN OTHERS THEN
            pout_mensaje := 'mensaje : '
                            || sqlerrm
                            || ' codigo :'
                            || sqlcode;
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pout_mensaje
                )
            INTO pout_message
            FROM
                dual;

    END sp_genera;

END;

/

--------------------------------------------------------
--  DDL for Function SP001_TIENE_CREDITO_SIMPLE
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP001_TIENE_CREDITO_SIMPLE" (
    pin_id_cia         IN   NUMBER,
    pin_codcli         IN   VARCHAR2,
    pin_tipdoc         IN   NUMBER,
    pin_codpag         IN   NUMBER,
    pin_totdoc         IN   NUMERIC,
    pin_tipcam         IN   NUMERIC,
    pin_tipmon         IN   VARCHAR2,
    pin_swmuestramsj   IN   VARCHAR2
) RETURN tbl_creditosimple
    PIPELINED
AS

    creditosimple    rec_creditosimple := rec_creditosimple(NULL, NULL, NULL, NULL, NULL,
                  NULL, NULL, NULL, NULL, NULL,
                  NULL, NULL, NULL, NULL, NULL,
                  NULL, NULL, NULL, NULL, NULL,
                  NULL, NULL, NULL, NULL);
    v_strsimbolo     VARCHAR2(5) := '';
    v_monlimcred     VARCHAR2(5) := 'USD';
    v_strlimcre      VARCHAR2(20) := '';
    v_strsaldo       VARCHAR2(20) := '';
    v_strdispon      VARCHAR2(20) := '';
    v_strtotal       VARCHAR2(20) := '';
    v_swchklimcre    VARCHAR2(10) := '';
    v_vercredcer     VARCHAR2(02) := '';
    v_desdoc         VARCHAR2(30) := '';
    v_strresultado   VARCHAR2(1) := 'S';
    v_descpag        VARCHAR2(50) := '';
    v_limcre2        NUMBER(9, 2) := 0;
    v_saldo          NUMBER(16, 2) := 0;
    v_total          NUMBER(16, 5) := 0;
    v_tipcam         NUMERIC(9, 6) := 0;
    v_mensaje        VARCHAR2(1000) := '';
    CURSOR cur_cliente (
        wid_cia   NUMBER,
        wcodcli   VARCHAR2
    ) IS
    SELECT
        c.codcli     AS codcli,
        c.razonc     AS razonc,
        c.dident     AS ruc,
        c.codpag,
        ft.vstrg     AS monlimcred,
        c.limcre2,
        cc.codpag    AS codpag2,
        cp.despag    AS despag2,
        c.observ,
        ccf.descri   AS desfidelidad,
        cv.codigo    AS verlimcred,
        (
            SELECT
                SUM(
                    CASE
                        WHEN ft.vstrg = dc.tipmon THEN
                            (dc.saldo * td.signo)
                        ELSE
                            CASE
                                WHEN dc.tipmon = 'PEN' THEN
                                    (dc.saldo * td.signo) / dc.tipcam
                                ELSE
                                    (dc.saldo * td.signo) * dc.tipcam
                            END
                    END
                )
            FROM
                dcta100        dc
                LEFT OUTER JOIN tdoccobranza   td ON td.id_cia = dc.id_cia
                                                   AND td.tipdoc = dc.tipdoc
            WHERE
                dc.id_cia = c.id_cia
                AND dc.codcli = c.codcli
                AND dc.saldo <> 0
            GROUP BY
                c.codcli
        ) AS saldo
    FROM
        cliente                c
        LEFT OUTER JOIN identidad              i ON i.id_cia = c.id_cia
                                       AND i.tident = c.tident
        LEFT OUTER JOIN cliente_codpag         cc ON cc.id_cia = c.id_cia
                                             AND cc.codcli = c.codcli
                                             AND cc.swdefaul = 'S'
        LEFT OUTER JOIN c_pago                 cp ON cp.id_cia = c.id_cia
                                     AND cp.codpag = cc.codpag
                                     AND upper(cp.swacti) = 'S'
        LEFT OUTER JOIN factor                 ft ON ft.id_cia = c.id_cia
                                     AND ft.codfac = 311  --- MONEDA DE LIMITE DE CREDITO CLIENTES ---
        LEFT OUTER JOIN cliente_clase          cf ON cf.id_cia = c.id_cia
                                            AND cf.tipcli = 'A'
                                            AND cf.codcli = c.codcli
                                            AND cf.clase = 29 -- FIDELIDAD---
        LEFT OUTER JOIN cliente_clase          cv ON cv.id_cia = c.id_cia
                                            AND cv.tipcli = 'A'
                                            AND cv.codcli = c.codcli
                                            AND cv.clase = 26 --VERIFICA CREDITO CERRADO DEFAULT S ---
        LEFT OUTER JOIN clase_cliente_codigo   ccf ON ccf.id_cia = c.id_cia
                                                    AND ccf.tipcli = cf.tipcli
                                                    AND ccf.clase = cf.clase
                                                    AND ccf.codigo = cf.codigo
    WHERE
        c.id_cia = wid_cia
        AND c.codcli = wcodcli
    FETCH NEXT 1 ROWS ONLY;

BEGIN
    v_tipcam := pin_tipcam;
    v_strresultado := 'S';
    v_mensaje := '';
    FOR registro IN cur_cliente(pin_id_cia, pin_codcli) LOOP
        v_swchklimcre := 'S';
        IF ( registro.verlimcred IS NULL ) THEN
            v_vercredcer := 'S';
        ELSE
            v_vercredcer := registro.verlimcred;
        END IF;

        IF ( registro.monlimcred IS NULL ) THEN
            v_monlimcred := 'USD';
            v_strsimbolo := 'US$';
        END IF;

        IF ( upper(registro.monlimcred) = 'PEN' ) THEN
            v_strsimbolo := 'S/.';
        END IF;

        IF ( upper(registro.monlimcred) = 'USD' ) THEN
            v_strsimbolo := 'US$';
        END IF;

        v_limcre2 := nvl(registro.limcre2, 0);
        v_saldo := nvl(registro.saldo, 0);
        BEGIN
       /*SACA DATOS DEL DOCUMENTO*/
            SELECT
                dt.descri
            INTO v_desdoc
            FROM
                documentos_tipo dt
            WHERE
                dt.id_cia = pin_id_cia
                AND dt.tipdoc = pin_tipdoc;

        EXCEPTION
            WHEN no_data_found THEN
                v_desdoc := '';
        END;

        IF ( NOT ( pin_tipdoc IN (
            0,
            7,
            8
        ) ) ) THEN
            IF ( ( pin_tipcam IS NULL ) OR ( pin_tipcam = 0 ) ) THEN
                v_tipcam := 1;
            END IF;

            IF ( pin_tipmon = v_monlimcred ) THEN
                v_total := nvl(pin_totdoc, 0);
            ELSE
                IF ( pin_tipmon = 'PEN' ) THEN
                    v_total := nvl(pin_totdoc, 0) / v_tipcam;
                ELSE
                    v_total := nvl(pin_totdoc, 0) * v_tipcam;
                END IF;
            END IF;

        END IF;
/*SE SACA LA DESCRICION DE LA CONDICION DE PAGO DEL DOCUMENTO */

        BEGIN
            SELECT
                c.despag,
                sc.valor
            INTO
                v_descpag,
                v_swchklimcre
            FROM
                c_pago         c
                LEFT OUTER JOIN c_pago_clase   sc ON sc.id_cia = c.id_cia
                                                   AND sc.codpag = c.codpag
                                                   AND sc.codigo = 2 -- CHEQUEA LIMITE DE CREDITO --
            WHERE
                c.id_cia = pin_id_cia
                AND c.codpag = pin_codpag;

        EXCEPTION
            WHEN no_data_found THEN
                v_descpag := '';
                v_swchklimcre := '';
        END;

        v_swchklimcre := nvl(v_swchklimcre, 'S');
        v_swchklimcre := upper(v_swchklimcre);
        IF ( upper(v_swchklimcre) = 'S' ) THEN
            IF ( ( v_vercredcer <> 'N' ) AND ( pin_codpag = 0 ) ) THEN
                v_strresultado := 'N';
                v_mensaje := 'EL CLIENTE '
                             || registro.codcli
                             || '-'
                             || registro.razonc
                             || ' POSEE EL CRÉDITO CERRADO';

            ELSE
                IF ( ( v_limcre2 - v_saldo ) < v_total ) THEN

                    v_strresultado := 'N';
                    SELECT
                        sp000_ajusta_string(CAST(CAST(v_limcre2 AS NUMBER(16, 2)) AS VARCHAR2(15)), 15, ' ', 'R')
                    INTO v_strlimcre
                    FROM
                        dual;

                    SELECT
                        sp000_ajusta_string(CAST(CAST(v_saldo AS NUMBER(16, 2)) AS VARCHAR2(15)), 15, ' ', 'R')
                    INTO v_strsaldo
                    FROM
                        dual;

                    SELECT
                        sp000_ajusta_string(CAST(CAST(v_total AS NUMBER(16, 2)) AS VARCHAR2(15)), 15, ' ', 'R')
                    INTO v_strtotal
                    FROM
                        dual;

                    SELECT
                        sp000_ajusta_string(CAST(CAST(v_limcre2 -(v_saldo + v_total) AS NUMERIC(16, 2)) AS VARCHAR2(15)), 15, ' '
                        , 'R')
                    INTO v_strdispon
                    FROM
                        dual;

                    v_mensaje := 'NO TIENE CRÉDITO SUFICIENTE PARA ATENDER ESTA '
                                 || v_desdoc
                                 || ' '
                                 || chr(13)
                                 || 'LÍNEA DE CRÉDITO:      '
                                 || v_strsimbolo
                                 || ' '
                                 || v_strlimcre
                                 || chr(13)
                                 || 'CRÉDITO UTILIZADO:     '
                                 || v_strsimbolo
                                 || ' '
                                 || v_strsaldo
                                 || chr(13)
                                 || 'DOCUMENTO ACTUAL:      '
                                 || v_strsimbolo
                                 || ' '
                                 || v_strtotal
                                 || chr(13)
                                 || 'NUEVO SALDO:           '
                                 || v_strsimbolo
                                 || ' '
                                 || v_strdispon;

                END IF;
            END IF;

            IF ( pin_swmuestramsj <> 'S' ) THEN
                v_mensaje := '';
            END IF;
        END IF;

        creditosimple.swresultado := v_strresultado;
        creditosimple.codcli := registro.codcli;
        creditosimple.razonc := registro.razonc;
        creditosimple.ruc := registro.ruc;
        creditosimple.codpag := registro.codpag;
        creditosimple.monlimcred := v_monlimcred;
        creditosimple.simbolo := v_strsimbolo;
        creditosimple.limcre2 := nvl(registro.limcre2,0);
        creditosimple.codpag2 := registro.codpag2;
        creditosimple.despag2 := registro.despag2;
        creditosimple.observ := registro.observ;
        creditosimple.desfidelidad := registro.desfidelidad;
        creditosimple.saldo := v_saldo;
        creditosimple.tipdoc := pin_tipdoc;
        creditosimple.descri := v_desdoc;
        creditosimple.series := '';
        creditosimple.numdoc := 0;
        creditosimple.codcpag := pin_codpag;
        creditosimple.descpag := v_descpag;
        creditosimple.tipmon := pin_tipmon;
        creditosimple.totdoc := pin_totdoc;
        creditosimple.tipcam := v_tipcam;
        creditosimple.total := v_total;
        creditosimple.mensaje := v_mensaje;
        PIPE ROW ( creditosimple );
    END LOOP;

    return;
END sp001_tiene_credito_simple;

/

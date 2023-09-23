--------------------------------------------------------
--  DDL for Function SP000_TIENE_CREDITO_SIMPLE
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP000_TIENE_CREDITO_SIMPLE" (
    pid_cia        IN  NUMBER,
    pcodcli        IN  VARCHAR2,
    pnumint        IN  NUMBER,
    pswmuestramsj  IN  VARCHAR2
) RETURN tbl_creditosimple
    PIPELINED
AS

    creditosimple  rec_creditosimple := rec_creditosimple(NULL, NULL, NULL, NULL, NULL,
                  NULL, NULL, NULL, NULL, NULL,
                  NULL, NULL, NULL, NULL, NULL,
                  NULL, NULL, NULL, NULL, NULL,
                  NULL, NULL, NULL, NULL);
    strsimbolo     VARCHAR2(5) := '';
    wmonlimcred    VARCHAR2(5) := 'USD';
    strlimcre      VARCHAR2(20) := '';
    strsaldo       VARCHAR2(20) := '';
    strdispon      VARCHAR2(20) := '';
    strtotal       VARCHAR2(20) := '';
    wswchklimcre   VARCHAR2(10) := '';
    wvercredcer    VARCHAR2(02) := '';
    wtotdoc        NUMERIC(16, 5) := 0;
    wtipdoc        NUMBER := 0;
    wdesdoc        VARCHAR2(30) := '';
    wseries        VARCHAR(5) := '';
    wnumdoc        NUMBER := 0;
    wcodcpag       NUMBER := 0;
    wtipcam        NUMERIC(9, 6) := 0;
    strresultado   VARCHAR2(1) := 'S';
    wdescpag       VARCHAR2(50) := '';
    wtipmon        VARCHAR2(5) := '';
    wlimcre2       NUMBER(9, 2) := 0;
    wsaldo         NUMBER(16, 2) := 0;
    wtotal         NUMBER(16, 5) := 0;
    wmensaje       VARCHAR2(1000) := '';
    CURSOR cur_creditosimple (
        wid_cia  NUMBER,
        wcodcli  VARCHAR2
    ) IS
    SELECT
        c.codcli      AS codcli,
        c.razonc      AS razonc,
        c.dident      AS ruc,
        c.codpag,
        ft.vstrg      AS monlimcred,
        c.limcre2,
        cc.codpag     AS codpag2,
        cp.despag     AS despag2,
		c.observ,
        ccf.descri    AS desfidelidad,
        cv.codigo     AS verlimcred,
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
                dcta100       dc
                LEFT OUTER JOIN tdoccobranza  td ON td.id_cia = dc.id_cia
                                                   AND td.tipdoc = dc.tipdoc
            WHERE
                    dc.id_cia = c.id_cia
                AND dc.codcli = c.codcli
                AND dc.saldo <> 0
            GROUP BY
                c.codcli
        ) AS saldo
    FROM
        cliente               c
        LEFT OUTER JOIN identidad             i ON i.id_cia = c.id_cia
                                       AND i.tident = c.tident
        LEFT OUTER JOIN cliente_codpag        cc ON cc.id_cia = c.id_cia
                                             AND cc.codcli = c.codcli
                                             AND cc.swdefaul = 'S'
        LEFT OUTER JOIN c_pago                cp ON cp.id_cia = c.id_cia
                                     AND cp.codpag = cc.codpag
                                     AND upper(cp.swacti) = 'S'
        LEFT OUTER JOIN factor                ft ON ft.id_cia = c.id_cia
                                     AND ft.codfac = 311  --- MONEDA DE LIMITE DE CREDITO CLIENTES ---
        LEFT OUTER JOIN cliente_clase         cf ON cf.id_cia = c.id_cia
                                            AND cf.tipcli = 'A'
                                            AND cf.codcli = c.codcli
                                            AND cf.clase = 29 -- FIDELIDAD---
        LEFT OUTER JOIN cliente_clase         cv ON cv.id_cia = c.id_cia
                                            AND cv.tipcli = 'A'
                                            AND cv.codcli = c.codcli
                                            AND cv.clase = 26 --VERIFICA CREDITO CERRADO DEFAULT S ---
        LEFT OUTER JOIN clase_cliente_codigo  ccf ON ccf.id_cia = c.id_cia
                                                    AND ccf.tipcli = cf.tipcli
                                                    AND ccf.clase = cf.clase
                                                    AND ccf.codigo = cf.codigo
    WHERE
            c.id_cia = wid_cia
        AND c.codcli = wcodcli
        FETCH NEXT 1 ROWS ONLY ;

BEGIN
    strresultado := 'S';
    wmensaje := '';
    FOR registro IN cur_creditosimple(pid_cia, pcodcli) LOOP
        wswchklimcre := 'S';
        IF ( registro.verlimcred IS NULL ) THEN
            wvercredcer := 'S';
        ELSE
            wvercredcer := registro.verlimcred;
        END IF;

        IF ( registro.monlimcred IS NULL ) THEN
            wmonlimcred := 'USD';
            strsimbolo := 'US$';
        END IF;

        IF ( upper(registro.monlimcred) = 'PEN' ) THEN
            strsimbolo := 'S/.';
        END IF;

        IF ( upper(registro.monlimcred) = 'USD' ) THEN
            strsimbolo := 'US$';
        END IF;

        wlimcre2 := nvl(registro.limcre2, 0);
        wsaldo := nvl(registro.saldo, 0);
        IF (
            ( pnumint IS NOT NULL ) AND ( pnumint <> 0 )
        ) THEN
            BEGIN
         --- SACA DATOS DEL DOCUMENTO-----
                SELECT
                    d.descri,
                    dc.tipdoc,
                    dc.series,
                    dc.numdoc,
                    dc.codcpag,
                    dc.tipmon,
                    dc.preven,
                    dc.tipcam
                INTO
                    wdesdoc,
                    wtipdoc,
                    wseries,
                    wnumdoc,
                    wcodcpag,
                    wtipmon,
                    wtotdoc,
                    wtipcam
                FROM
                    documentos_cab  dc
                    LEFT OUTER JOIN documentos      d ON d.id_cia = dc.id_cia
                                                    AND d.codigo = dc.tipdoc
                                                    AND d.series = dc.series
                WHERE
                        dc.id_cia = pid_cia
                    AND dc.numint = pnumint;

            EXCEPTION
                WHEN no_data_found THEN
                    wdesdoc := '';
                    wtipdoc := 0;
                    wseries := '';
                    wnumdoc := 0;
                    wcodcpag := 0;
                    wtipmon := '';
                    wtotdoc := 0;
                    wtipcam := 0;
            END;


---------------------

            IF ( NOT ( wtipdoc IN (
                0,
                7,
                8
            ) ) ) THEN
                IF ( ( wtipcam IS NULL ) OR ( wtipcam = 0 ) ) THEN
                    wtipcam := 1;
                END IF;

                IF ( wtipmon = wmonlimcred ) THEN
                    wtotal := nvl(wtotdoc, 0);
                ELSE
                    IF ( wtipmon = 'PEN' ) THEN
                        wtotal := nvl(wtotdoc, 0) / wtipcam;
                    ELSE
                        wtotal := nvl(wtotdoc, 0) * wtipcam;
                    END IF;
                END IF;

            END IF;
--------------------
         --SE SACA LA DESCRICION DE LA CONDICION DE PAGO DEL DOCUMENTO --

            BEGIN
                SELECT
                    c.despag,
                    sc.valor
                INTO
                    wdescpag,
                    wswchklimcre
                FROM
                    c_pago        c
                    LEFT OUTER JOIN c_pago_clase  sc ON sc.id_cia = c.id_cia
                                                       AND sc.codpag = c.codpag
                                                       AND sc.codigo = 2 -- CHEQUEA LIMITE DE CREDITO --
                WHERE
                        c.id_cia = pid_cia
                    AND c.codpag = wcodcpag;

            EXCEPTION
                WHEN no_data_found THEN
                    wdescpag := '';
                    wswchklimcre := '';
            END;

            wswchklimcre := nvl(wswchklimcre, 'S');
            wswchklimcre := upper(wswchklimcre);
            IF ( upper(wswchklimcre) = 'S' ) THEN
                IF (
                    ( wvercredcer <> 'N' ) AND ( wcodcpag = 0 )
                ) THEN
                    strresultado := 'N';
                    wmensaje := 'EL CLIENTE '
                                || registro.codcli
                                || '-'
                                || registro.razonc
                                || ' POSEE EL CRÉDITO CERRADO';

                ELSE
                    IF ( ( wlimcre2 - wsaldo ) <= wtotal ) THEN
                        strresultado := 'N';
                        SELECT
                            sp000_ajusta_string(CAST(CAST(wlimcre2 AS NUMBER(16, 2)) AS VARCHAR2(15)), 15, ' ', 'R')
                        INTO strlimcre
                        FROM
                            dual;

                        SELECT
                            sp000_ajusta_string(CAST(CAST(wsaldo AS NUMBER(16, 2)) AS VARCHAR2(15)), 15, ' ', 'R')
                        INTO strsaldo
                        FROM
                            dual;

                        SELECT
                            sp000_ajusta_string(CAST(CAST(wtotal AS NUMBER(16, 2)) AS VARCHAR2(15)), 15, ' ', 'R')
                        INTO strtotal
                        FROM
                            dual;

                        SELECT
                            sp000_ajusta_string(CAST(CAST(wlimcre2 -(wsaldo + wtotal) AS NUMERIC(16, 2)) AS VARCHAR2(15)), 15, ' ',
                            'R')
                        INTO strdispon
                        FROM
                            dual;

                        wmensaje := 'NO TIENE CRÉDITO SUFICIENTE PARA ATENDER ESTA   .'
                                    || wdesdoc
                                    || ' '
                                    || wseries
                                    || '-'
                                    || to_char(wnumdoc)
                                    || chr(13)
                                    || '    LÍNEA DE CRÉDITO:      '
                                    || strsimbolo
                                    || ' '
                                    || strlimcre
                                    || chr(13)
                                    || '    CRÉDITO UTILIZADO:     '
                                    || strsimbolo
                                    || ' '
                                    || strsaldo
                                    || chr(13)
                                    || '    DOCUMENTO ACTUAL:      '
                                    || strsimbolo
                                    || ' '
                                    || strtotal
                                    || chr(13)
                                    || chr(13)
                                    || '    NUEVO SALDO:           '
                                    || strsimbolo
                                    || ' '
                                    || strdispon;

                    END IF;
                END IF;

                IF ( pswmuestramsj <> 'S' ) THEN
                    wmensaje := '';
                END IF;
            END IF;
    -------------------------------------------------------------------------------------

---

        END IF;

        creditosimple.swresultado := strresultado;
        creditosimple.codcli := registro.codcli;
        creditosimple.razonc := registro.razonc;
        creditosimple.ruc := registro.ruc;
        creditosimple.codpag := registro.codpag;
        creditosimple.monlimcred := wmonlimcred;
        creditosimple.simbolo := strsimbolo;
        creditosimple.limcre2 := NVL(registro.limcre2,0);
        creditosimple.codpag2 := registro.codpag2;
        creditosimple.despag2 := registro.despag2;
		creditosimple.observ := registro.observ;
        creditosimple.desfidelidad := registro.desfidelidad;
        creditosimple.saldo := wsaldo;
        creditosimple.tipdoc := wtipdoc;
        creditosimple.descri := wdesdoc;
        creditosimple.series := wseries;
        creditosimple.numdoc := wnumdoc;
        creditosimple.codcpag := wcodcpag;
        creditosimple.descpag := wdescpag;
        creditosimple.tipmon := wtipmon;
        creditosimple.totdoc := wtotdoc;
        creditosimple.tipcam := wtipcam;
        creditosimple.total := wtotal;
        creditosimple.mensaje := wmensaje;
        PIPE ROW ( creditosimple );
    END LOOP;

    return;
END sp000_tiene_credito_simple;

/

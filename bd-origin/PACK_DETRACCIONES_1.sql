--------------------------------------------------------
--  DDL for Package Body PACK_DETRACCIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_DETRACCIONES" AS

    FUNCTION sp_masivo (
        pin_id_cia   NUMBER,
        pin_periodo  NUMBER,
        pin_mes      NUMBER,
        pin_generado VARCHAR2
    ) RETURN datatable_detracciones_masivo
        PIPELINED
    AS
        v_table datatable_detracciones_masivo;
    BEGIN
        IF pin_generado = 'S' THEN
            SELECT
                'N'                                                                      AS chksel,
                c.tipo,
                c.docume,
                c.codpro,
                ct.codcli,
                ct.dident                                                                AS ruc,
                ct.tident                                                                AS tident,
                ct.razonc                                                                AS razonc,
                c.razon,
                c.tdocum,
                td.descri                                                                AS tdocumdes,
                c.nserie,
                c.numero,
                c.femisi,
                ( ( EXTRACT(YEAR FROM c.femisi) * 100 ) + EXTRACT(MONTH FROM c.femisi) ) AS pertrib,
                c.moneda,
                c.impor01,
--            c.codpro,    
             --C.RAZON,     
                c.impdetrac,
                c.tdetrac,
                ft.nomfac                                                                AS nomtasa,
                ft.vreal                                                                 AS tasa,
                cc300.codigo                                                             AS c_operac,
                ft300.nomfac                                                             AS nomoperac,
                cc301.codigo                                                             AS c_bys,
                ft301.nomfac                                                             AS nombys,
                cb.cuenta                                                                AS cuentabn,
                ec.numdoc                                                                AS numdoc_env,
                ec.estado,
                ec.numint,
                es.descri                                                                AS generado,
                c.ddetrac,
                c.fdetrac
            BULK COLLECT
            INTO v_table
            FROM
                compr010                   c
                LEFT OUTER JOIN cliente                    ct ON ct.id_cia = c.id_cia
                                              AND ct.codcli = c.codpro
                LEFT OUTER JOIN tdocume                    td ON td.id_cia = c.id_cia
                                              AND td.codigo = c.tdocum
                LEFT OUTER JOIN compr010_clase             cc300 ON cc300.id_cia = c.id_cia
                                                        AND cc300.tipo = c.tipo
                                                        AND cc300.docume = c.docume
                                                        AND cc300.clase = 300
                LEFT OUTER JOIN tfactor                    ft ON ft.id_cia = c.id_cia
                                              AND ft.tipo = 64
                                              AND ft.codfac = c.tdetrac
                LEFT OUTER JOIN compr010_clase             cc301 ON cc301.id_cia = c.id_cia
                                                        AND cc301.tipo = c.tipo
                                                        AND cc301.docume = c.docume
                                                        AND cc301.clase = 301
                LEFT OUTER JOIN tfactor                    ft300 ON ft300.id_cia = c.id_cia
                                                 AND ft300.tipo = 300
                                                 AND ft300.codfac = cc300.codigo
                LEFT OUTER JOIN tfactor                    ft301 ON ft301.id_cia = c.id_cia
                                                 AND ft301.tipo = 301
                                                 AND ft301.codfac = cc301.codigo
                LEFT OUTER JOIN detraccion_det_envio_sunat ed ON ed.id_cia = c.id_cia
                                                                 AND ed.tipo = c.tipo
                                                                 AND ed.docume = c.docume
                LEFT OUTER JOIN detraccion_cab_envio_sunat ec ON ec.id_cia = c.id_cia
                                                                 AND ec.numint = ed.numint
                LEFT OUTER JOIN estado_envio_detraccion    es ON es.id_cia = c.id_cia
                                                              AND es.codest = ec.estado
                LEFT OUTER JOIN cliente_bancos             cb ON cb.id_cia = c.id_cia
                                                     AND cb.codcli = c.codpro
                                                     AND cb.codigo = 18
                                                     AND cb.tipcta = 4
                                                     AND cb.tipmon = 'PEN'
            WHERE
                    c.id_cia = pin_id_cia
                AND c.situac = 2
                AND c.swafeccion = 2
                AND c.periodo = pin_periodo
                AND c.mes = pin_mes
                AND EXISTS (
                    SELECT
                        e.tipo,
                        e.docume
                    FROM
                        detraccion_det_envio_sunat e
                    WHERE
                            e.id_cia = c.id_cia
                        AND e.tipo = c.tipo
                        AND e.docume = c.docume
                );

            FOR registro IN 1..v_table.count LOOP
                PIPE ROW ( v_table(registro) );
            END LOOP;

            RETURN;
        ELSIF pin_generado = 'N' THEN
            SELECT
                'N'                                                                      AS chksel,
                c.tipo,
                c.docume,
                c.codpro,
                ct.codcli,
                ct.dident                                                                AS ruc,
                ct.tident                                                                AS tident,
                ct.razonc                                                                AS razonc,
                c.razon,
                c.tdocum,
                td.descri                                                                AS tdocumdes,
                c.nserie,
                c.numero,
                c.femisi,
                ( ( EXTRACT(YEAR FROM c.femisi) * 100 ) + EXTRACT(MONTH FROM c.femisi) ) AS pertrib,
                c.moneda,
                c.impor01,
                c.impdetrac,
                c.tdetrac,
                ft.nomfac                                                                AS nomtasa,
                ft.vreal                                                                 AS tasa,
                cc300.codigo                                                             AS c_operac,
                ft300.nomfac                                                             AS nomoperac,
                cc301.codigo                                                             AS c_bys,
                ft301.nomfac                                                             AS nombys,
                cb.cuenta                                                                AS cuentabn,
                ec.numdoc                                                                AS numdoc_env,
                ec.estado,
                ec.numint,
                es.descri                                                                AS generado,
                c.ddetrac,
                c.fdetrac
            BULK COLLECT
            INTO v_table
            FROM
                compr010                   c
                LEFT OUTER JOIN cliente                    ct ON ct.id_cia = c.id_cia
                                              AND ct.codcli = c.codpro
                LEFT OUTER JOIN tdocume                    td ON td.id_cia = c.id_cia
                                              AND td.codigo = c.tdocum
                LEFT OUTER JOIN compr010_clase             cc300 ON cc300.id_cia = c.id_cia
                                                        AND cc300.tipo = c.tipo
                                                        AND cc300.docume = c.docume
                                                        AND cc300.clase = 300
                LEFT OUTER JOIN tfactor                    ft ON ft.id_cia = c.id_cia
                                              AND ft.tipo = 64
                                              AND ft.codfac = c.tdetrac
                LEFT OUTER JOIN compr010_clase             cc301 ON cc301.id_cia = c.id_cia
                                                        AND cc301.tipo = c.tipo
                                                        AND cc301.docume = c.docume
                                                        AND cc301.clase = 301
                LEFT OUTER JOIN tfactor                    ft300 ON ft300.id_cia = c.id_cia
                                                 AND ft300.tipo = 300
                                                 AND ft300.codfac = cc300.codigo
                LEFT OUTER JOIN tfactor                    ft301 ON ft301.id_cia = c.id_cia
                                                 AND ft301.tipo = 301
                                                 AND ft301.codfac = cc301.codigo
                LEFT OUTER JOIN detraccion_det_envio_sunat ed ON ed.id_cia = c.id_cia
                                                                 AND ed.tipo = c.tipo
                                                                 AND ed.docume = c.docume
                LEFT OUTER JOIN detraccion_cab_envio_sunat ec ON ec.id_cia = c.id_cia
                                                                 AND ec.numint = ed.numint
                LEFT OUTER JOIN estado_envio_detraccion    es ON es.id_cia = c.id_cia
                                                              AND es.codest = ec.estado
                LEFT OUTER JOIN cliente_bancos             cb ON cb.id_cia = c.id_cia
                                                     AND cb.codcli = c.codpro
                                                     AND cb.codigo = 18
                                                     AND cb.tipcta = 4
                                                     AND cb.tipmon = 'PEN'
            WHERE
                    c.id_cia = pin_id_cia
                AND c.situac = 2
                AND c.swafeccion = 2
                AND c.periodo = pin_periodo
                AND c.mes = pin_mes
                AND NOT EXISTS (
                    SELECT
                        e.tipo,
                        e.docume
                    FROM
                        detraccion_det_envio_sunat e
                    WHERE
                            e.id_cia = c.id_cia
                        AND e.tipo = c.tipo
                        AND e.docume = c.docume
                );

            FOR registro IN 1..v_table.count LOOP
                PIPE ROW ( v_table(registro) );
            END LOOP;

            RETURN;
        END IF;
    END sp_masivo;

    FUNCTION sp_txt (
        pin_id_cia NUMBER,
        pin_numint NUMBER
    ) RETURN datatable_txt
        PIPELINED
    AS
        v_table datatable_txt;
    BEGIN
        SELECT
            'N'                                                                  AS chksel,
            ec.numdoc                                                            AS lote,
            c.tipo,
            c.docume,
            c.codpro,
            ct.codcli,
            ct.dident                                                            AS ruc,
            ct.tident                                                            AS tident,
            CAST(i.codsunat AS INTEGER)                                          AS tidentsunat,
            ct.razonc                                                            AS razonc,
            c.razon,
            c.tdocum,
            td.descri                                                            AS tdocumdes,
            c.nserie,
            c.numero,
            c.femisi,
            ( EXTRACT(YEAR FROM c.femisi) * 100 ) + EXTRACT(MONTH FROM c.femisi) AS pertrib,
            c.moneda,
            c.impor01,
            c.impdetrac,
            c.tdetrac,
            ft.nomfac                                                            AS nomtasa,
            ft.vreal                                                             AS tasa,
            cc300.codigo                                                         AS c_operac,
            ft300.nomfac                                                         AS nomoperac,
            cc301.codigo                                                         AS c_bys,
            ft301.nomfac                                                         AS nombys,
            -- CUENTA DEL CLIENTE
            cb.tipcta,
            cb.tipmon,
            cb.cuenta                                                            AS cuentabn,
            ec.numdoc                                                            AS numdoc_env,
            ec.estado,
            ec.numint,
            es.descri                                                            AS generado,
            c.ddetrac,
            c.fdetrac
        BULK COLLECT
        INTO v_table
        FROM
                 detraccion_cab_envio_sunat ec
            INNER JOIN detraccion_det_envio_sunat ed ON ed.id_cia = ec.id_cia
                                                        AND ed.numint = ec.numint
            INNER JOIN compr010                   c ON c.id_cia = ed.id_cia
                                     AND c.tipo = ed.tipo
                                     AND c.docume = ed.docume
            INNER JOIN cliente                    ct ON ct.id_cia = c.id_cia
                                     AND ct.codcli = c.codpro
            INNER JOIN identidad                  i ON i.id_cia = ct.id_cia
                                      AND i.tident = ct.tident
                                      AND i.tident IN ( '06', '01', '00', '04', '07' )
            LEFT OUTER JOIN tdocume                    td ON td.id_cia = c.id_cia
                                          AND td.codigo = c.tdocum
            LEFT OUTER JOIN compr010_clase             cc300 ON cc300.id_cia = c.id_cia
                                                    AND cc300.tipo = c.tipo
                                                    AND cc300.docume = c.docume
                                                    AND cc300.clase = 300
            LEFT OUTER JOIN tfactor                    ft300 ON ft300.id_cia = cc300.id_cia
                                             AND ft300.tipo = 300
                                             AND ft300.codfac = cc300.codigo
            LEFT OUTER JOIN tfactor                    ft ON ft.id_cia = c.id_cia
                                          AND ft.tipo = 64
                                          AND ft.codfac = c.tdetrac
            LEFT OUTER JOIN compr010_clase             cc301 ON cc301.id_cia = c.id_cia
                                                    AND cc301.tipo = c.tipo
                                                    AND cc301.docume = c.docume
                                                    AND cc301.clase = 301
            LEFT OUTER JOIN tfactor                    ft301 ON ft301.id_cia = cc301.id_cia
                                             AND ft301.tipo = 301
                                             AND ft301.codfac = cc301.codigo
            LEFT OUTER JOIN estado_envio_detraccion    es ON es.id_cia = ec.id_cia
                                                          AND es.codest = ec.estado
            LEFT OUTER JOIN cliente_bancos             cb ON cb.id_cia = c.id_cia
                                                 AND cb.codcli = c.codpro
                                                 AND cb.codigo = 18
                                                 AND cb.tipcta = 4
                                                 AND cb.tipmon = 'PEN'
        WHERE
                ec.id_cia = pin_id_cia
            AND ec.numint = pin_numint;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_txt;

--    FUNCTION sp_detalle (
--        pin_id_cia NUMBER,
--        pin_numint NUMBER,
--        pin_codban NUMBER,
--        pin_codmon VARCHAR2
--    ) RETURN datatable_detalle
--        PIPELINED
--    AS
--        v_table datatable_detalle;
--    BEGIN
--        SELECT
--            t.codcli,
--            nvl(TO_NUMBER(t.nroctaabr),
--                0),
--            t.nroctaabr,
--            t.monpag
--        BULK COLLECT
--        INTO v_table
--        FROM
--            (
--                SELECT
--                    codcli,
--                    substr(cuentabn, 11, 20) AS nroctaabr,
--                    SUM(impdetrac)           AS monpag
--                FROM
--                    pack_detracciones.sp_txt(pin_id_cia, pin_numint)
--                WHERE
--                    TRIM(cuentabn) IS NOT NULL
--                GROUP BY
--                    codcli,
--                    substr(cuentabn, 11, 20)
--                ORDER BY
--                    codcli
--            ) t;
--
--        FOR registro IN 1..v_table.count LOOP
--            PIPE ROW ( v_table(registro) );
--        END LOOP;
--
--        RETURN;
--    END sp_detalle;

--    FUNCTION sp_generar_txt (
--        pin_id_cia NUMBER,
--        pin_numint NUMBER,
--        pin_codban NUMBER,
--        pin_codmon VARCHAR2
--    ) RETURN datatable_fomato
--        PIPELINED
--    AS
--
--        v_rec      datarecord_formato;
--        v_tipcta   VARCHAR2(1 CHAR) := '';
--        v_nrocta   VARCHAR2(100 CHAR);
--        v_codmon   VARCHAR2(5 CHAR) := '';
--        v_subtip   VARCHAR2(1 CHAR) := '';
--        v_numper   NUMBER;
--        v_checksum NUMBER;
--        v_monpag   NUMBER(16, 2);
--    BEGIN
--        BEGIN
--            SELECT
--                nrocta,
--                CASE
--                    WHEN tipcta = 1 THEN
--                        'C'
--                    ELSE
--                        'M'
--                END
--            INTO
--                v_nrocta,
--                v_tipcta
--            FROM
--                compania_banco
--            WHERE
--                    id_cia = pin_id_cia
--                AND codban = pin_codban
--                AND tipcta IN ( 1, 3 )
--                AND codmon = pin_codmon;
--
--        EXCEPTION
--            WHEN no_data_found THEN
--                v_nrocta := '0';
--            WHEN too_many_rows THEN
--                v_nrocta := '0';
--        END;
--
--        IF pin_codmon = 'PEN' THEN
--            v_codmon := '0001';
--        ELSE
--            v_codmon := '1001';
--        END IF;
--
--        BEGIN
--            SELECT
--                nvl(COUNT(codper),
--                    0),
--                nvl(SUM(checksum),
--                    0),
--                nvl(SUM(monpag),
--                    0)
--            INTO
--                v_numper,
--                v_checksum,
--                v_monpag
--            FROM
--                pack_detracciones.sp_detalle(pin_id_cia, pin_numint, pin_codban, pin_codmon);
--
--        END;
--
--        v_rec.rotulo := 'FORMATO DE BCP';
--        v_rec.indcabdet := '1';
--        v_rec.column01 := '1'
--                          || sp000_ajusta_string(to_char(v_numper), 6, '0', 'R')
--                          || to_char(current_timestamp, 'YYYYMMDD')
--                          || v_tipcta -- 'C'
--                          || v_codmon
--                          || v_nrocta;
--
--        v_rec.column02 := sp000_ajusta_string(trim(to_char(v_monpag, '99999999999999.99')), 17, '0', 'R');
--
--        v_rec.column03 := 'S'
--                          || sp000_ajusta_string(to_char(v_checksum), 15, '0', 'R'); -- SUMA DE CUENTA
--
--        PIPE ROW ( v_rec );
--        FOR i IN (
--            SELECT
--                tident         AS tident,
--                ruc            AS dident,
--                codcli,
--                razonc,
--                CASE
--                    WHEN tipcta IN ( 1, 3, 29 ) THEN
--                        'C'
--                    WHEN tipcta = 2 THEN
--                        'A'
--                    ELSE
--                        ''
--                END            AS tipcta,
--                CASE
--                    WHEN codmon = 'PEN' THEN
--                        '0001'
--                    ELSE
--                        '1001'
--                END            AS codmon,
--                cuentabn,
--                SUM(impdetrac) AS impdetrac
--            FROM
--                pack_detracciones.sp_txt(pin_id_cia, pin_numint)
--            GROUP BY
--                tident,
--                ruc,
--                codcli,
--                razonc,
--                CASE
--                        WHEN tipcta IN ( 1, 3, 29 ) THEN
--                            'C'
--                        WHEN tipcta = 2 THEN
--                            'A'
--                        ELSE
--                            ''
--                END,
--                CASE
--                    WHEN codmon = 'PEN' THEN
--                            '0001'
--                    ELSE
--                        '1001'
--                END,
--                cuentabn
--            ORDER BY
--                codcli
--        ) LOOP
--            v_rec.indcabdet := '2';
--            v_rec.column01 := '2'
--                              || i.tipcta
--                              || i.cuentabn;
--            v_rec.column02 := i.tident || i.dident;
--            v_rec.column03 := i.razonc;
--            v_rec.column04 := 'S'
--                              || sp000_ajusta_string(trim(to_char(i.impdetrac, '99999999999999.99')), 17, '0', 'R');
--
--            PIPE ROW ( v_rec );
--            FOR j IN (
--                SELECT
--                    CASE
--                        WHEN tdocum IN ( '01', '02' ) THEN
--                            'F'
--                        WHEN tdocum IN ( '07' ) THEN
--                            'C'
--                        WHEN tdocum IN ( '08' ) THEN
--                            'D'
--                        ELSE
--                            ''
--                    END              AS tdocum,
--                    nserie || numero AS docume,
--                    impdetrac        AS impdetrac
--                FROM
--                    pack_detracciones.sp_txt(pin_id_cia, pin_numint)
--                WHERE
--                    codcli = i.codcli
--            ) LOOP
--                v_rec.indcabdet := '3';
--                v_rec.column01 := '3'
--                                  || j.tdocum
--                                  || sp000_ajusta_string(j.docume, 15, '0', 'R')
--                                  || to_char(current_timestamp, 'YYYYMMDD')
--                                  || sp000_ajusta_string(trim(to_char(i.impdetrac, '99999999999999.99')), 17, '0', 'R');
--
--                v_rec.column02 := NULL;
--                v_rec.column03 := NULL;
--                v_rec.column04 := NULL;
--                PIPE ROW ( v_rec );
--            END LOOP;
--
--        END LOOP;
--
--    END sp_formato;

END;

/

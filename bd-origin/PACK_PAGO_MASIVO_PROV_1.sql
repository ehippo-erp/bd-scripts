--------------------------------------------------------
--  DDL for Package Body PACK_PAGO_MASIVO_PROV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_PAGO_MASIVO_PROV" AS

    FUNCTION sp_genera_txt (
        pin_id_cia    NUMBER,
        pin_libro     VARCHAR2,
        pin_periodo   NUMBER,
        pin_mes       NUMBER,
        pin_secuencia NUMBER,
        pin_codban    NUMBER,
        pin_codmon    VARCHAR2
    ) RETURN datatable_fomato
        PIPELINED
    AS

        v_rec      datarecord_formato := datarecord_formato(NULL, NULL, NULL, NULL, NULL,
                                                      NULL, NULL, NULL, NULL, NULL,
                                                      NULL, NULL);
        v_tipcta   VARCHAR2(1 CHAR) := '';
        v_nrocta   VARCHAR2(100 CHAR);
        v_codmon   VARCHAR2(5 CHAR) := '';
        v_tipmon   VARCHAR2(5 CHAR) := '';
        v_subtip   VARCHAR2(1 CHAR) := '';
        v_numper   NUMBER;
        v_checksum NUMBER;
        v_monpag   NUMBER(16, 2);
        pin_numint NUMBER := 15;
    BEGIN
        BEGIN
            SELECT
                p.tipmon
            INTO v_tipmon
            FROM
                prov104 p
            WHERE
                    p.id_cia = pin_id_cia
                AND p.libro = pin_libro
                AND p.periodo = pin_periodo
                AND p.mes = pin_mes
                AND p.secuencia = pin_secuencia
                AND p.situac = 'B'; -- CONTABILIZADA

        EXCEPTION
            WHEN no_data_found THEN
                RETURN; -- SIN RESULTADO
        END;

        BEGIN
            SELECT
                nrocta,
                CASE
                    WHEN tipcta = 1 THEN
                        'C'
                    ELSE
                        'M'
                END
            INTO
                v_nrocta,
                v_tipcta
            FROM
                compania_banco
            WHERE
                    id_cia = pin_id_cia
                AND codban = pin_codban
                AND tipcta IN ( 1, 3 )
                AND codmon = v_tipmon;

        EXCEPTION
            WHEN no_data_found THEN
                v_nrocta := '0';
            WHEN too_many_rows THEN
                v_nrocta := '0';
        END;

        IF pin_codmon = 'PEN' THEN
            v_codmon := '0001';
        ELSE
            v_codmon := '1001';
        END IF;

        BEGIN
            SELECT
                nvl(COUNT(codper),
                    0),
                nvl(SUM(checksum),
                    0),
                nvl(SUM(monpag),
                    0)
            INTO
                v_numper,
                v_checksum,
                v_monpag
            FROM
                pack_pago_masivo_prov.sp_detalle(pin_id_cia, pin_libro, pin_periodo, pin_mes, pin_secuencia,
                                                 pin_codban, v_tipmon);

        END;

        v_rec.rotulo := 'FORMATO DE BCP';
        v_rec.indcabdet := '1';
        v_rec.column01 := '1'
                          || sp000_ajusta_string(to_char(v_numper), 6, '0', 'R')
                          || to_char(current_timestamp, 'YYYYMMDD')
                          || v_tipcta -- 'C'
                          || v_codmon
                          || v_nrocta;

        v_rec.column02 := sp000_ajusta_string(trim(to_char(v_monpag, '99999999999999.99')), 17, '0', 'R');

        v_rec.column03 := 'S'
                          || sp000_ajusta_string(to_char(v_checksum), 15, '0', 'R'); -- SUMA DE CUENTA
        PIPE ROW ( v_rec );
        FOR i IN (
            SELECT
                tident AS tident,
                dident AS dident,
                codcli,
                razonc,
                CASE
                    WHEN tipcta IN ( 1, 3, 29 ) THEN
                        'C'
                    WHEN tipcta = 2 THEN
                        'A'
                    ELSE
                        ''
                END    AS tipcta,
                CASE
                    WHEN v_tipmon = 'PEN' THEN
                        '0001'
                    ELSE
                        '1001'
                END    AS codmon,
                nrocta,
                SUM(
                    CASE
                        WHEN v_tipmon = 'PEN' THEN
                            netomn
                        ELSE
                            netome
                    END
                )      AS impneto
            FROM
                pack_pago_masivo_prov.sp_prov103(pin_id_cia, pin_libro, pin_periodo, pin_mes, pin_secuencia,
                                                 pin_codban, v_tipmon)
            GROUP BY
                tident,
                dident,
                codcli,
                razonc,
                CASE
                        WHEN tipcta IN ( 1, 3, 29 ) THEN
                            'C'
                        WHEN tipcta = 2 THEN
                            'A'
                        ELSE
                            ''
                END,
                CASE
                    WHEN v_tipmon = 'PEN' THEN
                            '0001'
                    ELSE
                        '1001'
                END,
                nrocta
            ORDER BY
                codcli ASC
        ) LOOP
            v_rec.indcabdet := '2';
            v_rec.column01 := '2'
                              || i.tipcta
                              || i.nrocta;
            v_rec.column02 := i.tident || i.dident;
            v_rec.column03 := i.razonc;
            v_rec.column04 := 'S'
                              || sp000_ajusta_string(trim(to_char(i.impneto, '99999999999999.99')), 17, '0', 'R');

            PIPE ROW ( v_rec );
            FOR j IN (
                SELECT
                    CASE
                        WHEN tdocum IN ( '01', '02' ) THEN
                            'F'
                        WHEN tdocum IN ( '07' ) THEN
                            'C'
                        WHEN tdocum IN ( '08' ) THEN
                            'D'
                        ELSE
                            ''
                    END    AS tdocum,
                    docume AS docume,
                    CASE
                        WHEN v_tipmon = 'PEN' THEN
                            netomn
                        ELSE
                            netome
                    END    AS impneto
                FROM
                    pack_pago_masivo_prov.sp_prov103(pin_id_cia, pin_libro, pin_periodo, pin_mes, pin_secuencia,
                                                     pin_codban, v_tipmon)
                WHERE
                    codcli = i.codcli
                ORDER BY
                    docume ASC
            ) LOOP
                v_rec.indcabdet := '3';
                v_rec.column01 := '3'
                                  || j.tdocum
                                  || sp000_ajusta_string(j.docume, 15, '0', 'R')
                                  || to_char(current_timestamp, 'YYYYMMDD')
                                  || sp000_ajusta_string(trim(to_char(j.impneto, '99999999999999.99')), 17, '0', 'R');

                v_rec.column02 := NULL;
                v_rec.column03 := NULL;
                v_rec.column04 := NULL;
                PIPE ROW ( v_rec );
            END LOOP;

        END LOOP;

    END sp_genera_txt;

    FUNCTION sp_detalle (
        pin_id_cia    NUMBER,
        pin_libro     VARCHAR2,
        pin_periodo   NUMBER,
        pin_mes       NUMBER,
        pin_secuencia NUMBER,
        pin_codban    NUMBER,
        pin_codmon    VARCHAR2
    ) RETURN datatable_detalle
        PIPELINED
    AS
        v_table datatable_detalle;
    BEGIN
        SELECT
            t.codcli,
            nvl(TO_NUMBER(t.nroctaabr),
                0),
            t.nroctaabr,
            t.impneto
        BULK COLLECT
        INTO v_table
        FROM
            (
                SELECT
                    codcli,
                    substr(nrocta, 4, 14) AS nroctaabr,
                    SUM(
                        CASE
                            WHEN pin_codmon = 'PEN' THEN
                                netomn
                            ELSE
                                netome
                        END
                    )                     AS impneto
                FROM
                    pack_pago_masivo_prov.sp_prov103(pin_id_cia, pin_libro, pin_periodo, pin_mes, pin_secuencia,
                                                     pin_codban, pin_codmon)
                GROUP BY
                    codcli,
                    nrocta
            ) t;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_detalle;

    FUNCTION sp_reporte (
        pin_id_cia    NUMBER,
        pin_libro     VARCHAR2,
        pin_periodo   NUMBER,
        pin_mes       NUMBER,
        pin_secuencia NUMBER,
        pin_codban    NUMBER,
        pin_codmon    VARCHAR2
    ) RETURN datatable_reporte
        PIPELINED
    AS
        v_table  datatable_reporte;
        v_tipmon VARCHAR2(5 CHAR) := '';
    BEGIN
        BEGIN
            SELECT
                p.tipmon
            INTO v_tipmon
            FROM
                prov104 p
            WHERE
                    p.id_cia = pin_id_cia
                AND p.libro = pin_libro
                AND p.periodo = pin_periodo
                AND p.mes = pin_mes
                AND p.secuencia = pin_secuencia
                AND p.situac = 'B'; -- CONTABILIZADA

        EXCEPTION
            WHEN no_data_found THEN
                RETURN; -- SIN RESULTADO
        END;

        SELECT
            id_cia,
            codcli,
            razonc,
            despago,
            CASE
                WHEN tipcta IN ( 1, 3, 29 ) THEN
                    'C'
                WHEN tipcta = 2 THEN
                    'A'
                ELSE
                    ''
            END AS tipcta,
            nrocta,
            v_tipmon,
            SUM(
                CASE
                    WHEN v_tipmon = 'PEN' THEN
                        netomn
                    ELSE
                        netome
                END
            )   AS impneto
        BULK COLLECT
        INTO v_table
        FROM
            pack_pago_masivo_prov.sp_prov103(pin_id_cia, pin_libro, pin_periodo, pin_mes, pin_secuencia,
                                             pin_codban, v_tipmon)
        GROUP BY
            id_cia,
            codcli,
            razonc,
            despago,
            CASE
                    WHEN tipcta IN ( 1, 3, 29 ) THEN
                        'C'
                    WHEN tipcta = 2 THEN
                        'A'
                    ELSE
                        ''
            END,
            nrocta,
            codmon
        ORDER BY
            codcli ASC;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_reporte;

    FUNCTION sp_prov103 (
        pin_id_cia    NUMBER,
        pin_libro     VARCHAR2,
        pin_periodo   NUMBER,
        pin_mes       NUMBER,
        pin_secuencia NUMBER,
        pin_codban    NUMBER,
        pin_codmon    VARCHAR2
    ) RETURN datatable_prov103
        PIPELINED
    AS
        v_table datatable_prov103;
    BEGIN
        SELECT
            d.id_cia,
            d.tipdoc,
            CASE
                WHEN d.tipdoc = '07' THEN
                    p.refere01
                ELSE
                    p.docume
            END       AS docume,
            d.femisi,
            d.codcli,
            c.razonc,
            c.dident,
            c.tident,
            d.tipmon,
            p.tipcan,
            cb.tipcta,
            cb.cuenta AS nrocta,
            mp.descri AS despago,
            cp.nrodni,
            p.impor01 AS impor01,
            p.pagomn  AS pagomn,
            p.pagome  AS pagome,
            p.pagomn -
            CASE
                WHEN upper(nvl(p.swchkretiene, 'N')) = 'S'
                     AND upper(nvl(p.swchksepaga, 'S')) = 'S' THEN
                        ( p.pagomn * (
                            SELECT
                                tasa
                            FROM
                                pack_retencion.sp_regimen_retencion(d.id_cia, 0, d.femisi, d.codcli)
                        ) ) / 100
                ELSE
                    0
            END
            AS netomn,
            p.pagome -
            CASE
                WHEN upper(nvl(p.swchkretiene, 'N')) = 'S'
                     AND upper(nvl(p.swchksepaga, 'S')) = 'S' THEN
                        ( p.pagome * (
                            SELECT
                                tasa
                            FROM
                                pack_retencion.sp_regimen_retencion(d.id_cia, 0, d.femisi, d.codcli)
                        ) ) / 100
                ELSE
                    0
            END
            AS netome
        BULK COLLECT
        INTO v_table
        FROM
                 prov103 p
            INNER JOIN prov100           d ON d.id_cia = p.id_cia
                                    AND d.tipo = p.tipo
                                    AND d.docu = p.docu
                                    AND d.situac = '2'
            LEFT OUTER JOIN cliente           c ON c.id_cia = d.id_cia
                                         AND c.codcli = d.codcli
            LEFT OUTER JOIN cliente_tpersona  cp ON cp.id_cia = d.id_cia
                                                   AND cp.codcli = d.codcli
            LEFT OUTER JOIN cliente_bancos    cb ON cb.id_cia = d.id_cia
                                                 AND cb.codcli = d.codcli
                                                 AND cb.tipmon = p.tipmon
                                                 AND cb.codigo = pin_codban
                                                 AND cb.tipcta IN ( 1, 2 )
            LEFT OUTER JOIN e_financiera      ef ON cb.id_cia = ef.id_cia
                                               AND cb.codigo = ef.codigo
            LEFT OUTER JOIN e_financiera_tipo eft ON cb.id_cia = eft.id_cia
                                                     AND cb.tipcta = eft.tipcta
            LEFT OUTER JOIN m_pago            mp ON mp.id_cia = p.id_cia
                                         AND mp.codigo = p.tipcan
        WHERE
                p.id_cia = pin_id_cia
            AND p.libro = pin_libro
            AND p.periodo = pin_periodo
            AND p.mes = pin_mes
            AND p.secuencia = pin_secuencia
            AND p.situac NOT IN ( '9' )
            AND upper(nvl(p.swchksepaga, 'S')) = 'S'
        ORDER BY
            d.codcli ASC;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_prov103;

--    FUNCTION sp_prov104 (
--        pin_id_cia    NUMBER,
--        pin_libro     VARCHAR2,
--        pin_periodo   NUMBER,
--        pin_mes       NUMBER,
--        pin_secuencia NUMBER,
--        pin_codban    NUMBER,
--        pin_codmon    VARCHAR2
--    ) RETURN datatable_prov104
--        PIPELINED
--    AS
--        v_table datatable_prov104;
--    BEGIN
--        SELECT
--            p.tipdep,
--            p.tipmon,
--            p.codban,
--            b.codsunat,
--            b.descri  AS desban,
--            tp.descri AS dtipdep,
--            b.cuenta,
--            mo.simbolo
--        FROM
--            prov104 p
--            LEFT OUTER JOIN tbancos b ON b.id_cia = p.id_cia
--                                         AND b.codban = p.codban
--            LEFT OUTER JOIN m_pago  tp ON tp.id_cia = p.id_cia
--                                         AND tp.codigo = p.tipdep
--            LEFT OUTER JOIN tmoneda mo ON mo.id_cia = p.id_cia
--                                          AND mo.codmon = p.tipmon
--        WHERE
--                p.id_cia = pin_id_cia
--            AND p.libro = pin_libro
--            AND p.periodo = pin_periodo
--            AND p.mes = pin_mes
--            AND p.secuencia = pin_secuencia
--            AND p.item = pin_item;
--
--        FOR registro IN 1..v_table.count LOOP
--            PIPE ROW ( v_table(registro) );
--        END LOOP;
--
--        RETURN;
--    END sp_prov104;

END;

/

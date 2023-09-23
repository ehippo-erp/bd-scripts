--------------------------------------------------------
--  DDL for Function SP_PLE_8_1_REGISTRO_COMPRAS
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP_PLE_8_1_REGISTRO_COMPRAS" (
    pin_id_cia  IN NUMBER,
    pin_periodo IN NUMBER,
    pin_mes     IN NUMBER
) RETURN tbl_sp_ple_8_1_registro_compras
    PIPELINED
AS

    lsigno NUMBER;
    reg    rec_sp_ple_8_1_registro_compras := rec_sp_ple_8_1_registro_compras(NULL, NULL, NULL, NULL, NULL,
                                                                          NULL, NULL, NULL, NULL, NULL,
                                                                          NULL, NULL, NULL, NULL, NULL,
                                                                          NULL, NULL, NULL, NULL, NULL,
                                                                          NULL, NULL, NULL, NULL, NULL,
                                                                          NULL, NULL, NULL, NULL, NULL,
                                                                          NULL, NULL, NULL, NULL, NULL,
                                                                          NULL, NULL, NULL);
BEGIN
    FOR i IN (
        SELECT
            a1.periodo * 10000 + a1.mes * 100                               AS cperiodo,
            CASE
                WHEN fr.ventero = 1 THEN
                    CAST(a1.tipo
                         || '-'
                         || a1.docume AS VARCHAR(20))
                ELSE
                    CAST(sp000_ajusta_string(CAST(a1.asiento AS VARCHAR(10)),
                                             05,
                                             '0',
                                             'R') AS VARCHAR(20))
            END                                                             AS cnumregope,
            CAST(
                CASE
                    WHEN a1.libro = '00' THEN
                        'A'
                    ELSE
                        CASE
                            WHEN a1.libro = '99' THEN
                                    'C'
                            ELSE
                                CASE
                                    WHEN fr.ventero = 2 THEN
                                                'M-RER'
                                    ELSE
                                        'M'
                                END
                        END
                END
                || sp000_ajusta_string(a1.asiento, 4, '0', 'R') AS VARCHAR(10)) AS mcorrasien,
            ( ( to_char(c1.femisi, 'DD/MM/RRRR') ) )                        AS cfeccom,
            CAST(sp000_ajusta_string(
                CASE
                    WHEN(cl.codtpe = 3)
                        AND(
                        CASE
                            WHEN tc.codigo IS NULL THEN
                                a1.tdocum
                            ELSE
                                tc.codigo
                        END
                    IN('01', '07', '08')) THEN
                        CAST(CAST(
                            CASE
                                WHEN tc.codigo IS NULL THEN
                                    a1.tdocum
                                ELSE
                                    tc.codigo
                            END
                        AS INTEGER) + 90 AS VARCHAR(10))
                    ELSE
                        CASE
                            WHEN tc.codigo IS NULL THEN
                                    a1.tdocum
                            ELSE
                                tc.codigo
                        END
                END,
                02,
                '0',
                'R') AS VARCHAR(02))                                    AS ctipdoccom,
            CAST(
                CASE
                    WHEN sp000_ajusta_string(
                        CASE
                            WHEN(cl.codtpe = 3)
                                AND(
                                CASE
                                    WHEN tc.codigo IS NULL THEN
                                        a1.tdocum
                                    ELSE
                                        tc.codigo
                                END
                            IN('01', '07', '08')) THEN
                                CAST(CAST(
                                    CASE
                                        WHEN tc.codigo IS NULL THEN
                                            a1.tdocum
                                        ELSE
                                            tc.codigo
                                    END
                                AS INTEGER) + 90 AS VARCHAR(10))
                            ELSE
                                CASE
                                    WHEN tc.codigo IS NULL THEN
                                            a1.tdocum
                                    ELSE
                                        tc.codigo
                                END
                        END,
                        02,
                        '0',
                        'R') IN('14') THEN
                        ((to_char(c1.fvenci, 'DD/MM/RRRR')))
                    ELSE
                        to_char(c1.fvenci, 'DD/MM/RRRR')
                END
            AS VARCHAR(10))                                                 AS cfecvenpag,
            CAST(sp000_ajusta_string(c1.nserie,
                                     CASE
                                         WHEN sp000_ajusta_string(
                                             CASE
                                                 WHEN(cl.codtpe = 3)
                                                     AND(
                                                     CASE
                                                         WHEN tc.codigo IS NULL THEN
                                                             a1.tdocum
                                                         ELSE
                                                             tc.codigo
                                                     END
                                                 IN('01', '07', '08')) THEN
                                                     CAST(CAST(
                                                         CASE
                                                             WHEN tc.codigo IS NULL THEN
                                                                 a1.tdocum
                                                             ELSE
                                                                 tc.codigo
                                                         END
                                                     AS INTEGER) + 90 AS VARCHAR(10))
                                                 ELSE
                                                     CASE
                                                         WHEN tc.codigo IS NULL THEN
                                                                 a1.tdocum
                                                         ELSE
                                                             tc.codigo
                                                     END
                                             END,
                                             02,
                                             '0',
                                             'R') IN('05') THEN
                                             01
                                         ELSE
                                             CASE
                                                 WHEN sp000_ajusta_string(
                                                         CASE
                                                             WHEN(cl.codtpe = 3)
                                                                 AND(
                                                                 CASE
                                                                     WHEN tc.codigo IS NULL THEN
                                                                         a1.tdocum
                                                                     ELSE
                                                                         tc.codigo
                                                                 END
                                                             IN('01', '07', '08')) THEN
                                                                 CAST(CAST(
                                                                     CASE
                                                                         WHEN tc.codigo IS NULL THEN
                                                                             a1.tdocum
                                                                         ELSE
                                                                             tc.codigo
                                                                     END
                                                                 AS INTEGER) + 90 AS VARCHAR(10))
                                                             ELSE
                                                                 CASE
                                                                     WHEN tc.codigo IS NULL THEN
                                                                             a1.tdocum
                                                                     ELSE
                                                                         tc.codigo
                                                                 END
                                                         END,
                                                         02,
                                                         '0',
                                                         'R') IN('50', '52') THEN
                                                         03
                                                 ELSE
                                                     04
                                             END
                                     END,
                                     '0',
                                     'R') AS VARCHAR(20))                                    AS cnumser,
--            CAST(
--                CASE
--                    WHEN sp000_ajusta_string(
--                        CASE
--                            WHEN(cl.codtpe = 3)
--                                AND(
--                                CASE
--                                    WHEN tc.codigo IS NULL THEN
--                                        a1.tdocum
--                                    ELSE
--                                        tc.codigo
--                                END
--                            IN('01', '07', '08')) THEN
--                                CAST(CAST(
--                                    CASE
--                                        WHEN tc.codigo IS NULL THEN
--                                            a1.tdocum
--                                        ELSE
--                                            tc.codigo
--                                    END
--                                AS INTEGER) + 90 AS VARCHAR(10))
--                            ELSE
--                                CASE
--                                    WHEN tc.codigo IS NULL THEN
--                                            a1.tdocum
--                                    ELSE
--                                        tc.codigo
--                                END
--                        END,
--                        02,
--                        '0',
--                        'R') IN('50', '52') THEN
--                        c1.periodo
--                    ELSE
--                        0
--                END
--            AS VARCHAR(04))                                                 AS cemiduadsi,
            CASE
                WHEN nvl(c1.tdocum, a1.tdocum) IN ( '50', '52' ) THEN
                    a1.periodo
                ELSE
                    0
            END                                                             AS cemiduadsi,
            CAST(c1.numero AS VARCHAR(20))                                  AS cnumdcodfv,
            CAST(0 AS NUMERIC(16, 0))                                       AS operaconsolidada,
            CAST(substr(sp000_ajusta_string(
                CASE
                    WHEN(sp000_ajusta_string(
                        CASE
                            WHEN(cl.codtpe = 3)
                                AND(
                                CASE
                                    WHEN tc.codigo IS NULL THEN
                                        a1.tdocum
                                    ELSE
                                        tc.codigo
                                END
                            IN('01', '07', '08')) THEN
                                CAST(CAST(
                                    CASE
                                        WHEN tc.codigo IS NULL THEN
                                            a1.tdocum
                                        ELSE
                                            tc.codigo
                                    END
                                AS INTEGER) + 90 AS VARCHAR(10))
                            ELSE
                                CASE
                                    WHEN tc.codigo IS NULL THEN
                                            a1.tdocum
                                    ELSE
                                        tc.codigo
                                END
                        END,
                        02,
                        '0',
                        'R') IN('21')) THEN
                        '06'
                    ELSE
                        c1.tident
                END,
                02,
                '0',
                'R'),
                        02,
                        02) AS VARCHAR(02))                                             AS ctipdidpro,
            CAST(
                CASE
                    WHEN(sp000_ajusta_string(
                        CASE
                            WHEN(cl.codtpe = 3)
                                AND(
                                CASE
                                    WHEN tc.codigo IS NULL THEN
                                        a1.tdocum
                                    ELSE
                                        tc.codigo
                                END
                            IN('01', '07', '08')) THEN
                                CAST(CAST(
                                    CASE
                                        WHEN tc.codigo IS NULL THEN
                                            a1.tdocum
                                        ELSE
                                            tc.codigo
                                    END
                                AS INTEGER) + 90 AS VARCHAR(10))
                            ELSE
                                CASE
                                    WHEN tc.codigo IS NULL THEN
                                            a1.tdocum
                                    ELSE
                                        tc.codigo
                                END
                        END,
                        02,
                        '0',
                        'R') IN('21')) THEN
                        cm.ruc
                    ELSE
                        c1.dident
                END
            AS VARCHAR(15))                                                 AS cnumdidpro,
            a1.razon                                                        AS cnomrsopro,
            CAST(SUM(
                CASE
                    WHEN(a1.regcomcol = 1) THEN
                        a1.debe01 + a1.haber01
                    ELSE
                        0
                END
            ) * t.signo AS NUMERIC(16,
                 2))                                                        AS cbasimpgra,
            CAST(SUM(
                CASE
                    WHEN(a1.regcomcol = 6) THEN
                        a1.debe01 + a1.haber01
                    ELSE
                        0
                END
            ) * t.signo AS NUMERIC(16,
                 2))                                                        AS cigvgra,
            CAST(SUM(
                CASE
                    WHEN(a1.regcomcol = 2) THEN
                        a1.debe01 + a1.haber01
                    ELSE
                        0
                END
            ) * t.signo AS NUMERIC(16,
                 2))                                                        AS cbasimpgng,
            CAST(SUM(
                CASE
                    WHEN(a1.regcomcol = 8) THEN
                        a1.debe01 + a1.haber01
                    ELSE
                        0
                END
            ) * t.signo AS NUMERIC(16,
                 2))                                                        AS cigvgrangv,
            CAST(SUM(
                CASE
                    WHEN(a1.regcomcol = 5) THEN
                        a1.debe01 + a1.haber01
                    ELSE
                        0
                END
            ) * t.signo AS NUMERIC(16,
                 2))                                                        AS cbasimpscf,
            CAST(SUM(
                CASE
                    WHEN(a1.regcomcol = 7) THEN
                        a1.debe01 + a1.haber01
                    ELSE
                        0
                END
            ) * t.signo AS NUMERIC(16,
                 2))                                                        AS cigvscf,
            CAST(SUM(
                CASE
                    WHEN(a1.regcomcol = 4) THEN
                        a1.debe01 - a1.haber01
                    ELSE
                        0
                END
            ) AS NUMERIC(16,
                 2))                                                        AS cimptotngv,
            CAST(SUM(
                CASE
                    WHEN(a1.regcomcol = 10) THEN
                        a1.debe01 - a1.haber01
                    ELSE
                        0
                END
            ) AS NUMERIC(16,
                 2))                                                        AS cisc,
            CAST(SUM(
                CASE
                    WHEN(a1.regcomcol = 12) THEN
                        a1.debe01 - a1.haber01
                    ELSE
                        0
                END
            ) AS NUMERIC(16,
                 2))                                                        AS cicbper,
            CAST(SUM(
                CASE
                    WHEN(a1.regcomcol = 11) THEN
                        a1.debe01 - a1.haber01
                    ELSE
                        0
                END
            ) AS NUMERIC(16,
                 2))                                                        AS cotrtricgo,
            CAST(SUM(
                CASE
                    WHEN(a1.regcomcol = 9) THEN
                        a1.debe01 + a1.haber01
                    ELSE
                        0
                END
            ) * t.signo AS NUMERIC(16,
                 2))                                                        AS cimptotcom,
            c1.moneda                                                       AS cmoneda,
            CAST(a1.tcambio01 / a1.tcambio02 AS NUMERIC(06, 3))             AS ctipcam,
            CAST(
                CASE
                    WHEN(length(c1.numeroori) < 2) THEN
                        CAST('01/01/2021' AS VARCHAR(20))
                    WHEN c1.tDOCUM IN ('07','08') THEN
                        ((to_char(c1.femisiori, 'DD/MM/RRRR')))
                    ELSE
                        ''
                END
            AS VARCHAR(10))                                                 AS femisiori,
            c1.tdocumori,
            c1.nserieori,
            NULL                                                            mcodadudec,
            c1.numeroori,
            CASE
                WHEN sp000_ajusta_string(
                    CASE
                        WHEN(cl.codtpe = 3)
                            AND(
                            CASE
                                WHEN tc.codigo IS NULL THEN
                                    a1.tdocum
                                ELSE
                                    tc.codigo
                            END
                        IN('01', '07', '08')) THEN
                            CAST(CAST(
                                CASE
                                    WHEN tc.codigo IS NULL THEN
                                        a1.tdocum
                                    ELSE
                                        tc.codigo
                                END
                            AS INTEGER) + 90 AS VARCHAR(10))
                        ELSE
                            CASE
                                WHEN tc.codigo IS NULL THEN
                                        a1.tdocum
                                ELSE
                                    tc.codigo
                            END
                    END,
                    02,
                    '0',
                    'R') IN ( '91', '97', '98' ) THEN
                    c1.numero
                ELSE
                    '-'
            END                                                             AS nrocomnodom,
            CAST(
                CASE
                    WHEN length(c1.ddetrac) > 2 THEN
                        ((to_char(c1.fdetrac, 'DD/MM/RRRR')))
                    ELSE
                        CAST('' AS VARCHAR(20))
                END
            AS VARCHAR(10))                                                 AS cfemidepdet,
            CAST(c1.ddetrac AS VARCHAR(15))                                 AS cnrodetrac,
            CAST(
                CASE
                    WHEN c1.swafeccion IS NULL
                         OR c1.swafeccion <> 1 THEN
                        ' '
                    ELSE
                        '1'
                END
            AS VARCHAR(01))                                                 AS ccompgoret,
          /* (EXTRACT(YEAR  FROM C1.FEMISI)*100)+EXTRACT(MONTH FROM C1.FEMISI) AS LEVV,*/
            CASE
                WHEN ( a1.periodo * 100 + a1.mes ) > ( ( EXTRACT(YEAR FROM c1.femisi) * 100 ) + EXTRACT(MONTH FROM c1.femisi) ) THEN
                    0
                ELSE
                    CASE
                        WHEN pr.saldo IS NULL
                             OR pr.saldo = 0 THEN
                                1
                        ELSE
                            0
                    END
            END                                                             AS ccancelado,
            CASE
                WHEN ( sp000_ajusta_string(
                    CASE
                        WHEN(cl.codtpe = 3)
                            AND(
                            CASE
                                WHEN tc.codigo IS NULL THEN
                                    a1.tdocum
                                ELSE
                                    tc.codigo
                            END
                        IN('01', '07', '08')) THEN
                            CAST(CAST(
                                CASE
                                    WHEN tc.codigo IS NULL THEN
                                        a1.tdocum
                                    ELSE
                                        tc.codigo
                                END
                            AS INTEGER) + 90 AS VARCHAR(10))
                        ELSE
                            CASE
                                WHEN tc.codigo IS NULL THEN
                                        a1.tdocum
                                ELSE
                                    tc.codigo
                            END
                    END,
                    02,
                    '0',
                    'R') IN ( '00', '02', '03', '10', '15',
                              '16', '17', '18', '19', '21',
                              '22', '44', '45', '46', '49' ) ) THEN
                    0
                ELSE
                    CASE
                        WHEN ( a1.periodo * 100 + a1.mes ) = ( EXTRACT(YEAR FROM c1.femisi) * 100 + EXTRACT(MONTH FROM c1.femisi) ) THEN
                                1
                        ELSE
                            CASE
                                WHEN ( a1.periodo ) = ( EXTRACT(YEAR FROM c1.femisi) ) THEN
                                            6
                                ELSE  /*SI ESTA DENTO DEL AÑO */
                                    CASE
                                        WHEN ( a1.periodo ) > ( EXTRACT(YEAR FROM c1.femisi) + 1 ) THEN
                                                        7
                                        ELSE /* SI ES MAS DE UN AÑO */
                                            CASE
                                                WHEN ( ( a1.mes ) + ( 12 - EXTRACT(MONTH FROM c1.femisi) ) ) <= 12 THEN
                                                                    6
                                                ELSE
                                                    7
                                            END
                                    END
                            END
                    END
            END                                                             AS estado,
            t.signo,
            c1.bienser
        FROM
            movimientos    a1
            LEFT OUTER JOIN companias      cm ON cm.cia = pin_id_cia
            LEFT OUTER JOIN factor         fr ON ( fr.id_cia = a1.id_cia
                                           AND fr.codfac = 380 ) /* TIPO DE REGIMEN */
            LEFT OUTER JOIN compr010       c1 ON ( c1.id_cia = a1.id_cia
                                             AND c1.tipo = a1.tipo )
                                           AND ( c1.docume = a1.docume )
            LEFT OUTER JOIN prov100        pr ON ( pr.id_cia = a1.id_cia
                                            AND pr.tipo = a1.tipo )
                                          AND ( pr.docu = a1.docume )
            LEFT OUTER JOIN cliente        cl ON ( cl.id_cia = a1.id_cia
                                            AND cl.codcli = a1.codigo )
            LEFT OUTER JOIN tdocume        t ON t.id_cia = a1.id_cia
                                         AND ( t.codigo = a1.tdocum )
            LEFT OUTER JOIN tdocume_clases tc ON ( tc.id_cia = a1.id_cia
                                                   AND tc.tipdoc = a1.tdocum )
                                                 AND ( tc.clase = 5 )
            LEFT OUTER JOIN tlibro         l ON ( l.id_cia = a1.id_cia
                                          AND l.codlib = a1.libro )
        WHERE
                a1.id_cia = pin_id_cia
            AND a1.periodo = pin_periodo
            AND a1.mes = pin_mes
            AND a1.libro = '04'
            AND NOT ( a1.tdocum IN ( '91', '97', '98', 'DE' ) )
            AND a1.sitem = 0
            AND a1.tasien < 99
        GROUP BY
            fr.ventero,
            a1.periodo,
            a1.mes,
            a1.asiento,
            cl.codtpe,
            tc.codigo,
            a1.tdocum,
            c1.tdocum,
            c1.femisi,
            c1.periodo,
            c1.numero,
            c1.moneda,
            c1.fvenci,
            c1.nserie,
            c1.dident,
            c1.femisiori,
            cm.ruc,
            a1.razon,
            t.signo,
            c1.tident,
            c1.swafeccion,
            c1.fdetrac,
            a1.tipo,
            a1.docume,
            a1.tcambio01,
            a1.tcambio02,
            c1.ddetrac,
            pr.saldo,
            c1.tdocumori,
            c1.nserieori,
            c1.numeroori,
            a1.libro,
            c1.bienser
    ) LOOP
        reg.cperiodo := i.cperiodo;
        reg.cnumregope := i.cnumregope;
        reg.mcorrasien := i.mcorrasien;
        reg.cfeccom := i.cfeccom;
        reg.cfecvenpag := i.cfecvenpag;
        reg.ctipdoccom := i.ctipdoccom;
        reg.cnumser := i.cnumser;
        reg.cemiduadsi := i.cemiduadsi;
        reg.cnumdcodfv := i.cnumdcodfv;
        reg.operaconsolidada := i.operaconsolidada;
        reg.ctipdidpro := i.ctipdidpro;
        reg.cnumdidpro := i.cnumdidpro;
        reg.cnomrsopro := i.cnomrsopro;
        reg.cbasimpgra := i.cbasimpgra;
        reg.cigvgra := i.cigvgra;
        reg.cbasimpgng := i.cbasimpgng;
        reg.cigvgrangv := i.cigvgrangv;
        reg.cbasimpscf := i.cbasimpscf;
        reg.cigvscf := i.cigvscf;
        reg.cimptotngv := i.cimptotngv;
        reg.cisc := i.cisc;
        reg.cicbper := i.cicbper;
        reg.cotrtricgo := i.cotrtricgo;
        reg.cimptotcom := i.cimptotcom;
        reg.cmoneda := i.cmoneda;
        reg.ctipcam := i.ctipcam;
        reg.femisiori := i.femisiori;
        reg.tdocumori := i.tdocumori;
        reg.nserieori := i.nserieori;
        reg.mcodadudec := i.mcodadudec;
        reg.numeroori := i.numeroori;
        reg.nrocomnodom := i.nrocomnodom;
        reg.cfemidepdet := i.cfemidepdet;
        reg.cnrodetrac := i.cnrodetrac;
        reg.ccompgoret := i.ccompgoret;
        reg.ccancelado := i.ccancelado;
        IF i.bienser IS NOT NULL THEN
            reg.bienser := i.bienser;
        ELSE
            reg.bienser := ' ';
        END IF;

        reg.estado := i.estado;
        lsigno := i.signo;
        IF ( lsigno < 0 ) THEN
            reg.cimptotngv := abs(reg.cimptotngv) * -1;
        END IF;

        IF ( reg.ctipdoccom = '05' ) THEN
            reg.cnumser := '3';
        END IF;

        PIPE ROW ( reg );
    END LOOP;

    ------------- NEXT


    FOR i IN (
        SELECT
            c.periodo * 10000 + c.mes * 100                                AS cperiodo,
            c.tipo
            || '-'
            || c.docume                                                    AS cnumregope,
            CAST(
                CASE
                    WHEN c.libro = '00' THEN
                        'A'
                    ELSE
                        CASE
                            WHEN c.libro = '99' THEN
                                    'C'
                            ELSE
                                CASE
                                    WHEN fr.ventero = 2 THEN
                                                'M-RER'
                                    ELSE
                                        'M'
                                END
                        END
                END
                || sp000_ajusta_string(c.asiento, 4, '0', 'R') AS VARCHAR(10)) AS mcorrasien,
            CAST((to_char(c.femisi, 'DD/MM/RRRR')) AS VARCHAR(10))         AS cfeccom,
            '01/01/0001'                                                   AS cfecvenpag,
            CAST(c.tdocum AS VARCHAR(02))                                  AS ctipdoccom,
            CAST(c.nserie AS VARCHAR(20))                                  AS cnumser,
            0                                                              AS cemiduadsi,
            c.numero                                                       AS cnumdcodfv,
            0                                                              AS operaconsolidada,
            id.codsunat                                                    AS ctipdidpro,
            c.dident                                                       AS cnumdidpro,
            substr2(c.razon, 1, 100)                                       AS cnomrsopro,
            0                                                              AS cbasimpgra,
            0                                                              AS cigvgra,
            0                                                              AS cbasimpgng,
            0                                                              AS cigvgrangv,
            0                                                              AS cbasimpscf,
            0                                                              AS cigvscf,
            0                                                              AS cimptotngv,
            0                                                              AS cisc,
            0                                                              AS cicbper,
            0                                                              AS cotrtricgo,
            0                                                              AS cimptotcom,
            c.moneda                                                       AS cmoneda,
            CAST(c.tcamb01 / c.tcamb02 AS NUMERIC(06, 3))                  AS ctipcam,
            CAST('01/01/0001' AS VARCHAR(10))                              AS femisiori,
            c.tdocumori,
            c.nserieori,
            NULL                                                           mcodadudec,
            c.numeroori,
            '-'                                                            AS nrocomnodom,
            ''                                                             AS cfemidepdet,
            CAST(c.ddetrac AS VARCHAR(15))                                 AS cnrodetrac,
            CAST(
                CASE
                    WHEN c.swafeccion IS NULL
                         OR c.swafeccion <> 1 THEN
                        ' '
                    ELSE
                        '1'
                END
            AS VARCHAR(01))                                                AS ccompgoret,
            0                                                              AS ccancelado,
            0                                                              AS estado
        FROM
            compr010  c
            LEFT OUTER JOIN factor    fr ON fr.id_cia = c.id_cia
                                         AND ( fr.codfac = 380 ) /* TIPO DE REGIMEN */
            LEFT OUTER JOIN cliente   cl ON cl.id_cia = c.id_cia
                                          AND cl.codcli = c.codpro 
    --LEFT OUTER JOIN SP000_AJUSTA_STRING_FECHA(C.FVENCI   ,'DD/MM/RRRR') F2 ON F2.AJUSFEC IS NOT NULL
            LEFT OUTER JOIN identidad id ON id.id_cia = c.id_cia
                                            AND id.tident = c.tident
        WHERE
                c.id_cia = pin_id_cia
            AND c.periodo = pin_periodo
            AND c.mes = pin_mes
            AND c.tdocum = '04'
            AND c.situac = 9
            AND c.libro = '04'
    ) LOOP
        reg.cperiodo := i.cperiodo;
        reg.cnumregope := i.cnumregope;
        reg.mcorrasien := i.mcorrasien;
        reg.cfeccom := i.cfeccom;
        reg.cfecvenpag := i.cfecvenpag;
        reg.ctipdoccom := i.ctipdoccom;
        reg.cnumser := i.cnumser;
        reg.cemiduadsi := i.cemiduadsi;
        reg.cnumdcodfv := i.cnumdcodfv;
        reg.operaconsolidada := i.operaconsolidada;
        reg.ctipdidpro := i.ctipdidpro;
        reg.cnumdidpro := i.cnumdidpro;
        reg.cnomrsopro := i.cnomrsopro;
        reg.cbasimpgra := i.cbasimpgra;
        reg.cigvgra := i.cigvgra;
        reg.cbasimpgng := i.cbasimpgng;
        reg.cigvgrangv := i.cigvgrangv;
        reg.cbasimpscf := i.cbasimpscf;
        reg.cigvscf := i.cigvscf;
        reg.cimptotngv := i.cimptotngv;
        reg.cisc := i.cisc;
        reg.cicbper := i.cicbper;
        reg.cotrtricgo := i.cotrtricgo;
        reg.cimptotcom := i.cimptotcom;
        reg.cmoneda := i.cmoneda;
        reg.ctipcam := i.ctipcam;
        reg.femisiori := i.femisiori;
        reg.tdocumori := i.tdocumori;
        reg.nserieori := i.nserieori;
        reg.mcodadudec := i.mcodadudec;
        reg.numeroori := i.numeroori;
        reg.nrocomnodom := i.nrocomnodom;
        reg.cfemidepdet := i.cfemidepdet;
        reg.cnrodetrac := i.cnrodetrac;
        reg.ccompgoret := i.ccompgoret;
        reg.ccancelado := i.ccancelado;
        -- reg.bienser := i.bienser;


        reg.bienser := ' ';
        reg.estado := i.estado;
        IF ( reg.ctipdoccom = '05' ) THEN
            reg.cnumser := '3';
        END IF;

        PIPE ROW ( reg );
    END LOOP;

    RETURN;
END sp_ple_8_1_registro_compras;

/

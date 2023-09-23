--------------------------------------------------------
--  DDL for Package Body PACK_PLE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_PLE" AS

    FUNCTION IS_NUMERIC(P_INPUT IN VARCHAR2) 
    RETURN 
      INTEGER IS RESULT INTEGER;
      NUMERO NUMBER ;
    BEGIN
      NUMERO:=TO_NUMBER(P_INPUT);
      RETURN 1;
    EXCEPTION WHEN OTHERS THEN
      RETURN 0;
    END IS_NUMERIC;


    FUNCTION sp_ple_6_1_libro_mayor (
        pin_id_cia           NUMBER,
        pin_periodo          NUMBER,
        pin_mes              NUMBER,
        pin_asiento_apertura VARCHAR2,
        pin_asiento_cierre   VARCHAR2
    ) RETURN datatable_ple_6_1_libro_mayor
        PIPELINED
    AS
        v_table datatable_ple_6_1_libro_mayor;
    BEGIN
        SELECT
            ( d1.periodo * 10000 ) + ( (
                CASE
                    WHEN d1.mes = 0 THEN
                        1
                    ELSE
                        d1.mes
                END
            ) * 100 )                        AS mperiodo,
            CAST((
                SELECT
                    ajustado
                FROM
                    pack_ayuda_general.sp_ajusta_string(d1.libro, 02, '0', 'R')
            )
                 || '-'
                 ||(
                SELECT
                    ajustado
                FROM
                    pack_ayuda_general.sp_ajusta_string(CAST(d1.asiento AS VARCHAR(20)), 05, '0', 'R')
            )
                 || '-'
                 ||(
                SELECT
                    ajustado
                FROM
                    pack_ayuda_general.sp_ajusta_string(CAST(d1.item AS VARCHAR(20)), 05, '0', 'R')
            )
                 || '-'
                 ||(
                SELECT
                    ajustado
                FROM
                    pack_ayuda_general.sp_ajusta_string(CAST(d1.sitem AS VARCHAR(20)), 05, '0', 'R')
            ) AS VARCHAR(30))                AS mnumregope,
            CAST(
                CASE
                    WHEN d1.libro = '00' THEN
                        'A'
                    ELSE
                        CASE
                            WHEN d1.libro = '99' THEN
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
                || ax4.ajustado AS VARCHAR(10))  AS mcorrasien,
            '01' /* CODIGO DEL PLAN CONTABLE UTILIZADO  (TABLA 17)    */                             AS dcodplancon,
            d1.libro,
            d1.asiento,
            d1.tipo,
            d1.docume,
            d1.cuenta                        AS mnumctacon,
            d1.moneda                        AS mmoneda,
            cl.tident                        AS mtident,
            cl.dident                        AS mdident,
       /*D1.TIDENT                                                                                                               AS MTIDENT,
       D1.DIDENT                                                                                                               AS MDIDENT,*/
            CASE
                WHEN d1.tdocum IS NULL
                     OR d1.tdocum = ' '
                     OR LENGTH(REGEXP_REPLACE(d1.tdocum,' *[0-9]*')) > 0
                     OR d1.tdocum = ' ' THEN
                    '00'
                ELSE
                    CASE
                        WHEN NOT ( tc.codigo IS NULL ) THEN
                                tc.codigo
                        ELSE
                            CAST((
                                    SELECT
                                        ajustado
                                    FROM
                                        pack_ayuda_general.sp_ajusta_string(d1.tdocum, 2, '0', 'R')
                                ) AS VARCHAR(02))
                    END
            END                              AS mtdocum,
            CASE
                WHEN d1.tdocum IN ( '05' ) THEN
                    '2'
                ELSE
                    CASE
                        WHEN d1.tdocum IN ( '10' ) THEN
                                '1683'
                        ELSE
                            d1.serie
                    END
            END                              AS mserie,
            CASE
                WHEN d1.tdocum IN ( '05', '10' ) THEN
                    d1.numero
                ELSE
                    CASE
                        WHEN det.serie <> '' THEN
                                CAST(det.numero AS VARCHAR(20))
                        ELSE
                            d1.numero
                    END
            END                              AS mnumdoc,
            to_char(d1.fecha, 'DD/MM/YYYY')  AS mfecope,
            to_char(d1.fdocum, 'DD/MM/YYYY') AS mfvenci,
            to_char(d1.fdocum, 'DD/MM/YYYY') AS mfdocum,
            d1.concep                        AS mglosa,
            abs(d1.debe01)                   AS mdebe,
            abs(d1.haber01)                  AS mhaber,
            ''                               AS mcorrventas,
            ''                               AS mcorrcompra,
            ''                               AS mcorrconsig,
            CASE
                WHEN tlc.vstrg = '14' THEN  /* VENTAS */
                    '140100&'
                    || CAST(d1.periodo * 10000 + d1.mes * 100 AS VARCHAR(08))
                    || '&'
                    ||
                    CASE
                        WHEN fr.ventero = 1 THEN
                                CAST(d1.serie AS VARCHAR(20))
                                || '-'
                                || CAST(d1.numero AS VARCHAR(20))
                                || '-'
                                || CAST(d1.libro AS VARCHAR(20))
                                || '-'
                                || CAST(ax5.ajustado AS VARCHAR(20))
                        ELSE
                            CAST(d1.libro AS VARCHAR(20))
                            || '-'
                            || CAST(ax5.ajustado AS VARCHAR(20))
                    END
                    || '&'
                    || CAST(
                        CASE
                            WHEN d1.libro = '00' THEN
                                'A'
                            ELSE
                                CASE
                                    WHEN d1.libro = '99' THEN
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
                        || ax4.ajustado AS VARCHAR(20))
                ELSE
                    CASE
                        WHEN tlc.vstrg = '8' THEN  /* COMPRAS */
                                    CASE
                                        WHEN NOT ( d1.tdocum IS NULL )
                                                 AND NOT ( d1.tdocum IN ( '91', '97', '98' ) ) THEN
                                            '080100&'
                                        ELSE
                                            '080200&'
                                    END
                                    || CAST(d1.periodo * 10000 + d1.mes * 100 AS VARCHAR(08))
                                    || '&'
                                    ||
                                    CASE
                                        WHEN fr.ventero = 1 THEN
                                            CAST(d1.tipo
                                                 || '-'
                                                 || d1.docume AS VARCHAR(20))
                                        ELSE
                                            CAST(ax5.ajustado AS VARCHAR(20))
                                    END
                                    || '&'
                                    || CAST(
                                    CASE
                                        WHEN d1.libro = '00' THEN
                                            'A'
                                        ELSE
                                            CASE
                                                WHEN d1.libro = '99' THEN
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
                                    || ax4.ajustado AS VARCHAR(20))
                        ELSE
                            ''/* OTROS */
                    END
            END                              AS mcodestruc,
            1  /* SE SUPONE QUE EL REGISTRO FUE DENTRO DEL PERIODO DADO */                                AS estado
        BULK COLLECT
        INTO v_table
        FROM
            movimientos                                                                                  d1
            LEFT OUTER JOIN asiendet                                                                                     det ON det.id_cia =
            d1.id_cia
                                            AND det.periodo = d1.periodo
                                            AND det.mes = d1.mes
                                            AND det.libro = d1.libro
                                            AND det.asiento = d1.asiento
                                            AND det.item = d1.item
                                            AND det.sitem = d1.sitem
            LEFT OUTER JOIN tdocume_clases                                                                               tc ON tc.id_cia =
            d1.id_cia
                                                 AND ( tc.tipdoc = d1.tdocum )
                                                 AND tc.clase = 5
            LEFT OUTER JOIN cliente                                                                                      cl ON cl.id_cia =
            d1.id_cia
                                          AND cl.codcli = d1.codigo
            LEFT OUTER JOIN tlibros_clase                                                                                tlc ON tlc.id_cia =
            d1.id_cia
                                                 AND tlc.codlib = d1.libro
                                                 AND tlc.clase = 1
            LEFT OUTER JOIN TABLE ( pack_ayuda_general.sp_ajusta_string(CAST(d1.asiento AS VARCHAR(10)), 04, '0', 'R') ) ax4 ON ax4.ajustado
            IS NOT NULL
            LEFT OUTER JOIN TABLE ( pack_ayuda_general.sp_ajusta_string(CAST(d1.asiento AS VARCHAR(10)), 05, '0', 'R') ) ax5 ON ax5.ajustado
            IS NOT NULL
            LEFT OUTER JOIN factor                                                                                       fr ON fr.id_cia =
            d1.id_cia
                                         AND ( fr.codfac = 380 ) /* TIPO DE REGIMEN */
        WHERE
                d1.id_cia = pin_id_cia
            AND ( d1.periodo = pin_periodo )
            AND ( ( d1.mes = pin_mes )
                  OR ( ( 'S' = upper(pin_asiento_apertura) )
                       AND ( d1.mes = 0 ) ) )
            AND ( ( 'S' = upper(pin_asiento_cierre) )
                  OR ( d1.libro <> '99' ) )
            AND ( d1.debe01 <> d1.haber01 )
        ORDER BY
            d1.periodo,
            d1.mes,
            d1.cuenta,
            d1.libro,
            d1.asiento,
            d1.item,
            d1.sitem;

        FOR registro IN 1..v_table.count LOOP
       /*     IF (IS_NUMERIC(registro.mtdocum) = 0) THEN
                registro.mtdocum := '00';
            END IF;*/
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_ple_6_1_libro_mayor;

    FUNCTION sp_ple_5_3 (
        pin_id_cia    NUMBER,
        pin_periodo   NUMBER,
        pin_mes       NUMBER,
        pin_inccierre VARCHAR2
    ) RETURN datatable_ple_5_3
        PIPELINED
    AS
        v_table datatable_ple_5_3;
    BEGIN
        SELECT DISTINCT
            pc.cuenta,
            upper(pc.nombre) AS cdescri,
            '01'             AS codplan,
            '-'              AS desplan,
            '1'              estado
        BULK COLLECT
        INTO v_table
        FROM
                 pcuentas pc
            INNER JOIN movimientos d1 ON ( d1.id_cia = pc.id_cia )
                                         AND ( pc.cuenta = d1.cuenta )
                                         AND ( ( 'S' = upper(pin_inccierre) )
                                               OR ( d1.libro <> '99' ) )
        WHERE
                pc.id_cia = pin_id_cia
            AND d1.periodo = pin_periodo
            AND d1.mes = pin_mes
            AND d1.debe01 <> d1.haber01
            AND length(pc.cuenta) >= 3
        ORDER BY
            pc.cuenta;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_ple_5_3;

    FUNCTION sp_ple_5_1_libro_diario (
        pin_id_cia           NUMBER,
        pin_periodo          NUMBER,
        pin_mes              NUMBER,
        pin_asiento_apertura VARCHAR2,
        pin_asiento_cierre   VARCHAR2
    ) RETURN datatable_ple_5_1_libro_diario
        PIPELINED
    AS
        v_table datatable_ple_5_1_libro_diario;
    BEGIN
        SELECT
            ( d1.periodo * 10000 ) + ( (
                CASE
                    WHEN d1.mes = 0 THEN
                        1
                    ELSE
                        d1.mes
                END
            ) * 100 )                        AS mperiodo,
            CAST((
                SELECT
                    ajustado
                FROM
                    pack_ayuda_general.sp_ajusta_string(d1.libro, 02, '0', 'R')
            )
                 || '-'
                 ||(
                SELECT
                    ajustado
                FROM
                    pack_ayuda_general.sp_ajusta_string(CAST(d1.asiento AS VARCHAR(20)), 05, '0', 'R')
            )
                 || '-'
                 ||(
                SELECT
                    ajustado
                FROM
                    pack_ayuda_general.sp_ajusta_string(CAST(d1.item AS VARCHAR(20)), 05, '0', 'R')
            )
                 || '-'
                 ||(
                SELECT
                    ajustado
                FROM
                    pack_ayuda_general.sp_ajusta_string(CAST(d1.sitem AS VARCHAR(20)), 05, '0', 'R')
            ) AS VARCHAR(30))                AS mnumregope,
            CAST(
                CASE
                    WHEN d1.libro = '00' THEN
                        'A'
                    ELSE
                        CASE
                            WHEN d1.libro = '99' THEN
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
                || ax4.ajustado AS VARCHAR(10))  AS mcorrasien,
            '01' /* CODIGO DEL PLAN CONTABLE UTILIZADO  (TABLA 17)    */                             AS dcodplancon,
            d1.libro,
            d1.asiento,
            d1.tipo,
            d1.docume,
            d1.cuenta                        AS mnumctacon,
            d1.moneda                        AS mmoneda,
            cl.tident                        AS mtident,
            cl.dident                        AS mdident,
--       /*D1.TIDENT                                                                                                               AS MTIDENT,
--       D1.DIDENT                                                                                                               AS MDIDENT,*/
            CASE
                WHEN d1.tdocum IS NULL
                     OR d1.tdocum = ' '
                     OR LENGTH(REGEXP_REPLACE(d1.tdocum,' *[0-9]*')) > 0
                     OR d1.tdocum = ' ' THEN
                    '00'
                ELSE
                    CASE
                        WHEN NOT ( tc.codigo IS NULL ) THEN
                                tc.codigo
                        ELSE
                            CAST((
                                    SELECT
                                        ajustado
                                    FROM
                                        pack_ayuda_general.sp_ajusta_string(d1.tdocum, 2, '0', 'R')
                                ) AS VARCHAR(02))
                    END
            END                              AS mtdocum,
            CASE
                WHEN d1.tdocum IN ( '05' ) THEN
                    '2'
                ELSE
                    CASE
                        WHEN d1.tdocum IN ( '10' ) THEN
                                '1683'
                        ELSE
                            d1.serie
                    END
            END                              AS mserie,
            CASE
                WHEN d1.tdocum IN ( '05', '10' ) THEN
                    d1.numero
                ELSE
                    CASE
                        WHEN det.serie <> '' THEN
                                CAST(det.numero AS VARCHAR(20))
                        ELSE
                            d1.numero
                    END
            END                              AS mnumdoc,
            to_char(d1.fecha, 'DD/MM/YYYY')  AS mfecope,
            to_char(d1.fdocum, 'DD/MM/YYYY') AS mfvenci,
            to_char(d1.fdocum, 'DD/MM/YYYY') AS mfdocum,
            d1.concep                        AS mglosa,
            abs(d1.debe01)                   AS mdebe,
            abs(d1.haber01)                  AS mhaber,
            ''                               AS mcorrventas,
            ''                               AS mcorrcompra,
            ''                               AS mcorrconsig,
            CASE
                WHEN tlc.vstrg = '14' THEN  /* VENTAS */
                    '140100&'
                    || CAST(d1.periodo * 10000 + d1.mes * 100 AS VARCHAR(08))
                    || '&'
                    ||
                    CASE
                        WHEN fr.ventero = 1 THEN
                                CAST(d1.serie AS VARCHAR(20))
                                || '-'
                                || CAST(d1.numero AS VARCHAR(20))
                                || '-'
                                || CAST(d1.libro AS VARCHAR(20))
                                || '-'
                                || CAST(ax5.ajustado AS VARCHAR(20))
                        ELSE
                            CAST(d1.libro AS VARCHAR(20))
                            || '-'
                            || CAST(ax5.ajustado AS VARCHAR(20))
                    END
                    || '&'
                    || CAST(
                        CASE
                            WHEN d1.libro = '00' THEN
                                'A'
                            ELSE
                                CASE
                                    WHEN d1.libro = '99' THEN
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
                        || ax4.ajustado AS VARCHAR(20))
                ELSE
                    CASE
                        WHEN tlc.vstrg = '8' THEN  /* COMPRAS */
                                    CASE
                                        WHEN NOT ( d1.tdocum IS NULL )
                                                 AND NOT ( d1.tdocum IN ( '91', '97', '98' ) ) THEN
                                            '080100&'
                                        ELSE
                                            '080200&'
                                    END
                                    || CAST(d1.periodo * 10000 + d1.mes * 100 AS VARCHAR(08))
                                    || '&'
                                    ||
                                    CASE
                                        WHEN fr.ventero = 1 THEN
                                            CAST(d1.tipo
                                                 || '-'
                                                 || d1.docume AS VARCHAR(20))
                                        ELSE
                                            CAST(ax5.ajustado AS VARCHAR(20))
                                    END
                                    || '&'
                                    || CAST(
                                    CASE
                                        WHEN d1.libro = '00' THEN
                                            'A'
                                        ELSE
                                            CASE
                                                WHEN d1.libro = '99' THEN
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
                                    || ax4.ajustado AS VARCHAR(20))
                        ELSE
                            ''/* OTROS */
                    END
            END                              AS mcodestruc,
            1  /* SE SUPONE QUE EL REGISTRO FUE DENTRO DEL PERIODO DADO */                                AS estado
        BULK COLLECT
        INTO v_table
        FROM
            movimientos                                                                                  d1
            LEFT OUTER JOIN asiendet                                                                                     det ON det.id_cia =
            d1.id_cia
                                            AND det.periodo = d1.periodo
                                            AND det.mes = d1.mes
                                            AND det.libro = d1.libro
                                            AND det.asiento = d1.asiento
                                            AND det.item = d1.item
                                            AND det.sitem = d1.sitem
            LEFT OUTER JOIN tdocume_clases                                                                               tc ON tc.id_cia =
            d1.id_cia
                                                 AND ( tc.tipdoc = d1.tdocum )
                                                 AND tc.clase = 5
            LEFT OUTER JOIN cliente                                                                                      cl ON cl.id_cia =
            d1.id_cia
                                          AND cl.codcli = d1.codigo
            LEFT OUTER JOIN tlibros_clase                                                                                tlc ON tlc.id_cia =
            d1.id_cia
                                                 AND tlc.codlib = d1.libro
                                                 AND tlc.clase = 1
            LEFT OUTER JOIN TABLE ( pack_ayuda_general.sp_ajusta_string(CAST(d1.asiento AS VARCHAR(10)), 04, '0', 'R') ) ax4 ON ax4.ajustado
            IS NOT NULL
            LEFT OUTER JOIN TABLE ( pack_ayuda_general.sp_ajusta_string(CAST(d1.asiento AS VARCHAR(10)), 05, '0', 'R') ) ax5 ON ax5.ajustado
            IS NOT NULL
            LEFT OUTER JOIN factor                                                                                       fr ON fr.id_cia =
            d1.id_cia
                                         AND ( fr.codfac = 380 ) /* TIPO DE REGIMEN */
        WHERE
                d1.id_cia = pin_id_cia
            AND ( d1.periodo = pin_periodo )
            AND ( ( d1.mes = pin_mes )
                  OR ( ( 'S' = upper(pin_asiento_apertura) )
                       AND ( d1.mes = 0 ) ) )
            AND ( ( 'S' = upper(pin_asiento_cierre) )
                  OR ( d1.libro <> '99' ) )
            AND ( d1.debe01 <> d1.haber01 )
        ORDER BY
            d1.periodo,
            d1.mes,
            d1.cuenta,
            d1.libro,
            d1.asiento,
            d1.item,
            d1.sitem;

        FOR registro IN 1..v_table.count LOOP
           /* IF (IS_NUMERIC(registro.mtdocum) = 0) THEN
                registro.mtdocum := '00';
            END IF;*/
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_ple_5_1_libro_diario;

END;

/

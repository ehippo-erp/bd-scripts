--------------------------------------------------------
--  DDL for Package Body PACK_KARDEX_VALORIZADO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_KARDEX_VALORIZADO" AS

    FUNCTION sp_ingreso_salida (
        pin_id_cia   INTEGER,
        pin_tipinv   INTEGER,
        pin_codart   VARCHAR2,
        pin_anio     INTEGER,
        pin_mes      INTEGER,
        pin_moneda   VARCHAR2,
        pin_codadd01 VARCHAR2,
        pin_codadd02 VARCHAR2
    ) RETURN datatable_kardex_valorizado
        PIPELINED
    AS

        v_record        datarecord_kardex_valorizado := datarecord_kardex_valorizado(NULL, NULL, NULL, NULL, NULL,
                                                                             NULL, NULL, NULL, NULL, NULL,
                                                                             NULL, NULL, NULL, NULL, NULL,
                                                                             NULL, NULL, NULL, NULL, NULL,
                                                                             NULL, NULL, NULL, NULL, NULL,
                                                                             NULL, NULL, NULL, NULL, NULL,
                                                                             NULL, NULL, NULL, NULL, NULL,
                                                                             NULL, NULL, NULL, NULL, NULL,
                                                                             NULL, NULL);
        v_priorperiod   INTEGER;
        v_currentperiod INTEGER;
        CURSOR cur_select (
            panterior INTEGER,
            pactual   INTEGER
        ) IS
        SELECT
            a.tipinv,
            ti.dtipinv,
            ac2.codigo         AS codfam,
            ac2.desclase       AS desfam,
            ac3.codigo         AS codlin,
            ac3.desclase       AS deslin,
            a.codart,
            a.descri           AS desart,
            u.abrevi           AS codunisunat,
            ka.id,
            mc.valor           AS tipope,
            mo.abrevi          AS abrmot,
            mo.desmot          AS desmot,
            ka.numint,
            ka.numite,
            dcl.codcla         AS tipdoc,
            dc.series,
            dc.numdoc,
            dt.abrevi          AS desdoc,
            dc.femisi,
            ka.codalm,
            al.descri          AS desalm,
            al.abrevi          AS abralm,
            mn.desmon,
            mn.simbolo,
            si.cantid          AS stockini,
            CASE
                WHEN si.cantid <> 0 THEN
                    si.costo01 / si.cantid
                ELSE
                    0
            END                AS cosuniini01,
            si.costo01         AS costotini01,
            CASE
                WHEN si.cantid <> 0 THEN
                    si.costo02 / si.cantid
                ELSE
                    0
            END                AS cosuniini02,
            si.costo01         AS costotini02,
            CASE
                WHEN ka.id = 'I' THEN
                    ka.cantid
                ELSE
                    0
            END                AS caning,
            CASE
                WHEN ( ( ka.id = 'I' )
                       AND ( ka.cantid <> 0 ) ) THEN
                    ka.costot01 / ka.cantid
                ELSE
                    0
            END                AS cosuniing01,
            CASE
                WHEN ka.id = 'I' THEN
                    ka.costot01
                ELSE
                    0
            END                AS costoting01,
            CASE
                WHEN ( ( ka.id = 'I' )
                       AND ( ka.cantid <> 0 ) ) THEN
                    ka.costot02 / ka.cantid
                ELSE
                    0
            END                AS cosuniing02,
            CASE
                WHEN ka.id = 'I' THEN
                    ka.costot02
                ELSE
                    0
            END                AS costoting02,
            CASE
                WHEN ka.id = 'S' THEN
                    ka.cantid
                ELSE
                    0
            END                AS cansal,
            CASE
                WHEN ( ( ka.id = 'S' )
                       AND ( ka.cantid <> 0 ) ) THEN
                    ka.costot01 / ka.cantid
                ELSE
                    0
            END                AS cosunisal01,
            CASE
                WHEN ka.id = 'S' THEN
                    ka.costot01
                ELSE
                    0
            END                AS costotsal01,
            CASE
                WHEN ( ( ka.id = 'S' )
                       AND ( ka.cantid <> 0 ) ) THEN
                    ka.costot02 / ka.cantid
                ELSE
                    0
            END                AS cosunisal02,
            CASE
                WHEN ka.id = 'S' THEN
                    ka.costot02
                ELSE
                    0
            END                AS costotsal02,
            sf.cantid          AS stockfinal,
            CASE
                WHEN sf.cantid <> 0 THEN
                    sf.costo01 / sf.cantid
                ELSE
                    0
            END                AS cosunifin01,
            sf.costo01         AS costotfin01,
            CASE
                WHEN sf.cantid <> 0 THEN
                    sf.costo02 / sf.cantid
                ELSE
                    0
            END                AS cosunifin02,
            sf.costo02         AS costotfin02,
            ti.cuenta          AS ctatinv,
            pc.nombre          AS desctatinv,
            NULL               AS codadd01,
            NULL               AS dcodadd01,
            NULL               AS codadd02,
            NULL               AS dcodadd02,
            nvl(mk.valor, 'N') AS mc46,
            CASE
            WHEN mc49.valor IS NULL THEN
                dc.codmot
            ELSE
                CAST(mc49.valor AS INTEGER)
        END        AS worden
        FROM
            articulos                                                              a
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(a.id_cia, a.tipinv, a.codart, 2) ac2 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(a.id_cia, a.tipinv, a.codart, 3) ac3 ON 0 = 0
            LEFT OUTER JOIN t_inventario                                                           ti ON ti.id_cia = a.id_cia
                                               AND ti.tipinv = a.tipinv
            LEFT OUTER JOIN pcuentas                                                               pc ON pc.id_cia = a.id_cia
                                           AND pc.cuenta = ti.cuenta
            -- SOLO ARTICULO CON MOVIMIENTO EN EL PERIODO ACTUAL
            INNER JOIN kardex                                                                 ka ON ka.id_cia = a.id_cia
                                    AND ka.tipinv = a.tipinv
                                    AND ka.codart = a.codart
                                    AND length(TRIM(ka.codadd01)) IS NULL
                                    AND length(TRIM(ka.codadd02)) IS NULL
                                    AND ka.periodo = pactual
            LEFT OUTER JOIN almacen                                                                al ON al.id_cia = ka.id_cia
                                          AND al.tipinv = ka.tipinv
                                          AND al.codalm = ka.codalm
            LEFT OUTER JOIN tmoneda                                                                mn ON mn.id_cia = pin_id_cia
                                          AND mn.codmon = pin_moneda
            LEFT OUTER JOIN documentos_cab                                                         dc ON dc.id_cia = ka.id_cia
                                                 AND dc.numint = ka.numint
            LEFT OUTER JOIN documentos_tipo                                                        dt ON dt.id_cia = dc.id_cia
                                                  AND dt.tipdoc = dc.tipdoc
            LEFT OUTER JOIN motivos                                                                mo ON mo.id_cia = dc.id_cia
                                          AND mo.tipdoc = dc.tipdoc
                                          AND mo.id = dc.id
                                          AND mo.codmot = dc.codmot
            LEFT OUTER JOIN motivos_clase                                                          mc ON mc.id_cia = dc.id_cia
                                                AND mc.tipdoc = dc.tipdoc
                                                AND mc.id = dc.id
                                                AND mc.codmot = dc.codmot
                                                AND mc.codigo = 12
            LEFT OUTER JOIN motivos_clase                                                          mk ON mk.id_cia = dc.id_cia
                                                AND mk.tipdoc = dc.tipdoc
                                                AND mk.id = dc.id
                                                AND mk.codmot = dc.codmot
                                                AND mk.codigo = 46
                        LEFT OUTER JOIN motivos_clase                                                          mc49 ON mc49.id_cia = dc.id_cia
                                                  AND mc49.tipdoc = dc.tipdoc
                                                  AND mc49.id = dc.id
                                                  AND mc49.codmot = dc.codmot
                                                  AND mc49.codigo = 49  /* 49- ORDEN PARA PROCESO DE COSTEO */
            LEFT OUTER JOIN documentos_clase                                                       dcl ON dcl.id_cia = dc.id_cia
                                                    AND dcl.codigo = dc.tipdoc
                                                    AND dcl.series = dc.series
                                                    AND dcl.clase = 10
            LEFT OUTER JOIN articulos_costo                                                        si ON si.id_cia = a.id_cia
                                                  AND si.tipinv = a.tipinv
                                                  AND si.codart = a.codart
                                                  AND si.periodo = panterior
            LEFT OUTER JOIN articulos_costo                                                        sf ON sf.id_cia = a.id_cia
                                                  AND sf.tipinv = a.tipinv
                                                  AND sf.codart = a.codart
                                                  AND sf.periodo = pactual
            LEFT OUTER JOIN unidad                                                                 u ON u.id_cia = a.id_cia
                                        AND a.coduni = u.coduni
        WHERE
                a.id_cia = pin_id_cia
            AND a.tipinv = pin_tipinv
            AND ( pin_codart IS NULL
                  OR a.codart = pin_codart )
            AND ( pin_codadd01 IS NULL
                  OR ka.codadd01 = pin_codadd01 )
            AND ( pin_codadd02 IS NULL
                  OR ka.codadd02 = pin_codadd02 )
            AND ( ( ka.cantid <> 0 )
                  OR ( NOT ( si.cantid IS NULL )
                           AND si.cantid <> 0 )
                  OR ( NOT ( sf.cantid IS NULL )
                           AND sf.cantid <> 0 )
                  OR ( NOT ( si.costo01 IS NULL )
                           AND si.costo01 <> 0 )
                  OR ( NOT ( sf.costo01 IS NULL )
                           AND sf.costo01 <> 0 )
                  OR ( NOT ( si.costo02 IS NULL )
                           AND si.costo02 <> 0 )
                  OR ( NOT ( sf.costo02 IS NULL )
                           AND sf.costo02 <> 0 ) )
        UNION
        SELECT
            a.tipinv,
            ti.dtipinv,
            ac2.codigo         AS codfam,
            ac2.desclase       AS desfam,
            ac3.codigo         AS codlin,
            ac3.desclase       AS deslin,
            a.codart,
            a.descri           AS desart,
            u.abrevi           AS codunisunat,
            ka.id,
            mc.valor           AS tipope,
            mo.abrevi          AS abrmot,
            mo.desmot          AS desmot,
            ka.numint,
            ka.numite,
            dcl.codcla         AS tipdoc,
            dc.series,
            dc.numdoc,
            dt.abrevi          AS desdoc,
            dc.femisi,
            ka.codalm,
            al.descri          AS desalm,
            al.abrevi          AS abralm,
            mn.desmon,
            mn.simbolo,
            sia.cantid         AS stockini,
            CASE
                WHEN sia.cantid <> 0 THEN
                    sia.costo01 / sia.cantid
                ELSE
                    0
            END                AS cosuniini01,
            sia.costo01        AS costotini01,
            CASE
                WHEN sia.cantid <> 0 THEN
                    sia.costo02 / sia.cantid
                ELSE
                    0
            END                AS cosuniini02,
            sia.costo02        AS costotini02,
            CASE
                WHEN ka.id = 'I' THEN
                    ka.cantid
                ELSE
                    0
            END                AS caning,
            CASE
                WHEN ( ( ka.id = 'I' )
                       AND ( ka.cantid <> 0 ) ) THEN
                    ka.costot01 / ka.cantid
                ELSE
                    0
            END                AS cosuniing01,
            CASE
                WHEN ka.id = 'I' THEN
                    ka.costot01
                ELSE
                    0
            END                AS costoting01,
            CASE
                WHEN ( ( ka.id = 'I' )
                       AND ( ka.cantid <> 0 ) ) THEN
                    ka.costot02 / ka.cantid
                ELSE
                    0
            END                AS cosuniing02,
            CASE
                WHEN ka.id = 'I' THEN
                    ka.costot02
                ELSE
                    0
            END                AS costoting02,
            CASE
                WHEN ka.id = 'S' THEN
                    ka.cantid
                ELSE
                    0
            END                AS cansal,
            CASE
                WHEN ( ( ka.id = 'S' )
                       AND ( ka.cantid <> 0 ) ) THEN
                    ka.costot01 / ka.cantid
                ELSE
                    0
            END                AS cosunisal01,
            CASE
                WHEN ka.id = 'S' THEN
                    ka.costot01
                ELSE
                    0
            END                AS costotsal01,
            CASE
                WHEN ( ( ka.id = 'S' )
                       AND ( ka.cantid <> 0 ) ) THEN
                    ka.costot02 / ka.cantid
                ELSE
                    0
            END                AS cosunisal02,
            CASE
                WHEN ka.id = 'S' THEN
                    ka.costot02
                ELSE
                    0
            END                AS costotsal02,
            sfa.cantid         AS stockfinal,
            CASE
                WHEN sfa.cantid <> 0 THEN
                    sfa.costo01 / sfa.cantid
                ELSE
                    0
            END                AS cosunifin01,
            sfa.costo01        AS costotfin01,
            CASE
                WHEN sfa.cantid <> 0 THEN
                    sfa.costo02 / sfa.cantid
                ELSE
                    0
            END                AS cosunifin02,
            sfa.costo02        AS costotfin02,
            ti.cuenta          AS ctatinv,
            pc.nombre          AS desctatinv,
            ka.codadd01        AS codadd01,
            ca1.descri         AS dcodadd01,
            ka.codadd02        AS codadd02,
            ca2.descri         AS dcodadd02,
            nvl(mk.valor, 'N') AS mc46,
            CASE
            WHEN mc49.valor IS NULL THEN
                dc.codmot
            ELSE
                CAST(mc49.valor AS INTEGER)
        END        AS worden
        FROM
            articulos                                                              a
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(a.id_cia, a.tipinv, a.codart, 2) ac2 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(a.id_cia, a.tipinv, a.codart, 3) ac3 ON 0 = 0
            LEFT OUTER JOIN t_inventario                                                           ti ON ti.id_cia = a.id_cia
                                               AND ti.tipinv = a.tipinv
            LEFT OUTER JOIN pcuentas                                                               pc ON pc.id_cia = a.id_cia
                                           AND pc.cuenta = ti.cuenta
            -- ARTICULOS SOLO CON MOVIMIENTO EN EL PERIODO ACTUAL
            INNER JOIN kardex                                                                 ka ON ka.id_cia = a.id_cia
                                    AND ka.tipinv = a.tipinv
                                    AND ka.codart = a.codart
                                    AND length(TRIM(ka.codadd01)) IS NOT NULL
                                    AND length(TRIM(ka.codadd02)) IS NOT NULL
                                    AND ka.periodo = pactual
            LEFT OUTER JOIN almacen                                                                al ON al.id_cia = ka.id_cia
                                          AND al.tipinv = ka.tipinv
                                          AND al.codalm = ka.codalm
            LEFT OUTER JOIN tmoneda                                                                mn ON mn.id_cia = a.id_cia
                                          AND mn.codmon = pin_moneda
            LEFT OUTER JOIN documentos_cab                                                         dc ON dc.id_cia = ka.id_cia
                                                 AND dc.numint = ka.numint
            LEFT OUTER JOIN documentos_tipo                                                        dt ON dt.id_cia = dc.id_cia
                                                  AND dt.tipdoc = dc.tipdoc
            LEFT OUTER JOIN motivos                                                                mo ON mo.id_cia = dc.id_cia
                                          AND mo.tipdoc = dc.tipdoc
                                          AND mo.id = dc.id
                                          AND mo.codmot = dc.codmot
            LEFT OUTER JOIN motivos_clase                                                          mc ON mc.id_cia = dc.id_cia
                                                AND mc.tipdoc = dc.tipdoc
                                                AND mc.id = dc.id
                                                AND mc.codmot = dc.codmot
                                                AND mc.codigo = 12
            LEFT OUTER JOIN motivos_clase                                                          mc49 ON mc49.id_cia = dc.id_cia
                                                  AND mc49.tipdoc = dc.tipdoc
                                                  AND mc49.id = dc.id
                                                  AND mc49.codmot = dc.codmot
                                                  AND mc49.codigo = 49  /* 49- ORDEN PARA PROCESO DE COSTEO */
            LEFT OUTER JOIN motivos_clase                                                          mk ON mk.id_cia = dc.id_cia
                                                AND mk.tipdoc = dc.tipdoc
                                                AND mk.id = dc.id
                                                AND mk.codmot = dc.codmot
                                                AND mk.codigo = 46
            LEFT OUTER JOIN documentos_clase                                                       dcl ON dcl.id_cia = dc.id_cia
                                                    AND dcl.codigo = dc.tipdoc
                                                    AND dcl.series = dc.series
                                                    AND dcl.clase = 10
            LEFT OUTER JOIN articulos_costo_codadd                                                 sia ON sia.id_cia = a.id_cia
                                                          AND sia.tipinv = a.tipinv
                                                          AND sia.codart = a.codart
                                                          AND sia.codadd01 = ka.codadd01
                                                          AND sia.codadd02 = ka.codadd02
                                                          AND sia.periodo = panterior
            LEFT OUTER JOIN articulos_costo_codadd                                                 sfa ON sfa.id_cia = a.id_cia
                                                          AND sfa.tipinv = a.tipinv
                                                          AND sfa.codart = a.codart
                                                          AND sfa.codadd01 = ka.codadd01
                                                          AND sfa.codadd02 = ka.codadd02
                                                          AND sfa.periodo = pactual
            LEFT OUTER JOIN unidad                                                                 u ON u.id_cia = a.id_cia
                                        AND a.coduni = u.coduni
            LEFT OUTER JOIN cliente_articulos_clase                                                ca1 ON ca1.id_cia = a.id_cia
                                                           AND ca1.tipcli = 'B'
                                                           AND ca1.codcli = a.codprv
                                                           AND ca1.clase = 1
                                                           AND ca1.codigo = ka.codadd01
            LEFT OUTER JOIN cliente_articulos_clase                                                ca2 ON ca2.id_cia = a.id_cia
                                                           AND ca2.tipcli = 'B'
                                                           AND ca2.codcli = a.codprv
                                                           AND ca2.clase = 2
                                                           AND ca2.codigo = ka.codadd02
        WHERE
                a.id_cia = pin_id_cia
            AND a.tipinv = pin_tipinv
            AND ( pin_codart IS NULL
                  OR a.codart = pin_codart )
            AND ( pin_codadd01 IS NULL
                  OR ka.codadd01 = pin_codadd01 )
            AND ( pin_codadd02 IS NULL
                  OR ka.codadd02 = pin_codadd02 )
            AND ( ( ka.cantid <> 0 )
                  OR ( NOT ( sia.cantid IS NULL )
                           AND sia.cantid <> 0 )
                  OR ( NOT ( sfa.cantid IS NULL )
                           AND sfa.cantid <> 0 )
                  OR ( NOT ( sia.costo01 IS NULL )
                           AND sia.costo01 <> 0 )
                  OR ( NOT ( sfa.costo01 IS NULL )
                           AND sfa.costo01 <> 0 )
                  OR ( NOT ( sia.costo02 IS NULL )
                           AND sia.costo02 <> 0 )
                  OR ( NOT ( sfa.costo02 IS NULL )
                           AND sfa.costo02 <> 0 ) )
        UNION ALL
        -- SE ADICIONO ESTA UNION PARA CONSIDERAR LOS TOTALES DE TODOS LOS ARTICULOS , O ARTICULOS SIN MOVIMIENTO PERO CON STOCK
        SELECT
            ac.tipinv,
            ti.dtipinv,
            ac2.codigo                AS codfam,
            ac2.desclase              AS desfam,
            ac3.codigo                AS codlin,
            ac3.desclase              AS deslin,
            a.codart,
            a.descri                  AS desart,
            u.abrevi                  AS codunisunat,
            'A'                       AS id,
            CAST(NULL AS VARCHAR(25)) AS tipope,
            CAST(NULL AS VARCHAR(6))  AS desmot,
            CAST(NULL AS VARCHAR(6))  AS abrmot,
            CAST(NULL AS INTEGER)     AS numint,
            CAST(NULL AS INTEGER)     AS numite,
            CAST(NULL AS VARCHAR(20)) AS tipdoc,
            CAST(NULL AS VARCHAR(5))  AS series,
            CAST(NULL AS INTEGER)     AS numdoc,
            NULL                      AS desdoc,
            TO_DATE('01/'
                    || TRIM(to_char(pin_mes, '00'))
                    || TRIM(to_char(pin_anio, '0000')),
                    'DD/MM/YY')       AS femisi,
            CAST(NULL AS INTEGER)     AS codalm,
            CAST(NULL AS VARCHAR(50)) AS desalm,
            CAST(NULL AS VARCHAR(10)) AS abralm,
            mn.desmon,
            mn.simbolo,
            ac.cantid                 AS stockini,
            CASE
                WHEN ac.cantid <> 0 THEN
                    ac.costo01 / ac.cantid
                ELSE
                    0
            END                       AS cosuniini01,
            ac.costo01                AS costotini01,
            CASE
                WHEN ac.cantid <> 0 THEN
                    ac.costo02 / ac.cantid
                ELSE
                    0
            END                       AS cosuniini02,
            ac.costo02                AS costotini02,
            CAST(0 AS NUMERIC(16, 4)) AS caning,
            CAST(0 AS NUMERIC(18, 6)) AS cosuniing01,
            CAST(0 AS NUMERIC(16, 2)) AS costoting01,
            CAST(0 AS NUMERIC(18, 6)) AS cosuniing02,
            CAST(0 AS NUMERIC(16, 2)) AS costoting02,
            CAST(0 AS NUMERIC(16, 4)) AS cansal,
            CAST(0 AS NUMERIC(18, 6)) AS cosunisal01,
            CAST(0 AS NUMERIC(16, 2)) AS costotsal01,
            CAST(0 AS NUMERIC(18, 6)) AS cosunisal02,
            CAST(0 AS NUMERIC(16, 2)) AS costotsal02,
            ac.cantid                 AS stockfinal,
            CASE
                WHEN ac.cantid <> 0 THEN
                    ac.costo01 / ac.cantid
                ELSE
                    0
            END                       AS cosunifin01,
            ac.costo01                AS costotfin01,
            CASE
                WHEN ac.cantid <> 0 THEN
                    ac.costo02 / ac.cantid
                ELSE
                    0
            END                       AS cosunifin02,
            ac.costo02                AS costotfin02,
            ti.cuenta                 AS ctatinv,
            pc.nombre                 AS desctatinv,
            NULL                      AS codadd01,
            NULL                      AS dcodadd01,
            NULL                      AS codadd02,
            NULL                      AS dcodadd02,
            'N'                       AS mc46,
            NULL as worden
        FROM
            articulos_costo                                                        ac
            LEFT OUTER JOIN t_inventario                                                           ti ON ti.id_cia = ac.id_cia
                                               AND ti.tipinv = ac.tipinv
            LEFT OUTER JOIN pcuentas                                                               pc ON pc.id_cia = ti.id_cia
                                           AND pc.cuenta = ti.cuenta
            LEFT OUTER JOIN articulos                                                              a ON a.id_cia = ac.id_cia
                                           AND a.tipinv = ac.tipinv
                                           AND a.codart = ac.codart
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(a.id_cia, a.tipinv, a.codart, 2) ac2 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(a.id_cia, a.tipinv, a.codart, 3) ac3 ON 0 = 0
            LEFT OUTER JOIN unidad                                                                 u ON u.id_cia = a.id_cia
                                        AND u.coduni = a.coduni
            LEFT OUTER JOIN tmoneda                                                                mn ON mn.id_cia = ac.id_cia
                                          AND mn.codmon = pin_moneda
        WHERE
                ac.id_cia = pin_id_cia
            AND ac.tipinv = pin_tipinv
            AND ( pin_codart IS NULL
                  OR ac.codart = pin_codart )
            AND ac.periodo = panterior
            AND ( ac.cantid <> 0
                  OR ( ac.costo01 <> 0
                       OR ac.costo02 <> 0 ) )
        UNION ALL
        SELECT
            ac.tipinv,
            ti.dtipinv,
            ac2.codigo                AS codfam,
            ac2.desclase              AS desfam,
            ac3.codigo                AS codlin,
            ac3.desclase              AS deslin,
            a.codart,
            a.descri                  AS desart,
            u.abrevi                  AS codunisunat,
            'A'                       AS id,
            CAST(NULL AS VARCHAR(25)) AS tipope,
            CAST(NULL AS VARCHAR(6))  AS desmot,
            CAST(NULL AS VARCHAR(6))  AS abrmot,
            CAST(NULL AS INTEGER)     AS numint,
            CAST(NULL AS INTEGER)     AS numite,
            CAST(NULL AS VARCHAR(20)) AS tipdoc,
            CAST(NULL AS VARCHAR(5))  AS series,
            CAST(NULL AS INTEGER)     AS numdoc,
            NULL                      AS desdoc,
            TO_DATE('01/'
                    || TRIM(to_char(pin_mes, '00'))
                    || TRIM(to_char(pin_anio, '0000')),
                    'DD/MM/YY')       AS femisi,
            CAST(NULL AS INTEGER)     AS codalm,
            CAST(NULL AS VARCHAR(50)) AS desalm,
            CAST(NULL AS VARCHAR(10)) AS abralm,
            mn.desmon,
            mn.simbolo,
            ac.cantid                 AS stockini,
            CASE
                WHEN ac.cantid <> 0 THEN
                    ac.costo01 / ac.cantid
                ELSE
                    0
            END                       AS cosuniini01,
            ac.costo01                AS costotini01,
            CASE
                WHEN ac.cantid <> 0 THEN
                    ac.costo02 / ac.cantid
                ELSE
                    0
            END                       AS cosuniini02,
            ac.costo02                AS costotini02,
            CAST(0 AS NUMERIC(16, 4)) AS caning,
            CAST(0 AS NUMERIC(18, 6)) AS cosuniing01,
            CAST(0 AS NUMERIC(16, 2)) AS costoting01,
            CAST(0 AS NUMERIC(18, 6)) AS cosuniing02,
            CAST(0 AS NUMERIC(16, 2)) AS costoting02,
            CAST(0 AS NUMERIC(16, 4)) AS cansal,
            CAST(0 AS NUMERIC(18, 6)) AS cosunisal01,
            CAST(0 AS NUMERIC(16, 2)) AS costotsal01,
            CAST(0 AS NUMERIC(18, 6)) AS cosunisal02,
            CAST(0 AS NUMERIC(16, 2)) AS costotsal02,
            ac.cantid                 AS stockfinal,
            CASE
                WHEN ac.cantid <> 0 THEN
                    ac.costo01 / ac.cantid
                ELSE
                    0
            END                       AS cosunifin01,
            ac.costo01                AS costotfin01,
            CASE
                WHEN ac.cantid <> 0 THEN
                    ac.costo02 / ac.cantid
                ELSE
                    0
            END                       AS cosunifin02,
            ac.costo02                AS costotfin02,
            ti.cuenta                 AS ctatinv,
            pc.nombre                 AS desctatinv,
            ac.codadd01               AS codadd01,
            ca1.descri                AS dcodadd01,
            ac.codadd02               AS codadd02,
            ca2.descri                AS dcodadd02,
            'N'                       AS mc46,
            NULL as worden
        FROM
            articulos_costo_codadd                                                 ac
            LEFT OUTER JOIN t_inventario                                                           ti ON ti.id_cia = ac.id_cia
                                               AND ti.tipinv = ac.tipinv
            LEFT OUTER JOIN pcuentas                                                               pc ON pc.id_cia = ti.id_cia
                                           AND pc.cuenta = ti.cuenta
            LEFT OUTER JOIN articulos                                                              a ON a.id_cia = ac.id_cia
                                           AND a.tipinv = ac.tipinv
                                           AND a.codart = ac.codart
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(a.id_cia, a.tipinv, a.codart, 2) ac2 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(a.id_cia, a.tipinv, a.codart, 3) ac3 ON 0 = 0
            LEFT OUTER JOIN unidad                                                                 u ON u.id_cia = ac.id_cia
                                        AND a.coduni = u.coduni
            LEFT OUTER JOIN tmoneda                                                                mn ON mn.id_cia = ac.id_cia
                                          AND mn.codmon = pin_moneda
            LEFT OUTER JOIN cliente_articulos_clase                                                ca1 ON ca1.id_cia = a.id_cia
                                                           AND ca1.tipcli = 'B'
                                                           AND ca1.codcli = a.codprv
                                                           AND ca1.clase = 1
                                                           AND ca1.codigo = ac.codadd01
            LEFT OUTER JOIN cliente_articulos_clase                                                ca2 ON ca2.id_cia = a.id_cia
                                                           AND ca2.tipcli = 'B'
                                                           AND ca2.codcli = a.codprv
                                                           AND ca2.clase = 2
                                                           AND ca2.codigo = ac.codadd02
        WHERE
                ac.id_cia = pin_id_cia
            AND ac.tipinv = pin_tipinv
            AND ( pin_codart IS NULL
                  OR ac.codart = pin_codart )
            AND ( pin_codadd01 IS NULL
                  OR ac.codadd01 = pin_codadd01 )
            AND ( pin_codadd02 IS NULL
                  OR ac.codadd02 = pin_codadd02 )
            AND ac.periodo = panterior
            AND ( ac.cantid <> 0
                  OR ( ac.costo01 <> 0
                       OR ac.costo02 <> 0 ) )
        ORDER BY
            1, -- TIPINV
            3, -- CODFAM
            5, -- CODART
            7, -- ID
            20; -- FEMISI
--            53; -- 

    BEGIN
        v_priorperiod := ( pin_anio * 100 ) + ( pin_mes - 1 );
        v_currentperiod := ( pin_anio * 100 ) + pin_mes;
        FOR registro IN cur_select(v_priorperiod, v_currentperiod) LOOP
            v_record.id_cia := pin_id_cia;
            v_record.tipinv := registro.tipinv;
            v_record.dtipinv := registro.dtipinv;
            v_record.codfam := registro.codfam;
            v_record.desfam := registro.desfam;
            v_record.codlin := registro.codlin;
            v_record.deslin := registro.deslin;
            v_record.codart := registro.codart;
            v_record.desart := registro.desart;
            v_record.codunisunat := registro.codunisunat;
            v_record.id := registro.id;
--            v_record.tipope := registro.tipope;
            v_record.desmot := registro.desmot;
            v_record.abrmot := registro.abrmot;
            v_record.numint := registro.numint;
            v_record.numite := registro.numite;
            CASE
                WHEN registro.abrmot IS NULL THEN
                    v_record.tipope := substr(upper(registro.desmot), 1, 15);
                ELSE
                    v_record.tipope := upper(registro.abrmot);
            END CASE;

            v_record.series := registro.series;
            v_record.numdoc := registro.numdoc;
            v_record.femisi := registro.femisi;
            v_record.tipdoc := upper(registro.desdoc);
            v_record.codalm := registro.codalm;
            v_record.desalm := registro.desalm;
            v_record.abralm := registro.abralm;
            v_record.desmon := registro.desmon;
            v_record.simbolo := registro.simbolo;
            v_record.stockini := nvl(registro.stockini, 0);
            IF ( pin_moneda = 'PEN' ) THEN
                v_record.cosuniini := nvl(registro.cosuniini01, 0);
                v_record.costotini := nvl(registro.costotini01, 0);
                v_record.cosuniing := nvl(registro.cosuniing01, 0);
                v_record.costoting := nvl(registro.costoting01, 0);
                v_record.cosunisal := nvl(registro.cosunisal01, 0);
                v_record.costotsal := nvl(registro.costotsal01, 0);
                v_record.cosunifin := nvl(registro.cosunifin01, 0);
                v_record.costotfin := nvl(registro.costotfin01, 0);
            ELSE
                v_record.cosuniini := nvl(registro.cosuniini02, 0);
                v_record.costotini := nvl(registro.costotini02, 0);
                v_record.cosuniing := nvl(registro.cosuniing02, 0);
                v_record.costoting := nvl(registro.costoting02, 0);
                v_record.cosunisal := nvl(registro.cosunisal02, 0);
                v_record.costotsal := nvl(registro.costotsal02, 0);
                v_record.cosunifin := nvl(registro.cosunifin02, 0);
                v_record.costotfin := nvl(registro.costotfin02, 0);
            END IF;

            v_record.caning := nvl(registro.caning, 0);
            v_record.cansal := nvl(registro.cansal, 0);
            v_record.stockfinal := nvl(registro.stockfinal, 0);
            v_record.ctatinv := registro.ctatinv;
            v_record.desctatinv := registro.desctatinv;
            v_record.codadd01 := registro.codadd01;
            v_record.dcodadd01 := registro.dcodadd01;
            v_record.codadd02 := registro.codadd02;
            v_record.dcodadd02 := registro.dcodadd02;
            v_record.mc46 := registro.mc46;
            v_record.worden := NVL(to_number(registro.worden),-1);
            PIPE ROW ( v_record );
        END LOOP;

        RETURN;
    END sp_ingreso_salida;

    FUNCTION sp_buscar (
        pin_id_cia   INTEGER,
        pin_tipinv   INTEGER,
        pin_codart   VARCHAR2,
        pin_anio     INTEGER,
        pin_mes      INTEGER,
        pin_moneda   VARCHAR2,
        pin_codadd01 VARCHAR2,
        pin_codadd02 VARCHAR2
    ) RETURN datatable_kardex_valorizado
        PIPELINED
    AS

        v_numint     NUMBER := -1;
        v_aux        NUMBER := 0;
        v_imprime    VARCHAR2(1 CHAR) := 'N';
        v_tipinv     NUMBER := 1;
        v_codart     VARCHAR2(50) := 'XXXXXXXXX';
        v_stockfinal NUMBER(18, 2);
        v_cosunifin  NUMBER(18, 2);
        v_costotfin  NUMBER(18, 2);
        v_stockini   NUMBER(18, 2);
        v_cosuniini  NUMBER(18, 2);
        v_costotini  NUMBER(18, 2);
        v_stocking   NUMBER(18, 2);
        v_cosuniing  NUMBER(18, 2);
        v_costoting  NUMBER(18, 2);
        v_stocksal   NUMBER(18, 2);
        v_cosunisal  NUMBER(18, 2);
        v_costotsal  NUMBER(18, 2);
        v_pd_numint  NUMBER := -1;
        x_stocking   NUMBER(18, 2);
        x_cosuniing  NUMBER(18, 2);
        x_costoting  NUMBER(18, 2);
        x_stocksal   NUMBER(18, 2);
        x_cosunisal  NUMBER(18, 2);
        x_costotsal  NUMBER(18, 2);
        rec          datarecord_kardex_valorizado;
        CURSOR kardex_ingeso_salida IS
        SELECT
            *
        FROM
            sp_ingreso_salida(pin_id_cia, pin_tipinv, pin_codart, pin_anio, pin_mes,
                              pin_moneda, pin_codadd01, pin_codadd02)
        ORDER BY
            tipinv,
            codfam,
            codart,
            femisi, 
            id,
            worden,
            numint,
            numite;
            
    BEGIN
        FOR i IN kardex_ingeso_salida LOOP
            v_imprime := 'S';
            IF v_tipinv <> i.tipinv OR v_codart <> i.codart THEN
                -- IMPRIMIENDO TOTALES DEL ARTICULO ANTERIOR
                rec.tipope := NULL;
                rec.desmot := NULL;
                rec.abrmot := NULL;
                rec.numint := NULL;
                rec.numite := NULL;
                rec.tipdoc := NULL;
                rec.series := NULL;
                rec.numdoc := NULL;
                rec.femisi := NULL;
                rec.codalm := NULL;
                rec.desalm := NULL;
                rec.abralm := NULL;
                rec.stockini := v_stockini;
                rec.cosuniini := 0;
                rec.costotini := v_costotini;
                rec.cansal := v_stocksal - x_stocksal;
                rec.cosunisal := 0;
                rec.costotsal := v_costotsal - x_costotsal;
                rec.caning := v_stocking - x_stocking;
                rec.cosuniing := 0;
                rec.costoting := v_costoting - x_costoting;
                rec.cosunifin := 0;
                rec.mc46 := 'N';
                rec.id := 'F';
                IF ( v_aux > 0 ) THEN
                    PIPE ROW ( rec );
                END IF;
                v_aux := 1 + v_aux;
                v_stockini := 0;
                v_costotini := 0;
                v_stocking := 0;
                v_costoting := 0;
                v_stocksal := 0;
                v_costotsal := 0;
                x_stocking := 0;
                x_cosuniing := 0;
                x_costoting := 0;
                x_stocksal := 0;
                x_cosunisal := 0;
                x_costotsal := 0;
            END IF;
            -- IMPRIMIENDO CABEZERA
            rec.id_cia := i.id_cia;
            rec.tipinv := i.tipinv;
            rec.dtipinv := i.dtipinv;
            rec.codfam := i.codfam;
            rec.desfam := i.desfam;
            rec.codlin := i.codlin;
            rec.deslin := i.deslin;
            rec.codart := i.codart;
            rec.desart := i.desart;
            rec.codunisunat := i.codunisunat;
            -- PARA IDENTIFICAR REGISTROS SECUNDARIOS DEL ARTICULO
            IF
                v_tipinv = i.tipinv
                AND v_codart = i.codart
            THEN
            -- SEGUNDA LINEA DEL ARTICULO
                rec.id := i.id;
                rec.tipope := i.tipope;
                rec.desmot := i.desmot;
                rec.abrmot := i.abrmot;
                rec.numint := i.numint;
                rec.numite := i.numite;
                rec.tipdoc := i.tipdoc;
                rec.series := i.series;
                rec.numdoc := i.numdoc;
                rec.femisi := i.femisi;
                rec.codalm := i.codalm;
                rec.desalm := i.desalm;
                rec.abralm := i.abralm;
                rec.desmon := i.desmon;
                rec.simbolo := i.simbolo;
                -- CALCULO | ARTICULO CON MOVIMIENTO
                IF rec.id = 'I' THEN
                    rec.stockini := v_stockfinal;
                    rec.cosuniini := v_cosunifin;
                    rec.costotini := v_costotfin;
                    rec.caning := i.caning;
                    rec.cosuniing := i.cosuniing;
                    rec.costoting := i.costoting;
                    rec.cansal := 0;
                    rec.cosunisal := 0;
                    rec.costotsal := 0;
                    rec.stockfinal := ( v_stockfinal + i.caning );
                    rec.costotfin := ( v_costotfin + i.costoting );
                    CASE
                        WHEN rec.stockfinal = 0 THEN
                            rec.cosunifin := 0;
                        ELSE
                            rec.cosunifin := round(rec.costotfin / rec.stockfinal, 2);
                    END CASE;

                    v_stocking := v_stocking + rec.caning;
                    v_costoting := v_costoting + rec.costoting;
                ELSIF rec.id = 'S' THEN
                    rec.stockini := v_stockfinal;
                    rec.cosuniini := v_cosunifin;
                    rec.costotini := v_costotfin;
                    rec.caning := 0;
                    rec.cosuniing := 0;
                    rec.costoting := 0;
                    rec.cansal := i.cansal;
                    rec.cosunisal := i.cosunisal;
                    rec.costotsal := i.costotsal;
                    rec.stockfinal := ( v_stockfinal - i.cansal );
                    rec.costotfin := ( v_costotfin - i.costotsal );
                    CASE
                        WHEN rec.stockfinal = 0 THEN
                            rec.cosunifin := 0;
                        ELSE
                            rec.cosunifin := round(rec.costotfin / rec.stockfinal, 2);
                    END CASE;

                    v_stocksal := v_stocksal + rec.cansal;
                    v_costotsal := v_costotsal + rec.costotsal;
                END IF;
                    -- GUARDANDO VALORES PARA LLEVAR EL ACUMULADO
                v_stockfinal := rec.stockfinal;
                v_cosunifin := rec.cosunifin;
                v_costotfin := rec.costotfin;
                    -- FIN
                rec.ctatinv := i.ctatinv;
                rec.desctatinv := i.desctatinv;
                rec.codadd01 := i.codadd01;
                rec.codadd02 := i.codadd02;
                rec.dcodadd01 := i.dcodadd01;
                rec.dcodadd02 := i.dcodadd02;
                IF i.mc46 IN ( 'N' ) THEN
                    PIPE ROW ( rec );
                ELSE
                    x_stocking := x_stocking + rec.caning;
                    x_cosuniing := 0;
                    x_costoting := x_costoting + rec.costoting;
                    x_stocksal := x_stocksal + rec.cansal;
                    x_cosunisal := 0;
                    x_costotsal := x_costotsal + rec.costotsal;
                END IF;

            ELSE
                -- PRIMERA LINEA DEL ARTICULO
                -- IMPRIME LOS TOTALES DEL ARTICULO
                -- ASIGNANDO
                v_tipinv := rec.tipinv;
                v_codart := rec.codart;
                v_stockfinal := 0;
                v_cosunifin := 0;
                v_costotfin := 0;
                -- IMPRIMIENDO
                rec.tipope := NULL;
                rec.desmot := NULL;
                rec.abrmot := NULL;
                rec.numint := NULL;
                rec.numite := NULL;
                rec.tipdoc := NULL;
                rec.series := NULL;
                rec.numdoc := NULL;
                rec.femisi := NULL;
                rec.codalm := NULL;
                rec.desalm := NULL;
                rec.abralm := NULL;
                rec.desmon := i.desmon;
                rec.simbolo := i.simbolo;
                -- NO HAY NINGUN CALCULO / STOCK INICIAL ANTES DE LA APERTURA
                rec.stockini := i.stockini;
                rec.cosuniini := i.cosuniini;
                rec.costotini := i.costotini;
                rec.caning := 0;
                rec.cosuniing := 0;
                rec.costoting := 0;
                rec.cansal := 0;
                rec.cosunisal := 0;
                rec.costotsal := 0;
                rec.stockfinal := i.stockini;
                rec.cosunifin := i.cosuniini;
                rec.costotfin := i.costotini;
                -- FIN
                rec.ctatinv := i.ctatinv;
                rec.desctatinv := i.desctatinv;
                rec.codadd01 := i.codadd01;
                rec.codadd02 := i.codadd02;
                rec.dcodadd01 := i.dcodadd01;
                rec.dcodadd02 := i.dcodadd02;
                IF pin_mes = 0 OR i.id IN ( 'I', 'S' ) THEN  -- SOLO SI ES INVENTARIO DE APERTURA
                --- O SI EL ARTICULO NO TENIA STOCK AL INICIAL EL PERIODO ( ARTICULOS_COSTO )
                    v_stockini := rec.stockini;
                    v_cosuniini := rec.cosuniini;
                    v_costotini := rec.costotini;
                    rec.id := 'T';
                    PIPE ROW ( rec );
                    rec.id := i.id;
                ELSE
                    rec.id := 'T';
                END IF;
                -- IMPRIMIENDO EL PRIMER MOVIMIENTO DEL ARTICULO
                rec.tipope := i.tipope;
                rec.desmot := i.desmot;
                rec.abrmot := i.abrmot;
                rec.numint := i.numint;
                rec.numite := i.numite;
                rec.tipdoc := i.tipdoc;
                rec.series := i.series;
                rec.numdoc := i.numdoc;
                rec.femisi := i.femisi;
                rec.codalm := i.codalm;
                rec.desalm := i.desalm;
                rec.abralm := i.abralm;
                rec.desmon := i.desmon;
                rec.simbolo := i.simbolo;
                    -- CALCULO | ARTICULO CON MOVIMIENTO
                IF rec.id = 'I' THEN
                    rec.stockini := i.stockini;
                    rec.cosuniini := i.cosuniini;
                    rec.costotini := i.costotini;
                    rec.caning := i.caning;
                    rec.cosuniing := i.cosuniing;
                    rec.costoting := i.costoting;
                    rec.cansal := 0;
                    rec.cosunisal := 0;
                    rec.costotsal := 0;
                    rec.stockfinal := ( rec.stockini + i.caning );
                    rec.costotfin := ( rec.costotfin + i.costoting );
                    CASE
                        WHEN rec.stockfinal = 0 THEN
                            rec.cosunifin := 0;
                        ELSE
                            rec.cosunifin := round(rec.costotfin / rec.stockfinal, 2);
                    END CASE;

                    v_stocking := v_stocking + rec.caning;
                    v_costoting := v_costoting + rec.costoting;
                ELSIF rec.id = 'S' THEN
                    rec.stockini := i.stockini;
                    rec.cosuniini := i.cosuniini;
                    rec.costotini := i.costotini;
                    rec.caning := 0;
                    rec.cosuniing := 0;
                    rec.costoting := 0;
                    rec.cansal := i.cansal;
                    rec.cosunisal := i.cosunisal;
                    rec.costotsal := i.costotsal;
                    rec.stockfinal := ( rec.stockini - i.cansal );
                    rec.costotfin := ( rec.costotini - i.costotsal );
                    CASE
                        WHEN rec.stockfinal = 0 THEN
                            rec.cosunifin := 0;
                        ELSE
                            rec.cosunifin := round(rec.costotfin / rec.stockfinal, 2);
                    END CASE;

                    v_stocksal := v_stocksal + rec.cansal;
                    v_costotsal := v_costotsal + rec.costotsal;
                ELSIF rec.id = 'T' THEN
                    rec.femisi := NULL; -- ELIMINAR FECHA ( SOLO SE USO PARA EL ORDENAMIENTO )
                    rec.stockini := i.stockini;
                    rec.cosuniini := i.cosuniini;
                    rec.costotini := i.costotini;
                    v_stockini := rec.stockini;
                    v_cosuniini := rec.cosuniini;
                    v_costotini := rec.costotini;
                    rec.caning := 0;
                    rec.cosuniing := 0;
                    rec.costoting := 0;
                    rec.cansal := 0;
                    rec.cosunisal := 0;
                    rec.costotsal := 0;
                    rec.stockfinal := i.stockfinal;
                    rec.costotfin := i.costotfin;
                    rec.cosunifin := i.cosunifin;
                END IF;
                    -- GUARDANDO VALORES PARA LLEVAR EL ACUMULADO
                v_stockfinal := rec.stockfinal;
                v_cosunifin := rec.cosunifin;
                v_costotfin := rec.costotfin;
                    -- FIN
                rec.ctatinv := i.ctatinv;
                rec.desctatinv := i.desctatinv;
                rec.codadd01 := i.codadd01;
                rec.codadd02 := i.codadd02;
                rec.dcodadd01 := i.dcodadd01;
                rec.dcodadd02 := i.dcodadd02;
                IF i.mc46 IN ( 'N' ) THEN -- CLASE DEL MOTIVO 46 - OCULTO EN KARDEX O EN PLE
                    PIPE ROW ( rec );
                ELSE
                    x_stocking := x_stocking + rec.caning;
                    x_cosuniing := 0;
                    x_costoting := x_costoting + rec.costoting;
                    x_stocksal := x_stocksal + rec.cansal;
                    x_cosunisal := 0;
                    x_costotsal := x_costotsal + rec.costotsal;
                END IF;

            END IF;
                -- VARIABLE AUXILIAR
            v_numint := nvl(i.numint, -1);
            rec.mc46 := i.mc46;
        END LOOP;

        --IMPRIMIENDO TOTAL DEL ULTIMO ARTICULO
        rec.tipope := NULL;
        rec.desmot := NULL;
        rec.abrmot := NULL;
        rec.numint := NULL;
        rec.numite := NULL;
        rec.tipdoc := NULL;
        rec.series := NULL;
        rec.numdoc := NULL;
        rec.femisi := NULL;
        rec.codalm := NULL;
        rec.desalm := NULL;
        rec.abralm := NULL;
        rec.stockini := v_stockini;
        rec.cosuniini := 0;
        rec.costotini := v_costotini;
        -- SALIDA
        rec.cansal := v_stocksal - x_stocksal;
        rec.cosunisal := 0;
        rec.costotsal := v_costotsal - x_costotsal;
        -- INGRESO
        rec.caning := v_stocking - x_stocking;
        rec.cosuniing := 0;
        rec.costoting := v_costoting - x_costoting;
        -- FINAL
        rec.cosunifin := 0;
        rec.mc46 := 'N';
        rec.id := 'F';
        IF v_imprime = 'S' THEN
            PIPE ROW ( rec );
        END IF;
    END sp_buscar;

    FUNCTION sp_buscar_test (
        pin_id_cia   INTEGER,
        pin_tipinv   INTEGER,
        pin_codart   VARCHAR2,
        pin_anio     INTEGER,
        pin_mes      INTEGER,
        pin_moneda   VARCHAR2,
        pin_codadd01 VARCHAR2,
        pin_codadd02 VARCHAR2
    ) RETURN datatable_kardex_valorizado
        PIPELINED
    AS

        v_aux        NUMBER := 0;
        v_tipinv     NUMBER := 999;
        v_codart     VARCHAR2(50) := 'XXXXXXXXX';
        v_id         VARCHAR2(10);
        v_stockfinal NUMBER(18, 2);
        v_cosunifin  NUMBER(18, 2);
        v_costotfin  NUMBER(18, 2);
        rec          datarecord_kardex_valorizado;
        CURSOR kardex_ingeso_salida IS
        SELECT
            *
        FROM
            sp_ingreso_salida(pin_id_cia, pin_tipinv, pin_codart, pin_anio, pin_mes,
                              pin_moneda, pin_codadd01, pin_codadd02);

    BEGIN
        FOR i IN kardex_ingeso_salida LOOP
            IF ( v_tipinv <> i.tipinv OR v_codart <> i.codart ) THEN
                -- IMPRIMIENDO TOTALES DEL ARTICULO ANTERIOR
                rec.cansal := 0;
                rec.cosunisal := 0;
                rec.costotsal := 0;
                rec.caning := 0;
                rec.cosuniing := 0;
                rec.costoting := 0;
                rec.id := 'F';
                IF ( v_aux > 0 ) THEN
                    PIPE ROW ( rec );
                END IF;
                v_aux := 1 + v_aux;
            END IF;

            IF i.id IS NULL THEN
            -- SIGNIFICA QUE NO EXISTE MOVIMIENTO DE ESE ARTICULO
            -- IMPRIME LOS TOTALES DEL ARTICULO
                -- ASIGNANDO
                v_tipinv := i.tipinv;
                v_codart := i.codart;
                -- IMPRIMIENDO
                rec.id_cia := i.id_cia;
                rec.tipinv := i.tipinv;
                rec.dtipinv := i.dtipinv;
                rec.codfam := i.codfam;
                rec.desfam := i.desfam;
                rec.codlin := i.codlin;
                rec.deslin := i.deslin;
                rec.codart := i.codart;
                rec.desart := i.desart;
                rec.codunisunat := i.codunisunat;
                rec.id := 'T';
                rec.tipope := NULL;
                rec.desmot := NULL;
                rec.abrmot := NULL;
                rec.numint := NULL;
                rec.numite := NULL;
                rec.tipdoc := NULL;
                rec.series := NULL;
                rec.numdoc := NULL;
                rec.femisi := NULL;
                rec.codalm := NULL;
                rec.desalm := NULL;
                rec.abralm := NULL;
                rec.desmon := i.desmon;
                rec.simbolo := i.simbolo;
                -- NO HAY NINGUN CALCULO / STOCK INICIAL - PRIMERA LINEA DEL REPORTE
                rec.stockini := i.stockini;
                rec.cosuniini := i.cosuniini;
                rec.costotini := i.costotini;
                rec.caning := 0;
                rec.cosuniing := 0;
                rec.costoting := 0;
                rec.cansal := 0;
                rec.cosunisal := 0;
                rec.costotsal := 0;
                rec.stockfinal := i.stockfinal;
                rec.cosunifin := i.cosunifin;
                rec.costotfin := i.costotfin;
                -- FIN
                rec.ctatinv := i.ctatinv;
                rec.desctatinv := i.desctatinv;
                rec.codadd01 := i.codadd01;
                rec.codadd02 := i.codadd02;
                rec.dcodadd01 := i.dcodadd01;
                rec.dcodadd02 := i.dcodadd02;
                PIPE ROW ( rec );
            ELSE
            -- SIGNIFICA QUE EXISTE MOVIMIENTO DE ESE ARTICULO
            -- IMPRIMIENDO CABEZERA
                rec.id_cia := i.id_cia;
                rec.tipinv := i.tipinv;
                rec.dtipinv := i.dtipinv;
                rec.codfam := i.codfam;
                rec.desfam := i.desfam;
                rec.codlin := i.codlin;
                rec.deslin := i.deslin;
                rec.codart := i.codart;
                rec.desart := i.desart;
                rec.codunisunat := i.codunisunat;
                IF
                    v_tipinv = i.tipinv
                    AND v_codart = i.codart
                THEN
                -- SEGUNDA LINEA DEL ARTICULO
                    rec.id := i.id;
                    rec.tipope := i.tipope;
                    rec.desmot := i.desmot;
                    rec.abrmot := i.abrmot;
                    rec.numint := i.numint;
                    rec.numite := i.numite;
                    rec.tipdoc := i.tipdoc;
                    rec.series := i.series;
                    rec.numdoc := i.numdoc;
                    rec.femisi := i.femisi;
                    rec.codalm := i.codalm;
                    rec.desalm := i.desalm;
                    rec.abralm := i.abralm;
                    rec.desmon := i.desmon;
                    rec.simbolo := i.simbolo;
                    rec.stockini := i.stockini;
                    rec.cosuniini := i.cosuniini;
                    rec.costotini := i.costotini;
                    -- CALCULO | ARTICULO CON MOVIMIENTO
                    IF rec.id = 'I' THEN
                        rec.caning := i.caning;
                        rec.cosuniing := i.cosuniing;
                        rec.costoting := i.costoting;
                        rec.cansal := 0;
                        rec.cosunisal := 0;
                        rec.costotsal := 0;
                        rec.stockfinal := ( v_stockfinal + i.caning );
                        rec.costotfin := ( v_costotfin + i.costoting );
                        CASE
                            WHEN rec.stockfinal = 0 THEN
                                rec.cosunifin := 0;
                            ELSE
                                rec.cosunifin := round(rec.costotfin / rec.stockfinal, 2);
                        END CASE;

                    ELSIF rec.id = 'S' THEN
                        rec.caning := 0;
                        rec.cosuniing := 0;
                        rec.costoting := 0;
                        rec.cansal := i.cansal;
                        rec.cosunisal := i.cosunisal;
                        rec.costotsal := i.costotsal;
                        rec.stockfinal := ( v_stockfinal - i.cansal );
                        rec.costotfin := ( v_costotfin - i.costotsal );
                        CASE
                            WHEN rec.stockfinal = 0 THEN
                                rec.cosunifin := 0;
                            ELSE
                                rec.cosunifin := round(rec.costotfin / rec.stockfinal, 2);
                        END CASE;

                    END IF;
                    -- GUARDANDO VALORES PARA LLEVAR EL ACUMULADO
                    v_stockfinal := rec.stockfinal;
                    v_cosunifin := rec.cosunifin;
                    v_costotfin := rec.costotfin;
                    -- FIN
                    rec.ctatinv := i.ctatinv;
                    rec.desctatinv := i.desctatinv;
                    rec.codadd01 := i.codadd01;
                    rec.codadd02 := i.codadd02;
                    rec.dcodadd01 := i.dcodadd01;
                    rec.dcodadd02 := i.dcodadd02;
                    PIPE ROW ( rec );
                ELSE
                -- PRIMERA LINEA DEL ARTICULO
                -- IMPRIME LOS TOTALES DEL ARTICULO
                -- ASIGNANDO
                    v_tipinv := rec.tipinv;
                    v_codart := rec.codart;
                    v_stockfinal := 0;
                    v_cosunifin := 0;
                    v_costotfin := 0;
                -- IMPRIMIENDO
                    rec.id := 'T';
                    rec.tipope := NULL;
                    rec.desmot := NULL;
                    rec.abrmot := NULL;
                    rec.numint := NULL;
                    rec.numite := NULL;
                    rec.tipdoc := NULL;
                    rec.series := NULL;
                    rec.numdoc := NULL;
                    rec.femisi := NULL;
                    rec.codalm := NULL;
                    rec.desalm := NULL;
                    rec.abralm := NULL;
                    rec.desmon := i.desmon;
                    rec.simbolo := i.simbolo;
                -- NO HAY NINGUN CALCULO / STOCK INICIAL - PRIMERA LINEA DEL REPORTE
                    rec.stockini := i.stockini;
                    rec.cosuniini := i.cosuniini;
                    rec.costotini := i.costotini;
                    rec.caning := 0;
                    rec.cosuniing := 0;
                    rec.costoting := 0;
                    rec.cansal := 0;
                    rec.cosunisal := 0;
                    rec.costotsal := 0;
                    rec.stockfinal := i.stockini;
                    rec.cosunifin := i.cosuniini;
                    rec.costotfin := i.costotini;
                -- FIN
                    rec.ctatinv := i.ctatinv;
                    rec.desctatinv := i.desctatinv;
                    rec.codadd01 := i.codadd01;
                    rec.codadd02 := i.codadd02;
                    rec.dcodadd01 := i.dcodadd01;
                    rec.dcodadd02 := i.dcodadd02;
                    PIPE ROW ( rec );

                -- IMPRIMIENDO EL PRIMER MOVIMIENTO DEL ARTICULO
                    rec.id := i.id;
                    rec.tipope := i.tipope;
                    rec.desmot := i.desmot;
                    rec.abrmot := i.abrmot;
                    rec.numint := i.numint;
                    rec.numite := i.numite;
                    rec.tipdoc := i.tipdoc;
                    rec.series := i.series;
                    rec.numdoc := i.numdoc;
                    rec.femisi := i.femisi;
                    rec.codalm := i.codalm;
                    rec.desalm := i.desalm;
                    rec.abralm := i.abralm;
                    rec.desmon := i.desmon;
                    rec.simbolo := i.simbolo;
                    -- CALCULO | ARTICULO CON MOVIMIENTO
                    IF rec.id = 'I' THEN
                        rec.stockini := i.stockini;
                        rec.cosuniini := i.cosuniini;
                        rec.costotini := i.costotini;
                        rec.caning := i.caning;
                        rec.cosuniing := i.cosuniing;
                        rec.costoting := i.costoting;
                        rec.cansal := 0;
                        rec.cosunisal := 0;
                        rec.costotsal := 0;
                        rec.stockfinal := ( rec.stockini + i.caning );
                        rec.costotfin := ( rec.costotfin + i.costoting );
                        CASE
                            WHEN rec.stockfinal = 0 THEN
                                rec.cosunifin := 0;
                            ELSE
                                rec.cosunifin := round(rec.costotfin / rec.stockfinal, 2);
                        END CASE;

                    ELSIF rec.id = 'S' THEN
                        rec.stockini := i.stockini;
                        rec.cosuniini := i.cosuniini;
                        rec.costotini := i.costotini;
                        rec.caning := 0;
                        rec.cosuniing := 0;
                        rec.costoting := 0;
                        rec.cansal := i.cansal;
                        rec.cosunisal := i.cosunisal;
                        rec.costotsal := i.costotsal;
                        rec.stockfinal := ( rec.stockini - i.cansal );
                        rec.costotfin := ( rec.costotini - i.costotsal );
                        CASE
                            WHEN rec.stockfinal = 0 THEN
                                rec.cosunifin := 0;
                            ELSE
                                rec.cosunifin := round(rec.costotfin / rec.stockfinal, 2);
                        END CASE;

                    END IF;
                    -- GUARDANDO VALORES PARA LLEVAR EL ACUMULADO
                    v_stockfinal := rec.stockfinal;
                    v_cosunifin := rec.cosunifin;
                    v_costotfin := rec.costotfin;
                    -- FIN
                    rec.ctatinv := i.ctatinv;
                    rec.desctatinv := i.desctatinv;
                    rec.codadd01 := i.codadd01;
                    rec.codadd02 := i.codadd02;
                    rec.dcodadd01 := i.dcodadd01;
                    rec.dcodadd02 := i.dcodadd02;
                    PIPE ROW ( rec );
                END IF;

            END IF;

        END LOOP;
        --IMPRIMIENDO ULTIMO ARTICULO
        rec.cansal := 0;
        rec.cosunisal := 0;
        rec.costotsal := 0;
        rec.caning := 0;
        rec.cosuniing := 0;
        rec.costoting := 0;
        rec.id := 'F';
        PIPE ROW ( rec );
    END sp_buscar_test;

    FUNCTION sp_almacen (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER,
        pin_mes     NUMBER,
        pin_tipinv  NUMBER,
        pin_tipmon  VARCHAR2
    ) RETURN datatable_almacen_valorizado
        PIPELINED
    AS

        v_table  datatable_almacen_valorizado;
        v_pdesde NUMBER := pin_periodo * 100;
        v_phasta NUMBER := pin_periodo * 100 + pin_mes;
    BEGIN
        SELECT
            k.id_cia,
            k.tipinv,
            i.dtipinv,
            k.codalm,
            a.descri AS desalm,
            SUM(
                CASE
                    WHEN k.id = 'I' THEN
                        k.cantid
                    ELSE
                        k.cantid * - 1
                END
            )        AS stock,
            SUM(
                CASE
                    WHEN k.id = 'I' THEN
                        k.costot01
                    ELSE
                        k.costot01 * - 1
                END
            )        AS costot01,
            SUM(
                CASE
                    WHEN k.id = 'I' THEN
                        k.costot02
                    ELSE
                        k.costot02 * - 1
                END
            )        AS costot02
        BULK COLLECT
        INTO v_table
        FROM
            kardex       k
            LEFT OUTER JOIN t_inventario i ON i.id_cia = k.id_cia
                                              AND i.tipinv = k.tipinv
            LEFT OUTER JOIN almacen      a ON a.id_cia = k.id_cia
                                         AND a.tipinv = k.tipinv
                                         AND a.codalm = k.codalm
        WHERE
                k.id_cia = pin_id_cia
            AND ( nvl(pin_tipinv, - 1) = - 1
                  OR k.tipinv = pin_tipinv )
            AND ( k.periodo BETWEEN v_pdesde AND v_phasta )
        GROUP BY
            k.id_cia,
            k.tipinv,
            i.dtipinv,
            k.codalm,
            a.descri
        ORDER BY
            k.tipinv,
            i.dtipinv,
            k.codalm;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

    END sp_almacen;

END;

/

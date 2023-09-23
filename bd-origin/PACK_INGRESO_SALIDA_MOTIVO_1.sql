--------------------------------------------------------
--  DDL for Package Body PACK_INGRESO_SALIDA_MOTIVO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_INGRESO_SALIDA_MOTIVO" AS

    FUNCTION sp_buscar_tipo_documento (
        pin_id_cia   NUMBER,
        pin_fdesde   DATE,
        pin_fhasta   DATE,
        pin_tipinv   NUMBER,
        pin_tipdoc   NUMBER,
        pin_codmot   NUMBER,
        pin_codalm   NUMBER,
        pin_costo    NUMBER,
        pin_consigna VARCHAR2,
        pin_id       VARCHAR2
    ) RETURN datatable_tipo_documento
        PIPELINED
    AS
        v_table datatable_tipo_documento;
    BEGIN
        SELECT
            d.series      AS series,
            d.numdoc,
            d.numint      AS numint,
            k.numite,
            d.tipdoc,
            dt.descri     AS dtipdoc,
            k.femisi      AS femisi,
            d.razonc      AS razonc,
            k.tipinv      AS tipinv,
            ti.dtipinv    AS dtipinv,
            k.codart      AS codart,
            a.descri      AS articulo,
            a.codfam,
            ca2.descodigo AS desfam,
            a.codlin,
            ca3.descodigo AS deslin,
            al.descri     AS desalm,
            d.codmot,
            m.desmot      AS motivo,
            k.cantid      AS cantid,
            k.costot01,
            k.costot02,
            dd.nrocarrete,
            dd.lote,
            k001.etiqueta,
            k001.ancho,
            dd.fvenci,
            ca.descri     AS desmarca
        BULK COLLECT
        INTO v_table
        FROM
                 kardex k
            INNER JOIN almacen                                                             al ON al.id_cia = k.id_cia
                                     AND al.tipinv = k.tipinv
                                     AND al.codalm = k.codalm
            INNER JOIN motivos                                                             m ON m.id_cia = k.id_cia
                                    AND m.tipdoc = k.tipdoc
                                    AND m.id = k.id
                                    AND m.codmot = k.codmot
            LEFT OUTER JOIN documentos_cab                                                      d ON d.id_cia = k.id_cia
                                                AND d.numint = k.numint
            LEFT OUTER JOIN documentos_tipo                                                     dt ON dt.id_cia = k.id_cia
                                                  AND dt.tipdoc = d.tipdoc
            LEFT OUTER JOIN t_inventario                                                        ti ON ti.id_cia = k.id_cia
                                               AND ti.tipinv = k.tipinv
            LEFT OUTER JOIN articulos                                                           a ON a.id_cia = k.id_cia
                                           AND a.tipinv = k.tipinv
                                           AND a.codart = k.codart
            LEFT OUTER JOIN TABLE ( sp_select_articulo_clase(k.id_cia, a.tipinv, a.codart, 2) ) ca2 ON 0 = 0
            LEFT OUTER JOIN TABLE ( sp_select_articulo_clase(k.id_cia, a.tipinv, a.codart, 3) ) ca3 ON 0 = 0
            --LEFT OUTER JOIN vista_articulos_familia_linea a ON a.tipinv = k.tipinv
            --                                                   AND a.codart = k.codart
            LEFT OUTER JOIN documentos_det                                                      dd ON dd.id_cia = k.id_cia
                                                 AND dd.numint = k.numint
                                                 AND dd.numite = k.numite
            LEFT OUTER JOIN kardex001                                                           k001 ON k001.id_cia = k.id_cia
                                              AND k001.tipinv = k.tipinv
                                              AND k001.codart = k.codart
                                              AND k001.codalm = k.codalm
                                              AND k001.etiqueta = dd.etiqueta
            LEFT OUTER JOIN articulos                                                           ar ON ar.id_cia = k.id_cia
                                            AND ar.tipinv = dd.tipinv
                                            AND ar.codart = dd.codart
            LEFT OUTER JOIN cliente_articulos_clase                                             ca ON ca.id_cia = k.id_cia
                                                          AND ca.tipcli = 'B'
                                                          AND ca.codcli = ar.codprv
                                                          AND ca.clase = 1
                                                          AND ca.codigo = dd.codadd01
        WHERE
                k.id_cia = pin_id_cia
            AND ( k.tipinv = pin_tipinv
                  OR pin_tipinv = - 1 )
            AND ( k.tipdoc = pin_tipdoc
                  OR pin_tipdoc = - 1 )
            AND ( k.codalm = pin_codalm
                  OR pin_codalm = - 1 )
            AND ( k.codmot = pin_codmot
                  OR pin_codmot = - 1 )
            AND ( pin_id IS NULL
                  OR k.id = pin_id )
            AND ( ( pin_costo = - 1
                    OR pin_costo = 2 )
                  OR ( nvl(k.costot01, 0) <= 0
                       AND pin_costo = 1 ) )
            AND ( ( pin_costo = - 1
                    OR pin_costo = 1 )
                  OR ( nvl(k.costot02, 0) > 0
                       AND pin_costo = 2 ) )
            AND ( pin_consigna = 'N'
                  OR al.consigna = pin_consigna )
            AND k.femisi BETWEEN pin_fdesde AND pin_fhasta
        ORDER BY
            d.tipdoc,
            m.codmot,
            d.femisi,
            d.series,
            d.numdoc,
            dd.numite;
--            m.desmot,
--            a.tipinv,
--            a.codfam,
--            a.codlin,
--            a.codart;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar_tipo_documento;

    FUNCTION sp_buscar_resumen (
        pin_id_cia NUMBER,
        pin_pdesde NUMBER,
        pin_phasta NUMBER,
        pin_codalm NUMBER,
        pin_tipinv NUMBER
    ) RETURN datatable_resumen
        PIPELINED
    AS
        v_table datatable_resumen;
    BEGIN
        SELECT
            (
                CASE
                    WHEN mk.valor = 'S' THEN
                        'B'
                    ELSE
                        'A'
                END
            )               AS ocultokardex,
            k.id,
            m.codmot,
            m.desmot,
            dt.abrevi       AS desdoc,
            dt.descri
            || '-'
            || m.codmot
            || '-'
            || m.desmot     AS desdocmot,
            SUM(k.cantid)   AS totcan,
            SUM(k.costot01) AS totsol,
            SUM(k.costot02) AS totdol
        BULK COLLECT
        INTO v_table
        FROM
            kardex          k
            LEFT OUTER JOIN motivos         m ON m.id_cia = k.id_cia
                                         AND ( m.id = k.id )
                                         AND ( m.tipdoc = k.tipdoc )
                                         AND ( m.codmot = k.codmot )
            LEFT OUTER JOIN motivos_clase   mk ON mk.id_cia = k.id_cia
                                                AND mk.tipdoc = k.tipdoc
                                                AND mk.id = k.id
                                                AND mk.codmot = k.codmot
                                                AND mk.codigo = 46 /*OCULTO EN KARDEX VALORIZADO Y PLE*/
            LEFT OUTER JOIN documentos_tipo dt ON dt.id_cia = k.id_cia
                                                  AND dt.tipdoc = k.tipdoc
        WHERE
                k.id_cia = pin_id_cia
            AND ( pin_codalm IS NULL
                  OR pin_codalm = - 1
                  OR k.codalm = pin_codalm )
            AND ( pin_tipinv IS NULL
                  OR pin_tipinv = - 1
                  OR k.tipinv = pin_tipinv )
            AND k.periodo BETWEEN pin_pdesde AND pin_phasta
        GROUP BY
            mk.valor,
            k.id,
            dt.abrevi,
            m.codmot,
            m.desmot,
            dt.descri
        ORDER BY
            1,
            k.id,
            dt.abrevi,
            m.codmot,
            m.desmot;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar_resumen;

    FUNCTION sp_buscar_documento (
        pin_id_cia   NUMBER,
        pin_fdesde   DATE,
        pin_fhasta   DATE,
        pin_tipinv   NUMBER,
        pin_tipdoc   NUMBER,
        pin_codmot   NUMBER,
        pin_codalm   NUMBER,
        pin_costo    NUMBER,
        pin_consigna VARCHAR2,
        pin_id       VARCHAR2
    ) RETURN datatable_documento
        PIPELINED
    AS
        v_table datatable_documento;
    BEGIN
        SELECT
            d.series      AS series,
            d.numdoc,
            d.numint      AS numint,
            k.numite,
            k.femisi      AS femisi,
            d.razonc      AS razonc,
            k.tipinv      AS tipinv,
            ti.dtipinv    AS dtipinv,
            k.codart      AS codart,
            a.descri      AS articulo,
            a.codfam,
            ca2.descodigo AS desfam,
            a.codlin,
            ca3.descodigo AS deslin,
            al.descri     AS desalm,
            k.codmot      AS codmot,
            m.desmot      AS motivo,
            k.cantid      AS cantid,
            k.costot01,
            k.costot02,
            c.tdocum      AS ctdocum,
            c.nserie      AS cserie,
            c.numero      AS cnumero,
            c.femisi      AS cfemisi,
            t.abrevi      AS cabrevi,
            dd.nrocarrete,
            dd.lote,
            k001.etiqueta,
            k001.ancho,
            dd.fvenci,
            ca.descri     AS desmarca
        BULK COLLECT
        INTO v_table
        FROM
                 kardex k
            INNER JOIN almacen                                                             al ON al.id_cia = k.id_cia
                                     AND al.tipinv = k.tipinv
                                     AND al.codalm = k.codalm  --+ StrConsigna 
            INNER JOIN motivos                                                             m ON m.id_cia = k.id_cia
                                    AND m.tipdoc = k.tipdoc
                                    AND m.id = k.id
                                    AND m.codmot = k.codmot
            LEFT OUTER JOIN documentos_cab                                                      d ON d.id_cia = k.id_cia
                                                AND d.numint = k.numint
            LEFT OUTER JOIN t_inventario                                                        ti ON ti.id_cia = k.id_cia
                                               AND ti.tipinv = k.tipinv  
        --LEFT OUTER JOIN VISTA_ARTICULOS_FAMILIA_LINEA  A  ON  A.TIPINV=K.TIPINV AND A.CODART=K.CODART  
            LEFT OUTER JOIN documentos_det                                                      dd ON dd.id_cia = k.id_cia
                                                 AND dd.numint = k.numint
                                                 AND dd.numite = k.numite
            LEFT OUTER JOIN articulos                                                           a ON a.id_cia = k.id_cia
                                           AND a.tipinv = dd.tipinv
                                           AND a.codart = dd.codart
            LEFT OUTER JOIN kardex001                                                           k001 ON k001.id_cia = k.id_cia
                                              AND k001.tipinv = k.tipinv
                                              AND k001.codart = k.codart
                                              AND k001.codalm = k.codalm
                                              AND k001.etiqueta = dd.etiqueta
            LEFT OUTER JOIN TABLE ( sp_select_articulo_clase(k.id_cia, a.tipinv, a.codart, 2) ) ca2 ON 0 = 0
            LEFT OUTER JOIN TABLE ( sp_select_articulo_clase(k.id_cia, a.tipinv, a.codart, 3) ) ca3 ON 0 = 0
            LEFT OUTER JOIN cliente_articulos_clase                                             ca ON ca.id_cia = k.id_cia
                                                          AND ca.tipcli = 'B'
                                                          AND ca.codcli = a.codprv
                                                          AND ca.clase = 1
                                                          AND ca.codigo = dd.codadd01
            LEFT OUTER JOIN compr010guia                                                        g ON g.id_cia = k.id_cia
                                              AND g.numint = d.numint
            LEFT OUTER JOIN compr010                                                            c ON c.id_cia = k.id_cia
                                          AND c.tipo = g.tipo
                                          AND c.docume = g.docume
            LEFT OUTER JOIN tdocume                                                             t ON t.id_cia = k.id_cia
                                         AND t.codigo = c.tdocum
        WHERE
                k.id_cia = pin_id_cia--
            AND ( c.situac IS NULL
                  OR c.situac < 8 )
            AND ( k.tipinv = pin_tipinv
                  OR pin_tipinv = - 1 )--
            AND ( k.tipdoc = pin_tipdoc
                  OR pin_tipdoc = - 1 )
            AND ( k.codalm = pin_codalm
                  OR pin_codalm = - 1 )--
            AND ( k.codmot = pin_codmot
                  OR pin_codmot = - 1 )
            AND ( pin_id IS NULL
                  OR k.id = pin_id )--
            AND ( ( pin_costo = - 1
                    OR pin_costo = 2 )
                  OR ( nvl(k.costot01, 0) <= 0
                       AND pin_costo = 1 ) )
            AND ( ( pin_costo = - 1
                    OR pin_costo = 1 )
                  OR ( nvl(k.costot02, 0) > 0
                       AND pin_costo = 2 ) )
            AND ( pin_consigna = 'N'
                  OR al.consigna = pin_consigna )
            AND k.femisi BETWEEN pin_fdesde AND pin_fhasta--
        ORDER BY
            d.tipdoc,
            m.codmot,
            d.femisi,
            d.series,
            d.numdoc,
            dd.numite;
--            m.desmot,
--            d.numint,
--            k.numite;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar_documento;

    FUNCTION sp_buscar_articulo (
        pin_id_cia   NUMBER,--
        pin_fdesde   DATE,--
        pin_fhasta   DATE,--
        pin_tipinv   NUMBER,--
        pin_tipdoc   NUMBER,--
        pin_codmot   NUMBER,--
        pin_codalm   NUMBER,--
        pin_costo    NUMBER,
        pin_consigna VARCHAR2,--
        pin_id       VARCHAR2--
    ) RETURN datatable_articulo
        PIPELINED
    AS
        v_table datatable_articulo;
    BEGIN
        SELECT
            k.tipinv      AS tipinv,
            ti.dtipinv    AS dtipinv,
            k.codart      AS codart,
            a.descri      AS articulo,
            a.codfam,
            ca2.descodigo AS desfam,
            a.codlin,
            ca3.descodigo AS deslin,
            al.descri     AS desalm,
            k.codmot      AS codmot,
            m.desmot      AS motivo,
            k.cantid,
            k.costot01,
            k.costot02,
            dd.nrocarrete,
            dd.lote,
            k001.etiqueta,
            k001.ancho,
            dd.fvenci,
            ca.descri     AS desmarca
        BULK COLLECT
        INTO v_table
        FROM
                 kardex k
            INNER JOIN almacen                                                             al ON al.id_cia = k.id_cia
                                     AND al.tipinv = k.tipinv
                                     AND al.codalm = k.codalm  --+ StrConsigna
            INNER JOIN motivos                                                             m ON m.id_cia = k.id_cia
                                    AND m.tipdoc = k.tipdoc
                                    AND m.id = k.id
                                    AND m.codmot = k.codmot
            LEFT OUTER JOIN documentos_cab                                                      d ON d.id_cia = k.id_cia
                                                AND d.numint = k.numint
            LEFT OUTER JOIN t_inventario                                                        ti ON ti.id_cia = k.id_cia
                                               AND ti.tipinv = k.tipinv
            LEFT OUTER JOIN articulos                                                           a ON a.id_cia = k.id_cia
                                           AND a.id_cia = k.id_cia
                                           AND a.tipinv = k.tipinv
                                           AND a.codart = k.codart
            LEFT OUTER JOIN TABLE ( sp_select_articulo_clase(k.id_cia, a.tipinv, a.codart, 2) ) ca2 ON 0 = 0
            LEFT OUTER JOIN TABLE ( sp_select_articulo_clase(k.id_cia, a.tipinv, a.codart, 3) ) ca3 ON 0 = 0
     --LEFT OUTER JOIN VISTA_ARTICULOS_FAMILIA_LINEA  A  ON  A.TIPINV=K.TIPINV AND  
     --                                          A.CODART=K.CODART 
            LEFT OUTER JOIN documentos_det                                                      dd ON dd.id_cia = k.id_cia
                                                 AND dd.numint = k.numint
                                                 AND dd.numite = k.numite
            LEFT OUTER JOIN articulos                                                           ar ON ar.id_cia = k.id_cia
                                            AND ar.tipinv = dd.tipinv
                                            AND ar.codart = dd.codart
            LEFT OUTER JOIN cliente_articulos_clase                                             ca ON ca.id_cia = k.id_cia
                                                          AND ca.tipcli = 'B'
                                                          AND ca.codcli = ar.codprv
                                                          AND ca.clase = 1
                                                          AND ca.codigo = dd.codadd01
            LEFT OUTER JOIN kardex001                                                           k001 ON k001.id_cia = k.id_cia
                                              AND k001.tipinv = k.tipinv
                                              AND k001.codart = k.codart
                                              AND k001.codalm = k.codalm
                                              AND k001.etiqueta = dd.etiqueta
        WHERE
                k.id_cia = pin_id_cia--
            AND ( k.tipinv = pin_tipinv
                  OR pin_tipinv = - 1 )--
            AND ( k.tipdoc = pin_tipdoc
                  OR pin_tipdoc = - 1 )--
            AND ( k.codalm = pin_codalm
                  OR pin_codalm = - 1 )--
            AND ( k.codmot = pin_codmot
                  OR pin_codmot = - 1 )--
            AND ( pin_id IS NULL
                  OR k.id = pin_id )--
            AND ( ( pin_costo = - 1
                    OR pin_costo = 2 )
                  OR ( nvl(k.costot01, 0) <= 0
                       AND pin_costo = 1 ) )--
            AND ( ( pin_costo = - 1
                    OR pin_costo = 1 )
                  OR ( nvl(k.costot02, 0) > 0
                       AND pin_costo = 2 ) )--
            AND ( pin_consigna = 'N'
                  OR al.consigna = pin_consigna )
            AND k.femisi BETWEEN pin_fdesde AND pin_fhasta;
--        GROUP BY
--            k.tipinv,
--            ti.dtipinv,
--            k.codart,
--            a.descri,
--            a.codfam,
--            ca2.descodigo,
--            a.codlin,
--            ca3.descodigo,
--            al.descri,
--            m.desmot,
--            k.cantid,
--            k.costot01,
--            k.costot02,
--            k.codmot,
--            dd.nrocarrete,
--            dd.lote,
--            k001.etiqueta,
--            k001.ancho,
--            dd.fvenci,
--            ca.descri;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar_articulo;

    FUNCTION sp_buscar_articulo_resumen (
        pin_id_cia   NUMBER,
        pin_fdesde   DATE,
        pin_fhasta   DATE,
        pin_tipinv   NUMBER,
        pin_tipdoc   NUMBER,
        pin_codmot   NUMBER,
        pin_codalm   NUMBER,
        pin_costo    NUMBER,
        pin_consigna VARCHAR2,
        pin_id       VARCHAR2
    ) RETURN datatable_articulo_resumen
        PIPELINED
    AS
        v_table datatable_articulo_resumen;
    BEGIN
        SELECT
            k.tipinv        AS tipinv,
            ti.dtipinv      AS dtipinv,
            k.codart        AS codart,
            a.descri        AS articulo,
            a.codfam,
            ca2.descodigo   AS desfam,
            a.codlin,
            ca3.descodigo   AS deslin,
            al.descri       AS desalm,
            k.codmot        AS codmot,
            m.desmot        AS motivo,
            SUM(k.cantid)   AS cantid,
            SUM(k.costot01) AS costot01,
            SUM(k.costot02) AS costot02
        BULK COLLECT
        INTO v_table
        FROM
                 kardex k
            INNER JOIN almacen                                                             al ON al.id_cia = k.id_cia
                                     AND al.tipinv = k.tipinv
                                     AND al.codalm = k.codalm  --+ StrConsigna
            INNER JOIN motivos                                                             m ON m.id_cia = k.id_cia
                                    AND m.tipdoc = k.tipdoc
                                    AND m.id = k.id
                                    AND m.codmot = k.codmot
            LEFT OUTER JOIN documentos_cab                                                      d ON d.id_cia = k.id_cia
                                                AND d.numint = k.numint
            LEFT OUTER JOIN t_inventario                                                        ti ON ti.id_cia = k.id_cia
                                               AND ti.tipinv = k.tipinv
            LEFT OUTER JOIN articulos                                                           a ON a.id_cia = k.id_cia
                                           AND a.id_cia = k.id_cia
                                           AND a.tipinv = k.tipinv
                                           AND a.codart = k.codart
            LEFT OUTER JOIN TABLE ( sp_select_articulo_clase(k.id_cia, a.tipinv, a.codart, 2) ) ca2 ON 0 = 0
            LEFT OUTER JOIN TABLE ( sp_select_articulo_clase(k.id_cia, a.tipinv, a.codart, 3) ) ca3 ON 0 = 0
     --LEFT OUTER JOIN VISTA_ARTICULOS_FAMILIA_LINEA  A  ON  A.TIPINV=K.TIPINV AND  
     --                                          A.CODART=K.CODART 
            LEFT OUTER JOIN documentos_det                                                      dd ON dd.id_cia = k.id_cia
                                                 AND dd.numint = k.numint
                                                 AND dd.numite = k.numite
            LEFT OUTER JOIN articulos                                                           ar ON ar.id_cia = k.id_cia
                                            AND ar.tipinv = dd.tipinv
                                            AND ar.codart = dd.codart
            LEFT OUTER JOIN cliente_articulos_clase                                             ca ON ca.id_cia = k.id_cia
                                                          AND ca.tipcli = 'B'
                                                          AND ca.codcli = ar.codprv
                                                          AND ca.clase = 1
                                                          AND ca.codigo = dd.codadd01
        WHERE
                k.id_cia = pin_id_cia
            AND ( k.tipinv = pin_tipinv
                  OR pin_tipinv = - 1 )
            AND ( k.tipdoc = pin_tipdoc
                  OR pin_tipdoc = - 1 )
            AND ( k.codalm = pin_codalm
                  OR pin_codalm = - 1 )
            AND ( k.codmot = pin_codmot
                  OR pin_codmot = - 1 )
            AND ( pin_id IS NULL
                  OR k.id = pin_id )
            AND ( ( pin_costo = - 1
                    OR pin_costo = 2 )
                  OR ( nvl(k.costot01, 0) <= 0
                       AND pin_costo = 1 ) )
            AND ( ( pin_costo = - 1
                    OR pin_costo = 1 )
                  OR ( nvl(k.costot02, 0) > 0
                       AND pin_costo = 2 ) )
            AND ( pin_consigna = 'N'
                  OR al.consigna = pin_consigna )
            AND k.femisi BETWEEN pin_fdesde AND pin_fhasta
        GROUP BY
            k.tipinv,
            ti.dtipinv,
            k.codart,
            a.descri,
            a.codfam,
            ca2.descodigo,
            a.codlin,
            ca3.descodigo,
            al.descri,
            k.codmot,
            m.desmot;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar_articulo_resumen;

    FUNCTION sp_buscar_familialinea (
        pin_id_cia   NUMBER,
        pin_fdesde   DATE,
        pin_fhasta   DATE,
        pin_tipinv   NUMBER,
        pin_tipdoc   NUMBER,
        pin_codmot   NUMBER,
        pin_codalm   NUMBER,
        pin_costo    NUMBER,
        pin_consigna VARCHAR2,
        pin_id       VARCHAR2
    ) RETURN datatable_familialinea
        PIPELINED
    AS
        v_table datatable_familialinea;
    BEGIN
        SELECT
            d.series      AS series,
            d.numdoc,
            d.numint      AS numint,
            k.numite,
            k.femisi      AS femisi,
            d.razonc      AS razonc,
            k.tipinv      AS tipinv,
            ti.dtipinv    AS dtipinv,
            k.codart      AS codart,
            a.descri      AS articulo,
            a.codfam,
            ca2.descodigo AS desfam,
            a.codlin,
            ca3.descodigo AS deslin,
            al.descri     AS desalm,
            k.codmot      AS codmot,
            m.desmot      AS motivo,
            k.cantid      AS cantid,
            k.costot01,
            k.costot02,
            c.tdocum      AS ctdocum,
            c.nserie      AS cserie,
            c.numero      AS cnumero,
            c.femisi      AS cfemisi,
            t.abrevi      AS cabrevi,
            dd.nrocarrete,
            dd.lote,
            k001.etiqueta,
            k001.ancho,
            dd.fvenci,
            ca.descri     AS desmarca --+
        BULK COLLECT
        INTO v_table
        FROM
                 kardex k
            INNER JOIN almacen                                                             al ON al.id_cia = k.id_cia
                                     AND al.tipinv = k.tipinv
                                     AND al.codalm = k.codalm --+ strconsigna
            INNER JOIN motivos                                                             m ON m.id_cia = k.id_cia
                                    AND m.tipdoc = k.tipdoc
                                    AND m.id = k.id
                                    AND m.codmot = k.codmot
            LEFT OUTER JOIN documentos_cab                                                      d ON d.id_cia = k.id_cia
                                                AND d.numint = k.numint
            LEFT OUTER JOIN t_inventario                                                        ti ON ti.id_cia = k.id_cia
                                               AND ti.tipinv = k.tipinv
            --LEFT OUTER JOIN vista_articulos_familia_linea a ON a.id_Cia = K.id_cia AND a.tipinv = k.tipinv
              --                                                 AND a.codart = k.codart
            LEFT OUTER JOIN documentos_det                                                      dd ON dd.id_cia = k.id_cia
                                                 AND dd.numint = k.numint
                                                 AND dd.numite = k.numite  --+
            LEFT OUTER JOIN articulos                                                           a ON a.id_cia = k.id_cia
                                           AND a.tipinv = dd.tipinv
                                           AND a.codart = dd.codart
            LEFT OUTER JOIN TABLE ( sp_select_articulo_clase(k.id_cia, a.tipinv, a.codart, 2) ) ca2 ON 0 = 0
            LEFT OUTER JOIN TABLE ( sp_select_articulo_clase(k.id_cia, a.tipinv, a.codart, 3) ) ca3 ON 0 = 0
            LEFT OUTER JOIN cliente_articulos_clase                                             ca ON ca.id_cia = k.id_cia
                                                          AND ca.tipcli = 'B'
                                                          AND ca.codcli = a.codprv
                                                          AND ca.clase = 1
                                                          AND ca.codigo = dd.codadd01
            LEFT OUTER JOIN compr010guia                                                        g ON g.id_cia = k.id_cia
                                              AND g.numint = d.numint
            LEFT OUTER JOIN compr010                                                            c ON c.id_cia = k.id_cia
                                          AND c.tipo = g.tipo
                                          AND c.docume = g.docume
            LEFT OUTER JOIN tdocume                                                             t ON t.id_cia = k.id_cia
                                         AND t.codigo = c.tdocum
            LEFT OUTER JOIN kardex001                                                           k001 ON k001.id_cia = k.id_cia
                                              AND k001.tipinv = k.tipinv
                                              AND k001.codart = k.codart
                                              AND k001.codalm = k.codalm
                                              AND k001.etiqueta = dd.etiqueta
        WHERE
                k.id_cia = pin_id_cia
            AND ( k.tipinv = pin_tipinv
                  OR pin_tipinv = - 1 )
            AND ( k.tipdoc = pin_tipdoc
                  OR pin_tipdoc = - 1 )
            AND ( k.codalm = pin_codalm
                  OR pin_codalm = - 1 )
            AND ( k.codmot = pin_codmot
                  OR pin_codmot = - 1 )
            AND ( pin_id IS NULL
                  OR k.id = pin_id )
            AND ( ( pin_costo = - 1
                    OR pin_costo = 2 )
                  OR ( nvl(k.costot01, 0) <= 0
                       AND pin_costo = 1 ) )
            AND ( ( pin_costo = - 1
                    OR pin_costo = 1 )
                  OR ( nvl(k.costot02, 0) > 0
                       AND pin_costo = 2 ) )
            AND ( pin_consigna = 'N'
                  OR al.consigna = pin_consigna )
            AND k.femisi BETWEEN pin_fdesde AND pin_fhasta
        ORDER BY
            m.desmot,
            c.tdocum,
            c.nserie,
            c.numero;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar_familialinea;

    FUNCTION sp_buscar_almacen (
        pin_id_cia   NUMBER,
        pin_fdesde   DATE,
        pin_fhasta   DATE,
        pin_tipinv   NUMBER,
        pin_tipdoc   NUMBER,
        pin_codmot   NUMBER,
        pin_codalm   NUMBER,
        pin_costo    NUMBER,
        pin_consigna VARCHAR2,
        pin_id       VARCHAR2
    ) RETURN datatable_almacen
        PIPELINED
    AS
        v_table datatable_almacen;
    BEGIN
        SELECT
            d.series      AS series,
            d.numdoc,
            d.numint      AS numint,
            k.numite,
            k.femisi      AS femisi,
            d.razonc      AS razonc,
            k.tipinv      AS tipinv,
            ti.dtipinv    AS dtipinv,
            k.codart      AS codart,
            k.codalm,
            a.descri      AS articulo,
            a.codfam,
            ca2.descodigo AS desfam,
            a.codlin,
            ca3.descodigo AS deslin,
            al.descri     AS desalm,
            k.codmot      AS codmot,
            m.desmot      AS motivo,
            k.cantid      AS cantid,
            k.costot01,
            k.costot02,
            dd.nrocarrete,
            dd.lote,
            k001.etiqueta,
            k001.ancho,
            dd.fvenci,
            ca.descri     AS desmarca
        BULK COLLECT
        INTO v_table
        FROM
                 kardex k
            INNER JOIN almacen                                                             al ON al.id_cia = k.id_cia
                                     AND al.tipinv = k.tipinv
                                     AND al.codalm = k.codalm
            INNER JOIN motivos                                                             m ON m.id_cia = k.id_cia
                                    AND m.tipdoc = k.tipdoc
                                    AND m.id = k.id
                                    AND m.codmot = k.codmot
            LEFT OUTER JOIN documentos_cab                                                      d ON d.id_cia = k.id_cia
                                                AND d.numint = k.numint
            LEFT OUTER JOIN t_inventario                                                        ti ON ti.id_cia = k.id_cia
                                               AND ti.tipinv = k.tipinv
            /*LEFT OUTER JOIN vista_articulos_familia_linea a ON a.tipinv = k.tipinv
                                                               AND a.codart = k.codart*/
            LEFT OUTER JOIN documentos_det                                                      dd ON dd.id_cia = k.id_cia
                                                 AND dd.numint = k.numint
                                                 AND dd.numite = k.numite
            LEFT OUTER JOIN articulos                                                           a ON a.id_cia = k.id_cia
                                           AND a.tipinv = dd.tipinv
                                           AND a.codart = dd.codart
            LEFT OUTER JOIN TABLE ( sp_select_articulo_clase(k.id_cia, a.tipinv, a.codart, 2) ) ca2 ON 0 = 0
            LEFT OUTER JOIN TABLE ( sp_select_articulo_clase(k.id_cia, a.tipinv, a.codart, 3) ) ca3 ON 0 = 0
            LEFT OUTER JOIN cliente_articulos_clase                                             ca ON ca.id_cia = k.id_cia
                                                          AND ca.tipcli = 'B'
                                                          AND ca.codcli = a.codprv
                                                          AND ca.clase = 1
                                                          AND ca.codigo = dd.codadd01
            LEFT OUTER JOIN kardex001                                                           k001 ON k001.id_cia = k.id_cia
                                              AND k001.tipinv = k.tipinv
                                              AND k001.codart = k.codart
                                              AND k001.codalm = k.codalm
                                              AND k001.etiqueta = dd.etiqueta
        WHERE
                k.id_cia = pin_id_cia--
            AND ( k.tipinv = pin_tipinv
                  OR pin_tipinv = - 1 )--
            AND ( k.tipdoc = pin_tipdoc
                  OR pin_tipdoc = - 1 )--
            AND ( k.codalm = pin_codalm
                  OR pin_codalm = - 1 )--
            AND ( k.codmot = pin_codmot
                  OR pin_codmot = - 1 )--
            AND ( pin_id IS NULL
                  OR k.id = pin_id )--
            AND ( ( pin_costo = - 1
                    OR pin_costo = 2 )
                  OR ( nvl(k.costot01, 0) <= 0
                       AND pin_costo = 1 ) )
            AND ( ( pin_costo = - 1
                    OR pin_costo = 1 )
                  OR ( nvl(k.costot02, 0) > 0
                       AND pin_costo = 2 ) )
            AND ( pin_consigna = 'N'
                  OR al.consigna = pin_consigna )
            AND k.femisi BETWEEN pin_fdesde AND pin_fhasta--
        ORDER BY
            k.codalm,
            k.femisi,
            d.series,
            d.numdoc,
            k.numite;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar_almacen;

END;

/

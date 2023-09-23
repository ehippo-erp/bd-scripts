--------------------------------------------------------
--  DDL for Package Body PACK_CUBO_COMPRAS
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_CUBO_COMPRAS" IS

    FUNCTION sp_cubocompras001 (
        pin_id_cia NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_cubo_compras1
        PIPELINED
    AS
        v_table datatable_cubo_compras1;
    BEGIN
        SELECT
            ddc.descri                                                                        AS documento,
            s.sucursal                                                                        AS sucursal,
            to_char(dc.femisi, 'DAY')                                                         AS diasemana,
            ms.desmay                                                                         AS mes,
            to_number(to_char(dc.femisi, 'YYYY'))                                             AS periodo,
            to_number(to_char(dc.femisi, 'YYYY')) * 100 + to_number(to_char(dc.femisi, 'MM')) AS mesid,
            dc.series                                                                         AS serie,
            dc.numdoc                                                                         AS nro_documento,
            dc.femisi                                             AS fecha_emision,
            dc.tipcam                                                                         AS tipo_cambio,
            dc.codcli                                                                         AS codigo_cliente,
            c902c.descodigo                                                                   AS clasificacion_cliente,
            c900c.descodigo                                                                   AS tipo_cliente,
            dc.razonc                                                                         AS proveedor,--cliente
            dc.ruc                                                                            AS ruc,
            cp.despag                                                                         AS forma_pago,
            mt.desmot                                                                         AS motivo,
            ve.desven                                                                         AS atendido_por,--vendedor
            dc.tipmon                                                                         AS moneda,
            dd.tipinv                                                                         AS tipo_inventario,
            ca3.descodigo                                                                     AS linea_negocio,
            ca2.descodigo                                                                     AS familia_producto,
            ca5.descodigo                                                                     AS tipo_producto,
            ca11.descodigo                                                                    AS clasificacion_producto,
            dd.codart                                                                         AS codigo,
            a.descri                                                                          AS descripcion,
            dd.etiqueta                                                                       AS etiqueta,
            dd.ancho                                                                          AS dioptria,
            dd.lote                                                                           AS lote,
            dd.nrocarrete                                                                     AS serie_articulo,
            to_char(dd.fvenci, 'DD/MM/YYYY')                                                  AS fecha_vencimiento,
            dd.cantid                                                                         AS cantidad,
            dd.preuni                                                                         AS precio_unitario,
            dd.importe                                                                        AS importe,
            coalesce(c1c.descodigo, 'ND - DEPARTAMENTO')                                      AS departamento,
            coalesce(c2c.descodigo, 'ND - PROVINCIA')                                         AS provincia,
            coalesce(c3c.descodigo, 'ND - DISTRITO')                                          AS distrito,
            coalesce(c28c.descodigo, 'ND - DISTRITO')                                         AS grupo_economico
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab                                                        dc
            INNER JOIN documentos_det                                                        dd ON dc.id_cia = dd.id_cia -- Sale un Null
                                                 AND dc.numint = dd.numint
            LEFT OUTER JOIN documentos_tipo                                                       ddc ON ( dc.id_cia = ddc.id_cia )
                                                   AND ( ddc.tipdoc = dc.tipdoc )
            LEFT OUTER JOIN sucursal                                                              s ON s.id_cia = dc.id_cia
                                          AND ( s.codsuc = dc.codsuc )
            LEFT OUTER JOIN meses                                                                 ms ON ms.id_cia = dc.id_cia
                                        AND ( ms.nromes = EXTRACT(MONTH FROM dc.femisi) )
            LEFT OUTER JOIN c_pago                                                                cp ON cp.id_cia = dc.id_cia
                                         AND ( cp.codpag = dc.codcpag )
            LEFT OUTER JOIN vendedor                                                              ve ON ve.id_cia = dc.id_cia
                                           AND ( ve.codven = dc.codven )
            LEFT OUTER JOIN articulos                                                             a ON a.id_cia = dd.id_cia
                                           AND ( a.tipinv = dd.tipinv )
                                           AND ( a.codart = dd.codart )
            LEFT OUTER JOIN cliente_articulos_clase                                               cl1 ON cl1.id_cia = dd.id_cia
                                                           AND cl1.tipcli = 'B'
                                                           AND cl1.codcli = a.codprv
                                                           AND cl1.clase = 1
                                                           AND cl1.codigo = dd.codadd01
            LEFT OUTER JOIN cliente_articulos_clase                                               cl2 ON cl2.id_cia = dd.id_cia
                                                           AND cl2.tipcli = 'B'
                                                           AND cl2.codcli = a.codprv
                                                           AND cl2.clase = 2
                                                           AND cl2.codigo = dd.codadd02
            LEFT OUTER JOIN motivos                                                               mt ON ( mt.id_cia = dc.id_cia )
                                          AND ( mt.tipdoc = dc.tipdoc )
                                          AND ( mt.id = dc.id )
                                          AND ( mt.codmot = dc.codmot )
            LEFT OUTER JOIN kardex001                                                             k001 ON k001.id_cia = dd.id_cia
                                              AND k001.tipinv = dd.tipinv
                                              AND k001.codart = dd.codart
                                              AND k001.codalm = dd.codalm
                                              AND k001.etiqueta = dd.etiqueta
            LEFT OUTER JOIN TABLE ( sp_select_articulo_clase(dc.id_cia, a.tipinv, a.codart, 2) )  ca2 ON 0 = 0
            LEFT OUTER JOIN TABLE ( sp_select_articulo_clase(dc.id_cia, a.tipinv, a.codart, 3) )  ca3 ON 0 = 0
            LEFT OUTER JOIN TABLE ( sp_select_articulo_clase(dc.id_cia, a.tipinv, a.codart, 5) )  ca5 ON 0 = 0
            LEFT OUTER JOIN TABLE ( sp_select_articulo_clase(dc.id_cia, a.tipinv, a.codart, 11) ) ca11 ON 0 = 0
            LEFT OUTER JOIN TABLE ( sp_select_cliente_clase(dc.id_cia, 'A', dc.codcli, 902) )     c902c ON c902c.codigo <> 'ND'
            LEFT OUTER JOIN TABLE ( sp_select_cliente_clase(dc.id_cia, 'A', dc.codcli, 900) )     c900c ON c900c.codigo <> 'ND'
            LEFT OUTER JOIN TABLE ( sp_select_cliente_clase(dc.id_cia, 'A', dc.codcli, 14) )      c1c ON c1c.codigo <> 'ND'
            LEFT OUTER JOIN TABLE ( sp_select_cliente_clase(dc.id_cia, 'A', dc.codcli, 15) )      c2c ON c2c.codigo <> 'ND'
            LEFT OUTER JOIN TABLE ( sp_select_cliente_clase(dc.id_cia, 'A', dc.codcli, 16) )      c3c ON c3c.codigo <> 'ND'
            LEFT OUTER JOIN TABLE ( sp_select_cliente_clase(dc.id_cia, 'A', dc.codcli, 28) )      c28c ON c28c.codigo <> 'ND'
        WHERE
                dc.id_cia = pin_id_cia
           -- AND dc.situac = 'F' --  CUENTA, CORRIENTE
            AND dc.tipdoc IN ( 105, 127 )
            AND dc.situac IN ('G','H')
            AND dc.femisi BETWEEN pin_fdesde AND pin_fhasta;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_cubocompras001;

        FUNCTION sp_cubocompras002 (
        pin_id_cia NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_cubo_compras2
        PIPELINED
    AS
        v_table datatable_cubo_compras2;
    BEGIN
        SELECT
            ddc.descri                                                                        AS documento,
            s.sucursal                                                                        AS sucursal,
            to_char(dc.femisi, 'DAY')                                                         AS diasemana,
            ms.desmay                                                                         AS mes,
            to_number(to_char(dc.femisi, 'YYYY'))                                             AS periodo,
            to_number(to_char(dc.femisi, 'YYYY')) * 100 + to_number(to_char(dc.femisi, 'MM')) AS mesid,
            dc.series                                                                         AS serie,
            dc.numdoc                                                                         AS nro_documento,
            dc.femisi                                                                         AS fecha_emision,
            dc.tipcam                                                                         AS tipo_cambio,
            dc.codcli                                                                         AS codigo_cliente,
            c902c.descodigo                                                                   AS clasificacion_cliente,
            c900c.descodigo                                                                   AS tipo_cliente,
            dc.razonc                                                                         AS proveedor,--cliente
            dc.ruc                                                                            AS ruc,
            cp.despag                                                                         AS forma_pago,
            mt.desmot                                                                         AS motivo,
            ve.desven                                                                         AS atendido_por,--vendedor
            dc.tipmon                                                                         AS moneda,
            dd.tipinv                                                                         AS tipo_inventario,
            ca3.descodigo                                                                     AS linea_negocio,
            ca2.descodigo                                                                     AS familia_producto,
            ca5.descodigo                                                                     AS tipo_producto,
            ca11.descodigo                                                                    AS clasificacion_producto,
            dd.codart                                                                         AS codigo,
            a.descri                                                                          AS descripcion,
            dd.etiqueta                                                                       AS etiqueta,
            dd.ancho                                                                          AS dioptria,
            dd.lote                                                                           AS lote,
            dd.nrocarrete                                                                     AS serie_articulo,
            to_char(dd.fvenci, 'DD/MM/YYYY')                                                  AS fecha_vencimiento,
            dd.cantid                                                                         AS cantidad,
            dd.preuni                                                                         AS precio_unitario,
            dd.importe                                                                        AS importe,
            k.cosunisol,
            k.cosunidol,
            coalesce(c1c.descodigo, 'ND - DEPARTAMENTO')                                      AS departamento,
            coalesce(c2c.descodigo, 'ND - PROVINCIA')                                         AS provincia,
            coalesce(c3c.descodigo, 'ND - DISTRITO')                                          AS distrito,
            coalesce(c28c.descodigo, 'ND - DISTRITO')                                         AS grupo_economico
        BULK COLLECT
        INTO v_table
        FROM
                 documentos_cab dc
            INNER JOIN documentos_det                                                        dd ON dc.id_cia = dd.id_cia -- Sale un Null
                                            AND dc.numint = dd.numint
            LEFT OUTER JOIN documentos_tipo                                                       ddc ON ( dc.id_cia = ddc.id_cia )
                                                   AND ( ddc.tipdoc = dc.tipdoc )
            LEFT OUTER JOIN sucursal                                                              s ON s.id_cia = dc.id_cia
                                          AND ( s.codsuc = dc.codsuc )
            LEFT OUTER JOIN meses                                                                 ms ON ms.id_cia = dc.id_cia
                                        AND ( ms.nromes = EXTRACT(MONTH FROM dc.femisi) )
            LEFT OUTER JOIN c_pago                                                                cp ON cp.id_cia = dc.id_cia
                                         AND ( cp.codpag = dc.codcpag )
            LEFT OUTER JOIN vendedor                                                              ve ON ve.id_cia = dc.id_cia
                                           AND ( ve.codven = dc.codven )
            LEFT OUTER JOIN articulos                                                             a ON a.id_cia = dd.id_cia
                                           AND ( a.tipinv = dd.tipinv )
                                           AND ( a.codart = dd.codart )
            LEFT OUTER JOIN cliente_articulos_clase                                               cl1 ON cl1.id_cia = dd.id_cia
                                                           AND cl1.tipcli = 'B'
                                                           AND cl1.codcli = a.codprv
                                                           AND cl1.clase = 1
                                                           AND cl1.codigo = dd.codadd01
            LEFT OUTER JOIN cliente_articulos_clase                                               cl2 ON cl2.id_cia = dd.id_cia
                                                           AND cl2.tipcli = 'B'
                                                           AND cl2.codcli = a.codprv
                                                           AND cl2.clase = 2
                                                           AND cl2.codigo = dd.codadd02
            LEFT OUTER JOIN motivos                                                               mt ON ( mt.id_cia = dc.id_cia )
                                          AND ( mt.tipdoc = dc.tipdoc )
                                          AND ( mt.id = dc.id )
                                          AND ( mt.codmot = dc.codmot )
            LEFT OUTER JOIN kardex001                                                             k001 ON k001.id_cia = dd.id_cia
                                              AND k001.tipinv = dd.tipinv
                                              AND k001.codart = dd.codart
                                              AND k001.codalm = dd.codalm
                                              AND k001.etiqueta = dd.etiqueta
            LEFT OUTER JOIN TABLE ( sp_select_articulo_clase(dc.id_cia, a.tipinv, a.codart, 2) )  ca2 ON 0 = 0
            LEFT OUTER JOIN TABLE ( sp_select_articulo_clase(dc.id_cia, a.tipinv, a.codart, 3) )  ca3 ON 0 = 0
            LEFT OUTER JOIN TABLE ( sp_select_articulo_clase(dc.id_cia, a.tipinv, a.codart, 5) )  ca5 ON 0 = 0
            LEFT OUTER JOIN TABLE ( sp_select_articulo_clase(dc.id_cia, a.tipinv, a.codart, 11) ) ca11 ON 0 = 0
            LEFT OUTER JOIN TABLE ( sp_select_cliente_clase(dc.id_cia, 'A', dc.codcli, 902) )     c902c ON c902c.codigo <> 'ND'
            LEFT OUTER JOIN TABLE ( sp_select_cliente_clase(dc.id_cia, 'A', dc.codcli, 900) )     c900c ON c900c.codigo <> 'ND'
            LEFT OUTER JOIN TABLE ( sp_select_cliente_clase(dc.id_cia, 'A', dc.codcli, 14) )      c1c ON c1c.codigo <> 'ND'
            LEFT OUTER JOIN TABLE ( sp_select_cliente_clase(dc.id_cia, 'A', dc.codcli, 15) )      c2c ON c2c.codigo <> 'ND'
            LEFT OUTER JOIN TABLE ( sp_select_cliente_clase(dc.id_cia, 'A', dc.codcli, 16) )      c3c ON c3c.codigo <> 'ND'
            LEFT OUTER JOIN TABLE ( sp_select_cliente_clase(dc.id_cia, 'A', dc.codcli, 28) )      c28c ON c28c.codigo <> 'ND'
            LEFT OUTER JOIN pack_cubo_compras.sp_cosunikardex ( dc.id_cia,dd.numint,dd.numite )                       k ON 0 = 0
        WHERE
                dc.id_cia = pin_id_cia
           -- AND dc.situac = 'F' --  CUENTA, CORRIENTE
            AND dc.tipdoc IN ( 105, 127 )
            AND dc.situac IN ( 'G', 'H' )
            AND dc.femisi BETWEEN pin_fdesde AND pin_fhasta;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_cubocompras002;
    
    FUNCTION sp_cosunikardex (
        pin_id_cia NUMBER,
        pin_numint NUMBER,
        pin_numite NUMBER
    ) RETURN datatable_cosunikardex
        PIPELINED
    AS
        v_table datatable_cosunikardex;
    BEGIN
        SELECT
            k.id_cia,
            d.numint                        AS ocnumint,
            d.numite                        AS opnumite,
            k.numint                        AS knumint,
            k.numite                        AS knumite,
            round(k.costot01 / k.cantid, 2) AS cosunisol,
            round(k.costot02 / k.cantid, 2) AS cosunidol
        BULK COLLECT
        INTO v_table
        FROM
                 documentos_det d
            INNER JOIN documentos_cab c ON c.id_cia = d.id_cia
                                           AND c.numint = d.numint
            INNER JOIN documentos_det di ON di.id_cia = d.id_cia /* DOC IMPORTACION O ORDEN DE COMPRA */
                                            AND di.opnumdoc = d.numint
                                            AND di.opnumite = d.numite
            INNER JOIN documentos_ent e ON e.id_cia = d.id_cia
                                           AND e.opnumdoc = di.numint
                                           AND e.opnumite = di.numite
            INNER JOIN documentos_det dg ON dg.id_cia = e.id_cia /* GUIA INTERNA */
                                            AND dg.numint = e.orinumint
                                            AND dg.numite = e.orinumite
            INNER JOIN kardex         k ON k.id_cia = e.id_cia
                                   AND k.numint = dg.numint
                                   AND k.numite = dg.numite
        WHERE
                d.id_cia = pin_id_cia
            AND c.tipdoc  IN ( 105, 127 )
            AND d.numint = pin_numint
            AND d.numite = pin_numite
            AND ( nvl(k.costot01, 0) > 0
                  AND nvl(k.costot02, 0) > 0 );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_cosunikardex;

END;

/

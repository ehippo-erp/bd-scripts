--------------------------------------------------------
--  DDL for Package Body PACK_RELACION_COSTO_VENTA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_RELACION_COSTO_VENTA" AS

    FUNCTION sp_resumen (
        pin_id_cia NUMBER,
        pin_tipinv NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_detalle
        PIPELINED
    AS
        v_table datatable_detalle;
    BEGIN
        SELECT DISTINCT
            c.id_cia,
            c.numint,
            d.numite,
            d.tipinv,
            d.codart,
            a.descri AS desart,
            d.cantid,
            d.monexo,
            d.monina,
            d.monafe,
            d.codalm,
            c18.codigo,
            c19.codigo
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab  c
            LEFT OUTER JOIN documentos_det  d ON d.id_cia = c.id_cia
                                                AND d.numint = c.numint
            LEFT OUTER JOIN articulos       a ON a.id_cia = c.id_cia
                                           AND a.tipinv = d.tipinv
                                           AND a.codart = d.codart
            LEFT OUTER JOIN motivos_clase   mt60 ON mt60.id_cia = c.id_cia
                                                  AND mt60.tipdoc = c.tipdoc
                                                  AND mt60.codmot = c.codmot
                                                  AND mt60.id = c.id
                                                  AND mt60.codigo = 60 -- NO GENERAN ASIENTO DE VENTA, SI ESTA EN 'S'
            LEFT OUTER JOIN articulos_clase c18 ON c18.id_cia = c.id_cia
                                                   AND c18.tipinv = d.tipinv
                                                   AND c18.codart = d.codart
                                                   AND c18.clase = 18
            LEFT OUTER JOIN articulos_clase c19 ON c19.id_cia = c.id_cia
                                                   AND c19.tipinv = d.tipinv
                                                   AND c19.codart = d.codart
                                                   AND c19.clase = 19
        WHERE
                c.id_cia = pin_id_cia
            AND ( c.tipdoc IN ( 1, 3, 7, 8, 210 ) )
            AND ( c.situac IN ( 'C', 'B', 'H', 'G', 'F' ) )
            AND ( pin_tipinv = - 1
                  OR pin_tipinv IS NULL
                  OR d.tipinv = pin_tipinv )
            AND ( trunc(c.femisi) BETWEEN pin_fdesde AND pin_fhasta )
            AND nvl(mt60.valor, 'N') = 'N'
        ORDER BY
            c.numint,
            d.numite;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_resumen;

    FUNCTION sp_resumen_utilidad (
        pin_id_cia NUMBER,
        pin_tipinv NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_detalle
        PIPELINED
    AS
        v_table datatable_detalle;
    BEGIN
        SELECT DISTINCT
            c.id_cia,
            c.numint,
            d.numite,
            d.tipinv,
            d.codart,
            a.descri AS desart,
            d.cantid,
            d.monexo,
            d.monina,
            d.monafe,
            d.codalm,
            c18.codigo,
            c19.codigo
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab  c
            LEFT OUTER JOIN documentos_det  d ON d.id_cia = c.id_cia
                                                AND d.numint = c.numint
            LEFT OUTER JOIN articulos       a ON a.id_cia = c.id_cia
                                           AND a.tipinv = d.tipinv
                                           AND a.codart = d.codart
            LEFT OUTER JOIN articulos_clase c18 ON c18.id_cia = c.id_cia
                                                   AND c18.tipinv = d.tipinv
                                                   AND c18.codart = d.codart
                                                   AND c18.clase = 18
            LEFT OUTER JOIN articulos_clase c19 ON c19.id_cia = c.id_cia
                                                   AND c19.tipinv = d.tipinv
                                                   AND c19.codart = d.codart
                                                   AND c19.clase = 19
        WHERE
                c.id_cia = pin_id_cia
            AND ( c.tipdoc IN ( 1, 3, 7, 8, 210 ) )
            AND ( c.situac IN ( 'C', 'B', 'H', 'G', 'F' ) )
            AND ( pin_tipinv = - 1
                  OR pin_tipinv IS NULL
                  OR d.tipinv = pin_tipinv )
            AND ( trunc(c.femisi) BETWEEN pin_fdesde AND pin_fhasta )
        ORDER BY
            c.numint,
            d.numite;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_resumen_utilidad;

    FUNCTION sp_detalle (
        pin_id_cia NUMBER,
        pin_tipinv NUMBER,
        pin_tipdoc NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_costo_ventas
        PIPELINED
    AS
        v_table  datatable_costo_ventas;
        v_tipdoc VARCHAR2(20);
    BEGIN
        CASE
            WHEN pin_tipdoc = 0 THEN
                v_tipdoc := '1,3,210';
            WHEN pin_tipdoc = 1 THEN
                v_tipdoc := '7';
            WHEN pin_tipdoc = 2 THEN
                v_tipdoc := '';
        END CASE;

        SELECT
            dr.id_cia,
            dr.tipinv,
            dr.codart,
            a.descri                      AS desart,
            df.series                     AS serie,
            df.numdoc                     AS numdoc,
            dr.numint,
            df.femisi                     AS femisi,
            nvl(dt.abrevi,
                substr(dt.descri, 1, 5))  AS abr,
            dg.series                     AS seriegui,
            dg.numdoc                     AS numdocgui,
            dg.numint                     AS numintgui,
            dg.femisi                     AS femisigui,
            doc.nomser                    AS abrgui,
            ac2.clase                     AS codfam,
            ac2.codigo                    AS familia,
            ac2.descodigo                 AS desfam,
            ac3.clase                     AS codlin,
            ac3.codigo                    AS linea,
            ac3.descodigo                 AS deslin,
            nvl(dr.cantid, 0) * tdc.signo AS cantid,
            ( nvl(k.costot01, 0) * nvl(k.cantid, 0) ) / (
                CASE
                    WHEN nvl(k.cantid, 0) <> 0 THEN
                        k.cantid
                    ELSE
                        1
                END
            ) * tdc.signo                 AS tot01,
            ( nvl(k.costot02, 0) * nvl(k.cantid, 0) ) / (
                CASE
                    WHEN nvl(k.cantid, 0) <> 0 THEN
                        k.cantid
                    ELSE
                        1
                END
            ) * tdc.signo                 AS tot02
        BULK COLLECT
        INTO v_table
        FROM
            pack_relacion_costo_venta.sp_resumen(pin_id_cia, pin_tipinv, pin_fdesde, pin_fhasta) dr
            LEFT OUTER JOIN kardex_costoventa                                                                    k ON k.id_cia = dr.id_cia
                                                   AND k.numint = dr.numint
                                                   AND k.numite = dr.numite
            LEFT OUTER JOIN documentos_cab                                                                       df ON df.id_cia = dr.id_cia
                                                 AND df.numint = dr.numint
            LEFT OUTER JOIN tdoccobranza                                                                         tdc ON tdc.id_cia = dr.id_cia
                                                AND tdc.tipdoc = df.tipdoc
            LEFT OUTER JOIN documentos_tipo                                                                      dt ON dt.id_cia = dr.id_cia
                                                  AND dt.tipdoc = df.tipdoc
            LEFT OUTER JOIN documentos_cab                                                                       dg ON dg.id_cia = dr.id_cia
                                                 AND dg.numint = k.numint_k
                                                 AND dg.tipdoc = 102
            LEFT OUTER JOIN documentos                                                                           doc ON doc.id_cia = dr.id_cia
                                              AND doc.codigo = dg.tipdoc
                                              AND doc.series = dg.series
            LEFT OUTER JOIN articulos                                                                            a ON a.id_cia = dr.id_cia
                                           AND a.codart = dr.codart
                                           AND a.tipinv = dr.tipinv
            LEFT OUTER JOIN sp_select_articulo_clase(pin_id_cia, dr.tipinv, dr.codart, 2)                        ac2 ON 0 = 0
            LEFT OUTER JOIN sp_select_articulo_clase(pin_id_cia, dr.tipinv, dr.codart, 3)                        ac3 ON 0 = 0
        WHERE
                dr.id_cia = pin_id_cia
            AND ( v_tipdoc IS NULL
                  OR df.tipdoc IN (
                SELECT
                    *
                FROM
                    TABLE ( convert_in(v_tipdoc) )
            ) )
        ORDER BY
            dr.codart;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_detalle;

    FUNCTION sp_leyenda (
        pin_id_cia NUMBER,
        pin_tipinv NUMBER,
        pin_tipdoc NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_leyenda
        PIPELINED
    AS
        v_table datatable_leyenda;
        v_tipdoc VARCHAR2(20);
    BEGIN
        CASE
            WHEN pin_tipdoc = 0 THEN
                v_tipdoc := '1,3,210';
            WHEN pin_tipdoc = 1 THEN
                v_tipdoc := '7';
            WHEN pin_tipdoc = 2 THEN
                v_tipdoc := '';
        END CASE;

        SELECT
            documento,
            motivo,
            SUM(cantidad),
            SUM(costototsol),
            SUM(costototdol),
            SUM(ventatotsol),
            SUM(ventatotdol)
        BULK COLLECT
        INTO v_table
        FROM
            pack_cubo_ventas.sp_cuboventas008(pin_id_cia, pin_fdesde, pin_fhasta)
        WHERE
                id_cia = pin_id_cia
            AND ( v_tipdoc IS NULL
                  OR tipdoc IN (
                SELECT
                    *
                FROM
                    TABLE ( convert_in(v_tipdoc) )
            ) )
            AND ( nvl(pin_tipinv, - 1) = - 1
                  OR tipinv = pin_tipinv )
        GROUP BY
            documento,
            motivo
        ORDER BY
            documento;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_leyenda;

END;

/

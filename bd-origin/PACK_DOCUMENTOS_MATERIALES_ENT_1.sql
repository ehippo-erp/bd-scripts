--------------------------------------------------------
--  DDL for Package Body PACK_DOCUMENTOS_MATERIALES_ENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_DOCUMENTOS_MATERIALES_ENT" AS

    FUNCTION sp_detalle_entrega (
        pin_id_cia NUMBER,
        pin_numint NUMBER,
        pin_numite NUMBER,
        pin_numsec NUMBER
    ) RETURN datatable_entrega
        PIPELINED
    AS
        v_entrega NUMERIC(16, 5) := 0;
        v_rec     datarecord_entrega;
    BEGIN
        BEGIN
            SELECT
                abs(SUM(nvl(de.entreg, 0))) AS entrega
            INTO v_entrega
            FROM
                     documentos_materiales_ent de
                INNER JOIN documentos_cab dc ON dc.id_cia = de.id_cia
                                                AND dc.numint = de.orinumint
                                                AND dc.situac NOT IN ( 'J', 'K' )
            WHERE
                    de.id_cia = pin_id_cia
                AND de.opnumdoc = pin_numint
                AND de.opnumite = pin_numite
                AND de.opnumsec = pin_numsec;

        EXCEPTION
            WHEN no_data_found THEN
                v_entrega := 0;
        END;

        v_rec.id_cia := pin_id_cia;
        v_rec.numint := pin_numint;
        v_rec.numite := pin_numite;
        v_rec.numsec := pin_numsec;
        v_rec.entreg := nvl(v_entrega, 0);
        PIPE ROW ( v_rec );
    END sp_detalle_entrega;

    FUNCTION sp_saldo_documentos_det (
        pin_id_cia NUMBER,
        pin_numint NUMBER
    ) RETURN datatable_saldo_documentos_det
        PIPELINED
    AS
        v_table datatable_saldo_documentos_det;
    BEGIN
        SELECT
            d.id_cia,
            hd.numint                AS opnumint,
            dt.numite                AS opnumite,
            hd.series                AS opseries,
            hd.numdoc                AS opnumdoc,
            dt.tipinv                AS optipinv,
            dt.codart                AS opcodart,
            dtc.codigo               AS poclase1,
            ah.descri                AS opdesart,
            dt.cantid                AS opcantid,
            hd.razonc                AS oprazonc,
            hd.femisi                AS opfemisi,
            hd.numint,
            hd.tipdoc,
            hd.series,
            hd.numdoc,
            hd.situac,
            d.numite,
            d.tipinv,
            d.codart,
            a.descri                 AS desart,
            d.codalm,
            a.coduni                 AS codund,
            ( d.cantid - de.entreg ) *
            CASE
                WHEN a.consto = 2 THEN
                        d.largo
                ELSE
                    1.0
            END
            AS cantid,
            ( d.cantid - de.entreg ) AS canped,
            d.pordes1,
            d.pordes2,
            d.pordes3,
            d.pordes4,
            d.preuni,
            d.observ                 AS obsdet,
            hd.femisi                AS fcreac,
            hd.femisi                AS factua,
            hd.usuari,
            d.largo,
            CASE
                WHEN a.consto = 2 THEN
                    d.cantid - de.entreg
                ELSE
                    0.0
            END                      AS piezas,
            d.ancho,
            d.altura,
            d.numsec,
            d.numsec,
            dt.numintpre,
            dt.numitepre,
            kk.stock,
            current_date             AS fstock
        BULK COLLECT
        INTO v_table
        FROM
                 documentos_cab hd
            INNER JOIN documentos_det                                                                            dt ON dt.id_cia = hd.id_cia
                                            AND dt.numint = hd.numint
            INNER JOIN documentos_materiales                                                                     d ON d.id_cia = dt.id_cia
                                                  AND d.numint = dt.numint
                                                  AND d.numite = dt.numite
            LEFT OUTER JOIN documentos_det_clase                                                                      dtc ON dtc.id_cia = dt.id_cia
                                                        AND dtc.numint = dt.numint
                                                        AND dtc.numite = dt.numite
                                                        AND dtc.clase = 1
            LEFT OUTER JOIN documentos_relacion                                                                       dr ON dr.id_cia = d.id_cia
                                                      AND dr.numint = d.numint
            LEFT OUTER JOIN documentos_cab                                                                            hd2 ON hd2.id_cia = dr.id_cia
                                                  AND hd2.numint = dr.numintre
            LEFT OUTER JOIN documentos_det                                                                            dd2 ON dd2.id_cia = hd2.id_cia
                                                  AND dd2.numint = hd2.numint
                                                  AND dd2.numite = d.numite
            LEFT OUTER JOIN articulos                                                                                 ah ON ah.id_cia = dt.id_cia
                                            AND ah.tipinv = dt.tipinv
                                            AND ah.codart = dt.codart
            LEFT OUTER JOIN articulos                                                                                 a ON a.id_cia = d.id_cia
                                           AND a.tipinv = d.tipinv
                                           AND a.codart = d.codart
            LEFT OUTER JOIN pack_documentos_materiales_ent.sp_detalle_entrega(d.id_cia, d.numint, d.numite, d.numsec) de ON 0 = 0
            LEFT OUTER JOIN sp000_saca_stock_costo_articulos_almacen(d.id_cia,
                                                                     d.tipinv,
                                                                     d.codalm,
                                                                     d.codart,
                                                                     EXTRACT(YEAR FROM current_date),
                                                                     EXTRACT(MONTH FROM current_date),
                                                                     EXTRACT(MONTH FROM current_date))                                                         kk
                                                                     ON 0 = 0
        WHERE
                hd.id_cia = pin_id_cia
            AND hd.numint = pin_numint
            AND ( d.cantid - de.entreg ) > 0;
--    AND ( dd2.swacti = 0
--          OR dd2.swacti IS NULL )

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_saldo_documentos_det;

END;

/

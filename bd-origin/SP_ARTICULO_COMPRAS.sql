--------------------------------------------------------
--  DDL for Function SP_ARTICULO_COMPRAS
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP_ARTICULO_COMPRAS" (
    pin_id_cia  IN NUMBER,
    pin_tipinv  IN NUMBER,
    pin_codart  IN VARCHAR2,
    pin_codsuc  IN NUMBER,
    pin_codprov IN VARCHAR2,
    pin_limit   IN NUMBER,
    pin_offset  IN NUMBER
) RETURN tbl_sp_articulo_compras
    PIPELINED
AS

    rec rec_sp_articulo_compras := rec_sp_articulo_compras(NULL, NULL, NULL, NULL, NULL,
                                                          NULL, NULL, NULL, NULL, NULL,
                                                          NULL, NULL, NULL, NULL, NULL,
                                                          NULL, NULL, NULL, NULL, NULL,
                                                          NULL, NULL, NULL, NULL, NULL,
                                                          NULL, NULL, NULL, NULL, NULL,
                                                          NULL, NULL, NULL, NULL, NULL,
                                                          NULL, NULL, NULL, NULL, NULL);
BEGIN
    FOR i IN (
        SELECT
            a.locali,
            a.id,
            a.tipdoc,
            a.numint,
            a.numite,
            a.periodo,
            a.codmot,
            a.femisi,
            a.tipinv,
            a.codart,
            a.cantid,
            a.codalm,
            a.almdes,
            a.costot01,
            a.costot01 / a.cantid AS tcos01,
            a.costot02,
            a.costot02 / a.cantid tcos02,
            a.fobtot01,
            a.fobtot02,
            d.razonc,
            al.descri             AS desalm,
            a.usuari,
            d.numdoc,
            d.series,
            d.codcli,
            m.desmot,
            i.dtipinv,
            s.descri              AS desdoc,
            ar.descri,
            d.ordcom,
            d.numvale,
            ci.series             AS serord,
            ci.numdoc             AS nroord,
            ci.femisi             AS femisiord,
            ci.tipmon             AS tipmonord,
            di.preuni             AS cosfobuni,
            di.preuni * a.cantid  AS cosfobtot,
            dg.largo,
            dc5.series            series_oc,
            dc5.numdoc            AS numdoc_oc
        FROM
                 kardex a
            INNER JOIN documentos_cab                                                              d ON a.id_cia = d.id_cia
                                           AND a.numint = d.numint
            INNER JOIN almacen                                                                     al ON al.id_cia = a.id_cia
                                     AND al.tipinv = a.tipinv
                                     AND al.codalm = a.codalm
            LEFT OUTER JOIN t_inventario                                                                i ON a.id_cia = i.id_cia
                                              AND a.tipinv = i.tipinv
            LEFT OUTER JOIN motivos                                                                     m ON a.id_cia = m.id_cia
                                         AND a.codmot = m.codmot
                                         AND a.id = m.id
                                         AND a.tipdoc = m.tipdoc
            LEFT OUTER JOIN articulos                                                                   ar ON a.id_cia = ar.id_cia
                                            AND a.tipinv = ar.tipinv
                                            AND a.codart = ar.codart
            LEFT OUTER JOIN documentos                                                                  s ON d.id_cia = s.id_cia
                                            AND d.tipdoc = s.codigo
                                            AND d.series = s.series
            LEFT OUTER JOIN documentos_det                                                              dg ON dg.id_cia = a.id_cia
                                                 AND dg.numint = a.numint
                                                 AND dg.numite = a.numite
            LEFT OUTER JOIN documentos_cab                                                              ci ON ci.id_cia = dg.id_cia
                                                 AND ci.numint = dg.opnumdoc
            LEFT OUTER JOIN documentos_det                                                              di ON di.id_cia = dg.id_cia
                                                 AND di.numint = dg.opnumdoc
                                                 AND di.numite = dg.opnumite
            LEFT OUTER JOIN TABLE ( pack_trazabilidad.sp_trazabilidad_tipdoc(d.id_cia, d.numint, 105) ) dc5 ON 0 = 0
        WHERE
                a.id_cia = pin_id_cia
            AND a.tipinv = pin_tipinv
            AND a.codart = pin_codart
            AND d.codsuc = pin_codsuc
            AND ( pin_codprov IS NULL
                  OR d.codcli = pin_codprov )
            AND a.id = 'I'
            AND a.codmot IN ( 1, 28 )
        ORDER BY
            a.femisi DESC
        OFFSET pin_offset ROWS FETCH NEXT pin_limit ROWS ONLY
    ) LOOP
        rec.locali := i.locali;
        rec.id := i.id;
        rec.tipdoc := i.tipdoc;
        rec.numint := i.numint;
        rec.numite := i.numite;
        rec.periodo := i.periodo;
        rec.codmot := i.codmot;
        rec.femisi := i.femisi;
        rec.tipinv := i.tipinv;
        rec.codart := i.codart;
        rec.cantid := i.cantid;
        rec.codalm := i.codalm;
        rec.almdes := i.almdes;
        rec.costot01 := i.costot01;
        rec.tcos01 := i.tcos01;
        rec.costot02 := i.costot02;
        rec.tcos02 := i.tcos02;
        rec.fobtot01 := i.fobtot01;
        rec.fobtot02 := i.fobtot02;
        rec.razonc := i.razonc;
        rec.desalm := i.desalm;
        rec.usuari := i.usuari;
        rec.numdoc := i.numdoc;
        rec.series := i.series;
        rec.codcli := i.codcli;
        rec.desmot := i.desmot;
        rec.dtipinv := i.dtipinv;
        rec.desdoc := i.desdoc;
        rec.descri := i.descri;
        rec.ordcom := i.ordcom;
        rec.numvale := i.numvale;
        rec.serord := i.serord;
        rec.nroord := i.nroord;
        rec.femisiord := i.femisiord;
        rec.tipmonord := i.tipmonord;
        rec.cosfobuni := i.cosfobuni;
        rec.cosfobtot := i.cosfobtot;
        rec.largo := i.largo;
        rec.series_oc := i.series_oc;
        rec.numdoc_oc := i.numdoc_oc;
        PIPE ROW ( rec );
    END LOOP;
END sp_articulo_compras;

/

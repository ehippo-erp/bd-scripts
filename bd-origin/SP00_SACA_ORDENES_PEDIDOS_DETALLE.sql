--------------------------------------------------------
--  DDL for Function SP00_SACA_ORDENES_PEDIDOS_DETALLE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "USR_TSI_SUITE"."SP00_SACA_ORDENES_PEDIDOS_DETALLE" (
    pin_id_cia    IN NUMBER,
    pin_tipinv    IN NUMBER,
    pin_codart    IN VARCHAR2,
    pin_codalm    IN NUMBER,
    pin_wetiqueta IN VARCHAR2
) RETURN tbl_sp00_saca_ordenes_pedidos_detalle
    PIPELINED
AS

    rec     rec_sp00_saca_ordenes_pedidos_detalle := rec_sp00_saca_ordenes_pedidos_detalle(NULL, NULL, NULL, NULL, NULL,
                                                                                      NULL, NULL, NULL, NULL, NULL,
                                                                                      NULL, NULL, NULL, NULL, NULL,
                                                                                      NULL, NULL, NULL, NULL, NULL,
                                                                                      NULL, NULL, NULL, NULL, NULL,
                                                                                      NULL);
    wpreuni NUMERIC(16, 4);
BEGIN
    FOR j IN (
        SELECT
            dc.numint,
            dc.series,
            dc.numdoc,
            dc.femisi,
            dc.fentreg,
            dc.tipmon,
            dc.tipcam,
            dc.codcli,
            dc.ruc,
            dc.razonc,
            dc.opnumdoc,
            dc.ordcom,
            dc.codven,
            v.desven,
            dd.numite,
            dd.tipinv,
            dd.codalm,
            dd.codart,
            dd.cantid AS cantidad,
            dd.codund,
            CASE
                WHEN dd.cantid = 0 THEN
                    0
                ELSE
                    ( dd.monafe + dd.monina + dd.monigv ) / dd.cantid
            END       AS wpreuni,
            (
                SELECT
                    SUM(de.entreg)
                FROM
                    documentos_ent de
                WHERE
                        de.id_cia = pin_id_cia
                    AND de.opnumdoc = dd.numint
                    AND de.opnumite = dd.numite
            )         AS entrega,
            dd.etiqueta,
            dd.observ
        FROM
                 documentos_cab dc
            INNER JOIN documentos_det dd ON dd.id_cia = dc.id_cia
                                            AND dd.numint = dc.numint
            LEFT OUTER JOIN vendedor       v ON v.id_cia = dc.id_cia
                                          AND v.codven = dc.codven
        WHERE
                dc.id_cia = pin_id_cia
            AND dc.tipdoc = 101
            AND dc.situac IN ( 'B', 'D', 'G' )
            AND ( nvl(pin_tipinv, 0) = 0
                  OR dd.tipinv = pin_tipinv )
            AND ( pin_codart IS NULL
                  OR dd.codart = pin_codart )
            AND ( nvl(pin_codalm, 0) = 0
                  OR dd.codalm = pin_codalm )
            AND ( pin_wetiqueta IS NULL
                  OR dd.etiqueta = pin_wetiqueta )
        ORDER BY
            dd.numite,
            dd.tipinv,
            dd.codart,
            dd.codalm
    ) LOOP
        rec.numint := j.numint;
        rec.series := j.series;
        rec.numdoc := j.numdoc;
        rec.femisi := j.femisi;
        rec.fentreg := j.fentreg;
        rec.tipmon := j.tipmon;
        rec.tipcam := j.tipcam;
        rec.codcli := j.codcli;
        rec.ruc := j.ruc;
        rec.razonc := j.razonc;
        rec.opnumdoc := j.opnumdoc;
        rec.ordcom := j.ordcom;
        rec.codven := j.codven;
        rec.desven := j.desven;
        rec.saldo := j.cantidad - j.entrega;
        IF ( j.tipmon = 'PEN' ) THEN
            rec.preunisol := j.wpreuni;
            rec.preunidol := ( j.wpreuni / j.tipcam );
        ELSE
            rec.preunidol := j.wpreuni;
            rec.preunisol := ( j.wpreuni * j.tipcam );
        END IF;

        rec.numite := j.numite;
        rec.tipinv := nvl(j.tipinv, -1);
        rec.codalm := nvl(j.codalm, -1);
        rec.codart := nvl(j.codart, '-1');
        rec.cantidad := nvl(j.cantidad, 0);
        rec.codund := j.codund;
        rec.entrega := nvl(j.entrega, 0);
        rec.etiqueta := j.etiqueta;
        rec.observ := j.observ;
        PIPE ROW ( rec );
    END LOOP;
END sp00_saca_ordenes_pedidos_detalle;

/

--------------------------------------------------------
--  DDL for Function SP_ARTICULO_VENTAS
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP_ARTICULO_VENTAS" (
    pin_id_cia IN NUMBER,
    pin_tipinv IN NUMBER,
    pin_codart IN VARCHAR2,
    pin_codsuc IN NUMBER,
    pin_codcli IN VARCHAR2,
    pin_limit  IN NUMBER,
    pin_offset IN NUMBER
) RETURN tbl_sp_articulo_ventas
    PIPELINED
AS

    x   NUMBER;
    rec rec_sp_articulo_ventas := rec_sp_articulo_ventas(NULL, NULL, NULL, NULL, NULL,
                                                        NULL, NULL, NULL, NULL, NULL,
                                                        NULL, NULL, NULL, NULL, NULL,
                                                        NULL, NULL, NULL, NULL, NULL,
                                                        NULL, NULL, NULL, NULL, NULL,
                                                        NULL, NULL, NULL, NULL);
BEGIN
    SELECT
        COUNT(*)
    INTO x
    FROM
        documentos_cab;

    FOR i IN (
        SELECT
            c.tipdoc,
            c.numint,
            d.numite,
            c.codmot,
            c.femisi,
            c.numdoc,
            c.series,
            c.codcli,
            c.razonc,
            td.signo,
            c.incigv,
            d.tipinv,
            d.codart,
            a.descri as desart,
            d.cantid,
            d.largo,
            d.codalm,
            d.pordes1,
            d.pordes2,
            d.pordes3,
            d.pordes4,
            CASE
                WHEN tipmon = 'PEN' THEN
                        d.preuni
                ELSE
                    0
            END
            * td.signo AS preunisol,
            CASE
                WHEN tipmon = 'USD' THEN
                        d.preuni
                ELSE
                    0
            END
            * td.signo AS preunidol,
            CASE
                WHEN tipmon = 'PEN' THEN
                        d.importe
                ELSE
                    0
            END
            * td.signo AS pretotsol,
            CASE
                WHEN tipmon = 'USD' THEN
                        d.importe
                ELSE
                    0
            END
            * td.signo AS pretotdol,
            al.descri  AS desalm,
            c.ordcom,
            dc.descri  AS desdoc,
            s.dessit
        FROM
                 documentos_det d
            INNER JOIN documentos_cab c ON c.id_cia = d.id_cia
                                           AND ( c.numint = d.numint )
            LEFT OUTER JOIN documentos     dc ON dc.id_cia = d.id_cia
                                             AND ( dc.codigo = d.tipdoc )
                                             AND ( dc.series = c.series )
            LEFT OUTER JOIN situacion      s ON s.id_cia = d.id_cia
                                           AND ( s.tipdoc = d.tipdoc
                                                 AND s.situac = c.situac )
            LEFT OUTER JOIN almacen        al ON al.id_cia = d.id_cia
                                          AND al.tipinv = d.tipinv
                                          AND al.codalm = d.codalm
            LEFT OUTER JOIN tdoccobranza   td ON td.id_cia = d.id_cia
                                               AND ( td.tipdoc = d.tipdoc )
            LEFT OUTER JOIN articulos      a ON a.id_cia = pin_id_cia
                                           AND a.tipinv = d.tipinv
                                           AND a.codart = d.codart
        WHERE
            ( d.id_cia = pin_id_cia )
            AND ( ( d.tipinv = pin_tipinv
                    AND pin_tipinv IS NOT NULL )
                  OR ( pin_tipinv IS NULL
                       OR pin_tipinv = - 1 ) )
            AND ( ( d.codart = pin_codart
                    AND pin_codart IS NOT NULL )
                  OR ( pin_codart IS NULL ) )
            AND ( ( c.situac = 'F' )
                  OR ( c.situac = 'G' )
                  OR ( c.situac = 'C' )
                  OR ( c.situac = 'H' ) )
            AND ( ( c.codsuc = pin_codsuc
                    AND pin_codsuc IS NOT NULL )
                  OR ( pin_codsuc IS NULL
                       OR pin_codsuc = - 1 ) )
            AND ( ( c.tipdoc = 1 )
                  OR ( c.tipdoc = 3 )
                  OR ( c.tipdoc = 7 )
                  OR ( c.tipdoc = 8 ) )
            AND ( ( pin_codcli IS NULL )
                  OR ( c.codcli = pin_codcli
                       AND pin_codcli IS NOT NULL ) )
            AND ( c.id = 'S' )
            AND ( c.codmot = 1 )
        ORDER BY
            c.femisi DESC
        OFFSET
            CASE
                WHEN pin_offset = - 1 THEN
                    0
                ELSE
                    pin_offset
            END
        ROWS FETCH NEXT
            CASE
                WHEN pin_limit = - 1 THEN
                    x
                ELSE
                    pin_limit
            END
        ROWS ONLY
    ) LOOP
        rec.tipdoc := i.tipdoc;
        rec.numint := i.numint;
        rec.numite := i.numite;
        rec.codmot := i.codmot;
        rec.femisi := i.femisi;
        rec.numdoc := i.numdoc;
        rec.series := i.series;
        rec.codcli := i.codcli;
        rec.razonc := i.razonc;
        rec.signo := i.signo;
        rec.incigv := i.incigv;
        rec.tipinv := i.tipinv;
        rec.codart := i.codart;
        rec.desart := i.desart;
        rec.cantid := i.cantid;
        rec.largo := i.largo;
        rec.codalm := i.codalm;
        rec.pordes1 := i.pordes1;
        rec.pordes2 := i.pordes2;
        rec.pordes3 := i.pordes3;
        rec.pordes4 := i.pordes4;
        rec.preunisol := i.preunisol;
        rec.preunidol := i.preunidol;
        rec.pretotsol := i.pretotsol;
        rec.pretotdol := i.pretotdol;
        rec.desalm := i.desalm;
        rec.ordcom := i.ordcom;
        rec.desdoc := i.desdoc;
        rec.dessit := i.dessit;
        PIPE ROW ( rec );
    END LOOP;

 -- RETURN NULL;
END sp_articulo_ventas;

/

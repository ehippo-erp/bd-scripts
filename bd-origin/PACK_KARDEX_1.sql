--------------------------------------------------------
--  DDL for Package Body PACK_KARDEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_KARDEX" AS

    FUNCTION sp_buscar_kardex_por_articulo (
        pin_id_cia     NUMBER,
        pin_tipinv     NUMBER,
        pin_codalm     NUMBER,
        pin_codart     VARCHAR2,
        pin_periodo    NUMBER,
        pin_mes        NUMBER,
        pin_lote       VARCHAR2,
        pin_etiqueta   VARCHAR2,
        pin_checktodos VARCHAR2
    ) RETURN tbl_kardex
        PIPELINED
    AS

        rec rec_kardex := rec_kardex(NULL, NULL, NULL, NULL, NULL,
                                    NULL, NULL, NULL, NULL, NULL,
                                    NULL, NULL, NULL, NULL, NULL,
                                    NULL, NULL, NULL, NULL, NULL,
                                    NULL, NULL, NULL, NULL, NULL,
                                    NULL, NULL, NULL, NULL, NULL,
                                    NULL, NULL, NULL, NULL, NULL,
                                    NULL, NULL, NULL, NULL, NULL,
                                    NULL, NULL, NULL, NULL, NULL,
                                    NULL, NULL, NULL, NULL,NULL);
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
                alm.descri AS almdes,
                CASE
                    WHEN a.id = 'I' THEN
                        a.cantid
                    ELSE
                        NULL
                END        AS ingresos,
                CASE
                    WHEN a.id = 'S' THEN
                        a.cantid
                    ELSE
                        NULL
                END        AS salidas,
                a.costot01,
                CASE
                    WHEN ( a.cantid > 0 )
                         AND ( a.costot01 > 0 ) THEN
                        a.costot01 / a.cantid
                    ELSE
                        0
                END        AS tcos01,
                a.costot02,
                CASE
                    WHEN ( a.cantid > 0 )
                         AND ( a.costot02 > 0 ) THEN
                        a.costot02 / a.cantid
                    ELSE
                        0
                END        AS tcos02,
                a.fobtot01,
                a.fobtot02,
                a.etiqueta,
                a.opnumdoc,
                a.usuari,
                d.numdoc,
                d.series,
                d.codcli,
                cl.razonc,
                m.desmot,
                i.dtipinv,
                s.descri   AS desdoc,
                ar.descri  AS desart,
                d.ordcom,
                d.numvale,
                cl.dident  AS ruc,
                ac1.codigo AS codadd01,
                ac1.descri AS descodadd01,
                ac2.codigo AS codadd02,
                ac2.descri AS descodadd02,
                au.codigo  AS ubica,
                au.descri  AS desubica,
                dc.lote,
                dc.nrocarrete,
                dc.ancho,
                dc.combina,
                dc.empalme,
                dc.diseno,
                dc.acabado,
                dc.chasis,
                dc.motor
            FROM
                kardex                  a
                LEFT OUTER JOIN documentos_cab          d ON a.id_cia = d.id_cia
                                                    AND ( a.numint = d.numint )
                LEFT OUTER JOIN almacen_ubicacion       au ON au.id_cia = a.id_cia
                                                        AND au.tipinv = a.tipinv
                                                        AND au.codalm = a.codalm
                                                        AND au.codigo = a.ubica
                LEFT OUTER JOIN documentos_det          dc ON dc.id_cia = a.id_cia
                                                     AND ( dc.numint = a.numint )
                                                     AND ( dc.numite = a.numite )
                LEFT OUTER JOIN articulos               ar ON a.id_cia = ar.id_cia
                                                AND ( a.tipinv = ar.tipinv
                                                      AND a.codart = ar.codart )
                LEFT OUTER JOIN cliente_articulos_clase ac1 ON ac1.id_cia = ar.id_cia
                                                               AND ( ac1.tipcli = 'B' )
                                                               AND ( ac1.codcli = ar.codprv )
                                                               AND ( ac1.clase = 1 )
                                                               AND ( ac1.codigo = dc.codadd01 )
                LEFT OUTER JOIN cliente_articulos_clase ac2 ON ac2.id_cia = ar.id_cia
                                                               AND ( ac2.tipcli = 'B' )
                                                               AND ( ac2.codcli = ar.codprv )
                                                               AND ( ac2.clase = 2 )
                                                               AND ( ac2.codigo = dc.codadd02 )
                LEFT OUTER JOIN t_inventario            i ON a.id_cia = i.id_cia
                                                  AND ( a.tipinv = i.tipinv )
                LEFT OUTER JOIN motivos                 m ON a.id_cia = m.id_cia
                                             AND ( a.codmot = m.codmot
                                                   AND a.id = m.id
                                                   AND a.tipdoc = m.tipdoc )
                LEFT OUTER JOIN documentos              s ON d.id_cia = s.id_cia
                                                AND ( d.tipdoc = s.codigo
                                                      AND d.series = s.series )
                LEFT OUTER JOIN cliente                 cl ON cl.id_cia = a.id_cia
                                              AND ( cl.codcli = a.codcli )
                LEFT OUTER JOIN almacen                 alm ON alm.id_cia = a.id_cia
                                               AND alm.tipinv = a.tipinv
                                               AND ( alm.codalm = a.codalm )
            WHERE
                    a.id_cia = pin_id_cia
                AND a.tipinv = pin_tipinv
                AND a.codart = pin_codart
                AND ( pin_codalm = - 1
                      OR a.codalm = pin_codalm )
                AND ( ( ( pin_checktodos = 'N' )
                        AND a.periodo = ( pin_periodo * 100 ) + pin_mes )
                      OR ( ( pin_checktodos = 'S' )
                           AND trunc(a.periodo / 100) = pin_periodo ) )
                AND ( pin_lote IS NULL
                      OR dc.lote = pin_lote )
                AND ( pin_etiqueta IS NULL
                      OR a.etiqueta = pin_etiqueta )
            ORDER BY
                a.femisi DESC
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
            rec.ingresos := i.ingresos;
            rec.salidas := i.salidas;
            rec.costot01 := i.costot01;
            rec.tcos01 := i.tcos01;
            rec.costot02 := i.costot02;
            rec.tcos02 := i.tcos02;
            rec.fobtot01 := i.fobtot01;
            rec.fobtot02 := i.fobtot02;
            rec.etiqueta := i.etiqueta;
            rec.opnumdoc := i.opnumdoc;
            rec.usuari := i.usuari;
            rec.numdoc := i.numdoc;
            rec.series := i.series;
            rec.codcli := i.codcli;
            rec.razonc := i.razonc;
            rec.desmot := i.desmot;
            rec.dtipinv := i.dtipinv;
            rec.desdoc := i.desdoc;
            rec.desart := i.desart;
            rec.ordcom := i.ordcom;
            rec.numvale := i.numvale;
            rec.ruc := i.ruc;
            rec.codadd01 := i.codadd01;
            rec.descodadd01 := i.descodadd01;
            rec.codadd02 := i.codadd02;
            rec.descodadd02 := i.descodadd02;
            rec.ubica := i.ubica;
            rec.desubica := i.desubica;
            rec.lote := i.lote;
            rec.nrocarrete := i.nrocarrete;
            rec.ancho := i.ancho;
            rec.combina := i.combina;
            rec.empalme := i.empalme;
            rec.diseno := i.diseno;
            rec.acabado := i.acabado;
            rec.chasis := i.chasis;
            rec.motor := i.motor;
            PIPE ROW ( rec );
        END LOOP;
    END sp_buscar_kardex_por_articulo;

END pack_kardex;

/

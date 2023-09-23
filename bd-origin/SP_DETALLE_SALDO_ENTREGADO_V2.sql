--------------------------------------------------------
--  DDL for Function SP_DETALLE_SALDO_ENTREGADO_V2
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP_DETALLE_SALDO_ENTREGADO_V2" (
    pin_id_cia  NUMBER,
    pin_numints VARCHAR2
) RETURN tbl_detalle_saldo_entregado
    PIPELINED
AS

    r_detalle_saldo_entregado rec_detalle_saldo_entregado := rec_detalle_saldo_entregado(NULL, NULL, NULL, NULL, NULL,
                                                                                        NULL, NULL, NULL, NULL, NULL,
                                                                                        NULL, NULL, NULL, NULL, NULL,
                                                                                        NULL, NULL, NULL, NULL, NULL,
                                                                                        NULL, NULL, NULL, NULL, NULL,
                                                                                        NULL, NULL, NULL, NULL, NULL,
                                                                                        NULL, NULL, NULL, NULL, NULL,
                                                                                        NULL, NULL, NULL, NULL);
    CURSOR cur_select IS
    SELECT
        d.numint,
        d.numite,
        d.positi,
        d.tipinv,
        d.codart,
        a.descri AS desart,
        d.codadd01,
        d.codadd02,
        d.codund,
        CASE
            WHEN ( ( d.codalm = 98 )
                   AND ( c.tipdoc = 102 )
                   AND ( c.almdes <> 0 )
                   AND ( c.id = 'S' ) ) THEN
                c.almdes
            ELSE
                CASE
                    WHEN ( ( c.tipdoc IN ( 1, 3 ) )
                           AND ( mt6.valor = '99' )
                           AND ( d.codalm <> 99 ) ) THEN
                            99 /**/
                    ELSE
                        d.codalm
                END
        END      codalm,
        d.observ,
        d.largo,
        d.ancho,
        d.etiqueta,
        d.lote,
        d.nrocarrete,
        d.codcli,
        d.tara,
        d.royos,
        d.ubica,
        d.combina,
        d.empalme,
        d.diseno,
        d.acabado,
        d.chasis,
        d.motor,
        d.fvenci,
        d.valporisc,
        d.tipisc,
        d.cantid,
        d.preuni,
        d.pordes1,
        d.pordes2,
        d.pordes3,
        d.pordes4,
        d.cosuni,
        d.tipcam,
        t.modpre,
        (
            SELECT
                stock
            FROM
                sp000_saca_stock_costo_articulos_almacen(d.id_cia, d.tipinv, d.codalm, d.codart, EXTRACT(YEAR FROM current_date),
                                                         EXTRACT(MONTH FROM current_date), EXTRACT(MONTH FROM current_date))
        )        AS stock
    FROM
        documentos_det d
        LEFT OUTER JOIN documentos_cab c ON c.id_cia = d.id_cia
                                            AND c.numint = d.numint
        LEFT OUTER JOIN articulos      a ON a.id_cia = d.id_cia
                                       AND a.tipinv = d.tipinv
                                       AND a.codart = d.codart
        LEFT OUTER JOIN cliente        cl ON cl.id_cia = d.id_cia
                                      AND cl.codcli = c.codcli
        LEFT OUTER JOIN titulolista    t ON t.id_cia = d.id_cia
                                         AND t.codtit = cl.codtit
        LEFT OUTER JOIN motivos_clase  mt6 ON mt6.id_cia = d.id_cia
                                             AND mt6.tipdoc = c.tipdoc
                                             AND mt6.codmot = c.codmot
                                             AND mt6.id = c.id
                                             AND mt6.codigo = 6
    WHERE
            d.id_cia = pin_id_cia
        AND d.numint IN (
            SELECT
                *
            FROM
                TABLE ( convert_in(pin_numints) )
        )
    ORDER BY
        d.numint,
        d.numite;

    v_entrega                 NUMERIC(16, 5) := 0;
    v_cantid                  NUMERIC(16, 5) := 0;
BEGIN
    FOR registro IN cur_select LOOP
        BEGIN
            v_cantid := registro.cantid;
            SELECT
                abs(SUM(nvl(de.entreg, 0))) AS entrega
            INTO v_entrega
            FROM
                     documentos_ent de
                INNER JOIN documentos_cab dc ON dc.id_cia = pin_id_cia
                                                AND dc.numint = de.orinumint
                                                AND dc.situac NOT IN ( 'J', 'K' )
            WHERE
                    de.id_cia = pin_id_cia
                AND ( de.opnumdoc = registro.numint )
                AND ( de.opnumite = registro.numite );

        EXCEPTION
            WHEN no_data_found THEN
                v_entrega := 0;
        END;
        --DBMS_OUTPUT.PUT_LINE(v_cantid);
        --DBMS_OUTPUT.PUT_LINE(v_entrega);
        v_cantid := nvl(v_cantid, 0) - nvl(v_entrega, 0);
        IF ( v_cantid <> 0 ) THEN
            r_detalle_saldo_entregado.numint := registro.numint;
            r_detalle_saldo_entregado.numite := registro.numite;
            r_detalle_saldo_entregado.positi := registro.positi;
            r_detalle_saldo_entregado.tipinv := registro.tipinv;
            r_detalle_saldo_entregado.codart := registro.codart;
            r_detalle_saldo_entregado.desart := registro.desart;
            r_detalle_saldo_entregado.codadd01 := registro.codadd01;
            r_detalle_saldo_entregado.codadd02 := registro.codadd02;
            r_detalle_saldo_entregado.codund := registro.codund;
            r_detalle_saldo_entregado.codalm := registro.codalm;
            r_detalle_saldo_entregado.observ := registro.observ;
            r_detalle_saldo_entregado.largo := registro.largo;
            r_detalle_saldo_entregado.ancho := registro.ancho;
            r_detalle_saldo_entregado.etiqueta := registro.etiqueta;
            r_detalle_saldo_entregado.lote := registro.lote;
            r_detalle_saldo_entregado.nrocarrete := registro.nrocarrete;
            r_detalle_saldo_entregado.codcli := registro.codcli;
            r_detalle_saldo_entregado.tara := registro.tara;
            r_detalle_saldo_entregado.royos := registro.royos;
            r_detalle_saldo_entregado.ubica := registro.ubica;
            r_detalle_saldo_entregado.combina := registro.combina;
            r_detalle_saldo_entregado.empalme := registro.empalme;
            r_detalle_saldo_entregado.diseno := registro.diseno;
            r_detalle_saldo_entregado.acabado := registro.acabado;
            r_detalle_saldo_entregado.chasis := registro.chasis;
            r_detalle_saldo_entregado.motor := registro.motor;
            r_detalle_saldo_entregado.fvenci := registro.fvenci;
            r_detalle_saldo_entregado.valporisc := registro.valporisc;
            r_detalle_saldo_entregado.tipisc := registro.tipisc;
            r_detalle_saldo_entregado.cantid := v_cantid;
            r_detalle_saldo_entregado.preuni := registro.preuni;
            r_detalle_saldo_entregado.pordes1 := registro.pordes1;
            r_detalle_saldo_entregado.pordes2 := registro.pordes2;
            r_detalle_saldo_entregado.pordes3 := registro.pordes3;
            r_detalle_saldo_entregado.pordes4 := registro.pordes4;
            r_detalle_saldo_entregado.modpre := registro.modpre;
            r_detalle_saldo_entregado.stock := registro.stock;
            r_detalle_saldo_entregado.costo := registro.cosuni;
            r_detalle_saldo_entregado.tipcam := registro.tipcam;
            PIPE ROW ( r_detalle_saldo_entregado );
        END IF;

    END LOOP;
END "SP_DETALLE_SALDO_ENTREGADO_V2";

/

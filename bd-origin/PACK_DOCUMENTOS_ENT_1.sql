--------------------------------------------------------
--  DDL for Package Body PACK_DOCUMENTOS_ENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_DOCUMENTOS_ENT" AS

    FUNCTION sp_detalle_entrega (
        pin_id_cia NUMBER,
        pin_numint NUMBER,
        pin_numite NUMBER
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
                     documentos_ent de
                INNER JOIN documentos_cab dc ON dc.id_cia = pin_id_cia
                                                AND dc.numint = de.orinumint
                                                AND dc.situac NOT IN ( 'J', 'K' )
            WHERE
                    de.id_cia = pin_id_cia
                AND de.opnumdoc = pin_numint
                AND de.opnumite = pin_numite;

        EXCEPTION
            WHEN no_data_found THEN
                v_entrega := 0;
        END;

        v_rec.id_cia := pin_id_cia;
        v_rec.numint := pin_numint;
        v_rec.numite := pin_numite;
        v_rec.entreg := nvl(v_entrega, 0);
        PIPE ROW ( v_rec );
    END sp_detalle_entrega;

    FUNCTION sp_saldo_documentos_det (
        pin_id_cia NUMBER,
        pin_numint NUMBER,
        pin_numite NUMBER
    ) RETURN datatable_saldo_documentos_det
        PIPELINED
    AS
        v_table   datatable_saldo_documentos_det;
        v_entrega NUMBER(16, 5);
        v_saldo   NUMBER(16, 5);
    BEGIN
        SELECT
            d.id_cia,
            d.tipdoc,
            d.numint,
            d.numite,
            d.tipinv,
            d.codart,
            d.monafe,
            d.monina,
            d.monigv,
            abs(nvl(d.cantid, 0)) AS cantidad,
            de.entreg             AS saldo,
            abs(nvl(d.cantid, 0)) - de.entreg
        BULK COLLECT
        INTO v_table
        FROM
            documentos_det                                                           d
            LEFT OUTER JOIN pack_documentos_ent.sp_detalle_entrega(d.id_cia, d.numint, d.numite) de ON 0 = 0
        WHERE
                d.id_cia = pin_id_cia
            AND d.numint = pin_numint
            AND ( pin_numite <= 0
                  OR d.numite = pin_numite );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_saldo_documentos_det;

END;

/

--------------------------------------------------------
--  DDL for Package Body PACK_DOCUMENTOS_ENT_DEV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_DOCUMENTOS_ENT_DEV" AS

    PROCEDURE sp_eliminar (
        pin_id_cia    IN NUMBER,
        pin_orinumint IN NUMBER,
        pin_coduser   IN VARCHAR2,
        pin_mensaje   OUT VARCHAR2
    ) AS
        pout_mensaje VARCHAR2(1000) := '';
    BEGIN
        IF
            pin_orinumint IS NOT NULL
            AND pin_orinumint <> 0
        THEN
            DELETE FROM documentos_ent_dev
            WHERE
                    id_cia = pin_id_cia
                AND orinumint = pin_orinumint;

            COMMIT;
        END IF;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Success ...!'
            )
        INTO pin_mensaje
        FROM
            dual;

        RETURN;
    EXCEPTION
        WHEN pkg_exceptionuser.ex_error_inesperado THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pout_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN OTHERS THEN
            pin_mensaje := 'mensaje : '
                           || sqlerrm
                           || ' codigo :'
                           || sqlcode;
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pin_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

    END sp_eliminar;

    PROCEDURE sp_generar (
        pin_id_cia    IN NUMBER,
        pin_orinumint IN NUMBER,
        pin_coduser   IN VARCHAR2,
        pin_mensaje   OUT VARCHAR2
    ) AS
        pout_mensaje VARCHAR2(1000) := '';
    BEGIN
        IF
            pin_orinumint IS NOT NULL
            AND pin_orinumint <> 0
        THEN
            INSERT INTO documentos_ent_dev (
                id_cia,
                opnumdoc,
                opnumite,
                orinumint,
                orinumite,
                entreg,
                piezas
            )
                SELECT
                    c.id_cia,
                    CASE
                        WHEN c.opnumdoc = d.opnumdoc THEN
                            c.ordcomni
                        ELSE
                            CASE
                                WHEN d.opnumdoc IS NULL THEN
                                        0
                                ELSE
                                    d.opnumdoc
                            END
                    END,
                    CASE
                        WHEN d.opnumite IS NULL THEN
                            0
                        ELSE
                            d.opnumite
                    END,
                    d.numint,
                    d.numite,
                    d.cantid,
                    d.piezas
                FROM
                         documentos_det d
                    INNER JOIN documentos_cab c ON c.id_cia = d.id_cia
                                                   AND c.numint = d.numint
                WHERE
                        d.id_cia = pin_id_cia
                    AND d.numint = pin_orinumint
                    AND d.cantid > 0;

            COMMIT;
        END IF;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Success ...!'
            )
        INTO pin_mensaje
        FROM
            dual;

        RETURN;
    EXCEPTION
        WHEN pkg_exceptionuser.ex_error_inesperado THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pout_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN OTHERS THEN
            pin_mensaje := 'mensaje : '
                           || sqlerrm
                           || ' codigo :'
                           || sqlcode;
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pin_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

    END sp_generar;

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
                     documentos_ent_dev de
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

    FUNCTION sp_detalle_saldo (
        pin_id_cia  NUMBER,
        pin_numints VARCHAR2
    ) RETURN datatable_detalle_saldo
        PIPELINED
    AS

        v_table   datatable_detalle_saldo;
        v_entrega NUMERIC(16, 5) := 0;
        v_cantid  NUMERIC(16, 5) := 0;
    BEGIN
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
                                99
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
            ( nvl(d.cantid, 0) - de.entreg ),
            d.preuni,
            d.pordes1,
            d.pordes2,
            d.pordes3,
            d.pordes4,
            t.modpre,
            NULL     AS stock
        BULK COLLECT
        INTO v_table
        FROM
            documentos_det                                                           d
            LEFT OUTER JOIN documentos_cab                                                           c ON c.id_cia = d.id_cia
                                                AND c.numint = d.numint
            LEFT OUTER JOIN articulos                                                                a ON a.id_cia = d.id_cia
                                           AND a.tipinv = d.tipinv
                                           AND a.codart = d.codart
            LEFT OUTER JOIN cliente                                                                  cl ON cl.id_cia = c.id_cia
                                          AND cl.codcli = c.codcli
            LEFT OUTER JOIN titulolista                                                              t ON t.id_cia = cl.id_cia
                                             AND t.codtit = cl.codtit
            LEFT OUTER JOIN motivos_clase                                                            mt6 ON mt6.id_cia = c.id_cia
                                                 AND mt6.tipdoc = c.tipdoc
                                                 AND mt6.codmot = c.codmot
                                                 AND mt6.id = c.id
                                                 AND mt6.codigo = 6
--            LEFT OUTER JOIN sp000_saca_stock_costo_articulos_almacen(d.id_cia,
--                                                                     d.tipinv,
--                                                                     d.codalm,
--                                                                     d.codart,
--                                                                     EXTRACT(YEAR FROM current_date),
--                                                                     EXTRACT(MONTH FROM current_date),
--                                                                     EXTRACT(MONTH FROM current_date))                                        kk
--                                                                     ON 0 = 0
            LEFT OUTER JOIN pack_documentos_ent_dev.sp_detalle_entrega(d.id_cia, d.numint, d.numite) de ON 0 = 0
        WHERE
                c.id_cia = pin_id_cia
            AND c.numint IN (
                SELECT
                    regexp_substr(pin_numints, '[^,]+', 1, level)
                FROM
                    dual
                CONNECT BY
                    regexp_substr(pin_numints, '[^,]+', 1, level) IS NOT NULL
            )
            AND ( nvl(d.cantid, 0) - de.entreg ) <> 0
        ORDER BY
            d.numint,
            d.numite;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_detalle_saldo;

    FUNCTION sp_detalle_saldo_total (
        pin_id_cia  NUMBER,
        pin_numints VARCHAR2
    ) RETURN datatable_detalle_saldo
        PIPELINED
    AS

        v_table   datatable_detalle_saldo;
        v_entrega NUMERIC(16, 5) := 0;
        v_cantid  NUMERIC(16, 5) := 0;
    BEGIN
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
                                99
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
            ( nvl(d.cantid, 0) - de.entreg ),
            d.preuni,
            d.pordes1,
            d.pordes2,
            d.pordes3,
            d.pordes4,
            t.modpre,
            NULL     AS stock
        BULK COLLECT
        INTO v_table
        FROM
            documentos_det                                                           d
            LEFT OUTER JOIN documentos_cab                                                           c ON c.id_cia = d.id_cia
                                                AND c.numint = d.numint
            LEFT OUTER JOIN articulos                                                                a ON a.id_cia = d.id_cia
                                           AND a.tipinv = d.tipinv
                                           AND a.codart = d.codart
            LEFT OUTER JOIN cliente                                                                  cl ON cl.id_cia = c.id_cia
                                          AND cl.codcli = c.codcli
            LEFT OUTER JOIN titulolista                                                              t ON t.id_cia = cl.id_cia
                                             AND t.codtit = cl.codtit
            LEFT OUTER JOIN motivos_clase                                                            mt6 ON mt6.id_cia = c.id_cia
                                                 AND mt6.tipdoc = c.tipdoc
                                                 AND mt6.codmot = c.codmot
                                                 AND mt6.id = c.id
                                                 AND mt6.codigo = 6
--            LEFT OUTER JOIN sp000_saca_stock_costo_articulos_almacen(d.id_cia,
--                                                                     d.tipinv,
--                                                                     d.codalm,
--                                                                     d.codart,
--                                                                     EXTRACT(YEAR FROM current_date),
--                                                                     EXTRACT(MONTH FROM current_date),
--                                                                     EXTRACT(MONTH FROM current_date))                                        kk
--                                                                     ON 0 = 0
            LEFT OUTER JOIN pack_documentos_ent_dev.sp_detalle_entrega(d.id_cia, d.numint, d.numite) de ON 0 = 0
        WHERE
                c.id_cia = pin_id_cia
            AND c.numint IN (
                SELECT
                    regexp_substr(pin_numints, '[^,]+', 1, level)
                FROM
                    dual
                CONNECT BY
                    regexp_substr(pin_numints, '[^,]+', 1, level) IS NOT NULL
            )
--            AND c.numint IN (
--                SELECT
--                    *
--                FROM
--                    TABLE ( convert_in(pin_numints) )
--            )
        ORDER BY
            d.numint,
            d.numite;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_detalle_saldo_total;

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
            LEFT OUTER JOIN pack_documentos_ent_dev.sp_detalle_entrega(d.id_cia, d.numint, d.numite) de ON 0 = 0
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

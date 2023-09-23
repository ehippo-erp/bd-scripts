--------------------------------------------------------
--  DDL for Package Body PACK_ACTUALIZA_COSTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_ACTUALIZA_COSTO" AS

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_numint NUMBER
    ) RETURN datatable_buscar
        PIPELINED
    AS
        v_table datatable_buscar;
    BEGIN
        SELECT
            c.id_cia,
            c.tipdoc,
            c.numint,
            d.numite,
            c.series,
            c.numdoc,
            c.codcli,
            c.femisi,
            c.id,
            c.situac,
            c.presen                AS ncredito,
            c.observ,
            c.tipmon,
            c.tipcam,
            c.codmot,
            c.incigv,
            c.guipro,
            c.facpro,
            c.fguipro,
            c.ffacpro,
            d.tipinv,
            d.codalm,
            d.codart,
            a.descri                AS desart,
            d.cantid,
            ( a.faccon * d.cantid ) AS peso,
            a.coduni,
            d.preuni,
            d.pordes1,
            d.pordes2,
            d.pordes3,
            d.pordes4,
            d.codadd01,
            d.codadd02,
            cl1.descri              AS dcodadd01,
            cl2.descri              AS dcodadd02,
            d.opronumdoc,
            d.opnumite,
            d.etiqueta,
            d.importe_bruto,
            d.importe,
            d.porigv,
            d.monigv,
            d.monina,
            d.monisc,
            d.monexo,
            d.montgr,
            d.monafe,
            k.locali,
            k.numint,
            k.numite,
            k.costot01,
            k.costot02,
            CASE
                WHEN cp.numint IS NOT NULL
                     AND op.swacti = 1 THEN
                    'S'
                ELSE
                    'N'
            END                     AS liquidado
        BULK COLLECT
        INTO v_table
        FROM
                 documentos_cab c
            INNER JOIN documentos_det          d ON d.id_cia = c.id_cia
                                           AND d.numint = c.numint
            INNER JOIN documentos              ds ON ds.id_cia = c.id_cia
                                        AND ds.codigo = c.tipdoc
                                        AND ds.series = c.series
            INNER JOIN kardex                  k ON k.id_cia = c.id_cia
                                   AND k.numint = d.numint
                                   AND k.numite = d.numite
            INNER JOIN motivos                 m ON m.id_cia = c.id_cia
                                    AND m.tipdoc = k.tipdoc
                                    AND m.id = k.id
                                    AND m.codmot = k.codmot
                                    AND ( upper(m.costea) = 'N' )
            LEFT OUTER JOIN documentos_cab          cp ON cp.id_cia = c.id_cia
                                                 AND cp.numint = c.ordcomni
                                                 AND cp.tipdoc = 104
            LEFT OUTER JOIN documentos_det          op ON op.id_cia = c.id_cia
                                                 AND op.numint = cp.numint
                                                 AND op.numite = d.opnumite
            LEFT OUTER JOIN articulos               a ON a.id_cia = c.id_cia
                                           AND a.tipinv = d.tipinv
                                           AND a.codart = d.codart
            LEFT OUTER JOIN cliente_articulos_clase cl1 ON cl1.id_cia = c.id_cia
                                                           AND ( cl1.tipcli = 'B' )
                                                           AND ( cl1.codcli = a.codprv )
                                                           AND ( cl1.clase = 1 )
                                                           AND ( cl1.codigo = d.codadd01 )
            LEFT OUTER JOIN cliente_articulos_clase cl2 ON cl2.id_cia = c.id_cia
                                                           AND ( cl2.tipcli = 'B' )
                                                           AND ( cl2.codcli = a.codprv )
                                                           AND ( cl2.clase = 2 )
                                                           AND ( cl2.codigo = d.codadd02 )
        WHERE
                c.id_cia = pin_id_cia
            AND c.numint = pin_numint
            AND ( a.consto > 0 )
        ORDER BY
            c.tipdoc,
            c.series,
            d.numint,
            c.numdoc,
            d.numite;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

    END sp_buscar;

--set SERVEROUTPUT on;
--
--DECLARE
--    mensaje VARCHAR2(1000);
--    cadjson VARCHAR2(1000);
--BEGIN
--
--    cadjson := '{
--        "preuni":0.44,
--        "importe_bruto":2200,
--        "importe":2200,
--        "monafe":2200,
--        "monina":0,
--        "monigv":396
--    }';
--    pack_actualiza_costo.sp_update(66,100001,1,cadjson,mensaje);
--    DBMS_OUTPUT.PUT_LINE(mensaje);
--
--END;

    PROCEDURE sp_update (
        pin_id_cia  NUMBER,
        pin_numint  NUMBER,
        pin_numite  NUMBER,
        pin_datos   IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS

        o                  json_object_t;
        rec_documentos_det documentos_det%rowtype;
        v_tipmon           documentos_cab.tipmon%TYPE;
        v_tipcam           documentos_cab.tipcam%TYPE;
        v_costot01         kardex.costot01%TYPE;
        v_costot02         kardex.costot02%TYPE;
        v_accion           VARCHAR2(50) := '';
        pout_mensaje       VARCHAR2(1000) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_documentos_det.id_cia := pin_id_cia;
        rec_documentos_det.numint := pin_numint;
        rec_documentos_det.numite := pin_numite;
        rec_documentos_det.preuni := o.get_number('preuni');
        rec_documentos_det.importe_bruto := o.get_number('importe_bruto');
        rec_documentos_det.importe := o.get_number('importe');
        rec_documentos_det.monafe := o.get_number('monafe');
        rec_documentos_det.monina := o.get_number('monina');
        rec_documentos_det.monigv := o.get_number('monigv');
        BEGIN
            SELECT
                c.tipmon,
                c.tipcam
            INTO
                v_tipmon,
                v_tipcam
            FROM
                documentos_cab c
            WHERE
                    c.id_cia = pin_id_cia
                AND c.numint = rec_documentos_det.numint;

        EXCEPTION
            WHEN no_data_found THEN
                pout_mensaje := 'Error, el documento no Existe ...!';
                RAISE pkg_exceptionuser.ex_error_inesperado;
        END;

        UPDATE documentos_det
        SET
            preuni = rec_documentos_det.preuni,
            pordes1 = 0,
            pordes2 = 0,
            pordes3 = 0,
            pordes4 = 0,
            importe_bruto = rec_documentos_det.importe_bruto,
            importe = rec_documentos_det.importe,
            monafe = rec_documentos_det.monafe,
            monina = rec_documentos_det.monina,
            monigv = rec_documentos_det.monigv
        WHERE
                id_cia = pin_id_cia
            AND numint = rec_documentos_det.numint
            AND numite = rec_documentos_det.numite;

        IF v_tipmon = 'PEN' THEN
            v_costot01 := ( rec_documentos_det.monafe + rec_documentos_det.monina );
            v_costot02 := ( rec_documentos_det.monafe + rec_documentos_det.monina ) / v_tipcam;
        ELSE
            v_costot01 := ( rec_documentos_det.monafe + rec_documentos_det.monina ) * v_tipcam;
            v_costot02 := ( rec_documentos_det.monafe + rec_documentos_det.monina );
        END IF;

        UPDATE kardex
        SET
            costot01 = v_costot01,
            costot02 = v_costot02
        WHERE
                id_cia = pin_id_cia
            AND numint = rec_documentos_det.numint
            AND numite = rec_documentos_det.numite;

        COMMIT;
        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'La actualición de los costos se realizó satisfactoriamente...!'
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
        WHEN pkg_exceptionuser.ex_error_inesperado THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE pout_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

            ROLLBACK;
        WHEN value_error THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE 'El registro execede el limite permitido por el campo y/o se encuentra en un formato incorrecto'
                )
            INTO pin_mensaje
            FROM
                dual;

            ROLLBACK;
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

            ROLLBACK;
    END sp_update;

END;

/

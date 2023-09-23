--------------------------------------------------------
--  DDL for Package Body PACK_DOCUMENTOS_ENTREGA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_DOCUMENTOS_ENTREGA" AS

    PROCEDURE sp_update (
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS
        v_convert NUMBER := 1;
        v_res     NUMBER := 0;
    BEGIN
        SELECT
            gen_documentos_ent_respaldo.NEXTVAL
        INTO v_res
        FROM
            dual;

        -- BACKUP
        INSERT INTO documentos_ent_respaldo
            ( SELECT
                e.id_cia,
                v_res,
                e.opnumdoc,
                e.opnumite,
                e.orinumint,
                e.orinumite,
                e.entreg,
                e.piezas
            FROM
                documentos_ent e
                LEFT OUTER JOIN documentos_det d ON d.id_cia = e.id_cia
                                                    AND d.numint = e.orinumint
                                                    AND d.numite = e.orinumite
            WHERE
                    d.id_cia = pin_id_cia
                AND d.numint = pin_numint
            );

        -- ACTUALIZANDO COSTOS
        FOR i IN (
            SELECT
                e.id_cia,
                c.tipdoc,
                e.opnumdoc,
                e.opnumite,
                e.orinumint,
                e.orinumite,
                e.entreg,
                d.tipinv,
                d.codart,
                d.cantid,
                d.codund
            FROM
                     documentos_ent e
                INNER JOIN documentos_cab c ON c.id_cia = e.id_cia
                                               AND c.numint = e.orinumint
                INNER JOIN documentos_det d ON d.id_cia = e.id_cia
                                               AND d.numint = e.orinumint
                                               AND d.numite = e.orinumite
            WHERE
                    d.id_cia = pin_id_cia
                AND d.numint = pin_numint
        ) LOOP
            BEGIN
                SELECT
                    aca.vreal
                INTO v_convert
                FROM
                    articulos_clase_alternativo aca
                WHERE
                        aca.id_cia = i.id_cia
                    AND aca.tipinv = i.tipinv
                    AND aca.codart = i.codart
                    AND ( ( aca.clase = 1
                            AND i.tipdoc NOT IN ( 105, 115 ) )
                          OR ( aca.clase = 2
                               AND i.tipdoc IN ( 105, 115 ) ) )
                    AND aca.codigo = i.codund;

            EXCEPTION
                WHEN no_data_found THEN
                    v_convert := 1;
            END;

            UPDATE documentos_ent
            SET
                entreg = v_convert * i.cantid
            WHERE
                    id_cia = i.id_cia
                AND opnumdoc = i.opnumdoc
                AND opnumite = i.opnumite
                AND orinumint = i.orinumint
                AND orinumite = i.orinumite;

        END LOOP;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Success ...!'
            )
        INTO pin_mensaje
        FROM
            dual;

        COMMIT;
    EXCEPTION
        WHEN value_error THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE 'El registro execede el limite permitido por el campo y/o se encuentra en un formato incorrecto'
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

    END sp_update;

END;

/

--------------------------------------------------------
--  DDL for Package Body PACK_E_FINANCIERA_TIPO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_E_FINANCIERA_TIPO" AS

    FUNCTION sp_buscar (
        pin_id_cia IN NUMBER,
        pin_TipCta IN NUMBER,
        pin_descri IN VARCHAR2
    ) RETURN t_E_Financiera_Tipo
        PIPELINED
    IS
        v_table t_E_Financiera_Tipo;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            E_Financiera_Tipo
        WHERE
                id_cia = pin_id_cia
            AND ( ( pin_TipCta IS NULL )
                  OR ( TipCta = pin_TipCta ) )
            AND ( ( pin_descri IS NULL )
                  OR ( descri = pin_descri ) ) ;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar;
/*
set SERVEROUTPUT on;

DECLARE
    mensaje VARCHAR2(500);
    cadjson VARCHAR2(5000);
BEGIN
        cadjson := '{
            "TipCta":9,
            "descri":"demo"
        }';
        PACK_E_Financiera_Tipo.SP_SAVE(66,cadjson,1,mensaje);
        DBMS_OUTPUT.PUT_LINE(mensaje);
END;
SELECT *  FROM PACK_E_Financiera_Tipo.SP_BUSCAR(66,NULL,NULL);

*/
    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    ) IS
        o         json_object_t;
        rec_E_FINANCIERA_tipo E_Financiera_Tipo%rowtype;
        v_accion  VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_E_FINANCIERA_tipo.id_cia := pin_id_cia;
        rec_E_FINANCIERA_tipo.TipCta := o.get_number('TipCta');
        rec_E_FINANCIERA_tipo.descri := o.get_string('descri');

        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                INSERT INTO E_FINANCIERA_tipo (
                    id_cia,
                    TipCta,
                    descri
                ) VALUES (
                    rec_E_FINANCIERA_tipo.id_cia,
                    rec_E_FINANCIERA_tipo.TipCta,
                    rec_E_FINANCIERA_tipo.descri
                );

                COMMIT;
            WHEN 2 THEN
                v_accion := 'La actualización';
                UPDATE E_FINANCIERA_tipo
                SET
                    descri = rec_E_FINANCIERA_tipo.descri
                WHERE
                        id_cia = rec_E_FINANCIERA_tipo.id_cia
                    AND TipCta = rec_E_FINANCIERA_tipo.TipCta;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM E_FINANCIERA_tipo
                WHERE
                        id_cia = rec_E_FINANCIERA_tipo.id_cia
                    AND TipCta = rec_E_FINANCIERA_tipo.TipCta;

                COMMIT;
        END CASE;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE v_accion || ' se realizó satisfactoriamente...!'
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
         WHEN dup_val_on_index THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE 'El registro con tipo de cuenta de entidad financiera [ '
                                    || rec_E_FINANCIERA_tipo.TipCta
                                    || ' ] ya existe y no puede duplicarse ...!'
                )
            INTO pin_mensaje
            FROM
                dual;

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

    END sp_save;

END;

/

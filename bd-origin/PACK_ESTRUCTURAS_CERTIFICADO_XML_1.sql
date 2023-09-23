--------------------------------------------------------
--  DDL for Package Body PACK_ESTRUCTURAS_CERTIFICADO_XML
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_ESTRUCTURAS_CERTIFICADO_XML" AS

    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_item   NUMBER
    ) RETURN t_estructuras_certificado_xml
        PIPELINED
    AS
        v_table t_estructuras_certificado_xml;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            estructuras_certificado_xml
        WHERE
                id_cia = pin_id_cia
            AND item = pin_item;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_item   NUMBER,
        pin_descri VARCHAR2
    ) RETURN t_estructuras_certificado_xml
        PIPELINED
    IS
        v_table t_estructuras_certificado_xml;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            estructuras_certificado_xml
        WHERE
                id_cia = pin_id_cia
            AND ( item = pin_item
                  OR nvl(pin_item, - 1) = - 1 )
            AND ( upper(descri) LIKE '%'
                                     || upper(pin_descri)
                                     || '%'
                  OR pin_descri IS NULL );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar;

--set SERVEROUTPUT on;
--
--DECLARE
--    mensaje VARCHAR2(500);
--    cadjson VARCHAR2(5000);
--BEGIN
--cadjson := '{
--  "descri": "Descripción Prueba",
--  "agrupa": 1,
--  "xml": "<xml>Contenido del XML</xml>",
--  "swacti": "S"
--}';
--    pack_estructuras_certificado_xml.sp_save(66,NULL, cadjson, 1, mensaje);
--
--    dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_estructuras_certificado_xml.sp_obtener(66,1);
--
--SELECT * FROM pack_estructuras_certificado_xml.sp_buscar(66,NULL,NULL);

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_xml     IN BLOB,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    ) IS
        o                               json_object_t;
        rec_estructuras_certificado_xml estructuras_certificado_xml%rowtype;
        v_accion                        VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_estructuras_certificado_xml.id_cia := pin_id_cia;
        rec_estructuras_certificado_xml.item := o.get_number('item');
        rec_estructuras_certificado_xml.descri := o.get_string('descri');
        rec_estructuras_certificado_xml.agrupa := o.get_string('agrupa');
--        rec_estructuras_certificado_xml.xml := o.get_string('xml');
        rec_estructuras_certificado_xml.swacti := o.get_string('swacti');
        rec_estructuras_certificado_xml.ucreac := o.get_string('ucreac');
        rec_estructuras_certificado_xml.uactua := o.get_string('uactua');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                IF nvl(rec_estructuras_certificado_xml.item, 0) = 0 THEN
                    BEGIN
                        SELECT
                            item + 1
                        INTO rec_estructuras_certificado_xml.item
                        FROM
                            estructuras_certificado_xml
                        WHERE
                            id_cia = pin_id_cia
                        ORDER BY
                            item DESC
                        FETCH NEXT 1 ROWS ONLY;

                    EXCEPTION
                        WHEN no_data_found THEN
                            rec_estructuras_certificado_xml.item := 1;
                    END;
                END IF;

                INSERT INTO estructuras_certificado_xml (
                    id_cia,
                    item,
                    descri,
                    agrupa,
                    xml,
                    swacti,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_estructuras_certificado_xml.id_cia,
                    rec_estructuras_certificado_xml.item,
                    rec_estructuras_certificado_xml.descri,
                    rec_estructuras_certificado_xml.agrupa,
                    pin_xml,
                    rec_estructuras_certificado_xml.swacti,
                    rec_estructuras_certificado_xml.ucreac,
                    rec_estructuras_certificado_xml.uactua,
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS'),
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS')
                );

                COMMIT;
            WHEN 2 THEN
                v_accion := 'La actualización';
                UPDATE estructuras_certificado_xml
                SET
                    descri = rec_estructuras_certificado_xml.descri,
                    agrupa = rec_estructuras_certificado_xml.agrupa,
                    xml = pin_xml,
                    swacti = rec_estructuras_certificado_xml.swacti,
                    uactua = rec_estructuras_certificado_xml.uactua,
                    factua = TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
             'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_estructuras_certificado_xml.id_cia
                    AND item = rec_estructuras_certificado_xml.item;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM estructuras_certificado_xml
                WHERE
                        id_cia = rec_estructuras_certificado_xml.id_cia
                    AND item = rec_estructuras_certificado_xml.item;

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
                    'message' VALUE 'El registro con codigo de motivo planilla [ '
                                    || rec_estructuras_certificado_xml.item
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

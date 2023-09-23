--------------------------------------------------------
--  DDL for Package Body PACK_E_FINANCIERA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_E_FINANCIERA" AS

    FUNCTION sp_buscar (
        pin_id_cia IN NUMBER,
        pin_codigo IN NUMBER,
        pin_descri IN VARCHAR2,
		pin_situac IN VARCHAR2
    ) RETURN t_E_FINANCIERA
        PIPELINED
    IS
        v_table t_E_FINANCIERA;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            E_FINANCIERA
        WHERE
                id_cia = pin_id_cia
            AND ( ( pin_codigo IS NULL )
                  OR ( codigo = pin_codigo ) )
            AND ( ( pin_descri IS NULL )
                  OR ( descri = pin_descri ) )
			AND ( ( pin_situac IS NULL )
                  OR ( situac = pin_situac ) )	  ;

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
            "codigo":98,
            "descri":"demo",
			"situac":"N",
            "usuari":"admin"
        }';
        PACK_E_FINANCIERA.SP_SAVE(66,cadjson,2,mensaje);
        DBMS_OUTPUT.PUT_LINE(mensaje);
END;
SELECT *  FROM PACK_E_FINANCIERA.SP_BUSCAR(66,NULL,NULL,NULL);

*/
    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    ) IS
        o         json_object_t;
        rec_E_FINANCIERA E_FINANCIERA%rowtype;
        v_accion  VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_E_FINANCIERA.id_cia := pin_id_cia;
        rec_E_FINANCIERA.codigo := o.get_number('codigo');
        rec_E_FINANCIERA.descri := o.get_string('descri');
		rec_E_FINANCIERA.situac := o.get_string('situac');
        rec_E_FINANCIERA.usuari := o.get_string('usuari');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                INSERT INTO E_FINANCIERA (
                    id_cia,
                    codigo,
                    descri,
					situac,
                    usuari,
                    fcreac,
                    factua
                ) VALUES (
                    rec_E_FINANCIERA.id_cia,
                    rec_E_FINANCIERA.codigo,
                    rec_E_FINANCIERA.descri,
					rec_E_FINANCIERA.situac,
                    rec_E_FINANCIERA.usuari,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                );

                COMMIT;
            WHEN 2 THEN
                v_accion := 'La actualización';
                UPDATE E_FINANCIERA
                SET
                    descri = rec_E_FINANCIERA.descri,
					situac = rec_E_FINANCIERA.situac,
                    usuari = rec_E_FINANCIERA.usuari,
                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_E_FINANCIERA.id_cia
                    AND codigo = rec_E_FINANCIERA.codigo;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM E_FINANCIERA
                WHERE
                        id_cia = rec_E_FINANCIERA.id_cia
                    AND codigo = rec_E_FINANCIERA.codigo;

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
                    'message' VALUE 'El registro con codigo de entidad financiera [ '
                                    || rec_E_FINANCIERA.codigo
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

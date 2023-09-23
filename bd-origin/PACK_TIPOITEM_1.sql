--------------------------------------------------------
--  DDL for Package Body PACK_TIPOITEM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_TIPOITEM" AS

    FUNCTION sp_sel_tipoitem (
        pin_id_cia  IN  NUMBER,
        pin_codtip  IN  VARCHAR2,		
        pin_codite  IN  NUMBER,
        pin_nombre  IN  VARCHAR2
    ) RETURN t_tipoitem
        PIPELINED
    IS
        v_table t_tipoitem;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            tipoitem
        WHERE
                id_cia = pin_id_cia
            AND ( ( pin_codtip IS NULL )
                  OR ( codtip = pin_codtip ) )				
            AND ( ( pin_codite IS NULL )
                  OR ( codite = pin_codite ) )
            AND ( ( pin_nombre IS NULL )
                  OR ( nombre = pin_nombre ) );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        return;
    END sp_sel_tipoitem;

    PROCEDURE sp_save_tipoitem (
        pin_id_cia   IN   NUMBER,
        pin_datos    IN   VARCHAR2,
        pin_opcdml   INTEGER,
        pin_mensaje  OUT  VARCHAR2
    ) IS
        o             json_object_t;
        rec_tipoitem  tipoitem%rowtype;
        v_accion      VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_tipoitem.id_cia := pin_id_cia;
        rec_tipoitem.codtip := o.get_string('codtip');		
        rec_tipoitem.codite := o.get_number('codite');
        rec_tipoitem.nombre := o.get_string('nombre');
        rec_tipoitem.obliga := o.get_string('obliga');
        rec_tipoitem.ucreac := o.get_string('ucreac');
        rec_tipoitem.uactua := o.get_string('uactua');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                INSERT INTO tipoitem (
                    id_cia,
                    codtip,					
                    codite,
                    nombre,
                    obliga,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                    --imagen
                ) VALUES (
                    rec_tipoitem.id_cia,
                    rec_tipoitem.codtip,					
                    rec_tipoitem.codite,
                    rec_tipoitem.nombre,
                    rec_tipoitem.obliga,
                    rec_tipoitem.ucreac,
                    rec_tipoitem.uactua,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                );

                COMMIT;
            WHEN 2 THEN
                UPDATE tipoitem
                SET
                    nombre = rec_tipoitem.nombre,
                    obliga = rec_tipoitem.obliga,
                    uactua = rec_tipoitem.uactua,
                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_tipoitem.id_cia
					AND codtip = rec_tipoitem.codtip	
                    AND codite = rec_tipoitem.codite;


                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM tipoitem
                WHERE
                        id_cia = rec_tipoitem.id_cia
					AND codtip = rec_tipoitem.codtip	
                    AND codite = rec_tipoitem.codite;

                COMMIT;
        END CASE;

        SELECT
            JSON_OBJECT (
                'status' VALUE 1.0,
                'message' VALUE v_accion || ' se realizó satisfactoriamente'
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
        WHEN dup_val_on_index THEN
            SELECT
                JSON_OBJECT (
                    'status' VALUE 1.1,
                    'message' VALUE 'El registro con codigo item [ '
                                    || rec_tipoitem.codite
                                    || ' ] ya existe y no puede duplicarse ...!'
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN value_error THEN
            SELECT
                JSON_OBJECT (
                    'status' VALUE 1.2,
                    'message' VALUE 'El registro execede el limite permitido por el campo y/o se encuentra en un formato incorrecto'
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN OTHERS THEN
            IF sqlcode = -2292 THEN
                SELECT
                    JSON_OBJECT (
                        'status' VALUE 1.2,
                        'message' VALUE 'No es posible eliminar el codigo de item['
                                        || rec_tipoitem.codite
                                        || '] por restricción de integridad'
                    )
                INTO pin_mensaje
                FROM
                    dual;

            ELSE
                pin_mensaje := 'mensaje : '
                               || sqlerrm
                               || ' codigo :'
                               || sqlcode;
                SELECT
                    JSON_OBJECT (
                        'status' VALUE 1.2,
                        'message' VALUE pin_mensaje
                    )
                INTO pin_mensaje
                FROM
                    dual;

            END IF;
    END;

END;

/

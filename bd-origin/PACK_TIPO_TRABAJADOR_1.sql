--------------------------------------------------------
--  DDL for Package Body PACK_TIPO_TRABAJADOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_TIPO_TRABAJADOR" AS

    FUNCTION sp_sel_tipo_trabajador (
        pin_id_cia IN NUMBER,
        pin_tiptra IN VARCHAR2,
        pin_nombre IN VARCHAR2
    ) RETURN t_tipo_trabajador
        PIPELINED
    IS
        v_table t_tipo_trabajador;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            tipo_trabajador
        WHERE
                id_cia = pin_id_cia
            AND ( ( pin_tiptra IS NULL )
                  OR ( tiptra = pin_tiptra ) )
            AND ( ( pin_nombre IS NULL )
                  OR ( nombre = pin_nombre ) );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_sel_tipo_trabajador;

    PROCEDURE sp_save_tipo_trabajador (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    ) IS
        o                   json_object_t;
        rec_tipo_trabajador tipo_trabajador%rowtype;
        v_accion            VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_tipo_trabajador.id_cia := pin_id_cia;
        rec_tipo_trabajador.tiptra := o.get_string('tiptra');
        rec_tipo_trabajador.nombre := o.get_string('nombre');
        rec_tipo_trabajador.noper := o.get_string('noper');
        rec_tipo_trabajador.conpre := o.get_string('conpre');
        rec_tipo_trabajador.cuenta := o.get_string('cuenta');
        rec_tipo_trabajador.libro := o.get_string('libro');
        rec_tipo_trabajador.conred := o.get_string('conred');
        rec_tipo_trabajador.ucreac := o.get_string('ucreac');
        rec_tipo_trabajador.uactua := o.get_string('uactua');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                INSERT INTO tipo_trabajador (
                    id_cia,
                    tiptra,
                    nombre,
                    noper,
                    conpre,
                    cuenta,
                    libro,
                    conred,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_tipo_trabajador.id_cia,
                    rec_tipo_trabajador.tiptra,
                    rec_tipo_trabajador.nombre,
                    rec_tipo_trabajador.noper,
                    rec_tipo_trabajador.conpre,
                    rec_tipo_trabajador.cuenta,
                    rec_tipo_trabajador.libro,
                    rec_tipo_trabajador.conred,
                    rec_tipo_trabajador.ucreac,
                    rec_tipo_trabajador.uactua,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                );

                COMMIT;
            WHEN 2 THEN
                UPDATE tipo_trabajador
                SET
                    nombre = rec_tipo_trabajador.nombre,
                    noper = rec_tipo_trabajador.noper,
                    conpre = rec_tipo_trabajador.conpre,
                    cuenta = rec_tipo_trabajador.cuenta,
                    libro = rec_tipo_trabajador.libro,
                    conred = rec_tipo_trabajador.conred,
                    uactua = rec_tipo_trabajador.uactua,
                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_tipo_trabajador.id_cia
                    AND tiptra = rec_tipo_trabajador.tiptra;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM tipo_trabajador
                WHERE
                        id_cia = rec_tipo_trabajador.id_cia
                    AND tiptra = rec_tipo_trabajador.tiptra;

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
                    'message' VALUE 'El registro con codigo del tipo de trabajador [ '
                                    || rec_tipo_trabajador.tiptra
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

    END;

END;

/

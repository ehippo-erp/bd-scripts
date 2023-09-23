--------------------------------------------------------
--  DDL for Package Body PACK_HR_MOTIVO_PLANILLA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_HR_MOTIVO_PLANILLA" AS

    FUNCTION sp_tipo (
        pin_id_cia IN NUMBER,
        pin_tipo   IN VARCHAR2
    ) RETURN t_motivo_planilla
        PIPELINED
    AS
        v_table t_motivo_planilla;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            motivo_planilla
        WHERE
                id_cia = pin_id_cia
            AND ( pin_tipo IS NULL
                  OR tipo = pin_tipo );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_tipo;

    FUNCTION sp_buscar (
        pin_id_cia IN NUMBER,
        pin_codmot IN INTEGER,
        pin_descri IN VARCHAR2
    ) RETURN t_motivo_planilla
        PIPELINED
    IS
        v_table t_motivo_planilla;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            motivo_planilla
        WHERE
                id_cia = pin_id_cia
            AND ( ( pin_codmot IS NULL )
                  OR ( codmot = pin_codmot ) )
            AND ( ( pin_descri IS NULL )
                  OR ( descri = pin_descri ) );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    ) IS
        o                   json_object_t;
        rec_motivo_planilla motivo_planilla%rowtype;
        v_accion            VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_motivo_planilla.id_cia := pin_id_cia;
        rec_motivo_planilla.codmot := o.get_number('codmot');
        rec_motivo_planilla.descri := o.get_string('descri');
        rec_motivo_planilla.permite := o.get_string('permite');
        rec_motivo_planilla.codrel := o.get_string('codrel');
        rec_motivo_planilla.tipo := o.get_string('tipo');
        rec_motivo_planilla.pagado := o.get_string('pagado');
        rec_motivo_planilla.ucreac := o.get_string('ucreac');
        rec_motivo_planilla.uactua := o.get_string('uactua');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                INSERT INTO motivo_planilla (
                    id_cia,
                    codmot,
                    descri,
                    permite,
                    codrel,
                    tipo,
                    pagado,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_motivo_planilla.id_cia,
                    rec_motivo_planilla.codmot,
                    rec_motivo_planilla.descri,
                    rec_motivo_planilla.permite,
                    rec_motivo_planilla.codrel,
                    rec_motivo_planilla.tipo,
                    rec_motivo_planilla.pagado,
                    rec_motivo_planilla.ucreac,
                    rec_motivo_planilla.uactua,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                );

                COMMIT;
            WHEN 2 THEN
                v_accion := 'La actualización';
                UPDATE motivo_planilla
                SET
                    descri = rec_motivo_planilla.descri,
                    permite = rec_motivo_planilla.permite,
                    codrel = rec_motivo_planilla.codrel,
                    tipo = rec_motivo_planilla.tipo,
                    pagado = rec_motivo_planilla.pagado,
                    uactua = rec_motivo_planilla.uactua,
                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_motivo_planilla.id_cia
                    AND codmot = rec_motivo_planilla.codmot;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM motivo_planilla
                WHERE
                        id_cia = rec_motivo_planilla.id_cia
                    AND codmot = rec_motivo_planilla.codmot;

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
                                    || rec_motivo_planilla.codmot
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

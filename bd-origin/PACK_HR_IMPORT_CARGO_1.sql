--------------------------------------------------------
--  DDL for Package Body PACK_HR_IMPORT_CARGO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_HR_IMPORT_CARGO" AS

    FUNCTION sp_valida_objeto (
        pin_id_cia IN NUMBER,
        pin_datos  IN CLOB
    ) RETURN datatable
        PIPELINED
    AS

        reg_errores r_errores := r_errores(NULL, NULL, NULL, NULL);
        fila        NUMBER := 3;
        o           json_object_t;
        rec_cargo   cargo%rowtype;
        v_aux       NUMBER := 0;
        v_char      VARCHAR2(1 CHAR);
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_cargo.id_cia := pin_id_cia;
        rec_cargo.codcar := o.get_string('codcar');
        rec_cargo.nombre := o.get_string('nombre');
        reg_errores.orden := rec_cargo.codcar;
        reg_errores.concepto := rec_cargo.nombre;
        BEGIN
            SELECT
                'S'
            INTO v_char
            FROM
                dual
            WHERE
                NOT EXISTS (
                    SELECT
                        *
                    FROM
                        cargo c
                    WHERE
                            c.id_cia = pin_id_cia
                        AND c.codcar = rec_cargo.codcar
                );

        EXCEPTION
            WHEN no_data_found THEN
                reg_errores.valor := rec_cargo.codcar;
                reg_errores.deserror := 'YA EXISTE UN CARGO REGISTRADO CON ESTE CODIGO';
                PIPE ROW ( reg_errores );
        END;

    END sp_valida_objeto;

    PROCEDURE sp_importar (
        pin_id_cia  IN NUMBER,
        pin_datos   IN CLOB,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS
        o         json_object_t;
        rec_cargo cargo%rowtype;
        v_number  NUMBER := 0;
    BEGIN
        v_number := extract(MONTH FROM current_timestamp);
        o := json_object_t.parse(pin_datos);
        o := json_object_t.parse(pin_datos);
        rec_cargo.id_cia := pin_id_cia;
        rec_cargo.codcar := o.get_string('codcar');
        rec_cargo.nombre := o.get_string('nombre');
        rec_cargo.ucreac := pin_coduser;
        rec_cargo.uactua := pin_coduser;
        rec_cargo.fcreac := TO_TIMESTAMP ( to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS' );
        rec_cargo.factua := TO_TIMESTAMP ( to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS' );
        -- INSERTANDO CARGO
        INSERT INTO cargo (
            id_cia,
            codcar,
            nombre,
            ucreac,
            uactua,
            fcreac,
            factua
        ) VALUES (
            rec_cargo.id_cia,
            rec_cargo.codcar,
            rec_cargo.nombre,
            rec_cargo.ucreac,
            rec_cargo.uactua,
            rec_cargo.fcreac,
            rec_cargo.factua
        );

        COMMIT;
        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'El proceso completó correctamente.'
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
        WHEN dup_val_on_index THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE 'pk...!'
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
    END sp_importar;

END;

/

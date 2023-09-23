--------------------------------------------------------
--  DDL for Package Body PACK_IMPORT_CLIENTECONTACTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_IMPORT_CLIENTECONTACTO" AS

    FUNCTION sp_valida_objeto (
        pin_id_cia IN NUMBER,
        pin_datos  IN CLOB
    ) RETURN datatable
        PIPELINED
    AS

        reg_errores         r_errores := r_errores(NULL, NULL);
        fila                NUMBER := 3;
        o                   json_object_t;
        rec_contacto        contacto%rowtype;
        rec_clientecontacto clientecontacto%rowtype;
        v_aux               NUMBER := 0;
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_clientecontacto.id_cia := pin_id_cia;
        rec_clientecontacto.codcli := o.get_string('codcli');
        rec_contacto.dident := o.get_string('dident');
        -- NO EXISTE EL CLIENTE
        BEGIN
            SELECT
                1
            INTO v_aux
            FROM
                cliente t
            WHERE
                    t.id_cia = pin_id_cia
                AND t.codcli = rec_clientecontacto.codcli;

        EXCEPTION
            WHEN no_data_found THEN
                v_aux := 0;
                reg_errores.valor := rec_clientecontacto.codcli;
                reg_errores.deserror := 'El CLIENTE [ '
                                        || rec_clientecontacto.codcli
                                        || ' ] NO EXISTE!';
                PIPE ROW ( reg_errores );
        END;
        -- EL CLIENTE YA TIENE EL CONTACTO ASOCIADO CON ESE DOCUMENTO IDENTIDAD
        BEGIN
            SELECT
                1
            INTO v_aux
            FROM
                contacto t
            WHERE
                    t.id_cia = pin_id_cia
                AND t.dident = rec_contacto.dident
                AND EXISTS (
                    SELECT
                        cc.*
                    FROM
                        clientecontacto cc
                    WHERE
                            cc.id_cia = t.id_cia
                        AND cc.codcli = rec_clientecontacto.codcli
                        AND cc.codcont = t.codcont
                );

        EXCEPTION
            WHEN no_data_found THEN
                v_aux := 0;
        END;

        IF v_aux = 1 THEN
            reg_errores.valor := rec_clientecontacto.codcli;
            reg_errores.deserror := 'El CLIENTE [ '
                                    || rec_clientecontacto.codcli
                                    || ' ] YA TIENE ASIGNADO UN CONTACTO CON EL DOCUMENTO IDENTIDAD [ '
                                    || rec_contacto.dident
                                    || ' ]';

            PIPE ROW ( reg_errores );
        END IF;

    END;

    PROCEDURE sp_importar (
        pin_id_cia  IN NUMBER,
        pin_datos   IN CLOB,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS

        o                   json_object_t;
        rec_contacto        contacto%rowtype;
        rec_clientecontacto clientecontacto%rowtype;
        v_aux               VARCHAR2(1 CHAR);
        v_codcont           clientecontacto.codcont%TYPE;
    BEGIN
        o := json_object_t.parse(pin_datos);

    -- INSERTANDO CONTACTO
        rec_contacto.id_cia := pin_id_cia;
        BEGIN
            SELECT
                nvl(MAX(nvl(codcont, 0)),
                    0)
            INTO rec_contacto.codcont
            FROM
                contacto
            WHERE
                id_cia = rec_contacto.id_cia;

        EXCEPTION
            WHEN no_data_found THEN
                rec_contacto.codcont := 0;
        END;

        rec_contacto.codcont := rec_contacto.codcont + 1;
        rec_contacto.nomcont := o.get_string('nomcont');
        rec_contacto.direccion := o.get_string('direccion');
        rec_contacto.email := o.get_string('email');
        rec_contacto.telefono := o.get_string('telefono');
        rec_contacto.hobby := o.get_string('hobby');
        rec_contacto.cargo := o.get_string('cargo');
        rec_contacto.observacion := o.get_string('observacion');
        rec_contacto.dident := o.get_string('dident');

    -- INSERTANDO CLIENTE
        rec_clientecontacto.id_cia := pin_id_cia;
        rec_clientecontacto.codcli := o.get_string('codcli');
        rec_clientecontacto.codcont := rec_contacto.codcont;
        IF rec_contacto.dident IS NOT NULL THEN
            BEGIN
                SELECT
                    codcont
                INTO v_codcont
                FROM
                    contacto
                WHERE
                        id_cia = rec_contacto.id_cia
                    AND dident = rec_contacto.dident;

                rec_clientecontacto.codcont := v_codcont;
            EXCEPTION
                WHEN no_data_found THEN
                    INSERT INTO contacto (
                        id_cia,
                        codcont,
                        nomcont,
                        direccion,
                        email,
                        telefono,
                        hobby,
                        palabraclave,
                        observacion,
                        cargo,
                        fcreac,
                        factua,
                        usuari,
                        swacti,
                        dident
                    ) VALUES (
                        rec_contacto.id_cia,
                        rec_contacto.codcont,
                        rec_contacto.nomcont,
                        rec_contacto.direccion,
                        rec_contacto.email,
                        rec_contacto.telefono,
                        rec_contacto.hobby,
                        rec_contacto.palabraclave,
                        rec_contacto.observacion,
                        rec_contacto.cargo,
                        TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                     'YYYY-MM-DD HH24:MI:SS'),
                        TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                     'YYYY-MM-DD HH24:MI:SS'),
                        pin_coduser,
                        'S',
                        rec_contacto.dident
                    );

            END;
        ELSE
            INSERT INTO contacto (
                id_cia,
                codcont,
                nomcont,
                direccion,
                email,
                telefono,
                hobby,
                palabraclave,
                observacion,
                cargo,
                fcreac,
                factua,
                usuari,
                swacti,
                dident
            ) VALUES (
                rec_contacto.id_cia,
                rec_contacto.codcont,
                rec_contacto.nomcont,
                rec_contacto.direccion,
                rec_contacto.email,
                rec_contacto.telefono,
                rec_contacto.hobby,
                rec_contacto.palabraclave,
                rec_contacto.observacion,
                rec_contacto.cargo,
                TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                             'YYYY-MM-DD HH24:MI:SS'),
                TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                             'YYYY-MM-DD HH24:MI:SS'),
                pin_coduser,
                'S',
                rec_contacto.dident
            );

        END IF;

        INSERT INTO clientecontacto (
            id_cia,
            codcli,
            codcont,
            fcreac,
            factua,
            usuari,
            swacti
        ) VALUES (
            rec_clientecontacto.id_cia,
            rec_clientecontacto.codcli,
            rec_clientecontacto.codcont,
            TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                         'YYYY-MM-DD HH24:MI:SS'),
            TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                         'YYYY-MM-DD HH24:MI:SS'),
            pin_coduser,
            'S'
        );

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
        WHEN dup_val_on_index THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE 'El registro con CODIGO DE CLIENTE [ '
                                    || rec_clientecontacto.codcli
                                    || ' ] y CONTACTO [ '
                                    || rec_clientecontacto.codcont
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
            IF sqlcode = -2291 THEN
                SELECT
                    JSON_OBJECT(
                        'status' VALUE 1.1,
                        'message' VALUE 'No se INSERTAR O MODIFICAR este registro porque el CLIENTE [ '
                                        || rec_clientecontacto.codcli
                                        || ' ] NO EXISTE'
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
                    JSON_OBJECT(
                        'status' VALUE 1.2,
                        'message' VALUE pin_mensaje
                    )
                INTO pin_mensaje
                FROM
                    dual;

            END IF;
    END sp_importar;

END;

/

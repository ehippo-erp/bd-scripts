--------------------------------------------------------
--  DDL for Package Body PACK_IMPORT_CLIENTE_CLASE_CODIGO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_IMPORT_CLIENTE_CLASE_CODIGO" AS

    FUNCTION sp_exportar (
        pin_id_cia IN NUMBER,
        pin_tipcli IN VARCHAR2,
        pin_clase  IN NUMBER,
        pin_inccla IN VARCHAR2
    ) RETURN datatable_exportar
        PIPELINED
    AS
        v_table datatable_exportar;
    BEGIN
        IF nvl(pin_inccla, 'N') = 'N' THEN
            SELECT
                a.id_cia,
                cc.tipcli,
                a.codcli,
                a.razonc,
                pin_clase,
                ac.codigo
            BULK COLLECT
            INTO v_table
            FROM
                     cliente a
                INNER JOIN cliente_clase cc ON cc.id_cia = a.id_cia
                                               AND cc.tipcli = pin_tipcli
                                               AND cc.codcli = a.codcli
                                               AND cc.clase = 1
                LEFT OUTER JOIN cliente_clase ac ON ac.id_cia = a.id_cia
                                                    AND ac.tipcli = a.tipcli
                                                    AND ac.codcli = a.codcli
                                                    AND ac.clase = pin_clase
            WHERE
                    a.id_cia = pin_id_cia
                AND cc.tipcli = pin_tipcli
            ORDER BY
                a.codcli;

        ELSE
            SELECT
                a.id_cia,
                cc.tipcli,
                a.codcli,
                a.razonc,
                pin_clase,
                ac.codigo
            BULK COLLECT
            INTO v_table
            FROM
                     cliente a
                INNER JOIN cliente_clase cc ON cc.id_cia = a.id_cia
                                               AND cc.tipcli = pin_tipcli
                                               AND cc.codcli = a.codcli
                                               AND cc.clase = 1
                LEFT OUTER JOIN cliente_clase ac ON ac.id_cia = a.id_cia
                                                    AND ac.tipcli = a.tipcli
                                                    AND ac.codcli = a.codcli
                                                    AND ac.clase = pin_clase
            WHERE
                    a.id_cia = pin_id_cia
                AND cc.tipcli = pin_tipcli
                AND NOT EXISTS (
                    SELECT
                        ac1.*
                    FROM
                        cliente_clase ac1
                    WHERE
                            ac1.id_cia = a.id_cia
                        AND ac1.tipcli = a.tipcli
                        AND ac1.codcli = a.codcli
                        AND ac1.clase = pin_clase
                        AND ac1.codigo NOT IN ( 'ND' )
                )
            ORDER BY
                a.codcli;

        END IF;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_exportar;

    FUNCTION sp_valida_objeto (
        pin_id_cia IN NUMBER,
        pin_datos  IN CLOB
    ) RETURN datatable
        PIPELINED
    AS

        reg_errores       r_errores := r_errores(NULL, NULL, NULL, NULL);
        fila              NUMBER := 3;
        o                 json_object_t;
        rec_cliente       cliente%rowtype;
        rec_cliente_clase cliente_clase%rowtype;
        v_aux             NUMBER := 0;
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_cliente.id_cia := pin_id_cia;
        rec_cliente_clase.tipcli := o.get_string('tipcli');
        rec_cliente.codcli := o.get_string('codcli');
        rec_cliente.razonc := o.get_string('razonc');
        rec_cliente_clase.clase := o.get_number('clase');
        rec_cliente_clase.codigo := o.get_string('codigo');
        reg_errores.orden := rec_cliente.codcli;
        reg_errores.concepto := rec_cliente.razonc;
        BEGIN
            SELECT
                razonc
            INTO reg_errores.concepto
            FROM
                cliente p
            WHERE
                    p.id_cia = pin_id_cia
                AND p.codcli = rec_cliente.codcli;

        EXCEPTION
            WHEN no_data_found THEN
                reg_errores.valor := rec_cliente.codcli;
                IF rec_cliente_clase.tipcli = 'A' THEN
                    reg_errores.deserror := 'CODIGO DEL CLIENTE NO VALIDO';
                ELSE
                    reg_errores.deserror := 'CODIGO DEL PROVEEDOR NO VALIDO';
                END IF;

                PIPE ROW ( reg_errores );
        END;

        BEGIN
            SELECT
                0
            INTO v_aux
            FROM
                clase_cliente p
            WHERE
                    p.id_cia = pin_id_cia
                AND p.tipcli = rec_cliente_clase.tipcli
                AND p.clase = rec_cliente_clase.clase;

        EXCEPTION
            WHEN no_data_found THEN
                reg_errores.valor := rec_cliente_clase.clase;
                IF rec_cliente_clase.tipcli = 'A' THEN
                    reg_errores.deserror := 'CLASE DEL CLIENTE NO DEFINIDA';
                ELSE
                    reg_errores.deserror := 'CLASE DEL PROVEEDOR NO DEFINIDA';
                END IF;

                PIPE ROW ( reg_errores );
        END;

        BEGIN
            SELECT
                0
            INTO v_aux
            FROM
                clase_cliente_codigo p
            WHERE
                    p.id_cia = pin_id_cia
                AND p.tipcli = rec_cliente_clase.tipcli
                AND p.clase = rec_cliente_clase.clase
                AND p.codigo = nvl(rec_cliente_clase.codigo, 'ND');

        EXCEPTION
            WHEN no_data_found THEN
                reg_errores.valor := nvl(rec_cliente_clase.codigo, 'ND');
                IF rec_cliente_clase.tipcli = 'A' THEN
                    reg_errores.deserror := 'EL CODIGO ASOCIADO A LA CLASE [ '
                                            || rec_cliente_clase.clase
                                            || ' ] NO DEFINIDO';
                ELSE
                    reg_errores.deserror := 'EL CODIGO ASOCIADO A LA CLASE [ '
                                            || rec_cliente_clase.clase
                                            || ' ] NO DEFINIDO';
                END IF;

                PIPE ROW ( reg_errores );
        END;

    END sp_valida_objeto;

    PROCEDURE sp_importa (
        pin_id_cia  IN NUMBER,
        pin_datos   IN CLOB,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS

        o                 json_object_t;
        rec_cliente       cliente%rowtype;
        rec_cliente_clase cliente_clase%rowtype;
        m                 json_object_t;
        pout_mensaje      VARCHAR2(1000 CHAR);
        v_mensaje         VARCHAR2(1000 CHAR);
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_cliente.id_cia := pin_id_cia;
        rec_cliente_clase.tipcli := o.get_string('tipcli');
        rec_cliente.codcli := o.get_string('codcli');
        rec_cliente.razonc := o.get_string('razonc');
        rec_cliente_clase.clase := o.get_number('clase');
        rec_cliente_clase.codigo := nvl(o.get_string('codigo'), 'ND');
        MERGE INTO cliente_clase ac
        USING dual ddd ON ( ac.id_cia = rec_cliente.id_cia
                            AND ac.tipcli = rec_cliente_clase.tipcli
                            AND ac.codcli = rec_cliente.codcli
                            AND ac.clase = rec_cliente_clase.clase )
        WHEN MATCHED THEN UPDATE
        SET codigo = rec_cliente_clase.codigo,
            situac = 'S'
        WHERE
                id_cia = rec_cliente.id_cia
            AND tipcli = rec_cliente_clase.tipcli
            AND codcli = rec_cliente.codcli
            AND clase = rec_cliente_clase.clase
        WHEN NOT MATCHED THEN
        INSERT (
            id_cia,
            tipcli,
            codcli,
            clase,
            codigo,
            situac )
        VALUES
            ( rec_cliente.id_cia,
              rec_cliente_clase.tipcli,
              rec_cliente.codcli,
              rec_cliente_clase.clase,
              rec_cliente_clase.codigo,
            'S' );

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
        WHEN pkg_exceptionuser.ex_error_inesperado THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pout_mensaje
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
    END sp_importa;

END;

/

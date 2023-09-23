--------------------------------------------------------
--  DDL for Package Body PACK_HR_IMPORT_PERSONAL_CLASE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_HR_IMPORT_PERSONAL_CLASE" AS

    FUNCTION sp_exportar (
        pin_id_cia IN NUMBER,
        pin_tiptra IN VARCHAR2,
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
                a.tiptra,
                a.codper,
                a.apepat
                || ' '
                || a.apemat
                || ', '
                || a.nombre,
                pin_clase,
                ac.codigo
            BULK COLLECT
            INTO v_table
            FROM
                personal       a
                LEFT OUTER JOIN personal_clase ac ON ac.id_cia = a.id_cia
                                                     AND ac.codper = a.codper
                                                     AND ac.clase = pin_clase
            WHERE
                    a.id_cia = pin_id_cia
                AND a.tiptra = pin_tiptra;

        ELSE
            SELECT
                a.id_cia,
                a.tiptra,
                a.codper,
                a.apepat
                || ' '
                || a.apemat
                || ', '
                || a.nombre,
                pin_clase,
                ac.codigo
            BULK COLLECT
            INTO v_table
            FROM
                personal       a
                LEFT OUTER JOIN personal_clase ac ON ac.id_cia = a.id_cia
                                                     AND ac.codper = a.codper
                                                     AND ac.clase = pin_clase
            WHERE
                    a.id_cia = pin_id_cia
                AND a.tiptra = pin_tiptra
                AND NOT EXISTS (
                    SELECT
                        ac1.*
                    FROM
                        personal_clase ac1
                    WHERE
                            ac1.id_cia = a.id_cia
                        AND ac1.codper = a.codper
                        AND ac1.clase = pin_clase
                );

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

        reg_errores        r_errores := r_errores(NULL, NULL, NULL, NULL);
        fila               NUMBER := 3;
        o                  json_object_t;
        rec_personal       personal%rowtype;
        rec_personal_clase personal_clase%rowtype;
        v_nomper           VARCHAR2(2000 CHAR);
        v_aux              NUMBER := 0;
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_personal.id_cia := pin_id_cia;
        rec_personal.tiptra := o.get_string('tiptra');
        rec_personal.codper := o.get_string('codper');
        v_nomper := o.get_string('nomper');
        rec_personal_clase.clase := o.get_string('clase');
        rec_personal_clase.codigo := o.get_string('codigo');
        reg_errores.orden := rec_personal.codper;
        reg_errores.concepto := v_nomper;
        BEGIN
            SELECT
                p.apepat
                || ' '
                || p.apemat
                || ', '
                || p.nombre
            INTO reg_errores.concepto
            FROM
                personal p
            WHERE
                    p.id_cia = pin_id_cia
                AND p.tiptra = rec_personal.tiptra
                AND p.codper = rec_personal.codper;

        EXCEPTION
            WHEN no_data_found THEN
                reg_errores.valor := rec_personal.tiptra
                                     || ' - '
                                     || rec_personal.codper;
                reg_errores.deserror := 'EL PERSONAL INGRESADO NO EXISTE!';
                PIPE ROW ( reg_errores );
        END;

        BEGIN
            SELECT
                0
            INTO v_aux
            FROM
                clase_codigo p
            WHERE
                    p.id_cia = pin_id_cia
                AND p.clase = rec_personal_clase.clase
                AND p.codigo = rec_personal_clase.codigo;

        EXCEPTION
            WHEN no_data_found THEN
                reg_errores.valor := rec_personal_clase.codigo;
                reg_errores.deserror := 'EL CODIGO ASIGNADO A LA CLASE NO EXISTE!';
                PIPE ROW ( reg_errores );
        END;

    END sp_valida_objeto;

    PROCEDURE sp_importar (
        pin_id_cia  IN NUMBER,
        pin_datos   IN CLOB,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS

        o                  json_object_t;
        rec_personal       personal%rowtype;
        rec_personal_clase personal_clase%rowtype;
        m                  json_object_t;
        pout_mensaje       VARCHAR2(1000 CHAR);
        v_mensaje          VARCHAR2(1000 CHAR);
        v_nomber           VARCHAR(2000 CHAR);
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_personal.id_cia := pin_id_cia;
        rec_personal.tiptra := o.get_string('tiptra');
        rec_personal.codper := o.get_string('codper');
        v_nomber := o.get_string('nomper');
        rec_personal_clase.clase := o.get_string('clase');
        rec_personal_clase.codigo := o.get_string('codigo');
        MERGE INTO personal_clase ac
        USING dual ddd ON ( ac.id_cia = rec_personal.id_cia
                            AND ac.codper = rec_personal.codper
                            AND ac.clase = rec_personal_clase.clase )
        WHEN MATCHED THEN UPDATE
        SET codigo = rec_personal_clase.codigo,
            situac = 'S'
        WHERE
                id_cia = rec_personal.id_cia
            AND codper = rec_personal.codper
            AND clase = rec_personal_clase.clase
        WHEN NOT MATCHED THEN
        INSERT (
            id_cia,
            codper,
            clase,
            codigo,
            situac )
        VALUES
            ( rec_personal.id_cia,
              rec_personal.codper,
              rec_personal_clase.clase,
              rec_personal_clase.codigo,
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

--            ROLLBACK;
        WHEN OTHERS THEN
            pin_mensaje := 'personal : '
                           || rec_personal.tiptra
                           || ' mensaje : '
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

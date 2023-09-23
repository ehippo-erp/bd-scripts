--------------------------------------------------------
--  DDL for Package Body PACK_IMPORT_ARTICULO_CLASE_CODIGO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_IMPORT_ARTICULO_CLASE_CODIGO" AS

    FUNCTION sp_exportar (
        pin_id_cia IN NUMBER,
        pin_tipinv IN NUMBER,
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
                a.tipinv,
                a.codart,
                a.descri,
                pin_clase,
                ac.codigo
            BULK COLLECT
            INTO v_table
            FROM
                articulos       a
                LEFT OUTER JOIN articulos_clase ac ON ac.id_cia = a.id_cia
                                                      AND ac.tipinv = a.tipinv
                                                      AND ac.codart = a.codart
                                                      AND ac.clase = pin_clase
            WHERE
                    a.id_cia = pin_id_cia
                AND a.tipinv = pin_tipinv
            ORDER BY
                a.codart ASC;

        ELSE
            SELECT
                a.id_cia,
                a.tipinv,
                a.codart,
                a.descri,
                pin_clase,
                ac.codigo
            BULK COLLECT
            INTO v_table
            FROM
                articulos       a
                LEFT OUTER JOIN articulos_clase ac ON ac.id_cia = a.id_cia
                                                      AND ac.tipinv = a.tipinv
                                                      AND ac.codart = a.codart
                                                      AND ac.clase = pin_clase
            WHERE
                    a.id_cia = pin_id_cia
                AND a.tipinv = pin_tipinv
                AND NOT EXISTS (
                    SELECT
                        ac1.*
                    FROM
                        articulos_clase ac1
                    WHERE
                            ac1.id_cia = a.id_cia
                        AND ac1.tipinv = a.tipinv
                        AND ac1.codart = a.codart
                        AND ac1.clase = pin_clase
                        AND ac1.codigo NOT IN ( 'ND' )
                )
            ORDER BY
                a.codart ASC;

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

        reg_errores         r_errores := r_errores(NULL, NULL, NULL, NULL);
        fila                NUMBER := 3;
        o                   json_object_t;
        rec_articulos       articulos%rowtype;
        rec_articulos_clase articulos_clase%rowtype;
        v_aux               NUMBER := 0;
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_articulos.id_cia := pin_id_cia;
        rec_articulos.tipinv := o.get_number('tipinv');
        rec_articulos.codart := o.get_string('codart');
        rec_articulos.descri := o.get_string('desart');
        rec_articulos_clase.clase := o.get_number('clase');
        rec_articulos_clase.codigo := nvl(o.get_string('codigo'), 'ND');
        reg_errores.orden := rec_articulos.codart;
        reg_errores.concepto := rec_articulos.descri;
        BEGIN
            SELECT
                descri
            INTO reg_errores.concepto
            FROM
                articulos p
            WHERE
                    p.id_cia = pin_id_cia
                AND p.tipinv = rec_articulos.tipinv
                AND p.codart = rec_articulos.codart;

        EXCEPTION
            WHEN no_data_found THEN
                reg_errores.valor := rec_articulos.tipinv
                                     || ' - '
                                     || rec_articulos.codart;
                reg_errores.deserror := 'ARTICULO INGRESADO NO EXISTE';
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
                AND p.tipinv = rec_articulos.tipinv
                AND p.clase = rec_articulos_clase.clase
                AND p.codigo = rec_articulos_clase.codigo;

        EXCEPTION
            WHEN no_data_found THEN
                reg_errores.valor := rec_articulos_clase.codigo;
                reg_errores.deserror := 'EL CODIGO ASIGNADO A LA CLASE [ '
                                        || rec_articulos_clase.clase
                                        || ' ] NO ESTA DEFINIDO';
                PIPE ROW ( reg_errores );
        END;

    END sp_valida_objeto;

    PROCEDURE sp_importar (
        pin_id_cia  IN NUMBER,
        pin_datos   IN CLOB,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS

        o                   json_object_t;
        rec_articulos       articulos%rowtype;
        rec_articulos_clase articulos_clase%rowtype;
        m                   json_object_t;
        pout_mensaje        VARCHAR2(1000 CHAR);
        v_mensaje           VARCHAR2(1000 CHAR);
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_articulos.id_cia := pin_id_cia;
        rec_articulos.tipinv := o.get_number('tipinv');
        rec_articulos.codart := o.get_string('codart');
        rec_articulos.descri := o.get_string('desart');
        rec_articulos_clase.clase := o.get_number('clase');
        rec_articulos_clase.codigo := nvl(o.get_string('codigo'), 'ND');
        MERGE INTO articulos_clase ac
        USING dual ddd ON ( ac.id_cia = rec_articulos.id_cia
                            AND ac.tipinv = rec_articulos.tipinv
                            AND ac.codart = rec_articulos.codart
                            AND ac.clase = rec_articulos_clase.clase )
        WHEN MATCHED THEN UPDATE
        SET codigo = rec_articulos_clase.codigo,
            situac = 'S'
        WHERE
                id_cia = rec_articulos.id_cia
            AND tipinv = rec_articulos.tipinv
            AND codart = rec_articulos.codart
            AND clase = rec_articulos_clase.clase
        WHEN NOT MATCHED THEN
        INSERT (
            id_cia,
            tipinv,
            codart,
            clase,
            codigo,
            situac )
        VALUES
            ( rec_articulos.id_cia,
              rec_articulos.tipinv,
              rec_articulos.codart,
              rec_articulos_clase.clase,
              rec_articulos_clase.codigo,
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
    END sp_importar;

END;

/

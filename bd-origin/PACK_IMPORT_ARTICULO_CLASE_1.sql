--------------------------------------------------------
--  DDL for Package Body PACK_IMPORT_ARTICULO_CLASE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_IMPORT_ARTICULO_CLASE" AS

    FUNCTION sp_exportar (
        pin_id_cia IN NUMBER,
        pin_tipinv IN NUMBER,
        pin_clase  IN NUMBER
    ) RETURN datatable_buscar
        PIPELINED
    AS
        v_table datatable_buscar;
    BEGIN
        SELECT
            tipinv,
            clase,
            codigo,
            descri AS descri,
            situac,
            swdefaul
        BULK COLLECT
        INTO v_table
        FROM
            clase_codigo
        WHERE
                id_cia = pin_id_cia
            AND tipinv = pin_tipinv
            AND clase = pin_clase;

        FOR i IN 1..v_table.count LOOP
            PIPE ROW ( v_table(i) );
        END LOOP;

        RETURN;
    END sp_exportar;

    FUNCTION sp_valida_objeto (
        pin_id_cia IN NUMBER,
        pin_datos  IN CLOB
    ) RETURN datatable
        PIPELINED
    AS

        reg_errores      r_errores := r_errores(NULL, NULL);
        fila             NUMBER := 3;
        o                json_object_t;
        rec_clase_codigo clase_codigo%rowtype;
        v_aux            NUMBER := 0;
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_clase_codigo.id_cia := pin_id_cia;
        rec_clase_codigo.tipinv := o.get_number('tipinv');
        rec_clase_codigo.clase := o.get_number('clase');
        rec_clase_codigo.codigo := o.get_string('codigo');
        rec_clase_codigo.descri := o.get_string('descri');
        rec_clase_codigo.situac := nvl(o.get_string('situac'), 'S');
        rec_clase_codigo.swdefaul := nvl(o.get_string('defaul'), 'N');
        BEGIN
            SELECT
                0
            INTO v_aux
            FROM
                clase p
            WHERE
                    p.id_cia = pin_id_cia
                AND p.tipinv = rec_clase_codigo.tipinv
                AND p.clase = rec_clase_codigo.clase;

        EXCEPTION
            WHEN no_data_found THEN
                reg_errores.valor := to_char(rec_clase_codigo.clase);
                reg_errores.deserror := 'CLASE NO ESTA DEFINIDA';
                PIPE ROW ( reg_errores );
        END;

        IF rec_clase_codigo.situac NOT IN ( 'S', 'N' ) THEN
            reg_errores.valor := rec_clase_codigo.situac;
            reg_errores.deserror := 'SITUACION SOLO SE PUEDE ESTABLECER EN S O N';
            PIPE ROW ( reg_errores );
        END IF;

        IF rec_clase_codigo.swdefaul NOT IN ( 'S', 'N' ) THEN
            reg_errores.valor := rec_clase_codigo.swdefaul;
            reg_errores.deserror := 'DEFECTO SOLO SE PUEDE ESTABLECER EN S O N';
            PIPE ROW ( reg_errores );
        END IF;

    END sp_valida_objeto;

    PROCEDURE sp_importar (
        pin_id_cia  IN NUMBER,
        pin_datos   IN CLOB,
        pin_usuari  IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS
        o                json_object_t;
        rec_clase_codigo clase_codigo%rowtype;
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_clase_codigo.id_cia := pin_id_cia;
        rec_clase_codigo.tipinv := o.get_number('tipinv');
        rec_clase_codigo.clase := o.get_number('clase');
        rec_clase_codigo.codigo := o.get_string('codigo');
        rec_clase_codigo.descri := o.get_string('descri');
        rec_clase_codigo.abrevi := '';
        rec_clase_codigo.usuari := pin_usuari;
        rec_clase_codigo.situac := nvl(o.get_string('situac'), 'S');
        rec_clase_codigo.swdefaul := nvl(o.get_string('defaul'), 'N');
        MERGE INTO clase_codigo ccc
        USING dual ddd ON ( ccc.id_cia = rec_clase_codigo.id_cia
                            AND ccc.tipinv = rec_clase_codigo.tipinv
                            AND ccc.clase = rec_clase_codigo.clase
                            AND ccc.codigo = rec_clase_codigo.codigo )
        WHEN MATCHED THEN UPDATE
        SET descri = rec_clase_codigo.descri,
            swdefaul = rec_clase_codigo.swdefaul,
            situac = rec_clase_codigo.situac,
            usuari = rec_clase_codigo.usuari,
            factua = current_timestamp
        WHERE
                id_cia = rec_clase_codigo.id_cia
            AND tipinv = rec_clase_codigo.tipinv
            AND clase = rec_clase_codigo.clase
            AND codigo = rec_clase_codigo.codigo
        WHEN NOT MATCHED THEN
        INSERT (
            id_cia,
            tipinv,
            clase,
            codigo,
            descri,
            abrevi,
            situac,
            fcreac,
            factua,
            usuari,
            swdefaul )
        VALUES
            ( rec_clase_codigo.id_cia,
              rec_clase_codigo.tipinv,
              rec_clase_codigo.clase,
              rec_clase_codigo.codigo,
              rec_clase_codigo.descri,
              rec_clase_codigo.abrevi,
              rec_clase_codigo.situac,
              current_timestamp,
              current_timestamp,
              rec_clase_codigo.usuari,
              rec_clase_codigo.swdefaul );

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Success'
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
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

    END sp_importar;

END pack_import_articulo_clase;

/

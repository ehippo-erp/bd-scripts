--------------------------------------------------------
--  DDL for Package Body PACK_ARTICULOS_GLOSA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_ARTICULOS_GLOSA" AS

    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_tipo   NUMBER,
        pin_tipinv NUMBER,
        pin_codart VARCHAR2
    ) RETURN datatable_articulos_glosa
        PIPELINED
    IS
        v_table datatable_articulos_glosa;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            articulos_glosa
        WHERE
                id_cia = pin_id_cia
            AND tipo = pin_tipo
            AND tipinv = pin_tipinv
            AND codart = pin_codart;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia   NUMBER,
        pin_tipo     NUMBER,
        pin_tipinv   NUMBER,
        pin_codart   VARCHAR2,
        pin_swdefaul VARCHAR2
    ) RETURN datatable_articulos_glosa
        PIPELINED
    IS
        v_table datatable_articulos_glosa;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            articulos_glosa
        WHERE
                id_cia = pin_id_cia
            AND ( ( pin_tipo = - 1
                    OR pin_tipo IS NULL )
                  OR tipo = pin_tipo )
            AND ( ( pin_tipinv = - 1
                    OR pin_tipinv IS NULL )
                  OR tipinv = pin_tipinv )
            AND ( pin_codart IS NULL
                  OR codart = pin_codart )
            AND ( pin_swdefaul IS NULL
                  OR swdefaul = upper(pin_swdefaul) );

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
            "tipo":1,
            "tipinv":1,
            "codart":"1000",
            "observ":"Glosa de Prueba",
            "swdefaul":"N"
            }';
    PACK_ARTICULOS_GLOSA.sp_save(100, cadjson, 1, mensaje);
    dbms_output.put_line(mensaje);
END;

SELECT * FROM PACK_ARTICULOS_GLOSA.sp_buscar(100,-1,-1,NULL,'N');

SELECT * FROM PACK_ARTICULOS_GLOSA.sp_obtener(25,2,2,'0019');
*/

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) IS
        o                   json_object_t;
        rec_articulos_glosa articulos_glosa%rowtype;
        v_accion            VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_articulos_glosa.id_cia := pin_id_cia;
        rec_articulos_glosa.tipo := o.get_number('tipo');
        rec_articulos_glosa.tipinv := o.get_number('tipinv');
        rec_articulos_glosa.codart := o.get_string('codart');
        rec_articulos_glosa.observ := o.get_string('observ');
        rec_articulos_glosa.swdefaul := o.get_string('swdefaul');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                INSERT INTO articulos_glosa (
                    id_cia,
                    tipo,
                    tipinv,
                    codart,
                    observ,
                    swdefaul
                ) VALUES (
                    rec_articulos_glosa.id_cia,
                    rec_articulos_glosa.tipo,
                    rec_articulos_glosa.tipinv,
                    rec_articulos_glosa.codart,
                    rec_articulos_glosa.observ,
                    rec_articulos_glosa.swdefaul
                );

                COMMIT;
            WHEN 2 THEN
                v_accion := 'La actualización';
                UPDATE articulos_glosa
                SET
                    observ =
                        CASE
                            WHEN rec_articulos_glosa.observ IS NULL THEN
                                observ
                            ELSE
                                rec_articulos_glosa.observ
                        END,
                    swdefaul =
                        CASE
                            WHEN rec_articulos_glosa.swdefaul IS NULL THEN
                                swdefaul
                            ELSE
                                rec_articulos_glosa.swdefaul
                        END
                WHERE
                        id_cia = rec_articulos_glosa.id_cia
                    AND tipo = rec_articulos_glosa.tipo
                    AND tipinv = rec_articulos_glosa.tipinv
                    AND codart = rec_articulos_glosa.codart;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM articulos_glosa
                WHERE
                        id_cia = rec_articulos_glosa.id_cia
                    AND tipo = rec_articulos_glosa.tipo
                    AND tipinv = rec_articulos_glosa.tipinv
                    AND codart = rec_articulos_glosa.codart;

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
                    'message' VALUE 'El Registro con codigo ' || rec_articulos_glosa.tipo || '-' ||
                    rec_articulos_glosa.tipinv || '-' ||
                    rec_articulos_glosa.codart || ' ya Existe ...!'
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN value_error THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE 'Formato Incorrecto, No se puede resgistrar ...!'
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

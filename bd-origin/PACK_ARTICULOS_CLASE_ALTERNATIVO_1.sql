--------------------------------------------------------
--  DDL for Package Body PACK_ARTICULOS_CLASE_ALTERNATIVO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_ARTICULOS_CLASE_ALTERNATIVO" AS

    FUNCTION sp_sel_articulos_clase_alternativo (
        pin_id_cia IN NUMBER,
        pin_tipinv IN NUMBER,
        pin_codart IN VARCHAR2
    ) RETURN t_articulos_clase_alternativo
        PIPELINED
    IS
        v_table t_articulos_clase_alternativo;
    BEGIN
--    select *
--from table(pack_articulos_clase_alternativo.sp_sel_articulos_clase_alternativo(30,1,'OPTMTMB42A'));
        SELECT
            aca.id_cia      id_cia,
            aca.tipinv      tipinv,
            aca.codart      codart,
            aca.clase       clase,
            caa.descri      AS desclase,
            aca.codigo      codigo,
            u.desuni        AS descodigo,
            aca.vreal       vreal,
            aca.vstrg       vstrg,
            aca.vchar       vchar,
            aca.vdate       vdate,
            aca.vtime       vtime,
            aca.ventero     ventero,
            aca.codusercrea codusercrea,
            aca.coduseractu coduseractu,
            aca.fcreac      fcreac,
            aca.factua      factua,
            aca.orden       orden,
            aca.swacti      swacti
        BULK COLLECT
        INTO v_table
        FROM
            articulos_clase_alternativo aca
            LEFT OUTER JOIN clase_articulos_alternativo caa ON aca.id_cia = caa.id_cia
                                                               AND aca.clase = caa.clase
            LEFT OUTER JOIN unidad                      u ON aca.id_cia = u.id_cia
                                        AND aca.codigo = u.coduni
        WHERE
                aca.id_cia = pin_id_cia
            AND aca.tipinv = pin_tipinv
            AND aca.codart = pin_codart;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_sel_articulos_clase_alternativo;

    PROCEDURE sp_save_articulos_clase_alternativo (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    ) IS
        o                               json_object_t;
        rec_articulos_clase_alternativo articulos_clase_alternativo%rowtype;
        v_accion                        VARCHAR2(50) := '';
    BEGIN
--    SET SERVEROUTPUT ON;
--DECLARE 
--    MSJ VARCHAR2(500);
--    cadjson  VARCHAR2(4000);
--BEGIN
-- cadjson := '{
--    "tipinv": 1,
--    "codart": "OPTMTMB42A",
--    "clase":1,
--    "codigo":"KG",
--    "vreal":41,
--    "vstrg":"DEMO",
--    "vchar":"",
--    "vdate":"",
--    "vtime":"",
--    "codusercrea":"ADMIN",
--    "coduseractu":"ADMIN",
--    "orden":5,
--    "swacti":"S"}';
--    pack_articulos_clase_alternativo.sp_save_articulos_clase_alternativo(30,cadjson,1, MSJ);
--    dbms_output.put_line(MSJ);
--END;
        o := json_object_t.parse(pin_datos);
        rec_articulos_clase_alternativo.id_cia := pin_id_cia;
        rec_articulos_clase_alternativo.tipinv := o.get_number('tipinv');
        rec_articulos_clase_alternativo.codart := o.get_string('codart');
        rec_articulos_clase_alternativo.clase := o.get_number('clase');
        rec_articulos_clase_alternativo.codigo := o.get_string('codigo');
        rec_articulos_clase_alternativo.vreal := o.get_number('vreal');
        rec_articulos_clase_alternativo.vstrg := o.get_string('vstrg');
        rec_articulos_clase_alternativo.vchar := o.get_string('vchar');
        rec_articulos_clase_alternativo.vdate := o.get_date('vdate');
        rec_articulos_clase_alternativo.vtime := o.get_date('vtime');
        rec_articulos_clase_alternativo.ventero := o.get_number('ventero');
        rec_articulos_clase_alternativo.codusercrea := o.get_string('codusercrea');
        rec_articulos_clase_alternativo.coduseractu := o.get_string('coduseractu');
        rec_articulos_clase_alternativo.orden := o.get_number('orden');
        rec_articulos_clase_alternativo.swacti := o.get_string('swacti');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                INSERT INTO articulos_clase_alternativo (
                    id_cia,
                    tipinv,
                    codart,
                    clase,
                    codigo,
                    vreal,
                    vstrg,
                    vchar,
                    vdate,
                    vtime,
                    ventero,
                    codusercrea,
                    coduseractu,
                    fcreac,
                    factua,
                    orden,
                    swacti
                ) VALUES (
                    rec_articulos_clase_alternativo.id_cia,
                    rec_articulos_clase_alternativo.tipinv,
                    rec_articulos_clase_alternativo.codart,
                    rec_articulos_clase_alternativo.clase,
                    rec_articulos_clase_alternativo.codigo,
                    rec_articulos_clase_alternativo.vreal,
                    rec_articulos_clase_alternativo.vstrg,
                    rec_articulos_clase_alternativo.vchar,
                    rec_articulos_clase_alternativo.vdate,
                    rec_articulos_clase_alternativo.vtime,
                    rec_articulos_clase_alternativo.ventero,
                    rec_articulos_clase_alternativo.codusercrea,
                    rec_articulos_clase_alternativo.coduseractu,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    rec_articulos_clase_alternativo.orden,
                    rec_articulos_clase_alternativo.swacti
                );

                COMMIT;
            WHEN 2 THEN
                UPDATE articulos_clase_alternativo
                SET
                    vreal = rec_articulos_clase_alternativo.vreal,
                    vstrg = rec_articulos_clase_alternativo.vstrg,
                    vchar = rec_articulos_clase_alternativo.vchar,
                    vdate = rec_articulos_clase_alternativo.vdate,
                    vtime = rec_articulos_clase_alternativo.vtime,
                    ventero = rec_articulos_clase_alternativo.ventero,
                    coduseractu = rec_articulos_clase_alternativo.coduseractu,
                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    orden = rec_articulos_clase_alternativo.orden,
                    swacti = rec_articulos_clase_alternativo.swacti
                WHERE
                        id_cia = rec_articulos_clase_alternativo.id_cia
                    AND tipinv = rec_articulos_clase_alternativo.tipinv
                    AND codart = rec_articulos_clase_alternativo.codart
                    AND clase = rec_articulos_clase_alternativo.clase
                    AND codigo = rec_articulos_clase_alternativo.codigo;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM articulos_clase_alternativo
                WHERE
                        id_cia = rec_articulos_clase_alternativo.id_cia
                    AND tipinv = rec_articulos_clase_alternativo.tipinv
                    AND codart = rec_articulos_clase_alternativo.codart
                    AND clase = rec_articulos_clase_alternativo.clase
                    AND codigo = rec_articulos_clase_alternativo.codigo;

                COMMIT;
        END CASE;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE v_accion || ' se realizo satisfactoriamente...!'
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
                    'message' VALUE 'El registro con el TIPO DE INVENTARIO [ '
                                    || rec_articulos_clase_alternativo.tipinv
                                    || ' ], con el ARTICULO [ '
                                    || rec_articulos_clase_alternativo.codart
                                    || ' ], asociado a la CLASE [ '
                                    || rec_articulos_clase_alternativo.clase
                                    || ' ] y con CODIGO [ '
                                    || rec_articulos_clase_alternativo.codigo
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
--            IF sqlcode = -2291 THEN
--                SELECT
--                    JSON_OBJECT(
--                        'status' VALUE 1.1,
--                        'message' VALUE 'No se insertar o modificar este registro porque el TipoItem [ '
--                                        || rec_personal_legajo.codtip
--                                        || ' - '
--                                        || rec_personal_legajo.codite
--                                        || ' ] no existe ...! '
--                    )
--                INTO pin_mensaje
--                FROM
--                    dual;

--            ELSE
            pin_mensaje := 'mensaje : '
                           || sqlerrm
                           || ' codite :'
                           || sqlcode;
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pin_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

--            END IF;
    END sp_save_articulos_clase_alternativo;

END;

/

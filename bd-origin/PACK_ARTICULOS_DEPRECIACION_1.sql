--------------------------------------------------------
--  DDL for Package Body PACK_ARTICULOS_DEPRECIACION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_ARTICULOS_DEPRECIACION" AS

    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_locali NUMBER
    ) RETURN datatable_articulos_depreciacion
        PIPELINED
    AS
        v_table datatable_articulos_depreciacion;
    BEGIN
        SELECT
            ad.*
        BULK COLLECT
        INTO v_table
        FROM
            articulos_depreciacion ad
        WHERE
                ad.id_cia = pin_id_cia
            AND ad.locali = pin_locali;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_tipinv NUMBER,
        pin_codart VARCHAR2,
        pin_numint NUMBER
    ) RETURN datatable_articulos_depreciacion
        PIPELINED
    AS
        v_table datatable_articulos_depreciacion;
    BEGIN
        SELECT
            ad.*
        BULK COLLECT
        INTO v_table
        FROM
            articulos_depreciacion ad
        WHERE
                ad.id_cia = pin_id_cia
            AND ad.tipinv = pin_tipinv
            AND ad.codart = pin_codart
            AND ( pin_numint IS NULL
                  OR pin_numint = - 1
                  OR ad.numint = pin_numint );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar;

--set SERVEROUTPUT on;
--
--DECLARE
--    mensaje VARCHAR2(500);
--    cadjson VARCHAR2(5000);
--BEGIN
--cadjson := '{
--                "locali":19919,
--                "costot01":2133.62,
--                "costot02":5,
--                "mejora01":"",
--                "mejora02":"",
--                "ucreac":"admin",
--                "uactua":"admin"
--                }';
--pack_articulos_depreciacion.sp_save(74, cadjson, 2, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_articulos_depreciacion.sp_obtener(74,19919);
--
--SELECT * FROM pack_articulos_depreciacion.sp_buscar(74,100,'1045',0);

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS

        o                          json_object_t;
        rec_articulos_depreciacion articulos_depreciacion%rowtype;
        v_accion                   VARCHAR2(50) := '';
        pout_mensaje               VARCHAR2(1000 CHAR);
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_articulos_depreciacion.id_cia := pin_id_cia;
        rec_articulos_depreciacion.locali := o.get_number('locali');
        rec_articulos_depreciacion.id := o.get_string('id');
        rec_articulos_depreciacion.tipdoc := o.get_number('tipdoc');
        rec_articulos_depreciacion.numint := o.get_string('numint');
        rec_articulos_depreciacion.numite := o.get_string('numite');
        rec_articulos_depreciacion.periodo := o.get_number('periodo');
        rec_articulos_depreciacion.mes := o.get_number('mes');
        rec_articulos_depreciacion.codmot := o.get_string('codmot');
        rec_articulos_depreciacion.femisi := o.get_date('femisi');
        rec_articulos_depreciacion.tipinv := o.get_number('tipinv');
        rec_articulos_depreciacion.codart := o.get_string('codart');
        rec_articulos_depreciacion.cantid := o.get_number('cantid');
        rec_articulos_depreciacion.costot01 := o.get_number('costot01');
        rec_articulos_depreciacion.costot02 := o.get_number('costot02');
        rec_articulos_depreciacion.situac := o.get_string('situac');
        rec_articulos_depreciacion.fcreac := o.get_date('fcreac');
        rec_articulos_depreciacion.factua := o.get_date('factua');
        rec_articulos_depreciacion.usuari := o.get_string('uactua');
        rec_articulos_depreciacion.swacti := o.get_string('swacti');
        rec_articulos_depreciacion.tipcam := o.get_number('tipcam');
        rec_articulos_depreciacion.acumu01 := o.get_number('acumu01');
        rec_articulos_depreciacion.acumu02 := o.get_number('acumu02');
        rec_articulos_depreciacion.mejora01 := o.get_number('mejora01');
        rec_articulos_depreciacion.mejora02 := o.get_number('mejora02');
        v_accion := '';
        CASE pin_opcdml
            WHEN 1 THEN
                v_accion := 'La insercion';
                INSERT INTO articulos_depreciacion (
                    id_cia,
                    locali,
                    id,
                    tipdoc,
                    numint,
                    numite,
                    periodo,
                    mes,
                    codmot,
                    femisi,
                    tipinv,
                    codart,
                    cantid,
                    costot01,
                    costot02,
                    situac,
                    fcreac,
                    factua,
                    usuari,
                    swacti,
                    tipcam,
                    acumu01,
                    acumu02,
                    mejora01,
                    mejora02
                ) VALUES (
                    rec_articulos_depreciacion.id_cia,
                    rec_articulos_depreciacion.locali,
                    rec_articulos_depreciacion.id,
                    rec_articulos_depreciacion.tipdoc,
                    rec_articulos_depreciacion.numint,
                    rec_articulos_depreciacion.numite,
                    rec_articulos_depreciacion.periodo,
                    rec_articulos_depreciacion.mes,
                    rec_articulos_depreciacion.codmot,
                    rec_articulos_depreciacion.femisi,
                    rec_articulos_depreciacion.tipinv,
                    rec_articulos_depreciacion.codart,
                    rec_articulos_depreciacion.cantid,
                    rec_articulos_depreciacion.costot01,
                    rec_articulos_depreciacion.costot02,
                    rec_articulos_depreciacion.situac,
                    current_timestamp,
                    current_timestamp,
                    rec_articulos_depreciacion.usuari,
                    rec_articulos_depreciacion.swacti,
                    rec_articulos_depreciacion.tipcam,
                    rec_articulos_depreciacion.acumu01,
                    rec_articulos_depreciacion.acumu02,
                    rec_articulos_depreciacion.mejora01,
                    rec_articulos_depreciacion.mejora02
                );

            WHEN 2 THEN
                v_accion := 'La actualizacion';
                BEGIN
                    SELECT
                        nvl(tipcam, 1)
                    INTO rec_articulos_depreciacion.tipcam
                    FROM
                        articulos_depreciacion
                    WHERE
                            id_cia = pin_id_cia
                        AND locali = rec_articulos_depreciacion.locali;

                EXCEPTION
                    WHEN no_data_found THEN
                        pout_mensaje := 'El ARTICULO asignado no tiene definido el TIPO DE CAMBIO ...!';
                        RAISE pkg_exceptionuser.ex_error_inesperado;
                END;

                -- CONSISTENCIAR, AL MODIFICAR UN COSTO O MEJORA, SE MODIFCA AUTOMATICAMENTE SU EQUIVALENTE
                IF
                    o.get_string('costot01') IS NULL
                    AND o.get_string('costot02') IS NOT NULL
                THEN
                    rec_articulos_depreciacion.costot02 := o.get_number('costot02');
                    rec_articulos_depreciacion.costot01 := rec_articulos_depreciacion.costot02 * rec_articulos_depreciacion.tipcam;
                ELSIF
                    o.get_string('costot02') IS NULL
                    AND o.get_string('costot01') IS NOT NULL
                THEN
                    rec_articulos_depreciacion.costot01 := o.get_number('costot01');
                    rec_articulos_depreciacion.costot02 := rec_articulos_depreciacion.costot01 / rec_articulos_depreciacion.tipcam;
                END IF;

                IF
                    o.get_string('mejora01') IS NULL
                    AND o.get_string('mejora02') IS NOT NULL
                THEN
                    rec_articulos_depreciacion.mejora02 := o.get_number('mejora02');
                    rec_articulos_depreciacion.mejora01 := rec_articulos_depreciacion.mejora02 * rec_articulos_depreciacion.tipcam;
                ELSIF
                    o.get_string('mejora02') IS NULL
                    AND o.get_string('mejora01') IS NOT NULL
                THEN
                    rec_articulos_depreciacion.mejora01 := o.get_number('mejora01');
                    rec_articulos_depreciacion.mejora02 := rec_articulos_depreciacion.mejora01 / rec_articulos_depreciacion.tipcam;
                END IF;

                UPDATE articulos_depreciacion
                SET
                    costot01 =
                        CASE
                            WHEN rec_articulos_depreciacion.costot01 IS NULL THEN
                                costot01
                            ELSE
                                rec_articulos_depreciacion.costot01
                        END,
                    costot02 =
                        CASE
                            WHEN rec_articulos_depreciacion.costot02 IS NULL THEN
                                costot02
                            ELSE
                                rec_articulos_depreciacion.costot02
                        END,
                    mejora01 =
                        CASE
                            WHEN rec_articulos_depreciacion.mejora01 IS NULL THEN
                                mejora01
                            ELSE
                                rec_articulos_depreciacion.mejora01
                        END,
                    mejora02 =
                        CASE
                            WHEN rec_articulos_depreciacion.mejora02 IS NULL THEN
                                mejora02
                            ELSE
                                rec_articulos_depreciacion.mejora02
                        END,
                    usuari = rec_articulos_depreciacion.usuari,
                    fcreac = current_timestamp
                WHERE
                        id_cia = rec_articulos_depreciacion.id_cia
                    AND locali = rec_articulos_depreciacion.locali;

            WHEN 3 THEN
                v_accion := 'La eliminacion';
                DELETE FROM articulos_depreciacion
                WHERE
                        id_cia = rec_articulos_depreciacion.id_cia
                    AND locali = rec_articulos_depreciacion.locali;

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
                    'message' VALUE 'El registro con ID [ '
                                    || rec_articulos_depreciacion.locali
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

        WHEN pkg_exceptionuser.ex_error_inesperado THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE pout_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

            ROLLBACK;
        WHEN OTHERS THEN
            pin_mensaje := 'mensaje : '
                           || sqlerrm
                           || ' coment :'
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

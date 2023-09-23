--------------------------------------------------------
--  DDL for Package Body PACK_DCTA103
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_DCTA103" AS

    FUNCTION sp_obtener_rel (
        pin_id_cia    NUMBER,
        pin_libro     VARCHAR2,
        pin_periodo   NUMBER,
        pin_mes       NUMBER,
        pin_secuencia NUMBER,
        pin_item      NUMBER
    ) RETURN datatable_dcta103_rel
        PIPELINED
    AS
        v_table datatable_dcta103_rel;
    BEGIN
        SELECT
            pl.id_cia,
            pl.libro,
            pl.periodo,
            pl.mes,
            pl.secuencia,
            pl.item,
            pl.r_libro,
            pl.r_periodo,
            pl.r_mes,
            pl.r_secuencia,
            pl.r_item,
            pl.ucreac,
            pl.uactua,
            pl.fcreac,
            pl.factua
        BULK COLLECT
        INTO v_table
        FROM
            dcta103_rel pl
        WHERE
                pl.id_cia = pin_id_cia
            AND pl.libro = pin_libro
            AND pl.periodo = pin_periodo
            AND pl.mes = pin_mes
            AND pl.secuencia = pin_secuencia
            AND pl.item = pin_item;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener_rel;

    FUNCTION sp_buscar_rel (
        pin_id_cia    NUMBER,
        pin_libro     VARCHAR2,
        pin_periodo   NUMBER,
        pin_mes       NUMBER,
        pin_secuencia NUMBER,
        pin_item      NUMBER,
        pin_opcrel    NUMBER
    ) RETURN datatable_dcta103_rel
        PIPELINED
    AS
        v_table datatable_dcta103_rel;
    BEGIN
        IF pin_opcrel = 0 THEN
            SELECT
                pl.id_cia,
                pl.libro,
                pl.periodo,
                pl.mes,
                pl.secuencia,
                pl.item,
                pl.r_libro,
                pl.r_periodo,
                pl.r_mes,
                pl.r_secuencia,
                pl.r_item,
                pl.ucreac,
                pl.uactua,
                pl.fcreac,
                pl.factua
            BULK COLLECT
            INTO v_table
            FROM
                dcta103_rel pl
            WHERE
                    pl.id_cia = pin_id_cia
                AND pl.libro = pin_libro
                AND ( pin_periodo IS NULL
                      OR pin_periodo = - 1
                      OR pl.periodo = pin_periodo )
                AND ( pin_mes IS NULL
                      OR pin_mes = - 1
                      OR pl.mes = pin_mes )
                AND ( pin_secuencia IS NULL
                      OR pin_secuencia = - 1
                      OR pl.secuencia = pin_secuencia )
                AND ( pin_item IS NULL
                      OR pin_item = - 1
                      OR pl.item = pin_item );

            FOR registro IN 1..v_table.count LOOP
                PIPE ROW ( v_table(registro) );
            END LOOP;

            RETURN;
        ELSE
            SELECT
                pl.id_cia,
                pl.libro,
                pl.periodo,
                pl.mes,
                pl.secuencia,
                pl.item,
                pl.r_libro,
                pl.r_periodo,
                pl.r_mes,
                pl.r_secuencia,
                pl.r_item,
                pl.ucreac,
                pl.uactua,
                pl.fcreac,
                pl.factua
            BULK COLLECT
            INTO v_table
            FROM
                dcta103_rel pl
            WHERE
                    pl.id_cia = pin_id_cia
                AND pl.r_libro = pin_libro
                AND ( pin_periodo IS NULL
                      OR pin_periodo = - 1
                      OR pl.r_periodo = pin_periodo )
                AND ( pin_mes IS NULL
                      OR pin_mes = - 1
                      OR pl.r_mes = pin_mes )
                AND ( pin_secuencia IS NULL
                      OR pin_secuencia = - 1
                      OR pl.r_secuencia = pin_secuencia )
                AND ( pin_item IS NULL
                      OR pin_item = - 1
                      OR pl.r_item = pin_item );

            FOR registro IN 1..v_table.count LOOP
                PIPE ROW ( v_table(registro) );
            END LOOP;

            RETURN;
        END IF;
    END sp_buscar_rel;

--set SERVEROUTPUT on;
--
--DECLARE
--    mensaje VARCHAR2(500);
--    cadjson VARCHAR2(5000);
--BEGIN
--cadjson := '{
--                "libro":"10",
--                "periodo":2022,
--                "mes":10,
--                "secuencia":1,
--                "item":1,
--                "r_libro":"08",
--                "r_periodo":2022,
--                "r_mes":10,
--                "r_secuencia":1,
--                "r_item":1,
--                "ucreac":"Admin",
--                "uactua":"Admin"
--                }';
--pack_dcta103.sp_save_rel(66, cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_dcta103.sp_obtener_rel(66,'10',2022,10,1,1);
--
--SELECT * FROM pack_dcta103.sp_buscar_rel(66,'10',NULL,NULL,NULL,NULL,0);

    PROCEDURE sp_save_rel (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS
        o               json_object_t;
        rec_dcta103_rel dcta103_rel%rowtype;
        v_accion        VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_dcta103_rel.id_cia := pin_id_cia;
        rec_dcta103_rel.libro := o.get_string('libro');
        rec_dcta103_rel.periodo := o.get_number('periodo');
        rec_dcta103_rel.mes := o.get_number('mes');
        rec_dcta103_rel.secuencia := o.get_number('secuencia');
        rec_dcta103_rel.item := o.get_number('item');
        rec_dcta103_rel.r_libro := o.get_string('r_libro');
        rec_dcta103_rel.r_periodo := o.get_number('r_periodo');
        rec_dcta103_rel.r_mes := o.get_number('r_mes');
        rec_dcta103_rel.r_secuencia := o.get_number('r_secuencia');
        rec_dcta103_rel.r_item := o.get_number('r_item');
        rec_dcta103_rel.ucreac := o.get_string('ucreac');
        rec_dcta103_rel.uactua := o.get_string('uactua');
        v_accion := '';
        CASE pin_opcdml
            WHEN 1 THEN
                v_accion := 'La insercion';
                INSERT INTO dcta103_rel (
                    id_cia,
                    libro,
                    periodo,
                    mes,
                    secuencia,
                    item,
                    r_libro,
                    r_periodo,
                    r_mes,
                    r_secuencia,
                    r_item,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_dcta103_rel.id_cia,
                    rec_dcta103_rel.libro,
                    rec_dcta103_rel.periodo,
                    rec_dcta103_rel.mes,
                    rec_dcta103_rel.secuencia,
                    rec_dcta103_rel.item,
                    rec_dcta103_rel.r_libro,
                    rec_dcta103_rel.r_periodo,
                    rec_dcta103_rel.r_mes,
                    rec_dcta103_rel.r_secuencia,
                    rec_dcta103_rel.r_item,
                    rec_dcta103_rel.ucreac,
                    rec_dcta103_rel.uactua,
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS'),
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS')
                );

            WHEN 2 THEN
                v_accion := 'La actualizacion';
                UPDATE dcta103_rel
                SET
                    r_libro =
                        CASE
                            WHEN rec_dcta103_rel.r_libro IS NULL THEN
                                r_libro
                            ELSE
                                rec_dcta103_rel.r_libro
                        END,
                    r_periodo =
                        CASE
                            WHEN rec_dcta103_rel.r_periodo IS NULL THEN
                                r_periodo
                            ELSE
                                rec_dcta103_rel.r_periodo
                        END,
                    r_mes =
                        CASE
                            WHEN rec_dcta103_rel.r_mes IS NULL THEN
                                r_mes
                            ELSE
                                rec_dcta103_rel.r_mes
                        END,
                    r_secuencia =
                        CASE
                            WHEN rec_dcta103_rel.r_secuencia IS NULL THEN
                                r_secuencia
                            ELSE
                                rec_dcta103_rel.r_secuencia
                        END,
                    r_item =
                        CASE
                            WHEN rec_dcta103_rel.r_item IS NULL THEN
                                r_item
                            ELSE
                                rec_dcta103_rel.r_item
                        END,
                    uactua =
                        CASE
                            WHEN rec_dcta103_rel.uactua IS NULL THEN
                                uactua
                            ELSE
                                rec_dcta103_rel.uactua
                        END,
                    factua = TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
             'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_dcta103_rel.id_cia
                    AND libro = rec_dcta103_rel.libro
                    AND periodo = rec_dcta103_rel.periodo
                    AND mes = rec_dcta103_rel.mes
                    AND secuencia = rec_dcta103_rel.secuencia
                    AND item = rec_dcta103_rel.item;

            WHEN 3 THEN
                v_accion := 'La eliminacion';
                DELETE FROM dcta103_rel
                WHERE
                        id_cia = rec_dcta103_rel.id_cia
                    AND libro = rec_dcta103_rel.libro
                    AND periodo = rec_dcta103_rel.periodo
                    AND mes = rec_dcta103_rel.mes
                    AND secuencia = rec_dcta103_rel.secuencia
                    AND item = rec_dcta103_rel.item;

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
                    'message' VALUE 'El registro con codigo de DCTA103 [ '
                                    || rec_dcta103_rel.libro
                                    || ' '
                                    || rec_dcta103_rel.periodo
                                    || '-'
                                    || rec_dcta103_rel.mes
                                    || ' '
                                    || rec_dcta103_rel.secuencia
                                    || '-'
                                    || rec_dcta103_rel.item
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
--                                        || rec_dcta103_rel.secuencia
--                                        || ' - '
--                                        || rec_dcta103_rel.item
--                                        || ' ] no existe ...! '
--                    )
--                INTO pin_mensaje
--                FROM
--                    dual;

--            ELSE
            pin_mensaje := 'mensaje : '
                           || sqlerrm
                           || ' item :'
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
    END sp_save_rel;

    FUNCTION sp_obtener_aprobacion (
        pin_id_cia    NUMBER,
        pin_libro     VARCHAR2,
        pin_periodo   NUMBER,
        pin_mes       NUMBER,
        pin_secuencia NUMBER,
        pin_item      NUMBER,
        pin_numint    NUMBER,
        pin_tipo      NUMBER
    ) RETURN datatable_dcta103_aprobacion
        PIPELINED
    AS
        v_table datatable_dcta103_aprobacion;
    BEGIN
        SELECT
            da.*
        BULK COLLECT
        INTO v_table
        FROM
            dcta103_aprobacion da
        WHERE
                da.id_cia = pin_id_cia
            AND da.libro = pin_libro
            AND da.periodo = pin_periodo
            AND da.mes = pin_mes
            AND da.secuencia = pin_secuencia
            AND da.item = da.item
            AND da.numint = da.numint
            AND da.tipo = da.tipo;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener_aprobacion;

    FUNCTION sp_buscar_aprobacion (
        pin_id_cia    NUMBER,
        pin_libro     VARCHAR2,
        pin_periodo   NUMBER,
        pin_mes       NUMBER,
        pin_secuencia NUMBER,
        pin_item      NUMBER,
        pin_numint    NUMBER,
        pin_tipo      NUMBER
    ) RETURN datatable_dcta103_aprobacion
        PIPELINED
    AS
        v_table datatable_dcta103_aprobacion;
    BEGIN
        SELECT
            da.*
        BULK COLLECT
        INTO v_table
        FROM
            dcta103_aprobacion da
        WHERE
                da.id_cia = pin_id_cia
            AND ( pin_libro IS NULL
                  OR da.libro = pin_libro )
            AND ( pin_periodo IS NULL
                  OR pin_periodo = - 1
                  OR da.periodo = pin_periodo )
            AND ( pin_mes IS NULL
                  OR pin_mes = - 1
                  OR da.mes = pin_mes )
            AND ( pin_secuencia IS NULL
                  OR pin_secuencia = - 1
                  OR da.secuencia = pin_secuencia )
            AND ( pin_item IS NULL
                  OR pin_item = - 1
                  OR da.item = pin_item )
            AND ( pin_numint IS NULL
                  OR pin_numint = - 1
                  OR da.numint = pin_numint )
            AND ( pin_tipo IS NULL
                  OR pin_tipo = - 1
                  OR da.tipo = pin_tipo );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar_aprobacion;

--set SERVEROUTPUT on;
--
--DECLARE
--    mensaje VARCHAR2(500);
--    cadjson VARCHAR2(5000);
--BEGIN
--cadjson := '{
--                "libro":"10",
--                "periodo":2022,
--                "mes":10,
--                "secuencia":1,
--                "item":1,
--                "numint":165432,
--                "tipo":1,
--                "comentario":"Prueba",
--                "codopera":"admin",
--                "codaprob":"admin",
--                "ventero":1,
--                "vreal":1.52,
--                "vstrg":"Hola",
--                "vchar":"S",
--                "vdate":"2022-01-01",
--                "vtime":"",
--                "ucreac":"Admin",
--                "uactua":"Admin"
--                }';
--pack_dcta103.sp_save_aprobacion(66, cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_dcta103.sp_obtener_aprobacion(66,'10',2022,10,1,1,165432,1);
--
--SELECT * FROM pack_dcta103.sp_buscar_aprobacion(66,'10',NULL,NULL,NULL,NULL,NULL,NULL);
--
--SELECT * FROM pack_dcta103.sp_planilla_banco(66,0);

    PROCEDURE sp_save_aprobacion (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS
        o                      json_object_t;
        rec_dcta103_aprobacion dcta103_aprobacion%rowtype;
        v_accion               VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_dcta103_aprobacion.id_cia := pin_id_cia;
        rec_dcta103_aprobacion.libro := o.get_string('libro');
        rec_dcta103_aprobacion.periodo := o.get_number('periodo');
        rec_dcta103_aprobacion.mes := o.get_number('mes');
        rec_dcta103_aprobacion.secuencia := o.get_number('secuencia');
        rec_dcta103_aprobacion.item := o.get_number('item');
        rec_dcta103_aprobacion.numint := o.get_number('numint');
        rec_dcta103_aprobacion.tipo := o.get_number('tipo');
        rec_dcta103_aprobacion.comentario := o.get_string('comentario');
        rec_dcta103_aprobacion.codopera := o.get_string('codopera');
        rec_dcta103_aprobacion.codaprob := o.get_string('codaprob');
        rec_dcta103_aprobacion.ventero := o.get_string('ventero');
        rec_dcta103_aprobacion.vreal := o.get_number('vreal');
        rec_dcta103_aprobacion.vstrg := o.get_string('vstrg');
        rec_dcta103_aprobacion.vchar := o.get_string('vchar');
        rec_dcta103_aprobacion.vdate := o.get_date('vdate');
        rec_dcta103_aprobacion.vtime := o.get_timestamp('v_time');
        rec_dcta103_aprobacion.ucreac := o.get_string('ucreac');
        rec_dcta103_aprobacion.uactua := o.get_string('uactua');
        v_accion := '';
        CASE pin_opcdml
            WHEN 1 THEN
                v_accion := 'La insercion';
                INSERT INTO dcta103_aprobacion (
                    id_cia,
                    libro,
                    periodo,
                    mes,
                    secuencia,
                    item,
                    numint,
                    tipo,
                    comentario,
                    codopera,
                    codaprob,
                    ventero,
                    vreal,
                    vstrg,
                    vchar,
                    vdate,
                    vtime,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_dcta103_aprobacion.id_cia,
                    rec_dcta103_aprobacion.libro,
                    rec_dcta103_aprobacion.periodo,
                    rec_dcta103_aprobacion.mes,
                    rec_dcta103_aprobacion.secuencia,
                    rec_dcta103_aprobacion.item,
                    rec_dcta103_aprobacion.numint,
                    rec_dcta103_aprobacion.tipo,
                    rec_dcta103_aprobacion.comentario,
                    rec_dcta103_aprobacion.codopera,
                    rec_dcta103_aprobacion.codaprob,
                    rec_dcta103_aprobacion.ventero,
                    rec_dcta103_aprobacion.vreal,
                    rec_dcta103_aprobacion.vstrg,
                    rec_dcta103_aprobacion.vchar,
                    rec_dcta103_aprobacion.vdate,
                    rec_dcta103_aprobacion.vtime,
                    rec_dcta103_aprobacion.ucreac,
                    rec_dcta103_aprobacion.uactua,
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS'),
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS')
                );

            WHEN 2 THEN
                v_accion := 'La actualizacion';
                UPDATE dcta103_aprobacion
                SET
                    comentario =
                        CASE
                            WHEN rec_dcta103_aprobacion.comentario IS NULL THEN
                                comentario
                            ELSE
                                rec_dcta103_aprobacion.comentario
                        END,
                    codopera =
                        CASE
                            WHEN rec_dcta103_aprobacion.codopera IS NULL THEN
                                codopera
                            ELSE
                                rec_dcta103_aprobacion.codopera
                        END,
                    codaprob =
                        CASE
                            WHEN rec_dcta103_aprobacion.codaprob IS NULL THEN
                                codaprob
                            ELSE
                                rec_dcta103_aprobacion.codaprob
                        END,
                    ventero =
                        CASE
                            WHEN rec_dcta103_aprobacion.ventero IS NULL THEN
                                ventero
                            ELSE
                                rec_dcta103_aprobacion.ventero
                        END,
                    vreal =
                        CASE
                            WHEN rec_dcta103_aprobacion.vreal IS NULL THEN
                                vreal
                            ELSE
                                rec_dcta103_aprobacion.vreal
                        END,
                    vstrg =
                        CASE
                            WHEN rec_dcta103_aprobacion.vstrg IS NULL THEN
                                vstrg
                            ELSE
                                rec_dcta103_aprobacion.vstrg
                        END,
                    vchar =
                        CASE
                            WHEN rec_dcta103_aprobacion.vchar IS NULL THEN
                                vchar
                            ELSE
                                rec_dcta103_aprobacion.vchar
                        END,
                    vdate =
                        CASE
                            WHEN rec_dcta103_aprobacion.vdate IS NULL THEN
                                vdate
                            ELSE
                                rec_dcta103_aprobacion.vdate
                        END,
                    vtime =
                        CASE
                            WHEN rec_dcta103_aprobacion.vtime IS NULL THEN
                                vtime
                            ELSE
                                rec_dcta103_aprobacion.vtime
                        END,
                    uactua =
                        CASE
                            WHEN rec_dcta103_aprobacion.uactua IS NULL THEN
                                uactua
                            ELSE
                                rec_dcta103_aprobacion.uactua
                        END,
                    factua = TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
             'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_dcta103_aprobacion.id_cia
                    AND libro = rec_dcta103_aprobacion.libro
                    AND periodo = rec_dcta103_aprobacion.periodo
                    AND mes = rec_dcta103_aprobacion.mes
                    AND secuencia = rec_dcta103_aprobacion.secuencia
                    AND item = rec_dcta103_aprobacion.item
                    AND numint = rec_dcta103_aprobacion.numint
                    AND tipo = rec_dcta103_aprobacion.tipo;

            WHEN 3 THEN
                v_accion := 'La eliminacion';
                DELETE FROM dcta103_aprobacion
                WHERE
                        id_cia = rec_dcta103_aprobacion.id_cia
                    AND libro = rec_dcta103_aprobacion.libro
                    AND periodo = rec_dcta103_aprobacion.periodo
                    AND mes = rec_dcta103_aprobacion.mes
                    AND secuencia = rec_dcta103_aprobacion.secuencia
                    AND item = rec_dcta103_aprobacion.item
                    AND numint = rec_dcta103_aprobacion.numint
                    AND tipo = rec_dcta103_aprobacion.tipo;

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
                    'message' VALUE 'El registro con codigo de DCTA103 [ '
                                    || rec_dcta103_aprobacion.libro
                                    || ' '
                                    || rec_dcta103_aprobacion.periodo
                                    || '-'
                                    || rec_dcta103_aprobacion.mes
                                    || ' '
                                    || rec_dcta103_aprobacion.secuencia
                                    || '-'
                                    || rec_dcta103_aprobacion.item
                                    || ' '
                                    || rec_dcta103_aprobacion.numint
                                    || '-'
                                    || rec_dcta103_aprobacion.tipo
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
--                                        || rec_dcta103_aprobacion.secuencia
--                                        || ' - '
--                                        || rec_dcta103_aprobacion.item
--                                        || ' ] no existe ...! '
--                    )
--                INTO pin_mensaje
--                FROM
--                    dual;

--            ELSE
            pin_mensaje := 'mensaje : '
                           || sqlerrm
                           || ' item :'
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

    END sp_save_aprobacion;

    FUNCTION sp_planilla_banco (
        pin_id_cia NUMBER,
        pin_tippla NUMBER
    ) RETURN datatable_planilla_banco
        PIPELINED
    AS
        v_table datatable_planilla_banco;
    BEGIN
        SELECT DISTINCT
            d3.id_cia,
            d3.libro,
            d3.periodo,
            d3.mes,
            d3.secuencia,
            d2.concep,
            d2.dia,
            d2.situac,
            d2.femisi,
            d2.referencia,
            CASE
                WHEN d2.conpag = 1 THEN
                    'Cobranza'
                ELSE
                    CASE
                        WHEN d2.conpag = 2 THEN
                                'Descuento'
                        ELSE
                            CASE
                                WHEN d2.conpag = 3 THEN
                                            'Garantia'
                                ELSE
                                    'No definido'
                            END
                    END
            END AS tipenvio
        BULK COLLECT
        INTO v_table
        FROM
            dcta102            d2
            LEFT OUTER JOIN dcta103            d3 ON d3.id_cia = d2.id_cia
                                          AND d3.libro = d2.libro
                                          AND d3.periodo = d2.periodo
                                          AND d3.mes = d2.mes
                                          AND d3.secuencia = d2.secuencia
            LEFT OUTER JOIN dcta103_rel        dr ON dr.id_cia = d3.id_cia
                                              AND dr.r_libro = d3.libro
                                              AND dr.r_periodo = d3.periodo
                                              AND dr.r_mes = d3.mes
                                              AND dr.r_secuencia = d3.secuencia
                                              AND dr.r_item = d3.item
            LEFT OUTER JOIN dcta102_aprobacion da ON da.id_cia = d2.id_cia
                                                     AND da.libro = d2.libro
                                                     AND da.periodo = d2.periodo
                                                     AND da.mes = d2.mes
                                                     AND da.secuencia = d2.secuencia
                                                     AND da.tipo = 1
        WHERE
                d2.id_cia = pin_id_cia
            AND d2.tippla = pin_tippla
            AND d2.situac = 'B'
            AND ( dr.libro IS NULL )
            AND ( da.vdate IS NOT NULL )
            AND d2.conpag = 2
            AND d2.codcob = 2;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_planilla_banco;

    FUNCTION sp_formato_bcp (
        pin_id_cia    NUMBER,
        pin_libro     VARCHAR2,
        pin_periodo   NUMBER,
        pin_mes       NUMBER,
        pin_secuencia NUMBER
    ) RETURN datatable_formato_bcp
        PIPELINED
    AS
        v_table datatable_formato_bcp;
    BEGIN
        SELECT
            p.id_cia,
            d.codcli,
            c.razonc,
            ct1.apepat,
            ct1.apemat,
            ct1.nombre,
            c.dident,
            p.docume,
            i.codsunat AS tident_codsunat,
            d.fvenci,
            p.amorti
        BULK COLLECT
        INTO
        v_table
        FROM
            dcta103          p
            LEFT OUTER JOIN dcta100          d ON d.id_cia = p.id_cia
                                         AND d.numint = p.numint
            LEFT OUTER JOIN cliente          c ON c.id_cia = d.id_cia
                                         AND c.codcli = d.codcli
            LEFT OUTER JOIN identidad        i ON i.id_cia = c.id_cia
                                           AND i.tident = c.tident
            LEFT OUTER JOIN cliente_tpersona ct1 ON ct1.id_cia = d.id_cia
                                                    AND ct1.codcli = d.codcli
        WHERE
                p.id_cia = pin_id_cia
            AND p.libro = pin_libro
            AND p.periodo = pin_periodo
            AND p.mes = pin_mes
            AND p.secuencia = pin_secuencia;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END;

END;

/

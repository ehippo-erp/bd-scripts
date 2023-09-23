--------------------------------------------------------
--  DDL for Package Body PACK_DW_CVENTAS_MENSUAL_META
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_DW_CVENTAS_MENSUAL_META" AS

    FUNCTION sp_obtener (
        pin_id_cia  NUMBER,
        pin_codsuc  NUMBER,
        pin_periodo NUMBER,
        pin_idmes   NUMBER
    ) RETURN datatable_dw_cventas_mensual_meta
        PIPELINED
    AS
        v_table datatable_dw_cventas_mensual_meta;
    BEGIN
        SELECT
            p.id_cia,
            p.codsuc,
            CASE
                WHEN p.codsuc = 0 THEN
                    'Todas las Sucursales'
                ELSE
                    s.sucursal
            END AS sucursal,
            p.periodo,
            p.idmes,
            p.mes,
            p.mesid,
            p.meta01,
            p.meta02,
            p.ucreac,
            p.uactua,
            p.fcreac,
            p.factua
        BULK COLLECT
        INTO v_table
        FROM
            dw_cventas_mensual_meta p
            LEFT OUTER JOIN sucursal                s ON s.id_cia = p.id_cia
                                          AND s.codsuc = p.codsuc
        WHERE
                p.id_cia = pin_id_cia
            AND p.codsuc = 0
            AND p.periodo = pin_periodo
            AND p.idmes = pin_idmes;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia  NUMBER,
        pin_codsuc  NUMBER,
        pin_periodo NUMBER
    ) RETURN datatable_dw_cventas_mensual_meta
        PIPELINED
    AS
        v_table datatable_dw_cventas_mensual_meta;
    BEGIN
        SELECT
            p.id_cia,
            p.codsuc,
            CASE
                WHEN p.codsuc = 0 THEN
                    'Todas las Sucursales'
                ELSE
                    s.sucursal
            END AS sucursal,
            p.periodo,
            p.idmes,
            p.mes,
            p.mesid,
            p.meta01,
            p.meta02,
            p.ucreac,
            p.uactua,
            p.fcreac,
            p.factua
        BULK COLLECT
        INTO v_table
        FROM
            dw_cventas_mensual_meta p
            LEFT OUTER JOIN sucursal                s ON s.id_cia = p.id_cia
                                          AND s.codsuc = p.codsuc
        WHERE
                p.id_cia = pin_id_cia
            AND p.codsuc = 0
            AND ( pin_periodo IS NULL
                  OR pin_periodo = - 1
                  OR p.periodo = pin_periodo )
        ORDER BY
            p.mesid ASC;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar;

--set SERVEROUTPUT on;
--/
--DECLARE
--    mensaje VARCHAR2(500);
--    cadjson VARCHAR2(5000);
--BEGIN
--cadjson := '{
--                "codsuc":1,
--                "periodo":2022,
--                "idmes":10,
--                "meta01":400266.77,
--                "meta02":89059.05,
--                "ucreac":"Admin",
--                "uactua":"Admin"
--                }';
--pack_dw_cventas_mensual_meta.sp_save(66, cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--/
--SELECT * FROM pack_dw_cventas_mensual_meta.sp_obtener(66,1,2022,1);
--/
--SELECT * FROM pack_dw_cventas_mensual_meta.sp_buscar(66,1,2022);

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS

        o                           json_object_t;
        rec_dw_cventas_mensual_meta dw_cventas_mensual_meta%rowtype;
        v_accion                    VARCHAR2(50) := '';
        pout_mensaje                VARCHAR2(1000) := '';
        v_idmes                     NUMBER := 0;
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_dw_cventas_mensual_meta.id_cia := pin_id_cia;
        rec_dw_cventas_mensual_meta.codsuc := 0;
        rec_dw_cventas_mensual_meta.periodo := o.get_number('periodo');
        rec_dw_cventas_mensual_meta.idmes := o.get_number('idmes');
        rec_dw_cventas_mensual_meta.meta01 := o.get_number('meta01');
        rec_dw_cventas_mensual_meta.meta02 := o.get_number('meta02');
        rec_dw_cventas_mensual_meta.ucreac := o.get_string('ucreac');
        rec_dw_cventas_mensual_meta.uactua := o.get_string('uactua');
        v_accion := '';
        CASE pin_opcdml
            WHEN 1 THEN
                v_accion := 'La inserción';
                INSERT INTO dw_cventas_mensual_meta (
                    id_cia,
                    codsuc,
                    periodo,
                    idmes,
                    mes,
                    mesid,
                    meta01,
                    meta02,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_dw_cventas_mensual_meta.id_cia,
                    rec_dw_cventas_mensual_meta.codsuc,
                    rec_dw_cventas_mensual_meta.periodo,
                    rec_dw_cventas_mensual_meta.idmes,
                    upper(to_char(to_date(rec_dw_cventas_mensual_meta.idmes, 'MM'), 'month', 'nls_date_language=spanish')),
                    ( rec_dw_cventas_mensual_meta.periodo * 100 ) + rec_dw_cventas_mensual_meta.idmes,
                    rec_dw_cventas_mensual_meta.meta01,
                    rec_dw_cventas_mensual_meta.meta02,
                    rec_dw_cventas_mensual_meta.ucreac,
                    rec_dw_cventas_mensual_meta.uactua,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                );

            WHEN 2 THEN
                v_accion := 'La actualización';
                UPDATE dw_cventas_mensual_meta
                SET
                    meta01 =
                        CASE
                            WHEN rec_dw_cventas_mensual_meta.meta01 IS NULL THEN
                                meta01
                            ELSE
                                rec_dw_cventas_mensual_meta.meta01
                        END,
                    meta02 =
                        CASE
                            WHEN rec_dw_cventas_mensual_meta.meta02 IS NULL THEN
                                meta02
                            ELSE
                                rec_dw_cventas_mensual_meta.meta02
                        END,
                    uactua =
                        CASE
                            WHEN rec_dw_cventas_mensual_meta.uactua IS NULL THEN
                                uactua
                            ELSE
                                rec_dw_cventas_mensual_meta.uactua
                        END,
                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_dw_cventas_mensual_meta.id_cia
                    AND codsuc = rec_dw_cventas_mensual_meta.codsuc
                    AND periodo = rec_dw_cventas_mensual_meta.periodo
                    AND idmes = rec_dw_cventas_mensual_meta.idmes;

            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM dw_cventas_mensual_meta
                WHERE
                        id_cia = rec_dw_cventas_mensual_meta.id_cia
                    AND codsuc = rec_dw_cventas_mensual_meta.codsuc
                    AND periodo = rec_dw_cventas_mensual_meta.periodo
                    AND idmes = rec_dw_cventas_mensual_meta.idmes;

        END CASE;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE v_accion || ' se realizó satisfactoriamente...!'
            )
        INTO pin_mensaje
        FROM
            dual;

        COMMIT;
    EXCEPTION
        WHEN dup_val_on_index THEN
--            SELECT
--                JSON_OBJECT(
--                    'status' VALUE 1.1,
--                    'message' VALUE 'El registro con codigo de 
--                                    Sucursal [ '
--                                    || rec_dw_cventas_mensual_meta.codsuc
--                                    || ' ], con
--                                    el Periodo [ '
--                                    || rec_dw_cventas_mensual_meta.periodo
--                                    || ' ] y con el Mes [ '
--                                    || upper(to_char(to_date(rec_dw_cventas_mensual_meta.idmes, 'MM'), 'month', 'nls_date_language=spanish'))
--                                    || ' ] ya existe y no puede duplicarse ...!'
--                )
--            INTO pin_mensaje
--            FROM
--                dual;
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE 'El registro con el Periodo [ '
                                    || rec_dw_cventas_mensual_meta.periodo
                                    || ' ] y con el Mes [ '
                                    || TRIM(upper(to_char(to_date(rec_dw_cventas_mensual_meta.idmes, 'MM'), 'month', 'nls_date_language=spanish')))
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
            IF sqlcode = -2291 THEN
                SELECT
                    JSON_OBJECT(
                        'status' VALUE 1.1,
                        'message' VALUE 'No se insertar o modificar este registro porque el codigo de Sucursal [ '
                                        || rec_dw_cventas_mensual_meta.codsuc
                                        || ' ] no existe ...! '
                    )
                INTO pin_mensaje
                FROM
                    dual;

                NULL;
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
    END sp_save;

    PROCEDURE sp_elimina (
        pin_id_cia  IN NUMBER,
        pin_codsuc  IN NUMBER,
        pin_periodo IN NUMBER
    ) AS
    BEGIN
        DELETE FROM dw_cventas_mensual_meta
        WHERE
                id_cia = pin_id_cia
            AND codsuc = 0
            AND periodo = pin_periodo;

                COMMIT;
    END sp_elimina;

    FUNCTION sp_valida_objeto (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER,
        pin_datos   CLOB
    ) RETURN datatable
        PIPELINED
    AS

        o                           json_object_t;
        reg_errores                 r_errores := r_errores(NULL, NULL);
        rec_dw_cventas_mensual_meta dw_cventas_mensual_meta%rowtype;
        v_accion                    VARCHAR2(50) := '';
        pout_mensaje                VARCHAR2(1000) := '';
        v_idmes                     NUMBER := 0;
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_dw_cventas_mensual_meta.id_cia := pin_id_cia;
        rec_dw_cventas_mensual_meta.codsuc := 0;
        rec_dw_cventas_mensual_meta.periodo := o.get_number('periodo');
        rec_dw_cventas_mensual_meta.idmes := o.get_number('idmes');
        rec_dw_cventas_mensual_meta.meta01 := o.get_number('meta01');
        rec_dw_cventas_mensual_meta.meta02 := o.get_number('meta02');
        rec_dw_cventas_mensual_meta.ucreac := o.get_string('ucreac');
        rec_dw_cventas_mensual_meta.uactua := o.get_string('uactua');
        v_accion := '';
        IF rec_dw_cventas_mensual_meta.periodo <> pin_periodo THEN
            reg_errores.valor := rec_dw_cventas_mensual_meta.periodo;
            reg_errores.deserror := 'El Periodo [ '
                                    || rec_dw_cventas_mensual_meta.periodo
                                    || ' ] no coincide con el Periodo Seleccionado [ '
                                    || pin_periodo
                                    || ' ]';

            PIPE ROW ( reg_errores );
        END IF;

        IF rec_dw_cventas_mensual_meta.idmes < 1 OR rec_dw_cventas_mensual_meta.idmes > 12 THEN
            reg_errores.valor := rec_dw_cventas_mensual_meta.idmes;
            reg_errores.deserror := 'El IDMes no Existe [ '
                                    || rec_dw_cventas_mensual_meta.idmes
                                    || ' ] debe tener un valor entre 1 y 12';
            PIPE ROW ( reg_errores );
        END IF;

    END sp_valida_objeto;

END;

/

--------------------------------------------------------
--  DDL for Package Body PACK_PERIODO_COMISION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_PERIODO_COMISION" AS

    FUNCTION sp_obtener (
        pin_id_cia     NUMBER,
        pin_id_periodo NUMBER
    ) RETURN datatable_periodo_comision
        PIPELINED
    AS
        v_table datatable_periodo_comision;
    BEGIN
        SELECT
            p.id_cia,
            p.id_periodo,
            p.despercom,
            p.periodo,
            p.mes,
            CASE
                WHEN ( p.mes > 0
                       AND p.mes < 13 ) THEN
                    upper(to_char(to_date(p.mes, 'MM'), 'month', 'nls_date_language=spanish'))
                ELSE
                    'ND'
            END,
            p.finicio,
            p.ffin,
            p.situac,
            p.ucreac,
            p.uactua,
            p.fcreac,
            p.factua
        BULK COLLECT
        INTO v_table
        FROM
            periodo_comision p
        WHERE
                p.id_cia = pin_id_cia
            AND p.id_periodo = pin_id_periodo;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER,
        pin_mes     NUMBER
    ) RETURN datatable_periodo_comision
        PIPELINED
    AS
        v_table datatable_periodo_comision;
    BEGIN
        SELECT
            p.id_cia,
            p.id_periodo,
            p.despercom,
            p.periodo,
            p.mes,
            CASE
                WHEN ( p.mes > 0
                       AND p.mes < 13 ) THEN
                    upper(to_char(to_date(p.mes, 'MM'), 'month', 'nls_date_language=spanish'))
                ELSE
                    'ND'
            END,
            p.finicio,
            p.ffin,
            p.situac,
            p.ucreac,
            p.uactua,
            p.fcreac,
            p.factua
        BULK COLLECT
        INTO v_table
        FROM
            periodo_comision p
        WHERE
                p.id_cia = pin_id_cia
            AND p.periodo = pin_periodo
            AND ( pin_mes = - 1
                  OR p.mes = pin_mes );

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
--                "id_periodo":202301,
--                "despercom":"ENERO - 2023",
--                "periodo":2023,
--                "mes":1,
--                "finicio":"2023-01-05",
--                "ffin":"2023-02-05",
--                "situac":"S",
--                "ucreac":"admin",
--                "uactua":"admin"
--                }';
--pack_periodo_comision.sp_save(66, cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_periodo_comision.sp_obtener(66,202301);
--
--SELECT * FROM pack_periodo_comision.sp_buscar(66,2023,01);

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS

        o                    json_object_t;
        rec_periodo_comision periodo_comision%rowtype;
        v_accion             VARCHAR2(50) := '';
        pout_mensaje         VARCHAR2(1000) := '';
        v_periodo            NUMBER := 0;
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_periodo_comision.id_cia := pin_id_cia;
        rec_periodo_comision.id_periodo := o.get_number('id_periodo');
        rec_periodo_comision.despercom := o.get_string('despercom');
        rec_periodo_comision.periodo := o.get_number('periodo');
        rec_periodo_comision.mes := o.get_number('mes');
        rec_periodo_comision.finicio := o.get_date('finicio');
        rec_periodo_comision.ffin := o.get_date('ffin');
        rec_periodo_comision.situac := o.get_string('situac');
        rec_periodo_comision.ucreac := o.get_string('ucreac');
        rec_periodo_comision.uactua := o.get_string('uactua');
        v_accion := '';
        CASE pin_opcdml
            WHEN 1 THEN
                v_accion := 'La inserción';
                INSERT INTO periodo_comision (
                    id_cia,
                    id_periodo,
                    despercom,
                    periodo,
                    mes,
                    finicio,
                    ffin,
                    situac,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_periodo_comision.id_cia,
                    rec_periodo_comision.id_periodo,
                    rec_periodo_comision.despercom,
                    rec_periodo_comision.periodo,
                    rec_periodo_comision.mes,
--                    upper(to_char(to_date(rec_periodo_comision.periodo, 'MM'), 'month', 'nls_date_language=spanish')),
--                    ( rec_periodo_comision.periodo * 100 ) + rec_periodo_comision.periodo,
                    rec_periodo_comision.finicio,
                    rec_periodo_comision.ffin,
                    rec_periodo_comision.situac,
                    rec_periodo_comision.ucreac,
                    rec_periodo_comision.uactua,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                );

            WHEN 2 THEN
                v_accion := 'La actualización';
                UPDATE periodo_comision
                SET
                    despercom =
                        CASE
                            WHEN rec_periodo_comision.despercom IS NULL THEN
                                despercom
                            ELSE
                                rec_periodo_comision.despercom
                        END,
                    periodo =
                        CASE
                            WHEN rec_periodo_comision.periodo IS NULL THEN
                                periodo
                            ELSE
                                rec_periodo_comision.periodo
                        END,
                    mes =
                        CASE
                            WHEN rec_periodo_comision.mes IS NULL THEN
                                mes
                            ELSE
                                rec_periodo_comision.mes
                        END,
                    finicio =
                        CASE
                            WHEN rec_periodo_comision.finicio IS NULL THEN
                                finicio
                            ELSE
                                rec_periodo_comision.finicio
                        END,
                    ffin =
                        CASE
                            WHEN rec_periodo_comision.ffin IS NULL THEN
                                ffin
                            ELSE
                                rec_periodo_comision.ffin
                        END,
                    situac =
                        CASE
                            WHEN rec_periodo_comision.situac IS NULL THEN
                                situac
                            ELSE
                                rec_periodo_comision.situac
                        END,
                    uactua =
                        CASE
                            WHEN rec_periodo_comision.uactua IS NULL THEN
                                uactua
                            ELSE
                                rec_periodo_comision.uactua
                        END,
                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_periodo_comision.id_cia
                    AND id_periodo = rec_periodo_comision.id_periodo;

            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM periodo_comision
                WHERE
                        id_cia = rec_periodo_comision.id_cia
                    AND id_periodo = rec_periodo_comision.id_periodo;

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
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE 'El registro con codigo para el Periodo [ '
                                    || rec_periodo_comision.id_periodo
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
        pin_periodo IN NUMBER
    ) AS
    BEGIN
        DELETE FROM periodo_comision
        WHERE
                id_cia = pin_id_cia
            AND periodo = pin_periodo;

    END sp_elimina;

    FUNCTION sp_valida_objeto (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER,
        pin_datos   CLOB
    ) RETURN datatable
        PIPELINED
    AS

        o                    json_object_t;
        reg_errores          r_errores := r_errores(NULL, NULL);
        rec_periodo_comision periodo_comision%rowtype;
        v_periodo            NUMBER := 0;
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_periodo_comision.id_cia := pin_id_cia;
        rec_periodo_comision.id_periodo := o.get_number('id_periodo');
        rec_periodo_comision.despercom := o.get_string('despercom');
        rec_periodo_comision.periodo := o.get_number('periodo');
        rec_periodo_comision.mes := o.get_number('mes');
        rec_periodo_comision.finicio := o.get_date('finicio');
        rec_periodo_comision.ffin := o.get_date('ffin');
        rec_periodo_comision.situac := o.get_string('situac');
        rec_periodo_comision.ucreac := o.get_string('ucreac');
        rec_periodo_comision.uactua := o.get_string('uactua');
        IF rec_periodo_comision.periodo <> pin_periodo THEN
            reg_errores.valor := rec_periodo_comision.periodo;
            reg_errores.deserror := 'El Periodo [ '
                                    || rec_periodo_comision.periodo
                                    || ' ] no coincide con el Periodo Seleccionado [ '
                                    || pin_periodo
                                    || ' ]';

            PIPE ROW ( reg_errores );
        END IF;

        IF rec_periodo_comision.mes < 1 OR rec_periodo_comision.mes > 12 THEN
            reg_errores.valor := rec_periodo_comision.mes;
            reg_errores.deserror := 'El IDMes no Existe [ '
                                    || rec_periodo_comision.mes
                                    || ' ] debe tener un valor entre 1 y 12';
            PIPE ROW ( reg_errores );
        END IF;

        IF rec_periodo_comision.finicio IS NULL THEN
            reg_errores.valor := rec_periodo_comision.finicio;
            reg_errores.deserror := 'Ingrese una Fecha de Inicio para este Registro !';
        END IF;

        IF rec_periodo_comision.ffin IS NULL THEN
            reg_errores.valor := rec_periodo_comision.ffin;
            reg_errores.deserror := 'Ingrese una Fecha Final para este Registro !';
        END IF;

        PIPE ROW ( reg_errores );
    END sp_valida_objeto;

END;

/

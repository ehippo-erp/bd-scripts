--------------------------------------------------------
--  DDL for Package Body PACK_HR_ASISTENCIA_PLANILLA_FERIADOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_HR_ASISTENCIA_PLANILLA_FERIADOS" AS

    FUNCTION sp_obtener (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER,
        pin_fecha   DATE
    ) RETURN datatable_asistencia_planilla_feriados
        PIPELINED
    AS
        v_table datatable_asistencia_planilla_feriados;
    BEGIN
        SELECT
            pl.id_cia,
            pl.periodo,
            pl.fecha,
            pl.desfer,
            pl.fijvar,
            CASE
                WHEN pl.fijvar = 'F' THEN
                    'FIJO'
                WHEN pl.fijvar = 'V' THEN
                    'VARIABLE'
                ELSE
                    'ND'
            END,
            pl.situac,
            pl.ucreac,
            pl.uactua,
            pl.fcreac,
            pl.factua
        BULK COLLECT
        INTO v_table
        FROM
            asistencia_planilla_feriados pl
        WHERE
                pl.id_cia = pin_id_cia
            AND pl.periodo = pin_periodo
            AND pl.fecha = pin_fecha;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER,
        pin_fdesde  DATE,
        pin_fhasta  DATE
    ) RETURN datatable_asistencia_planilla_feriados
        PIPELINED
    AS
        v_table datatable_asistencia_planilla_feriados;
    BEGIN
        SELECT
            pl.id_cia,
            pl.periodo,
            pl.fecha,
            pl.desfer,
            pl.fijvar,
            CASE
                WHEN pl.fijvar = 'F' THEN
                    'FIJO'
                WHEN pl.fijvar = 'V' THEN
                    'VARIABLE'
                ELSE
                    'ND'
            END,
            pl.situac,
            pl.ucreac,
            pl.uactua,
            pl.fcreac,
            pl.factua
        BULK COLLECT
        INTO v_table
        FROM
            asistencia_planilla_feriados pl
        WHERE
                pl.id_cia = pin_id_cia
            AND ( pin_periodo IS NULL
                  OR pl.periodo = pin_periodo )
            AND ( ( pin_fdesde IS NULL
                    AND pin_fhasta IS NULL )
                  OR ( pl.fecha BETWEEN pin_fdesde AND pin_fhasta ) );

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
--                "periodo":2022,
--                "fecha":"2022-01-01",
--                "desfer":"Feliz Año Nuevo",
--                "ucreac":"Admin",
--                "uactua":"Admin"
--                }';
--pack_hr_asistencia_planilla_feriados.sp_save(66, cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_hr_asistencia_planilla_feriados.sp_obtener(66,2022,to_date('01/01/2022','DD/MM/YYYY'));
--
--SELECT * FROM pack_hr_asistencia_planilla_feriados.sp_buscar(66,NULL,NULL,NULL);

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS

        o                                json_object_t;
        rec_asistencia_planilla_feriados asistencia_planilla_feriados%rowtype;
        v_accion                         VARCHAR2(50) := '';
        pout_mensaje                     VARCHAR2(1000) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_asistencia_planilla_feriados.id_cia := pin_id_cia;
        rec_asistencia_planilla_feriados.periodo := o.get_number('periodo');
        rec_asistencia_planilla_feriados.fecha := o.get_date('fecha');
        rec_asistencia_planilla_feriados.periodo := extract(YEAR FROM rec_asistencia_planilla_feriados.fecha);
        rec_asistencia_planilla_feriados.desfer := o.get_string('desfer');
        rec_asistencia_planilla_feriados.fijvar := o.get_string('fijvar');
        rec_asistencia_planilla_feriados.ucreac := o.get_string('ucreac');
        rec_asistencia_planilla_feriados.uactua := o.get_string('uactua');
        v_accion := '';
        IF rec_asistencia_planilla_feriados.periodo IS NOT NULL THEN
            IF extract(YEAR FROM rec_asistencia_planilla_feriados.fecha) <> rec_asistencia_planilla_feriados.periodo THEN
                pout_mensaje := 'No se puede modificar o ingresar este registro porque la Fecha asignada [ '
                                || to_char(rec_asistencia_planilla_feriados.fecha, 'DD/MM/YYYY')
                                || ' ] no pertenece al Periodo [ '
                                || rec_asistencia_planilla_feriados.periodo
                                || ' ]';

                RAISE pkg_exceptionuser.ex_error_inesperado;
            END IF;
        END IF;

        CASE pin_opcdml
            WHEN 1 THEN
                v_accion := 'La insercion';
                INSERT INTO asistencia_planilla_feriados (
                    id_cia,
                    periodo,
                    fecha,
                    desfer,
                    fijvar,
                    situac,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_asistencia_planilla_feriados.id_cia,
                    rec_asistencia_planilla_feriados.periodo,
                    rec_asistencia_planilla_feriados.fecha,
                    rec_asistencia_planilla_feriados.desfer,
                    rec_asistencia_planilla_feriados.fijvar,
                    'S',
                    rec_asistencia_planilla_feriados.ucreac,
                    rec_asistencia_planilla_feriados.uactua,
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS'),
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS')
                );

            WHEN 2 THEN
                v_accion := 'La actualizacion';
                UPDATE asistencia_planilla_feriados
                SET
                    situac = 'S',
                    desfer =
                        CASE
                            WHEN rec_asistencia_planilla_feriados.desfer IS NULL THEN
                                desfer
                            ELSE
                                rec_asistencia_planilla_feriados.desfer
                        END,
                    fijvar =
                        CASE
                            WHEN rec_asistencia_planilla_feriados.fijvar IS NULL THEN
                                fijvar
                            ELSE
                                rec_asistencia_planilla_feriados.fijvar
                        END,
                    uactua =
                        CASE
                            WHEN rec_asistencia_planilla_feriados.uactua IS NULL THEN
                                uactua
                            ELSE
                                rec_asistencia_planilla_feriados.uactua
                        END,
                    factua = TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
             'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_asistencia_planilla_feriados.id_cia
                    AND periodo = rec_asistencia_planilla_feriados.periodo
                    AND fecha = rec_asistencia_planilla_feriados.fecha;

            WHEN 3 THEN
                v_accion := 'La eliminacion';
                DELETE FROM asistencia_planilla_feriados
                WHERE
                        id_cia = rec_asistencia_planilla_feriados.id_cia
                    AND periodo = rec_asistencia_planilla_feriados.periodo
                    AND fecha = rec_asistencia_planilla_feriados.fecha;

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
        WHEN pkg_exceptionuser.ex_error_inesperado THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE pout_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN dup_val_on_index THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE 'El registro con Periodo [ '
                                    || rec_asistencia_planilla_feriados.periodo
                                    || ' ] y Fecha [ '
                                    || rec_asistencia_planilla_feriados.fecha
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
            IF sqlcode = -2291 THEN
--                SELECT
--                    JSON_OBJECT(
--                        'status' VALUE 1.1,
--                        'message' VALUE 'No se insertar o modificar este registro porque el TipoItem [ '
--                                        || rec_asistencia_planilla_feriados.codtip
--                                        || ' - '
--                                        || rec_asistencia_planilla_feriados.codite
--                                        || ' ] no existe ...! '
--                    )
--                INTO pin_mensaje
--                FROM
--                    dual;
                NULL;
            ELSE
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

            END IF;
    END sp_save;

    PROCEDURE sp_replicar (
        pin_id_cia  IN NUMBER,
        pin_periodo IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS
    BEGIN
        INSERT INTO asistencia_planilla_feriados
            (
                SELECT
                    apf.id_cia,
                    pin_periodo,
                    add_months(apf.fecha, 12),
                    apf.desfer,
                    apf.fijvar,
                    CASE
                        WHEN apf.fijvar = 'F' THEN
                            'S'
                        ELSE
                            'N'
                    END,
                    pin_coduser,
                    pin_coduser,
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS'),
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS')
                FROM
                    asistencia_planilla_feriados apf
                WHERE
                        apf.id_cia = pin_id_cia
                    AND ( apf.periodo = pin_periodo - 1 )
                    AND NOT EXISTS (
                        SELECT
                            afp1.*
                        FROM
                            asistencia_planilla_feriados apf1
                        WHERE
                                apf1.id_cia = apf.id_cia
                            AND trunc(apf1.fecha) = trunc(add_months(apf.fecha, 12))
                            AND apf1.periodo = pin_periodo
                    )
            );

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'La replicación se realizo satisfactoriamente...!'
            )
        INTO pin_mensaje
        FROM
            dual;

        COMMIT;
    EXCEPTION
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

    END sp_replicar;

END;

/

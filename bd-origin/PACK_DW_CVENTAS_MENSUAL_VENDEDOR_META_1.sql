--------------------------------------------------------
--  DDL for Package Body PACK_DW_CVENTAS_MENSUAL_VENDEDOR_META
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_DW_CVENTAS_MENSUAL_VENDEDOR_META" AS

    FUNCTION sp_obtener (
        pin_id_cia  NUMBER,
        pin_codsuc  NUMBER,
        pin_codven  NUMBER,
        pin_periodo NUMBER,
        pin_idmes   NUMBER
    ) RETURN datatable_buscar
        PIPELINED
    AS
        v_table datatable_buscar;
    BEGIN
        SELECT
            vm.id_cia,
            vm.codven,
            v.desven,
            vm.periodo,
            vm.mes,
            CASE
                WHEN vm.mes <> 0 THEN
                    upper(to_char(to_date(vm.mes, 'MM'), 'month', 'nls_date_language=spanish'))
                ELSE
                    'TODOS'
            END,
            vm.periodo * 100 + vm.mes,
            vm.meta01,
            vm.meta02,
            vm.ucreac,
            vm.uactua,
            vm.fcreac,
            vm.factua
        BULK COLLECT
        INTO v_table
        FROM
            vendedor_metas vm
            LEFT OUTER JOIN vendedor       v ON v.id_cia = vm.id_cia
                                          AND v.codven = vm.codven
        WHERE
                vm.id_cia = pin_id_cia
            AND vm.codven = pin_codven
            AND vm.periodo = pin_periodo
            AND ( vm.mes = pin_idmes
                  AND vm.mes <> 0 );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia  NUMBER,
        pin_codsuc  NUMBER,
        pin_codven  NUMBER,
        pin_periodo NUMBER
    ) RETURN datatable_buscar
        PIPELINED
    AS
        v_table datatable_buscar;
    BEGIN
        SELECT
            vm.id_cia,
            vm.codven,
            v.desven,
            vm.periodo,
            vm.mes,
            CASE
                WHEN vm.mes <> 0 THEN
                    upper(to_char(to_date(vm.mes, 'MM'), 'month', 'nls_date_language=spanish'))
                ELSE
                    'TODOS'
            END,
            vm.periodo * 100 + vm.mes,
            vm.meta01,
            vm.meta02,
            vm.ucreac,
            vm.uactua,
            vm.fcreac,
            vm.factua
        BULK COLLECT
        INTO v_table
        FROM
            vendedor_metas vm
            LEFT OUTER JOIN vendedor       v ON v.id_cia = vm.id_cia
                                          AND v.codven = vm.codven
        WHERE
                vm.id_cia = pin_id_cia
            AND ( pin_codven = - 1
                  OR vm.codven = pin_codven )
            AND ( pin_periodo = - 1
                  OR vm.periodo = pin_periodo )
            AND vm.mes <> 0;

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
--                "idmes":12,
--                "codven":1,
--                "meta01":800266.77,
--                "meta02":809059.05 
--                }';
--pack_dw_cventas_mensual_vendedor_meta.sp_save(66, cadjson, 3, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_dw_cventas_mensual_vendedor_meta.sp_obtener(66,NULL,1,2022,12);
--
--SELECT * FROM pack_dw_cventas_mensual_vendedor_meta.sp_buscar(66,NULL,1,2022);

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS

        o                  json_object_t;
        rec_vendedor_metas vendedor_metas%rowtype;
        v_accion           VARCHAR2(50) := '';
        pout_mensaje       VARCHAR2(1000) := '';
        v_idmes            NUMBER := 0;
        v_meta01           NUMBER(20, 8);
        v_meta02           NUMBER(20, 8);
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_vendedor_metas.id_cia := pin_id_cia;
        rec_vendedor_metas.periodo := o.get_number('periodo');
        rec_vendedor_metas.mes := o.get_number('idmes');
        rec_vendedor_metas.codven := o.get_number('codven');
        rec_vendedor_metas.meta01 := o.get_number('meta01');
        rec_vendedor_metas.meta02 := o.get_number('meta02');
        rec_vendedor_metas.ucreac := o.get_string('ucreac');
        rec_vendedor_metas.uactua := o.get_string('uactua');
        v_accion := '';
        CASE pin_opcdml
            WHEN 1 THEN
                v_accion := 'La inserción';
                INSERT INTO vendedor_metas (
                    id_cia,
                    codven,
                    periodo,
                    mes,
                    meta01,
                    meta02,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_vendedor_metas.id_cia,
                    rec_vendedor_metas.codven,
                    rec_vendedor_metas.periodo,
                    rec_vendedor_metas.mes,
                    rec_vendedor_metas.meta01,
                    rec_vendedor_metas.meta02,
                    rec_vendedor_metas.ucreac,
                    rec_vendedor_metas.uactua,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                );

            WHEN 2 THEN
                v_accion := 'La actualización';
                UPDATE vendedor_metas
                SET
                    meta01 =
                        CASE
                            WHEN rec_vendedor_metas.meta01 IS NULL THEN
                                meta01
                            ELSE
                                rec_vendedor_metas.meta01
                        END,
                    meta02 =
                        CASE
                            WHEN rec_vendedor_metas.meta02 IS NULL THEN
                                meta02
                            ELSE
                                rec_vendedor_metas.meta02
                        END,
                    uactua =
                        CASE
                            WHEN rec_vendedor_metas.uactua IS NULL THEN
                                uactua
                            ELSE
                                rec_vendedor_metas.uactua
                        END,
                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_vendedor_metas.id_cia
                    AND periodo = rec_vendedor_metas.periodo
                    AND mes = rec_vendedor_metas.mes
                    AND codven = rec_vendedor_metas.codven;

            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM vendedor_metas
                WHERE
                        id_cia = rec_vendedor_metas.id_cia
                    AND periodo = rec_vendedor_metas.periodo
                    AND mes = rec_vendedor_metas.mes
                    AND codven = rec_vendedor_metas.codven;

        END CASE;

        COMMIT;
        BEGIN
            SELECT
                SUM(meta01),
                SUM(meta02)
            INTO
                v_meta01,
                v_meta02
            FROM
                vendedor_metas
            WHERE
                    id_cia = rec_vendedor_metas.id_cia
                AND codven = rec_vendedor_metas.codven
                AND periodo = rec_vendedor_metas.periodo
                AND mes <> 0;

        EXCEPTION
            WHEN no_data_found THEN
                v_meta01 := 0;
                v_meta02 := 0;
        END;

        DELETE FROM vendedor_metas
        WHERE
                id_cia = rec_vendedor_metas.id_cia
            AND codven = rec_vendedor_metas.codven
            AND periodo = rec_vendedor_metas.periodo
            AND mes = 0;

        INSERT INTO vendedor_metas (
            id_cia,
            codven,
            periodo,
            mes,
            meta01,
            meta02,
            ucreac,
            uactua,
            fcreac,
            factua
        ) VALUES (
            rec_vendedor_metas.id_cia,
            rec_vendedor_metas.codven,
            rec_vendedor_metas.periodo,
            0,
            v_meta01,
            v_meta02,
            rec_vendedor_metas.ucreac,
            rec_vendedor_metas.uactua,
            to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
            to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
        );
--        MERGE INTO vendedor_metas ori
--        USING vendedor_metas des ON ( ori.id_cia = rec_vendedor_metas.id_cia
--                                      AND ori.codven = rec_vendedor_metas.codven
--                                      AND ori.periodo = rec_vendedor_metas.periodo
--                                      AND ori.mes = 0 )
--        WHEN MATCHED THEN UPDATE
--        SET ori.meta01 = v_meta01,
--            ori.meta02 = v_meta02
--        WHEN NOT MATCHED THEN
--        INSERT (
--            id_cia,
--            codven,
--            periodo,
--            mes,
--            meta01,
--            meta02 )
--        VALUES
--            ( rec_vendedor_metas.id_cia,
--              rec_vendedor_metas.codven,
--              rec_vendedor_metas.periodo,
--            0,
--              v_meta01,
--              v_meta02 );

        COMMIT;
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
                    'message' VALUE 'El registro con el Periodo [ '
                                    || rec_vendedor_metas.periodo
                                    || ' ], con el Mes [ '
                                    || TRIM(upper(to_char(to_date(rec_vendedor_metas.mes, 'MM'), 'month', 'nls_date_language=spanish')))
                                    || ' ] y para el Vendedor [ '
                                    || rec_vendedor_metas.codven
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
        pin_codsuc  IN NUMBER,
        pin_periodo IN NUMBER,
        pin_codven  IN NUMBER
    ) AS
    BEGIN
        IF pin_codven = -1 THEN
            DELETE FROM vendedor_metas
            WHERE
                    id_cia = pin_id_cia
                AND periodo = pin_periodo;

        ELSE
            DELETE FROM vendedor_metas
            WHERE
                    id_cia = pin_id_cia
                AND periodo = pin_periodo
                AND codven = pin_codven;

        END IF;

        COMMIT;
    END;

    FUNCTION sp_valida_objeto (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER,
        pin_codven  NUMBER,
        pin_datos   CLOB
    ) RETURN datatable
        PIPELINED
    AS

        o                  json_object_t;
        reg_errores        r_errores := r_errores(NULL, NULL);
        rec_vendedor_metas vendedor_metas%rowtype;
        pout_mensaje       VARCHAR2(1000) := '';
        v_aux              VARCHAR2(10) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_vendedor_metas.id_cia := pin_id_cia;
        rec_vendedor_metas.periodo := o.get_number('periodo');
        rec_vendedor_metas.mes := o.get_number('idmes');
        rec_vendedor_metas.codven := o.get_number('codven');
        rec_vendedor_metas.meta01 := o.get_number('meta01');
        rec_vendedor_metas.meta02 := o.get_number('meta02');
        rec_vendedor_metas.ucreac := o.get_string('ucreac');
        rec_vendedor_metas.uactua := o.get_string('uactua');

        IF rec_vendedor_metas.periodo <> pin_periodo THEN
            reg_errores.valor := rec_vendedor_metas.periodo;
            reg_errores.deserror := 'El Periodo del Registro [ '
                                    || rec_vendedor_metas.periodo
                                    || ' ] no coincide con el Periodo Seleccionado [ '
                                    || pin_periodo
                                    || ' ]';

            PIPE ROW ( reg_errores );
        END IF;

        IF pin_codven = -1 THEN
            BEGIN
                SELECT
                    'S'
                INTO v_aux
                FROM
                    vendedor
                WHERE
                        id_cia = pin_id_cia
                    AND codven = rec_vendedor_metas.codven
                    AND swacti = 'S';

            EXCEPTION
                WHEN no_data_found THEN
                    reg_errores.valor := rec_vendedor_metas.codven;
                    reg_errores.deserror := 'El Codigo Vendedor [ '
                                            || rec_vendedor_metas.codven
                                            || ' ] no Existe o no se encuentra Activo';
                    PIPE ROW ( reg_errores );
            END;
        ELSE
            IF rec_vendedor_metas.codven <> pin_codven THEN
                reg_errores.valor := rec_vendedor_metas.codven;
                reg_errores.deserror := 'El Codigo Vendedor [ '
                                        || rec_vendedor_metas.codven
                                        || ' ] no coincide con el Vendedor Seleccionado [ '
                                        || pin_codven
                                        || ' ]';

                PIPE ROW ( reg_errores );
            END IF;
        END IF;

        IF rec_vendedor_metas.mes < 1 OR rec_vendedor_metas.mes > 12 THEN
            reg_errores.valor := rec_vendedor_metas.mes;
            reg_errores.deserror := 'El IDMes no Existe [ '
                                    || rec_vendedor_metas.mes
                                    || ' ] debe tener un valor entre 1 y 12';
            PIPE ROW ( reg_errores );
        END IF;

    END sp_valida_objeto;

END;

/

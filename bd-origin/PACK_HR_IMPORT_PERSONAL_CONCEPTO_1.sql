--------------------------------------------------------
--  DDL for Package Body PACK_HR_IMPORT_PERSONAL_CONCEPTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_HR_IMPORT_PERSONAL_CONCEPTO" AS

    FUNCTION sp_exportar (
        pin_id_cia IN NUMBER,
        pin_tiptra IN VARCHAR2,
        pin_codcon  IN VARCHAR2,
        pin_periodo IN NUMBER,
        pin_mes IN NUMBER,
        pin_inccla IN VARCHAR2
    ) RETURN datatable_exportar
        PIPELINED
    AS
        v_table datatable_exportar;
    BEGIN
        IF nvl(pin_inccla, 'N') = 'N' THEN
            SELECT
                a.id_cia,
                a.tiptra,
                a.codper,
                a.apepat
                || ' '
                || a.apemat
                || ', '
                || a.nombre,
                pin_codcon,
                ac.valcon
            BULK COLLECT
            INTO v_table
            FROM
                personal       a
                LEFT OUTER JOIN personal_concepto ac ON ac.id_cia = a.id_cia
                                                     AND ac.codper = a.codper
                                                     AND ac.codcon = pin_codcon
                                                     AND ac.periodo = pin_periodo
                                                     AND ac.mes = pin_mes
            WHERE
                    a.id_cia = pin_id_cia
                AND a.tiptra = pin_tiptra;

        ELSE
            SELECT
                a.id_cia,
                a.tiptra,
                a.codper,
                a.apepat
                || ' '
                || a.apemat
                || ', '
                || a.nombre,
                pin_codcon,
                ac.valcon
            BULK COLLECT
            INTO v_table
            FROM
                personal       a
                LEFT OUTER JOIN personal_concepto ac ON ac.id_cia = a.id_cia
                                                     AND ac.codper = a.codper
                                                     AND ac.codcon = pin_codcon
                                                     AND ac.periodo = pin_periodo
                                                     AND ac.mes = pin_mes
            WHERE
                    a.id_cia = pin_id_cia
                AND a.tiptra = pin_tiptra
                AND NOT EXISTS (
                    SELECT
                        ac1.*
                    FROM
                        personal_concepto ac1
                    WHERE
                            ac1.id_cia = a.id_cia
                        AND ac1.codper = a.codper
                        AND ac1.codcon = pin_codcon
                );

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

        reg_errores        r_errores := r_errores(NULL, NULL, NULL, NULL);
        fila               NUMBER := 3;
        o                  json_object_t;
        rec_personal       personal%rowtype;
        rec_personal_concepto personal_concepto%rowtype;
        v_nomper           VARCHAR2(2000 CHAR);
        v_aux              NUMBER := 0;
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_personal.id_cia := pin_id_cia;
        rec_personal.tiptra := o.get_string('tiptra');
        rec_personal.codper := o.get_string('codper');
        v_nomper := o.get_string('nomper');
        rec_personal_concepto.codcon := o.get_string('codcon');
        rec_personal_concepto.valcon := o.get_number('valcon');
        rec_personal_concepto.periodo := o.get_number('periodo');
        rec_personal_concepto.mes := o.get_number('mes');
        reg_errores.orden := rec_personal.codper;
        reg_errores.concepto := v_nomper;
        BEGIN
            SELECT
                p.apepat
                || ' '
                || p.apemat
                || ', '
                || p.nombre
            INTO reg_errores.concepto
            FROM
                personal p
            WHERE
                    p.id_cia = pin_id_cia
                AND p.tiptra = rec_personal.tiptra
                AND p.codper = rec_personal.codper;

        EXCEPTION
            WHEN no_data_found THEN
                reg_errores.valor := rec_personal.tiptra
                                     || ' - '
                                     || rec_personal.codper;
                reg_errores.deserror := 'EL PERSONAL INGRESADO NO EXISTE!';
                PIPE ROW ( reg_errores );
        END;

        BEGIN
            SELECT
                0
            INTO v_aux
            FROM
                personal_concepto p
            WHERE
                    p.id_cia = pin_id_cia
                AND p.codcon = rec_personal_concepto.codcon
                AND p.valcon = rec_personal_concepto.valcon
                AND p.periodo = rec_personal_concepto.periodo
                AND p.mes = rec_personal_concepto.mes;

        EXCEPTION
            WHEN no_data_found THEN
                reg_errores.valor := rec_personal_concepto.valcon;
                reg_errores.deserror := 'EL CONCEPTO FIJO NO SE ENCUENTRA ASIGNADO A ESTE PERSONAL';
                PIPE ROW ( reg_errores );
        END;

    END sp_valida_objeto;

    PROCEDURE sp_importar (
        pin_id_cia  IN NUMBER,
        pin_datos   IN CLOB,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS

        o                  json_object_t;
        rec_personal       personal%rowtype;
        rec_personal_concepto personal_concepto%rowtype;
        m                  json_object_t;
        pout_mensaje       VARCHAR2(1000 CHAR);
        v_mensaje          VARCHAR2(1000 CHAR);
        v_nomber           VARCHAR(2000 CHAR);
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_personal.id_cia := pin_id_cia;
        rec_personal.tiptra := o.get_string('tiptra');
        rec_personal.codper := o.get_string('codper');
        v_nomber := o.get_string('nomper');
        rec_personal_concepto.codcon := o.get_string('codcon');
        rec_personal_concepto.valcon := o.get_number('valcon');
        rec_personal_concepto.periodo := o.get_number('periodo');
        rec_personal_concepto.mes := o.get_number('mes');
        MERGE INTO personal_concepto ac
        USING dual ddd ON ( ac.id_cia = rec_personal.id_cia
                            AND ac.codper = rec_personal.codper
                            AND ac.codcon = rec_personal_concepto.codcon
                            AND ac.periodo =  rec_personal_concepto.periodo 
                            AND ac.mes = rec_personal_concepto.mes )
        WHEN MATCHED THEN UPDATE
        SET valcon = rec_personal_concepto.valcon,
            uactua = pin_coduser,
            factua = CURRENT_TIMESTAMP
        WHERE
                id_cia = rec_personal.id_cia
            AND codper = rec_personal.codper
            AND codcon = rec_personal_concepto.codcon
            AND periodo = rec_personal_concepto.periodo
            AND mes = rec_personal_concepto.mes
        WHEN NOT MATCHED THEN
        INSERT (
            id_cia,
            codper,
            periodo,
            mes,
            codcon,
            valcon,
            uactua,
            ucreac,
            fcreac,
            factua )
        VALUES
            ( rec_personal.id_cia,
              rec_personal.codper,
              rec_personal_concepto.periodo,
              rec_personal_concepto.mes,
              rec_personal_concepto.codcon,
              rec_personal_concepto.valcon,
              pin_coduser,
              pin_coduser,
              CURRENT_TIMESTAMP,
              CURRENT_TIMESTAMP
            );

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

--            ROLLBACK;
        WHEN OTHERS THEN
            pin_mensaje := 'personal : '
                           || rec_personal.tiptra
                           || ' mensaje : '
                           || sqlerrm
                           || ' valcon :'
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

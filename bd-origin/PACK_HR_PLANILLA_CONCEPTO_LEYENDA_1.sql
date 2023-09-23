--------------------------------------------------------
--  DDL for Package Body PACK_HR_PLANILLA_CONCEPTO_LEYENDA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_HR_PLANILLA_CONCEPTO_LEYENDA" AS

    PROCEDURE sp_insgen (
        pin_id_cia   IN NUMBER,
        pin_numpla   IN NUMBER,
        pin_codper   IN VARCHAR2,
        pin_codori   IN VARCHAR2,
        pin_coddes   IN VARCHAR2,
        pin_tipori   IN VARCHAR2,
        pin_nivel    IN NUMBER,
        pin_formula  IN OUT VARCHAR2,
        pout_formula IN OUT VARCHAR2,
        pin_valor    IN VARCHAR2,
        pin_mensaje  OUT VARCHAR2
    ) AS

        v_desley     VARCHAR2(4000 CHAR);
        v_codley     VARCHAR2(20 CHAR);
        v_dtipori    VARCHAR2(1000 CHAR);
        pout_mensaje VARCHAR2(1000) := '';
        v_mensaje    VARCHAR2(1000) := '';
        v_formula    VARCHAR2(4000) := '';
    BEGIN
        IF pin_tipori IN ( 'C', 'F', 'V', 'S' ) THEN
            BEGIN
                SELECT
                    upper(nombre)
                INTO v_desley
                FROM
                    concepto
                WHERE
                        id_cia = pin_id_cia
                    AND codcon = pin_coddes;

                CASE
                    WHEN pin_tipori = 'C' THEN
                        v_dtipori := 'CONCEPTO CALCULADO';
                    WHEN pin_tipori = 'F' THEN
                        v_dtipori := 'CONCEPTO FIJO';
                    WHEN pin_tipori = 'V' THEN
                        v_dtipori := 'CONCEPTO VARIABLE';
                    WHEN pin_tipori = 'S' THEN
                        v_dtipori := 'CONCEPTO SISTEMA';
                END CASE;

                v_codley := 'C' || pin_coddes;
                v_formula := pin_formula;
            EXCEPTION
                WHEN no_data_found THEN
                    pout_mensaje := 'Error el CONCEPTO [ '
                                    || pin_coddes
                                    || ' ] no existe! ';
                    RAISE pkg_exceptionuser.ex_error_inesperado;
            END;
        ELSIF pin_tipori = 'SS' THEN
            v_codley := 'S' || pin_coddes;
            v_desley := pin_formula;
            v_dtipori := 'FUNCION';
            v_formula := pout_formula;
        ELSIF pin_tipori = 'FT' THEN
            v_codley := 'F' || pin_coddes;
            v_desley := pin_formula;
            v_dtipori := 'FACTOR';
            v_formula := pout_formula;
        ELSE
            v_codley := 'ND' || pin_coddes;
            v_desley := 'NO DEFINIDO';
            v_dtipori := 'ND';
            v_formula := '0';
        END IF;

        INSERT INTO planilla_concepto_leyenda VALUES (
            pin_id_cia,
            pin_numpla,
            pin_codper,
            pin_codori,
            pin_coddes,
            pin_tipori,
            v_dtipori,
            pin_nivel,
            v_codley,
            v_desley,
            pin_valor,
            v_formula
        );

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Success ...! [ '
                                || pin_codper
                                || ' - '
                                || pin_coddes
                                || ' ] '
            )
        INTO pin_mensaje
        FROM
            dual;

        dbms_output.put_line(pin_mensaje);
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

    END sp_insgen;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_numpla NUMBER,
        pin_codper VARCHAR2,
        pin_codcon VARCHAR2,
        pin_nivel  NUMBER
    ) RETURN datatable_leyenda
        PIPELINED
    AS
        v_table datatable_leyenda;
    BEGIN
        SELECT DISTINCT
            pcl.*
        BULK COLLECT
        INTO v_table
        FROM
            planilla_concepto_leyenda pcl
        WHERE
                pcl.id_cia = pin_id_cia
            AND pcl.numpla = pin_numpla
            AND pcl.codper = pin_codper
            AND pcl.codori = pin_codcon;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END;

END;

/

--------------------------------------------------------
--  DDL for Procedure SP_CHEQUEA_MES_PROCESO
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_CHEQUEA_MES_PROCESO" (
    pin_id_cia   IN NUMBER,
    pin_periodo  IN NUMBER,
    pin_mes      IN NUMBER,
    pin_sistema  IN NUMBER,
    pout_mensaje OUT VARCHAR2
) AS
    v_estado  INTEGER := 1;
    v_desmay  meses.desmay%TYPE;
    v_mensaje VARCHAR2(1000);
BEGIN

--SET SERVEROUTPUT on;
--
--DECLARE
--    v_mensaje VARCHAR2(2000);
--BEGIN
--    sp_chequea_mes_proceso(66,2020,12,5, v_mensaje);
--    dbms_output.put_line(v_mensaje);
--END;

    CASE
        WHEN pin_sistema = 1 THEN
            v_mensaje := 'MODULO CONTABILIDAD - ';
        WHEN pin_sistema = 2 THEN
            v_mensaje := 'MODULO CUENTAS POR COBRAR CLIENTES - ';
        WHEN pin_sistema = 3 THEN
            v_mensaje := 'MODULO COMERCIAL - ';
        WHEN pin_sistema = 4 THEN
            v_mensaje := 'MODULO LOGISTICA - ';
        WHEN pin_sistema = 5 THEN
            v_mensaje := 'MODULO CUENTAS POR PAGAR PROVEEDORES - ';
        WHEN pin_sistema = 6 THEN
            v_mensaje := 'MODULO PLANILLA DE RECURSOS HUMANOS - ';
        ELSE
            v_mensaje := 'ERROR, MODULO NO EXISTE';
            RAISE pkg_exceptionuser.ex_error_inesperado;
    END CASE;

    BEGIN
        SELECT
            c.cierre,
            m.desmay
        INTO
            v_estado,
            v_desmay
        FROM
            cierre c
            LEFT OUTER JOIN meses  m ON m.id_cia = c.id_cia
                                       AND m.nromes = c.mes
        WHERE
                c.id_cia = pin_id_cia
            AND c.periodo = pin_periodo
            AND c.mes = pin_mes /* 0 = siempre apertura */
            AND c.sistema = pin_sistema; /* 5 = Módulo logistica */

    EXCEPTION
        WHEN no_data_found THEN
            v_mensaje := 'ERROR, PERIODO Y/O MES NO EXISTE';
            RAISE pkg_exceptionuser.ex_error_inesperado;
    END;

    v_mensaje := v_mensaje
                 || to_char(pin_periodo)
                 || ' '
                 || v_desmay;
    CASE
        WHEN v_estado = 0 THEN
            v_mensaje := v_mensaje || ' - PERIODO Y MES ABIERTO';
        WHEN v_estado = 1 THEN
            v_mensaje := v_mensaje || ' - PERIODO Y MES CERRADO';
            RAISE pkg_exceptionuser.ex_error_inesperado;
    END CASE;

    SELECT
        JSON_OBJECT(
            'status' VALUE 1.0,
            'message' VALUE v_mensaje
        )
    INTO pout_mensaje
    FROM
        dual;

EXCEPTION
    WHEN pkg_exceptionuser.ex_error_inesperado THEN
        SELECT
            JSON_OBJECT(
                'status' VALUE 1.1,
                'message' VALUE v_mensaje
            )
        INTO pout_mensaje
        FROM
            dual;

    WHEN OTHERS THEN
        pout_mensaje := 'mensaje : '
                        || sqlerrm
                        || ' codigo :'
                        || sqlcode;
        SELECT
            JSON_OBJECT(
                'status' VALUE 1.2,
                'message' VALUE pout_mensaje
            )
        INTO pout_mensaje
        FROM
            dual;

END sp_chequea_mes_proceso;

/

--------------------------------------------------------
--  DDL for Procedure SP000_VERIFICA_MES_CERRADO_HR_PLANILLA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP000_VERIFICA_MES_CERRADO_HR_PLANILLA" (
    pin_id_cia    IN NUMBER,
    pin_periodo   IN NUMBER,
    pin_mes       IN NUMBER,
    pin_situacold IN VARCHAR2,
    pin_situacnew IN VARCHAR2
) AS
    v_situacold VARCHAR2(1);
    v_situacnew VARCHAR2(1);
    v_cierra    NUMBER;
BEGIN

--SET SERVEROUTPUT ON
--
--BEGIN
--    sp000_verifica_mes_cerrado_hr_planilla(66, 2021, 01, '', '');
--END;

    BEGIN
        SELECT
            NVL(cierre,0)
        INTO v_cierra
        FROM
            cierre
        WHERE
                id_cia = pin_id_cia
            AND sistema = 6 -- PLANILLA
            AND periodo = pin_periodo
            AND mes = pin_mes;

    EXCEPTION
        WHEN no_data_found THEN
            v_cierra := NULL;
    END;

    IF ( v_cierra IS NULL OR v_cierra = 1 ) THEN
        RAISE pkg_exceptionuser.ex_mes_cerrado_planilla;
    END IF;

EXCEPTION
    WHEN pkg_exceptionuser.ex_mes_cerrado_planilla THEN
        raise_application_error(pkg_exceptionuser.mes_cerrado_planilla, 'Mes cerrado en módulo Planilla');
END sp000_verifica_mes_cerrado_hr_planilla;

/

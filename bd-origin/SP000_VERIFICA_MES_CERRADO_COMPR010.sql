--------------------------------------------------------
--  DDL for Procedure SP000_VERIFICA_MES_CERRADO_COMPR010
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP000_VERIFICA_MES_CERRADO_COMPR010" (
    pin_id_cia     IN  NUMBER,
    pin_periodo    IN  NUMBER,
    pin_mes        IN  NUMBER,
    pin_situacold  IN  NUMBER,
    pin_situacnew  IN  NUMBER,
    pin_motcaja    IN  NUMBER
) AS
    v_situacold  NUMBER;
    v_situacnew  NUMBER;
    v_cierra     NUMBER;
BEGIN
--EJEMPLO DE USO
--SET SERVEROUTPUT ON
--
--BEGIN
--    sp000_verifica_mes_cerrado_compr010(13,2021,1,2,0,1)
--END;
    IF pin_situacold IS NULL THEN
        v_situacold := 0;
    END IF;
    IF pin_situacnew IS NULL THEN
        v_situacnew := 0;
    END IF;
   -- solo por cambio de situacion o que ya este contabilizado 
    v_cierra := 1;
    BEGIN
        SELECT
            cierre
        INTO v_cierra
        FROM
            cierre
        WHERE
                id_cia = pin_id_cia
            AND sistema = 1
            AND periodo = pin_periodo
            AND mes = pin_mes;

    EXCEPTION
        WHEN no_data_found THEN
            v_cierra := NULL;
    END;

    IF ( ( v_cierra IS NULL ) OR ( v_cierra = 1 ) ) THEN
        RAISE pkg_exceptionuser.ex_mes_cerrado_contabilidad;
    END IF;

    IF ( pin_motcaja = 0 ) THEN --Solo los que no son caja Chica van ha Ctas X Pagar segun Trigger 
        v_cierra := 1; --5-Cuentas por Pagar
        BEGIN
            SELECT
                cierre
            INTO v_cierra
            FROM
                cierre
            WHERE
                    id_cia = pin_id_cia
                AND sistema = 5
                AND periodo = pin_periodo
                AND mes = pin_mes;

        EXCEPTION
            WHEN no_data_found THEN
                v_cierra := NULL;
        END;

        IF ( ( v_cierra IS NULL ) OR ( v_cierra = 1 ) ) THEN
            RAISE pkg_exceptionuser.ex_mes_cerrado_ctaxpagar;
        END IF;

    END IF;

EXCEPTION
    WHEN pkg_exceptionuser.ex_mes_cerrado_contabilidad THEN
        raise_application_error(pkg_exceptionuser.mes_cerrado_contabilidad, 'Mes cerrado en módulo Contabilidad');
    WHEN pkg_exceptionuser.ex_mes_cerrado_ctaxpagar THEN
        raise_application_error(pkg_exceptionuser.mes_cerrado_ctaxpagar, 'Mes cerrado en módulo Cuentas por pagar');
END sp000_verifica_mes_cerrado_compr010;

/

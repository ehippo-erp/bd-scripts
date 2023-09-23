--------------------------------------------------------
--  DDL for Procedure SP000_VERIFICA_MES_CERRADO_PROV102
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP000_VERIFICA_MES_CERRADO_PROV102" (
    pin_id_cia     IN  NUMBER,
    pin_periodo    IN  NUMBER,
    pin_mes        IN  NUMBER,
    pin_situacold  IN  VARCHAR2,
    pin_situacnew  IN  VARCHAR2
) AS
    v_situacold  VARCHAR2(1);
    v_situacnew  VARCHAR2(1);
    v_cierra     NUMBER;
BEGIN
--EJEMPLO DE USO
--SET SERVEROUTPUT ON
--
--BEGIN
--    SP000_VERIFICA_MES_CERRADO_PROV102(13,2021,1,2,0)
--END;
    IF pin_situacold IS NULL THEN
        v_situacold := 'A';
    END IF;
    IF pin_situacnew IS NULL THEN
        v_situacnew := 'A';
    END IF;
    v_situacold := upper(v_situacold);
    v_situacnew := upper(v_situacnew);
    v_cierra := 1;   --  5-Cuentas por Pagar 
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
 -- solo por cambio de situacion o que ya este contabilizado 

    IF ( ( v_situacold = 'B' ) OR ( v_situacnew = 'B' ) ) THEN
        v_cierra := 1;                             -- 1-Contabilidad  
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

    END IF;

EXCEPTION
    WHEN pkg_exceptionuser.ex_mes_cerrado_ctaxpagar THEN
        raise_application_error(pkg_exceptionuser.mes_cerrado_ctaxpagar, ' Mes cerrado en módulo Contabilidad');
    WHEN pkg_exceptionuser.ex_mes_cerrado_contabilidad THEN
        raise_application_error(pkg_exceptionuser.mes_cerrado_contabilidad, ' Mes cerrado en módulo Cuentas por pagar');
END sp000_verifica_mes_cerrado_prov102;

/

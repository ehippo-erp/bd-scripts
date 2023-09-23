--------------------------------------------------------
--  DDL for Function SP_VALIDA_CUENTA_EXISTE_EN_PCUENTAS
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP_VALIDA_CUENTA_EXISTE_EN_PCUENTAS" (
    pin_id_cia   IN   NUMBER,
    pin_cuenta   IN   VARCHAR2
) RETURN VARCHAR2 AS
    v_nreg    INTEGER := 0;
    v_valor   VARCHAR2(1);
BEGIN
--SET SERVEROUTPUT ON;
--DECLARE
-- MSJ VARCHAR2(1);
--BEGIN
--  MSJ := SP_VALIDA_CUENTA_EXISTE_EN_PCUENTAS(26,'632310');
--  if msj='N' THEN
--  dbms_output.put_line('Cuenta '||' no existe');
--  ELSE
--    dbms_output.put_line('Cuenta '||' SI existe');
--    END IF;
--  
--END;
    v_valor := 'N';
    IF ( trim(pin_cuenta) = '' ) THEN
        v_valor := 'N';
    ELSE
        BEGIN
            SELECT
                COUNT(0) AS nreg
            INTO v_nreg
            FROM
                pcuentas
            WHERE
                id_cia = pin_id_cia
                AND cuenta = pin_cuenta;

        EXCEPTION
            WHEN no_data_found THEN
                v_nreg := 0;
        END;

        IF ( v_nreg > 0 ) THEN
            v_valor := 'S';
        ELSE
            v_valor := 'N';
        END IF;

    END IF;

    RETURN v_valor;
END SP_VALIDA_CUENTA_EXISTE_EN_PCUENTAS;

/

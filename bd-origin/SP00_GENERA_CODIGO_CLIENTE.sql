--------------------------------------------------------
--  DDL for Procedure SP00_GENERA_CODIGO_CLIENTE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP00_GENERA_CODIGO_CLIENTE" (
    pin_id_cia     IN NUMBER,
    pin_incremento IN NUMBER,
    pout_valor     OUT VARCHAR2
)
    AUTHID current_user
AS
    v_valor  NUMBER;
    v_codcli VARCHAR(20) := '';
BEGIN
--FORMA DE USO
--SET SERVEROUTPUT ON
--
--DECLARE
--    svalor VARCHAR2(200);
--BEGIN
--    sp00_genera_codigo_cliente(0,svalor);
--    dbms_output.put_line('CODIGO GENERADO ' || svalor);
--END;
    IF pin_incremento = 0 THEN
        BEGIN
            SELECT
                last_number
            INTO v_valor
            FROM
                all_sequences
            WHERE
                sequence_name = upper('gen_cliente_')
                                || pin_id_cia;

        EXCEPTION
            WHEN no_data_found THEN
                v_valor := 1;
        END;

        IF v_valor > 1 THEN
            v_valor := v_valor - 1;
        END IF;
    ELSE
        EXECUTE IMMEDIATE 'ALTER SEQUENCE '
                          || 'USR_TSI_SUITE.'
                          || upper('gen_cliente_')
                          || pin_id_cia
                          || ' INCREMENT BY '
                          || pin_incremento
                          || ' ORDER';

        EXECUTE IMMEDIATE 'select '
                          || 'USR_TSI_SUITE.gen_cliente_'
                          || pin_id_cia
                          || '.NEXTVAL FROM DUAL'
        INTO v_valor;
    END IF;

    IF v_valor > 0 THEN
        v_codcli := 'X'
                    || sp000_ajusta_string(v_valor, 10, '0', 'R');
    END IF;

    pout_valor := v_codcli;
END sp00_genera_codigo_cliente;

/

--------------------------------------------------------
--  DDL for Function SP000_SACA_CUENTA_TDOCUME
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP000_SACA_CUENTA_TDOCUME" (
    pin_id_cia   IN  NUMBER,
    pin_codprov  IN  VARCHAR2,
    pin_tipdoc   IN  VARCHAR2,
    pin_cdomon   IN  VARCHAR2
) RETURN VARCHAR2 AS
    v_cuenta VARCHAR2(20) := '';
BEGIN
    SELECT
        tc.codigo AS cuenta
    INTO v_cuenta
    FROM
        cliente_clase   cc
        LEFT OUTER JOIN tdocume_clases  tc ON tc.id_cia = pin_id_cia
                                             AND tc.tipdoc = pin_tipdoc
                                             AND tc.clase = cc.codigo
                                             AND tc.moneda = pin_cdomon
    WHERE
            cc.id_cia =pin_id_cia and 
            cc.tipcli = 'B'
        AND cc.codcli = pin_codprov
        AND cc.clase = 4;  /*4= Clase Cliente relacionado */

    RETURN v_cuenta;
END sp000_saca_cuenta_tdocume;

/

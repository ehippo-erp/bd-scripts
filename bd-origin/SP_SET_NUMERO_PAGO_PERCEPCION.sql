--------------------------------------------------------
--  DDL for Function SP_SET_NUMERO_PAGO_PERCEPCION
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP_SET_NUMERO_PAGO_PERCEPCION" (
    pin_id_cia  NUMBER,
    pin_tipdoc  IN  VARCHAR2,
    pin_serie   IN  VARCHAR2,
    pin_numero  IN  VARCHAR2,
    pin_femisi  IN  DATE
) RETURN NUMBER IS
    v_numpago NUMBER := 0;
BEGIN
--SET SERVEROUTPUT ON
--
--DECLARE
--    VALOR  NUMBER;
--BEGIN
--    VALOR:=sp_set_numero_pago_percepcion(1, 1, 'F001', '25',TO_DATE('24/03/21','DD/MM/RR'));
--    dbms_output.put_line('RESULTADO  '
--                         || VALOR);
--END;
    BEGIN
        SELECT
            COUNT(*) + 1
        INTO v_numpago
        FROM
                 documentos_cab c
            INNER JOIN documentos_det_percepcion d ON d.numint = c.numint
        WHERE
                d.id_cia = pin_id_cia
            AND d.tdocum = pin_tipdoc
            AND d.serie = pin_serie
            AND d.numero = pin_numero
            AND c.id_cia = pin_id_cia
            AND c.tipdoc = 41
            AND c.femisi < pin_femisi
            AND NOT ( c.situac IN (
                'J',
                'K'
            ) );

    EXCEPTION
        WHEN no_data_found THEN
            v_numpago := NULL;
    END;

    IF ( v_numpago IS NULL ) THEN
        v_numpago := 1;
    END IF;
    RETURN v_numpago;
END sp_set_numero_pago_percepcion;

/

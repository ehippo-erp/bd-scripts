--------------------------------------------------------
--  DDL for Function SP_TRAZABILIDAD_DOC_AE
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP_TRAZABILIDAD_DOC_AE" (
    pin_id_cia   NUMBER,
    pin_numint   NUMBER
) RETURN NUMBER IS
    v_cantid NUMBER;
BEGIN
    BEGIN
        SELECT
            COUNT(1)
        INTO v_cantid
        FROM
            TABLE ( pack_trazabilidad.sp_trazabilidad(pin_id_cia, pin_numint) )
        WHERE
            ( tipdoc = 108
              AND situac IN (
                'A'
            ) )
            OR ( tipdoc <> 108
                 AND situac IN (
                'A',
                'E'
            ) );

    EXCEPTION
        WHEN no_data_found THEN
            v_cantid := 0;
    END;

    RETURN v_cantid;
END sp_trazabilidad_doc_ae;

/

--------------------------------------------------------
--  DDL for Function SP_EXISTE_SEQUENCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "USR_TSI_SUITE"."SP_EXISTE_SEQUENCE" (
    pin_namesequence VARCHAR2
) RETURN INTEGER AS
    v_count_exist INTEGER := 0;
BEGIN
    BEGIN
        SELECT
            COUNT(0)
        INTO v_count_exist
        FROM
            user_sequences
        WHERE
            upper(sequence_name) = upper(pin_namesequence);

    EXCEPTION
        WHEN no_data_found THEN
            v_count_exist := 0;
    END;

    RETURN v_count_exist;
END sp_existe_sequence;

/

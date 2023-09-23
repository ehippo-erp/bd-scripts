--------------------------------------------------------
--  DDL for Procedure ALTER_START_SEQUENCE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."ALTER_START_SEQUENCE" (
    name_sequence  user_sequences.sequence_name%TYPE,
    start_value    user_sequences.increment_by%TYPE DEFAULT 0
)
    AUTHID current_user
AS
    count_exist NUMBER := 0;
BEGIN
    BEGIN
        SELECT
            COUNT(0)
        INTO count_exist
        FROM
            user_sequences
        WHERE
            upper(sequence_name) = upper(name_sequence);

    EXCEPTION
        WHEN no_data_found THEN
            count_exist := 0;
    END;

    IF ( count_exist > 0 ) THEN
        EXECUTE IMMEDIATE 'DROP SEQUENCE ' || upper(name_sequence);
    END IF;

    EXECUTE IMMEDIATE 'CREATE SEQUENCE '
                      || upper(name_sequence)
                      || ' START WITH '
                      || start_value
                      || ' INCREMENT BY 1 ORDER'
                      || ' MINVALUE '
                      || start_value
                      || ' NOCACHE ';

    EXECUTE IMMEDIATE 'SELECT '
                      || upper(name_sequence)
                      || '.nextval FROM dual';

END;

/

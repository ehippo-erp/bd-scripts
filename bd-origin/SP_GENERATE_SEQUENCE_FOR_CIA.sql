--------------------------------------------------------
--  DDL for Procedure SP_GENERATE_SEQUENCE_FOR_CIA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_GENERATE_SEQUENCE_FOR_CIA" (
    pin_name_sequence  IN  VARCHAR2,
    pin_id_cia         IN  NUMBER
)
    AUTHID current_user
AS
    count_exist      NUMBER := 0;
    v_name_sequence  VARCHAR2(200);
    sentencia        VARCHAR2(2000);
BEGIN
--BEGIN
--    sp_generate_sequence_for_cia('GEN_COMPROMETIDO', null);
--END;
    FOR reg IN (
        SELECT
            cia
        FROM
            companias
        WHERE
            pin_id_cia IS NULL
            OR cia = pin_id_cia
    ) LOOP
        v_name_sequence := pin_name_sequence
                           || '_'
                           || reg.cia;
        BEGIN
            SELECT
                COUNT(0)
            INTO count_exist
            FROM
                user_sequences
            WHERE
                upper(sequence_name) = upper(v_name_sequence);

        EXCEPTION
            WHEN no_data_found THEN
                count_exist := 0;
        END;

        IF ( count_exist = 0 ) THEN
            EXECUTE IMMEDIATE 'CREATE SEQUENCE '
                              || upper(v_name_sequence)
                              || ' START WITH '
                              || 1
                              || ' INCREMENT BY 1 ORDER'
                              || ' MINVALUE '
                              || 1
                              || ' NOCACHE ';

            EXECUTE IMMEDIATE 'SELECT '
                              || upper(v_name_sequence)
                              || '.nextval FROM dual';
        END IF;

    END LOOP;
END;

/

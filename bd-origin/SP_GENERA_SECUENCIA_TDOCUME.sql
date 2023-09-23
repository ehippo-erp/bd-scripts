--------------------------------------------------------
--  DDL for Procedure SP_GENERA_SECUENCIA_TDOCUME
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_GENERA_SECUENCIA_TDOCUME" (
    pin_id_cia IN NUMBER
)
    AUTHID current_user
AS

    count_exist      NUMBER := 0;
    v_name_sequence  VARCHAR2(200);
    sentencia        VARCHAR2(2000);
    CURSOR cur_compania IS
    SELECT
        cia
    FROM
        companias
    WHERE
        pin_id_cia IS NULL
        OR pin_id_cia = - 1
        OR cia = pin_id_cia;

    CURSOR cur_tdocume (
        pid_cia NUMBER
    ) IS
    SELECT
        codigo
    FROM
        tdocume
    WHERE
        id_cia = pid_cia;

BEGIN
--BEGIN
--    sp_generate_sequence_for_cia('GEN_COMPROMETIDO', null);
--END;
    FOR r_cia IN cur_compania LOOP
        FOR r_tdoc IN cur_tdocume(r_cia.cia) LOOP
            v_name_sequence := 'GEN_PROV105_CXP_'
                               || r_cia.cia
                               || '_'
                               || r_tdoc.codigo;
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
    END LOOP;
END;

/

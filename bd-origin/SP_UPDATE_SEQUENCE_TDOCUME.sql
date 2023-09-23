--------------------------------------------------------
--  DDL for Procedure SP_UPDATE_SEQUENCE_TDOCUME
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_UPDATE_SEQUENCE_TDOCUME" (
    pin_id_cia  IN  INTEGER,
    pin_tipdoc  IN  VARCHAR2
) AS

    CURSOR cur_compania IS
    SELECT
        cia
    FROM
        companias
    WHERE
        ( ( pin_id_cia IS NULL )
          OR ( pin_id_cia = - 1 )
          OR ( cia = pin_id_cia ) );

    CURSOR cur_prov105 (
        pid_cia NUMBER
    ) IS
    SELECT
        tipdoc,
        MAX(numdoc) numdoc
    FROM
        prov105
    WHERE
            id_cia = pid_cia
        AND ( ( pin_tipdoc IS NULL )
              OR ( pin_tipdoc = '-1' )
              OR ( tipdoc = pin_tipdoc ) )
    GROUP BY
        tipdoc;

    v_name_sequence  VARCHAR2(60);
    v_lastnumber     NUMBER := 0;
    n                NUMBER;
BEGIN
    FOR r_cia IN cur_compania LOOP
        FOR r_tdoc IN cur_prov105(r_cia.cia) LOOP
            v_name_sequence := 'GEN_PROV105_CXP_'
                               || r_cia.cia
                               || '_'
                               || r_tdoc.tipdoc;
            dbms_output.put_line(' nombre secuencia ==> ' || v_name_sequence);
            BEGIN
                SELECT
                    last_number
                INTO v_lastnumber
                FROM
                    user_sequences
                WHERE
                    sequence_name = v_name_sequence;

            EXCEPTION
                WHEN no_data_found THEN
                    v_lastnumber := NULL;
            END;

            IF v_lastnumber IS NULL THEN
                v_lastnumber := 0;
            END IF;
            dbms_output.put_line('last_number secuencia ==> ' || v_lastnumber);
            dbms_output.put_line(' numdoc ==> ' || r_tdoc.numdoc);
            IF (
                ( r_tdoc.numdoc > 0 ) AND ( v_lastnumber < r_tdoc.numdoc )
            ) THEN
                dbms_output.put_line('new numdoc ==> ' ||(r_tdoc.numdoc - v_lastnumber));
                EXECUTE IMMEDIATE 'ALTER SEQUENCE '
                                  || v_name_sequence
                                  || ' RESTART START WITH '
                                  || to_char(v_lastnumber +(r_tdoc.numdoc - v_lastnumber));
                 --                 || ' INCREMENT BY 2';
                  --                ||to_char(( r_tdoc.numdoc - v_lastnumber ));

                EXECUTE IMMEDIATE 'select '
                                  || v_name_sequence
                                  || '.NEXTVAL FROM DUAL'
                INTO n;
                EXECUTE IMMEDIATE 'ALTER SEQUENCE '
                                  || v_name_sequence
                                  || ' INCREMENT BY 1';
            END IF;

        END LOOP;
    END LOOP;
END sp_update_sequence_tdocume;

/

--------------------------------------------------------
--  DDL for Procedure SP_ACTUALIZA_SALDO_DCTA100_V2
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_ACTUALIZA_SALDO_DCTA100_V2" (
    pin_id_cia IN NUMBER
) AS

    CURSOR registro IS
    SELECT
        c.numint,
        c.tipdoc
    FROM
        dcta100     c
    WHERE
        c.id_cia = pin_id_cia;

BEGIN
    FOR i IN registro LOOP
        BEGIN
            sp_actualiza_saldo_dcta100(pin_id_cia, i.numint);
--            dbms_output.put_line( pin_id_cia ||  i.numint);
            COMMIT;
        EXCEPTION
            WHEN OTHERS THEN
                dbms_output.put_line( pin_id_cia ||  i.numint);
                ROLLBACK;
        END;
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        raise_application_error(pkg_exceptionuser.error_inesperado, 'ERROR, '
                                                                    || ' SQLCODE: '
                                                                    || sqlcode);
END sp_actualiza_saldo_dcta100_v2;

/

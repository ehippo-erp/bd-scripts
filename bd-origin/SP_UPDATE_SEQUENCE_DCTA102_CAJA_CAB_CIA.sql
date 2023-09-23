--------------------------------------------------------
--  DDL for Procedure SP_UPDATE_SEQUENCE_DCTA102_CAJA_CAB_CIA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_UPDATE_SEQUENCE_DCTA102_CAJA_CAB_CIA" (
    pin_id_cia IN NUMBER
)
    AUTHID current_user
AS
    v_maxnumcaja NUMBER;
BEGIN
--FORMA DE USO
--SET SERVEROUTPUT ON
--BEGIN
-- sp_update_sequence_dcta102_caja_cab_cia(13);
--END;
    BEGIN
        SELECT
            nvl(MAX(numcaja), 1)
        INTO v_maxnumcaja
        FROM
            dcta102_caja_cab
        WHERE
            id_cia = pin_id_cia;

    EXCEPTION
        WHEN no_data_found THEN
            v_maxnumcaja := 1;
    END;

    alter_start_sequence('GEN_DCTA102_CAJA_CAB_' || pin_id_cia, v_maxnumcaja+1);
END sp_update_sequence_dcta102_caja_cab_cia;

/

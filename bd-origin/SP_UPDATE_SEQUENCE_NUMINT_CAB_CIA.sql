--------------------------------------------------------
--  DDL for Procedure SP_UPDATE_SEQUENCE_NUMINT_CAB_CIA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_UPDATE_SEQUENCE_NUMINT_CAB_CIA" (
    pin_id_cia IN NUMBER
)
    AUTHID current_user
AS
    v_maxnumint NUMBER;
BEGIN
--FORMA DE USO
--SET SERVEROUTPUT ON
--BEGIN
-- sp_update_sequence_numint_cab_cia(13);
--END;
    BEGIN
        SELECT
            nvl(MAX(numint), 1)
        INTO v_maxnumint
        FROM
            documentos_cab
        WHERE
            id_cia = pin_id_cia;

    EXCEPTION
        WHEN no_data_found THEN
            v_maxnumint := 1;
    END;

    alter_start_sequence('GEN_DOCUMENTOS_CAB_' || pin_id_cia, v_maxnumint+1);
END sp_update_sequence_numint_cab_cia;

/

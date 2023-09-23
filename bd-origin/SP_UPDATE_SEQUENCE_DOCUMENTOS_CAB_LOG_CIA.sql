--------------------------------------------------------
--  DDL for Procedure SP_UPDATE_SEQUENCE_DOCUMENTOS_CAB_LOG_CIA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_UPDATE_SEQUENCE_DOCUMENTOS_CAB_LOG_CIA" (
    pin_id_cia IN NUMBER
)
    AUTHID current_user
AS
    v_maxlocali NUMBER;
BEGIN
--FORMA DE USO
--SET SERVEROUTPUT ON
--BEGIN
-- sp_update_sequence_documentos_cab_log_cia(13);
--END;
    BEGIN
        SELECT
            nvl(MAX(locali), 1)
        INTO v_maxlocali
        FROM
            documentos_cab_log
        WHERE
            id_cia = pin_id_cia;

    EXCEPTION
        WHEN no_data_found THEN
            v_maxlocali := 1;
    END;

    alter_start_sequence('GEN_DOCUMENTOS_CAB_LOG_' || pin_id_cia, v_maxlocali+1);
END sp_update_sequence_documentos_cab_log_cia;

/

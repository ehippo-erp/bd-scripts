--------------------------------------------------------
--  DDL for Procedure SP_UPDATE_SEQUENCE_ASISTENCIA_CIA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_UPDATE_SEQUENCE_ASISTENCIA_CIA" (
    pin_id_cia IN NUMBER
)
    AUTHID current_user
AS
    v_maxnum NUMBER;
BEGIN
--FORMA DE USO
--SET SERVEROUTPUT ON
--BEGIN
-- SP_UPDATE_SEQUENCE_ASISTENCIA_PLANILLA_CIA(25);
--END;
    BEGIN
        SELECT
            nvl(MAX(codasist), 1)
        INTO v_maxnum
        FROM
            asistencia
        WHERE
            id_cia = pin_id_cia;

    EXCEPTION
        WHEN no_data_found THEN
            v_maxnum := 1;
    END;

    alter_start_sequence('GEN_ASISTENCIA_PLANILLA_' || pin_id_cia, v_maxnum + 1);
END sp_update_sequence_asistencia_cia;

/

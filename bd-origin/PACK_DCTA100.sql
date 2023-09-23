--------------------------------------------------------
--  DDL for Package PACK_DCTA100
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_DCTA100" AS
    PROCEDURE sp_update_saldo (
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_mensaje OUT VARCHAR2
    );

    PROCEDURE sp_update (
        pin_id_cia  IN NUMBER,
        pin_fdesde  IN DATE,
        pin_fhasta  IN DATE,
        pin_mensaje OUT VARCHAR2
    );

--set SERVEROUTPUT on;
--/
--DECLARE
--    mensaje VARCHAR2(1000);
--BEGIN
--
--    pack_dcta100.sp_update(62,'01/01/2022',current_date,mensaje);
--    DBMS_OUTPUT.PUT_LINE(mensaje);
--
--END;

END;

/

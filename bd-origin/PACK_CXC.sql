--------------------------------------------------------
--  DDL for Package PACK_CXC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_CXC" AS
    PROCEDURE sp_update_ubicacion (
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_codubi  IN NUMBER,
        pin_cuenta  IN VARCHAR2,
        pin_fecha   IN DATE,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR
    );

--set SERVEROUTPUT on;
--
--DECLARE
--    mensaje VARCHAR2(1000);
--BEGIN
--    pack_cxc.sp_update_ubicacion(66,167647,2,'121201',to_date('01/07/21','DD/MM/YY'),'admin',mensaje);
--    DBMS_OUTPUT.PUT_LINE(mensaje);
--
--END;

END;

/

--------------------------------------------------------
--  DDL for Package PACK_ARTICULOS_COSTO_REPOSICION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_ARTICULOS_COSTO_REPOSICION" AS
    PROCEDURE sp_procesar (
        pin_id_cia  IN INTEGER,
        pin_tipinv  IN INTEGER,
        pin_codart  IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

    PROCEDURE sp_actualizar (
        pin_id_cia   IN INTEGER,
        pin_tipinv   IN INTEGER,
        pin_codart   IN VARCHAR2,
        pin_codadd01 IN VARCHAR2,
        pin_codadd02 IN VARCHAR2,
        pin_cantid   IN NUMBER,
        pin_costot01 IN NUMBER,
        pin_costot02 IN NUMBER,
        pin_femisi   IN DATE,
        pin_mensaje  OUT VARCHAR2
    );

--SELECT * FROM articulos_costo_reposicion WHERE id_cia = 60;
--
--set SERVEROUTPUT on;
--
--DECLARE
--    v_mensaje VARCHAR2(2000);
--BEGIN
--    pack_articulos_costo_reposicion.sp_procesar(60,1,NULL, v_mensaje);
--    dbms_output.put_line(v_mensaje);
--END;

END;

/

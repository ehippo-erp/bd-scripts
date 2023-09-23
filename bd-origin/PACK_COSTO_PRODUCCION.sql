--------------------------------------------------------
--  DDL for Package PACK_COSTO_PRODUCCION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_COSTO_PRODUCCION" AS
    PROCEDURE sp_procesar (
        pin_id_cia  IN INTEGER,
        pin_codmot  IN INTEGER,
        pin_periodo IN INTEGER,
        pin_mes     IN INTEGER,
        pin_totobra IN NUMBER,
        pin_totfrab IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

    PROCEDURE sp_update_kardex (
        pin_id_cia   IN INTEGER,
        pin_numint   IN INTEGER,
        pin_numite   IN INTEGER,
        pin_codmot   IN INTEGER,
        pin_cosuni01 IN NUMBER,
        pin_cosuni02 IN NUMBER,
        pin_coduser  IN VARCHAR2,
        pin_mensaje  OUT VARCHAR2
    );

--set SERVEROUTPUT on;
--
--DECLARE
--    v_mensaje VARCHAR2(2000);
--BEGIN
--    pack_costo_produccion.sp_procesar(25,6,2023,09,1000,200, 'admin', v_mensaje);
--    dbms_output.put_line(v_mensaje);
--END;

END;

/

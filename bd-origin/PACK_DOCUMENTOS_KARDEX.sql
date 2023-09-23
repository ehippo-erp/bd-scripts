--------------------------------------------------------
--  DDL for Package PACK_DOCUMENTOS_KARDEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_DOCUMENTOS_KARDEX" AS
    PROCEDURE sp_envia_kardex_guia_interna (
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

    PROCEDURE sp_envia_kardex_guia_remision (
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

    PROCEDURE sp_hereda_aprobaciones (
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

    PROCEDURE sp_genera_documento_ent (
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

    PROCEDURE sp_genera_documento_material_ent (
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

    PROCEDURE sp_verifica_movimientos (
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

    PROCEDURE sp_verifica_movimientos_relacionados (
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

    PROCEDURE sp_anular_guia_interna (
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

    PROCEDURE sp_asigna_kilos_unitarios (
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

--SET SERVEROUT ON
--
--DECLARE
--    v_mensaje VARCHAR2(1000);
--BEGIN
--    pack_documentos_kardex.sp_anular_guia_interna(66,163264,'admin',v_mensaje);
--    dbms_output.put_line(v_mensaje);
--END;

--SET SERVEROUT ON
--
--DECLARE
--    v_mensaje VARCHAR2(1000);
--BEGIN
--    pack_documentos_kardex.sp_envia_kardex_guia_interna(66,163264,'admin',v_mensaje);
--    dbms_output.put_line(v_mensaje);
--END;

--SET SERVEROUT ON
--
--DECLARE
--    v_mensaje VARCHAR2(1000);
--BEGIN
--    pack_documentos_kardex.sp_envia_kardex_guia_remision(66,163548,'admin',v_mensaje);
--    dbms_output.put_line(v_mensaje);
--END;

END;

/

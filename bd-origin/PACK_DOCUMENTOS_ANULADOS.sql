--------------------------------------------------------
--  DDL for Package PACK_DOCUMENTOS_ANULADOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_DOCUMENTOS_ANULADOS" AS
    PROCEDURE sp_anular (
        pin_id_cia     IN NUMBER,
        pin_tipdoc     IN NUMBER,
        pin_numint     IN NUMBER,
        pin_coduser    IN VARCHAR2,
        pin_comentario IN VARCHAR2,
        pin_mensaje    OUT VARCHAR2
    );

    PROCEDURE sp_anular_guia_remision (
        pin_id_cia     IN NUMBER,
        pin_numint     IN NUMBER,
        pin_coduser    IN VARCHAR2,
        pin_comentario IN VARCHAR2,
        pin_mensaje    OUT VARCHAR2
    );

    PROCEDURE sp_anular_orden_pedido (
        pin_id_cia     IN NUMBER,
        pin_numint     IN NUMBER,
        pin_coduser    IN VARCHAR2,
        pin_comentario IN VARCHAR2,
        pin_mensaje    OUT VARCHAR2
    );

    PROCEDURE sp_anular_cotizacion (
        pin_id_cia     IN NUMBER,
        pin_numint     IN NUMBER,
        pin_coduser    IN VARCHAR2,
        pin_comentario IN VARCHAR2,
        pin_mensaje    OUT VARCHAR2
    );

--set SERVEROUTPUT on;
--
--DECLARE
--    mensaje VARCHAR2(1000);
--BEGIN
--
--    pack_documentos_anulados.sp_anular_cotizacion(66,163281,'admin','Anulado por Luis',mensaje);
--    DBMS_OUTPUT.PUT_LINE(mensaje);
--
--END;
--
--set SERVEROUTPUT on;
--
--DECLARE
--    mensaje VARCHAR2(1000);
--BEGIN
--
--    pack_documentos_anulados.sp_anular_orden_pedido(66,153525,'admin','Anulado por Luis',mensaje);
--    DBMS_OUTPUT.PUT_LINE(mensaje);
--
--END;

    PROCEDURE sp_actualiza_situacion (
        pin_id_cia           IN NUMBER,
        pin_numint           IN NUMBER,
        pin_situac           IN VARCHAR2,
        pin_coduser          IN VARCHAR2,
        pin_mensaje          OUT VARCHAR2,
        v_swacti             VARCHAR2,
        v_proccesslock       VARCHAR2,
        v_formconsulta       VARCHAR2,
        v_unlock             VARCHAR2,
        v_actualizasituacmax VARCHAR2
    );

    PROCEDURE sp_actualiza_situacion_documentos_relacionados (
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

    PROCEDURE sp_actualiza_situacion_segun_saldo (
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

    PROCEDURE sp_actualiza_documentos_aprobacion (
        pin_id_cia     IN NUMBER,
        pin_numint     IN NUMBER,
        pin_situac     IN VARCHAR2,
        pin_situac_dev IN VARCHAR2,
        pin_coduser    IN VARCHAR2,
        pin_mensaje    OUT VARCHAR2
    );

    FUNCTION sp_marca_completo (
        pin_id_cia  NUMBER,
        pin_numint  NUMBER,
        pin_tipdoc  NUMBER,
        pin_coduser VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION sp_marca_situac_ori (
        pin_id_cia  NUMBER,
        pin_numint  NUMBER,
        pin_tipdoc  NUMBER,
        pin_coduser VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION sp_marca_parcial (
        pin_id_cia    NUMBER,
        pin_numint    NUMBER,
        pin_tipdoc    NUMBER,
        pin_series    VARCHAR2,
        pin_total     NUMBER,
        pin_pendiente NUMBER,
        pin_coduser   VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION sp_documentos_relacionados (
        pin_id_cia IN NUMBER,
        pin_numint IN NUMBER
    ) RETURN INTEGER;

    FUNCTION sp_documentos_correlacionadas (
        pin_id_cia IN NUMBER,
        pin_numint IN NUMBER
    ) RETURN INTEGER;

    FUNCTION sp_documentos_planilla_cxc (
        pin_id_cia IN NUMBER,
        pin_numint IN NUMBER
    ) RETURN INTEGER;

    FUNCTION sp_documentos_obtener (
        pin_id_cia NUMBER,
        pin_numint NUMBER,
        pin_tipdoc NUMBER
    ) RETURN INTEGER;

    PROCEDURE sp_documento_aceptado_maxdias (
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_tipdoc  IN NUMBER,
        pin_mensaje OUT VARCHAR2
    );

    FUNCTION sp_existe_factor (
        pin_id_cia IN NUMBER,
        pin_factor IN NUMBER
    ) RETURN VARCHAR2;

END;

/

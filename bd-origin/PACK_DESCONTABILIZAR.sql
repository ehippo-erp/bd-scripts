--------------------------------------------------------
--  DDL for Package PACK_DESCONTABILIZAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_DESCONTABILIZAR" AS
    PROCEDURE sp_planilla_cxc (
        pin_id_cia    IN NUMBER,
        pin_libro     IN VARCHAR2,
        pin_periodo   IN NUMBER,
        pin_mes       IN NUMBER,
        pin_secuencia IN NUMBER,
        pin_coduser   IN VARCHAR2,
        pin_mensaje   OUT VARCHAR2
    );

    PROCEDURE sp_planilla_cxp (
        pin_id_cia    IN NUMBER,
        pin_libro     IN VARCHAR2,
        pin_periodo   IN NUMBER,
        pin_mes       IN NUMBER,
        pin_secuencia IN NUMBER,
        pin_coduser   IN VARCHAR2,
        pin_mensaje   OUT VARCHAR2
    );

    FUNCTION sp_existe_asiento_cxc (
        pin_id_cia    IN NUMBER,
        pin_libro     IN VARCHAR2,
        pin_periodo   IN NUMBER,
        pin_mes       IN NUMBER,
        pin_secuencia IN NUMBER
    ) RETURN VARCHAR2;

    FUNCTION sp_existe_asiento_cxp (
        pin_id_cia    IN NUMBER,
        pin_libro     IN VARCHAR2,
        pin_periodo   IN NUMBER,
        pin_mes       IN NUMBER,
        pin_secuencia IN NUMBER
    ) RETURN VARCHAR2;

    PROCEDURE sp_asiento (
        pin_id_cia    IN NUMBER,
        pin_libro     IN VARCHAR2,
        pin_periodo   IN NUMBER,
        pin_mes       IN NUMBER,
        pin_secuencia IN NUMBER,--asiento
        pin_usuario   IN VARCHAR2,
        pin_mensaje   OUT VARCHAR2
    );

END;

/

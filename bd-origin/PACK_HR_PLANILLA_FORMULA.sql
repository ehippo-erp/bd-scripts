--------------------------------------------------------
--  DDL for Package PACK_HR_PLANILLA_FORMULA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_HR_PLANILLA_FORMULA" AS
    PROCEDURE sp_decodificar (
        pin_id_cia   IN NUMBER,
        pin_numpla   IN NUMBER,
        pin_codper   IN VARCHAR2,
        pin_codcon   IN VARCHAR2,
        pin_swacti   IN VARCHAR2,
        pin_coduser  IN VARCHAR2,
        pin_concepto IN VARCHAR2,
        pin_formula  IN OUT VARCHAR2,
        pout_formula OUT VARCHAR2,
        pin_valor    OUT VARCHAR2,
        pin_mensaje  OUT VARCHAR2
    );

    PROCEDURE sp_decodificar_fsistema (
        pin_id_cia   IN NUMBER,
        pin_numpla   IN NUMBER,
        pin_codper   IN VARCHAR2,
        pin_codcon   IN VARCHAR2,
        pin_swacti   IN VARCHAR2,
        pin_coduser  IN VARCHAR2,
        pin_concepto IN VARCHAR2,
        pin_formula  IN OUT VARCHAR2,
        pout_formula OUT VARCHAR2,
        pin_valor    OUT VARCHAR2,
        pin_mensaje  OUT VARCHAR2
    );

    PROCEDURE sp_decodificar_ffactor (
        pin_id_cia   IN NUMBER,
        pin_numpla   IN NUMBER,
        pin_codper   IN VARCHAR2,
        pin_codcon   IN VARCHAR2,
        pin_swacti   IN VARCHAR2,
        pin_coduser  IN VARCHAR2,
        pin_concepto IN VARCHAR2,
        pin_formula  IN OUT VARCHAR2,
        pout_formula OUT VARCHAR2,
        pin_valor    OUT VARCHAR2,
        pin_mensaje  OUT VARCHAR2
    );

    PROCEDURE sp_decodificar_cfijo (
        pin_id_cia   IN NUMBER,
        pin_numpla   IN NUMBER,
        pin_codper   IN VARCHAR2,
        pin_codcon   IN VARCHAR2,
        pin_swacti   IN VARCHAR2,
        pin_coduser  IN VARCHAR2,
        pin_concepto IN VARCHAR2,
        pin_formula  IN OUT VARCHAR2,
        pout_formula OUT VARCHAR2,
        pin_valor    IN OUT VARCHAR2,
        pin_mensaje  OUT VARCHAR2
    );

    PROCEDURE sp_decodificar_cvariable (
        pin_id_cia   IN NUMBER,
        pin_numpla   IN NUMBER,
        pin_codper   IN VARCHAR2,
        pin_codcon   IN VARCHAR2,
        pin_swacti   IN VARCHAR2,
        pin_coduser  IN VARCHAR2,
        pin_concepto IN VARCHAR2,
        pin_formula  IN OUT VARCHAR2,
        pout_formula OUT VARCHAR2,
        pin_valor    IN OUT VARCHAR2,
        pin_mensaje  OUT VARCHAR2
    );

    PROCEDURE sp_decodificar_csistema (
        pin_id_cia   IN NUMBER,
        pin_numpla   IN NUMBER,
        pin_codper   IN VARCHAR2,
        pin_codcon   IN VARCHAR2,
        pin_swacti   IN VARCHAR2,
        pin_coduser  IN VARCHAR2,
        pin_concepto IN VARCHAR2,
        pin_formula  IN OUT VARCHAR2,
        pout_formula OUT VARCHAR2,
        pin_valor    OUT VARCHAR2,
        pin_mensaje  OUT VARCHAR2
    );

    PROCEDURE sp_decodificar_cprestamo (
        pin_id_cia   IN NUMBER,
        pin_numpla   IN NUMBER,
        pin_codper   IN VARCHAR2,
        pin_codcon   IN VARCHAR2,
        pin_swacti   IN VARCHAR2,
        pin_coduser  IN VARCHAR2,
        pin_concepto IN VARCHAR2,
        pin_formula  IN OUT VARCHAR2,
        pout_formula OUT VARCHAR2,
        pin_valor    IN OUT VARCHAR2,
        pin_mensaje  OUT VARCHAR2
    );

    PROCEDURE sp_decodificar_cnodefinido (
        pin_id_cia   IN NUMBER,
        pin_numpla   IN NUMBER,
        pin_codper   IN VARCHAR2,
        pin_codcon   IN VARCHAR2,
        pin_swacti   IN VARCHAR2,
        pin_coduser  IN VARCHAR2,
        pin_concepto IN VARCHAR2,
        pin_formula  IN OUT VARCHAR2,
        pout_formula OUT VARCHAR2,
        pin_valor    OUT VARCHAR2,
        pin_mensaje  OUT VARCHAR2
    );

END;

/

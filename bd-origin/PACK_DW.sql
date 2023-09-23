--------------------------------------------------------
--  DDL for Package PACK_DW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_DW" AS

    PROCEDURE sp_dw_cventas_all(
        pin_fdesde IN DATE,
        pin_fhasta IN DATE
    );

    PROCEDURE sp_dw_cventas (
        pin_id_cia IN NUMBER,
        pin_fdesde IN DATE,
        pin_fhasta IN DATE,
        pin_mensaje OUT VARCHAR2
    );

    PROCEDURE sp_dw_cventasv2 (
        pin_id_cia IN NUMBER,
        pin_fdesde IN DATE,
        pin_fhasta IN DATE
    );

    PROCEDURE sp_dw_cventas_actualiza (
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_mensaje OUT VARCHAR2
    );

    PROCEDURE sp_dw_actualiza_cventas_hijas (
        pin_id_cia  IN NUMBER,
        pin_tipact  IN NUMBER,
        pin_mensaje OUT VARCHAR2
    );

    PROCEDURE sp_dw_actualiza_costo_cventas (
        pin_id_cia  IN NUMBER,
        pin_fdesde  IN DATE,
        pin_fhasta  IN DATE,
        pin_mensaje OUT VARCHAR
    );

    PROCEDURE sp_dw_actualiza_cventas_hijas_costo (
        pin_id_cia  IN NUMBER,
        pin_periodo IN NUMBER,
        pin_mes IN NUMBER,
        pin_mensaje OUT VARCHAR
    );

    FUNCTION sp_deskardex (
        pin_id_cia IN NUMBER,
        pin_numint IN NUMBER,
        pin_numite IN NUMBER
    ) RETURN VARCHAR2;

END;

/

--------------------------------------------------------
--  DDL for Package PACK_PROV101
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_PROV101" AS
    TYPE datatable_prov101 IS
        TABLE OF prov101%rowtype;
    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_tipo   NUMBER,
        pin_docu   NUMBER
    ) RETURN datatable_prov101
        PIPELINED;

    PROCEDURE delprov101 (
        pin_id_cia    IN NUMBER,
        pin_libro     IN VARCHAR2,
        pin_periodo   IN NUMBER,
        pin_mes       IN NUMBER,
        pin_secuencia IN NUMBER,
        pin_mensaje   OUT VARCHAR2
    );

    PROCEDURE enviar_ctas_ctes_from_prov103 (
        pin_id_cia    IN NUMBER,
        pin_libro     IN VARCHAR2,
        pin_periodo   IN NUMBER,
        pin_mes       IN NUMBER,
        pin_secuencia IN NUMBER,
        pin_usuari    IN VARCHAR2,
        pin_mensaje   OUT VARCHAR2
    );

    PROCEDURE delprov113 (
        pin_id_cia    IN NUMBER,
        pin_libro     IN VARCHAR2,
        pin_periodo   IN NUMBER,
        pin_mes       IN NUMBER,
        pin_secuencia IN NUMBER,
        pin_mensaje   OUT VARCHAR2
    );

    PROCEDURE enviar_ctas_ctes_from_prov113 (
        pin_id_cia    IN NUMBER,
        pin_libro     IN VARCHAR2,
        pin_periodo   IN NUMBER,
        pin_mes       IN NUMBER,
        pin_secuencia IN NUMBER,
        pin_usuari    IN VARCHAR2,
        pin_mensaje   OUT VARCHAR2
    );

END pack_prov101;

/

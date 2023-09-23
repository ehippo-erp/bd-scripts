--------------------------------------------------------
--  DDL for Package PACK_CF_CERTIFICADO_PFX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_CF_CERTIFICADO_PFX" AS

    TYPE datarecord_certificado_pfx IS RECORD (
        id_cia     NUMBER(38),
        item       NUMBER(38),
        descri     VARCHAR2(100),
        femisi     DATE,
        fvenci     DATE,
        certif     BLOB,
        clave      VARCHAR2(100),
        swacti     CHAR(1),
        fsolicitud DATE
    );
    TYPE datatable_certificado_pfx IS
        TABLE OF datarecord_certificado_pfx;
    FUNCTION sp_obtener_vigente (
        pin_id_cia IN NUMBER,
        pin_fhoy   IN DATE
    ) RETURN datatable_certificado_pfx
        PIPELINED;

    PROCEDURE sp_valida_certificado (
        pin_id_cia  IN NUMBER,
        pin_fhoy    IN DATE,
        pin_mensaje OUT VARCHAR2
    );

END;

/

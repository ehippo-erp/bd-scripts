--------------------------------------------------------
--  DDL for Package PACK_CERTIFICADOCAL_CAB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_CERTIFICADOCAL_CAB" AS
--    TYPE t_certificadocal_cab IS
--        TABLE OF certificadocal_cab%rowtype;

    TYPE datarecord_certificadocal_cab IS RECORD (
        id_cia      NUMBER(38),
        numint      NUMBER(38),
        femisi      DATE,
        situac      CHAR(1),
        codcli      VARCHAR2(20),
        codestruc   NUMBER(38),
        referencia  VARCHAR2(50),
        opnumint    NUMBER(38),
        ucreac      VARCHAR2(10),
        fcreac      TIMESTAMP(6),
        uactua      VARCHAR2(10),
        factua      TIMESTAMP(6),
        ocfecha     DATE,
        usocantid   NUMBER(38),
        ocnumero    VARCHAR2(20),
        ufirma      VARCHAR2(10 CHAR),
        situacion   VARCHAR2(100 CHAR),
        razonsocial documentos_cab.razonc%TYPE,
        optipdoc    documentos_cab.tipdoc%TYPE,
        opcodmot    documentos_cab.codmot%TYPE
    );
    TYPE datatable_certificadocal_cab IS
        TABLE OF datarecord_certificadocal_cab;
    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_numint NUMBER
    ) RETURN datatable_certificadocal_cab
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia  NUMBER,
        pin_fdesde  DATE,
        pin_fhasta  DATE,
        pin_situacs VARCHAR2
    ) RETURN datatable_certificadocal_cab
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/

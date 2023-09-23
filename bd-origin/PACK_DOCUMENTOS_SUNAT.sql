--------------------------------------------------------
--  DDL for Package PACK_DOCUMENTOS_SUNAT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_DOCUMENTOS_SUNAT" AS
    TYPE datarecord_enviar_correo IS RECORD (
        id_cia documentos_cab.id_cia%TYPE,
        numint documentos_cab.numint%TYPE,
        tipdoc documentos_cab.tipdoc%TYPE,
        serie  documentos_cab.series%TYPE,
        numdoc documentos_cab.numdoc%TYPE,
        femisi documentos_cab.femisi%TYPE,
        moneda documentos_cab.tipmon%TYPE,
        codcli documentos_cab.codcli%TYPE,
        razonc documentos_cab.razonc%TYPE,
        ruc    documentos_cab.ruc%TYPE,
        preven documentos_cab.preven%TYPE,
        codest documentos_cab_envio_sunat.estado%TYPE,
        desest estado_envio_sunat.descri%TYPE
    );
    TYPE datatable_enviar_correo IS
        TABLE OF datarecord_enviar_correo;
    FUNCTION sp_enviar_correo (
        pin_id_cia NUMBER,
        pin_tipdoc  VARCHAR2,
        pin_codcli VARCHAR2,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_enviar_correo
        PIPELINED;

END;

/

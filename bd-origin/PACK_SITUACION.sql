--------------------------------------------------------
--  DDL for Package PACK_SITUACION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_SITUACION" AS
    TYPE datarecord_relacion IS RECORD (
        id_cia documentos_cab.id_cia%TYPE,
        numint documentos_cab.numint%TYPE,
        tipdoc documentos_cab.tipdoc%TYPE,
        situac situacion.situac%TYPE,
        dessit situacion.dessit%TYPE
    );
    TYPE datatable_relacion IS
        TABLE OF datarecord_relacion;
    FUNCTION sp_relacion (
        pin_id_cia NUMBER,
        pin_numint NUMBER
    ) RETURN datatable_relacion
        PIPELINED;

END;

/

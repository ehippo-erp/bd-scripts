--------------------------------------------------------
--  DDL for Package PACK_FE_RESUMENDIARIO_DET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_FE_RESUMENDIARIO_DET" AS
    TYPE datarecord_fe_resumendiario_det IS RECORD (
        id_cia    fe_resumendiario_det.id_cia%TYPE,
        idres     fe_resumendiario_det.idres%TYPE,
        numint    fe_resumendiario_det.numint%TYPE,
        tipdoc    fe_resumendiario_det.tipdoc%TYPE,
        destipdoc documentos_tipo.descri%TYPE,
        serie     fe_resumendiario_det.series%TYPE,
        numdoc    fe_resumendiario_det.numdoc%TYPE,
        femisi  documentos_cab.femisi%TYPE,
        fgenera documentos_cab.femisi%TYPE,
        codcli    documentos_cab.codcli%TYPE,
        razonc    documentos_cab.razonc%TYPE,
        tipmon    documentos_cab.tipmon%TYPE,
        importe   documentos_cab.preven%TYPE,
        codest    fe_resumendiario_det.estado%TYPE,
        desest    VARCHAR2(100 CHAR)
    );
    TYPE datatable_fe_resumendiario_det IS
        TABLE OF datarecord_fe_resumendiario_det;
    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_idres  VARCHAR2,
        pin_numint VARCHAR2
    ) RETURN datatable_fe_resumendiario_det
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_idres  VARCHAR2
    ) RETURN datatable_fe_resumendiario_det
        PIPELINED;

--    PROCEDURE sp_save (
--        pin_id_cia  IN NUMBER,
--        pin_datos   IN VARCHAR2,
--        pin_opcdml  IN INTEGER,
--        pin_mensaje OUT VARCHAR2
--    );

END;

/

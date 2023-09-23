--------------------------------------------------------
--  DDL for Package PACK_DOCUMENTOS_GUIA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_DOCUMENTOS_GUIA" AS
    TYPE datarecord_buscar IS RECORD (
        id_cia     documentos_cab.id_cia%TYPE,
        numint     documentos_cab.numint%TYPE,
        serie      documentos_cab.series%TYPE,
        numdoc     documentos_cab.numdoc%TYPE,
        codcli     documentos_cab.codcli%TYPE,
        razonc     documentos_cab.razonc%TYPE,
        femisi     documentos_cab.femisi%TYPE,
        tipdoc     documentos_cab.tipdoc%TYPE,
        dtipdoc    VARCHAR2(20),
        atipdoc    VARCHAR2(20),
        renumint   documentos_cab.numint%TYPE,
        reserie    documentos_cab.series%TYPE,
        renumdoc   documentos_cab.numdoc%TYPE,
        refemisi   documentos_cab.femisi%TYPE,
        tipinv     documentos_det.tipinv%TYPE,
        codart     documentos_det.codart%TYPE,
        desart     articulos.descri%TYPE,
        cantid     documentos_det.cantid%TYPE,
        etiqueta   documentos_det.etiqueta%TYPE,
        ancho      documentos_det.ancho%TYPE,
        nrocarrete documentos_det.nrocarrete%TYPE,
        lote       documentos_det.lote%TYPE,
        fvenci     documentos_det.fvenci%TYPE
    );
    TYPE datatable_buscar IS
        TABLE OF datarecord_buscar;
        
--select COUNT(0) from pack_documentos_guia.sp_buscar(66,'01/12/2022',current_date,0);
--
--select COUNT(0) from pack_documentos_guia.sp_buscar(66,'01/12/2022',current_date,1);
--
--select COUNT(0) from pack_documentos_guia.sp_buscar(66,'01/12/2022',current_date,2);
        
    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE,
        pin_inggui NUMBER
    ) RETURN datatable_buscar
        PIPELINED;

--set SERVEROUTPUT on;
--
--DECLARE
--    v_mensaje VARCHAR2(2000);
--BEGIN
--    pack_documentos_guia.sp_update_guiarem_cv(56, 2477, 'admin', v_mensaje);
--    dbms_output.put_line(v_mensaje);
--END;

    PROCEDURE sp_update_guiarem_cv (
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

END;

/

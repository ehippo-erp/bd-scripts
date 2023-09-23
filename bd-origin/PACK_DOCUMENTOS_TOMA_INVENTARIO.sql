--------------------------------------------------------
--  DDL for Package PACK_DOCUMENTOS_TOMA_INVENTARIO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_DOCUMENTOS_TOMA_INVENTARIO" AS
    TYPE datarecord_toma_inventario IS RECORD (
        numint       documentos_cab.numint%TYPE,
        series       documentos_cab.series%TYPE,
        numdoc       documentos_cab.numdoc%TYPE,
        tident       documentos_cab.tident%TYPE,
        ruc          documentos_cab.ruc%TYPE,
        codcli       documentos_cab.codcli%TYPE,
        razonsocial  documentos_cab.razonc%TYPE,
        direccion    documentos_cab.direc1%TYPE,
        fentreg      documentos_cab.fentreg%TYPE,
        femisi       documentos_cab.femisi%TYPE,
        lugemi       documentos_cab.lugemi%TYPE,
        situac       documentos_cab.situac%TYPE,
        situacnombre situacion.dessit%TYPE,
        id           documentos_cab.id%TYPE,
        codmot       documentos_cab.codmot%TYPE,
        codven       documentos_cab.codven%TYPE,
        codsuc       documentos_cab.codsuc%TYPE,
        moneda       documentos_cab.tipmon%TYPE,
        tipcam       documentos_cab.tipcam%TYPE,
        optipinv     documentos_cab.optipinv%TYPE,
        dtipinv      t_inventario.dtipinv%TYPE,
        codalm       documentos_cab.codalm%TYPE,
        desalm       almacen.descri%TYPE,
--        coc_numint    documentos_cab_ordcom.numint%TYPE,
--        coc_fecha     documentos_cab_ordcom.fecha%TYPE,
--        coc_numero    documentos_cab_ordcom.numero%TYPE,
--        coc_contacto  documentos_cab_ordcom.contacto%TYPE,
--        condicionpago c_pago.despag%TYPE,
        vendedor     VARCHAR2(250),
--        codcpag       documentos_cab.codcpag%TYPE,
        coduser      documentos_cab.usuari%TYPE,
        usuario      VARCHAR2(250),
        incigv       VARCHAR2(5),
        porigv       documentos_cab.porigv%TYPE,
        referencia   documentos_cab.numped%TYPE,
        observacion  documentos_cab.observ%TYPE,
        monafe       documentos_cab.monafe%TYPE,
        monina       documentos_cab.monina%TYPE,
        monigv       documentos_cab.monigv%TYPE,
        preven       documentos_cab.preven%TYPE,
        importebruto documentos_cab.totbru%TYPE,
        importe      documentos_cab.preven%TYPE,
        situacimp    documentos_cab_clase.vchar%TYPE,
        dessituacimp VARCHAR2(100),
        flete        documentos_cab.flete%TYPE,
        countadj     documentos_cab.countadj%TYPE,
        seguro       documentos_cab.seguro%TYPE,
        tipdoc       documentos_cab.tipdoc%TYPE,
        dtipdoc      documentos.descri%TYPE,
        motivo       motivos.desmot%TYPE,
        ucreac       documentos_cab.ucreac%TYPE,
        factua       documentos_cab.factua%TYPE,
        fcreac       documentos_cab.fcreac%TYPE
    );
    TYPE datatable_toma_inventario IS
        TABLE OF datarecord_toma_inventario;
    PROCEDURE sp_anular (
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

    PROCEDURE sp_anular_fisico (
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_toma_inventario
        PIPELINED;

--SET SERVEROUTPUT on;
--
--DECLARE
--    v_mensaje VARCHAR2(2000);
--BEGIN
--    pack_documentos_toma_inventario.sp_anular(66,104090,'admin', v_mensaje);
--    dbms_output.put_line(v_mensaje);
--END;
--
--SET SERVEROUTPUT on;
--
--DECLARE
--    v_mensaje VARCHAR2(2000);
--BEGIN
--    pack_documentos_toma_inventario.sp_anular_fisico(66,104090,'admin', v_mensaje);
--    dbms_output.put_line(v_mensaje);
--END;

--SELECT * FROM pack_documentos_toma_inventario.sp_buscar(56,to_date('01/01/23','DD/MM/YY'),to_date('01/01/23','DD/MM/YY'))

END;

/

--------------------------------------------------------
--  DDL for Package PACK_CONSULTAS_CXC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_CONSULTAS_CXC" AS
    TYPE datarecord_ecc_resumen_pendientes IS RECORD (
        desdoc  VARCHAR2(30),
        tipdoc  documentos_cab.tipdoc%TYPE,
        tipmon  documentos_cab.tipmon%TYPE,
        solven  NUMERIC(16, 2),
        dolven  NUMERIC(16, 2),
        eurven  NUMERIC(16, 2),
        solxven NUMERIC(16, 2),
        dolxven NUMERIC(16, 2),
        eurxven NUMERIC(16, 2),
        totsol  NUMERIC(16, 2),
        totdol  NUMERIC(16, 2),
        toteur  NUMERIC(16, 2)
    );
    TYPE datatable_ecc_resumen_pendientes IS
        TABLE OF datarecord_ecc_resumen_pendientes;
    TYPE datarecord_documentos_cancelados IS RECORD (
        id_cia     dcta101.id_cia%TYPE,
        planilla   VARCHAR2(500),
        atipdoc    tdoccobranza.abrevi%TYPE,
        libro      dcta101.libro%TYPE,
        deslib     tlibro.descri%TYPE,
        periodo    dcta101.periodo%TYPE,
        mes        dcta101.mes%TYPE,
        secuencia  dcta101.secuencia%TYPE,
        tipdoc     dcta100.tipdoc%TYPE,
        docume     dcta100.docume%TYPE,
        codcli     dcta100.codcli%TYPE,
        descli     cliente.razonc%TYPE,
        limcre1    cliente.limcre1%TYPE,
        limcre2    cliente.limcre2%TYPE,
        chedev     cliente.chedev%TYPE,
        letpro     cliente.letpro%TYPE,
        renova     cliente.renova%TYPE,
        refina     cliente.refina%TYPE,
        fecing     cliente.fecing%TYPE,
        refere01   dcta100.refere01%TYPE,
        femisi     dcta100.femisi%TYPE,
        fvenci     dcta100.fvenci%TYPE,
        fcance     dcta100.fcance%TYPE,
        fproce     dcta101.femisi%TYPE,
        numbco     dcta101.numbco%TYPE,
        impor01    dcta101.impor01%TYPE,
        impor02    dcta101.impor02%TYPE,
        doccan     dcta101.doccan%TYPE,
        tipcan     dcta101.tipcan%TYPE,
        codban     dcta100.codban%TYPE,
        dtipdoc    tdoccobranza.descri%TYPE,
        dcodtipcan m_pago.codigo%TYPE,
        dtipcan    m_pago.descri%TYPE,
        monori     dcta100.tipmon%TYPE,
        impori     dcta101.importe%TYPE,
        tipmon     dcta100.tipmon%TYPE,
        importe    dcta101.importe%TYPE,
        comisi     dcta100.comisi%TYPE,
        tipcam     dcta100.tipcam%TYPE,
        codven     dcta100.codven%TYPE,
        desven     vendedor.desven%TYPE,
        d4codban   dcta104.codban%TYPE,
        d4desban   tbancos.descri%TYPE,
        usuari     usuarios.coduser%TYPE,
        nomusuari  usuarios.nombres%TYPE
    );
    TYPE datatable_documentos_cancelados IS
        TABLE OF datarecord_documentos_cancelados;
    FUNCTION ecc_resumen_pendientes (
        pin_id_cia      IN NUMBER,---1
        pin_codcli      IN VARCHAR2,---2
        pin_swsolpend   IN VARCHAR2,---3
        pin_swincdocdes IN VARCHAR2,---4
        pin_subicacion  IN VARCHAR2,---5
        pin_numint      IN NUMBER,---6
        pin_swcancela   IN VARCHAR2,---7
        pin_swdcta106   IN VARCHAR2---8
    ) RETURN datatable_ecc_resumen_pendientes
        PIPELINED;

    FUNCTION sp_documentos_cancelados (
        pin_id_cia  NUMBER,
        pin_codcli  VARCHAR2,
        pin_codven  NUMBER,
        pin_codsuc  NUMBER,
        pin_fdesde  DATE,
        pin_fhasta  DATE,
        pin_tipdocs VARCHAR2,-- Tipdoc Concetenados por Comas
        pin_libros  VARCHAR2,-- Libro Concatenados por Comas
        pin_orderby NUMBER-- Tipo de Ordenamiento / 0-1-2
    ) RETURN datatable_documentos_cancelados
        PIPELINED;

END pack_consultas_cxc;

/

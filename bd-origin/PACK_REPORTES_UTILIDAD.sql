--------------------------------------------------------
--  DDL for Package PACK_REPORTES_UTILIDAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_REPORTES_UTILIDAD" AS
    TYPE datarecord_detalle IS RECORD (
        id_cia     documentos_cab.id_cia%TYPE,
        desdoc     documentos_tipo.descri%TYPE,
        series     documentos_cab.series%TYPE,
        numdoc     documentos_cab.numdoc%TYPE,
        femisi     documentos_cab.femisi%TYPE,
        codcli     documentos_cab.codcli%TYPE,
        razonc     documentos_cab.razonc%TYPE,
        numint     documentos_cab.numint%TYPE,
        numite     documentos_det.numite%TYPE,
        tipinv     documentos_det.tipinv%TYPE,
        dtipinv    t_inventario.dtipinv%TYPE,
        codart     documentos_det.codart%TYPE,
        desart     articulos.descri%TYPE,
        codalm     documentos_cab.codalm%TYPE,
        desalm     almacen.descri%TYPE,
        tipmon     documentos_cab.tipmon%TYPE,
        tipcam     documentos_cab.tipcam%TYPE,
        codfam     clase_codigo.clase%TYPE,
        familia    clase_codigo.codigo%TYPE,
        desfam     clase_codigo.descri%TYPE,
        codlin     clase_codigo.clase%TYPE,
        linea      clase_codigo.codigo%TYPE,
        deslin     clase_codigo.descri%TYPE,
        abrmot     motivos.abrevi%TYPE,
        desmot     motivos.desmot%TYPE,
        ventatotal NUMBER(20, 5),
        costot01   NUMBER(20, 5),
        costot02   NUMBER(20, 5),
        cosuni01   NUMBER(20, 5),
        cosuni02   NUMBER(20, 5),
        cantid     documentos_det.cantid%TYPE,
        cospro     NUMBER(20, 5),
        costot     NUMBER(20, 5),
        venpro     NUMBER(20, 5),
        ventot     NUMBER(20, 5),
        margen     NUMBER(20, 5)
    );
    TYPE datatable_detalle IS
        TABLE OF datarecord_detalle;
    TYPE datarecord_resumen IS RECORD (
        id_cia  documentos_cab.id_cia%TYPE,
        tipinv  documentos_det.tipinv%TYPE,
        dtipinv t_inventario.dtipinv%TYPE,
        codart  documentos_det.codart%TYPE,
        desart  articulos.descri%TYPE,
        codfam  clase_codigo.clase%TYPE,
        familia clase_codigo.codigo%TYPE,
        desfam  clase_codigo.descri%TYPE,
        codlin  clase_codigo.clase%TYPE,
        linea   clase_codigo.codigo%TYPE,
        deslin  clase_codigo.descri%TYPE,
        cantid  NUMBER(20, 5),
        cospro  NUMBER(20, 5),
        costot  NUMBER(20, 5),
        venpro  NUMBER(20, 5),
        ventot  NUMBER(20, 5),
        margen  NUMBER(20, 5)
    );
    TYPE datatable_resumen IS
        TABLE OF datarecord_resumen;
    TYPE datarecord_leyenda IS RECORD (
        documento   tdoccobranza.descri%TYPE,
        motivo      motivos.desmot%TYPE,
        cantidad    NUMBER(38),
        costototsol NUMBER(20, 4),
        costototdol NUMBER(20, 4),
        ventatotsol NUMBER(20, 4),
        ventatotdol NUMBER(20, 4)
    );
    TYPE datatable_leyenda IS
        TABLE OF datarecord_leyenda;
    FUNCTION sp_detalle (
        pin_id_cia NUMBER,
        pin_tipinv NUMBER,
        pin_tipo   NUMBER,
        pin_codmon VARCHAR2,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_detalle
        PIPELINED;

    FUNCTION sp_resumen (
        pin_id_cia NUMBER,
        pin_tipinv NUMBER,
        pin_tipo   NUMBER,
        pin_codmon VARCHAR2,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_resumen
        PIPELINED;

    FUNCTION sp_leyenda (
        pin_id_cia NUMBER,
        pin_tipinv NUMBER,
        pin_tipo   NUMBER,
        pin_codmon VARCHAR2,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_leyenda
        PIPELINED;

END;

/

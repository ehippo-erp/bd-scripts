--------------------------------------------------------
--  DDL for Package PACK_REPORTES_TSI_KARDEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_REPORTES_TSI_KARDEX" AS
    TYPE datarecord_resumen_detallado_kardex IS RECORD (
        id_cia   kardex.id_cia%TYPE,
        periodo  NUMBER,
        tipinv   kardex.tipinv%TYPE,
        codart   kardex.codart%TYPE,
        codalm   kardex.codalm%TYPE,
        costot01 kardex.costot01%TYPE,
        costot02 kardex.costot02%TYPE,
        cantid   kardex.cantid%TYPE
    );
    TYPE datatable_resumen_detallado_kardex IS
        TABLE OF datarecord_resumen_detallado_kardex;
    TYPE datarecord_resumen_kardex IS RECORD (
        id_cia   kardex.id_cia%TYPE,
        periodo  NUMBER,
        tipinv   kardex.tipinv%TYPE,
        codalm   kardex.codalm%TYPE,
        costot01 kardex.costot01%TYPE,
        costot02 kardex.costot02%TYPE,
        cantid   kardex.cantid%TYPE
    );
    TYPE datatable_resumen_kardex IS
        TABLE OF datarecord_resumen_kardex;
    TYPE datarecord_apertura_consistencia_detallado IS RECORD (
        tipinv            kardex.tipinv%TYPE,
        tipo_inventario   t_inventario.dtipinv%TYPE,
        codalm            kardex.codalm%TYPE,
        almacen           VARCHAR2(250 CHAR),
        codart            kardex.codart%TYPE,
        articulo          VARCHAR2(250 CHAR),
        periodo_anterior  NUMBER,
        costot01_anterior kardex.costot01%TYPE,
        costot02_anterior kardex.costot02%TYPE,
        cantid_anterior   kardex.cantid%TYPE,
        periodo_nuevo     NUMBER,
--        tipinv_nuevo      kardex.tipinv%TYPE,
--        codalm_nuevo      kardex.codalm%TYPE,
--        codart_nuevo      kardex.codart%TYPE,
        costot01_nuevo    kardex.costot01%TYPE,
        costot02_nuevo    kardex.costot02%TYPE,
        cantid_nuevo      kardex.cantid%TYPE
    );
    TYPE datatable_apertura_consistencia_detallado IS
        TABLE OF datarecord_apertura_consistencia_detallado;
    TYPE datarecord_apertura_consistencia_resumen IS RECORD (
        tipinv            kardex.tipinv%TYPE,
        tipo_inventario   t_inventario.dtipinv%TYPE,
        codalm            kardex.codalm%TYPE,
        almacen           VARCHAR2(250 CHAR),
        periodo_anterior  NUMBER,
        costot01_anterior kardex.costot01%TYPE,
        costot02_anterior kardex.costot02%TYPE,
        cantid_anterior   kardex.cantid%TYPE,
        periodo_nuevo     NUMBER,
--        tipinv_nuevo      kardex.tipinv%TYPE,
--        codalm_nuevo      kardex.codalm%TYPE,
        costot01_nuevo    kardex.costot01%TYPE,
        costot02_nuevo    kardex.costot02%TYPE,
        cantid_nuevo      kardex.cantid%TYPE
    );
    TYPE datatable_apertura_consistencia_resumen IS
        TABLE OF datarecord_apertura_consistencia_resumen;
    FUNCTION sp_resumen_kardex (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER,
        pin_swacti  VARCHAR2
    ) RETURN datatable_resumen_kardex
        PIPELINED;

    FUNCTION sp_resumen_detallado_kardex (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER,
        pin_swacti  VARCHAR2
    ) RETURN datatable_resumen_detallado_kardex
        PIPELINED;

    FUNCTION sp_apertura_consistencia_detallado (
        pin_id_cia NUMBER,
        pin_pdesde NUMBER,
        pin_phasta NUMBER
    ) RETURN datatable_apertura_consistencia_detallado
        PIPELINED;

    FUNCTION sp_apertura_consistencia_resumen (
        pin_id_cia NUMBER,
        pin_pdesde NUMBER,
        pin_phasta NUMBER
    ) RETURN datatable_apertura_consistencia_resumen
        PIPELINED;

    TYPE datarecord_chasis_motor IS RECORD (
        tipo_documento VARCHAR2(2000 CHAR),
        fecha_emision  VARCHAR2(20 CHAR),
        series         documentos_cab.series%TYPE,
        numdoc         documentos_cab.numdoc%TYPE,
        cliente        documentos_cab.codcli%TYPE,
        razon_social   documentos_cab.razonc%TYPE,
        tipo           VARCHAR2(20 CHAR),
        motivo         motivos.desmot%TYPE,
        situac         VARCHAR2(2000 CHAR),
        numero_interno documentos_cab.numint%TYPE,
        item           documentos_det.numite%TYPE,
        codart         documentos_det.codart%TYPE,
        articulo       articulos.descri%TYPE,
        cantidad       documentos_det.cantid%TYPE,
        etiqueta       documentos_det.etiqueta%TYPE,
        chasis         documentos_det.chasis%TYPE,
        motor          documentos_det.motor%TYPE
    );
    TYPE datatable_chasis_motor IS
        TABLE OF datarecord_chasis_motor;
    FUNCTION sp_chasis_motor (
        pin_id_cia NUMBER,
        pin_codcli VARCHAR2,
        pin_chasis VARCHAR2,
        pin_motor  VARCHAR2
    ) RETURN datatable_chasis_motor
        PIPELINED;

END;

/

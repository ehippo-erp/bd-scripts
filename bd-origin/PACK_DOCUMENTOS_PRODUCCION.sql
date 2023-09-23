--------------------------------------------------------
--  DDL for Package PACK_DOCUMENTOS_PRODUCCION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_DOCUMENTOS_PRODUCCION" AS
    TYPE datarecord_movimiento IS RECORD (
        id_cia      documentos_cab.id_cia%TYPE,
        numint      documentos_cab.numint%TYPE,
        series      documentos_cab.series%TYPE,
        numdoc      documentos_cab.numdoc%TYPE,
        codcli      documentos_cab.codcli%TYPE,
        razonc      documentos_cab.razonc%TYPE,
        numintre    documentos_cab.numint%TYPE,
        seriesre    documentos_cab.series%TYPE,
        numdocre    documentos_cab.numdoc%TYPE,
        codclire    documentos_cab.codcli%TYPE,
        razoncre    documentos_cab.razonc%TYPE,
        abrevi      documentos.nomser%TYPE,
        femisi      kardex.femisi%TYPE,
        numite      kardex.numite%TYPE,
        tipinv      kardex.tipinv%TYPE,
        codart      kardex.codart%TYPE,
        desart      articulos.descri%TYPE,
        cantid      kardex.cantid%TYPE,
        id          kardex.id%TYPE,
        cosunisol   kardex.costot01%TYPE,
        cosunidol   kardex.costot01%TYPE,
        costotsol   kardex.costot01%TYPE,
        costotdol   kardex.costot01%TYPE,
        codcalid    kardex.codadd01%TYPE,
        dcalidad    VARCHAR2(500),
        codcolor    kardex.codadd02%TYPE,
        dcolor      VARCHAR2(500),
        etiqueta    kardex.etiqueta%TYPE,
        numintop        documentos_det.numint%TYPE,
        numiteop    documentos_det.numite%TYPE,
        tipinvop    documentos_det.tipinv%TYPE,
        codartop    documentos_det.codart%TYPE,
        desartop    articulos.descri%TYPE,
        cantidop    kardex.cantid%TYPE,
        idop        kardex.id%TYPE,
        cosmat01    kardex.costot01%TYPE,
        cosmob01    kardex.costot01%TYPE,
        cosfab01    kardex.costot01%TYPE,
        cosunisolop kardex.costot01%TYPE,
        cosunidolop kardex.costot01%TYPE,
        costotsolop kardex.costot01%TYPE,
        costotdolop kardex.costot01%TYPE,
        abrevmot    motivos.abrevi%TYPE,
        codadd01op  kardex.codadd01%TYPE,
        dcalidadop  VARCHAR2(500),
        codadd02op  kardex.codadd01%TYPE,
        dcolorop    VARCHAR2(500)
    );
    TYPE datatable_movimiento IS
        TABLE OF datarecord_movimiento;
    TYPE datarecord_distribucion_costo IS RECORD (
        id_cia      documentos_det.id_cia%TYPE,
        opnumdoc    documentos_det.opnumdoc%TYPE,
        opnumite    documentos_det.opnumite%TYPE,
        femisi      documentos_cab.femisi%TYPE,
        keyopnumdoc documentos_det.opnumdoc%TYPE,
        series      documentos_cab.series%TYPE,
        numdoc      documentos_cab.numdoc%TYPE,
        numint      documentos_cab.numint%TYPE,
        tipinv      documentos_det.tipinv%TYPE,
        dtipinv     t_inventario.dtipinv%TYPE,
        codart      documentos_det.codart%TYPE,
        desart      articulos.descri%TYPE,
        metraje     documentos_det.largo%TYPE,
        cantid      kardex.cantid%TYPE,
        cosmatsol   kardex.cosmat01%TYPE,
        cosmobsol   kardex.cosmob01%TYPE,
        cosfabsol   kardex.cosfab01%TYPE,
        cosunisol   kardex.costot01%TYPE,
        cosunidol   kardex.costot01%TYPE,
        costotsol   kardex.costot01%TYPE,
        costotdol   kardex.costot01%TYPE,
        concepto    VARCHAR2(200 CHAR),
        id          kardex.id%TYPE
    );
    TYPE datatable_distribucion_costo IS
        TABLE OF datarecord_distribucion_costo;
    TYPE datarecord_motivo_guia_salida IS RECORD (
        id_cia           motivos.id_cia%TYPE,
        tipdoc           motivos.tipdoc%TYPE,
        id               motivos.id%TYPE,
        codmot           motivos.codmot%TYPE,
        desmot           motivos.desmot%TYPE,
        abrmot           motivos.abrevi%TYPE,
        clase6           motivos_clase.codigo%TYPE,
        clase6valor      motivos_clase.valor%TYPE,
        motoblidocpadre  motivos_clase.valor%TYPE,
        relcossalprod    motivos_clase.valor%TYPE,
        motdevfacbol     motivos_clase.valor%TYPE,
        noimportadetalle motivos_clase.valor%TYPE,
        reclasifica      motivos_clase.valor%TYPE,
        clase01moneda    motivos_clase.valor%TYPE,
        clase10incigv    motivos_clase.valor%TYPE
    );
    TYPE datatable_motivo_guia_salida IS
        TABLE OF datarecord_motivo_guia_salida;
    TYPE datarecord_detalle_items IS RECORD (
        id_cia    documentos_cab.id_cia%TYPE,
        series    documentos_cab.series%TYPE,
        numdoc    documentos_cab.numdoc%TYPE,
        numint    documentos_det.numint%TYPE,
        numite    documentos_det.numite%TYPE,
        codalm    documentos_det.codalm%TYPE,
        tipinv    documentos_det.tipinv%TYPE,
        codart    documentos_det.codart%TYPE,
        desart    articulos.descri%TYPE,
        cantid    documentos_det.cantid%TYPE,
        codund    documentos_det.codund%TYPE,
        preuni    documentos_det.preuni%TYPE,
        etiqueta  documentos_det.etiqueta%TYPE,
        codadd01  documentos_det.codadd01%TYPE,
        codadd02  documentos_det.codadd02%TYPE,
        numintpre documentos_det.numintpre%TYPE,
        numitepre documentos_det.numitepre%TYPE
    );
    TYPE datatable_detalle_items IS
        TABLE OF datarecord_detalle_items;
    TYPE datarecord_reporte_detallado IS RECORD (
        id_cia      documentos_cab.id_cia%TYPE,
        ciaruc      companias.ruc%TYPE,
        ciarazonc   companias.razsoc%TYPE,
        numint      documentos_cab.numint%TYPE,
        numite      documentos_det.numite%TYPE,
        series      documentos_cab.series%TYPE,
        numdoc      documentos_cab.numdoc%TYPE,
        femisi      documentos_cab.femisi%TYPE,
        fentreg     documentos_cab.fentreg%TYPE,
        codcli      documentos_cab.codcli%TYPE,
        razonc      documentos_cab.razonc%TYPE,
        ruc         documentos_cab.ruc%TYPE,
        numped      documentos_cab.numped%TYPE,
        desdoc      documentos.descri%TYPE,
        nomser      documentos.nomser%TYPE,
        desmot      motivos.desmot%TYPE,
        dessit      situacion.dessit%TYPE,
        aliassit    situacion.alias%TYPE,
        tipinv      documentos_det.tipinv%TYPE,
        codart      documentos_det.codart%TYPE,
        desartclase VARCHAR2(200 CHAR),
        cantid      documentos_det.cantid%TYPE,
        piezas      documentos_det.piezas%TYPE,
        largo       documentos_det.largo%TYPE,
        codalm      documentos_det.codalm%TYPE,
        obsdet      documentos_det.observ%TYPE,
        coduni      articulos.coduni%TYPE,
        desart      articulos.descri%TYPE,
        fmeta       documentos_cab.fecter%TYPE,
        nropedido   VARCHAR2(100 CHAR)
    );
    TYPE datatable_reporte_detallado IS
        TABLE OF datarecord_reporte_detallado;
    TYPE datarecord_reporte_resumen IS RECORD (
        id_cia   documentos_cab.id_cia%TYPE,
        ciaruc   companias.ruc%TYPE,
        numint   documentos_cab.numint%TYPE,
        numite   documentos_det.numite%TYPE,
        series   documentos_cab.series%TYPE,
        numdoc   documentos_cab.numdoc%TYPE,
        femisi   documentos_cab.femisi%TYPE,
        codcli   documentos_cab.codcli%TYPE,
        razonc   documentos_cab.razonc%TYPE,
        direc1   documentos_cab.direc1%TYPE,
        ruc      documentos_cab.ruc%TYPE,
        desarea  areas.desarea%TYPE,
        desmot   motivos.desmot%TYPE,
        dessit   situacion.dessit%TYPE,
        aliassit situacion.alias%TYPE,
        tipinv   documentos_det.tipinv%TYPE,
        codart   documentos_det.codart%TYPE,
        desart   articulos.descri%TYPE,
        largo    documentos_det.largo%TYPE,
        cantid   documentos_det.cantid%TYPE,
        coduni   articulos.coduni%TYPE,
        medida   documentos_det.largo%TYPE,
        total    documentos_det.largo%TYPE,
        codalm   documentos_det.codalm%TYPE,
        obsdet   documentos_det.observ%TYPE
    );
    TYPE datatable_reporte_resumen IS
        TABLE OF datarecord_reporte_resumen;
    TYPE datarecord_reporte_frabricacion_documento IS RECORD (
        id_cia      documentos_cab.id_cia%TYPE,
        ciaruc      companias.ruc%TYPE,
        ciarazonc   companias.razsoc%TYPE,
        numint      documentos_cab.numint%TYPE,
        numite      documentos_det.numite%TYPE,
        series      documentos_cab.series%TYPE,
        numdoc      documentos_cab.numdoc%TYPE,
        femisi      documentos_cab.femisi%TYPE,
        fentreg     documentos_cab.fentreg%TYPE,
        codcli      documentos_cab.codcli%TYPE,
        razonc      documentos_cab.razonc%TYPE,
        ruc         documentos_cab.ruc%TYPE,
        numped      documentos_cab.numped%TYPE,
        desdoc      documentos.descri%TYPE,
        nomser      documentos.nomser%TYPE,
        desmot      motivos.desmot%TYPE,
        dessit      situacion.dessit%TYPE,
        aliassit    situacion.alias%TYPE,
        tipinv      documentos_det.tipinv%TYPE,
        codart      documentos_det.codart%TYPE,
        desartclase VARCHAR2(200 CHAR),
        cantid      documentos_det.cantid%TYPE,
        piezas      documentos_det.piezas%TYPE,
        largo       documentos_det.largo%TYPE,
        codalm      documentos_det.codalm%TYPE,
        obsdet      documentos_det.observ%TYPE,
        coduni      articulos.coduni%TYPE,
        desart      articulos.descri%TYPE,
        fmeta       documentos_cab.fecter%TYPE,
        nropedido   VARCHAR2(100 CHAR)
    );
    TYPE datatable_reporte_frabricacion_documento IS
        TABLE OF datarecord_reporte_frabricacion_documento;
    TYPE datarecord_reporte_frabricacion_material IS RECORD (
        cabdet  VARCHAR2(1 CHAR),
        id_cia  documentos_cab.id_cia%TYPE,
        numint  documentos_cab.numint%TYPE,
        numite  documentos_det.numite%TYPE,
        numsec  documentos_materiales.numsec%TYPE,
        tipinv  documentos_det.tipinv%TYPE,
        dtipinv t_inventario.dtipinv%TYPE,
        codalm  documentos_det.codalm%TYPE,
        desalm  almacen.descri%TYPE,
        codart  documentos_det.codart%TYPE,
        desart  articulos.descri%TYPE,
        consto  articulos.consto%TYPE,
        coduni  articulos.coduni%TYPE,
        obsdet  documentos_det.observ%TYPE,
        piezas  documentos_det.piezas%TYPE,
        largo   documentos_det.largo%TYPE,
        cantid  documentos_det.cantid%TYPE,
        medida  documentos_det.largo%TYPE,
        total   documentos_det.largo%TYPE
    );
    TYPE datatable_reporte_frabricacion_material IS
        TABLE OF datarecord_reporte_frabricacion_material;
    FUNCTION sp_motivo_guia_salida (
        pin_id_cia IN NUMBER
    ) RETURN datatable_motivo_guia_salida
        PIPELINED;

    FUNCTION sp_motivo_guia_ingreso (
        pin_id_cia IN NUMBER
    ) RETURN datatable_motivo_guia_salida
        PIPELINED;

    FUNCTION sp_motivo_guia_ingreso_dev (
        pin_id_cia IN NUMBER
    ) RETURN datatable_motivo_guia_salida
        PIPELINED;

    FUNCTION sp_motivo_guia_ingreso_materiales (
        pin_id_cia IN NUMBER
    ) RETURN datatable_motivo_guia_salida
        PIPELINED;

    FUNCTION sp_detalle_items (
        pin_id_cia NUMBER,
        pin_series VARCHAR2,
        pin_numdoc NUMBER
    ) RETURN datatable_detalle_items
        PIPELINED;

    PROCEDURE sp_visar_ordpro (
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

    PROCEDURE sp_anular_ordpro (
        pin_id_cia     IN NUMBER,
        pin_numint     IN NUMBER,
        pin_coduser    IN VARCHAR2,
        pin_comentario IN VARCHAR2,
        pin_mensaje    OUT VARCHAR2
    );

    PROCEDURE sp_reordena_positi (
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

    FUNCTION sp_movimiento (
        pin_id_cia NUMBER,
        pin_ingsal VARCHAR,
        pin_codcli VARCHAR,
        pin_codmot NUMBER,
        pin_codart VARCHAR,
        pin_fdesde DATE,
        pin_fhasta DATE,
        pin_serie  VARCHAR2,
        pin_numdoc NUMBER
    ) RETURN datatable_movimiento
        PIPELINED;

    FUNCTION sp_distribucion_costo (
        pin_id_cia NUMBER,
        pin_codmot NUMBER,
        pin_tipinv NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_distribucion_costo
        PIPELINED;

    FUNCTION sp_reporte_detallado (
        pin_id_cia NUMBER,
        pin_numint NUMBER
    ) RETURN datatable_reporte_detallado
        PIPELINED;

    FUNCTION sp_reporte_resumen (
        pin_id_cia NUMBER,
        pin_numint NUMBER
    ) RETURN datatable_reporte_resumen
        PIPELINED;

    FUNCTION sp_reporte_frabricacion_material (
        pin_id_cia NUMBER,
        pin_numint NUMBER,
        pin_numite NUMBER
    ) RETURN datatable_reporte_frabricacion_material
        PIPELINED;

    FUNCTION sp_reporte_frabricacion_documento (
        pin_id_cia NUMBER,
        pin_numint NUMBER
    ) RETURN datatable_reporte_frabricacion_documento
        PIPELINED;

    FUNCTION sp_reporte_frabricacion_material_final (
        pin_id_cia NUMBER,
        pin_numint NUMBER
    ) RETURN datatable_reporte_frabricacion_material
        PIPELINED;


--set SERVEROUTPUT on;
--
--DECLARE
--    mensaje VARCHAR2(1000);
--BEGIN
--
--    pack_documentos_produccion.sp_visar_ordpro(67,6,'admin',mensaje);
--    DBMS_OUTPUT.PUT_LINE(mensaje);
--
--END;
--
-- set SERVEROUTPUT on;
--
--DECLARE
--    mensaje VARCHAR2(1000);
--BEGIN
--
--    pack_documentos_produccion.sp_anular_ordpro(67,5,'admin','Anulado por Luis',mensaje);
--    DBMS_OUTPUT.PUT_LINE(mensaje);
--
--END;

--SELECT * FROM pack_documentos_produccion.sp_motivo_guia_salida(37);
--
--SELECT * FROM pack_documentos_produccion.sp_motivo_guia_ingreso(66);
--
--SELECT * FROM pack_documentos_produccion.sp_motivo_guia_ingreso_dev(37);
--
--SELECT * FROM pack_documentos_produccion.sp_motivo_guia_ingreso_materiales(37);

--SELECT * FROM pack_documentos_produccion.sp_reporte_detallado(131,515491);
--
--SELECT * FROM pack_documentos_produccion.sp_reporte_resumen(131,515491);

--SELECT SUM(COSMATSOL),SUM(COSMOBSOL),SUM(COSFABSOL) FROM pack_documentos_produccion.sp_distribucion_costo
--(25, 6, 3, to_date('01/09/23','DD/MM/YY'), to_date('15/09/23','DD/MM/YY'))
--
--SELECT * FROM pack_documentos_produccion.sp_distribucion_costo
--(25, 6, 3, to_date('01/09/23','DD/MM/YY'), to_date('15/09/23','DD/MM/YY'))

--SELECT *
--FROM pack_documentos_produccion.sp_movimiento(25, 'I',NULL, 6,NULL, to_date('01/09/23','DD/MM/YY'), to_date('15/09/23','DD/MM/YY'), NULL, -1)
--
--SELECT SUM(COSTOTSOL)
--FROM pack_documentos_produccion.sp_movimiento(25, 'I',NULL, 6,NULL, to_date('01/09/23','DD/MM/YY'), to_date('15/09/23','DD/MM/YY'), NULL, -1)
--
--SELECT *
--FROM pack_documentos_produccion.sp_movimiento(25, 'S',NULL, 6,NULL, to_date('01/09/23','DD/MM/YY'), to_date('15/09/23','DD/MM/YY'), NULL, -1)
--
--SELECT SUM(COSTOTSOL)
--FROM pack_documentos_produccion.sp_movimiento(25, 'S',NULL, 6,NULL, to_date('01/09/23','DD/MM/YY'), to_date('15/09/23','DD/MM/YY'), NULL, -1)


END;

/

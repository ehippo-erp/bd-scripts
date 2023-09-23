--------------------------------------------------------
--  DDL for Package PACK_DEPRECIACION_ACTIVOS_FIJOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_DEPRECIACION_ACTIVOS_FIJOS" AS
    TYPE datarecord_reporte_buscar IS RECORD (
        id_cia        documentos_cab.id_cia%TYPE,
        tipinv        documentos_det.tipinv%TYPE,
        dtipinv       t_inventario.dtipinv%TYPE,
        codigo        clase_codigo.codigo%TYPE,
        descodigo     clase_codigo.descri%TYPE,
        codart        documentos_det.codart%TYPE,
        desart        articulos.descri%TYPE,
        fecadq        articulo_especificacion.vdate%TYPE, -- Fecha de Adquisición
        fecdep        articulo_especificacion.vdate%TYPE, -- Fecha de Depresiación
        actacumulado  articulo_especificacion.vreal%TYPE, -- Total Activo al 01/01/Periodo
        actperiodo    articulo_especificacion.vreal%TYPE, -- Total Activo despues del 01/01/Periodo 
        acttotal      articulo_especificacion.vreal%TYPE, -- Total Activo
        depacumulado  articulos_depreciacion.acumu01%TYPE,
        tasa          VARCHAR2(100),
        depenero      articulos_depreciacion.acumu01%TYPE,
        depfebrero    articulos_depreciacion.acumu01%TYPE,
        depmarzo      articulos_depreciacion.acumu01%TYPE,
        depabril      articulos_depreciacion.acumu01%TYPE,
        depmayo       articulos_depreciacion.acumu01%TYPE,
        depjunio      articulos_depreciacion.acumu01%TYPE,
        depjulio      articulos_depreciacion.acumu01%TYPE,
        depagosto     articulos_depreciacion.acumu01%TYPE,
        depseptiembre articulos_depreciacion.acumu01%TYPE,
        depoctubre    articulos_depreciacion.acumu01%TYPE,
        depnoviembre  articulos_depreciacion.acumu01%TYPE,
        depdiciembre  articulos_depreciacion.acumu01%TYPE,
        depperiodo    articulos_depreciacion.acumu01%TYPE, -- Depreciacion Año
        retperiodo    articulos_depreciacion.acumu01%TYPE, -- Retiro Año
        deptotal      articulos_depreciacion.acumu01%TYPE, -- Total Depreciacion Año
        actneto       articulos_depreciacion.acumu01%TYPE -- Total Neto
    );
    TYPE datatable_reporte_buscar IS
        TABLE OF datarecord_reporte_buscar;
    TYPE datarecord_activo_fijo IS RECORD (
        id_cia              documentos_det.id_cia%TYPE,
        tipinv              documentos_det.tipinv%TYPE,
        dtipinv             t_inventario.dtipinv%TYPE,
        cuenta              clase_codigo.codigo%TYPE,
        descuenta           clase_codigo.descri%TYPE,
        codart              documentos_det.codart%TYPE,
        desart              articulos.descri%TYPE,
        marca               articulo_especificacion.vstrg%TYPE,
        modelo              articulo_especificacion.vstrg%TYPE,
        serie               articulo_especificacion.vstrg%TYPE,
        actacumulado        articulos_depreciacion.acumu01%TYPE,
        actperiodo          articulos_depreciacion.acumu01%TYPE,
        actmejora           articulos_depreciacion.acumu01%TYPE,
        actretiro_bajas     articulos_depreciacion.acumu01%TYPE,
        actajsute_otros     articulos_depreciacion.acumu01%TYPE, -- NO DEFINIDO DELPHI
        acthis_acumulado    articulos_depreciacion.acumu01%TYPE,
        actajuste_inflacion articulos_depreciacion.acumu01%TYPE, -- NO DEFINIDO DELPHI
        actaju_acumulado    articulos_depreciacion.acumu01%TYPE,
        fecadq              DATE,
        fecdep              DATE,
        tasa                clase_codigo.codigo%TYPE,
        codmetdep           clase_codigo.codigo%TYPE,
        desmetdep           clase_codigo.descri%TYPE,
        depacumulado        articulos_depreciacion.acumu01%TYPE,
        depperiodo          articulos_depreciacion.acumu01%TYPE,
        depretiro_bajas     articulos_depreciacion.acumu01%TYPE,
        depajuste_otros     articulos_depreciacion.acumu01%TYPE,
        dephis_acumulado    articulos_depreciacion.acumu01%TYPE,
        depajuste_inflacion articulos_depreciacion.acumu01%TYPE,
        depaju_acumulado    articulos_depreciacion.acumu01%TYPE
    );
    TYPE datatable_activo_fijo IS
        TABLE OF datarecord_activo_fijo;
    TYPE datarecord_activo_leasing IS RECORD (
        id_cia    documentos_det.id_cia%TYPE,
        tipinv    documentos_det.tipinv%TYPE,
        dtipinv   t_inventario.dtipinv%TYPE,
        codart    documentos_det.codart%TYPE,
        desart    articulos.descri%TYPE,
        fcontra   articulo_especificacion.vdate%TYPE,
        nrocontra articulo_especificacion.vstrg%TYPE,
        finicio   articulo_especificacion.vdate%TYPE,
        nrocuotas articulo_especificacion.ventero%TYPE,
        monto     articulo_especificacion.vreal%TYPE
    );
    TYPE datatable_activo_leasing IS
        TABLE OF datarecord_activo_leasing;
    TYPE datarecord_depreciacion IS RECORD (
        actacumulado        articulos_depreciacion.acumu01%TYPE,
        actperiodo          articulos_depreciacion.acumu01%TYPE,
        actmejora           articulos_depreciacion.acumu01%TYPE,
        actretiro_bajas     articulos_depreciacion.acumu01%TYPE,
        actajsute_otros     articulos_depreciacion.acumu01%TYPE, -- NO DEFINIDO DELPHI
        acthis_acumulado    articulos_depreciacion.acumu01%TYPE,
        actajuste_inflacion articulos_depreciacion.acumu01%TYPE, -- NO DEFINIDO DELPHI
        actaju_acumulado    articulos_depreciacion.acumu01%TYPE,
        depacumulado        articulos_depreciacion.acumu01%TYPE,
        depperiodo          articulos_depreciacion.acumu01%TYPE,
        depretiro_bajas     articulos_depreciacion.acumu01%TYPE,
        depajuste_otros     articulos_depreciacion.acumu01%TYPE,-- NO DEFINIDO DELPHI
        dephis_acumulado    articulos_depreciacion.acumu01%TYPE,
        depajuste_inflacion articulos_depreciacion.acumu01%TYPE,
        depaju_acumulado    articulos_depreciacion.acumu01%TYPE
    );
    TYPE datatable_depreciacion IS
        TABLE OF datarecord_depreciacion;

--    SELECT * FROM pack_depreciacion_activos_fijos.sp_buscar(74,2023,1,NULL,NULL);

    FUNCTION sp_depreciacion (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER,
        pin_tipinv  NUMBER,
        pin_codart  VARCHAR2
    ) RETURN datatable_depreciacion
        PIPELINED;

    FUNCTION sp_reporte (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER,
        pin_mes     NUMBER,
        pin_clase   NUMBER
    ) RETURN datatable_reporte_buscar
        PIPELINED;

    FUNCTION sp_activo_fijo (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER
    ) RETURN datatable_activo_fijo
        PIPELINED;

    FUNCTION sp_activo_leasing (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER
    ) RETURN datatable_activo_leasing
        PIPELINED;

    PROCEDURE sp_procesar (
        pin_id_cia  IN NUMBER,
        pin_tipinv  IN NUMBER,
        pin_codart  IN VARCHAR2,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

    PROCEDURE sp_recalcular (
        pin_id_cia  IN NUMBER,
        pin_tipinv  IN NUMBER,
        pin_codart  IN VARCHAR2,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

END;

/

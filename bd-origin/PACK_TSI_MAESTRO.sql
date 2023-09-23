--------------------------------------------------------
--  DDL for Package PACK_TSI_MAESTRO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_TSI_MAESTRO" AS
    TYPE datarecord_cliente IS RECORD (
        codigo                cliente.codcli%TYPE,
        razon_social          cliente.razonc%TYPE,
        tipo_persona          t_persona.destpe%TYPE,
        documento             identidad.descri%TYPE,
        nro_identidad         cliente.dident%TYPE,
        direccion_fiscal      cliente.direc1%TYPE,
        telefono              cliente.telefono%TYPE,
        correo_electronico    cliente.email%TYPE,
        ubigeo                clase_cliente_codigo.codigo%TYPE,
        departamento          clase_cliente_codigo.descri%TYPE,
        provincia             clase_cliente_codigo.descri%TYPE,
        distrito              clase_cliente_codigo.descri%TYPE,
        situacion             clase_cliente_codigo.descri%TYPE,
        linea_crédito         cliente.limcre2%TYPE,
        condicion_pago        c_pago.despag%TYPE,
        codven                cliente.codven%TYPE,
        vendedor              VARCHAR2(1000 CHAR),
        grupo_economico       clase_cliente_codigo.descri%TYPE,
        grupo_cliente         clase_cliente_codigo.descri%TYPE,
        clasificacion_cliente clase_cliente_codigo.descri%TYPE,
        fidelidad             clase_cliente_codigo.descri%TYPE
    );
    TYPE datatable_cliente IS
        TABLE OF datarecord_cliente;
    TYPE datarecord_proveedor IS RECORD (
        codigo                cliente.codcli%TYPE,
        razon_social          cliente.razonc%TYPE,
        tipo_persona          t_persona.destpe%TYPE,
        documento             identidad.descri%TYPE,
        nro_identidad         cliente.dident%TYPE,
        direccion_fiscal      cliente.direc1%TYPE,
        telefono              cliente.telefono%TYPE,
        correo_electronico    cliente.email%TYPE,
        ubigeo                clase_cliente_codigo.codigo%TYPE,
        departamento          clase_cliente_codigo.descri%TYPE,
        provincia             clase_cliente_codigo.descri%TYPE,
        distrito              clase_cliente_codigo.descri%TYPE,
        situacion             clase_cliente_codigo.descri%TYPE,
        linea_crédito         cliente.limcre2%TYPE,
        condicion_pago        c_pago.despag%TYPE,
        codven                cliente.codven%TYPE,
        vendedor              VARCHAR2(1000 CHAR),
        grupo_economico       clase_cliente_codigo.descri%TYPE,
        grupo_cliente         clase_cliente_codigo.descri%TYPE,
        clasificacion_cliente clase_cliente_codigo.descri%TYPE
    );
    TYPE datatable_proveedor IS
        TABLE OF datarecord_proveedor;
    TYPE datarecord_cliente_proveedor IS RECORD (
        tipo                  VARCHAR2(100 CHAR),
        codigo                cliente.codcli%TYPE,
        razon_social          cliente.razonc%TYPE,
        tipo_persona          t_persona.destpe%TYPE,
        documento             identidad.descri%TYPE,
        nro_identidad         cliente.dident%TYPE,
        direccion_fiscal      cliente.direc1%TYPE,
        telefono              cliente.telefono%TYPE,
        correo_electronico    cliente.email%TYPE,
        ubigeo                clase_cliente_codigo.codigo%TYPE,
        departamento          clase_cliente_codigo.descri%TYPE,
        provincia             clase_cliente_codigo.descri%TYPE,
        distrito              clase_cliente_codigo.descri%TYPE,
        situacion             clase_cliente_codigo.descri%TYPE,
        grupo_economico       clase_cliente_codigo.descri%TYPE,
        grupo_cliente         clase_cliente_codigo.descri%TYPE,
        clasificacion_cliente clase_cliente_codigo.descri%TYPE
    );
    TYPE datatable_cliente_proveedor IS
        TABLE OF datarecord_cliente_proveedor;
    TYPE datarecord_plan_cuenta IS RECORD (
        cuenta                   pcuentas.cuenta%TYPE,
        descripcion              pcuentas.nombre%TYPE,
        dh                       VARCHAR2(100 CHAR),
        nivel                    VARCHAR2(100 CHAR),
        moneda_01                VARCHAR2(100 CHAR),
        moneda_02                VARCHAR2(100 CHAR),
        analitica                VARCHAR2(100 CHAR),
        destino_automatico       VARCHAR2(100 CHAR),
        destino_debe             VARCHAR2(100 CHAR),
        destino_haber            VARCHAR2(100 CHAR),
        imputable                VARCHAR2(100 CHAR),
        pide_referencia          VARCHAR2(100 CHAR),
        pide_centro_costo        VARCHAR2(100 CHAR),
        incluir_balance          VARCHAR2(100 CHAR),
        pedir_proyecto           VARCHAR2(100 CHAR),
        conciliacion             VARCHAR2(100 CHAR),
        moneda01                 VARCHAR2(100 CHAR),
        moneda02                 VARCHAR2(100 CHAR),
        documento_origen         VARCHAR2(100 CHAR),
        tipo_gasto               VARCHAR2(100 CHAR),
        columna_registro_compras VARCHAR2(100 CHAR),
        columna_registro_ventas  VARCHAR2(100 CHAR),
        columna_balance          VARCHAR2(100 CHAR)
    );
    TYPE datatable_plan_cuenta IS
        TABLE OF datarecord_plan_cuenta;
    FUNCTION sp_cliente (
        pin_id_cia NUMBER
    ) RETURN datatable_cliente
        PIPELINED;

    FUNCTION sp_proveedor (
        pin_id_cia NUMBER
    ) RETURN datatable_proveedor
        PIPELINED;

    FUNCTION sp_cliente_proveedor (
        pin_id_cia NUMBER
    ) RETURN datatable_cliente_proveedor
        PIPELINED;

    FUNCTION sp_plan_cuenta (
        pin_id_cia NUMBER
    ) RETURN datatable_plan_cuenta
        PIPELINED;

END;

/

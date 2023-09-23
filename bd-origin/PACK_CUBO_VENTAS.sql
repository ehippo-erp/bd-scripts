--------------------------------------------------------
--  DDL for Package PACK_CUBO_VENTAS
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_CUBO_VENTAS" IS
    TYPE datarecord IS RECORD (
        documento    VARCHAR2(50),
        sucursal     VARCHAR2(20),
        mes          VARCHAR2(12),
        periodo      INTEGER,
        mesid        VARCHAR2(8),
        serie        VARCHAR2(5),
        numdoc       INTEGER,
        femisi       DATE,
        tcambio      NUMERIC(10, 6),
        codcli       VARCHAR2(20),
        clase_abc    VARCHAR2(70),
        clascli      VARCHAR2(70),
        tipcli       VARCHAR2(70),
        cliente      VARCHAR2(80),
        fcreac_cli   TIMESTAMP,
        ruc          VARCHAR(20),
        fpago        VARCHAR2(50 CHAR),
        motivo       VARCHAR2(50),
        vencompvnt   VARCHAR2(50),
        venasigcli   VARCHAR2(50),
        moneda       VARCHAR2(5),
        tipinv       SMALLINT,
        proveedor    VARCHAR2(80),
        lineanegocio VARCHAR2(70),
        famproducto  VARCHAR(70),
        tipoproducto VARCHAR(70),
        clasproducto VARCHAR(70),
        codigo       VARCHAR2(40),
        descripcion  VARCHAR2(100),
        cantidad     NUMERIC(16, 5),
        cosunisol    NUMERIC(16, 2),
        cosunidol    NUMERIC(16, 2),
        cantidori    NUMERIC(16, 5),
        prenetunisol NUMERIC(16, 4),
        prenetunidol NUMERIC(16, 4),
        ventatotsol  NUMERIC(16, 4),
        ventatotdol  NUMERIC(16, 4),
        salpen       NUMERIC(16, 2),
        cancelado    VARCHAR2(10),
        comision     DOUBLE PRECISION,
        departamento VARCHAR2(70),
        provincia    VARCHAR2(70),
        distrito     VARCHAR2(70),
        geconomico   VARCHAR2(70),
        coduseremi   VARCHAR2(10),
        usuariemit   VARCHAR2(70),
        tlista       VARCHAR2(50),
        margenprov   VARCHAR2(70),
        supervisor   VARCHAR2(100),
        ordenpedido  VARCHAR2(30),
        usuaremitop  VARCHAR2(80)
    );
    TYPE datatable IS
        TABLE OF datarecord;
    TYPE datarecord_cubo_ventas2 IS RECORD (
        documento              tdoccobranza.descri%TYPE,
        sucursal               VARCHAR2(250),
        diasemana              VARCHAR2(25),
        mes                    VARCHAR2(25),
        periodo                NUMBER(38),
        mesid                  NUMBER(38),
        serie                  documentos_cab.series%TYPE,
        nro_documento          documentos_cab.numdoc%TYPE,
        fecha_emision          VARCHAR2(100),
        tipo_cambio            documentos_cab.tipcam%TYPE,
        codigo_cliente         documentos_cab.codcli%TYPE,
        clasificacion_cliente  VARCHAR2(250),
        tipo_cliente           VARCHAR2(250),
        cliente                documentos_cab.razonc%TYPE,
        ruc                    documentos_cab.ruc%TYPE,
        forma_pago             c_pago.despag%TYPE,
        motivo                 motivos.desmot%TYPE,
        vendedor               VARCHAR2(250),
        moneda                 documentos_cab.tipmon%TYPE,
        tipo_inventario        documentos_det.tipinv%TYPE,
        linea_negocio          VARCHAR2(250),
        familia_producto       VARCHAR2(250),
        tipo_producto          VARCHAR2(250),
        clasificacion_producto VARCHAR2(250),
        codigo                 documentos_det.codart%TYPE,
        descripcion            articulos.descri%TYPE,
        cantidad               NUMBER(38),
        cstunisol              NUMBER(20, 4),
        cstunidol              NUMBER(20, 4),
        costototsol            NUMBER(20, 4),
        costototdol            NUMBER(20, 4),
        preunisol              NUMBER(20, 4),
        preunidol              NUMBER(20, 4),
        ventatotsol            NUMBER(20, 4),
        ventatotdol            NUMBER(20, 4),
        rentabsol              NUMBER(20, 4),
        porcentsol             NUMBER(20, 4),
        comision               documentos_det_clase.vreal%TYPE,
        departamento           VARCHAR2(250),
        provincia              VARCHAR2(250),
        distrito               VARCHAR2(250),
        grupo_economico        VARCHAR2(250),
        transferencia_gratuita VARCHAR2(1 CHAR)
    );
    TYPE datatable_cubo_ventas2 IS
        TABLE OF datarecord_cubo_ventas2;
    TYPE datarecord_cubo_ventas3 IS RECORD (
        documento              tdoccobranza.descri%TYPE,
        sucursal               VARCHAR2(250),
        diasemana              VARCHAR2(25),
        mes                    VARCHAR2(25),
        periodo                NUMBER(38),
        mesid                  NUMBER(38),
        serie                  documentos_cab.series%TYPE,
        nro_documento          documentos_cab.numdoc%TYPE,
        fecha_emision          VARCHAR2(250),
        tipo_cambio            documentos_cab.tipcam%TYPE,
        codigo_cliente         documentos_cab.codcli%TYPE,
        clasificacion_cliente  VARCHAR2(250),
        tipo_cliente           VARCHAR2(250),
        cliente                documentos_cab.razonc%TYPE,
        ruc                    documentos_cab.ruc%TYPE,
        forma_pago             c_pago.despag%TYPE,
        motivo                 motivos.desmot%TYPE,
        vendedor               VARCHAR2(250),
        moneda                 documentos_cab.tipmon%TYPE,
        tipo_inventario        documentos_det.tipinv%TYPE,
        linea_negocio          VARCHAR2(250),
        familia_producto       VARCHAR2(250),
        tipo_producto          VARCHAR2(250),
        clasificacion_producto VARCHAR2(250),
        codigo                 documentos_det.codart%TYPE,
        descripcion            articulos.descri%TYPE,
        etiqueta               kardex001.etiqueta%TYPE,
        chasis                 kardex001.chasis%TYPE,
        motor                  kardex001.motor%TYPE,
        cantidad               NUMBER(38),
        cstunisol              NUMBER(20, 4),
        cstunidol              NUMBER(20, 4),
        costototsol            NUMBER(20, 4),
        costototdol            NUMBER(20, 4),
        preunisol              NUMBER(20, 4),
        preunidol              NUMBER(20, 4),
        ventatotsol            NUMBER(20, 4),
        ventatotdol            NUMBER(20, 4),
        rentabsol              NUMBER(20, 4),
        porcentsol             NUMBER(20, 4),
        comision               documentos_det_clase.vreal%TYPE,
        departamento           VARCHAR2(250),
        provincia              VARCHAR2(250),
        distrito               VARCHAR2(250),
        grupo_economico        VARCHAR2(250),
        transferencia_gratuita VARCHAR2(1 CHAR)
    );
    TYPE datatable_cubo_ventas3 IS
        TABLE OF datarecord_cubo_ventas3;
    TYPE datarecord_cubo_ventas4 IS RECORD (
        documento                tdoccobranza.descri%TYPE,
        sucursal                 VARCHAR2(250),
        mes                      VARCHAR2(25),
        periodo                  NUMBER(38),
        fecha_emision            VARCHAR2(250),
        fecha_emision_date       DATE,
        mesid                    NUMBER(38),
        serie                    documentos_cab.series%TYPE,
        nro_documento            documentos_cab.numdoc%TYPE,
        forma_de_pago            c_pago.despag%TYPE,
        codigo_cliente           documentos_cab.codcli%TYPE,
        cliente                  documentos_cab.razonc%TYPE,
        ruc                      documentos_cab.ruc%TYPE,
        vendedor                 VARCHAR2(250),
        t_inventario             documentos_det.tipinv%TYPE,
        codigo                   documentos_det.codart%TYPE,
        descripcion              articulos.descri%TYPE,
        familia                  VARCHAR2(250),
        linea                    VARCHAR2(250),
        marca                    VARCHAR2(250),
        cuenta_contable          VARCHAR2(250),
        descripcion_cuenta       VARCHAR2(250),
        codalm                   NUMBER(38),
        almacen                  VARCHAR2(50),
        cantidad                 NUMBER(38),
        prenetunisol             NUMBER(20, 4),
        prenetunidol             NUMBER(20, 4),
        ventatotsol              NUMBER(20, 4),
        ventatotdol              NUMBER(20, 4),
        t_cambio                 documentos_cab.tipcam%TYPE,
        moneda                   documentos_cab.tipmon%TYPE,
        motivo                   motivos.desmot%TYPE,
        grupo_de_cliente         VARCHAR2(250),
        clasificacion_de_cliente VARCHAR2(250),
        departamento             VARCHAR2(250),
        provincia                VARCHAR2(250),
        distrito                 VARCHAR2(250),
        zona                     VARCHAR2(250),
        tipo_venta               VARCHAR2(250),
        dioptria                 documentos_det.ancho%TYPE,
        lote                     documentos_det.lote%TYPE,
        serie_etiqueta           documentos_det.nrocarrete%TYPE,
        transferencia_gratuita   VARCHAR2(1 CHAR)
    );
    TYPE datatable_cubo_ventas4 IS
        TABLE OF datarecord_cubo_ventas4;
    TYPE datarecord_cubo_ventas5 IS RECORD (
        documento              documentos_tipo.descri%TYPE,
        mes                    meses.desmin%TYPE,
        serie                  documentos_cab.series%TYPE,
        nro_documento          documentos_cab.numdoc%TYPE,
        fecha_emision          VARCHAR2(250 CHAR),
        tcambio                documentos_cab.tipcam%TYPE,
        codigo_cliente         documentos_cab.codcli%TYPE,
        cliente                documentos_cab.razonc%TYPE,
        ruc                    documentos_cab.ruc%TYPE,
        motivo                 motivos.desmot%TYPE,
        forma_de_pago          c_pago.despag%TYPE,
        vendedor_abreviatura   vendedor.abrevi%TYPE,
        vendedo_asig_cliente   vendedor.desven%TYPE,
        moneda                 documentos_cab.tipmon%TYPE,
        item_fac               documentos_det.numite%TYPE,
        tinventario            documentos_det.tipinv%TYPE,
        tipo_de_inventario     t_inventario.dtipinv%TYPE,
        codigo                 documentos_det.codart%TYPE,
        descripcion            articulos.descri%TYPE,
        etiqueta               documentos_det.etiqueta%TYPE,
        dioptria               documentos_det.ancho%TYPE,
        lote                   documentos_det.lote%TYPE,
        serie_articulo         documentos_det.nrocarrete%TYPE,
        fecha_de_vencimiento   VARCHAR2(250),
        codigo_almacen         documentos_det.codalm%TYPE,
        almacen                VARCHAR2(1000 CHAR),
        costo_almacen          NUMBER(16, 2),
        proveedor              VARCHAR2(1000 CHAR),
        especialidad           VARCHAR2(1000 CHAR),
        sub_familia            VARCHAR2(1000 CHAR),
        cantidad               documentos_det.cantid%TYPE,
        precio_unit_soles      NUMBER(16, 2),
        venta_total_soles      NUMBER(16, 2),
        costo_unitario         NUMBER(16, 2),
        costo_total_soles      NUMBER(16, 2),
        rentabilidad_soles     NUMBER(16, 2),
        porcentaje             NUMBER(16, 2),
        saldo_pendiente        documentos_det.saldo%TYPE,
        cancelado              VARCHAR2(1000 CHAR),
        departamento           VARCHAR2(1000 CHAR),
        provincia              VARCHAR2(1000 CHAR),
        distrito               VARCHAR2(1000 CHAR),
        zona                   VARCHAR2(1000 CHAR),
        grupo_de_cliente       VARCHAR2(1000 CHAR),
        fidelidad              VARCHAR2(1000 CHAR),
        situacion_de_cliente   VARCHAR2(1000 CHAR),
        transferencia_gratuita VARCHAR2(1 CHAR)
    );
    TYPE datatable_cubo_ventas5 IS
        TABLE OF datarecord_cubo_ventas5;
    TYPE datarecord_cubo_ventas6 IS RECORD (
        documento                  tdoccobranza.descri%TYPE,
        sucursal                   VARCHAR2(250),
        diasemana                  VARCHAR2(25),
        mes                        VARCHAR2(25),
        periodo                    NUMBER(38),
        mesid                      NUMBER(38),
        serie                      documentos_cab.series%TYPE,
        nro_documento              documentos_cab.numdoc%TYPE,
        fecha_emision              VARCHAR2(250),
        tipo_cambio                documentos_cab.tipcam%TYPE,
        codigo_cliente             documentos_cab.codcli%TYPE,
        clase_abc                  VARCHAR2(250),
        clasificacion_cliente      VARCHAR2(250),
        tipo_cliente               VARCHAR2(250),
        cliente                    documentos_cab.razonc%TYPE,
        fecha_creacion_del_cliente VARCHAR2(250),
        ruc                        documentos_cab.ruc%TYPE,
        forma_pago                 c_pago.despag%TYPE,
        motivo                     motivos.desmot%TYPE,
        vendedor_de_comp_vnt       VARCHAR2(250),
        vendedor_asig_cliente      VARCHAR2(250),
        moneda                     documentos_cab.tipmon%TYPE,
        tipo_inventario            documentos_det.tipinv%TYPE,
        proveedor                  VARCHAR2(250),
        linea_negocio              VARCHAR2(250),
        familia_producto           VARCHAR2(250),
        tipo_producto              VARCHAR2(250),
        clasificacion_producto     VARCHAR2(250),
        codigo                     documentos_det.codart%TYPE,
        descripcion                articulos.descri%TYPE,
        cantidad_costo             NUMBER(20, 4),
        costo_unit_soles           NUMBER(20, 4),
        costo_unit_dolares         NUMBER(20, 4),
        cantidad                   NUMBER(20, 4),
        prenetunisol               NUMBER(20, 4),
        prenetunidol               NUMBER(20, 4),
        ventatotsol                NUMBER(20, 4),
        ventatotdol                NUMBER(20, 4),
        moniscsoles                NUMBER(20, 4),
        valporisc                  NUMBER(20, 4),
        monigvsoles                NUMBER(20, 4),
        saldo_pendiente            NUMBER(20, 4),
        cancelado                  VARCHAR2(250 CHAR),
        comision                   documentos_det_clase.vreal%TYPE,
        departamento               VARCHAR2(250),
        provincia                  VARCHAR2(250),
        distrito                   VARCHAR2(250),
        grupo_economico            VARCHAR2(250),
        canal                      VARCHAR2(250),
        cod_user_emitio            usuarios.coduser%TYPE,
        usuario_emitido            usuarios.nombres%TYPE,
        titulo_lista_precios       titulolista.titulo%TYPE,
        margen_proveedor           VARCHAR2(250),
        supervisor                 VARCHAR2(250),
        orden_de_pedido            VARCHAR2(250),
        usuario_que_emitio_op      VARCHAR2(250),
        transferencia_gratuita     VARCHAR2(1 CHAR)
    );
    TYPE datatable_cubo_ventas6 IS
        TABLE OF datarecord_cubo_ventas6;
    TYPE datarecord_cubo_ventas7 IS RECORD (
        documento              tdoccobranza.descri%TYPE,
        sucursal               VARCHAR2(250),
        diasemana              VARCHAR2(25),
        mes                    VARCHAR2(25),
        periodo                NUMBER(38),
        mesid                  NUMBER(38),
        serie                  documentos_cab.series%TYPE,
        nro_documento          documentos_cab.numdoc%TYPE,
        fecha_emision          VARCHAR2(250),
        tipo_cambio            documentos_cab.tipcam%TYPE,
        codigo_cliente         documentos_cab.codcli%TYPE,
        clasificacion_cliente  VARCHAR2(250),
        tipo_cliente           VARCHAR2(250),
        cliente                documentos_cab.razonc%TYPE,
        ruc                    documentos_cab.ruc%TYPE,
        forma_pago             c_pago.despag%TYPE,
        motivo                 motivos.desmot%TYPE,
--        codven                 vendedor.codven%TYPE,
        vendedor               VARCHAR2(250),
        moneda                 documentos_cab.tipmon%TYPE,
        tipo_inventario        documentos_det.tipinv%TYPE,
        linea_negocio          VARCHAR2(250),
        familia_producto       VARCHAR2(250),
        tipo_producto          VARCHAR2(250),
        clasificacion_producto VARCHAR2(250),
        codigo                 documentos_det.codart%TYPE,
        descripcion            articulos.descri%TYPE,
        cantidad               NUMBER(38),
--        cstunisol              NUMBER(20, 4),
--        cstunidol              NUMBER(20, 4),
--        costototsol            NUMBER(20, 4),
--        costototdol            NUMBER(20, 4),
        prenetunisol           NUMBER(20, 4),
        prenetunidol           NUMBER(20, 4),
        ventatotsol            NUMBER(20, 4),
        ventatotdol            NUMBER(20, 4),
--        rentabsol              NUMBER(20, 4),
--        porcentsol             NUMBER(20, 4),
        comision               documentos_det_clase.vreal%TYPE,
        departamento           VARCHAR2(250),
        provincia              VARCHAR2(250),
        distrito               VARCHAR2(250),
        grupo_economico        VARCHAR2(250),
        transferencia_gratuita VARCHAR2(1 CHAR)
    );
    TYPE datatable_cubo_ventas7 IS
        TABLE OF datarecord_cubo_ventas7;
    TYPE datarecord_cubo_ventas8 IS RECORD (
        id_cia                 documentos_cab.id_cia%TYPE,
        tipdoc                 documentos_cab.tipdoc%TYPE,
        documento              tdoccobranza.descri%TYPE,
        codmot                 motivos.codmot%TYPE,
        motivo                 motivos.desmot%TYPE,
        tipinv                 documentos_det.tipinv%TYPE,
        codart                 documentos_det.codart%TYPE,
        etiqueta               documentos_det.etiqueta%TYPE,
        cantidad               NUMBER(38),
        cstunisol              NUMBER(20, 4),
        cstunidol              NUMBER(20, 4),
        costototsol            NUMBER(20, 4),
        costototdol            NUMBER(20, 4),
        preunisol              NUMBER(20, 4),
        preunidol              NUMBER(20, 4),
        ventatotsol            NUMBER(20, 4),
        ventatotdol            NUMBER(20, 4),
        transferencia_gratuita VARCHAR2(1 CHAR),
        imprime_utilidad       VARCHAR2(1 CHAR)
    );
    TYPE datatable_cubo_ventas8 IS
        TABLE OF datarecord_cubo_ventas8;
    FUNCTION sp_cuboventas001 (
        pin_id_cia NUMBER,
        pin_numint INTEGER,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable
        PIPELINED;

    FUNCTION sp_cuboventas002 (
        pin_id_cia NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_cubo_ventas2
        PIPELINED;

    -- Cubo de Ventas para Bulos
    FUNCTION sp_cuboventas003 (
        pin_id_cia NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_cubo_ventas3
        PIPELINED;

    -- Cubo de Ventas para ASG
    FUNCTION sp_cuboventas004 (
        pin_id_cia NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_cubo_ventas4
        PIPELINED;

    -- Cubo de Ventas para Taga
    FUNCTION sp_cuboventas005 (
        pin_id_cia NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_cubo_ventas5
        PIPELINED;

    -- Cubo de Ventas para RamirezFood
    FUNCTION sp_cuboventas006 (
        pin_id_cia NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_cubo_ventas6
        PIPELINED;

    -- Cubo de Ventas para *Opticas, creo revisar****
    FUNCTION sp_cuboventas007 (
        pin_id_cia NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_cubo_ventas7
        PIPELINED;

    FUNCTION sp_cuboventas008 (
        pin_id_cia NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_cubo_ventas8
        PIPELINED;

END pack_cubo_ventas;

/

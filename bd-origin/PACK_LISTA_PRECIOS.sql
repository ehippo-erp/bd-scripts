--------------------------------------------------------
--  DDL for Package PACK_LISTA_PRECIOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_LISTA_PRECIOS" AS
    TYPE datarecord_buscar_all IS RECORD (
        id_cia      listaprecios.id_cia%TYPE,
        vencom      listaprecios.vencom%TYPE,
        codtit      listaprecios.codtit%TYPE,
        codpro      listaprecios.codpro%TYPE,
        tipinv      listaprecios.tipinv%TYPE,
        codart      listaprecios.codart%TYPE,
        desart      articulos.descri%TYPE,
        codmon      listaprecios.codmon%TYPE,
        simbolo     tmoneda.simbolo%TYPE,
        codund      articulos.coduni%TYPE,
        precio      listaprecios.precio%TYPE,
        incigv      VARCHAR2(10),
        modpre      listaprecios.modpre%TYPE,
        desc01      listaprecios.desc01%TYPE,
        desc02      listaprecios.desc02%TYPE,
        desc03      listaprecios.desc03%TYPE,
        desc04      listaprecios.desc04%TYPE,
        porigv      listaprecios.porigv%TYPE,
        sku         listaprecios.sku%TYPE,
        desartcom   listaprecios.desart%TYPE,
        desmax      listaprecios.desmax%TYPE,
        margen      listaprecios.margen%TYPE,
        otros       listaprecios.otros%TYPE,
        flete       listaprecios.flete%TYPE,
        desmaxmon   listaprecios.desmaxmon%TYPE,
        desinc      listaprecios.desinc%TYPE,
        precionac   listaprecios.precionac%TYPE,
        codadd01    VARCHAR2(10),
        descodadd01 VARCHAR2(100),
        codadd02    VARCHAR2(10),
        descodadd02 VARCHAR2(100)
    );
    TYPE datatable_buscar_all IS
        TABLE OF datarecord_buscar_all;
    TYPE datarecord_buscar IS RECORD (
        id_cia      listaprecios.id_cia%TYPE,
        codtit      listaprecios.codtit%TYPE,
        tipinv      listaprecios.tipinv%TYPE,
        codart      listaprecios.codart%TYPE,
        desart      articulos.descri%TYPE,
        codmon      listaprecios.codmon%TYPE,
        simbolo     tmoneda.simbolo%TYPE,
        precio      listaprecios.precio%TYPE,
        incigv      VARCHAR2(10),
        desc01      listaprecios.desc01%TYPE,
        desc02      listaprecios.desc02%TYPE,
        desc03      listaprecios.desc03%TYPE,
        desc04      listaprecios.desc04%TYPE,
        porigv      listaprecios.porigv%TYPE,
        sku         listaprecios.sku%TYPE,
        codadd01    VARCHAR2(10),
        descodadd01 VARCHAR2(100),
        codadd02    VARCHAR2(10),
        descodadd02 VARCHAR2(100)
    );
    TYPE datatable_buscar IS
        TABLE OF datarecord_buscar;
    TYPE datarecord_buscar_stock IS RECORD (
        id_cia      listaprecios.id_cia%TYPE,
        codtit      listaprecios.codtit%TYPE,
        titulo      titulolista.titulo%TYPE,
        tipinv      listaprecios.tipinv%TYPE,
        dtipinv     t_inventario.dtipinv%TYPE,
        codart      listaprecios.codart%TYPE,
        desart      articulos.descri%TYPE,
        codprv      articulos.codprv%TYPE,
        codmon      listaprecios.codmon%TYPE,
        simbolo     tmoneda.simbolo%TYPE,
        precio      listaprecios.precio%TYPE,
        desc01      listaprecios.desc01%TYPE,
        desc02      listaprecios.desc02%TYPE,
        desc03      listaprecios.desc03%TYPE,
        desc04      listaprecios.desc04%TYPE,
        modpre      listaprecios.modpre%TYPE,
        incigv      listaprecios.incigv%TYPE,
        porigv      listaprecios.porigv%TYPE,
        clase01     articulos_clase.clase%TYPE,
        desclase01  clase.descri%TYPE,
        codigo01    articulos_clase.codigo%TYPE,
        descodigo01 clase_codigo.descri%TYPE,
        clase02     articulos_clase.clase%TYPE,
        desclase02  clase.descri%TYPE,
        codigo02    articulos_clase.codigo%TYPE,
        descodigo02 clase_codigo.descri%TYPE,
        sku         listaprecios.sku%TYPE,
        stock       kardex.cantid%TYPE,
        stock98     kardex.cantid%TYPE,
        glosa       VARCHAR2(1000),
        coduni      unidad.coduni%TYPE,
        desuni      unidad.desuni%TYPE,
        almacol     VARCHAR2(1000),
        stockcol    VARCHAR2(1000)
    );
    TYPE datatable_buscar_stock IS
        TABLE OF datarecord_buscar_stock;
    TYPE datarecord_exportar IS RECORD (
        codtit        listaprecios.codtit%TYPE,
        titulo        VARCHAR2(1000),
        tipinv        listaprecios.tipinv%TYPE,
        inventario    t_inventario.dtipinv%TYPE,
        codart        listaprecios.codart%TYPE,
        articulo      articulos.descri%TYPE,
        codpro        clase_codigo.codigo%TYPE,
        procedencia   clase_codigo.descri%TYPE,
        codfam        clase_codigo.codigo%TYPE,
        familia       clase_codigo.descri%TYPE,
        codlin        clase_codigo.codigo%TYPE,
        linea         clase_codigo.descri%TYPE,
        codmar        clase_codigo.codigo%TYPE,
        marca         clase_codigo.descri%TYPE,
        codemp        clase_codigo.codigo%TYPE,
        empaque       clase_codigo.descri%TYPE,
        coduni        articulos.coduni%TYPE,
        codmon        listaprecios.codmon%TYPE,
        precio        listaprecios.precio%TYPE,
        stock         NUMBER(16, 2),
        codalm        NUMBER,
        almacen       VARCHAR2(100),
        codprv        articulos.codprv%TYPE,
        proveedor     cliente.razonc%TYPE,
        fecha_emision VARCHAR2(100)
    );
    TYPE datatable_exportar IS
        TABLE OF datarecord_exportar;
    TYPE datarecord_stock_almacen IS RECORD (
        codalm NUMBER,
        stock  NUMBER(16, 2)
    );
    TYPE datatable_stock_almacen IS
        TABLE OF datarecord_stock_almacen;
    TYPE datarecord_asigna_nuevo IS RECORD (
        id_cia    articulos.id_cia%TYPE,
        vencom    listaprecios.vencom%TYPE,
        codtit    listaprecios.codtit%TYPE,
        codprv    listaprecios.codpro%TYPE,
        codmon    titulolista.codmon%TYPE,
        incigv    titulolista.incigv%TYPE,
        porigv    listaprecios.porigv%TYPE,
        modpre titulolista.modpre%TYPE,
        tipinv    listaprecios.tipinv%TYPE,
        codart    articulos.codart%TYPE,
        desart    articulos.descri%TYPE,
        codund    articulos.coduni%TYPE,
        clase     NUMBER,
        desclase  VARCHAR2(500),
        codigo    clase_codigo.codigo%TYPE,
        descodigo clase_codigo.descri%TYPE
    );
    TYPE datatable_asigna_nuevo IS
        TABLE OF datarecord_asigna_nuevo;
    TYPE datarecord_nueva_lista IS RECORD (
        codart articulos.codart%TYPE,
        desart articulos.descri%TYPE,
        codund articulos.coduni%TYPE,
        codmon listaprecios.codmon%TYPE,
        precio listaprecios.precio%TYPE,
        desc01 listaprecios.desc01%TYPE,
        desc02 listaprecios.desc02%TYPE,
        desc03 listaprecios.desc03%TYPE,
        desc04 listaprecios.desc04%TYPE,
        desinc listaprecios.desinc%TYPE,
        totnet listaprecios.desc04%TYPE,
        modpre listaprecios.modpre%TYPE,
        incigv listaprecios.incigv%TYPE,
        porigv listaprecios.porigv%TYPE,
        desmax listaprecios.desmax%TYPE,
        desmaxmon listaprecios.desmaxmon%TYPE,
        sku    listaprecios.sku%TYPE,
        margen listaprecios.margen%TYPE,
        otros  listaprecios.otros%TYPE,
        flete  listaprecios.flete%TYPE,
        factua listaprecios.factua%TYPE,
        vencom listaprecios.vencom%TYPE,
        codtit listaprecios.codtit%TYPE,
        codprv listaprecios.codpro%TYPE,
        tipinv listaprecios.tipinv%TYPE,
        descom listaprecios.desart%TYPE
--        nuevo VARCHAR2(1 CHAR)
    );
    TYPE datatable_nueva_lista IS
        TABLE OF datarecord_nueva_lista;
    FUNCTION sp_buscar_all (
        pin_id_cia NUMBER,
        pin_tipinv NUMBER,
        pin_codpro VARCHAR2,
        pin_codart VARCHAR2,
        pin_desart VARCHAR2,
        pin_codtit NUMBER,
        pin_offset NUMBER,
        pin_limit  NUMBER
    ) RETURN datatable_buscar_all
        PIPELINED;

    FUNCTION sp_buscar_stock (
        pin_id_cia  NUMBER,
        pin_pdesde  NUMBER,
        pin_phasta  NUMBER,
        pin_codtit  NUMBER,
        pin_tipinv  NUMBER,
        pin_codalm  NUMBER,
        pin_clase01 NUMBER,
        pin_clase02 NUMBER,
        pin_porcol  VARCHAR2
    ) RETURN datatable_buscar_stock
        PIPELINED;

    FUNCTION sp_stock_almacen (
        pin_id_cia  NUMBER,
        pin_tipinv  NUMBER,
        pin_codart  VARCHAR2,
        pin_codalms VARCHAR2,
        pin_pdesde  NUMBER,
        pin_phasta  NUMBER
    ) RETURN datatable_stock_almacen
        PIPELINED;

    FUNCTION sp_exportar (
        pin_id_cia   NUMBER,
        pin_tipinv   NUMBER,
        pin_codprv   VARCHAR2,
        pin_codigo01 VARCHAR2,
        pin_codigo02 VARCHAR2
    ) RETURN datatable_exportar
        PIPELINED;

    FUNCTION sp_asigna (
        pin_id_cia NUMBER,
        pin_tipinv NUMBER,
        pin_vencom NUMBER,
        pin_codtit NUMBER,
        pin_codprv VARCHAR2,
        pin_clase  NUMBER
    ) RETURN datatable_asigna_nuevo
        PIPELINED;

    FUNCTION sp_nueva_lista (
        pin_id_cia NUMBER,
        pin_tipinv NUMBER,
        pin_vencom NUMBER,
        pin_codtit NUMBER,
        pin_codprv VARCHAR2,
        pin_clase  NUMBER
    ) RETURN datatable_nueva_lista
        PIPELINED;

    FUNCTION sp_calcula (
        pin_preuni  NUMBER,
        pin_pordes1 NUMBER,
        pin_pordes2 NUMBER,
        pin_pordes3 NUMBER,
        pin_pordes4 NUMBER
    ) RETURN NUMBER;

END;

/

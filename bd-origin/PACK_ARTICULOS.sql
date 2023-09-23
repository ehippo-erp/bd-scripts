--------------------------------------------------------
--  DDL for Package PACK_ARTICULOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_ARTICULOS" AS
    TYPE datarecord_articulo_ventas IS RECORD (
        tipdoc     documentos_cab.tipdoc%TYPE,
        numint     documentos_cab.numint%TYPE,
        numite     documentos_det.numite%TYPE,
        codmot     documentos_cab.codmot%TYPE,
        desmot     motivos.desmot%TYPE,
        codven     vendedor.codven%TYPE,
        desven     vendedor.desven%TYPE,
        codcpag    c_pago.codpag%TYPE,
        despag     c_pago.despag%TYPE,
        femisi     documentos_cab.femisi%TYPE,
        numdoc     documentos_cab.numdoc%TYPE,
        series     documentos_cab.series%TYPE,
        codcli     documentos_cab.codcli%TYPE,
        razonc     documentos_cab.razonc%TYPE,
        signo      tdoccobranza.signo%TYPE,
        incigv     documentos_cab.incigv%TYPE,
        tipinv     documentos_det.tipinv%TYPE,
        codart     documentos_det.codart%TYPE,
        desart     articulos.descri%TYPE,
        cantid     documentos_det.cantid%TYPE,
        largo      documentos_det.largo%TYPE,
        codalm     documentos_det.codalm%TYPE,
        pordes1    documentos_det.pordes1%TYPE,
        pordes2    documentos_det.pordes2%TYPE,
        pordes3    documentos_det.pordes3%TYPE,
        pordes4    documentos_det.pordes4%TYPE,
        ancho      documentos_det.ancho%TYPE,
        lote       documentos_det.lote%TYPE,
        nrocarrete documentos_det.nrocarrete%TYPE,
        fvenci     documentos_det.fvenci%TYPE,
        preunisol  documentos_det.preuni%TYPE,
        preunidol  documentos_det.preuni%TYPE,
        pretotsol  documentos_det.importe%TYPE,
        pretotdol  documentos_det.importe%TYPE,
        desalm     almacen.descri%TYPE,
        ordcom     documentos_cab.ordcom%TYPE,
        desdoc     documentos.descri%TYPE,
        dessit     situacion.dessit%TYPE
    );
    TYPE datatable_articulo_ventas IS
        TABLE OF datarecord_articulo_ventas;
    TYPE datarecord_articulos IS RECORD (
        id_cia                  articulos.id_cia%TYPE,
        tipinv                  articulos.tipinv%TYPE,
        dtipinv                 t_inventario.dtipinv%TYPE,
        codart                  articulos.codart%TYPE,
        desart                  articulos.descri%TYPE,
        codmar                  articulos.codmar%TYPE,
        codubi                  articulos.codubi%TYPE,
        codprc                  articulos.codprc%TYPE,
        codmod                  articulos.codmod%TYPE,
--        modelo                  articulos.modelo%TYPE,
        codobs                  articulos.codobs%TYPE,
        coduni                  articulos.coduni%TYPE,
--        codl                 articulos.codlin%TYPE,
        codori                  articulos.codori%TYPE,
--        codfam                  articulos.codfam%TYPE,
        codbar                  articulos.codbar%TYPE,
        parara                  articulos.parara%TYPE,
        proart                  articulos.proart%TYPE,
        consto                  articulos.consto%TYPE,
        codprv                  articulos.codprv%TYPE,
        agrupa                  articulos.agrupa%TYPE,
        fmatri                  articulos.fmatri%TYPE,
        wglosa                  articulos.wglosa%TYPE,
        faccon                  articulos.faccon%TYPE,
        tusoesp                 articulos.tusoesp%TYPE,
        tusoing                 articulos.tusoing%TYPE,
        diacmm                  articulos.diacmm%TYPE,
--        cuenta                  articulos.cuenta%TYPE,
        conesp                  articulos.conesp%TYPE,
--        linea                   articulos.linea%TYPE,
        proint                  articulos.proint%TYPE,
        codint                  articulos.codint%TYPE,
        codope                  articulos.codope%TYPE,
--        situac                  articulos.situac%TYPE,
        glosacotizaciondefecto  articulos_glosa.observ%TYPE,
        glosafacturaciondefecto articulos_glosa.observ%TYPE,
        ucreac                  articulos.usuari%TYPE,
        uactua                  articulos.usuari%TYPE,
        factua                  articulos.factua%TYPE,
        fcreac                  articulos.fcreac%TYPE
    );
    TYPE datatable_articulos IS
        TABLE OF datarecord_articulos;
    TYPE datarecord_clase_codigo IS RECORD (
        tipinv    NUMBER,
        codart    VARCHAR2(40),
        clase     NUMBER,
        desclase  VARCHAR2(70),
        codigo    VARCHAR2(20),
        descodigo VARCHAR2(70)
    );
    TYPE datatable_clase_codigo IS
        TABLE OF datarecord_clase_codigo;
    TYPE datarecord_listaprecios_prov IS RECORD (
        codcli   cliente.codcli%TYPE,
        razonc   cliente.razonc%TYPE,
        dident   cliente.dident%TYPE,
        codmon   listaprecios.codmon%TYPE,
        precio   listaprecios.precio%TYPE,
        incigv   listaprecios.incigv%TYPE,
        modpre   listaprecios.modpre%TYPE,
        desc01   listaprecios.desc01%TYPE,
        desc02   listaprecios.desc02%TYPE,
        desc03   listaprecios.desc03%TYPE,
        desc04   listaprecios.desc04%TYPE,
        porigv   listaprecios.porigv%TYPE,
        factua   listaprecios.factua%TYPE,
        codcalid VARCHAR2(250 CHAR),
        dcalidad VARCHAR2(250 CHAR),
        codcolor VARCHAR2(250 CHAR),
        dcolor   VARCHAR2(250 CHAR),
        codund   articulos.coduni%TYPE
    );
    TYPE datatable_listaprecios_prov IS
        TABLE OF datarecord_listaprecios_prov;
    TYPE datarecord_xrecibir IS RECORD (
        numint    documentos_det.numint%TYPE,
        numite    documentos_det.numite%TYPE,
        cantidad  documentos_det.cantid%TYPE,
        entrega   documentos_det.cantid%TYPE,
        saldo     documentos_det.cantid%TYPE,
        series    documentos_cab.series%TYPE,
        numdoc    documentos_cab.numdoc%TYPE,
        femisi    documentos_cab.femisi%TYPE,
        fentreg   documentos_cab.fentreg%TYPE,
        tipmon    documentos_cab.tipmon%TYPE,
        tipcam    documentos_cab.tipcam%TYPE,
        codcli    documentos_cab.codcli%TYPE,
        razonc    documentos_cab.razonc%TYPE,
        ruc       documentos_cab.ruc%TYPE,
        opnumdoc  documentos_cab.opnumdoc%TYPE,
        codund    documentos_det.codund%TYPE,
        preunisol documentos_det.monafe%TYPE,
        preunidol documentos_det.monafe%TYPE,
        pretotsol documentos_det.monafe%TYPE,
        pretotdol documentos_det.monafe%TYPE
    );
    TYPE datatable_xrecibir IS
        TABLE OF datarecord_xrecibir;
    TYPE datarecord_compras IS RECORD (
        numint   kardex.numint%TYPE,
        id       kardex.id%TYPE,
        tipdoc   kardex.tipdoc%TYPE,
        codmot   kardex.codmot%TYPE,
        periodo  kardex.periodo%TYPE,
        femisi   kardex.femisi%TYPE,
        tipinv   kardex.tipinv%TYPE,
        codalm   kardex.codalm%TYPE,
        codart   kardex.codart%TYPE,
        cantid   kardex.cantid%TYPE,
        costot01 kardex.costot01%TYPE,
        tcos01   kardex.costot01%TYPE,
        costot02 kardex.costot02%TYPE,
        tcos02   kardex.costot02%TYPE,
        fobtot01 kardex.fobtot01%TYPE,
        fobtot02 kardex.fobtot02%TYPE,
        razonc   documentos_cab.razonc%TYPE,
        numdoc   documentos_cab.numdoc%TYPE,
        series   documentos_cab.series%TYPE,
        codcli   documentos_cab.codcli%TYPE,
        desmot   motivos.desmot%TYPE,
        desalm   almacen.descri%TYPE,
        descri   articulos.descri%TYPE
    );
    TYPE datatable_compras IS
        TABLE OF datarecord_compras;
    TYPE datarecord_especificaciones IS RECORD (
        codesp  especificaciones.codesp%TYPE,
        descri  especificaciones.descri%TYPE,
        vreal   articulo_especificacion.vreal%TYPE,
        vstrg   articulo_especificacion.vstrg%TYPE,
        vchar   articulo_especificacion.vchar%TYPE,
        vdate   articulo_especificacion.vdate%TYPE,
        vtime   articulo_especificacion.vtime%TYPE,
        ventero articulo_especificacion.ventero%TYPE
    );
    TYPE datatable_especificaciones IS
        TABLE OF datarecord_especificaciones;
    TYPE datarecord_listaprecios IS RECORD (
        vencom    listaprecios.vencom%TYPE,
        codtit    listaprecios.codtit%TYPE,
        codpro    listaprecios.codpro%TYPE,
        tipinv    listaprecios.tipinv%TYPE,
        codart    listaprecios.codart%TYPE,
        codmon    listaprecios.codmon%TYPE,
        precio    listaprecios.precio%TYPE,
        incigv    listaprecios.incigv%TYPE,
        modpre    listaprecios.modpre%TYPE,
        desc01    listaprecios.desc01%TYPE,
        desc02    listaprecios.desc02%TYPE,
        desc03    listaprecios.desc03%TYPE,
        desc04    listaprecios.desc04%TYPE,
        fcreac    listaprecios.fcreac%TYPE,
        factua    listaprecios.factua%TYPE,
        usuari    listaprecios.usuari%TYPE,
        porigv    listaprecios.porigv%TYPE,
        sku       listaprecios.sku%TYPE,
        desartcom listaprecios.desart%TYPE,
        desmax    listaprecios.desmax%TYPE,
        margen    listaprecios.margen%TYPE,
        otros     listaprecios.otros%TYPE,
        flete     listaprecios.flete%TYPE,
        desmaxmon listaprecios.desmaxmon%TYPE,
        desinc    listaprecios.desinc%TYPE,
        destit    titulolista.titulo%TYPE,
        simbolo   tmoneda.simbolo%TYPE
    );
    TYPE datatable_listaprecios IS
        TABLE OF datarecord_listaprecios;
    TYPE datarecord_cotizaciones IS RECORD (
        tipdoc    documentos_cab.tipdoc%TYPE,
        numint    documentos_cab.numint%TYPE,
        numite    documentos_det.numite%TYPE,
        codmot    documentos_cab.codmot%TYPE,
        femisi    documentos_cab.femisi%TYPE,
        numdoc    documentos_cab.numdoc%TYPE,
        series    documentos_cab.series%TYPE,
        codcli    documentos_cab.codcli%TYPE,
        razonc    documentos_cab.razonc%TYPE,
        incigv    documentos_cab.incigv%TYPE,
        tipinv    documentos_det.tipinv%TYPE,
        codart    documentos_det.codart%TYPE,
        cantid    documentos_det.cantid%TYPE,
        codalm    documentos_det.codalm%TYPE,
        preunisol documentos_det.preuni%TYPE,
        preunidol documentos_det.preuni%TYPE,
        pretotsol documentos_det.importe%TYPE,
        pretotdol documentos_det.importe%TYPE,
        pordes1   documentos_det.pordes1%TYPE,
        pordes2   documentos_det.pordes2%TYPE,
        pordes3   documentos_det.pordes3%TYPE,
        pordes4   documentos_det.pordes4%TYPE,
        desalm    almacen.descri%TYPE,
        ordcom    documentos_cab.ordcom%TYPE,
        desdoc    documentos.descri%TYPE,
        dessit    situacion.dessit%TYPE,
        largo     documentos_det.largo%TYPE
    );
    TYPE datatable_cotizaciones IS
        TABLE OF datarecord_cotizaciones;
    FUNCTION sp_articulo_ventas (
        pin_id_cia NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE,
        pin_tipinv NUMBER,
        pin_codart VARCHAR2,
        pin_codsuc NUMBER,
        pin_codcli VARCHAR2,
        pin_limit  NUMBER,
        pin_offset NUMBER
    ) RETURN datatable_articulo_ventas
        PIPELINED;

    FUNCTION sp_buscar_clase_codigo (
        pin_id_cia NUMBER,
        pin_tipinv NUMBER,
        pin_codart VARCHAR2,
        pin_clase  NUMBER
    ) RETURN datatable_clase_codigo
        PIPELINED;

    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_tipinv NUMBER,
        pin_codart VARCHAR2
    ) RETURN datatable_articulos
        PIPELINED;

    FUNCTION sp_xrecibir (
        pin_id_cia INTEGER,
        pin_tipinv INTEGER,
        pin_codart VARCHAR2,
        pin_codalm INTEGER
    ) RETURN datatable_xrecibir
        PIPELINED;

    FUNCTION sp_listaprecios_prov (
        pin_id_cia INTEGER,
        pin_tipinv INTEGER,
        pin_codart VARCHAR2
    ) RETURN datatable_listaprecios_prov
        PIPELINED;

    FUNCTION sp_compras (
        pin_id_cia  NUMBER,
        pin_tipinv  NUMBER,
        pin_codart  VARCHAR2,
        pin_codsuc  NUMBER,
        pin_codprov VARCHAR2,
        pin_limit   NUMBER,
        pin_offset  NUMBER
    ) RETURN datatable_compras
        PIPELINED;

    FUNCTION sp_especificaciones (
        pin_id_cia INTEGER,
        pin_tipinv INTEGER,
        pin_codart VARCHAR2
    ) RETURN datatable_especificaciones
        PIPELINED;

    FUNCTION sp_listaprecios (
        pin_id_cia INTEGER,
        pin_tipinv INTEGER,
        pin_codart VARCHAR2
    ) RETURN datatable_listaprecios
        PIPELINED;

    FUNCTION sp_cotizaciones (
        pin_id_cia NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE,
        pin_tipinv NUMBER,
        pin_codart VARCHAR2,
        pin_codsuc NUMBER,
        pin_codcli VARCHAR2,
        pin_situac VARCHAR2,
        pin_limit  NUMBER,
        pin_offset NUMBER
    ) RETURN datatable_cotizaciones
        PIPELINED;

END;

/

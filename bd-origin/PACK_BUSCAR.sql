--------------------------------------------------------
--  DDL for Package PACK_BUSCAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_BUSCAR" AS
    -- Se usa este DATARECORD para sp_buscar_comprobantes
    TYPE datarecord IS RECORD (
        id_cia      documentos_cab.id_cia%TYPE,
        numint      documentos_cab.numint%TYPE,
        tipdoc      documentos_cab.tipdoc%TYPE,
        dtipdoc     VARCHAR2(500),
        series      documentos_cab.series%TYPE,
        numdoc      documentos_cab.numdoc%TYPE,
        femisi      DATE,
        lugemi      NUMBER,
        situac      documentos_cab.situac%TYPE,
        codmot      NUMBER,
        codcli      documentos_cab.codcli%TYPE,
        tident      VARCHAR2(500),
        dident      VARCHAR2(500),
        razonc      VARCHAR2(500),
        codcpag     NUMBER,
        desccpag    VARCHAR2(500),
        codven      NUMBER,
        desven      VARCHAR2(500),
        comisi      NUMBER(16, 2),
        destin      NUMBER,
        desesp      NUMBER(16, 2),
        monafe      NUMBER(16, 2),
        monina      NUMBER(16, 2),
        porigv      NUMBER(16, 2),
        monigv      NUMBER(16, 2),
        preven      NUMBER(16, 2),
        tipmon      VARCHAR2(500),
        tipcam      NUMBER(16, 2),
        observ      documentos_cab.observ%TYPE,
        ordcom      VARCHAR2(500),
        numped      VARCHAR2(500),
        desmot      motivos.desmot%TYPE,
        comentario  VARCHAR2(500),
        numdue      VARCHAR2(500),
        fentreg     DATE,
        codsuc      NUMBER,
        totcan      NUMBER(16, 2),
        ordcomni    NUMBER,
        fecter      DATE,
        estadofe    VARCHAR2(500),
        situacresfe VARCHAR2(500),
        situacfe    NUMBER,
        situacdesc  VARCHAR2(200),
        emitidopor  VARCHAR2(200),
        ucreac      VARCHAR2(500),
        usuari      VARCHAR2(500),
        fcreac      DATE,
        factua      DATE
    );
    TYPE datatable IS
        TABLE OF datarecord;

    -- Se usa este DATARECORD para sp_guias_recepcion
    TYPE datarecord1 IS RECORD (
        id_cia        NUMBER,
        numint        NUMBER,
        tipdoc        NUMBER,
        dtipdoc       VARCHAR2(500),
        series        VARCHAR2(500),
        numdoc        NUMBER,
        femisi        DATE,
        lugemi        NUMBER,
        situac        VARCHAR2(500),
        situacdesc    VARCHAR2(500),
        id            VARCHAR2(500),
        codmot        NUMBER,
        motdoc        NUMBER,
        codalm        NUMBER,
        almdes        NUMBER,
        codcli        VARCHAR2(500),
        tident        VARCHAR2(500),
        dident        VARCHAR2(500),
        ruc           VARCHAR2(500),
        razonsocial   VARCHAR2(500),
        direccion     VARCHAR2(500),
        codenv        NUMBER,
        codcpag       NUMBER,
        desccpag      VARCHAR2(500),
        codtra        NUMBER,
        codven        NUMBER,
        desven        VARCHAR2(500),
        comisi        NUMBER(16, 2),
        incigv        VARCHAR2(500),
        destin        NUMBER,
        importebruto  NUMBER(16, 2),
        descuento     NUMBER(16, 2),
        desesp        NUMBER(16, 2),
        monafe        NUMBER(16, 2),
        monina        NUMBER(16, 2),
        porigv        NUMBER(16, 2),
        monigv        NUMBER(16, 2),
        preven        NUMBER(16, 2),
        costo         NUMBER(16, 2),
        moneda        VARCHAR2(500),
        tipcam        NUMBER(16, 2),
        observacion   VARCHAR2(500),
        atenci        VARCHAR2(500),
        valide        VARCHAR2(500),
        plaent        VARCHAR2(500),
        ordcom        VARCHAR2(500),
        referencia    VARCHAR2(500),
        gasvin        NUMBER(16, 2),
        seguro        NUMBER(16, 2),
        flete         NUMBER(16, 2),
        desfle        VARCHAR2(500),
        desexp        NUMBER(16, 2),
        gasadu        NUMBER(16, 2),
        pesbru        NUMBER(16, 2),
        pesnet        NUMBER(16, 2),
        bultos        NUMBER,
        comentario    VARCHAR2(500),
        marcas        VARCHAR2(500),
        numdue        VARCHAR2(500),
        fnumdue       DATE,
        fembarq       DATE,
        fentreg       DATE,
        valfob        NUMBER(16, 2),
        guipro        VARCHAR2(500),
        fguipro       DATE,
        facpro        VARCHAR2(500),
        ffacpro       DATE,
        cargo         VARCHAR2(500),
        codsuc        NUMBER,
        acuenta       NUMBER(16, 2),
        swacti        VARCHAR2(500),
        codarea       NUMBER,
        coduso        NUMBER,
        opnumdoc      NUMBER,
        opcargo       VARCHAR2(500),
        opnumite      NUMBER,
        opcodart      VARCHAR2(500),
        optipinv      NUMBER,
        totcan        NUMBER(16, 2),
        fordcom       DATE,
        ordcomni      NUMBER,
        motvarios     NUMBER,
        horing        DATE,
        fecter        DATE,
        horter        DATE,
        codtec        NUMBER,
        guiarefe      VARCHAR2(500),
        desenv        VARCHAR2(500),
        codaux        VARCHAR2(500),
        codetapauso   NUMBER,
        codsec        NUMBER,
        numvale       NUMBER,
        fecvale       DATE,
        swtrans       NUMBER,
        desseg        VARCHAR2(500),
        desgasa       VARCHAR2(500),
        desnetx       VARCHAR2(500),
        despreven     VARCHAR2(500),
        codcob        NUMBER,
        codveh        NUMBER,
        codpunpar     NUMBER,
        ubigeopar     VARCHAR2(500),
        direccpar     VARCHAR2(500),
        estadofe      VARCHAR2(500),
        situacresfe   VARCHAR2(500),
        situacfe      NUMBER,
        coduser       VARCHAR2(60),
        usuario       VARCHAR2(70),
        desmot        VARCHAR2(60),
        condicionpago VARCHAR2(120),
        ucreac        VARCHAR2(500),
        usuari        VARCHAR2(500),
        fcreac        DATE,
        factua        DATE
    );
    TYPE datatable1 IS
        TABLE OF datarecord1;

    -- Se usa este DATARECORD para sp_buscar_cotizaciones
    TYPE datarecord2 IS RECORD (
        id_cia        NUMBER,
        numint        NUMBER,
        tipdoc        NUMBER,
        series        VARCHAR2(500),
        numdoc        NUMBER,
        tident        VARCHAR2(500),
        ruc           VARCHAR2(500),
        codcli        VARCHAR2(500),
        razonsocial   VARCHAR2(500),
        direccion     VARCHAR2(500),
        fentreg       DATE,
        femisi        DATE,
        lugemi        NUMBER,
        situac        VARCHAR2(500),
        situacnombre  VARCHAR2(500),
        situacdes     VARCHAR2(500),
        id            VARCHAR2(500),
        codmot        NUMBER,
        desmot        motivos.desmot%TYPE,
        codven        NUMBER,
        codsuc        NUMBER,
        moneda        VARCHAR2(5),
        tipcam        NUMBER(16, 2),
        coc_numint    NUMBER,
        coc_fecha     DATE,
        cocnumero     VARCHAR2(25),
        coccontacto   VARCHAR2(50),
        condicionpago VARCHAR2(120),
        desven        VARCHAR2(500),
        codcpag       NUMBER,
        nombres       VARCHAR2(70),
        incigv        VARCHAR2(500),
        porigv        NUMBER(16, 2),
        referencia    VARCHAR2(500),
        observacion   documentos_cab.observ%TYPE,
        monafe        NUMBER(16, 2),
        monina        NUMBER(16, 2),
        monigv        NUMBER(16, 2),
        preven        NUMBER(16, 2),
        monisc        NUMBER(16, 2),
        importebruto  NUMBER(16, 2),
        importe       NUMBER(16, 2),
        countadj      NUMBER(38, 0),
        ucreac        VARCHAR2(500),
        usuari        VARCHAR2(500),
        fcreac        DATE,
        factua        DATE
    );
    TYPE datatable2 IS
        TABLE OF datarecord2;

    -- Se usa este DATARECORD para sp_buscar_pedidos
    TYPE datarecord3 IS RECORD (
        id_cia        NUMBER,
        numint        NUMBER,
        tipdoc        NUMBER,
        series        VARCHAR2(500),
        numdoc        NUMBER,
        telefono      VARCHAR2(50),
        tident        VARCHAR2(500),
        ruc           VARCHAR2(500),
        codcli        VARCHAR2(500),
        razonsocial   VARCHAR2(500),
        direccion     VARCHAR2(500),
        fentreg       DATE,
        femisi        DATE,
        lugemi        NUMBER,
        situac        VARCHAR2(500),
        situacnombre  VARCHAR2(500),
        id            VARCHAR2(500),
        codmot        NUMBER,
        desmot        motivos.desmot%TYPE,
        codven        NUMBER,
        codsuc        NUMBER,
        moneda        VARCHAR2(5),
        tipcam        NUMBER(16, 2),
        condicionpago VARCHAR2(50),
        desven        VARCHAR2(60),
        codcpag       NUMBER,
        nombres       VARCHAR2(70),
        incigv        VARCHAR2(500),
        porigv        NUMBER(16, 2),
        referencia    VARCHAR2(500),
        monafe        NUMBER(16, 2),
        monina        NUMBER(16, 2),
        monigv        NUMBER(16, 2),
        monisc        NUMBER(16, 2),
        preven        NUMBER(16, 2),
        importebruto  NUMBER(16, 2),
        importe       NUMBER(16, 2),
        countadj      NUMBER(38, 0),
        situacda      VARCHAR2(500),
        ucreac        VARCHAR2(500),
        usuari        VARCHAR2(500),
        fcreac        DATE,
        factua        DATE
    );
    TYPE datatable3 IS
        TABLE OF datarecord3;

    -- Se usa este DATARECORD para sp_buscar_guiasremision
    TYPE datarecord_guia_remision IS RECORD (
        id_cia        NUMBER,
        tipdoc        NUMBER(38, 0),
        numint        NUMBER,
        series        VARCHAR2(500),
        numdoc        NUMBER,
        tident        VARCHAR2(500),
        femisi        DATE,
        comisi        NUMBER(16, 2),
        codven        NUMBER,
        lugemi        NUMBER,
        situac        VARCHAR2(500),
        situacfe      NUMBER(38, 0),
        destin        NUMBER(38, 0),
        estadofe      VARCHAR2(15),
        situacresfe   VARCHAR2(20),
        tipcam        NUMBER(16, 2),
        tipmon        VARCHAR2(5),
        codcpag       NUMBER,
        numdue        VARCHAR2(25),
        porigv        NUMBER(16, 2),
        fecter        DATE,
        fentreg       DATE,
        razonc        VARCHAR2(500),
        docelec       VARCHAR2(10),
        abrevi        VARCHAR2(10),
        totcan        NUMBER(16, 2),
        ordcom        VARCHAR2(500),
        permis        VARCHAR(30),
        dtipdoc       VARCHAR(50),
        countadj      NUMBER(38, 0),
        codsuc        NUMBER,
        codcli        VARCHAR2(500),
        ordcomni      NUMBER(38, 0),
        desven        VARCHAR2(60),
        monafe        NUMBER(16, 2),
        monina        NUMBER(16, 2),
        monigv        NUMBER(16, 2),
        preven        NUMBER(16, 2),
        codmot        NUMBER,
        referencia    VARCHAR2(500),
        observacion   documentos_cab.observ%TYPE,
        comentario    VARCHAR2(500),
        desesp        NUMBER(16, 2),
        countadj2     NUMBER(38, 0),
        desmot        VARCHAR2(50),
        emitidopor    VARCHAR2(70),
        anuladopor    VARCHAR2(50),
        situacdesc    VARCHAR2(50),
        condicionpago VARCHAR2(50),
        incoterm      VARCHAR2(50),
        ucreac        VARCHAR2(500),
        usuari        VARCHAR2(500),
        fcreac        DATE,
        factua        DATE
    );
    TYPE datatable_guia_remision IS
        TABLE OF datarecord_guia_remision;

    -- -- Se usa este DATARECORD para sp_buscar_req_compra
    TYPE datarecord5 IS RECORD (
        id_cia        NUMBER,
        numint        NUMBER,
        tipdoc        NUMBER,
        series        VARCHAR2(500),
        numdoc        NUMBER,
        tident        VARCHAR2(500),
        ruc           VARCHAR2(500),
        codcli        VARCHAR2(500),
        razonsocial   VARCHAR2(500),
        direccion     VARCHAR2(500),
        fentreg       DATE,
        femisi        DATE,
        lugemi        NUMBER,
        situac        VARCHAR2(500),
        situacnombre  VARCHAR2(50),
        id            VARCHAR2(500),
        codmot        NUMBER,
        codven        NUMBER,--        
        codsuc        NUMBER,
        moneda        VARCHAR2(5),
        tipcam        NUMBER(16, 2),
        codera        NUMBER(38, 0),
        destin        NUMBER(38, 0),
        coc_numint    NUMBER,
        coc_fecha     DATE,
        cocnumero     VARCHAR2(25),
        coccontacto   VARCHAR2(50),
        dcccodcont    NUMBER(38, 0),
        dccatenci     VARCHAR2(100),
        dccemail      VARCHAR2(100),
        condicionpago VARCHAR2(50),
        desven        VARCHAR2(60),
        codcpag       NUMBER,
        nombres       VARCHAR2(70),
        incigv        VARCHAR2(500),
        porigv        NUMBER(16, 2),
        referencia    VARCHAR2(500),
        observacion   documentos_cab.observ%TYPE,
        comentario    VARCHAR2(500),
        monafe        NUMBER(16, 2),
        monina        NUMBER(16, 2),
        monigv        NUMBER(16, 2),
        importe       NUMBER(16, 2),
        countadj      NUMBER(38, 0),
        importebruto  NUMBER(16, 2),
        preven        NUMBER(16, 2),
        codarea       NUMBER,
        ucreac        VARCHAR2(500),
        usuari        VARCHAR2(500),
        fcreac        DATE,
        factua        DATE
    );
    TYPE datatable5 IS
        TABLE OF datarecord5;

    -- Se usa este DATARECORD para sp_buscar_orden_compra
    TYPE datarecord6 IS RECORD (
        id_cia        NUMBER,
        numint        NUMBER,
        tipdoc        NUMBER,
        series        VARCHAR2(500),
        numdoc        NUMBER,
        tident        VARCHAR2(500),
        ruc           VARCHAR2(500),
        codcli        VARCHAR2(500),
        razonsocial   VARCHAR2(500),
        direccion     VARCHAR2(500),
        fentreg       DATE,
        femisi        DATE,--        
        lugemi        NUMBER,--        
        situac        VARCHAR2(500),
        situacnombre  VARCHAR2(50),
        id            VARCHAR2(500),
        codmot        NUMBER,
        codven        NUMBER,--        
        codsuc        NUMBER,
        moneda        VARCHAR2(5),
        tipcam        NUMBER(16, 2),
        codarea       NUMBER(38, 0),
        destin        NUMBER(38, 0),
        desdestin     VARCHAR2(15),
        desmot        motivos.desmot%TYPE,
        coc_numint    NUMBER,
        coc_fecha     DATE,
        cocnumero     VARCHAR2(25),
        coccontacto   VARCHAR2(50),
        dcccodcont    NUMBER(38, 0),
        dccatenci     VARCHAR2(100),
        dccemail      VARCHAR2(100),
        dccplaent     VARCHAR2(50),--
        dccvalide     VARCHAR2(50),--
        condicionpago VARCHAR2(50),
        desven        VARCHAR2(60),
        codcpag       NUMBER,
        nombres       VARCHAR2(70),
        incigv        VARCHAR2(500),
        porigv        NUMBER(16, 2),
        referencia    VARCHAR2(500),
        observacion   documentos_cab.observ%TYPE,
        comentario    VARCHAR2(500),
        monafe        NUMBER(16, 2),
        monina        NUMBER(16, 2),
        monigv        NUMBER(16, 2),
        preven        NUMBER(16, 2),--             
        importebruto  NUMBER(16, 2),
        importe       NUMBER(16, 2),--
        facpro        VARCHAR2(20),--
        ffacpro       DATE,--
        numdue        VARCHAR2(25),--
        dnumint       NUMBER,
        dnumite       NUMBER,
        dtipinv       NUMBER,
        dcodart       VARCHAR2(40),
        ddescri       VARCHAR2(100),
        dpreuni       NUMBER(16, 5),
        dpordes1      NUMBER(16, 5),
        dpordes2      NUMBER(16, 5),
        dpordes3      NUMBER(16, 5),
        dpordes4      NUMBER(16, 5),
        dimporte      NUMBER(16, 5),
        ddobserv      VARCHAR2(3000),
        dcantid       NUMBER(16, 5),
        dcodadd01     VARCHAR2(10),
        cc1descri     VARCHAR2(60),
        dcodadd02     VARCHAR2(10),
        cc2descri     VARCHAR2(60),
        detiqueta     VARCHAR(100),
        dpositi       NUMBER,
        dcodund       VARCHAR2(3),
        dcodalm       NUMBER,
        countadj      NUMBER(38, 0),
        dvreal        NUMBER(9, 2),
        situacda      VARCHAR2(15),
        ucreac        VARCHAR2(500),
        usuari        VARCHAR2(500),
        fcreac        DATE,
        factua        DATE
    );
    TYPE datatable6 IS
        TABLE OF datarecord6;

    -- Se usa este DATARECORD para sp_documentos_importacion
    TYPE datarecord7 IS RECORD (
        id_cia        NUMBER,
        numint        NUMBER,
        tipdoc        NUMBER,
        series        VARCHAR2(500),
        numdoc        NUMBER,
        tident        VARCHAR2(500),
        ruc           VARCHAR2(500),
        codcli        VARCHAR2(500),
        razonsocial   VARCHAR2(500),
        direccion     VARCHAR2(500),
        fentreg       DATE,
        femisi        DATE,
        lugemi        NUMBER,
        situac        VARCHAR2(500),
        situacnombre  VARCHAR2(50),
        id            VARCHAR2(500),
        codmot        NUMBER,
        codven        NUMBER,
        codsuc        NUMBER,
        moneda        VARCHAR2(5),
        tipcam        NUMBER(16, 2),
        coc_numint    NUMBER,
        coc_fecha     DATE,
        cocnumero     VARCHAR2(25),
        coccontacto   VARCHAR2(50),
        condicionpago VARCHAR2(50),
        desven        VARCHAR2(60),
        codcpag       NUMBER,
        nombres       VARCHAR2(70),
        incigv        VARCHAR2(500),
        porigv        NUMBER(16, 2),
        referencia    VARCHAR2(500),
        observacion   documentos_cab.observ%TYPE,
        monafe        NUMBER(16, 2),
        monina        NUMBER(16, 2),
        monigv        NUMBER(16, 2),
        preven        NUMBER(16, 2),
        countadj      NUMBER(38, 0),
        importe       NUMBER(16, 2),
        ucreac        VARCHAR2(500),
        usuari        VARCHAR2(500),
        fcreac        DATE,
        factua        DATE
    );
    TYPE datatable7 IS
        TABLE OF datarecord7;

    -- Se usa este DATARECORD para sp_buscar_guias_internas
    TYPE datarecord_guias_internas IS RECORD (
        id_cia        NUMBER,
        numint        NUMBER,
        tipdoc        NUMBER,
        series        documentos_cab.series%TYPE,
        numdoc        documentos_cab.numdoc%TYPE,
        tident        documentos_cab.tident%TYPE,
        ruc           documentos_cab.ruc%TYPE,
        codcli        documentos_cab.codcli%TYPE,
        razonsocial   documentos_cab.razonc%TYPE,
        direccion     documentos_cab.direc1%TYPE,
        fentreg       DATE,
        femisi        DATE,
        lugemi        documentos_cab.lugemi%TYPE,
        situac        documentos_cab.situac%TYPE,
        situacnombre  situacion.dessit%TYPE,
        id            documentos_cab.id%TYPE,
        codmot        documentos_cab.codmot%TYPE,
        desmot        motivos.desmot%TYPE,
        codven        NUMBER,
        codsuc        NUMBER,
        moneda        documentos_cab.tipmon%TYPE,
        monisc        documentos_cab.monisc%TYPE,
        tipcam        documentos_cab.tipcam%TYPE,
        coc_numint    NUMBER,
        coc_fecha     DATE,
        cocnumero     VARCHAR2(250),
        coccontacto   VARCHAR2(500),
        condicionpago VARCHAR2(500),
        desven        vendedor.desven%TYPE,
        codcpag       documentos_cab.codcpag%TYPE,
        nombres       VARCHAR2(100),
        incigv        VARCHAR2(500),
        porigv        documentos_cab.porigv%TYPE,
        referencia    documentos_cab.numped%TYPE,
        comentario    documentos_cab.observ%TYPE,
        observacion   documentos_cab.presen%TYPE,
        monafe        documentos_cab.monafe%TYPE,
        monina        documentos_cab.monina%TYPE,
        monigv        documentos_cab.monigv%TYPE,
        preven        documentos_cab.preven%TYPE,
        importebruto  documentos_cab.totbru%TYPE,
        importe       documentos_cab.preven%TYPE,
        situacimp     VARCHAR2(20),
        dessituacimp  VARCHAR2(20),
        flete         documentos_cab.flete%TYPE,
        countadj      documentos_cab.countadj%TYPE,
        seguro        documentos_cab.seguro%TYPE,
        gremision     documentos_cab.guipro%TYPE,
        factura       documentos_cab.facpro%TYPE,
        fecgremision  documentos_cab.fguipro%TYPE,
        fecfactura    documentos_cab.ffacpro%TYPE,
        ucreac        VARCHAR2(500),
        usuari        VARCHAR2(500),
        fcreac        DATE,
        factua        DATE
    );
    TYPE datatable_guias_internas IS
        TABLE OF datarecord_guias_internas;

    -- Se usa este DATARECORD para sp_buscar_orden_compra_importacion
    TYPE datarecord9 IS RECORD (
        id_cia        NUMBER,
        numint        NUMBER,
        tipdoc        NUMBER,
        series        VARCHAR2(500),
        numdoc        NUMBER,
        tident        VARCHAR2(500),
        ruc           VARCHAR2(500),
        codcli        VARCHAR2(500),
        razonsocial   VARCHAR2(500),
        direccion     VARCHAR2(500),
        fentreg       DATE,
        femisi        DATE,--        
        lugemi        NUMBER,--        
        situac        VARCHAR2(500),
        situacnombre  VARCHAR2(50),
        id            VARCHAR2(500),
        codmot        NUMBER,
        codven        NUMBER,--        
        codsuc        NUMBER,
        moneda        VARCHAR2(5),
        tipcam        NUMBER(16, 2),
        codarea       NUMBER(38, 0),
        destin        NUMBER(38, 0),
        desdestin     VARCHAR2(15),
        desmot        motivos.desmot%TYPE,
        coc_numint    NUMBER,
        coc_fecha     DATE,
        cocnumero     VARCHAR2(25),
        coccontacto   VARCHAR2(50),
        dcccodcont    NUMBER(38, 0),
        dccatenci     VARCHAR2(100),
        dccemail      VARCHAR2(100),
        dccplaent     VARCHAR2(50),--
        dccvalide     VARCHAR2(50),--
        condicionpago VARCHAR2(50),
        desven        VARCHAR2(60),
        codcpag       NUMBER,
        nombres       VARCHAR2(70),
        incigv        VARCHAR2(500),
        porigv        NUMBER(16, 2),
        referencia    VARCHAR2(500),
        observacion   documentos_cab.observ%TYPE,
        comentario    VARCHAR2(500),
        monafe        NUMBER(16, 2),
        monina        NUMBER(16, 2),
        monigv        NUMBER(16, 2),
        preven        NUMBER(16, 2),--             
        importebruto  NUMBER(16, 2),
        importe       NUMBER(16, 2),--
        facpro        VARCHAR2(20),--
        ffacpro       DATE,--
        numdue        VARCHAR2(25),--
        dnumint       NUMBER,
        dnumite       NUMBER,
        dtipinv       NUMBER,
        dcodart       VARCHAR2(40),
        ddescri       VARCHAR2(100),
        dpreuni       NUMBER(16, 5),
        dpordes1      NUMBER(16, 5),
        dpordes2      NUMBER(16, 5),
        dpordes3      NUMBER(16, 5),
        dpordes4      NUMBER(16, 5),
        dimporte      NUMBER(16, 5),
        ddobserv      VARCHAR2(3000),
        dcantid       NUMBER(16, 5),
        dcodadd01     VARCHAR2(10),
        cc1descri     VARCHAR2(60),
        dcodadd02     VARCHAR2(10),
        cc2descri     VARCHAR2(60),
        detiqueta     VARCHAR(100),
        dpositi       NUMBER,
        dcodund       VARCHAR2(3),
        dcodalm       NUMBER,
        countadj      NUMBER(38, 0),
        dvreal        NUMBER(9, 2),
        situacda      VARCHAR2(15),
        flete         documentos_cab.flete%TYPE,
        seguro        documentos_cab.seguro%TYPE,
        ucreac        VARCHAR2(500),
        usuari        VARCHAR2(500),
        fcreac        DATE,
        factua        DATE
    );
    TYPE datatable9 IS
        TABLE OF datarecord9;

    -- Se usa este DATARECORD para sp_buscar_orden_produccion
    TYPE datarecord_buscar_orden_produccion IS RECORD (
        id_cia        NUMBER,
        numint        NUMBER,
        tipdoc        NUMBER,
        series        VARCHAR2(500),
        numdoc        NUMBER,
        tident        VARCHAR2(500),
        ruc           VARCHAR2(500),
        codcli        VARCHAR2(500),
        razonsocial   VARCHAR2(500),
        direccion     VARCHAR2(500),
        telefono      VARCHAR2(50),
        fentreg       DATE,
        femisi        DATE,
        lugemi        NUMBER,
        situac        VARCHAR2(500),
        situacnombre  VARCHAR2(500),
        id            VARCHAR2(500),
        codmot        NUMBER,
        desmot        VARCHAR2(500),
        codven        NUMBER,
        codsuc        NUMBER,
        moneda        VARCHAR2(5),
        tipcam        NUMBER(16, 2),
        condicionpago VARCHAR2(50),
        desven        VARCHAR2(60),
        codcpag       NUMBER,
        nombres       VARCHAR2(70),
        incigv        VARCHAR2(500),
        porigv        NUMBER(16, 2),
        referencia    VARCHAR2(500),
        monafe        NUMBER(16, 2),
        monina        NUMBER(16, 2),
        monigv        NUMBER(16, 2),
        monisc        NUMBER(16, 2),
        preven        NUMBER(16, 2),
        importebruto  NUMBER(16, 2),
        importe       NUMBER(16, 2),
        countadj      NUMBER(38, 0),
        situacda      VARCHAR2(500),
        ucreac        VARCHAR2(500),
        usuari        VARCHAR2(500),
        fcreac        DATE,
        factua        DATE
    );
    TYPE datatable_buscar_orden_produccion IS
        TABLE OF datarecord_buscar_orden_produccion;
    -- INICIO BUSQUEDA DE  COMPROBANTES

    FUNCTION sp_buscar_comprobantes (
        pin_id_cia      IN NUMBER,
        pin_fdesde      IN DATE,
        pin_fhasta      IN DATE,
        pin_codcli      IN VARCHAR2,
        pin_situac      IN VARCHAR2,
        pin_tipdoc      IN NUMBER,
        pin_codmot      IN NUMBER,
        pin_lugemi      IN NUMBER,
        pin_destino     IN NUMBER,
        pin_codven      IN NUMBER,
        pin_codsuc      IN NUMBER,
        pin_estadosunat IN NUMBER,
        pin_offset      IN NUMBER,
        pin_limit       IN NUMBER
    ) RETURN datatable
        PIPELINED;
   -- FIN BUSQUEDA DE COMPROBANTES     

    FUNCTION sp_buscar_guias_recepcion (
        pin_id_cia IN NUMBER,
        pin_fdesde IN DATE,
        pin_fhasta IN DATE,
        pin_codcli IN VARCHAR2,
        pin_situac IN VARCHAR2,
        pin_codmot IN NUMBER,
        pin_codven IN NUMBER,
        pin_codsuc IN NUMBER,
        pin_codpag IN NUMBER,
        pin_offset IN NUMBER,
        pin_limit  IN NUMBER
    ) RETURN datatable1
        PIPELINED;
   -- FIN BUSQUEDA GUIAS_RECEPCION 

--SELECT
--    *
--FROM
--    pack_buscar.sp_buscar_cotizaciones(56, TO_DATE('01/01/22', 'DD/MM/YY'), TO_DATE('01/01/24', 'DD/MM/YY'),
--                                  NULL, -1, -1, NULL, -1,
--                                  -1, -1);

    FUNCTION sp_buscar_cotizaciones (
        pin_id_cia IN NUMBER,
        pin_fdesde IN DATE,
        pin_fhasta IN DATE,
        pin_codcli IN VARCHAR2,
        pin_codven IN NUMBER,
        pin_codsuc IN NUMBER,
        pin_situac IN VARCHAR2,
        pin_lugemi IN NUMBER,
        pin_limit  IN NUMBER,
        pin_offset IN NUMBER
    ) RETURN datatable2
        PIPELINED;
    -- FIN BUSQUEDA DE COTIZACIONES


--SELECT
--    *
--FROM
--    pack_buscar.sp_buscar_pedidos(56, TO_DATE('01/01/22', 'DD/MM/YY'), TO_DATE('01/01/24', 'DD/MM/YY'),
--                                     -1, -1, -1,NULL, NULL,
--                                  -1, -1);

    FUNCTION sp_buscar_pedidos (
        pin_id_cia IN NUMBER,
        pin_fdesde IN DATE,
        pin_fhasta IN DATE,
        pin_codven IN NUMBER,
        pin_codmot IN NUMBER,
        pin_codsuc IN NUMBER,
        pin_codcli IN VARCHAR2,
        pin_situac IN VARCHAR2,
        pin_limit  IN NUMBER,
        pin_offset IN NUMBER
    ) RETURN datatable3
        PIPELINED;

    FUNCTION sp_buscar_orden_servicios (
        pin_id_cia IN NUMBER,
        pin_fdesde IN DATE,
        pin_fhasta IN DATE,
        pin_codven IN NUMBER,
        pin_codmot IN NUMBER,
        pin_codsuc IN NUMBER,
        pin_codcli IN VARCHAR2,
        pin_situac IN VARCHAR2,
        pin_limit  IN NUMBER,
        pin_offset IN NUMBER
    ) RETURN datatable3
        PIPELINED;

    FUNCTION sp_buscar_orden_devolucion (
        pin_id_cia IN NUMBER,
        pin_fdesde IN DATE,
        pin_fhasta IN DATE,
        pin_codven IN NUMBER,
        pin_codmot IN NUMBER,
        pin_codsuc IN NUMBER,
        pin_codcli IN VARCHAR2,
        pin_situac IN VARCHAR2,
        pin_limit  IN NUMBER,
        pin_offset IN NUMBER
    ) RETURN datatable3
        PIPELINED;

    -- FIN BUSQUEDA DE PEDIDOS

    FUNCTION sp_buscar_guiasremision (
        pin_id_cia      IN NUMBER,
        pin_fdesde      IN DATE,
        pin_fhasta      IN DATE,
        pin_codcli      IN VARCHAR2,
        pin_situac      IN VARCHAR2,
        pin_codmot      IN NUMBER,
        pin_codven      IN NUMBER,
        pin_codsuc      IN NUMBER,
        pin_estadosunat IN NUMBER,
        pin_lugemi      IN NUMBER,
        pin_limit       IN NUMBER,
        pin_offset      IN NUMBER
    ) RETURN datatable_guia_remision
        PIPELINED;

    FUNCTION sp_buscar_req_compra (
        pin_id_cia IN NUMBER,--
        pin_lugemi IN NUMBER,--
        pin_fdesde IN DATE,--
        pin_fhasta IN DATE,--
        pin_codcli IN VARCHAR2,
        pin_situac IN VARCHAR2,
        pin_codven IN NUMBER,
        pin_codsuc IN NUMBER,
        pin_limit  IN NUMBER,
        pin_offset IN NUMBER
    ) RETURN datatable5
        PIPELINED;

    FUNCTION sp_buscar_orden_compra (
        pin_id_cia IN NUMBER,--
        pin_lugemi IN NUMBER,--
        pin_fdesde IN DATE,--
        pin_fhasta IN DATE,--
        pin_codcli IN VARCHAR2,
        pin_situac IN VARCHAR2,
        pin_codven IN NUMBER,
        pin_codsuc IN NUMBER,
        pin_destin IN NUMBER,
        pin_limit  IN NUMBER,
        pin_offset IN NUMBER
    ) RETURN datatable6
        PIPELINED;

    FUNCTION sp_buscar_doc_importacion (
        pin_id_cia IN NUMBER,--
        pin_lugemi IN NUMBER,--
        pin_fdesde IN DATE,--
        pin_fhasta IN DATE,--
        pin_codcli IN VARCHAR2,--
        pin_situac IN VARCHAR2,--
        pin_codven IN NUMBER,--
        pin_codsuc IN NUMBER,--
        pin_limit  IN NUMBER,
        pin_offset IN NUMBER
    ) RETURN datatable7
        PIPELINED;

    FUNCTION sp_buscar_guiias_internas (
        pin_id_cia IN NUMBER,--A
        pin_lugemi IN NUMBER,--A
        pin_fdesde IN DATE,--A
        pin_fhasta IN DATE,--A
        pin_codcli IN VARCHAR2,--A
        pin_situac IN VARCHAR2,--A
        pin_codven IN NUMBER,--A
        pin_codsuc IN NUMBER,--A
        pin_id     CHAR,
        pin_codmot IN NUMBER,
        pin_limit  IN NUMBER,
        pin_offset IN NUMBER
    ) RETURN datatable_guias_internas
        PIPELINED;

    FUNCTION sp_buscar_req_compra_importacion (
        pin_id_cia IN NUMBER,
        pin_lugemi IN NUMBER,
        pin_fdesde IN DATE,
        pin_fhasta IN DATE,
        pin_codcli IN VARCHAR2,
        pin_situac IN VARCHAR2,
        pin_codven IN NUMBER,
        pin_codsuc IN NUMBER,
        pin_limit  IN NUMBER,
        pin_offset IN NUMBER
    ) RETURN datatable5
        PIPELINED;

--SELECT * FROM PACK_BUSCAR.sp_buscar_req_compra_importacion (25,-1,to_date('01/01/2020','DD/MM/YYYY'),to_date('25/07/2022','DD/MM/YYYY'),
--    NULL,NULL,-1,-1,100,0);

    FUNCTION sp_buscar_orden_compra_importacion (
        pin_id_cia IN NUMBER,
        pin_lugemi IN NUMBER,
        pin_fdesde IN DATE,
        pin_fhasta IN DATE,
        pin_codcli IN VARCHAR2,
        pin_situac IN VARCHAR2,
        pin_codven IN NUMBER,
        pin_codsuc IN NUMBER,
        pin_destin IN NUMBER,
        pin_limit  IN NUMBER,
        pin_offset IN NUMBER
    ) RETURN datatable9
        PIPELINED;

--SELECT * FROM  PACK_BUSCAR.sp_buscar_orden_compra_importacion(25,-1,to_date('01/01/2020','DD/MM/YYYY'),to_date('25/07/2022','DD/MM/YYYY'),
--    NULL,NULL,-1,-1,-1,100,0);

    FUNCTION sp_buscar_orden_produccion (
        pin_id_cia IN NUMBER,
        pin_fdesde IN DATE,
        pin_fhasta IN DATE,
        pin_codven IN NUMBER,
        pin_codmot IN NUMBER,
        pin_codsuc IN NUMBER,
        pin_codcli IN VARCHAR2,
        pin_situac IN VARCHAR2,
        pin_limit  IN NUMBER,
        pin_offset IN NUMBER
    ) RETURN datatable_buscar_orden_produccion
        PIPELINED;

    FUNCTION sp_buscar_orden_produccion_noliq (
        pin_id_cia IN NUMBER,
        pin_fdesde IN DATE,
        pin_fhasta IN DATE,
        pin_codven IN NUMBER,
        pin_codmot IN NUMBER,
        pin_codsuc IN NUMBER,
        pin_codcli IN VARCHAR2,
        pin_situac IN VARCHAR2,
        pin_limit  IN NUMBER,
        pin_offset IN NUMBER
    ) RETURN datatable_buscar_orden_produccion
        PIPELINED;

    FUNCTION sp_buscar_orden_trabajo (
        pin_id_cia IN NUMBER,
        pin_fdesde IN DATE,
        pin_fhasta IN DATE,
        pin_codven IN NUMBER,
        pin_codmot IN NUMBER,
        pin_codsuc IN NUMBER,
        pin_codcli IN VARCHAR2,
        pin_situac IN VARCHAR2,
        pin_limit  IN NUMBER,
        pin_offset IN NUMBER
    ) RETURN datatable_buscar_orden_produccion
        PIPELINED;

END pack_buscar;

/

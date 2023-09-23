--------------------------------------------------------
--  DDL for Package PACK_REPORTES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_REPORTES" AS
    TYPE datarecord_registro_ventas_detalle IS RECORD (
        tipdoc     documentos_cab.tipdoc%TYPE,
        series     documentos_cab.series%TYPE,
        numint     documentos_cab.numint%TYPE,
        numdoc     documentos_cab.numdoc%TYPE,
        femisi     documentos_cab.femisi%TYPE,
        codmot     documentos_cab.codmot%TYPE,
        situac     documentos_cab.situac%TYPE,
        situacdesc situacion.dessit%TYPE,
        razonc     documentos_cab.razonc%TYPE,
        codcpag    documentos_cab.codcpag%TYPE,
        desccpag   c_pago.despag%TYPE,
        desdoc     documentos_tipo.descri%TYPE,
        simbolo    tmoneda.simbolo%TYPE,
        totbru     documentos_cab.totbru%TYPE,
        descue     documentos_cab.descue%TYPE,
        monafe     documentos_cab.monafe%TYPE,
        monina     documentos_cab.monina%TYPE,
        monexpadd  documentos_cab.monina%TYPE,
        moninaca   documentos_cab.monina%TYPE,
        monexocab  documentos_cab.monina%TYPE,
        monexoexp  documentos_cab.monina%TYPE,
        monigv     documentos_cab.monina%TYPE,
        monisc     documentos_cab.monisc%TYPE,
        monotr     documentos_cab.monotr%TYPE,
        preven     documentos_cab.preven%TYPE,
        prevensol  documentos_cab.preven%TYPE,
        prevendol  documentos_cab.preven%TYPE
    );
    TYPE datatable_registro_ventas_detalle IS
        TABLE OF datarecord_registro_ventas_detalle;
    TYPE datarecord_registro_ventas_pdf IS RECORD (
        tipdoc        documentos_cab.tipdoc%TYPE,
        serie         documentos_cab.series%TYPE,
        numdoc        documentos_cab.numdoc%TYPE,
        femisi        documentos_cab.femisi%TYPE,
        fecter        documentos_cab.fecter%TYPE,
        destin        documentos_cab.destin%TYPE,
        situac        documentos_cab.situac%TYPE,
        numint        documentos_cab.numint%TYPE,
        codmot        documentos_cab.codmot%TYPE,
        tident        cliente.tident%TYPE,
        dident        cliente.dident%TYPE,
        codcli        documentos_cab.codcli%TYPE,
        ruc           documentos_cab.ruc%TYPE,
        razonc        documentos_cab.razonc%TYPE,
        tipmon        documentos_cab.tipmon%TYPE,
        tipcam        documentos_cab.tipcam%TYPE,
        facpro        documentos_cab.facpro%TYPE,
        ffacpro       documentos_cab.ffacpro%TYPE,
        tipdocre      documentos_cab.tipdoc%TYPE,
        seriere       documentos_cab.series%TYPE,
        numdocre      documentos_cab.numdoc%TYPE,
        femisire      documentos_cab.femisi%TYPE,
        totbru        documentos_cab.totbru%TYPE,
        descue        documentos_cab.descue%TYPE,
        monafe        documentos_cab.monafe%TYPE,
        monexo        documentos_cab.monexo%TYPE,
        monina        documentos_cab.monina%TYPE,
        monigv        documentos_cab.monigv%TYPE,
        preven        documentos_cab.preven%TYPE,
        seguro        documentos_cab.seguro%TYPE,
        gasadu        documentos_cab.gasadu%TYPE,
        flete         documentos_cab.flete%TYPE,
        prevensol     NUMERIC(16, 2),
        prevendol     NUMERIC(16, 2),
        dessit        situacion.dessit%TYPE,
        aliassit      situacion.alias%TYPE,
        permisit      situacion.permis%TYPE,
        desser        documentos.descri%TYPE,
        desdoc        tdoccobranza.descri%TYPE,
        signo         tdoccobranza.signo%TYPE,
        codsuc        NUMBER(38, 0),
        sucursal      VARCHAR2(20),
        monisc        documentos_cab.monisc%TYPE,
        monotr        documentos_cab.monotr%TYPE,
        numintdcr     documentos_cab.numint%TYPE,
        tipdocdcr     documentos_cab.tipdoc%TYPE,
        seriesdcr     documentos_cab.series%TYPE,
        numdocdcr     documentos_cab.numdoc%TYPE,
        femisidcr     documentos_cab.femisi%TYPE,
        factdestipdoc documentos.descri%TYPE,
        simbolo       tmoneda.simbolo%TYPE
    );
    TYPE datatable_registro_ventas_pdf IS
        TABLE OF datarecord_registro_ventas_pdf;
    TYPE datarecord_registro_ventas_resumen IS RECORD (
        tipdoc       documentos_cab.tipdoc%TYPE,
        serie        documentos_cab.series%TYPE,
        desdoc       documentos_tipo.descri%TYPE,
        simbolo      tmoneda.simbolo%TYPE,
        cantidaddocs NUMBER(38, 0),
        acuenta      documentos_cab.acuenta%TYPE,
        totbru       documentos_cab.totbru%TYPE,
        descue       documentos_cab.descue%TYPE,
        monafe       documentos_cab.monafe%TYPE,
        monexo       documentos_cab.monexo%TYPE,
        monina       documentos_cab.monina%TYPE,
        monigv       documentos_cab.monigv%TYPE,
        monisc       documentos_cab.monisc%TYPE,
        monotr       documentos_cab.monotr%TYPE,
        preven       documentos_cab.preven%TYPE
    );
    TYPE datatable_registro_ventas_resumen IS
        TABLE OF datarecord_registro_ventas_resumen;
    TYPE datarecord_fn_acta_entrega IS RECORD (
        clienterazonc    documentos_cab.razonc%TYPE,
        clienteruc       documentos_cab.ruc%TYPE,
        dam              kardex000.dam%TYPE,
        placa            kardex000.placa%TYPE,
        dam_item         kardex000.dam_item%TYPE,
        clase02          VARCHAR2(500),
        clase03          VARCHAR2(500),
        clase04          VARCHAR2(500),
        clase12          VARCHAR2(150),
        especificacion11 VARCHAR2(150),
        especificacion13 VARCHAR2(150),
        femisi           documentos_cab.femisi%TYPE,
        periodo          NUMBER,
        idmes            NUMBER,
        id_cia           documentos_det.id_cia%TYPE,
        numint           documentos_det.numint%TYPE,
        numite           documentos_det.numite%TYPE,
        tipdoc           documentos_det.tipdoc%TYPE,
        series           VARCHAR2(5 BYTE),
        tipinv           documentos_det.tipinv%TYPE,
        codart           VARCHAR2(40 BYTE),
        situac           CHAR(1 BYTE),
        codalm           documentos_det.codalm%TYPE,
        cantid           NUMBER(16, 5),
        canref           NUMBER(16, 5),
        canped           NUMBER(16, 5),
        saldo            NUMBER(16, 5),
        pordes1          NUMBER(16, 5),
        pordes2          NUMBER(16, 5),
        pordes3          NUMBER(16, 5),
        pordes4          NUMBER(16, 5),
        preuni           NUMBER(16, 5),
        cosuni           NUMBER(16, 5),
        observ           VARCHAR2(3000 BYTE),
        fcreac           TIMESTAMP(6),
        factua           TIMESTAMP(6),
        usuari           VARCHAR2(10 BYTE),
        importe_bruto    NUMBER(16, 2),
        importe          NUMBER(16, 2),
        opnumdoc         documentos_det.opnumdoc%TYPE,
        opcargo          VARCHAR2(8 BYTE),
        opnumite         documentos_det.opnumite%TYPE,
        optipinv         documentos_det.optipinv%TYPE,
        codund           VARCHAR2(3 BYTE),
        largo            NUMBER(9, 3),
        ancho            NUMBER(9, 3),
        altura           NUMBER(9, 3),
        porigv           NUMBER(16, 2),
        monafe           NUMBER(16, 2),
        monina           NUMBER(16, 2),
        monigv           NUMBER(16, 5),
        optramo          documentos_det.optramo%TYPE,
        etiqueta         VARCHAR2(100 BYTE),
        piezas           NUMBER(16, 5),
        opronumdoc       VARCHAR2(30 BYTE),
        numguia          VARCHAR2(20 BYTE),
        fecguia          DATE,
        numfact          VARCHAR2(20 BYTE),
        fecfact          DATE,
        lote             VARCHAR2(20 BYTE),
        fecfabr          DATE,
        nrocarrete       VARCHAR2(20 BYTE),
        nrotramo         documentos_det.nrotramo%TYPE,
        tottramo         documentos_det.tottramo%TYPE,
        norma            documentos_det.norma%TYPE,
        etiqueta2        VARCHAR2(100 BYTE),
        codcli           VARCHAR2(20 BYTE),
        tara             NUMBER(16, 5),
        royos            NUMBER(16, 5),
        positi           documentos_det.positi%TYPE,
        codadd01         VARCHAR2(10 BYTE),
        codadd02         VARCHAR2(10 BYTE),
        ubica            VARCHAR2(10 BYTE),
        opnumsec         documentos_det.opnumsec%TYPE,
        combina          VARCHAR2(20 BYTE),
        empalme          VARCHAR2(20 BYTE),
        swacti           documentos_det.swacti%TYPE,
        diseno           VARCHAR2(20 BYTE),
        acabado          VARCHAR2(20 BYTE),
        fvenci           DATE,
        seguro           NUMBER(12, 2),
        flete            NUMBER(12, 2),
        fmanuf           DATE,
        monisc           NUMBER(16, 2),
        valporisc        NUMBER(12, 6),
        tipisc           CHAR(2 BYTE),
        monotr           NUMBER(16, 2),
        monexo           NUMBER(16, 2),
        numintpre        NUMBER,
        numitepre        NUMBER,
        montgr           NUMBER(16, 2),
        tipafec          VARCHAR2(5 BYTE),
        costot01         NUMBER(16, 2),
        costot02         NUMBER(16, 2),
        cargamin         NUMBER(16, 4),
        det_dam          documentos_det.dam%TYPE,
        det_dam_item     documentos_det.dam_item%TYPE,
        chasis           documentos_det.chasis%TYPE,
        motor            documentos_det.motor%TYPE,
        monicbper        documentos_det.monicbper%TYPE
    );
    TYPE datatable_fn_acta_entrega IS
        TABLE OF datarecord_fn_acta_entrega;
    FUNCTION sp_registro_ventas_detalle (
        pin_id_cia IN NUMBER,--S
        pin_fdesde IN DATE,--S
        pin_fhasta IN DATE,--S
        pin_codsuc IN NUMBER,--S
        pin_codcli IN VARCHAR2,--S
        pin_codven IN NUMBER,--S
        pin_moneda IN VARCHAR2,--S
        pin_limit  IN NUMBER,--S
        pin_offset IN NUMBER--S
    ) RETURN datatable_registro_ventas_detalle
        PIPELINED;

    FUNCTION sp_registro_ventas_pdf (
        pin_id_cia  IN NUMBER,
        pin_tipdoc  IN NUMBER,
        pin_periodo IN NUMBER,
        pin_mes     IN NUMBER,
        pin_fdesde  IN DATE,
        pin_fhasta  IN DATE,
        pin_codsuc  IN NUMBER,
        pin_lugemi  IN NUMBER,
        pin_codmot  IN NUMBER,
        pin_codcli  IN VARCHAR2,
        pin_codven  IN NUMBER
    ) RETURN datatable_registro_ventas_pdf
        PIPELINED;

    FUNCTION sp_registro_ventas_resumen (
        pin_id_cia IN NUMBER,
        pin_fdesde IN DATE,
        pin_fhasta IN DATE,
        pin_codsuc IN NUMBER,
        pin_codcli IN VARCHAR2,
        pin_codven IN NUMBER,
        pin_moneda IN VARCHAR2
    ) RETURN datatable_registro_ventas_resumen
        PIPELINED;

    FUNCTION fn_acta_entrega (
        pin_id_cia IN NUMBER,
        pin_numint IN NUMBER,
        pin_numite IN NUMBER
    ) RETURN datatable_fn_acta_entrega
        PIPELINED;

END pack_reportes;

/

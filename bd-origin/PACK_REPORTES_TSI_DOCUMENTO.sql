--------------------------------------------------------
--  DDL for Package PACK_REPORTES_TSI_DOCUMENTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_REPORTES_TSI_DOCUMENTO" AS
    TYPE datarecord_buscar_documento_cxc IS RECORD (
        id_cia         documentos_cab.id_cia%TYPE,
        codcli         documentos_cab.codcli%TYPE,
        swflag         VARCHAR2(10),
        tipdoc         documentos_cab.tipdoc%TYPE,
        desdoc         documentos_tipo.descri%TYPE,
        abrdoc         documentos_tipo.abrevi%TYPE,
        docume         dcta100.docume%TYPE,
        numint         dcta100.numint%TYPE,
        operac         dcta100.operac%TYPE,
        femisi         dcta100.femisi%TYPE,
        fvenci         dcta100.fvenci%TYPE,
        dh             dcta100.dh%TYPE,
        tipmon         dcta100.tipmon%TYPE,
        importedebe    dcta100.importe%TYPE,
        importehaber   dcta100.importe%TYPE,
        importedebe01  dcta100.importe%TYPE,
        importehaber01 dcta100.importe%TYPE,
        importedebe02  dcta100.importe%TYPE,
        importehaber02 dcta100.importe%TYPE,
        orisaldo       dcta100_ori.saldo%TYPE
    );
    TYPE datatable_buscar_documento_cxc IS
        TABLE OF datarecord_buscar_documento_cxc;
    TYPE datarecord_buscar_documento_cxp IS RECORD (
        id_cia         documentos_cab.id_cia%TYPE,
        codcli         documentos_cab.codcli%TYPE,
        swflag         VARCHAR2(10),
        tipdoc         tdocume.codigo%TYPE,
        desdoc         tdocume.descri%TYPE,
        abrdoc         tdocume.abrevi%TYPE,
        docume         dcta100.docume%TYPE,
        tipo           prov100.tipo%TYPE,
        docu           prov100.docu%TYPE,
        operac         dcta100.operac%TYPE,
        femisi         dcta100.femisi%TYPE,
        fvenci         dcta100.fvenci%TYPE,
        dh             dcta100.dh%TYPE,
        tipmon         dcta100.tipmon%TYPE,
        importedebe    dcta100.importe%TYPE,
        importehaber   dcta100.importe%TYPE,
        importedebe01  dcta100.importe%TYPE,
        importehaber01 dcta100.importe%TYPE,
        importedebe02  dcta100.importe%TYPE,
        importehaber02 dcta100.importe%TYPE
    );
    TYPE datatable_buscar_documento_cxp IS
        TABLE OF datarecord_buscar_documento_cxp;
    TYPE datarecord_buscar_saldo_cxc IS RECORD (
        id_cia documentos_cab.id_cia%TYPE,
        codcli documentos_cab.codcli%TYPE,
        tipdoc documentos_cab.tipdoc%TYPE,
        desdoc documentos_tipo.descri%TYPE,
        abrdoc documentos_tipo.abrevi%TYPE,
        docume dcta100.docume%TYPE,
        numint dcta100.numint%TYPE,
        femisi dcta100.femisi%TYPE,
        fvenci dcta100.fvenci%TYPE,
        dh     dcta100.dh%TYPE,
        tipmon dcta100.tipmon%TYPE,
        saldo  dcta100.saldo%TYPE
    );
    TYPE datatable_buscar_saldo_cxc IS
        TABLE OF datarecord_buscar_saldo_cxc;
    TYPE datarecord_buscar_saldo_cxp IS RECORD (
        id_cia documentos_cab.id_cia%TYPE,
        codcli documentos_cab.codcli%TYPE,
        tipdoc tdocume.codigo%TYPE,
        desdoc tdocume.descri%TYPE,
        abrdoc tdocume.abrevi%TYPE,
        docume dcta100.docume%TYPE,
        tipo   prov100.tipo%TYPE,
        docu   prov100.docu%TYPE,
        femisi dcta100.femisi%TYPE,
        fvenci dcta100.fvenci%TYPE,
        dh     dcta100.dh%TYPE,
        tipmon dcta100.tipmon%TYPE,
        saldo  dcta100.saldo%TYPE
    );
    TYPE datatable_buscar_saldo_cxp IS
        TABLE OF datarecord_buscar_saldo_cxp;
    TYPE datarecord_buscar_cxc IS RECORD (
--        id_cia    documentos_cab.id_cia%TYPE,
        periodo   NUMBER(38, 0),
        mes       NUMBER(38, 0),
        tipdoc    dcta100.tipdoc%TYPE,
        abrdoc    documentos_tipo.abrevi%TYPE,
        desdoc    documentos_tipo.descri%TYPE,
        docume    dcta100.docume%TYPE,
        serie     dcta100.serie%TYPE,
        numero    dcta100.numero%TYPE,
        refere01  dcta100.refere01%TYPE,
        femisi    VARCHAR2(100),
        fvenci    VARCHAR2(100),
        diasmora  NUMBER(38, 0),
        fcance    VARCHAR2(100),
        numbco    dcta100.numbco%TYPE,
        tipmon    dcta100.tipmon%TYPE,
        tipcam    dcta100.tipcam%TYPE,
        importe   dcta100.importe%TYPE,
        codsuc    dcta100.codsuc%TYPE,
        saldox    dcta100.saldo%TYPE,
        codban    dcta100.codban%TYPE,
        desban    tbancos.descri%TYPE,
        codcli    dcta100.codcli%TYPE,
        razonc    cliente.razonc%TYPE,
        limcre1   cliente.limcre1%TYPE,
        limcre2   cliente.limcre2%TYPE,
        chedev    cliente.chedev%TYPE,
        letpro    cliente.letpro%TYPE,
        renova    cliente.renova%TYPE,
        refina    cliente.refina%TYPE,
        fecing    VARCHAR2(100),
        codven    dcta100.codven%TYPE,
        desven    vendedor.desven%TYPE,
        protes    dcta100.protes%TYPE,
        operac    dcta100.operac%TYPE,
        credito   VARCHAR2(20),
        cuenta    dcta100.cuenta%TYPE,
        descuenta pcuentas.nombre%TYPE
    );
    TYPE datatable_buscar_cxc IS
        TABLE OF datarecord_buscar_cxc;
    TYPE datarecord_buscar_cxp IS RECORD (
--        id_cia    documentos_cab.id_cia%TYPE,
        periodo   NUMBER(38, 0),
        mes       NUMBER(38, 0),
        tipdoc    tdocume.codigo%TYPE,
        abrdoc    tdocume.abrevi%TYPE,
        desdoc    tdocume.descri%TYPE,
        docume    dcta100.docume%TYPE,
        tipo      prov100.tipo%TYPE,
        docu      prov100.docu%TYPE,
        refere01  dcta100.refere01%TYPE,
        femisi    VARCHAR2(100),
        fvenci    VARCHAR2(100),
        diasmora  NUMBER(38, 0),
        fcance    VARCHAR2(100),
        numbco    dcta100.numbco%TYPE,
        tipmon    dcta100.tipmon%TYPE,
--        tipcam    dcta100.tipcam%TYPE,
        importe   dcta100.importe%TYPE,
        codsuc    dcta100.codsuc%TYPE,
        saldox    prov100.saldo%TYPE,
        codban    dcta100.codban%TYPE,
        desban    tbancos.descri%TYPE,
        codcli    dcta100.codcli%TYPE,
        razonc    cliente.razonc%TYPE,
        limcre1   cliente.limcre1%TYPE,
        limcre2   cliente.limcre2%TYPE,
        chedev    cliente.chedev%TYPE,
        letpro    cliente.letpro%TYPE,
        renova    cliente.renova%TYPE,
        refina    cliente.refina%TYPE,
        fecing    VARCHAR2(100),
        operac    dcta100.operac%TYPE,
        credito   VARCHAR2(20),
        cuenta    dcta100.cuenta%TYPE,
        descuenta pcuentas.nombre%TYPE
    );
    TYPE datatable_buscar_cxp IS
        TABLE OF datarecord_buscar_cxp;

--SELECT
--    *
--FROM
--    pack_reportes_tsi_documento.sp_buscar(216, NULL, NULL, NULL, NULL,
--                                          NULL, 'S', '01/10/2023', NULL);

    FUNCTION sp_buscar_documento_cxc (
        pin_id_cia    NUMBER,
        pin_codsuc    NUMBER,
        pin_codcli    VARCHAR2,
        pin_codven    NUMBER,
        pin_tipdocs   VARCHAR2,
        pin_codubis   VARCHAR2,
        pin_fhasta    DATE,
        pin_numint    NUMBER,
        pin_incletdes VARCHAR2
    ) RETURN datatable_buscar_documento_cxc
        PIPELINED;

    FUNCTION sp_buscar_documento_cxp (
        pin_id_cia  NUMBER,
        pin_codcli  VARCHAR2,
        pin_tipdocs VARCHAR2,
        pin_fhasta  DATE,
        pin_tipo    NUMBER,
        pin_docu    NUMBER
    ) RETURN datatable_buscar_documento_cxp
        PIPELINED;

    FUNCTION sp_buscar_saldo_cxc (
        pin_id_cia    NUMBER,
        pin_codsuc    NUMBER,
        pin_codcli    VARCHAR2,
        pin_codven    NUMBER,
        pin_tipdocs   VARCHAR2,
        pin_codubis   VARCHAR2,
        pin_fhasta    DATE,
        pin_numint    NUMBER,
        pin_incletdes VARCHAR2,
        pin_incfacant VARCHAR2
    ) RETURN datatable_buscar_saldo_cxc
        PIPELINED;

    FUNCTION sp_buscar_saldo_cxp (
        pin_id_cia  NUMBER,
        pin_codcli  VARCHAR2,
        pin_tipdocs VARCHAR2,
        pin_fhasta  DATE,
        pin_tipo    NUMBER,
        pin_docu    NUMBER
    ) RETURN datatable_buscar_saldo_cxp
        PIPELINED;

    -- REPORTE EN EXCEL - TSI REPORTES
    FUNCTION sp_buscar_cxc (
        pin_id_cia NUMBER,
        pin_fhasta DATE
    ) RETURN datatable_buscar_cxc
        PIPELINED;

    FUNCTION sp_buscar_cxp (
        pin_id_cia NUMBER,
        pin_fhasta DATE
    ) RETURN datatable_buscar_cxp
        PIPELINED;

    -- REPORTE EN PDF DE CXC Y CXP
    FUNCTION sp_reporte_cxc (
        pin_id_cia  NUMBER,
        pin_fhasta  DATE,
        pin_codcli  VARCHAR2,
        pin_tipdocs VARCHAR2,
        pin_codalms VARCHAR2
    ) RETURN datatable_buscar_cxc
        PIPELINED;

    FUNCTION sp_reporte_cxp (
        pin_id_cia  NUMBER,
        pin_fhasta  DATE,
        pin_codcli  VARCHAR2,
        pin_tipdocs VARCHAR2
    ) RETURN datatable_buscar_cxp
        PIPELINED;
        
--    SELECT
--    periodo,
--    mes,
--    tipmon,
--    SUM(importe),
--    SUM(saldox)
--FROM pack_reportes_tsi_documento.sp_buscar_cxp(56,'27/01/23')
--GROUP BY
--    periodo,
--    mes,
--    tipmon
--ORDER BY
--    periodo,
--    mes;
--
--SELECT
--    *
--FROM pack_reportes_tsi_documento.sp_buscar_cxp(56,'27/01/23')
--WHERE periodo = 2022 and mes = 2 AND tipmon = 'PEN'
--ORDER BY
--TIPO DESC,
--DOCU DESC
--
--SELECT
--    *
--FROM pack_reportes_tsi_documento.sp_buscar_saldo_cxp(56,NULL,NULL,'27/01/23',999,55)
--
--SELECT
--    *
--FROM pack_reportes_tsi_documento.sp_buscar_DOCUMENTO_cxp(56,NULL,NULL,'27/01/23',999,55)
--
--SELECT
--    EXTRACT(YEAR FROM d.fvenci)  AS periodo,
--    EXTRACT(MONTH FROM d.fvenci) AS mes,
--    tipmon,
--    SUM(D.importe * td.signo),
--    SUM(D.saldo * td.signo)
----        SUM(importe),
----    SUM(saldo)
--FROM
--    prov100      d
--    LEFT OUTER JOIN cliente      c ON c.id_cia = d.id_cia
--                                 AND c.codcli = d.codcli
--    LEFT OUTER JOIN tdocume      td ON td.id_cia = d.id_cia
--                                  AND td.codigo = d.tipdoc
--    LEFT OUTER JOIN e_financiera ef ON ef.id_cia = d.id_cia
--                                       AND ef.codigo = d.codban
--    LEFT OUTER JOIN sucursal     s ON s.id_cia = d.id_cia
--                                  AND s.codsuc = d.codsuc
--WHERE
--        d.id_cia = 56
--    AND ( d.saldo <> 0 )
----    AND F.FVENCI
--    AND ( d.fvenci BETWEEN '01/01/00' AND '27/01/23' )
--GROUP BY
--    EXTRACT(YEAR FROM d.fvenci),
--    EXTRACT(MONTH FROM d.fvenci),
--    tipmon
--ORDER BY
--    periodo,
--    mes;
--
--SELECT
--d.*
--FROM
--    prov100      d
--    LEFT OUTER JOIN cliente      c ON c.id_cia = d.id_cia
--                                 AND c.codcli = d.codcli
--    LEFT OUTER JOIN tdocume      td ON td.id_cia = d.id_cia
--                                  AND td.codigo = d.tipdoc
--    LEFT OUTER JOIN e_financiera ef ON ef.id_cia = d.id_cia
--                                       AND ef.codigo = d.codban
--    LEFT OUTER JOIN sucursal     s ON s.id_cia = d.id_cia
--                                  AND s.codsuc = d.codsuc
--WHERE
--        d.id_cia = 56
--    AND ( d.saldo <> 0 )
--    AND ( d.fvenci <= '01/01/2024' ) AND
--    EXTRACT(YEAR FROM d.fvenci)  = 2022 AND
--    EXTRACT(MONTH FROM d.fvenci) = 2
--    AND tipmon = 'PEN'
--ORDER BY
--TIPO DESC,
--DOCU DESC

--SELECT * FROM pack_reportes_tsi_documento.sp_buscar_documento_cxc(25,-1,'20259659907',-1,NULL,NULL,
--    to_date('15/06/23','DD/MM/YY'),-1,'S') WHERE numint = 3165
--    
--    
--SELECT * FROM pack_reportes_tsi_documento.sp_buscar_documento_cxc(66,-1,NULL,-1,NULL,NULL,
--    to_date('06/05/23','DD/MM/YY'),-1,'S') WHERE codcli = '00000010'
--
--
--SELECT ddd.* FROM pack_reportes_tsi_documento.sp_buscar_saldo_cxc(66,1,NULL,-1,NULL,NULL,
--    to_date('06/05/23','DD/MM/YY'),-1,'S','N')  ddd
--        LEFT OUTER JOIN dcta100 d ON  d.id_cia = ddd.id_cia AND d.numint = ddd.numint 
--    WHERE
--        ddd.saldo <>  d.saldo

END;

/

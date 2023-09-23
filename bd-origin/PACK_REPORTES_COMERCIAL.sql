--------------------------------------------------------
--  DDL for Package PACK_REPORTES_COMERCIAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_REPORTES_COMERCIAL" AS
    TYPE datarecord_rventas IS RECORD (
        tipdoc        documentos_cab.tipdoc%TYPE,
        serie         documentos_cab.series%TYPE,
        numdoc        documentos_cab.numdoc%TYPE,
        femisi        documentos_cab.femisi%TYPE,
        fecter        DATE,
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
        totexo      documentos_cab.monigv%TYPE,
        preven        documentos_cab.preven%TYPE,
        seguro        documentos_cab.seguro%TYPE,
        gasadu        documentos_cab.gasadu%TYPE,
        flete         documentos_cab.flete%TYPE,
        prevensol     NUMBER(16, 2),
        prevendol     NUMBER(16, 2),
        dessit        situacion.dessit%TYPE,
        aliassit      situacion.alias%TYPE,
        permisit      situacion.permis%TYPE,
        desser        documentos.descri%TYPE,
        desdoc        tdoccobranza.descri%TYPE,
        signo         tdoccobranza.signo%TYPE,
        codsuc        NUMBER,
        sucursal      VARCHAR2(100),
        monisc        documentos_cab.monisc%TYPE,
        monotr        documentos_cab.monotr%TYPE,
        numintdcr     documentos_cab_referencia.numint%TYPE,
        tipdocdcr     documentos_cab_referencia.tipdoc%TYPE,
        seriesdcr     documentos_cab_referencia.series%TYPE,
        numdocdcr     documentos_cab_referencia.numdoc%TYPE,
        femisidcr     documentos_cab_referencia.femisi%TYPE,
        factdestipdoc documentos.descri%TYPE,
        simbolo       tmoneda.simbolo%TYPE
    );
    TYPE datatable_rventas IS
        TABLE OF datarecord_rventas;
    FUNCTION sp_rventas (
        pin_id_cia  NUMBER,
        pin_tipdoc  NUMBER,
        pin_periodo NUMBER,
        pin_mes     NUMBER,
        pin_fdesde  DATE,
        pin_fhasta  DATE,
        pin_codsuc  NUMBER,
        pin_lugemi  NUMBER,
        pin_codmot  NUMBER,
        pin_codven  NUMBER,
        pin_codcli  VARCHAR2
    ) RETURN datatable_rventas
        PIPELINED;

--SELECT
--    *
--FROM
--    pack_reportes_comercial.sp_rventas(48, - 1, NULL, NULL, '01/12/2022',
--                                       '31/12/2022', - 1, - 1, - 1, - 1,
--                                       NULL);

END;

/

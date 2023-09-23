--------------------------------------------------------
--  DDL for Package PACK_DETRACCIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_DETRACCIONES" AS
    TYPE datarecord_detracciones_masivo IS RECORD (
        chksel     VARCHAR2(1),
        tipo       compr010.tipo%TYPE,
        docume     compr010.docume%TYPE,
        codpro     compr010.codpro%TYPE,
        codcli     cliente.codcli%TYPE,
        ruc        cliente.dident%TYPE,
        tident     cliente.tident%TYPE,
        razonc     cliente.razonc%TYPE,
        razon      compr010.razon%TYPE,
        tdocum     compr010.tdocum%TYPE,
        tdocumdes  tdocume.descri%TYPE,
        nserie     compr010.nserie%TYPE,
        numero     compr010.numero%TYPE,
        femisi     compr010.femisi%TYPE,
        pertrib    NUMBER,
        moneda     compr010.moneda%TYPE,
        impor01    compr010.impor01%TYPE,
        impdetrac  compr010.impdetrac%TYPE,
        tdetrac    compr010.tdetrac%TYPE,
        nomtasa    tfactor.nomfac%TYPE,
        tasa       tfactor.vreal%TYPE,
        c_operac   compr010_clase.codigo%TYPE,
        nomoperac  tfactor.nomfac%TYPE,
        c_bys      compr010_clase.codigo%TYPE,
        nombys     tfactor.nomfac%TYPE,
        cuentabn   cliente_bancos.cuenta%TYPE,
        numdoc_env detraccion_cab_envio_sunat.numdoc%TYPE,
        eestado    detraccion_cab_envio_sunat.estado%TYPE,
        enumint    detraccion_cab_envio_sunat.numint%TYPE,
        generado   estado_envio_detraccion.descri%TYPE,
        ddetrac    compr010.ddetrac%TYPE,
        fdetrac    compr010.fdetrac%TYPE
    );
    TYPE datatable_detracciones_masivo IS
        TABLE OF datarecord_detracciones_masivo;
    TYPE datarecord_txt IS RECORD (
        chksel      VARCHAR2(1),
        lote        INTEGER,
        tipo        compr010.tipo%TYPE,
        docume      compr010.docume%TYPE,
        codpro      compr010.codpro%TYPE,
        codcli      cliente.codcli%TYPE,
        ruc         cliente.dident%TYPE,
        tident      cliente.tident%TYPE,
        tidentsunat INTEGER,
        razonc      cliente.razonc%TYPE,
        razon       compr010.razon%TYPE,
        tdocum      compr010.tdocum%TYPE,
        tdocumdes   tdocume.descri%TYPE,
        nserie      compr010.nserie%TYPE,
        numero      compr010.numero%TYPE,
        femisi      compr010.femisi%TYPE,
        pertrib     NUMBER,
        moneda      compr010.moneda%TYPE,
        impor01     compr010.impor01%TYPE,
        impdetrac   compr010.impdetrac%TYPE,
        tdetrac     compr010.tdetrac%TYPE,
        nomtasa     tfactor.nomfac%TYPE,
        tasa        tfactor.vreal%TYPE,
        c_operac    compr010_clase.codigo%TYPE,
        nomoperac   tfactor.nomfac%TYPE,
        c_bys       compr010_clase.codigo%TYPE,
        nombys      tfactor.nomfac%TYPE,
        tipcta      cliente_bancos.tipcta%TYPE,
        codmon      cliente_bancos.tipmon%TYPE,
        cuentabn    cliente_bancos.cuenta%TYPE,
        numdoc_env  detraccion_cab_envio_sunat.numdoc%TYPE,
        estado      detraccion_cab_envio_sunat.estado%TYPE,
        numint      detraccion_cab_envio_sunat.numint%TYPE,
        generado    estado_envio_detraccion.descri%TYPE,
        ddetrac     compr010.ddetrac%TYPE,
        fdetrac     compr010.fdetrac%TYPE
    );
    TYPE datatable_txt IS
        TABLE OF datarecord_txt;
    FUNCTION sp_masivo (
        pin_id_cia   NUMBER,
        pin_periodo  NUMBER,
        pin_mes      NUMBER,
        pin_generado VARCHAR2
    ) RETURN datatable_detracciones_masivo
        PIPELINED;

    FUNCTION sp_txt (
        pin_id_cia NUMBER,
        pin_numint NUMBER
    ) RETURN datatable_txt
        PIPELINED;

END;

/

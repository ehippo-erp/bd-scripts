--------------------------------------------------------
--  DDL for Package PACK_REPORTES_CUENTAS_X_PAGAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_REPORTES_CUENTAS_X_PAGAR" AS
    TYPE datarecord_buscar IS RECORD (
        id_cia    prov101.id_cia%TYPE,
        planilla  VARCHAR2(500),
        libro     prov101.libro%TYPE,
        periodo   prov101.periodo%TYPE,
        mes       prov101.mes%TYPE,
        secuencia prov101.secuencia%TYPE,
        femisip101    prov101.femisi%TYPE,
        tipdoc    prov100.tipdoc%TYPE,
        docume    prov100.docume%TYPE,
        refere01  prov100.refere01%TYPE,
        refere02  prov100.refere02%TYPE,
        femisip100    prov100.femisi%TYPE,
        fvenci    prov100.fvenci%TYPE,
        fproce    prov101.fproce%TYPE,
        numbco    prov100.numbco%TYPE,
        tipmon    prov100.tipmon%TYPE,
        impor01   prov101.impor01%TYPE,
        impor02   prov101.impor02%TYPE,
        codban    prov100.codban%TYPE,
        codcli    prov100.codcli%TYPE,
        razonc    cliente.razonc%TYPE,
        limcre1   cliente.limcre1%TYPE,
        limcre2   cliente.limcre2%TYPE,
        chedev    cliente.chedev%TYPE,
        letpro    cliente.letpro%TYPE,
        renova    cliente.renova%TYPE,
        reFina    cliente.reFina%TYPE,
        fecing    cliente.fecing%TYPE,
        dtipdoc   tdocume.descri%TYPE,
        doccan    prov101.doccan%TYPE,
        dtipcan   m_pago.descri%TYPE
    );
    TYPE datatable_buscar IS
        TABLE OF datarecord_buscar;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_tipdoc VARCHAR2,
        pin_codcli VARCHAR2,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_buscar
        PIPELINED;

END;

/

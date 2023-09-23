--------------------------------------------------------
--  DDL for Package PACK_PROV100
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_PROV100" AS
    TYPE datarecord_prov100 IS RECORD (
        id_cia    prov100.id_cia%TYPE,
        tipo      prov100.tipo%TYPE,
        docu      prov100.docu%TYPE,
        tident    cliente.tident%TYPE,
        dident    cliente.dident%TYPE,
        codcli    prov100.codcli%TYPE,
        razonc    cliente.razonc%TYPE,
        tipdoc    prov100.tipdoc%TYPE,
        docume    prov100.docume%TYPE,
        serie     prov100.serie%TYPE,
        numero    prov100.numero%TYPE,
        periodo   prov100.periodo%TYPE,
        mes       prov100.mes%TYPE,
        femisi    prov100.femisi%TYPE,
        fvenci    prov100.fvenci%TYPE,
        fcance    prov100.fcance%TYPE,
        codban    prov100.codban%TYPE,
        numbco    prov100.numbco%TYPE,
        refere01  prov100.refere01%TYPE,
        refere02  prov100.refere02%TYPE,
        tipmon    prov100.tipmon%TYPE,
        importe   prov100.importe%TYPE,
        importemn prov100.importemn%TYPE,
        importeme prov100.importeme%TYPE,
        saldo     prov100.saldo%TYPE,
        saldomn   prov100.saldomn%TYPE,
        saldome   prov100.saldome%TYPE,
        concpag   prov100.concpag%TYPE,
        codcob    prov100.codcob%TYPE,
        codven    prov100.codven%TYPE,
        comisi    prov100.comisi%TYPE,
        codsuc    prov100.codsuc%TYPE,
        cancelado prov100.cancelado%TYPE,
        fcreac    prov100.fcreac%TYPE,
        factua    prov100.factua%TYPE,
        usuari    prov100.usuari%TYPE,
        situac    prov100.situac%TYPE,
        cuenta    prov100.cuenta%TYPE,
        dh        prov100.dh%TYPE,
        tipcam    prov100.tipcam%TYPE,
        operac    prov100.operac%TYPE,
        protes    prov100.protes%TYPE,
        diasmora  INTEGER
    );
    TYPE datatable_prov100 IS
        TABLE OF datarecord_prov100;
    FUNCTION sp_buscar_pago (
        pin_id_cia    NUMBER,
        pin_codcli    VARCHAR2,
        pin_tipo      VARCHAR2,
        pin_fhasta    DATE,
        pin_moneda    VARCHAR2,
        pin_mediopago VARCHAR2
    ) RETURN datatable_prov100
        PIPELINED;

--SELECT * FROM pack_prov100.sp_buscar_pago(66,NULL,'N',to_date('31/08/23','DD/MM/YY'),'PEN','2');

END;

/

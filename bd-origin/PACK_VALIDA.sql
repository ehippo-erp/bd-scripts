--------------------------------------------------------
--  DDL for Package PACK_VALIDA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_VALIDA" AS 

  /* TODO enter package declarations (types, exceptions, methods etc) here */

    TYPE datarecord IS RECORD (
        codigo      VARCHAR2(10),
        descripcion VARCHAR2(220)
    );
    TYPE datatable IS
        TABLE OF datarecord;
    FUNCTION envioctactefacturaboleta (
        pin_id_cia IN NUMBER,
        pin_doccab IN VARCHAR2
    ) RETURN datatable
        PIPELINED;

    FUNCTION documentocajatienda (
        pin_id_cia IN NUMBER,
        pin_doccab IN VARCHAR2
    ) RETURN datatable
        PIPELINED;

    FUNCTION configbanco (
        pin_id_cia IN NUMBER,
        pin_tipdep IN NUMBER,
        pin_tipmon IN VARCHAR2,
        pin_codsuc IN NUMBER
    ) RETURN datatable
        PIPELINED;

    FUNCTION configbancoautomatico (
        pin_id_cia IN NUMBER,
        pin_tipdep IN NUMBER,
        pin_tipmon IN VARCHAR2,
        pin_codsuc IN NUMBER
    ) RETURN datatable
        PIPELINED;

    FUNCTION documentorelacionado (
        pin_id_cia     IN NUMBER,
        pin_numint_rel IN NUMBER
    ) RETURN datatable
        PIPELINED;

    FUNCTION mescerrado (
        pin_id_cia  IN NUMBER,
        pin_sistema IN NUMBER,
        pin_periodo IN NUMBER,
        pin_mes     IN NUMBER
    ) RETURN datatable
        PIPELINED;

    FUNCTION envio_a_cuenta_x_cobrar (
        pin_id_cia IN NUMBER,
        pin_codpag IN NUMBER
    ) RETURN VARCHAR2;

    FUNCTION fechaentrega (
        pin_id_cia IN NUMBER,
        pin_fechaentrega IN DATE
    ) RETURN VARCHAR2;

    FUNCTION topeboletas (
        pin_id_cia IN NUMBER,
        pin_tipdoc IN NUMBER,
        pin_tident IN VARCHAR2,
        pin_ruc    IN VARCHAR2,
        pin_preven IN NUMBER
    ) RETURN datatable
        PIPELINED;

    FUNCTION igvdocumento (
        pin_id_cia IN NUMBER,
        pin_porigv IN NUMBER,
        pin_monafe IN NUMBER,
        pin_preven IN NUMBER,
        pin_monotr IN NUMBER,
        pin_monisc IN NUMBER,
        pin_monigv IN NUMBER,
        pin_monina IN NUMBER,
        pin_monexo IN NUMBER
    ) RETURN datatable
        PIPELINED;

    FUNCTION clientecredito_verify (
        pin_id_cia IN NUMBER,
        pin_codcli IN VARCHAR2
    ) RETURN datatable
        PIPELINED;

    FUNCTION dcabcorrelativo_validafemisi (
        pin_id_cia IN NUMBER,
        pin_tipdoc IN NUMBER,
        pin_serie  IN VARCHAR2,
        pin_numdoc IN NUMBER,
        pin_femisi IN DATE,
        pin_accion IN NUMBER
    ) RETURN datatable
        PIPELINED;

    FUNCTION valida_tident_ruc (
        pin_id_cia IN NUMBER,
        pin_tipdoc IN NUMBER,
        pin_tident IN VARCHAR2,
        pin_ruc    IN VARCHAR2,
        pin_destin IN NUMBER,
        pin_direc1 IN VARCHAR2
    ) RETURN datatable
        PIPELINED;

    FUNCTION retornaitemsxnumint (
        pin_id_cia IN NUMBER,
        pin_numint IN NUMBER,
        pin_tipdoc IN NUMBER,
        pin_serie  IN VARCHAR2
    ) RETURN datatable
        PIPELINED;


  /*  function verificar_cantidades_saldos_articulo(
         pin_id_cia IN NUMBER,
         pin_tipdoc in NUMBER,
         pin_id in VARCHAR2,
         pin_codmot in number
    ) return datatable PIPELINED;
    */



END pack_valida;

/

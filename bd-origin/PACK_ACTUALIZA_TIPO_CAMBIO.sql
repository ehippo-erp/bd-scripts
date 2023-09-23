--------------------------------------------------------
--  DDL for Package PACK_ACTUALIZA_TIPO_CAMBIO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_ACTUALIZA_TIPO_CAMBIO" AS
    TYPE datarecord_actualiza_tipo_cambio IS RECORD (
        id_cia    documentos_cab.id_cia%TYPE,
        numint    documentos_cab.numint%TYPE,
        tipdoc    documentos_cab.tipdoc%TYPE,
        series    documentos_cab.series%TYPE,
        numdoc    documentos_cab.numdoc%TYPE,
        femisi    documentos_cab.femisi%TYPE,
        razonc    documentos_cab.razonc%TYPE,
        tipmon    documentos_cab.tipmon%TYPE,
        situac    documentos_cab.situac%TYPE,
        tipdocref documentos_cab_referencia.tipdoc%TYPE,
        seriesref documentos_cab_referencia.series%TYPE,
        numdocref documentos_cab_referencia.numdoc%TYPE,
        femisiref documentos_cab_referencia.femisi%TYPE,
        numintdc3 documentos_cab.numint%TYPE,
        tipdocdc3 documentos_cab.tipdoc%TYPE,
        seriesdc3 documentos_cab.series%TYPE,
        numdocdc3 documentos_cab.numdoc%TYPE,
        femisidc3 documentos_cab.femisi%TYPE,
        situacdc3 documentos_cab.situac%TYPE,
        tipmondc3 documentos_cab.tipmon%TYPE,
        tipcamdc3 documentos_cab.tipcam%TYPE,
        venta     tcambio.venta%TYPE
    );
    TYPE datatable_actualiza_tipo_cambio IS
        TABLE OF datarecord_actualiza_tipo_cambio;
    PROCEDURE sp_actualiza (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER,
        pin_mes     NUMBER,
        pin_mensaje OUT VARCHAR2
    );

    FUNCTION sp_actualiza_tipo_cambio (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER,
        pin_mes     NUMBER
    ) RETURN datatable_actualiza_tipo_cambio
        PIPELINED;

END;

/

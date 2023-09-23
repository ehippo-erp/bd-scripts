--------------------------------------------------------
--  DDL for Package PACK_RECALCULO
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_RECALCULO" AS
    TYPE tacumuladetalle IS RECORD (
        totalsaldo            NUMERIC(16, 5),
        totalcantidad         NUMERIC(16, 5),
        pordes                NUMERIC(16, 5),
        totaldesespigv        NUMERIC(16, 5),
        totalbruto            NUMERIC(16, 5),
        totalprecioventa      NUMERIC(16, 5),
        totalpeso             NUMERIC(16, 5),
        totaligv              NUMERIC(16, 5),
        totaldescuento        NUMERIC(16, 5),
        totalafecto           NUMERIC(16, 5),
        totalinafecto         NUMERIC(16, 5),
        totaldesesp           NUMERIC(16, 5),
        totalneto             NUMERIC(16, 5),
        totalimporte          NUMERIC(16, 5),
        totalacuenta          NUMERIC(16, 5),
        totalimporteafecto    NUMERIC(16, 5),
        totalimporteinafecto  NUMERIC(16, 5),
        totalpesoneto         NUMERIC(16, 5),
        totalpesotara         NUMERIC(16, 5),
        totalpesobruto        NUMERIC(16, 5),
        totalisc              NUMERIC(16, 5),
        totalotrotributos     NUMERIC(16, 5),
        totalclase90          NUMERIC(16, 5),
        totalexonerado        NUMERIC(16, 5),
        totalgratuito         NUMERIC(16, 5)
    );
    PROCEDURE recalcula_toles (
        pin_id_cia           IN  NUMBER,
        pin_numint           IN  NUMBER,
        pin_sw_actualizacab  IN  VARCHAR2 DEFAULT 'S',
        pin_montoredondeo    IN  NUMERIC DEFAULT 0,
        pin_reverdesesp      IN  VARCHAR2 DEFAULT 'S'
    );

END pack_recalculo;

/

--------------------------------------------------------
--  DDL for Package PACK_SECUENCIA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_SECUENCIA" AS
    FUNCTION SP_ULTIMO_VALOR(
        PIN_ID_CIA IN NUMBER,
        PIN_TIPDOC IN NUMBER,
        PIN_SERIE IN VARCHAR2
    ) RETURN
        NUMBER;

    FUNCTION SP_VERIFICA_EXISTENCIA(
        PIN_ID_CIA IN NUMBER,
        PIN_TIPDOC IN NUMBER,--610
        PIN_SERIE IN VARCHAR2--999
    ) RETURN
        NUMBER;

END PACK_SECUENCIA;

/

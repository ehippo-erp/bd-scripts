--------------------------------------------------------
--  DDL for Package PACK_DCTA101
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_DCTA101" AS
    TYPE datatable_dcta101 IS
        TABLE OF dcta101%rowtype;

    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_numint NUMBER
    ) RETURN datatable_dcta101
        PIPELINED;

    PROCEDURE deldcta101 (
        pin_id_cia     IN   NUMBER,
        pin_libro      IN   VARCHAR2,
        pin_periodo    IN   NUMBER,
        pin_mes        IN   NUMBER,
        pin_secuencia  IN   NUMBER,
        pin_mensaje    OUT  VARCHAR2
    );

    PROCEDURE enviar_ctas_ctes_from_dcta103 (
        pin_id_cia     IN   NUMBER,
        pin_libro      IN   VARCHAR2,
        pin_periodo    IN   NUMBER,
        pin_mes        IN   NUMBER,
        pin_secuencia  IN   NUMBER,
        pin_usuari     IN   VARCHAR2,
        pin_mensaje    OUT  VARCHAR2
    );

    PROCEDURE deldcta113 (
        pin_id_cia     IN   NUMBER,
        pin_libro      IN   VARCHAR2,
        pin_periodo    IN   NUMBER,
        pin_mes        IN   NUMBER,
        pin_secuencia  IN   NUMBER,
        pin_mensaje    OUT  VARCHAR2
    );

    PROCEDURE enviar_ctas_ctes_from_dcta113 (
        pin_id_cia     IN   NUMBER,
        pin_libro      IN   VARCHAR2,
        pin_periodo    IN   NUMBER,
        pin_mes        IN   NUMBER,
        pin_secuencia  IN   NUMBER,
        pin_usuari     IN   VARCHAR2,
        pin_mensaje    OUT  VARCHAR2
    );

END pack_dcta101;

/

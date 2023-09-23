--------------------------------------------------------
--  DDL for Package PACK_ASIENHEA
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_ASIENHEA" AS 

  /* TODO enter package declarations (types, exceptions, methods etc) here */
    TYPE t_asienhea IS
        TABLE OF asienhea%rowtype;
    PROCEDURE delasienhea (
        pin_id_cia            IN   NUMBER,
        pin_periodo           IN   NUMBER,
        pin_mes               IN   NUMBER,
        pin_libro             IN   VARCHAR2,
        pin_asiento           IN   NUMBER,
        pin_eliminarasienhea  IN   VARCHAR2,
        pin_mensaje           OUT  VARCHAR2
    );

    PROCEDURE borracontabilidad (
        pin_id_cia   IN   NUMBER,
        pin_periodo  IN   NUMBER,
        pin_mes      IN   NUMBER,
        pin_libro    IN   VARCHAR2,
        pin_asiento  IN   NUMBER,
        pin_mensaje  OUT  VARCHAR2
    );
    /* TODO enter package declarations (types, exceptions, methods etc) here */

    PROCEDURE sp_save_asienhea (
        pin_id_cia   IN   NUMBER,
        pin_datos    IN   VARCHAR2,
        pin_opcdml   IN   NUMBER,
        pin_mensaje  OUT  VARCHAR2
    );

END pack_asienhea;

/

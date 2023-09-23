--------------------------------------------------------
--  DDL for Package PACK_BGENERALHEA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_BGENERALHEA" AS 

    PROCEDURE sp_save (
        pin_id_cia   IN   NUMBER,
        pin_datos    IN   VARCHAR2,
        pin_opcdml   INTEGER,
        pin_mensaje  OUT  VARCHAR2
    ); 

     PROCEDURE sp_save_det (
        pin_id_cia   IN   NUMBER,
        pin_datos    IN   VARCHAR2,
        pin_opcdml   INTEGER,
        pin_mensaje  OUT  VARCHAR2
    ); 

END PACK_BGENERALHEA;

/

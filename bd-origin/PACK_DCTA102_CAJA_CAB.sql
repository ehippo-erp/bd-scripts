--------------------------------------------------------
--  DDL for Package PACK_DCTA102_CAJA_CAB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_DCTA102_CAJA_CAB" AS 

  /* TODO enter package declarations (types, exceptions, methods etc) here */ 


    TYPE rec_detalles_caja IS RECORD (
        libro      VARCHAR2(3),
        deslibro   VARCHAR2(50),
        periodo    NUMBER,
        mes        NUMBER,
        secuencia  NUMBER,
        concep     VARCHAR2(150),
        situac     VARCHAR2(1),
        dessituac  VARCHAR2(20),
        pagomn     NUMERIC(16, 2),
        pagome     NUMERIC(16, 2)
    );
    TYPE tbl_detalles_caja IS
        TABLE OF rec_detalles_caja;
    FUNCTION detalles_caja (
        pin_id_cia   IN  NUMBER,
        pin_numcaja  IN  NUMBER
    ) RETURN tbl_detalles_caja
        PIPELINED;


   TYPE objResponse IS RECORD (
        codigo       VARCHAR2(10),
        descripcion  VARCHAR2(1200)
   );
   TYPE tblResponse IS TABLE OF objResponse;

    FUNCTION sp_chequea_caja_usuario (
        pin_id_cia IN NUMBER,
        pin_codsuc IN number,
        pin_femisi IN DATE,
        pin_coduser IN varchar2
    ) RETURN  tblResponse PIPELINED;


    PROCEDURE sp_apertura (
        pin_id_cia   IN   NUMBER,
        pin_numcaja  IN   NUMBER,
        pin_mensaje  OUT  VARCHAR2
    );

    PROCEDURE sp_cierre (
        pin_id_cia   IN   NUMBER,
        pin_numcaja  IN   NUMBER,
        pin_mensaje  OUT  VARCHAR2
    );

END pack_dcta102_caja_cab;

/

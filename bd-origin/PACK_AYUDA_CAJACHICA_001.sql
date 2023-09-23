--------------------------------------------------------
--  DDL for Package PACK_AYUDA_CAJACHICA_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_AYUDA_CAJACHICA_001" AS
    TYPE librodatarecord IS RECORD (
        codlib   VARCHAR2(3),
        descri   VARCHAR2(50),
        motivo   NUMBER(38)
    );
    TYPE librodatatable IS
        TABLE OF librodatarecord;
    FUNCTION hlp_libros_cajachica (
        pin_id_cia IN NUMBER
    ) RETURN librodatatable
        PIPELINED;
/***********AYUDA PERSONAL*************/

    TYPE personaldatarecord IS RECORD (
        codper    VARCHAR2(20),
        nombres   VARCHAR2(80)
    );
    TYPE personaldatatable IS
        TABLE OF personaldatarecord;
    FUNCTION hlp_personal_cajachica (
        pin_id_cia IN NUMBER
    ) RETURN personaldatatable
        PIPELINED;

/***********AYUDA CUENTA DE PAGO*************/

    TYPE cuentapagodatarecord IS RECORD (
        cuenta   VARCHAR2(16),
        nombre   VARCHAR2(160)
    );
    TYPE cuentapagodatatable IS
        TABLE OF cuentapagodatarecord;
    FUNCTION hlp_cuenta_de_pago_cajachica (
        pin_id_cia IN NUMBER
    ) RETURN cuentapagodatatable
        PIPELINED;

/***********AYUDA CENTRO DE COSTO*************/

    TYPE centrocostodatarecord IS RECORD (
        codigo   VARCHAR2(16),
        descri   VARCHAR2(50)
    );
    TYPE centrocostodatatable IS
        TABLE OF centrocostodatarecord;
    FUNCTION hlp_centro_de_costo_cajachica (
        pin_id_cia IN NUMBER
    ) RETURN centrocostodatatable
        PIPELINED;        

        /***********AYUDA TIPO DE PAGO*************/

    TYPE tipopagodatarecord IS RECORD (
        codigo   NUMBER(38),
        descri   VARCHAR2(50)
    );
    TYPE tipopagodatatable IS
        TABLE OF tipopagodatarecord;
    FUNCTION hlp_tipo_de_pago_cajachica (
        pin_id_cia IN NUMBER
    ) RETURN tipopagodatatable
        PIPELINED;        

/*********** NUMERO DE CAJA**************/

    TYPE numerocajadatarecord IS RECORD (
        tipo     NUMBER(38),
        docume   NUMBER(38),
        girara   VARCHAR2(70)
    );
    TYPE numerocajadatatable IS
        TABLE OF numerocajadatarecord;
    FUNCTION hlp_numero_caja_cajachica (
        pin_id_cia    IN   NUMBER,
        pin_coduser   IN   VARCHAR2,
        pin_tipo      IN   NUMBER,
        pin_periodo   IN   NUMBER,
        pin_mes       IN   NUMBER
    ) RETURN numerocajadatatable
        PIPELINED;

END;

/

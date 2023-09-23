--------------------------------------------------------
--  DDL for Package XHLP001
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE "USR_TSI_SUITE"."XHLP001" AUTHID current_user IS
    
    TYPE datarecord IS RECORD (
        codigo       NUMBER,
        descripcion  VARCHAR2(80)
    );

    TYPE datatable IS
        TABLE OF datarecord;

    FUNCTION clasestbancos RETURN datatable
        PIPELINED;

    FUNCTION bancos RETURN datatable
        PIPELINED;


END xhlp001;

/

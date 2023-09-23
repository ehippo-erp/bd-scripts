--------------------------------------------------------
--  DDL for Package PACK_HR_FUNCION_CONTABLE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_HR_FUNCION_CONTABLE" AS
    TYPE record_gratxclase IS RECORD (
        id_cia NUMBER,
        numpla NUMBER,
        codper VARCHAR(20),
        valcon NUMERIC(15, 4),
        valdes NUMERIC(15, 4),
        valing NUMERIC(15, 4),
        valbon NUMERIC(15, 4),
        cuenta VARCHAR(16),
        nomcta VARCHAR(40)
    );
    TYPE dt_gratxclase IS
        TABLE OF record_gratxclase;
    FUNCTION sp_buscar_gratxclase (
        pin_id_cia NUMBER,
        pin_anopla NUMBER,
        pin_mespla NUMBER,
        pin_tiptra VARCHAR2
    ) RETURN dt_gratxclase
        PIPELINED;

    TYPE record_vacaxclase IS RECORD (
        id_cia NUMBER,
        numpla NUMBER,
        codper VARCHAR(20),
        dias   SMALLINT,
        valcon NUMERIC(15, 4),
        valren NUMERIC(15, 4),
        valdes NUMERIC(15, 4),
        valing NUMERIC(15, 4),
        valafp NUMERIC(15, 4),
        porafp NUMERIC(15, 4),
        cuenta VARCHAR(16),
        nomcta VARCHAR(40)
    );
    TYPE dt_vacaxclase IS
        TABLE OF record_vacaxclase;
    FUNCTION sp_buscar_vacaxclase (
        pin_id_cia NUMBER,
        pin_anopla NUMBER,
        pin_mespla NUMBER,
        pin_tiptra VARCHAR2
    ) RETURN dt_vacaxclase
        PIPELINED;

    TYPE datarecord_concepto_gasto IS RECORD (
        codper VARCHAR2(20),
        codcon VARCHAR2(5),
        nomcon VARCHAR2(100),
        totcon NUMERIC(15, 4),
        cuenta VARCHAR2(15),
        dh     VARCHAR2(1)
    );
    TYPE datatable_concepto_gasto IS
        TABLE OF datarecord_concepto_gasto;
    FUNCTION sp_concepto_gasto (
        pin_id_cia NUMBER,
        pin_anopla INTEGER,
        pin_mespla INTEGER,
        pin_tiptra VARCHAR2,
        pin_opc    INTEGER
    ) RETURN datatable_concepto_gasto
        PIPELINED;

END;

/

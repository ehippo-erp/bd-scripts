--------------------------------------------------------
--  DDL for Package PACK_EXCELDINAMICO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_EXCELDINAMICO" AS
    TYPE datarecord_exceldinamico IS RECORD (
        id_cia    exceldinamico.id_cia%TYPE,
        codigo    exceldinamico.codigo%TYPE,
        descri    exceldinamico.descri%TYPE,
        cadsql    exceldinamico_generico.cadsql%TYPE,
        observ    exceldinamico.observ%TYPE,
        nlibro    exceldinamico.nlibro%TYPE,
        codmod    exceldinamico_generico.codmod%TYPE,
        tipbd     exceldinamico.tipbd%TYPE,
        params    exceldinamico.params%TYPE,
        swtabd    exceldinamico.swtabd%TYPE,
        swsistema exceldinamico.swsistema%TYPE
    );
    TYPE datatable_exceldinamico IS
        TABLE OF datarecord_exceldinamico;

--    SELECT * FROM pack_exceldinamico.sp_buscar(56,'CLIENTE',null);

    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_codexc NUMBER
    ) RETURN datatable_exceldinamico
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia    NUMBER,
        pin_codmod    NUMBER,
        pin_desexc    VARCHAR2,
        pin_coduser   VARCHAR2,
        pin_swsistema VARCHAR2
    ) RETURN datatable_exceldinamico
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_cadsql  IN VARCHAR2,
        pin_observ  IN VARCHAR2,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/

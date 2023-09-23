--------------------------------------------------------
--  DDL for Package PACK_HR_CONCEPTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_HR_CONCEPTO" AS
    TYPE datarecord_concepto IS RECORD (
        id_cia      concepto.id_cia%TYPE,
        codcon      concepto.codcon%TYPE,
        empobr      concepto.empobr%TYPE,
        ingdes      concepto.ingdes%TYPE,
        nombre      concepto.nombre%TYPE,
        abrevi      concepto.abrevi%TYPE,
        fijvar      concepto.fijvar%TYPE,
        codcta      concepto.codcta%TYPE,
        descodcta   pcuentas.nombre%TYPE,
        formul      concepto.formul%TYPE,
        indprc      concepto.indprc%TYPE,
        posimp      concepto.posimp%TYPE,
        indimp      concepto.indimp%TYPE,
        nomimp      concepto.nomimp%TYPE,
        nomcts      concepto.nomcts%TYPE,
        indcts      concepto.indcts%TYPE,
        dh          concepto.dh%TYPE,
        agrupa      concepto.agrupa%TYPE,
        ctagasto    concepto.ctagasto%TYPE,
        desctagasto pcuentas.nombre%TYPE,
        conrel      concepto.conrel%TYPE,
        tipo        concepto.tipo%TYPE,
        nomtipo     concepto.nomtipo%TYPE,
        codpdt      concepto.codpdt%TYPE,
        despdt      conceptos_pdt.descri%TYPE,
        idliq       concepto.idliq%TYPE,
        swacti      concepto.swacti%TYPE,
        ucreac      concepto.ucreac%TYPE,
        uactua      concepto.uactua%TYPE,
        fcreac      concepto.fcreac%TYPE,
        factua      concepto.factua%TYPE
    );
    TYPE datatable_concepto IS
        TABLE OF datarecord_concepto;
    TYPE datarecord_list_conceptos IS RECORD (
        id_cia concepto.id_cia%TYPE,
        codcon concepto.codcon%TYPE,
        nombre concepto.nombre%TYPE
    );
    TYPE datatable_list_conceptos IS
        TABLE OF datarecord_list_conceptos;
    TYPE datarecord_ingdes IS RECORD (
        id_cia  NUMBER,
        ingdes  VARCHAR2(1),
        dingdes VARCHAR2(100 CHAR)
    );
    TYPE datatable_ingdes IS
        TABLE OF datarecord_ingdes;
    TYPE datarecord_fijvar IS RECORD (
        id_cia  NUMBER,
        fijvar  VARCHAR2(1),
        dfijvar VARCHAR2(100 CHAR)
    );
    TYPE datatable_fijvar IS
        TABLE OF datarecord_fijvar;
    TYPE datarecord_idliq IS RECORD (
        id_cia NUMBER,
        idliq  VARCHAR2(1),
        didliq VARCHAR2(100 CHAR)
    );
    TYPE datatable_idliq IS
        TABLE OF datarecord_idliq;
    FUNCTION sp_buscar_ingdes (
        pin_id_cia NUMBER
    ) RETURN datatable_ingdes
        PIPELINED;

    FUNCTION sp_buscar_fijvar (
        pin_id_cia NUMBER
    ) RETURN datatable_fijvar
        PIPELINED;

    FUNCTION sp_buscar_idliq (
        pin_id_cia NUMBER
    ) RETURN datatable_idliq
        PIPELINED;

--    SELECT * FROM pack_hr_concepto.sp_buscar_ingdes(66);
--    
--    SELECT * FROM pack_hr_concepto.sp_buscar_fijvar(66);
--    
--    SELECT * FROM pack_hr_concepto.sp_buscar_idliq(66);

    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_codcon VARCHAR2
    ) RETURN datatable_concepto
        PIPELINED;

    FUNCTION sp_list_conceptos (
        pin_id_cia NUMBER,
        pin_empobr VARCHAR2
    ) RETURN datatable_list_conceptos
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_empobr VARCHAR2,
        pin_tippla VARCHAR2,
        pin_ingdes VARCHAR2,
        pin_indimp VARCHAR2,
        pin_dh     VARCHAR2,
        pin_fijvar VARCHAR2,
        pin_idliq  VARCHAR2,
        pin_agrupa VARCHAR2
    ) RETURN datatable_concepto
        PIPELINED;

    FUNCTION sp_buscar_nombre (
        pin_id_cia NUMBER,
        pin_nombre IN VARCHAR2
    ) RETURN datatable_concepto
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_formula IN VARCHAR2,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/

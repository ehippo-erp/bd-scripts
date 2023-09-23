--------------------------------------------------------
--  DDL for Package PACK_TBANCOS_CHEQUES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_TBANCOS_CHEQUES" AS
    TYPE datarecord_tbancos_cheques IS RECORD (
        id_cia  tbancos_cheques.id_cia%TYPE,
        codban  tbancos_cheques.codban%TYPE,
        desban  tbancos.descri%TYPE,
        serie   tbancos_cheques.serie%TYPE,
        correl  tbancos_cheques.correl%TYPE,
        desche  tbancos_cheques.descri%TYPE,
        periodo tbancos_cheques.periodo%TYPE,
        mes     tbancos_cheques.mes%TYPE,
        libro   tbancos_cheques.libro%TYPE,
        asiento tbancos_cheques.asiento%TYPE,
        situac  tbancos_cheques.situac%TYPE,
        dessituac VARCHAR2(100),
        ucreac  tbancos_cheques.ucreac%TYPE,
        uactua  tbancos_cheques.uactua%TYPE,
        fcreac  tbancos_cheques.factua%TYPE,
        factua  tbancos_cheques.factua%TYPE
    );
    TYPE datatable_tbancos_cheques IS
        TABLE OF datarecord_tbancos_cheques;

--    FUNCTION sp_obtener (
--        pin_id_cia NUMBER,
--        pin_codban NUMBER,
--        pin_serie  VARCHAR2
--    ) RETURN datatable_tbancos_cheques
--        PIPELINED;
--
--    FUNCTION sp_obtener_detalle (
--        pin_id_cia NUMBER,
--        pin_codban NUMBER,
--        pin_serie  VARCHAR2,
--        pin_correl NUMBER
--    ) RETURN datatable_tbancos_cheques
--        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_codban VARCHAR2,
        pin_serie  VARCHAR2
    ) RETURN datatable_tbancos_cheques
        PIPELINED;

    FUNCTION sp_buscar_detalle (
        pin_id_cia NUMBER,
        pin_codban VARCHAR2,
        pin_serie  VARCHAR2,
        pin_correl NUMBER
    ) RETURN datatable_tbancos_cheques
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

    PROCEDURE sp_save_detalle (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/

--------------------------------------------------------
--  DDL for Package PACK_HR_TIPOPLANILLA_CONCEPTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_HR_TIPOPLANILLA_CONCEPTO" AS
    TYPE datarecord_tipoplanilla_concepto IS RECORD (
        id_cia    tipoplanilla_concepto.id_cia%TYPE,
        tippla    tipoplanilla_concepto.tippla%TYPE,
        codcon    tipoplanilla_concepto.codcon%TYPE,
        destippla tipoplanilla.nombre%TYPE,
        ucreac    tipoplanilla_concepto.ucreac%TYPE,
        uactua    tipoplanilla_concepto.uactua%TYPE,
        fcreac    tipoplanilla_concepto.fcreac%TYPE,
        factua    tipoplanilla_concepto.factua%TYPE
    );
    TYPE datatable_tipoplanilla_concepto IS
        TABLE OF datarecord_tipoplanilla_concepto;
    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_tippla VARCHAR2,
        pin_codcon VARCHAR2
    ) RETURN datatable_tipoplanilla_concepto
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_tippla VARCHAR2,
        pin_codcon VARCHAR2
    ) RETURN datatable_tipoplanilla_concepto
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/

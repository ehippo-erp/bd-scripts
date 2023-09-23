--------------------------------------------------------
--  DDL for Package PACK_HR_PRESTAMO_TIPOPLANILLA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_HR_PRESTAMO_TIPOPLANILLA" AS

    TYPE datarecord_prestamo_tipoplanilla IS RECORD(
        id_cia prestamo_tipoplanilla.id_cia%TYPE,
        id_pre prestamo_tipoplanilla.id_pre%TYPE,
        tippla prestamo_tipoplanilla.tippla%TYPE,
        destippla tipoplanilla.nombre%TYPE,
        ucreac prestamo_tipoplanilla.ucreac%TYPE,
        uactua prestamo_tipoplanilla.uactua%TYPE,
        fcreac prestamo_tipoplanilla.fcreac%TYPE,
        factua prestamo_tipoplanilla.factua%TYPE
    );
    TYPE datatable_prestamo_tipoplanilla IS
        TABLE OF datarecord_prestamo_tipoplanilla;

    FUNCTION sp_obtener(
        pin_id_cia NUMBER,
        pin_id_pre NUMBER,
        pin_tippla VARCHAR2
    ) RETURN datatable_prestamo_tipoplanilla
        PIPELINED;

    FUNCTION sp_buscar(
        pin_id_cia NUMBER,
        pin_id_pre NUMBER
    ) RETURN datatable_prestamo_tipoplanilla
        PIPELINED;

        PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/

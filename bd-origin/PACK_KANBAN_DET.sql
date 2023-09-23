--------------------------------------------------------
--  DDL for Package PACK_KANBAN_DET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_KANBAN_DET" AS
    TYPE datarecord_kanban_det IS RECORD (
        id_cia    kanban_det.id_cia%TYPE,
        codkan    kanban_det.codkan%TYPE,
        deskan  kanban_cab.descri%TYPE,
        tipinv    kanban_det.tipinv%TYPE,
        dtipinv   t_inventario.dtipinv%TYPE,
        codalm    kanban_cab.codalm%TYPE,
        desalm    almacen.descri%TYPE,
        codart    kanban_det.codart%TYPE,
        desart    articulos.descri%TYPE,
        cantid    tipoitem.nombre%TYPE,
        cantidmin kanban_det.cantidmin%TYPE,
        cantidmax kanban_det.cantidmax%TYPE,
        swacti    kanban_det.swacti%TYPE,
        ucreac    kanban_det.ucreac%TYPE,
        uactua    kanban_det.uactua%TYPE,
        fcreac    kanban_det.factua%TYPE,
        factua    kanban_det.factua%TYPE
    );
    TYPE datatable_kanban_det IS
        TABLE OF datarecord_kanban_det;
    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_codkan VARCHAR2,
        pin_tipinv NUMBER,
        pin_codalm NUMBER,
        pin_codart VARCHAR2
    ) RETURN datatable_kanban_det
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_codkan VARCHAR2,
        pin_tipinv NUMBER,
        pin_codalm NUMBER,
        pin_codart VARCHAR2,
        pin_swacti VARCHAR2
    ) RETURN datatable_kanban_det
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/

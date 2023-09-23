--------------------------------------------------------
--  DDL for Package PACK_AFP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_AFP" AS
    TYPE afpdatarecord IS RECORD (
        id_cia afp.id_cia%TYPE,
        codafp afp.codafp%TYPE,
        nombre afp.nombre%TYPE,
        codcla afp.codcla%TYPE,
        codcta afp.codcta%TYPE,
        dh     afp.dh%TYPE,
        nomcla clase_codigo_personal.descri%TYPE,
        codigo afp.codigo%TYPE,
        abrevi afp.abrevi%TYPE,
        ucreac afp.ucreac%TYPE,
        uactua afp.uactua%TYPE,
        fcreac afp.fcreac%TYPE,
        factua afp.factua%TYPE
    );
    TYPE afpdatatable IS
        TABLE OF afpdatarecord;
    TYPE t_afp IS
        TABLE OF afp%rowtype;
    FUNCTION sp_buscar (
        pin_id_cia IN NUMBER,
        pin_codafp IN VARCHAR2,
        pin_nombre IN VARCHAR2,
        pin_codcla IN VARCHAR2,
        pin_dh     IN VARCHAR2
    ) RETURN afpdatatable
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/

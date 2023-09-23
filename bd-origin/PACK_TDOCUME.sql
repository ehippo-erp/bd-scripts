--------------------------------------------------------
--  DDL for Package PACK_TDOCUME
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_TDOCUME" AS
    TYPE r_tdocume IS RECORD (
        id_cia           tdocume.id_cia%TYPE,
        codigo           tdocume.codigo%TYPE,
        descri           tdocume.descri%TYPE,
        abrevi           tdocume.abrevi%TYPE,
        dh               tdocume.dh%TYPE,
        factor           tdocume.factor%TYPE,
        cdocum           tdocume.cdocum%TYPE,
        clibro           tdocume.clibro%TYPE,
        rinfadi          tdocume.rinfadi%TYPE,
        signo            tdocume.signo%TYPE,
        situac           tdocume.situac%TYPE,
        usuari           tdocume.usuari%TYPE,
        salectas         tdocume.salectas%TYPE,
        ctagascolregcom  tdocume.ctagascolregcom%TYPE,
        valor            tdocume.valor%TYPE,
        swchkcompr010    tdocume.swchkcompr010%TYPE,
        fcreac           tdocume.fcreac%TYPE,
        factua           tdocume.factua%TYPE,
        deslibro         tlibro.descri%TYPE
    );
    TYPE t_tdocume IS
        TABLE OF r_tdocume;
    FUNCTION sp_sel_tdocume (
        pin_id_cia IN NUMBER
    ) RETURN t_tdocume
        PIPELINED;

    PROCEDURE sp_savetdocume (
        pin_id_cia   IN   NUMBER,
        pin_datos    IN   VARCHAR2,
        pin_opcdml   INTEGER,
        pin_mensaje  OUT  VARCHAR2
    );

END;

/

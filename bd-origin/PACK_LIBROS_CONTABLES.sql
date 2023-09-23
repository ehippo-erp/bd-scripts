--------------------------------------------------------
--  DDL for Package PACK_LIBROS_CONTABLES
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_LIBROS_CONTABLES" AS
    TYPE r_libros_contables IS RECORD (
        id_cia    tlibro.id_cia%TYPE,
        codlib    tlibro.codlib%TYPE,
        descri    tlibro.descri%TYPE,
        moneda01  tlibro.moneda01%TYPE,
        moneda02  tlibro.moneda02%TYPE,
        destino   tlibro.destino%TYPE,
        abrevi    tlibro.abrevi%TYPE,
        usuari    tlibro.usuario%TYPE,
        swacti    tlibro.swacti%TYPE,
        fcreac    tlibro.fcreac%TYPE,
        factua    tlibro.factua%TYPE,
        filtro    tlibro.filtro%TYPE,
        motivo    tlibro.motivo%TYPE
    );
    TYPE t_libros_contables IS
        TABLE OF r_libros_contables;

    TYPE r_libros_contables_planillas IS RECORD (
        id_cia    tlibro.id_cia%TYPE,
        codlib    tlibro.codlib%TYPE,
        descri    tlibro.descri%TYPE,
        moneda01  tlibro.moneda01%TYPE,
        moneda02  tlibro.moneda02%TYPE,
        destino   tlibro.destino%TYPE,
        abrevi    tlibro.abrevi%TYPE,
        usuari    tlibro.usuario%TYPE,
        swacti    tlibro.swacti%TYPE,
        fcreac    tlibro.fcreac%TYPE,
        factua    tlibro.factua%TYPE,
        filtro    tlibro.filtro%TYPE,
        motivo    tlibro.motivo%TYPE
    );
    TYPE t_libros_contables_planillas IS
        TABLE OF r_libros_contables_planillas;

    FUNCTION sp_sel_libros_contables (
        pin_id_cia IN NUMBER
    ) RETURN t_libros_contables
        PIPELINED;

    FUNCTION sp_sel_libros_contables_planillas (
        pin_id_cia IN NUMBER,
        pin_clase IN NUMBER
    ) RETURN t_libros_contables_planillas
        PIPELINED;

    PROCEDURE sp_save_tlibro (
        pin_id_cia   IN   NUMBER,
        pin_datos    IN   VARCHAR2,
        pin_opcdml   INTEGER,
        pin_mensaje  OUT  VARCHAR2
    );

    TYPE t_libros IS
        TABLE OF libros%rowtype;
    FUNCTION sp_sel_libros (
        pin_id_cia  IN  NUMBER,
        pin_codlib  IN  VARCHAR2,
        pin_anio    IN  NUMBER
    ) RETURN t_libros
        PIPELINED;

    PROCEDURE sp_save_libros (
        pin_id_cia   IN   NUMBER,
        pin_datos    IN   VARCHAR2,
        pin_opcdml   INTEGER,
        pin_mensaje  OUT  VARCHAR2
    );

    PROCEDURE sp_crea_libros_anual (
        pin_id_cia   IN  NUMBER,
        pin_periodo  IN  NUMBER
    );

END;

/

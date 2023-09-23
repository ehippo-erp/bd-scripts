--------------------------------------------------------
--  DDL for Package PACK_HR_PRESTAMO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_HR_PRESTAMO" AS
    TYPE datarecord_prestamo IS RECORD (
        id_cia    prestamo.id_cia%TYPE,
        id_pre    prestamo.id_pre%TYPE,
        codper    prestamo.codper%TYPE,
        nomper    VARCHAR2(500),
        fecpre    prestamo.fecpre%TYPE,
        monpre    prestamo.monpre%TYPE,
        monpag    prestamo.monpag%TYPE,
        codmon    prestamo.codmon%TYPE,
        cancuo    prestamo.cancuo%TYPE,
        valcuo    prestamo.valcuo%TYPE,
        salpre    prestamo.salpre%TYPE,
        observ    prestamo.observ%TYPE,
        modifi    prestamo.modifi%TYPE,
        situac    prestamo.situac%TYPE,
        ucreac    prestamo.ucreac%TYPE,
        uactua    prestamo.uactua%TYPE,
        fcreac    prestamo.factua%TYPE,
        factua    prestamo.factua%TYPE,
        nomucreac usuarios.nombres%TYPE,
        nomuactua usuarios.nombres%TYPE
    );
    TYPE datatable_prestamo IS
        TABLE OF datarecord_prestamo;
    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_id_pre NUMBER
    ) RETURN datatable_prestamo
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_tiptra VARCHAR2,
        pin_codper VARCHAR2,
        pin_codmon VARCHAR2,
        pin_mdesde NUMBER,
        pin_mhasta NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_prestamo
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/

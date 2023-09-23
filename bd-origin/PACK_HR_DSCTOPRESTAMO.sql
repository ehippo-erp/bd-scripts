--------------------------------------------------------
--  DDL for Package PACK_HR_DSCTOPRESTAMO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_HR_DSCTOPRESTAMO" AS
    TYPE datarecord_buscar IS RECORD (
        id_cia      dsctoprestamo.id_cia%TYPE,
        id_pre      dsctoprestamo.id_pre%TYPE,
        numpla      dsctoprestamo.numpla%TYPE,
        codper      prestamo.codper%TYPE,
        fecdes      dsctoprestamo.fecdes%TYPE,
        valcuo      dsctoprestamo.valcuo%TYPE,
        aplica      dsctoprestamo.aplica%TYPE,
        desaplica   VARCHAR2(100 CHAR),
        observ      dsctoprestamo.observ%TYPE,
        id_planilla VARCHAR2(500),
        tippla      planilla.tippla%TYPE,
        empobr      planilla.empobr%TYPE,
        anopla      planilla.anopla%TYPE,
        mespla      planilla.mespla%TYPE,
        sempla      planilla.sempla%TYPE,
        situac      planilla.situac%TYPE,
        nomper      VARCHAR2(500),
        fecpre      prestamo.fecpre%TYPE,
        monpre      prestamo.monpre%TYPE,
        monpag      prestamo.monpag%TYPE,
        codmon      prestamo.codmon%TYPE,
        cancuo      prestamo.cancuo%TYPE,
        valcup      prestamo.valcuo%TYPE,
        salpre      prestamo.salpre%TYPE,
        ucreac      prestamo.ucreac%TYPE,
        uactua      prestamo.uactua%TYPE,
        fcreac      prestamo.fcreac%TYPE,
        factua      prestamo.factua%TYPE,
        nomucreac   usuarios.nombres%TYPE,
        nomuactua   usuarios.nombres%TYPE
    );
    TYPE datatable_buscar IS
        TABLE OF datarecord_buscar;
    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_id_pre NUMBER,
        pin_numpla NUMBER,
        pin_codper VARCHAR2
    ) RETURN datatable_buscar
        PIPELINED;

    PROCEDURE sp_registrar (
        pin_id_cia  IN NUMBER,
        pin_numpla  IN NUMBER,
        pin_id_pre  IN NUMBER,
        pin_codper  IN VARCHAR2,
        pin_fdesde  IN DATE,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/

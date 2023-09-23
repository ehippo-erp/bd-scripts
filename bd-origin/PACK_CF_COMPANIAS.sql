--------------------------------------------------------
--  DDL for Package PACK_CF_COMPANIAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_CF_COMPANIAS" AS
    TYPE datarecord_companias IS RECORD (
        cia      NUMBER,
        razsoc   VARCHAR2(100 BYTE),
        nomcom   VARCHAR2(100 BYTE),
        direcc   companias.direcc%TYPE,
        dircom   companias.dircom%TYPE,
        distri   companias.distri%TYPE,
        ruc      companias.ruc%TYPE,
        telefo   companias.telefo%TYPE,
        fax      companias.fax%TYPE,
        email    companias.email%TYPE,
        repres   companias.repres%TYPE,
        codsuc   companias.codsuc%TYPE,
        anno     companias.anno%TYPE,
        mes      companias.mes%TYPE,
        moneda01 companias.moneda01%TYPE,
        moneda02 companias.moneda02%TYPE,
        fcreac   companias.fcreac%TYPE,
        factua   companias.factua%TYPE,
        usuari   companias.usuari%TYPE,
        activo   VARCHAR2(100 CHAR),
        situac   companias.situac%TYPE,
        swflag   companias.swflag%TYPE,
        piepag01 companias.piepag01%TYPE,
        piepag02 companias.piepag01%TYPE,
        piepag03 companias.piepag01%TYPE,
        piepag04 companias.piepag01%TYPE,
        piepag05 companias.piepag01%TYPE,
        nomanio  companias.nomanio%TYPE,
        grupo    companias_grupo.grupo%TYPE,
        usuarios companias.usuarios%TYPE
    );
    TYPE datatable_companias IS
        TABLE OF datarecord_companias;
    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_razonc VARCHAR2
    ) RETURN datatable_companias
        PIPELINED;

END;

/

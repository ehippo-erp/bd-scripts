--------------------------------------------------------
--  DDL for Package PACK_COMPR040
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_COMPR040" AS

    TYPE datarecord_compr040 IS RECORD (
        id_cia  compr040.id_cia%type,
        tipo compr040.tipo%type,
        docume compr040.docume%type,
        femisi compr040.femisi%type,
        codper compr040.codper%type,
        concep compr040.concep%type,
        motivo compr040.motivo%type,
        moneda compr040.moneda%type,
        codarea compr040.codarea%type,
        referen compr040.referen%type,
        ccosto compr040.ccosto%type,
        aprobado compr040.aprobado%type,
        caprob compr040.caprob%type,
        faprob compr040.faprob%type,
        tippago compr040.tippago%type,
        ctapago compr040.ctapago%type,
        situac compr040.situac%type,
        usuari compr040.usuari%type,
        fcreac compr040.fcreac%type,
        factua compr040.factua%type,
        periodo compr040.periodo%type,
        mes compr040.mes%type,
        libro compr040.libro%type,
        asiento compr040.asiento%type,
        librop compr040.librop%type,
        asientop compr040.asientop%type,
        tcambio compr040.tcambio%type,
        fondo compr040.fondo%type,
        personal    cliente.razonc%type,
        librodesc  tlibro.descri%type,
        ccostodesc  tccostos.descri%type,
        ctapagodesc pcuentas.nombre%type,
        tippagodesc m_pago.descri%type,
        nomuser usuarios.nombres%type
    );
    TYPE datatable_compr040 IS
        TABLE OF datarecord_compr040;

    FUNCTION sp_obtener (
        pin_id_cia IN NUMBER,
        pin_tipo   IN NUMBER,
        pin_docume IN NUMBER
    ) RETURN datatable_compr040
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia  IN NUMBER,
        pin_tipo    IN NUMBER,
        pin_docume  IN NUMBER,
        pin_fdesde  IN DATE,
        pin_fhasta  IN DATE,
        pin_codper  IN VARCHAR2,
        pin_moneda  IN VARCHAR2,
        pin_codarea IN NUMBER,
        pin_limit   IN NUMBER,
        pin_offset  IN NUMBER
    ) RETURN datatable_compr040
        PIPELINED;

    -- NO IMPLEMENTADO 
    /*PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    );*/

END;

/

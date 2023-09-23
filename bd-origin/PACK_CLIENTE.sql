--------------------------------------------------------
--  DDL for Package PACK_CLIENTE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_CLIENTE" AS
    TYPE datarecord_clase_codigo IS RECORD (
        tipcli    VARCHAR2(1),
        codcli    VARCHAR2(20),
        clase     NUMBER,
        desclase  VARCHAR2(70),
        codigo    VARCHAR2(20),
        descodigo VARCHAR2(70),
        abrcodigo VARCHAR2(10)
    );
    TYPE datatable_clase_codigo IS
        TABLE OF datarecord_clase_codigo;
    TYPE datarecord_proveedor IS RECORD (
        id_cia    cliente.id_cia%TYPE,
        codcli    cliente.codcli%TYPE,
        tident    cliente.tident%TYPE,
        dident    cliente.dident%TYPE,
        codsec    cliente.codsec%TYPE,
        razonc    cliente.razonc%TYPE,
        codtit    cliente.codtit%TYPE,
        codven    cliente.codven%TYPE,
        codtpe    cliente.codtpe%TYPE,
        codpag    cliente.codpag%TYPE,
        telefono  cliente.telefono%TYPE,
        fax       cliente.fax%TYPE,
        email     cliente.email%TYPE,
        repres    cliente.repres%TYPE,
        situacion cliente_clase.codigo%TYPE,
        relacion  cliente_clase.codigo%TYPE,
        direc1    cliente.direc1%TYPE,
        direc2    cliente.direc2%TYPE,
        codtitcom cliente.codtitcom%TYPE,
        regret    cliente.regret%TYPE,
        ucreac    cliente.usuari%TYPE,
        uactua    cliente.usuari%TYPE,
        factua    cliente.factua%TYPE,
        fcreac    cliente.fcreac%TYPE
    );
    TYPE datatable_proveedor IS
        TABLE OF datarecord_proveedor;
    TYPE datarecord_cliente IS RECORD (
        id_cia          cliente.id_cia%TYPE,
        codcli          cliente.codcli%TYPE,
        tident          cliente.tident%TYPE,
        abrent          identidad.abrevi%TYPE,
        dident          cliente.dident%TYPE,
        codsec          cliente.codsec%TYPE,
        razonc          cliente.razonc%TYPE,
        codtit          cliente.codtit%TYPE,
        codven          cliente.codven%TYPE,
        codtpe          cliente.codtpe%TYPE,
        telefono        cliente.telefono%TYPE,
        fax             cliente.fax%TYPE,
        email           cliente.email%TYPE,
        limcre1         cliente.limcre1%TYPE,
        limcre2         cliente.limcre2%TYPE,
        repres          cliente.repres%TYPE,
        regret          cliente.regret%TYPE,
        direc1          cliente.direc1%TYPE,
        direc2          cliente.direc2%TYPE,
        codpag          cliente.codpag%TYPE,
        observ          cliente.observ%TYPE,
        exoimp          VARCHAR2(10 CHAR),
        clase_01        cliente_clase.codigo%TYPE,
        clase_22        cliente_clase.codigo%TYPE,
        clase_30        cliente_clase.codigo%TYPE,
        clase_32        cliente_clase.codigo%TYPE,
        apellidopaterno cliente_tpersona.apepat%TYPE,
        apeliidomaterno cliente_tpersona.apemat%TYPE,
        nombres         cliente_tpersona.nombre%TYPE,
        nrodni          cliente_tpersona.nrodni%TYPE,
        sexo            cliente_tpersona.sexo%TYPE,
        fecing          cliente.fecing%TYPE,
        valident        VARCHAR2(10 CHAR),
        titulolista     VARCHAR2(500 CHAR),
        ucreac          cliente.usuari%TYPE,
        uactua          cliente.usuari%TYPE,
        factua          cliente.factua%TYPE,
        fcreac          cliente.fcreac%TYPE
    );
    TYPE datatable_cliente IS
        TABLE OF datarecord_cliente;
    FUNCTION sp_buscar_clase_codigo (
        pin_id_cia IN NUMBER,
        pin_tipcli IN VARCHAR2,
        pin_codcli IN VARCHAR2,
        pin_clase  IN NUMBER
    ) RETURN datatable_clase_codigo
        PIPELINED;

    PROCEDURE sp_insert_clases_obligatorias (
        pin_id_cia  IN NUMBER,
        pin_tipcli  IN VARCHAR2,
        pin_codcli  IN VARCHAR2,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    );

    FUNCTION sp_obtener_proveedor (
        pin_id_cia NUMBER,
        pin_codcli VARCHAR2
    ) RETURN datatable_proveedor
        PIPELINED;

    FUNCTION sp_obtener_cliente (
        pin_id_cia NUMBER,
        pin_codcli VARCHAR2
    ) RETURN datatable_cliente
        PIPELINED;

END;

/

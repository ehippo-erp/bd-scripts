--------------------------------------------------------
--  DDL for Package PACK_PCUENTAS
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_PCUENTAS" AS
    TYPE r_pcuentas IS RECORD (
        id_cia      pcuentas.id_cia%TYPE,
        cuenta      pcuentas.cuenta%TYPE,
        nombre      pcuentas.nombre%TYPE,
        tipgas      pcuentas.tipgas%TYPE,
        cpadre      pcuentas.cpadre%TYPE,
        nivel       pcuentas.nivel%TYPE,
        imputa      pcuentas.imputa%TYPE,
        codtana     pcuentas.codtana%TYPE,
        destino     pcuentas.destino%TYPE,
        destid      pcuentas.destid%TYPE,
        destih      pcuentas.destih%TYPE,
        dh          pcuentas.dh%TYPE,
        moneda01    pcuentas.moneda01%TYPE,
        moneda02    pcuentas.moneda02%TYPE,
        ccosto      pcuentas.ccosto%TYPE,
        proyec      pcuentas.proyec%TYPE,
        docori      pcuentas.docori%TYPE,
        tipo        pcuentas.tipo%TYPE,
        refere      pcuentas.refere%TYPE,
        fhabdes     pcuentas.fhabdes%TYPE,
        fhabhas     pcuentas.fhabhas%TYPE,
        balance     pcuentas.balance%TYPE,
        regcomcol   pcuentas.regcomcol%TYPE,
        regvencol   pcuentas.regvencol%TYPE,
        clasif      pcuentas.clasif%TYPE,
        situac      pcuentas.situac%TYPE,
        usuari      pcuentas.usuari%TYPE,
        fcreac      pcuentas.fcreac%TYPE,
        factua      pcuentas.factua%TYPE,
        balancecol  pcuentas.balancecol%TYPE,
        habilitado  pcuentas.habilitado%TYPE,
        concilia    pcuentas.concilia%TYPE
    );
    TYPE t_pcuentas IS
        TABLE OF r_pcuentas;
    FUNCTION sp_sel_pcuentas (
        pin_id_cia IN NUMBER
    ) RETURN t_pcuentas
        PIPELINED;

    PROCEDURE sp_save_pcuentas (
        pin_id_cia   IN   NUMBER,
        pin_datos    IN   VARCHAR2,
        pin_opcdml   INTEGER,
        pin_mensaje  OUT  VARCHAR2
    );

    TYPE r_pcuentas_ccosto IS RECORD (
        id_cia    pcuentas_ccosto.id_cia%TYPE,
        cuenta    pcuentas_ccosto.cuenta%TYPE,
        ccosto    pcuentas_ccosto.ccosto%TYPE,
        desccosto  pcuentas.nombre%TYPE,
        porcen    pcuentas_ccosto.porcen%TYPE
    );
    TYPE t_pcuentas_ccosto IS
        TABLE OF r_pcuentas_ccosto;
    FUNCTION sp_sel_pcuentas_ccosto (
        pin_id_cia  IN  NUMBER,
        pin_cuenta  IN  VARCHAR2
    ) RETURN t_pcuentas_ccosto
        PIPELINED;

    PROCEDURE sp_save_pcuentas_ccosto (
        pin_id_cia   IN   NUMBER,
        pin_datos    IN   VARCHAR2,
        pin_opcdml   INTEGER,
        pin_mensaje  OUT  VARCHAR2
    );

    PROCEDURE sp_cuenta_no_existe(
        pin_id_cia IN NUMBER,
        pin_periodo IN NUMBER,
        pin_mes IN NUMBER,
        pin_libro IN VARCHAR2,
        pin_asiento IN NUMBER,
        pin_cuenta IN OUT VARCHAR2
    );

END;

/

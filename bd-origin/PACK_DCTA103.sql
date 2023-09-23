--------------------------------------------------------
--  DDL for Package PACK_DCTA103
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_DCTA103" AS
    TYPE datarecord_dcta103_rel IS RECORD (
        id_cia      dcta103_rel.id_cia%TYPE,
        libro       dcta103_rel.libro%TYPE,
        periodo     dcta103_rel.periodo%TYPE,
        mes         dcta103_rel.mes%TYPE,
        secuencia   dcta103_rel.secuencia%TYPE,
        item        dcta103_rel.item%TYPE,
        r_libro     dcta103_rel.r_libro%TYPE,
        r_periodo   dcta103_rel.r_periodo%TYPE,
        r_mes       dcta103_rel.r_mes%TYPE,
        r_secuencia dcta103_rel.r_secuencia%TYPE,
        r_item      dcta103_rel.r_item%TYPE,
        ucreac      dcta103_rel.ucreac%TYPE,
        uactua      dcta103_rel.uactua%TYPE,
        fcreac      dcta103_rel.factua%TYPE,
        factua      dcta103_rel.factua%TYPE
    );
    TYPE datatable_dcta103_rel IS
        TABLE OF datarecord_dcta103_rel;
    TYPE datarecord_dcta103_aprobacion IS RECORD (
        id_cia     dcta103_aprobacion.id_cia%TYPE,
        libro      dcta103_aprobacion.libro%TYPE,
        periodo    dcta103_aprobacion.periodo%TYPE,
        mes        dcta103_aprobacion.mes%TYPE,
        secuencia  dcta103_aprobacion.secuencia%TYPE,
        item       dcta103_aprobacion.item%TYPE,
        numint     dcta103_aprobacion.numint%TYPE,
        tipo       dcta103_aprobacion.tipo%TYPE,
        comentario dcta103_aprobacion.comentario%TYPE,
        codopera   dcta103_aprobacion.codopera%TYPE,
        codaprob   dcta103_aprobacion.codaprob%TYPE,
        ventero    dcta103_aprobacion.ventero%TYPE,
        vreal      dcta103_aprobacion.vreal%TYPE,
        vstrg      dcta103_aprobacion.vstrg%TYPE,
        vchar      dcta103_aprobacion.vchar%TYPE,
        vdate      dcta103_aprobacion.vdate%TYPE,
        vtime      dcta103_aprobacion.vtime%TYPE,
        ucreac     dcta103_aprobacion.ucreac%TYPE,
        uactua     dcta103_aprobacion.uactua%TYPE,
        fcreac     dcta103_aprobacion.factua%TYPE,
        factua     dcta103_aprobacion.factua%TYPE
    );
    TYPE datatable_dcta103_aprobacion IS
        TABLE OF datarecord_dcta103_aprobacion;
    TYPE datarecord_planilla_banco IS RECORD (
        id_cia     dcta103_aprobacion.id_cia%TYPE,
        libro      dcta103_aprobacion.libro%TYPE,
        periodo    dcta103_aprobacion.periodo%TYPE,
        mes        dcta103_aprobacion.mes%TYPE,
        secuencia  dcta103_aprobacion.secuencia%TYPE,
        concep     dcta102.concep%TYPE,
        dia        dcta102.dia%TYPE,
        situac     dcta102.situac%TYPE,
        femisi     dcta102.femisi%TYPE,
        referencia dcta102.referencia%TYPE,
        tipoenvio  VARCHAR2(1000)
    );
    TYPE datatable_planilla_banco IS
        TABLE OF datarecord_planilla_banco;
    TYPE datarecord_formato_bcp IS RECORD (
        id_cia      dcta103_aprobacion.id_cia%TYPE,
        codcli      cliente.codcli%TYPE,
        razonc      cliente.razonc%TYPE,
        apepat      cliente_tpersona.apepat%TYPE,
        apemat      cliente_tpersona.apemat%TYPE,
        nombre      cliente_tpersona.nombre%TYPE,
        dident      cliente.dident%TYPE,
        docume      dcta103.docume%TYPE,
        tidentsunat identidad.codsunat%TYPE,
        fvenci      dcta100.fvenci%TYPE,
        amorti      dcta103.amorti%TYPE
    );
    TYPE datatable_formato_bcp IS
        TABLE OF datarecord_formato_bcp;
    FUNCTION sp_obtener_rel (
        pin_id_cia    NUMBER,
        pin_libro     VARCHAR2,
        pin_periodo   NUMBER,
        pin_mes       NUMBER,
        pin_secuencia NUMBER,
        pin_item      NUMBER
    ) RETURN datatable_dcta103_rel
        PIPELINED;

    FUNCTION sp_buscar_rel (
        pin_id_cia    NUMBER,
        pin_libro     VARCHAR2,
        pin_periodo   NUMBER,
        pin_mes       NUMBER,
        pin_secuencia NUMBER,
        pin_item      NUMBER,
        pin_opcrel    NUMBER -- 0 ( Busca por Asiento )  / 1 ( Busca por Relacionado ) 
    ) RETURN datatable_dcta103_rel
        PIPELINED;

    PROCEDURE sp_save_rel (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

    FUNCTION sp_obtener_aprobacion (
        pin_id_cia    NUMBER,
        pin_libro     VARCHAR2,
        pin_periodo   NUMBER,
        pin_mes       NUMBER,
        pin_secuencia NUMBER,
        pin_item      NUMBER,
        pin_numint    NUMBER,
        pin_tipo      NUMBER
    ) RETURN datatable_dcta103_aprobacion
        PIPELINED;

    FUNCTION sp_buscar_aprobacion (
        pin_id_cia    NUMBER,
        pin_libro     VARCHAR2,
        pin_periodo   NUMBER,
        pin_mes       NUMBER,
        pin_secuencia NUMBER,
        pin_item      NUMBER,
        pin_numint    NUMBER,
        pin_tipo      NUMBER
    ) RETURN datatable_dcta103_aprobacion
        PIPELINED;

    PROCEDURE sp_save_aprobacion (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

    FUNCTION sp_planilla_banco (
        pin_id_cia NUMBER,
        pin_tippla NUMBER
    ) RETURN datatable_planilla_banco
        PIPELINED;

    FUNCTION sp_formato_bcp (
        pin_id_cia    NUMBER,
        pin_libro     VARCHAR2,
        pin_periodo   NUMBER,
        pin_mes       NUMBER,
        pin_secuencia NUMBER
    ) RETURN datatable_formato_bcp
        PIPELINED;

END;

/

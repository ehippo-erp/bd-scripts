--------------------------------------------------------
--  DDL for Package PACK_DW_CVENTAS_MENSUAL_VENDEDOR_META
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_DW_CVENTAS_MENSUAL_VENDEDOR_META" AS
    TYPE datarecord_buscar IS RECORD (
        id_cia vendedor_metas.id_cia%TYPE,
        codven     vendedor_metas.codven%TYPE,
        desven     vendedor.desven%TYPE,
        periodo    vendedor_metas.periodo%TYPE,
        idmes      vendedor_metas.mes%TYPE,
        mes        VARCHAR2(100),
        mesid      NUMBER,
        meta01     vendedor_metas.meta01%TYPE,
        meta02     vendedor_metas.meta02%TYPE,
        ucreac     vendedor_metas.ucreac%TYPE,
        uactua     vendedor_metas.uactua%TYPE,
        fcreac     vendedor_metas.fcreac%TYPE,
        factua     vendedor_metas.factua%TYPE
    );
    TYPE datatable_buscar IS
        TABLE OF datarecord_buscar;

        TYPE r_errores IS RECORD (
        valor     VARCHAR2(80),
        deserror  VARCHAR2(250)
    );
    TYPE datatable IS
        TABLE OF r_errores;

    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_codsuc NUMBER,
        pin_codven NUMBER,
        pin_periodo NUMBER,
        pin_idmes NUMBER
    ) RETURN  datatable_buscar
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia  NUMBER,
        pin_codsuc  NUMBER,
        pin_codven  NUMBER,
        pin_periodo NUMBER
    ) RETURN datatable_buscar
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

    PROCEDURE sp_elimina (
        pin_id_cia  IN NUMBER,
        pin_codsuc  IN NUMBER,
        pin_periodo IN NUMBER,
        pin_codven IN NUMBER
    );

    FUNCTION sp_valida_objeto (
        pin_id_cia   NUMBER,
        pin_periodo NUMBER,
        pin_codven NUMBER,
        pin_datos    CLOB
    ) RETURN datatable
        PIPELINED;
END;

/

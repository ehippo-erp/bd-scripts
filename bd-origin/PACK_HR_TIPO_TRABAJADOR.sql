--------------------------------------------------------
--  DDL for Package PACK_HR_TIPO_TRABAJADOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_HR_TIPO_TRABAJADOR" AS
    TYPE datarecord_tipo_trabajador IS RECORD (
        id_cia    tipo_trabajador.id_cia%TYPE,
        tiptra    tipo_trabajador.tiptra%TYPE,
        nombre    tipo_trabajador.nombre%TYPE,
        noper     tipo_trabajador.noper%TYPE,
        conpre    tipo_trabajador.conpre%TYPE,
        cuenta    tipo_trabajador.cuenta%TYPE,
        descuenta pcuentas.nombre%TYPE,
        libro     tipo_trabajador.libro%TYPE,
        conred    tipo_trabajador.conred%TYPE,
        ucreac    tipo_trabajador.ucreac%TYPE,
        uactua    tipo_trabajador.uactua%TYPE,
        fcreac    tipo_trabajador.fcreac%TYPE,
        factua    tipo_trabajador.factua%TYPE
    );
    TYPE datatable_tipo_trabajador IS
        TABLE OF datarecord_tipo_trabajador;
    FUNCTION sp_buscar (
        pin_id_cia IN NUMBER,
        pin_tiptra IN VARCHAR2,
        pin_nombre IN VARCHAR2
    ) RETURN datatable_tipo_trabajador
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END;

/

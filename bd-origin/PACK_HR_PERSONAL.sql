--------------------------------------------------------
--  DDL for Package PACK_HR_PERSONAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_HR_PERSONAL" AS
    TYPE datarecord_personal IS RECORD (
        id_cia    personal.id_cia%TYPE,--
        codper    personal.codper%TYPE,--
        codsunat  personal_clase.codigo%TYPE,
        dessunat  clase_codigo_personal.descri%TYPE,
        apepat    personal.apepat%TYPE,
        apemat    personal.apemat%TYPE,
        nombre    personal.nombre%TYPE,
        nomper    VARCHAR2(500),
        direcc    personal.direcc%TYPE,-- 
        nrotlf    personal.nrotlf%TYPE,--
        sexper    personal.sexper%TYPE,--
        fecnac    personal.fecnac%TYPE,--
        codeci    personal.codeci%TYPE,--
        deseci    estado_civil.deseci%TYPE,
        tiptra    personal.tiptra%TYPE,--
        codnac    personal.codnac%TYPE,
        desnac    nacionalidad.nombre%TYPE,
        codcar    personal.codcar%TYPE,--
        descar    cargo.nombre%TYPE,
        fecing    DATE,
        fecrei    DATE,
        fecces    DATE,
        forpag    personal.forpag%TYPE,--
        codban    personal.codban%TYPE,--
        desban    e_financiera.descri%TYPE,
        tipcta    personal.tipcta%TYPE,
        destipcta e_financiera_tipo.descri%TYPE,
        codmon    personal.codmon%TYPE,
        nrocta    personal.nrocta%TYPE,--
        situac    personal.situac%TYPE,--
        codest    personal.codest%TYPE,--
        desest    estado_personal.nombre%TYPE,
        glonot    personal.glonot%TYPE,--
        codafp    personal.codafp%TYPE,--
        nomafp    afp.nombre%TYPE,
        fotogr    personal.fotogr%TYPE,--
        formato   personal.formato%TYPE,--
        codsuc    personal.codsuc%TYPE,--
        dessuc    sucursal.sucursal%TYPE,
        email     personal.email%TYPE,--
        ucreac    personal.ucreac%TYPE,--
        uactua    personal.uactua%TYPE,--
        fcreac    personal.fcreac%TYPE,--
        factua    personal.factua%TYPE--
    );
    TYPE datatable_personal IS
        TABLE OF datarecord_personal;
    TYPE datarecord_validacion IS RECORD (
        id     INTEGER,
        observ VARCHAR2(1000)
    );
    TYPE datatable_validacion IS
        TABLE OF datarecord_validacion;
    TYPE datarecord_periodolaboral IS RECORD (
        id_cia    personal.id_cia%TYPE,
        codper    personal.codper%TYPE,
        nomper    VARCHAR2(500),
        tiptra    personal.tiptra%TYPE,
        situac    personal.situac%TYPE,
        id_plab personal_periodolaboral.id_plab%TYPE,
        finicio   personal_periodolaboral.finicio%TYPE,
        ffinal    personal_periodolaboral.ffinal%TYPE,
        diatratot NUMBER,
        diatrames NUMBER
    );
    TYPE datatable_periodolaboral IS
        TABLE OF datarecord_periodolaboral;

    -- MUESTRA TODAS LAS VALIDACIONES NO CUMPLIDAS
    FUNCTION sp_validaciones (
        pin_id_cia IN NUMBER,
        pin_codper IN VARCHAR2
    ) RETURN datatable_validacion
        PIPELINED;

    -- ACTUALIZA SITUACION A '04', SI NO TIENE TODAS LAS VALIDACIONES CUMPLIDAS
    PROCEDURE sp_update_situacion_validacion (
        pin_id_cia IN NUMBER,
        pin_codper IN VARCHAR2
    );

    FUNCTION sp_periodolaboral (
        pin_id_cia NUMBER,
        pin_tiptra VARCHAR2,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_periodolaboral
        PIPELINED;

    FUNCTION sp_ultimo_ingreso (
        pin_id_cia IN NUMBER,
        pin_codper IN VARCHAR2
    ) RETURN NUMBER;

    FUNCTION sp_obtener (
        pin_id_cia IN NUMBER,
        pin_codper IN VARCHAR2
    ) RETURN datatable_personal
        PIPELINED;

    FUNCTION sp_buscar_nombre (
        pin_id_cia IN NUMBER,
        pin_nombre IN VARCHAR2
    ) RETURN datatable_personal
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia   NUMBER,-- Compania
        pin_situac   VARCHAR2,-- Situacion
        pin_codeci   VARCHAR2,-- Estado Civil
        pin_tiptra   VARCHAR2,-- Tipo Trabajador
        pin_codcar   IN VARCHAR2,-- Cargo
        pin_forpag   VARCHAR2,-- Forma de Pago
        pin_codnac   VARCHAR2,-- Nacionalidad
        pin_codest   VARCHAR2, -- Estado
        pin_codafp   VARCHAR2,-- Regimen Pensionario
        pin_codsuc   NUMBER, -- Sucursal
        pin_codban   NUMBER, -- Codigo de Banco
        pin_codigo   VARCHAR2, -- Codigo de Clase - 18 Sunat 
        pin_criterio NUMBER, -- Selecciona el Criterio de Busqueda de Fecha
        pin_fdesde   DATE,
        pin_fhasta   DATE
    ) RETURN datatable_personal
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_codigo  IN VARCHAR2,
        pin_imagen  IN BLOB,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

    PROCEDURE sp_save_img (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_imagen  IN BLOB,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

END pack_hr_personal;

/

--------------------------------------------------------
--  DDL for Package PACK_HR_PLANILLA_BOLETA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_HR_PLANILLA_BOLETA" AS
    TYPE datarecord_buscar IS RECORD (
        id_cia         NUMBER,
        nrocop         NUMBER,
        nomcom         VARCHAR(200),
        nroruc         VARCHAR(20),
        nomdep         VARCHAR(40),
        nompro         VARCHAR(40),
        nomdis         VARCHAR(40),
        direcc         VARCHAR(200),
        anopla         SMALLINT,
        mespla         SMALLINT,
        desmespla      VARCHAR2(100),
        tippla         VARCHAR(1),
        destippla      tipoplanilla.nombre%TYPE,
        empobr         VARCHAR(1),
        desempobr      tipo_trabajador.nombre%TYPE,
        fecini         TIMESTAMP,
        fecfin         TIMESTAMP,
        codper         personal.codper%TYPE,
        nomper         VARCHAR2(500 CHAR),
        numdni         personal_documento.nrodoc%TYPE,
        nomcco         VARCHAR(40), -- DESCRIPCION TCCOSTO
        nomcar         cargo.nombre%TYPE,
        fecing         TIMESTAMP,
        fecces         TIMESTAMP,
        carips         personal_documento.nrodoc%TYPE,
        nomafp         VARCHAR(80),
        carafp         personal_documento.nrodoc%TYPE,
        ingdes         VARCHAR(1), -- INGREOS DESCUENTO APORTACION
        dingdes        VARCHAR2(100),
        codcon         concepto.codcon%TYPE,
        abrcon         concepto.abrevi%TYPE,
        descon         concepto.nombre%TYPE,
        valcon         NUMERIC(15, 4),
        salpre         NUMERIC(15, 4), -- SALDO PRESTAMO
        conrel         VARCHAR(5), --CONCEPTO RELACIONADOS* 9 TIPO DE TRABAJADOR CONREL
        rotdiaslab     VARCHAR2(60),
        diaslab        VARCHAR2(60),
        rotdiasnolab   VARCHAR2(60),
        diasnolab      VARCHAR2(60),
        rotdiassub     VARCHAR2(60),
        diassub        VARCHAR2(60),
        rothordinarias VARCHAR2(60),
        hordinarias    VARCHAR2(60),
        rottardanzas   VARCHAR2(60),
        tardanzas      VARCHAR2(60),
        suelba         NUMERIC(15, 4),
        codafp         VARCHAR(4),
        porfac         NUMERIC(15, 4), -- % FACTOR 18% 
        porafp         NUMERIC(15, 4), -- % ESSALUD
        nomsba         VARCHAR(1000 CHAR), -- CONCEPTO NOMBRE
        nomeps         VARCHAR(1000 CHAR), -- CLASE / PERSONAL
        perconf        VARCHAR(25) --NUMERO DOCUMENTO
    );
    TYPE datatable_buscar IS
        TABLE OF datarecord_buscar;
    TYPE datarecord_buscar_cts IS RECORD (
        id_cia    NUMBER,
        nrocop    NUMBER,
        nomcom    VARCHAR(80),
        nroruc    VARCHAR(11),
        nomdep    VARCHAR(40),
        nompro    VARCHAR(40),
        nomdis    VARCHAR(40),
        direcc    VARCHAR(80),
        anopla    SMALLINT,
        mespla    SMALLINT,
        desmespla VARCHAR2(100),
        tippla    VARCHAR(1),
        destippla tipoplanilla.nombre%TYPE,
        empobr    VARCHAR(1),
        desempobr tipo_trabajador.nombre%TYPE,
        fecini    TIMESTAMP,
        fecfin    TIMESTAMP,
        codper    personal.codper%TYPE,
        nomper    VARCHAR2(500 CHAR),
        numdni    VARCHAR(25), -- DNI PERSONAL_DOCUMENTOS
        nomcco    VARCHAR(40), -- DESCRIPCION TCCOSTO
        nomcar    VARCHAR(40), -- CARGO
        fecing    TIMESTAMP,
        fecces    TIMESTAMP,
        carips    VARCHAR(20), -- CARNET DE SEGURO
        nomafp    VARCHAR(80),
        carafp    VARCHAR(20), -- CARNET DE AFP - USS
        idliq     VARCHAR(1),
        didliq    VARCHAR2(100),
        codcon    concepto.codcon%TYPE,
        abrcon    concepto.abrevi%TYPE,
        descon    concepto.nombre%TYPE,
        valcon    NUMERIC(15, 4),
        salpre    NUMERIC(15, 4), -- SALDO PRESTAMO
        conrel    VARCHAR(3), --CONCEPTO RELACIONADOS* 9 TIPO DE TRABAJADOR CONREL
        mescts    NUMBER(16, 2),
        diacts    NUMBER(16, 2),
        totcts    NUMBER(16, 2),
        codban    tbancos.codban%TYPE,
        desban    tbancos.descri%TYPE,
        tipmon    tbancos.moneda%TYPE,
        tipcam    NUMBER(16, 2),
        simmon    tmoneda.simbolo%TYPE,
        cuenta    personal_cts.cuenta%TYPE,
        deposito  NUMBER(16, 2),
        suelba    NUMERIC(15, 4),
        codafp    VARCHAR(4),
        porfac    NUMERIC(15, 4), -- % FACTOR 18% 
        porafp    NUMERIC(15, 4), -- % ESSALUD
        nomsba    VARCHAR(1000 CHAR), -- CONCEPTO NOMBRE
        nomeps    VARCHAR(1000 CHAR), -- CLASE / PERSONAL
        perconf   VARCHAR(25) --NUMERO DOCUMENTO
    );
    TYPE datatable_buscar_cts IS
        TABLE OF datarecord_buscar_cts;
    TYPE datarecord_buscar_liq IS RECORD (
        id_cia    NUMBER,
        nrocop    NUMBER,
        nomcom    VARCHAR(80),
        nroruc    VARCHAR(11),
        nomdep    VARCHAR(40),
        nompro    VARCHAR(40),
        nomdis    VARCHAR(40),
        direcc    VARCHAR(80),
        anopla    SMALLINT,
        mespla    SMALLINT,
        desmespla VARCHAR2(100),
        tippla    VARCHAR(1),
        destippla tipoplanilla.nombre%TYPE,
        empobr    VARCHAR(1),
        desempobr tipo_trabajador.nombre%TYPE,
        fecini    TIMESTAMP,
        fecfin    TIMESTAMP,
        codper    personal.codper%TYPE,
        nomper    VARCHAR2(500 CHAR),
        apepat    personal.apepat%TYPE,
        apemat    personal.apemat%TYPE,
        nombre    personal.nombre%TYPE,
        numdni    VARCHAR(25), -- DNI PERSONAL_DOCUMENTOS
        nomcco    VARCHAR(40), -- DESCRIPCION TCCOSTO
        nomcar    VARCHAR(40), -- CARGO
        fecing    TIMESTAMP,
        fecces    TIMESTAMP,
        carips    VARCHAR(20), -- CARNET DE SEGURO
        nomafp    VARCHAR(80),
        carafp    VARCHAR(20), -- CARNET DE AFP - USS
        idliq     VARCHAR(1),
        didliq    VARCHAR2(100),
        codcon    concepto.codcon%TYPE,
        abrcon    concepto.abrevi%TYPE,
        descon    concepto.nombre%TYPE,
        valcon    NUMERIC(15, 4),
        salpre    NUMERIC(15, 4), -- SALDO PRESTAMO
        conrel    VARCHAR(3), --CONCEPTO RELACIONADOS* 9 TIPO DE TRABAJADOR CONREL
        perliq    NUMBER(16, 2),
        mesliq    NUMBER(16, 2),
        dialiq    NUMBER(16, 2),
        totliq    NUMBER(16, 2),
        codmot    motivo_planilla.codmot%TYPE,
        desmot    motivo_planilla.descri%TYPE,
        deposito  NUMBER(16, 2),
        suelba    NUMERIC(15, 4),
        codafp    VARCHAR(4),
        porfac    NUMERIC(15, 4), -- % FACTOR 18% 
        porafp    NUMERIC(15, 4), -- % ESSALUD
        nomsba    VARCHAR(1000 CHAR), -- CONCEPTO NOMBRE
        nomeps    VARCHAR(1000 CHAR), -- CLASE / PERSONAL
        perconf   VARCHAR(25) --NUMERO DOCUMENTO
    );
    TYPE datatable_buscar_liq IS
        TABLE OF datarecord_buscar_liq;
    TYPE datarecord_detalle_dias IS RECORD (
        rotdiaslab     VARCHAR2(60),
        diaslab        VARCHAR2(60),
        rotdiasnolab   VARCHAR2(60),
        diasnolab      VARCHAR2(60),
        rotdiassub     VARCHAR2(60),
        diassub        VARCHAR2(60),
        rothordinarias VARCHAR2(60),
        hordinarias    VARCHAR2(60),
        rottardanzas   VARCHAR2(60),
        tardanzas      VARCHAR2(60)
    );
    TYPE datatable_detalle_dias IS
        TABLE OF datarecord_detalle_dias;
    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_numpla NUMBER,
        pin_codper VARCHAR2
    ) RETURN datatable_buscar
        PIPELINED;

    TYPE datarecord_detalle_rango IS RECORD (
        codper  VARCHAR2(20 CHAR),
        tipo    motivo_planilla.codrel%TYPE,
        motivo  motivo_planilla.descri%TYPE,
        finicio planilla_rango.finicio%TYPE,
        ffinal  planilla_rango.ffinal%TYPE,
        dias    planilla_rango.dias%TYPE
    );
    TYPE datatable_detalle_rango IS
        TABLE OF datarecord_detalle_rango;
    TYPE datarecord_detalle_cts IS RECORD (
        codper   VARCHAR2(20 CHAR),
        finicio  DATE,
        ffinal   DATE,
        mescts   NUMBER(16, 2),
        diacts   NUMBER(16, 2),
        totcts   NUMBER(16, 2),
        codban   tbancos.codban%TYPE,
        desban   tbancos.descri%TYPE,
        codmon   tbancos.moneda%TYPE,
        simmon   tmoneda.simbolo%TYPE,
        cuenta   personal_cts.cuenta%TYPE,
        deposito NUMBER(16, 2)
    );
    TYPE datatable_detalle_cts IS
        TABLE OF datarecord_detalle_cts;
    TYPE datarecord_detalle_liq IS RECORD (
        codper   VARCHAR2(20 CHAR),
        finicio  DATE,
        ffinal   DATE,
        perliq   NUMBER(16, 2),
        mesliq   NUMBER(16, 2),
        dialiq   NUMBER(16, 2),
        totliq   NUMBER(16, 2),
        codmot   motivo_planilla.codmot%TYPE,
        desmot   motivo_planilla.descri%TYPE,
        deposito NUMBER(16, 2)
    );
    TYPE datatable_detalle_liq IS
        TABLE OF datarecord_detalle_liq;
    TYPE datarecord_detalle_tcc IS RECORD (
        codcco tccostos.codigo%TYPE,
        descco tccostos.descri%TYPE,
        prcdis personal_ccosto.prcdis%TYPE
    );
    TYPE datatable_detalle_tcc IS
        TABLE OF datarecord_detalle_tcc;
    TYPE datarecord_detalle_concepto IS RECORD (
        codcon  concepto.codcon%TYPE,
        descon  concepto.nombre%TYPE,
        prefijo concepto.nombre%TYPE,
        sufijo  concepto.nombre%TYPE,
        rotulo  VARCHAR2(500 CHAR)
    );
    TYPE datatable_detalle_concepto IS
        TABLE OF datarecord_detalle_concepto;
    TYPE datarecord_detalle_concepto_resultado IS RECORD (
        id_cia concepto.id_cia%TYPE,
        codcon concepto.codcon%TYPE,
        clase  concepto_clase.clase%TYPE,
        codigo concepto_clase.codigo%TYPE,
        vstrg  concepto_clase.vresult%TYPE,
        valcon VARCHAR2(100 CHAR)
    );
    TYPE datatable_detalle_concepto_resultado IS
        TABLE OF datarecord_detalle_concepto_resultado;
    TYPE datarecord_observ_liq IS RECORD (
        observ VARCHAR2(4000 CHAR)
    );
    TYPE datatable_observ_liq IS
        TABLE OF datarecord_observ_liq;
    TYPE datarecord_detalle_firma IS RECORD (
        id_cia  concepto.id_cia%TYPE,
        logocab companias.logocab%TYPE,
        formcab companias.formcab%TYPE,
        logodet companias.logodet%TYPE,
        formdet companias.formdet%TYPE
    );
    TYPE datatable_detalle_firma IS
        TABLE OF datarecord_detalle_firma;
    TYPE datarecord_detalle_envio_correo IS RECORD (
        id_cia planilla_resumen.id_cia%TYPE,
        numpla planilla_resumen.numpla%TYPE,
        codper planilla_resumen.codper%TYPE
    );
    TYPE datatable_detalle_envio_correo IS
        TABLE OF datarecord_detalle_envio_correo;
    FUNCTION sp_convert_format (
        pin_input  VARCHAR2,
        pin_codfor NUMBER
    ) RETURN VARCHAR2;

    FUNCTION sp_detalle_firma (
        pin_id_cia NUMBER
    ) RETURN datatable_detalle_firma
        PIPELINED;

    FUNCTION sp_detalle_envio_correo (
        pin_id_cia NUMBER,
        pin_numpla NUMBER,
        pin_codper VARCHAR2
    ) RETURN datatable_detalle_envio_correo
        PIPELINED;

    FUNCTION sp_detalle_rango (
        pin_id_cia NUMBER,
        pin_numpla NUMBER,
        pin_codper VARCHAR2
    ) RETURN datatable_detalle_rango
        PIPELINED;

    FUNCTION sp_detalle_cts (
        pin_id_cia NUMBER,
        pin_numpla NUMBER,
        pin_codper VARCHAR2
    ) RETURN datatable_detalle_cts
        PIPELINED;

    FUNCTION sp_detalle_liq (
        pin_id_cia NUMBER,
        pin_numpla NUMBER,
        pin_codper VARCHAR2
    ) RETURN datatable_detalle_liq
        PIPELINED;

    FUNCTION sp_observ_liq (
        pin_id_cia NUMBER,
        pin_numpla NUMBER,
        pin_codper VARCHAR2
    ) RETURN datatable_observ_liq
        PIPELINED;

    FUNCTION sp_detalle_dias (
        pin_id_cia NUMBER,
        pin_numpla NUMBER,
        pin_codper VARCHAR2
    ) RETURN datatable_detalle_dias
        PIPELINED;

    FUNCTION sp_detalle_concepto (
        pin_id_cia NUMBER,
        pin_numpla NUMBER,
        pin_codper VARCHAR2,
        pin_codcon VARCHAR2
    ) RETURN datatable_detalle_concepto
        PIPELINED;

    FUNCTION sp_detalle_concepto_resultado (
        pin_id_cia NUMBER,
        pin_numpla NUMBER,
        pin_codper VARCHAR2,
        pin_codcon VARCHAR2,
        pin_clase  NUMBER,
        pin_codigo VARCHAR2,
        pin_vstrg  VARCHAR2
    ) RETURN datatable_detalle_concepto_resultado
        PIPELINED;

    FUNCTION sp_buscar_cts (
        pin_id_cia NUMBER,
        pin_numpla NUMBER,
        pin_codper VARCHAR2
    ) RETURN datatable_buscar_cts
        PIPELINED;

    FUNCTION sp_buscar_qui (
        pin_id_cia NUMBER,
        pin_numpla NUMBER,
        pin_codper VARCHAR2
    ) RETURN datatable_buscar
        PIPELINED;

    FUNCTION sp_buscar_liq (
        pin_id_cia NUMBER,
        pin_numpla NUMBER,
        pin_codper VARCHAR2
    ) RETURN datatable_buscar_liq
        PIPELINED;

    FUNCTION sp_detalle_tcc (
        pin_id_cia NUMBER,
        pin_codper VARCHAR2
    ) RETURN datatable_detalle_tcc
        PIPELINED;

END;

/

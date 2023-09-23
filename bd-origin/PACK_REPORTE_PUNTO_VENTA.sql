--------------------------------------------------------
--  DDL for Package PACK_REPORTE_PUNTO_VENTA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_REPORTE_PUNTO_VENTA" AS
    TYPE rec_sp_recibo_de_caja IS RECORD (
        libro      VARCHAR2(3),
        periodo    NUMBER,
        mes        NUMBER,
        secuencia  NUMBER,
        item       NUMBER,
        tipdep     NUMBER,
        doccan     VARCHAR2(15),
        cuenta     VARCHAR2(16),
        dh         VARCHAR2(1),
        tipmon     VARCHAR2(5),
        simdoc     VARCHAR2(3),
        codban     VARCHAR2(6),
        op         VARCHAR2(10),
        agencia    VARCHAR2(20),
        tipcam     NUMERIC(9, 6),
        deposito   NUMERIC(9, 2),
        tcamb01    NUMERIC(14, 6),
        tcamb02    NUMERIC(16, 6),
        impor01    NUMERIC(9, 2),
        impor02    NUMERIC(9, 2),
        pagomn     NUMERIC(9, 2),
        pagome     NUMERIC(9, 2),
        situac     VARCHAR2(1),
        concep     VARCHAR2(75),
        desban     VARCHAR2(65),
        dtipdep    VARCHAR2(50)
    );
    TYPE tbl_sp_recibo_de_caja IS
        TABLE OF rec_sp_recibo_de_caja;
    FUNCTION sp_recibo_de_caja (
        pin_id_cia     IN NUMBER,
        pin_tippla     NUMBER,
        pin_periodo    NUMBER,
        pin_mes        NUMBER,
        pin_secuencia  NUMBER
    ) RETURN tbl_sp_recibo_de_caja
        PIPELINED;


    ----

    TYPE rec_sp_bancarizacion_documentos IS RECORD (
        numcaja      NUMBER,
        libro        VARCHAR2(3),
        periodo      NUMBER,
        mes          NUMBER,
        secuencia    NUMBER,
        concep       VARCHAR2(120),
        docume       VARCHAR2(15),
        tipmon       VARCHAR2(5),
        amorti       NUMERIC(16, 2),
        importe      NUMERIC(16, 2),
        swdep        VARCHAR2(1),
        montosalida  NUMERIC(16, 2)
    );
    TYPE tbl_sp_bancarizacion_documentos IS
        TABLE OF rec_sp_bancarizacion_documentos;
    FUNCTION sp_bancarizacion_documentos (
        pin_id_cia   IN  NUMBER,
        pin_fdesde   IN  DATE,
        pin_fhasta   IN  DATE,
        pin_codsuc   IN  NUMBER,
        pin_nrocaja  IN  NUMBER,
        pin_estado   IN  NUMBER
    ) RETURN tbl_sp_bancarizacion_documentos
        PIPELINED;

    TYPE rec_sp_documentos_emitidos IS RECORD (
        numint   NUMBER,
        tipdoc   NUMBER,
        femisi   DATE,
        fvenci   DATE,
        series   VARCHAR2(5),
        numdoc   NUMBER,
        codcli   VARCHAR2(20),
        razonc   cliente.razonc%TYPE,
        tipmon   VARCHAR2(5),
        monafe   NUMBER(16, 2),
        monigv   NUMBER(16, 2),
        preven   NUMBER(16, 2),
        situac   VARCHAR2(1),
        dessit   VARCHAR2(50),
        codven   NUMBER,
        grupo    NUMBER,
        simbolo  VARCHAR2(3),
        despag   VARCHAR2(50),
        codcpag  NUMBER,
        desdoc   VARCHAR2(50),
        desgru   VARCHAR2(50)
    );
    TYPE tbl_sp_documentos_emitidos IS
        TABLE OF rec_sp_documentos_emitidos;
    FUNCTION sp_documentos_emitidos (
        pin_id_cia  IN  NUMBER,
        pin_fdesde  IN  DATE,
        pin_fhasta  IN  DATE,
        pin_codcli  IN  VARCHAR2,
        pin_codpag  IN  NUMBER,
        pin_codsuc  IN  NUMBER,
        pin_tipdoc  IN  VARCHAR2
    ) RETURN tbl_sp_documentos_emitidos
        PIPELINED;

    TYPE rec_sp_informe_diario_caja IS RECORD (
        numcaja       NUMBER,
        periodo       NUMBER,
        mes           NUMBER,
        dia           NUMBER,
        libro         VARCHAR2(3),
        secuencia     NUMBER,
        flags         VARCHAR2(2),
        flag          VARCHAR2(2),
        coduser       VARCHAR2(10),
        nombres       VARCHAR2(70),
        item          NUMBER,
        femisi        DATE,
        tipcam        NUMBER(9, 6),
        codcli        VARCHAR2(20),
        razonc   cliente.razonc%TYPE,
        tipdoc        NUMBER,
        abrevi        VARCHAR2(4),
        destipo       VARCHAR2(50),
        docume        VARCHAR2(40),
        tipdocori     NUMBER,
        abreviori     VARCHAR2(4),
        destipoori    VARCHAR2(50),
        tipo          VARCHAR2(5),
        despago       VARCHAR2(50),
        simbold       VARCHAR2(3),
        tipmonc       VARCHAR2(5),
        simboldoc     VARCHAR2(5),
        tipmond       VARCHAR2(5),
        importe       NUMBER(16, 2),
        mpago         NUMBER,
        deposito      NUMBER(16, 2),
        depositosol   NUMBER(16, 2),
        depositodol   NUMBER(16, 2),
        swsuma        NUMBER,
        fopera        DATE,
        secuenciaxls  VARCHAR2(25)
    );
    TYPE tbl_sp_informe_diario_caja IS
        TABLE OF rec_sp_informe_diario_caja;
    FUNCTION sp_informe_diario_caja (
        pin_id_cia    IN  NUMBER,
        pin_codsuc    IN  NUMBER,
        pin_pnumcaja  IN  NUMBER,
        pin_fdesde    IN  DATE,
        pin_fhasta    IN  DATE,
        pin_fmpago    IN  NUMBER
    ) RETURN tbl_sp_informe_diario_caja
        PIPELINED;

    TYPE r_cuadre_caja IS RECORD (
        flag       NUMBER,
        orden      NUMBER,
        id         VARCHAR2(5),
        despago    VARCHAR2(60),
        importemn  NUMBER(16, 2),
        importeme  NUMBER(16, 2),
        swcomven   VARCHAR2(5)
    );
    TYPE t_cuadre_caja IS
        TABLE OF r_cuadre_caja;
    TYPE r_cuadre_caja_detallado IS RECORD (
        flag       VARCHAR2(5),
        id         VARCHAR2(5),
        numcaja    NUMBER,
        tipdep     NUMBER,
        periodo    NUMBER,
        mes        NUMBER,
        secuencia  NUMBER,
        item       NUMBER,
        concep     VARCHAR2(220),
        dtipdep    VARCHAR2(220),
        motivo     VARCHAR2(220),
        docume     VARCHAR2(25),
        importemn  NUMBER(16, 2),
        importeme  NUMBER(16, 2),
        idtarjeta  INTEGER
    );
    TYPE t_cuadre_caja_detallado IS
        TABLE OF r_cuadre_caja_detallado;
    TYPE r_documentos_registrados IS RECORD (
        tipdoc     NUMBER,
        docume     VARCHAR2(40),
        refere01   VARCHAR2(40),
        refere02   VARCHAR2(40),
        femisi     DATE,
        fvenci     DATE,
        signo      VARCHAR2(40),
        fcance     DATE,
        numbco     VARCHAR2(50),
        tipmon     VARCHAR2(40),
        importe    NUMBER(16, 2),
        saldo      NUMBER(16, 2),
        codban     NUMBER,
        codcli     VARCHAR2(120),
        razonc   cliente.razonc%TYPE,
        limcre1    NUMBER(16, 2),
        limcre2    NUMBER(16, 2),
        desmon     VARCHAR2(40),
        chedev     NUMBER(16, 2),
        letpro     NUMBER(16, 2),
        renova     NUMBER(16, 2),
        refina     NUMBER(16, 2),
        fecing     DATE,
        dtipdoc    VARCHAR2(40),
        desmot     VARCHAR2(40),
        despagven  c_pago.despag%TYPE
    );
    TYPE t_documentos_registrados IS
        TABLE OF r_documentos_registrados;
    FUNCTION sp_cuadre_caja (
        pin_id_cia    IN  NUMBER,
        pin_codsuc    IN  NUMBER,
        pin_pnumcaja  IN  NUMBER,
        pin_fecha     IN  DATE
    ) RETURN t_cuadre_caja
        PIPELINED;

    FUNCTION sp_cuadre_caja_detallado (
        pin_id_cia    IN  NUMBER,
        pin_codsuc    IN  NUMBER,
        pin_pnumcaja  IN  NUMBER,
        pin_fecha     IN  DATE
    ) RETURN t_cuadre_caja_detallado
        PIPELINED;

    FUNCTION sp_documentos_registrados (
        pin_id_cia   IN  NUMBER,
        pin_fecha    IN  DATE,
        pin_codcli   IN  VARCHAR2,
        pin_codsuc   IN  NUMBER,
        pin_estado   IN  NUMBER,
        pin_tipdocs  IN  VARCHAR2 --Lista de tipo de documentos SELECCIONADOS
    ) RETURN t_documentos_registrados
        PIPELINED;

    TYPE r_sp00_resumen_informe_diario_mpago IS RECORD (
        tipdoc       NUMBER,
        abrtdoc      VARCHAR2(4),
        destdoc      VARCHAR2(50),
        mpago        NUMBER,
        abrmpag      VARCHAR2(5),
        desmpag      VARCHAR2(50),
        tipmon       VARCHAR2(5),
        simbol       VARCHAR2(3),
        depositosol  NUMBER(16, 2),
        depositodol  NUMBER(16, 2),
        deposito     NUMBER(16, 2)
    );
    TYPE t_sp00_resumen_informe_diario_mpago IS
        TABLE OF r_sp00_resumen_informe_diario_mpago;
    FUNCTION sp00_resumen_informe_diario_mpago (
        pin_id_cia   IN  NUMBER,
        pin_fdesde   IN  DATE,
        pin_fhasta   IN  DATE,
        pin_codsuc   IN  NUMBER,
        pin_nrocaja  IN  NUMBER,
        pin_mpago    IN  NUMBER
    ) RETURN t_sp00_resumen_informe_diario_mpago
        PIPELINED;

    TYPE r_sp01_resumen_informe_diario_mpago IS RECORD (
        tipdoc       NUMBER,
        abrtdoc      VARCHAR2(4),
        destdoc      VARCHAR2(50),
        mpago        NUMBER,
        abrmpag      VARCHAR2(5),
        desmpag      VARCHAR2(50),
        tipmon       VARCHAR2(5),
        simbol       VARCHAR2(3),
        depositosol  NUMBER(16, 2),
        depositodol  NUMBER(16, 2),
        deposito     NUMBER(16, 2)
    );
    TYPE t_sp01_resumen_informe_diario_mpago IS
        TABLE OF r_sp01_resumen_informe_diario_mpago;
    FUNCTION sp01_resumen_informe_diario_mpago (
        pin_id_cia   IN  NUMBER,
        pin_fdesde   IN  DATE,
        pin_fhasta   IN  DATE,
        pin_codsuc   IN  NUMBER,
        pin_nrocaja  IN  NUMBER,
        pin_mpago    IN  NUMBER
    ) RETURN t_sp01_resumen_informe_diario_mpago
        PIPELINED;

    TYPE r_sp00_resumen_informe_diario_tipdoc IS RECORD (
        tipdoc       NUMBER,
        abrtdoc      VARCHAR2(4),
        destdoc      VARCHAR2(50),
        mpago        INTEGER,
        abrmpag      VARCHAR2(5),
        desmpag      VARCHAR2(50),
        tipmon       VARCHAR2(5),
        simbol       VARCHAR2(3),
        depositosol  NUMBER(16, 2),
        depositodol  NUMBER(16, 2),
        deposito     NUMBER(16, 2)
    );
    TYPE t_sp00_resumen_informe_diario_tipdoc IS
        TABLE OF r_sp00_resumen_informe_diario_tipdoc;
    FUNCTION sp00_resumen_informe_diario_tipdoc (
        pin_id_cia   IN  NUMBER,
        pin_fdesde   IN  DATE,
        pin_fhasta   IN  DATE,
        pin_codsuc   IN  NUMBER,
        pin_nrocaja  IN  NUMBER,
        pin_mpago    IN  NUMBER
    ) RETURN t_sp00_resumen_informe_diario_tipdoc
        PIPELINED;

    TYPE r_sp01_resumen_informe_diario_tipdoc IS RECORD (
        tipdoc       NUMBER,
        abrtdoc      VARCHAR2(4),
        destdoc      VARCHAR2(50),
        mpago        INTEGER,
        abrmpag      VARCHAR2(5),
        desmpag      VARCHAR2(50),
        tipmon       VARCHAR2(5),
        simbol       VARCHAR2(3),
        depositosol  NUMBER(16, 2),
        depositodol  NUMBER(16, 2),
        deposito     NUMBER(16, 2)
    );
    TYPE t_sp01_resumen_informe_diario_tipdoc IS
        TABLE OF r_sp01_resumen_informe_diario_tipdoc;
    FUNCTION sp01_resumen_informe_diario_tipdoc (
        pin_id_cia   IN  NUMBER,
        pin_fdesde   IN  DATE,
        pin_fhasta   IN  DATE,
        pin_codsuc   IN  NUMBER,
        pin_nrocaja  IN  NUMBER,
        pin_mpago    IN  NUMBER
    ) RETURN t_sp01_resumen_informe_diario_tipdoc
        PIPELINED;

END pack_reporte_punto_venta;

/

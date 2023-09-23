--------------------------------------------------------
--  DDL for Package PACK_DOCUMENTOS_PENDIENTES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_DOCUMENTOS_PENDIENTES" AS
    TYPE datarecord_detalle_pendientes_envio_sunat IS RECORD (
        id_cia     documentos_cab.id_cia%TYPE,
        numint     documentos_cab.numint%TYPE,
        estado     VARCHAR(100),
        tipdoc     documentos_cab.tipdoc%TYPE,
        desdoc     tdoccobranza.descri%TYPE,
        femisi     documentos_cab.femisi%TYPE,
        series     documentos_cab.series%TYPE,
        numdoc     documentos_cab.numdoc%TYPE,
        codcli     documentos_cab.codcli%TYPE,
        tident     cliente.tident%TYPE,
        dident     cliente.dident%TYPE,
        cab_tident documentos_cab.tident%TYPE,
        ruc        documentos_cab.ruc%TYPE,
        razonc     documentos_cab.razonc%TYPE,
        preven     documentos_cab.preven%TYPE
    );
    TYPE datatable_detalle_pendientes_envio_sunat IS
        TABLE OF datarecord_detalle_pendientes_envio_sunat;
    TYPE datarecord_resumen_pendientes_envio_sunat IS RECORD (
        tipdoc documentos_cab.tipdoc%TYPE,
        desdoc tdoccobranza.descri%TYPE,
        numpen INTEGER
    );
    TYPE datatable_resumen_pendientes_envio_sunat IS
        TABLE OF datarecord_resumen_pendientes_envio_sunat;
    TYPE datarecord_detalle_planilla IS RECORD (
        id_cia      dcta100.id_cia%TYPE,
        numint      dcta100.numint%TYPE,
        tipdoc      dcta100.tipdoc%TYPE,
        docume      dcta100.docume%TYPE,
        serie       dcta100.serie%TYPE,
        numero      dcta100.numero%TYPE,
        femisi      dcta100.femisi%TYPE,
        fvenci      dcta100.fvenci%TYPE,
        codban      dcta100.codban%TYPE,
        numbco      dcta100.numbco%TYPE,
        refere01    dcta100.refere01%TYPE,
        refere02    dcta100.refere02%TYPE,
        tipmon      dcta100.tipmon%TYPE,
        importe     dcta100.importe%TYPE,
        importemn   dcta100.importemn%TYPE,
        importeme   dcta100.importeme%TYPE,
        saldo       dcta100.saldo%TYPE,
        saldomn     dcta100.saldomn%TYPE,
        saldome     dcta100.saldome%TYPE,
        dh          dcta100.dh%TYPE,
        cuenta      dcta100.cuenta%TYPE,
        tipcam      dcta100.tipcam%TYPE,
        protes      dcta100.protes%TYPE,
        codcli      cliente.codcli%TYPE,
        razonc      cliente.razonc%TYPE,
        regret      cliente.regret%TYPE,
        tident      cliente.tident%TYPE,
        dident      cliente.dident%TYPE,
        codsunat    tdoccobranza.codsunat%TYPE,
        abrevi      tdoccobranza.abrevi%TYPE,
        tasa        regimen_retenciones_vigencia.tasa%TYPE,
        tope        regimen_retenciones_vigencia.tope%TYPE,
        saldosret   dcta100.saldo%TYPE,
        saldosretmn dcta100.saldo%TYPE,
        saldosretme dcta100.saldo%TYPE
    );
    TYPE datatable_detalle_planilla IS
        TABLE OF datarecord_detalle_planilla;
    TYPE datarecord_planilla_ingban IS RECORD (
        id_cia     dcta103.id_cia%TYPE,
        libro      dcta103.libro%TYPE,
        periodo    dcta103.periodo%TYPE,
        mes        dcta103.mes%TYPE,
        secuencia  dcta103.secuencia%TYPE,
        concep     dcta102.concep%TYPE,
        dia        dcta102.dia%TYPE,
        situac     dcta102.situac%TYPE,
        femisi     dcta102.femisi%TYPE,
        referencia dcta102.referencia%TYPE,
        tipenvio   VARCHAR2(100)
    );
    TYPE datatable_planilla_ingban IS
        TABLE OF datarecord_planilla_ingban;
    TYPE datarecord_planilla_ingban_detalle IS RECORD (
        id_cia      NUMBER(38),
        libro       VARCHAR2(3),
        periodo     NUMBER(38),
        mes         NUMBER(38),
        secuencia   NUMBER(38),
        item        NUMBER(38),
        numint      NUMBER(38),
        tipcan      NUMBER(38),
        cuenta      VARCHAR2(16),
        dh          CHAR(1),
        tipmon      VARCHAR2(5),
        doccan      VARCHAR2(25),
        docume      VARCHAR2(15),
        tipcam      NUMBER(16, 6),
        amorti      NUMBER(16, 2),
        tcamb01     NUMBER(16, 6),
        tcamb02     NUMBER(16, 6),
        impor01     NUMBER(16, 2),
        impor02     NUMBER(16, 2),
        pagomn      NUMBER(16, 2),
        pagome      NUMBER(16, 2),
        situac      CHAR(1),
        numbco      VARCHAR2(50),
        deposito    NUMBER(16, 2),
        swchksepaga VARCHAR2(1),
        swdep       VARCHAR2(1),
        tipdoc      NUMBER(38),
        codban      NUMBER(38)
    );
    TYPE datatable_planilla_ingban_detalle IS
        TABLE OF datarecord_planilla_ingban_detalle;
    TYPE datarecord_consulta IS RECORD (
        id_cia       NUMBER(38),
        numint       NUMBER(38),
        codcli       VARCHAR2(20),
        tipdoc       NUMBER(38),
        docume       VARCHAR2(40),
        serie        VARCHAR2(20),
        numero       VARCHAR2(20),
        periodo      NUMBER(38),
        mes          NUMBER(38),
        femisi       DATE,
        fvenci       DATE,
        fcance       DATE,
        codban       NUMBER(38),
        numbco       VARCHAR2(50),
        refere01     VARCHAR2(25),
        refere02     VARCHAR2(25),
        tipmon       VARCHAR2(5),
        importe      NUMBER(16, 2),
        importemn    NUMBER(16, 2),
        importeme    NUMBER(16, 2),
        saldo        NUMBER(16, 2),
        saldomn      NUMBER(16, 2),
        saldome      NUMBER(16, 2),
        concpag      NUMBER(38),
        codcob       NUMBER(38),
        codven       NUMBER(38),
        comisi       NUMBER(14, 4),
        codsuc       NUMBER(38),
        cancelado    CHAR(1),
        fcreac       DATE,
        factua       DATE,
        usuari       VARCHAR2(10),
        situac       CHAR(1),
        cuenta       VARCHAR2(16),
        dh           CHAR(1),
        tipcam       NUMBER(14, 6),
        operac       NUMBER(38),
        protes       NUMBER(38),
        xlibro       VARCHAR2(3),
        xperiodo     NUMBER(38),
        xmes         NUMBER(38),
        xsecuencia   NUMBER(38),
        codubi       NUMBER(38),
        xprotesto    NUMBER(16, 2),
        tercero      NUMBER(38),
        codterc      VARCHAR2(20),
        codacep      VARCHAR2(20),
        swmigra      VARCHAR2(1),
        razonc       cliente.razonc%TYPE,
        razonc_acep  cliente.razonc%TYPE,
        desban       tbancos.descri%TYPE,
        operac_des   dcta100_operac.desoperac%TYPE,
        protesto_des VARCHAR2(10)
    );
    TYPE datatable_consulta IS
        TABLE OF datarecord_consulta;
    FUNCTION sp_detalle_cpe_pendientes_envio_sunat (
        pin_id_cia NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE,
        pin_tipdoc IN VARCHAR2
    ) RETURN datatable_detalle_pendientes_envio_sunat
        PIPELINED;

    FUNCTION sp_resumen_cpe_pendientes_envio_sunat (
        pin_id_cia NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE,
        pin_tipdoc IN VARCHAR2
    ) RETURN datatable_resumen_pendientes_envio_sunat
        PIPELINED;
--SELECT * FROM pack_documentos_pendientes.sp_detalle_planilla(217,-1,'','01/01/2023');
    FUNCTION sp_detalle_planilla (
        pin_id_cia   NUMBER,
        pin_tipdoc   NUMBER,
        pin_codcli   VARCHAR2,
        pin_solodesc VARCHAR2,
        pin_fhasta   DATE
    ) RETURN datatable_detalle_planilla
        PIPELINED;

    FUNCTION sp_detalle_planilla_docume (
        pin_id_cia   NUMBER,
        pin_tipdoc   NUMBER,
        pin_docume   VARCHAR2,
        pin_solodesc VARCHAR2,
        pin_fhasta   DATE
    ) RETURN datatable_detalle_planilla
        PIPELINED;

    FUNCTION sp_planilla_ingban (
        pin_id_cia NUMBER,
        pin_codban VARCHAR2
    ) RETURN datatable_planilla_ingban
        PIPELINED;

    FUNCTION sp_planilla_ingban_detalle (
        pin_id_cia    NUMBER,
        pin_libro     VARCHAR2,
        pin_periodo   NUMBER,
        pin_mes       NUMBER,
        pin_secuencia NUMBER
    ) RETURN datatable_planilla_ingban_detalle
        PIPELINED;

--SELECT * FROM pack_documentos_pendientes.sp_consulta(66,1,NULL,NULL,'N',to_date('01/01/23','DD/MM/YY'),to_date('01/01/24','DD/MM/YY'),10,10);

    FUNCTION sp_consulta (
        pin_id_cia   NUMBER,
        pin_tipdoc   NUMBER,
        pin_codcli   VARCHAR2,
        pin_docume   VARCHAR2,
        pin_chksaldo VARCHAR2,
        pin_fdesde   DATE,
        pin_fhasta   DATE,
        pin_limit    INTEGER,
        pin_offset   INTEGER
    ) RETURN datatable_consulta
        PIPELINED;

END;

/

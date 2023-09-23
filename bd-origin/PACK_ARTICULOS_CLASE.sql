--------------------------------------------------------
--  DDL for Package PACK_ARTICULOS_CLASE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_ARTICULOS_CLASE" AS
    TYPE datarecord_buscar IS RECORD (
        id_cia                  NUMBER,
        codtit                  NUMBER,
        tipinv                  NUMBER,
        codart                  VARCHAR2(50),
        desart                  VARCHAR2(100),
        coduni                  VARCHAR2(5),
        simbolo                 VARCHAR2(5),
        codmon                  VARCHAR2(5),
        precio                  NUMERIC(16, 5),
        desc01                  NUMERIC(9, 5),
        desc02                  NUMERIC(9, 5),
        desc03                  NUMERIC(9, 5),
        desc04                  NUMERIC(9, 5),
        desmax                  NUMERIC(9, 5),
        incigv                  VARCHAR2(1),
        consto                  NUMBER,
        dprecio                 NUMERIC(16, 5),
        dincigv                 VARCHAR2(1),
        dporigv                 NUMERIC(9, 5),
        dmargen                 NUMERIC(9, 5),
        dotros                  NUMERIC(9, 5),
        dflete                  NUMERIC(9, 5),
        dcodmon                 VARCHAR2(5),
        ddesc01                 NUMERIC(9, 5),
        ddesc02                 NUMERIC(9, 5),
        ddesc03                 NUMERIC(9, 5),
        ddesc04                 NUMERIC(9, 5),
        codcla1                 VARCHAR2(20),
        descla1                 VARCHAR2(50),
        codcla2                 VARCHAR2(20),
        descla2                 VARCHAR2(50),
        codcla3                 VARCHAR2(20),
        descla3                 VARCHAR2(50),
        codcla4                 VARCHAR2(20),
        descla4                 VARCHAR2(50),
        codcla5                 VARCHAR2(20),
        descla5                 VARCHAR2(50),
        codcla6                 VARCHAR2(20),
        descla6                 VARCHAR2(50),
        stock                   VARCHAR2(200),
        codpro                  VARCHAR2(20),
        profactua               TIMESTAMP,
        situacion               VARCHAR2(10),
        glosacotizaciondefecto  VARCHAR2(1000 CHAR),
        glosafacturaciondefecto VARCHAR2(1000 CHAR)
    );
    TYPE datatable_buscar IS
        TABLE OF datarecord_buscar;
    TYPE datarecord_buscar_stock IS RECORD (
        id_cia                  NUMBER,
        codtit                  NUMBER,
        tipinv                  NUMBER,
        codart                  VARCHAR2(50),
        desart                  VARCHAR2(100),
        coduni                  VARCHAR2(5),
        simbolo                 VARCHAR2(5),
        codmon                  VARCHAR2(5),
        precio                  NUMERIC(16, 5),
        desc01                  NUMERIC(9, 5),
        desc02                  NUMERIC(9, 5),
        desc03                  NUMERIC(9, 5),
        desc04                  NUMERIC(9, 5),
        desmax                  NUMERIC(9, 5),
        incigv                  VARCHAR2(1),
        consto                  NUMBER,
        dprecio                 NUMERIC(16, 5),
        dincigv                 VARCHAR2(1),
        dporigv                 NUMERIC(9, 5),
        dmargen                 NUMERIC(9, 5),
        dotros                  NUMERIC(9, 5),
        dflete                  NUMERIC(9, 5),
        dcodmon                 VARCHAR2(5),
        ddesc01                 NUMERIC(9, 5),
        ddesc02                 NUMERIC(9, 5),
        ddesc03                 NUMERIC(9, 5),
        ddesc04                 NUMERIC(9, 5),
        codcla1                 VARCHAR2(20),
        descla1                 VARCHAR2(50),
        codcla2                 VARCHAR2(20),
        descla2                 VARCHAR2(50),
        codcla3                 VARCHAR2(20),
        descla3                 VARCHAR2(50),
        codcla4                 VARCHAR2(20),
        descla4                 VARCHAR2(50),
        codcla5                 VARCHAR2(20),
        descla5                 VARCHAR2(50),
        codcla6                 VARCHAR2(20),
        descla6                 VARCHAR2(50),
        stock                   VARCHAR2(200),
        codpro                  VARCHAR2(20),
        profactua               TIMESTAMP,
        situacion               VARCHAR2(10),
        glosacotizaciondefecto  VARCHAR2(1000 CHAR),
        glosafacturaciondefecto VARCHAR2(1000 CHAR),
        totalstock              NUMBER
    );
    TYPE datatable_buscar_stock IS
        TABLE OF datarecord_buscar_stock;
    TYPE datarecord_tipcamlista IS RECORD (
        id_cia      documentos_cab.id_cia%TYPE,
        codmonlista documentos_cab.tipmon%TYPE,
        tipcamlista documentos_cab.tipcam%TYPE,
        preciolista listaprecios.precio%TYPE,
        femisi      documentos_cab.femisi%TYPE
    );
    TYPE datatable_tipcamlista IS
        TABLE OF datarecord_tipcamlista;
    TYPE datarecord_ayuda IS RECORD (
        tipinv  articulos.tipinv%TYPE,
        codart  articulos.codart%TYPE,
        descri  articulos.descri%TYPE,
        codmar  articulos.codmar%TYPE,
        codubi  articulos.codubi%TYPE,
        codprc  articulos.codprc%TYPE,
        codmod  articulos.codmod%TYPE,
        modelo  articulos.modelo%TYPE,
        codobs  articulos.codobs%TYPE,
        coduni  articulos.coduni%TYPE,
        codlin  articulos.codlin%TYPE,
        codori  articulos.codori%TYPE,
        codfam  articulos.codfam%TYPE,
        codbar  articulos.codbar%TYPE,
        consto  articulos.consto%TYPE,
        codprv  articulos.codprv%TYPE,
        agrupa  articulos.agrupa%TYPE,
        fcreac  articulos.fcreac%TYPE,
        fmatri  articulos.fmatri%TYPE,
        factua  articulos.factua%TYPE,
        usuari  articulos.usuari%TYPE,
        wglosa  articulos.wglosa%TYPE,
        faccon  articulos.faccon%TYPE,
        tusoesp articulos.tusoesp%TYPE,
        tusoing articulos.tusoing%TYPE,
        diacmm  articulos.diacmm%TYPE,
        cuenta  articulos.cuenta%TYPE,
        codope  articulos.codope%TYPE,
        situac  articulos.situac%TYPE
    );
    TYPE datatable_ayuda IS
        TABLE OF datarecord_ayuda;
    FUNCTION sp_buscar (
        pin_id_cia    IN NUMBER,
        pin_tipo      IN NUMBER,
        pin_codtit    IN VARCHAR2,
        pin_tipinv    IN NUMBER,
        pin_codpro    IN VARCHAR2,
        pin_codmon    IN VARCHAR2,
        pin_femisi    IN DATE, --N
        pin_codmondoc IN VARCHAR2, --N
        pin_tipcamdoc NUMBER, --N
        pin_incigvdoc VARCHAR2, --N
        pin_descri    IN VARCHAR2,
        pin_descla1   IN VARCHAR2,
        pin_descla2   IN VARCHAR2,
        pin_descla3   IN VARCHAR2,
        pin_descla4   IN VARCHAR2,
        pin_descla5   IN VARCHAR2,
        pin_descla6   IN VARCHAR2,
        pin_almacenes IN VARCHAR2,
        pin_fdesde    IN NUMBER,
        pin_fhasta    IN NUMBER,
        pin_incstock  IN VARCHAR2
    ) RETURN datatable_buscar
        PIPELINED;

    FUNCTION sp_buscar_stock (
        pin_id_cia    IN NUMBER,
        pin_tipo      IN NUMBER,
        pin_codtit    IN VARCHAR2,
        pin_tipinv    IN NUMBER,
        pin_codpro    IN VARCHAR2,
        pin_codmon    IN VARCHAR2,
        pin_femisi    IN DATE, --N
        pin_codmondoc IN VARCHAR2, --N
        pin_tipcamdoc NUMBER, --N
        pin_incigvdoc VARCHAR2, --N
        pin_descri    IN VARCHAR2,
        pin_descla1   IN VARCHAR2,
        pin_descla2   IN VARCHAR2,
        pin_descla3   IN VARCHAR2,
        pin_descla4   IN VARCHAR2,
        pin_descla5   IN VARCHAR2,
        pin_descla6   IN VARCHAR2,
        pin_almacenes IN VARCHAR2,
        pin_fdesde    IN NUMBER,
        pin_fhasta    IN NUMBER,
        pin_incstock  IN VARCHAR2,
        pin_anystock  IN VARCHAR2
    ) RETURN datatable_buscar_stock
        PIPELINED;

    FUNCTION sp_tipcamlista (
        pin_id_cia    NUMBER,
        pin_codmonlis VARCHAR2,
        pin_incigvlis VARCHAR2,
        pin_codmondoc VARCHAR2,
        pin_incigvdoc VARCHAR2,
        pin_tipcamdoc VARCHAR2,
        pin_preciolis NUMBER,
        pin_porigvlis NUMBER,
        pin_femisi    DATE
    ) RETURN datatable_tipcamlista
        PIPELINED;

    FUNCTION sp_ayuda (
        pin_id_cia     NUMBER,
        pin_tipinv NUMBER,
        pin_codart     VARCHAR2,
        pin_desart     VARCHAR2,
        pin_offset     NUMBER,
        pin_limit      NUMBER,
        pin_soloactivo VARCHAR2
    ) RETURN datatable_ayuda
        PIPELINED;

--select * from pack_articulos_clase.sp_buscar(215,1,'1',1,NULL,NULL,'01/06/2022','USD',3.89,'%cuchillete',
--NULL,NULL,NULL,NULL,NULL,NULL,
--3,202200,202212,'S');
--
--select * from pack_articulos_clase.sp_buscar(215,1,'1',1,NULL,NULL,'01/06/2022','PEN',3.89,'%cuchillete',
--NULL,NULL,NULL,NULL,NULL,NULL,
--3,202200,202212,'S');
--
--select * from pack_articulos_clase.sp_buscar(216,1,'1',1,NULL,NULL,'01/06/2022','PEN',3.89,'%MANGO ARTICULADO ENC 3/8 X 8 STANLEY',
--NULL,NULL,NULL,NULL,NULL,NULL,
--3,202200,202212,'S');

--select * from pack_articulos_clase.sp_buscar_stock(66,1,'1',1,NULL,NULL,null,'USD',3.89,'S','%cuchillete',
--NULL,NULL,NULL,NULL,NULL,NULL,
--'1,2,3,4,5',NULL,NULL,'S','S');

END;

/

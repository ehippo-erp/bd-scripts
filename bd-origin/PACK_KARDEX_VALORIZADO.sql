--------------------------------------------------------
--  DDL for Package PACK_KARDEX_VALORIZADO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_KARDEX_VALORIZADO" AS
    TYPE datarecord_kardex_valorizado IS RECORD (
        id_cia      NUMBER,
        tipinv      INTEGER,
        dtipinv     VARCHAR2(50),
        codfam      VARCHAR2(20),
        desfam      VARCHAR2(70),
        codlin      VARCHAR2(20),
        deslin      VARCHAR2(70),
        codart      VARCHAR2(40),
        desart      VARCHAR2(100),
        codunisunat VARCHAR2(10),
        id          VARCHAR2(1),
        tipope      VARCHAR2(50 CHAR), --TIPO DE OPERACION
        desmot      VARCHAR2(50 CHAR),
        abrmot      VARCHAR2(6),
        numint      NUMBER,
        numite      NUMBER,
        tipdoc      VARCHAR2(20), --TIPO 
        series      VARCHAR2(5),
        numdoc      NUMBER,
        femisi      DATE,
        codalm      NUMBER,
        desalm      VARCHAR2(50),
        abralm      VARCHAR2(10),
        desmon      VARCHAR2(50),
        simbolo     VARCHAR2(3),
        stockini    NUMBER(18, 2),
        cosuniini   NUMBER(18, 2),
        costotini   NUMBER(18, 2),
        caning      NUMBER(18, 2),
        cosuniing   NUMBER(18, 2),
        costoting   NUMBER(18, 2),
        cansal      NUMBER(18, 2),
        cosunisal   NUMBER(18, 2),
        costotsal   NUMBER(18, 2),
        stockfinal  NUMBER(18, 2),
        cosunifin   NUMBER(18, 2),
        costotfin   NUMBER(18, 2),
        ctatinv     VARCHAR2(16),
        desctatinv  VARCHAR2(50),
        codadd01    VARCHAR2(10),
        dcodadd01   VARCHAR2(100),
        codadd02    VARCHAR2(10),
        dcodadd02   VARCHAR2(100),
        mc46        VARCHAR2(1 CHAR),
        worden NUMBER
    );
    TYPE datatable_kardex_valorizado IS
        TABLE OF datarecord_kardex_valorizado;
    TYPE datarecord_almacen_valorizado IS RECORD (
        id_cia   kardex.id_cia%TYPE,
        tipinv   kardex.tipinv%TYPE,
        dtipinv  t_inventario.dtipinv%TYPE,
        codalm   kardex.codalm%TYPE,
        desalm   almacen.descri%TYPE,
        stock    NUMBER(18, 2),
        costot01 NUMBER(18, 2),
        costot02 NUMBER(18, 2)
    );
    TYPE datatable_almacen_valorizado IS
        TABLE OF datarecord_almacen_valorizado;
    FUNCTION sp_ingreso_salida (
        pin_id_cia   INTEGER,
        pin_tipinv   INTEGER,
        pin_codart   VARCHAR2,
        pin_anio     INTEGER,
        pin_mes      INTEGER,
        pin_moneda   VARCHAR2,
        pin_codadd01 VARCHAR2,
        pin_codadd02 VARCHAR2
    ) RETURN datatable_kardex_valorizado
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia   INTEGER,
        pin_tipinv   INTEGER,
        pin_codart   VARCHAR2,
        pin_anio     INTEGER,
        pin_mes      INTEGER,
        pin_moneda   VARCHAR2,
        pin_codadd01 VARCHAR2,
        pin_codadd02 VARCHAR2
    ) RETURN datatable_kardex_valorizado
        PIPELINED;

    -- NO SE USA, SOLO PARA VALIDACIONES
    -- DEFINE UNA FILA ADICIONAL CON EL ID = 'F', PARA CALCULAR LOS SUBTOTALES DEL REPORTE
    FUNCTION sp_buscar_test (
        pin_id_cia   INTEGER,
        pin_tipinv   INTEGER,
        pin_codart   VARCHAR2,
        pin_anio     INTEGER,
        pin_mes      INTEGER,
        pin_moneda   VARCHAR2,
        pin_codadd01 VARCHAR2,
        pin_codadd02 VARCHAR2
    ) RETURN datatable_kardex_valorizado
        PIPELINED;

--SELECT SUM(stockini),SUM(costotini),SUM(caning),SUM(costoting),SUM(cansal),SUM(costotsal),SUM(stockfinal),SUM(costotfin)
--    FROM pack_kardex_valorizado.sp_buscar(78,1,NULL,2022,11,'PEN',NULL,NULL)
--WHERE id = 'F'

--SELECT
--    k.*
--FROM
--    pack_kardex_valorizado.sp_buscar(78, 1, NULL, 2022, 12,
--                                     'PEN', NULL, NULL) k
--WHERE
--        k.id = 'F'
--    AND EXISTS (
--        SELECT
--            ac.*
--        FROM
--            articulos_costo ac
--        WHERE
--                ac.id_cia = 78
--            AND ac.periodo = 202212
--            AND ac.tipinv = k.tipinv
--            AND ac.codart = k.codart
--            AND ac.costo01 <> k.costotfin 
--    );

--SELECT * FROM pack_kardex_valorizado.sp_almacen(66,2022,12,1,'PEN');

    FUNCTION sp_almacen (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER,
        pin_mes     NUMBER,
        pin_tipinv  NUMBER,
        pin_tipmon  VARCHAR2
    ) RETURN datatable_almacen_valorizado
        PIPELINED;

END;

/

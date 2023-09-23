--------------------------------------------------------
--  DDL for Package PACK_RELACION_COSTO_VENTA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_RELACION_COSTO_VENTA" AS
    TYPE datarecord_detalle IS RECORD (
        id_cia  INTEGER,
        numint  INTEGER,
        numite  INTEGER,
        tipinv  INTEGER,
        codart  VARCHAR(40),
        desart  articulos.descri%TYPE,
        cantid  NUMERIC(16, 5),
        monexo  NUMERIC(16, 2),
        monina  NUMERIC(16, 2),
        monafe  NUMERIC(16, 2),
        codalm  INTEGER,
        clase18 VARCHAR(20),
        clase19 VARCHAR(20)
    );
    TYPE datatable_detalle IS
        TABLE OF datarecord_detalle;
    TYPE datarecord_costo_ventas IS RECORD (
        id_cia    INTEGER,
        tipinv    articulos.tipinv%TYPE,
        codart    articulos.codart%TYPE,
        desart    articulos.descri%TYPE,
        seriesfac documentos_cab.series%TYPE,
        numdocfac documentos_cab.numdoc%TYPE,
        numintfac documentos_cab.numint%TYPE,
        femisifac documentos_cab.femisi%TYPE,
        abrfac    documentos.nomser%TYPE,
        seriesgui documentos_cab.series%TYPE,
        numdocgui documentos_cab.numdoc%TYPE,
        numintgui documentos_cab.numint%TYPE,
        femisigui documentos_cab.femisi%TYPE,
        abrgui    documentos.nomser%TYPE,
        codfam    articulos_clase.codigo%TYPE,
        familia   VARCHAR2(20),
        desfam    VARCHAR2(200),
        codlin    articulos_clase.codigo%TYPE,
        linea     VARCHAR2(20),
        deslin    VARCHAR2(200),
        cantid    NUMBER(16, 4),
        tot01     NUMBER(16, 4),
        tot02     NUMBER(16, 4)
    );
    TYPE datatable_costo_ventas IS
        TABLE OF datarecord_costo_ventas;
    TYPE datarecord_leyenda IS RECORD (
        documento   tdoccobranza.descri%TYPE,
        motivo      motivos.desmot%TYPE,
        cantidad    NUMBER(38),
        costototsol NUMBER(20, 4),
        costototdol NUMBER(20, 4),
        ventatotsol NUMBER(20, 4),
        ventatotdol NUMBER(20, 4)
    );
    TYPE datatable_leyenda IS
        TABLE OF datarecord_leyenda;
    FUNCTION sp_resumen (
        pin_id_cia NUMBER,
        pin_tipinv NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_detalle
        PIPELINED;

    FUNCTION sp_resumen_utilidad (
        pin_id_cia NUMBER,
        pin_tipinv NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_detalle
        PIPELINED;

    FUNCTION sp_detalle (
        pin_id_cia NUMBER,
        pin_tipinv NUMBER,
        pin_tipdoc NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_costo_ventas
        PIPELINED;

    FUNCTION sp_leyenda (
        pin_id_cia NUMBER,
        pin_tipinv NUMBER,
        pin_tipdoc NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_leyenda
        PIPELINED;

END;

/

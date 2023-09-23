--------------------------------------------------------
--  DDL for Package PACK_PLE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_PLE" AS
    TYPE datarecord_ple_5_3 IS RECORD (
        cuenta  pcuentas.cuenta%TYPE,
        cdescri pcuentas.nombre%TYPE,
        codplan VARCHAR2(5),
        desplan VARCHAR2(5),
        estado  VARCHAR2(5)
    );
    TYPE datatable_ple_5_3 IS
        TABLE OF datarecord_ple_5_3;
    TYPE datarecord_ple_6_1_libro_mayor IS RECORD (
        mperiodo    INTEGER,
        mnumregope  VARCHAR(100),
        mcorrasien  VARCHAR(100),
        dcodplancon VARCHAR(5),
        libro       movimientos.libro%TYPE,
        asiento     movimientos.asiento%TYPE,
        tipo        movimientos.tipo%TYPE,
        docume      movimientos.docume%TYPE,
        mnumctacon  movimientos.cuenta%TYPE,
        mmoneda     movimientos.moneda%TYPE,
        mtident     cliente.tident%TYPE,
        mdident     cliente.dident%TYPE,
        mtdocum     VARCHAR(5 CHAR),
        mserie      VARCHAR(20 CHAR),
        mnumdoc     VARCHAR(20 CHAR),
        mfecope     VARCHAR(10),
        mfvenci     VARCHAR(10),
        mfdocum     VARCHAR(10),
        mglosa      movimientos.concep%TYPE,
        mdebe       NUMERIC(16, 2),
        mhaber      NUMERIC(16, 2),
        mcorrventas VARCHAR(100),
        mcorrcompra VARCHAR(100),
        mcorrconsig VARCHAR(100),
        mcodestruc  VARCHAR(100),
        estado      INTEGER
    );
    TYPE datatable_ple_6_1_libro_mayor IS
        TABLE OF datarecord_ple_6_1_libro_mayor;
    TYPE datarecord_ple_5_1_libro_diario IS RECORD (
        mperiodo    INTEGER,
        mnumregope  VARCHAR(100),
        mcorrasien  VARCHAR(100),
        dcodplancon VARCHAR(5),
        libro       movimientos.libro%TYPE,
        asiento     movimientos.asiento%TYPE,
        tipo        movimientos.tipo%TYPE,
        docume      movimientos.docume%TYPE,
        mnumctacon  movimientos.cuenta%TYPE,
        mmoneda     movimientos.moneda%TYPE,
        mtident     cliente.tident%TYPE,
        mdident     cliente.dident%TYPE,
        mtdocum     VARCHAR(5 CHAR),
        mserie      VARCHAR(20 CHAR),
        mnumdoc     VARCHAR(20 CHAR),
        mfecope     VARCHAR(10),
        mfvenci     VARCHAR(10),
        mfdocum     VARCHAR(10),
        mglosa      movimientos.concep%TYPE,
        mdebe       NUMERIC(16, 2),
        mhaber      NUMERIC(16, 2),
        mcorrventas VARCHAR(100),
        mcorrcompra VARCHAR(100),
        mcorrconsig VARCHAR(100),
        mcodestruc  VARCHAR(100),
        estado      INTEGER
    );
    TYPE datatable_ple_5_1_libro_diario IS
        TABLE OF datarecord_ple_5_1_libro_diario;
    FUNCTION sp_ple_6_1_libro_mayor (
        pin_id_cia           NUMBER,
        pin_periodo          NUMBER,
        pin_mes              NUMBER,
        pin_asiento_apertura VARCHAR2,
        pin_asiento_cierre   VARCHAR2
    ) RETURN datatable_ple_6_1_libro_mayor
        PIPELINED;

    FUNCTION sp_ple_5_1_libro_diario (
        pin_id_cia           NUMBER,
        pin_periodo          NUMBER,
        pin_mes              NUMBER,
        pin_asiento_apertura VARCHAR2,
        pin_asiento_cierre   VARCHAR2
    ) RETURN datatable_ple_5_1_libro_diario
        PIPELINED;

    FUNCTION sp_ple_5_3 (
        pin_id_cia    NUMBER,
        pin_periodo   NUMBER,
        pin_mes       NUMBER,
        pin_inccierre VARCHAR2
    ) RETURN datatable_ple_5_3
        PIPELINED;

END;

/

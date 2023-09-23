--------------------------------------------------------
--  DDL for Package PACK_ASIENDET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_ASIENDET" AS 

  /* TODO enter package declarations (types, exceptions, methods etc) here */ 
    TYPE t_ASIENDET IS TABLE OF ASIENDET%rowtype;


    /* TODO enter package declarations (types, exceptions, methods etc) here */ 
    PROCEDURE sp_save_ASIENDET (
        pin_id_cia   IN   NUMBER,
        pin_datos    IN   VARCHAR2,
        pin_opcdml   INTEGER,
        pin_mensaje  OUT  VARCHAR2
    );

      TYPE rec_asiento_apertura IS RECORD (

            id_cia number,
            periodo number,
            mes number,
            libro varchar2(120),
            asiento number,
            item number,
            sitem number,
            concep varchar2(120),
            fecha Date,
            tasien number,
            topera varchar2(120),
            cuenta varchar2(120),
            dh varchar2(120),
            moneda varchar2(120),
            importe number(16,2),
            impor01 number(16,2),
            impor02 number(16,2),
            debe number(16,2),
            debe01 number(16,2),
            debe02 number(16,2),
            haber number(16,2),
            haber01 number(16,2),
            haber02 number(16,2),
            tcambio01 number(16,2),
            tcambio02 number(16,2),
            ccosto varchar2(120),
            proyec varchar2(120),
            subcco varchar2(120),
            subccosto varchar2(120),
            tipo number,
            docume number,
            codigo varchar2(120),
            razon varchar2(120),
            tident varchar2(120),
            dident varchar2(120),
            tdocum varchar2(120),
            serie varchar2(120),
            numero varchar2(120),
            fdocum Date,
            usuari varchar2(120),
            fcreac Date,
            factua Date,
            regcomcol number,
            swprovicion varchar2(120),
            saldo number(16,2),
            swgasoper number,
            codporret varchar2(120),
            swchkconcilia varchar2(120),
            ctaalternativa varchar2(120)   

    );

    TYPE tbl_asiento_apertura IS
        TABLE OF rec_asiento_apertura;

    FUNCTION genera_asiento_apertura  (
        PIN_ID_CIA IN NUMBER
        , pin_periodo IN NUMBER
    ) RETURN tbl_asiento_apertura
        PIPELINED;

    FUNCTION genera_asiento_apertura_con_ajuste_final  (
        PIN_ID_CIA IN NUMBER
        , pin_periodo IN NUMBER
    ) RETURN tbl_asiento_apertura
        PIPELINED;



END PACK_ASIENDET;

/

--------------------------------------------------------
--  DDL for Type CONCILIACION_DETALLE_REC
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TYPE "USR_TSI_SUITE"."CONCILIACION_DETALLE_REC" AS OBJECT 
( 

          swchkconcilia      VARCHAR2(250),
          cuenta   VARCHAR2(250),
          codigo   VARCHAR2(250),
          razon  VARCHAR2(250),
          periodo   NUMBER,
          mes   NUMBER,
          fecha    DATE,
          libro    VARCHAR2(250),
          asiento  VARCHAR2(250),
          item     VARCHAR2(250),
          sitem    VARCHAR2(250),
          numero   VARCHAR2(250),
          moneda01   VARCHAR2(250),
          debe    NUMBER,
          haber   NUMBER,
          saldo   NUMBER,
          pendebe   NUMBER,
          penhaber   NUMBER,
          tipcam   NUMBER,
          concep   VARCHAR2(250),
          topera   VARCHAR2(250),
          destopera   VARCHAR2(250),
          periodocob   VARCHAR2(250),
          mescob  VARCHAR2(250),
          referencia   VARCHAR2(250),
          numeroref   VARCHAR2(250),
          coduser    VARCHAR2(250),
          usuario   VARCHAR2(250)


);

/

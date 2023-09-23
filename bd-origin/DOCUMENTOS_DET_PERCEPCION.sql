--------------------------------------------------------
--  DDL for Table DOCUMENTOS_DET_PERCEPCION
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."DOCUMENTOS_DET_PERCEPCION" 
   (	"ID_CIA" NUMBER(*,0), 
	"NUMINT" NUMBER(*,0), 
	"NUMITE" NUMBER(*,0), 
	"NUMINTFAC" NUMBER(*,0), 
	"TDOCUM" CHAR(2 BYTE), 
	"SERIE" VARCHAR2(5 BYTE), 
	"NUMERO" VARCHAR2(20 BYTE), 
	"FDOCUM" TIMESTAMP (6), 
	"MONEDA" VARCHAR2(3 BYTE), 
	"PORPER" NUMBER(16,2), 
	"PAGO" NUMBER(16,2), 
	"PAGO01" NUMBER(16,2), 
	"PAGO02" NUMBER(16,2), 
	"PERCEPCION" NUMBER(16,2), 
	"PERCEPCION01" NUMBER(16,2), 
	"PERCEPCION02" NUMBER(16,2), 
	"FCREAC" TIMESTAMP (6), 
	"FACTUA" TIMESTAMP (6), 
	"FCANCE" DATE, 
	"TIPCAM" NUMBER(10,6)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;

--------------------------------------------------------
--  DDL for Table BANCO010
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."BANCO010" 
   (	"ID_CIA" NUMBER(*,0), 
	"CODBAN" VARCHAR2(6 BYTE), 
	"NUMERO" NUMBER(*,0), 
	"PERIODO" NUMBER(*,0), 
	"MESPRO" NUMBER(*,0), 
	"FECHA" DATE, 
	"LIBRO" VARCHAR2(3 BYTE), 
	"ASIENTO" NUMBER(*,0), 
	"CUENTA" VARCHAR2(16 BYTE), 
	"CONCEP" VARCHAR2(60 BYTE), 
	"MONEDA" VARCHAR2(3 BYTE), 
	"IMPORTE" NUMBER(16,2), 
	"IMPOR01" NUMBER(16,2), 
	"IMPOR02" NUMBER(16,2), 
	"TCAMB01" NUMBER(14,6), 
	"TCAMB02" NUMBER(14,6), 
	"SITUAC" NUMBER(*,0), 
	"USUARI" VARCHAR2(10 BYTE), 
	"FCREAC" TIMESTAMP (6), 
	"FACTUA" TIMESTAMP (6)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;

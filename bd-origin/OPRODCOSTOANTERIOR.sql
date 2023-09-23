--------------------------------------------------------
--  DDL for Table OPRODCOSTOANTERIOR
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."OPRODCOSTOANTERIOR" 
   (	"ID_CIA" NUMBER(*,0), 
	"CARGO" VARCHAR2(8 BYTE), 
	"NUMITE" NUMBER(*,0), 
	"COSHOR" NUMBER(9,4), 
	"COSTER" NUMBER(9,4), 
	"COSMAT" NUMBER(9,4), 
	"GIF" NUMBER(9,4), 
	"SALDO" NUMBER(9,4), 
	"FCREAC" TIMESTAMP (6), 
	"FACTUA" TIMESTAMP (6), 
	"USUARI" VARCHAR2(10 BYTE), 
	"SWACTI" CHAR(1 BYTE)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;

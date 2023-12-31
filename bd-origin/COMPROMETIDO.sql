--------------------------------------------------------
--  DDL for Table COMPROMETIDO
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."COMPROMETIDO" 
   (	"ID_CIA" NUMBER(*,0), 
	"LOCALI" NUMBER(*,0), 
	"ID" CHAR(1 BYTE), 
	"TIPDOC" NUMBER(*,0), 
	"NUMINT" NUMBER(*,0), 
	"NUMITE" NUMBER(*,0), 
	"FEMISI" DATE, 
	"TIPINV" NUMBER(*,0), 
	"CODART" VARCHAR2(40 BYTE), 
	"CODADD01" VARCHAR2(10 BYTE), 
	"CODADD02" VARCHAR2(10 BYTE), 
	"CANTID" NUMBER(16,4), 
	"CODALM" NUMBER(*,0), 
	"FCREAC" TIMESTAMP (6), 
	"FACTUA" TIMESTAMP (6), 
	"USUARI" VARCHAR2(10 BYTE), 
	"NUMINTCO" NUMBER(*,0), 
	"NUMITECO" NUMBER(*,0)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;

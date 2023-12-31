--------------------------------------------------------
--  DDL for Table ORDEPRODCAB
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."ORDEPRODCAB" 
   (	"ID_CIA" NUMBER(*,0), 
	"NUMINT" NUMBER(*,0), 
	"TIPDOC" NUMBER(*,0), 
	"SERIES" VARCHAR2(5 BYTE), 
	"NUMDOC" NUMBER(*,0), 
	"PERIODO" NUMBER(*,0), 
	"CARGO" VARCHAR2(10 BYTE), 
	"ORDCOM" VARCHAR2(10 BYTE), 
	"PEDVEN" VARCHAR2(10 BYTE), 
	"FEMISI" DATE, 
	"FSOLTIE" DATE, 
	"FDIGPLA" DATE, 
	"FPROENT" DATE, 
	"CODCLI" VARCHAR2(20 BYTE), 
	"ORDTIE" VARCHAR2(10 BYTE), 
	"FENTREG" DATE, 
	"FLIQUID" DATE, 
	"CODPRO" NUMBER(*,0), 
	"SITUAC" CHAR(1 BYTE), 
	"OBSERV" VARCHAR2(1000 BYTE), 
	"ENTEXA" CHAR(1 BYTE), 
	"CODVEN" NUMBER(*,0), 
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

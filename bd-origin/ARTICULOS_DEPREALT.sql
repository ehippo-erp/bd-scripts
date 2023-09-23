--------------------------------------------------------
--  DDL for Table ARTICULOS_DEPREALT
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."ARTICULOS_DEPREALT" 
   (	"ID_CIA" NUMBER(*,0), 
	"LOCALI" NUMBER(*,0), 
	"ID" CHAR(1 BYTE), 
	"TIPDOC" NUMBER(*,0), 
	"NUMINT" NUMBER(*,0), 
	"NUMITE" NUMBER(*,0), 
	"PERIODO" NUMBER(*,0), 
	"MES" NUMBER(*,0), 
	"CODMOT" NUMBER(*,0), 
	"FEMISI" DATE, 
	"TIPINV" NUMBER(*,0), 
	"CODART" VARCHAR2(40 BYTE), 
	"CANTID" NUMBER(16,4), 
	"COSTOT01" NUMBER(16,2), 
	"COSTOT02" NUMBER(16,2), 
	"SITUAC" CHAR(1 BYTE), 
	"FCREAC" TIMESTAMP (6), 
	"FACTUA" TIMESTAMP (6), 
	"USUARI" VARCHAR2(10 BYTE), 
	"SWACTI" CHAR(1 BYTE), 
	"TIPCAM" NUMBER(11,4), 
	"ACUMU01" NUMBER(16,2), 
	"ACUMU02" NUMBER(16,2), 
	"MEJORA01" NUMBER(16,2), 
	"MEJORA02" NUMBER(16,2)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;

--------------------------------------------------------
--  DDL for Table TIEMPOS_CAB
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."TIEMPOS_CAB" 
   (	"ID_CIA" NUMBER(*,0), 
	"NUMINT" NUMBER(*,0), 
	"NUMDOC" VARCHAR2(20 BYTE), 
	"FEMISI" DATE, 
	"TIPCAM" NUMBER(10,6), 
	"CODMAE" VARCHAR2(20 BYTE), 
	"CODOPE" VARCHAR2(20 BYTE), 
	"SITUAC" CHAR(1 BYTE), 
	"FCREAC" TIMESTAMP (6), 
	"FACTUA" TIMESTAMP (6), 
	"USUARI" VARCHAR2(10 BYTE)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;

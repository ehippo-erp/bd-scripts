--------------------------------------------------------
--  DDL for Table FE_RESUMENDIARIO_DET
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."FE_RESUMENDIARIO_DET" 
   (	"ID_CIA" NUMBER(*,0), 
	"IDRES" NUMBER(*,0), 
	"NUMINT" NUMBER(*,0), 
	"TIPDOC" NUMBER(*,0), 
	"SERIES" VARCHAR2(5 BYTE), 
	"NUMDOC" NUMBER(*,0), 
	"ESTADO" VARCHAR2(1 BYTE)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;

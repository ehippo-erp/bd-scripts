--------------------------------------------------------
--  DDL for Table ORDPRODPROC
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."ORDPRODPROC" 
   (	"ID_CIA" NUMBER(*,0), 
	"NUMPROC" NUMBER(*,0), 
	"OPNUMDOC" NUMBER(*,0), 
	"OPCARGO" VARCHAR2(10 BYTE), 
	"NUMITE" NUMBER(*,0), 
	"NUMINT" NUMBER(*,0), 
	"TIPDOC" NUMBER(*,0), 
	"CODPROC" NUMBER(*,0), 
	"FCREAC" DATE, 
	"USUARI" VARCHAR2(10 BYTE)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;

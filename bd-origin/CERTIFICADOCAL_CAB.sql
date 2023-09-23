--------------------------------------------------------
--  DDL for Table CERTIFICADOCAL_CAB
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."CERTIFICADOCAL_CAB" 
   (	"ID_CIA" NUMBER(*,0), 
	"NUMINT" NUMBER(*,0), 
	"FEMISI" DATE, 
	"SITUAC" CHAR(1 BYTE), 
	"CODCLI" VARCHAR2(20 BYTE), 
	"CODESTRUC" NUMBER(*,0), 
	"REFERENCIA" VARCHAR2(50 BYTE), 
	"OPNUMINT" NUMBER(*,0), 
	"UCREAC" VARCHAR2(10 BYTE), 
	"FCREAC" TIMESTAMP (6), 
	"UACTUA" VARCHAR2(10 BYTE), 
	"FACTUA" TIMESTAMP (6), 
	"OCFECHA" DATE, 
	"USOCANTID" NUMBER(*,0), 
	"OCNUMERO" VARCHAR2(20 BYTE), 
	"UFIRMA" VARCHAR2(10 CHAR)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;
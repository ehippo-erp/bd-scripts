--------------------------------------------------------
--  DDL for Table BANCO005
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."BANCO005" 
   (	"ID_CIA" NUMBER(*,0), 
	"CODOPE" VARCHAR2(3 BYTE), 
	"DESCRI" VARCHAR2(35 BYTE), 
	"CUENTA" VARCHAR2(16 BYTE), 
	"DOCORI" NUMBER(*,0), 
	"REFERE" NUMBER(*,0), 
	"EMIDOC" NUMBER(*,0), 
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
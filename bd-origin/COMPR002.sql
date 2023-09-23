--------------------------------------------------------
--  DDL for Table COMPR002
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."COMPR002" 
   (	"ID_CIA" NUMBER(*,0), 
	"TIDENT" CHAR(2 BYTE), 
	"DIDENT" VARCHAR2(16 BYTE), 
	"TPERSO" NUMBER(*,0), 
	"RAZONC" VARCHAR2(120 BYTE), 
	"APPAT" VARCHAR2(40 BYTE), 
	"APMAT" VARCHAR2(40 BYTE), 
	"NOMBR" VARCHAR2(40 BYTE), 
	"FEMISI" TIMESTAMP (6), 
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

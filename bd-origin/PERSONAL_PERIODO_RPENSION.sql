--------------------------------------------------------
--  DDL for Table PERSONAL_PERIODO_RPENSION
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."PERSONAL_PERIODO_RPENSION" 
   (	"ID_CIA" NUMBER, 
	"CODPER" VARCHAR2(20 BYTE), 
	"CODAFP" VARCHAR2(4 BYTE), 
	"ID_PRPEN" NUMBER(*,0), 
	"FINICIO" DATE, 
	"FFINAL" DATE, 
	"UCREAC" VARCHAR2(10 BYTE), 
	"UACTUA" VARCHAR2(10 BYTE), 
	"FCREAC" TIMESTAMP (6), 
	"FACTUA" TIMESTAMP (6)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;

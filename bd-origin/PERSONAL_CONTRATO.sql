--------------------------------------------------------
--  DDL for Table PERSONAL_CONTRATO
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."PERSONAL_CONTRATO" 
   (	"ID_CIA" NUMBER, 
	"CODPER" VARCHAR2(20 BYTE), 
	"NROCON" NUMBER(*,0), 
	"FINICIO" DATE, 
	"FFIN" DATE, 
	"FTERMINO" DATE, 
	"DURACION" NUMBER, 
	"COUNTADJ" NUMBER, 
	"OBSERV" VARCHAR2(4000 CHAR), 
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

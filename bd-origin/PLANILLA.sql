--------------------------------------------------------
--  DDL for Table PLANILLA
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."PLANILLA" 
   (	"ID_CIA" NUMBER, 
	"NUMPLA" NUMBER, 
	"TIPPLA" VARCHAR2(1 CHAR), 
	"EMPOBR" VARCHAR2(1 CHAR), 
	"ANOPLA" NUMBER, 
	"MESPLA" NUMBER, 
	"SEMPLA" NUMBER, 
	"FECINI" DATE, 
	"FECFIN" DATE, 
	"DIANOR" NUMBER, 
	"HORNOR" NUMBER, 
	"TCAMBIO" NUMBER(10,6), 
	"SITUAC" VARCHAR2(1 CHAR), 
	"UCREAC" VARCHAR2(10 CHAR), 
	"UACTUA" VARCHAR2(10 CHAR), 
	"FCREAC" TIMESTAMP (6), 
	"FACTUA" TIMESTAMP (6)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;

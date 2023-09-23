--------------------------------------------------------
--  DDL for Table FUNCION_PLANILLA
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."FUNCION_PLANILLA" 
   (	"ID_CIA" NUMBER, 
	"CODFUN" NUMBER(*,0), 
	"NOMBRE" VARCHAR2(50 BYTE), 
	"NOMFUN" VARCHAR2(60 BYTE), 
	"TIPFUN" NUMBER, 
	"NUMMES" NUMBER, 
	"PACTUAL" VARCHAR2(1 CHAR), 
	"MACTUAL" VARCHAR2(1 CHAR), 
	"OBSERV" VARCHAR2(2000 BYTE), 
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

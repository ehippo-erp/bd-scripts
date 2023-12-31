--------------------------------------------------------
--  DDL for Table FACTOR_CLASE_PLANILLA
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."FACTOR_CLASE_PLANILLA" 
   (	"ID_CIA" NUMBER, 
	"CODFAC" VARCHAR2(3 BYTE), 
	"CODCLA" VARCHAR2(10 BYTE), 
	"TIPCLA" NUMBER, 
	"TIPVAR" VARCHAR2(1 CHAR), 
	"NOMBRE" VARCHAR2(50 BYTE), 
	"VREAL" NUMBER(9,2), 
	"VSTRG" VARCHAR2(30 BYTE), 
	"VCHAR" CHAR(1 BYTE), 
	"VDATE" DATE, 
	"VTIME" TIMESTAMP (6), 
	"VENTERO" NUMBER(*,0), 
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

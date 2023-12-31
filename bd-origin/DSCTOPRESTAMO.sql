--------------------------------------------------------
--  DDL for Table DSCTOPRESTAMO
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."DSCTOPRESTAMO" 
   (	"ID_CIA" NUMBER, 
	"ID_PRE" NUMBER(*,0), 
	"NUMPLA" NUMBER, 
	"CODPER" VARCHAR2(20 CHAR), 
	"FECDES" DATE, 
	"VALCUO" NUMBER(15,4), 
	"APLICA" VARCHAR2(1 BYTE), 
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

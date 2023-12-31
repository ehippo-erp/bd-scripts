--------------------------------------------------------
--  DDL for Table CLASE_CONCEPTO
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."CLASE_CONCEPTO" 
   (	"ID_CIA" NUMBER, 
	"CLASE" NUMBER(*,0), 
	"DESCRI" VARCHAR2(100 BYTE), 
	"INDSUBCOD" VARCHAR2(1 CHAR) DEFAULT 'N', 
	"INDROTULO" VARCHAR2(1 CHAR) DEFAULT 'N', 
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

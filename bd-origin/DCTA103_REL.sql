--------------------------------------------------------
--  DDL for Table DCTA103_REL
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."DCTA103_REL" 
   (	"ID_CIA" NUMBER(*,0), 
	"LIBRO" VARCHAR2(3 BYTE), 
	"PERIODO" NUMBER(*,0), 
	"MES" NUMBER(*,0), 
	"SECUENCIA" NUMBER(*,0), 
	"ITEM" NUMBER(*,0), 
	"R_LIBRO" VARCHAR2(3 BYTE), 
	"R_PERIODO" NUMBER(*,0), 
	"R_MES" NUMBER(*,0), 
	"R_SECUENCIA" NUMBER(*,0), 
	"R_ITEM" NUMBER(*,0), 
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
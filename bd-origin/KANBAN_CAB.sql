--------------------------------------------------------
--  DDL for Table KANBAN_CAB
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."KANBAN_CAB" 
   (	"ID_CIA" NUMBER(*,0), 
	"CODKAN" VARCHAR2(20 BYTE), 
	"TIPINV" NUMBER(*,0), 
	"CODALM" NUMBER(*,0), 
	"DESCRI" VARCHAR2(100 BYTE), 
	"SWACTI" CHAR(1 BYTE), 
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

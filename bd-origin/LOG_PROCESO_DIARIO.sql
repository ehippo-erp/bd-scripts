--------------------------------------------------------
--  DDL for Table LOG_PROCESO_DIARIO
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."LOG_PROCESO_DIARIO" 
   (	"ID_CIA" NUMBER, 
	"ID_LOG" NUMBER, 
	"SITUAC" VARCHAR2(1 BYTE), 
	"PROCESO" VARCHAR2(100 BYTE), 
	"MENSAJE" VARCHAR2(4000 BYTE), 
	"FCREAC" TIMESTAMP (6), 
	"FACTUA" TIMESTAMP (6)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;

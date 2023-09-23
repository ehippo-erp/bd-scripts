--------------------------------------------------------
--  DDL for Table KARDEX001_IMPR
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."KARDEX001_IMPR" 
   (	"ID_CIA" NUMBER(*,0), 
	"TIPINV" NUMBER(*,0), 
	"CODART" VARCHAR2(40 BYTE), 
	"ETIQUETA" VARCHAR2(100 BYTE), 
	"FCREAC" TIMESTAMP (6), 
	"CODUSER" VARCHAR2(10 BYTE), 
	"COMENT" VARCHAR2(75 BYTE)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;

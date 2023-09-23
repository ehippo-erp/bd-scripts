--------------------------------------------------------
--  DDL for Table CALIDAD
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."CALIDAD" 
   (	"ID_CIA" NUMBER(*,0), 
	"CODIGO" VARCHAR2(10 BYTE), 
	"DESCRI" VARCHAR2(50 BYTE), 
	"ABREVI" VARCHAR2(10 BYTE), 
	"EQUIVA" VARCHAR2(50 BYTE)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;

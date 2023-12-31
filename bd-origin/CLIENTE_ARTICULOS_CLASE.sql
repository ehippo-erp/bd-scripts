--------------------------------------------------------
--  DDL for Table CLIENTE_ARTICULOS_CLASE
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."CLIENTE_ARTICULOS_CLASE" 
   (	"ID_CIA" NUMBER(*,0), 
	"TIPCLI" VARCHAR2(1 BYTE), 
	"CODCLI" VARCHAR2(20 BYTE), 
	"CLASE" NUMBER(*,0), 
	"CODIGO" VARCHAR2(20 BYTE), 
	"DESCRI" VARCHAR2(100 BYTE), 
	"ABREVI" VARCHAR2(10 BYTE), 
	"SITUAC" VARCHAR2(1 BYTE)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;

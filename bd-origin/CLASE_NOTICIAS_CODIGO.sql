--------------------------------------------------------
--  DDL for Table CLASE_NOTICIAS_CODIGO
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."CLASE_NOTICIAS_CODIGO" 
   (	"ID_CIA" NUMBER(*,0), 
	"CLASE" NUMBER(*,0), 
	"CODIGO" VARCHAR2(20 BYTE), 
	"DESCRI" VARCHAR2(60 BYTE), 
	"ABREVI" VARCHAR2(6 BYTE), 
	"SITUAC" CHAR(1 BYTE), 
	"FCREAC" TIMESTAMP (6), 
	"FACTUA" TIMESTAMP (6), 
	"USUARI" VARCHAR2(10 BYTE), 
	"SWDEFAUL" VARCHAR2(1 BYTE)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;

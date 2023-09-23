--------------------------------------------------------
--  DDL for Table DESTINO_VENTAS
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."DESTINO_VENTAS" 
   (	"ID_CIA" NUMBER(*,0), 
	"CODDES" NUMBER(*,0), 
	"DESCRI" VARCHAR2(20 BYTE), 
	"ABREVI" VARCHAR2(3 BYTE), 
	"FCREAC" TIMESTAMP (6), 
	"FACTUA" TIMESTAMP (6), 
	"USUARI" VARCHAR2(10 BYTE), 
	"SWACTI" CHAR(1 BYTE)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;

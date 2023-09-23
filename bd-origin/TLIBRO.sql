--------------------------------------------------------
--  DDL for Table TLIBRO
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."TLIBRO" 
   (	"ID_CIA" NUMBER(*,0), 
	"CODLIB" VARCHAR2(3 BYTE), 
	"DESCRI" VARCHAR2(50 BYTE), 
	"MONEDA01" VARCHAR2(3 BYTE), 
	"MONEDA02" VARCHAR2(3 BYTE), 
	"DESTINO" NUMBER(*,0), 
	"ABREVI" VARCHAR2(6 BYTE), 
	"USUARIO" VARCHAR2(10 BYTE), 
	"SWACTI" CHAR(1 BYTE), 
	"FCREAC" TIMESTAMP (6), 
	"FACTUA" TIMESTAMP (6), 
	"FILTRO" VARCHAR2(40 BYTE), 
	"MOTIVO" NUMBER(*,0)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;

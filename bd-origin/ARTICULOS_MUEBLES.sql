--------------------------------------------------------
--  DDL for Table ARTICULOS_MUEBLES
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."ARTICULOS_MUEBLES" 
   (	"ID_CIA" NUMBER(*,0), 
	"TIPINV" NUMBER(*,0), 
	"CODART" VARCHAR2(40 BYTE), 
	"PLANO" VARCHAR2(6 BYTE), 
	"FULTPLANO" DATE, 
	"LARGO" NUMBER(9,4), 
	"ANCHO" NUMBER(9,4), 
	"ALTURA" NUMBER(9,4), 
	"PESO" NUMBER(9,4), 
	"PESEMB" NUMBER(9,4), 
	"LOTE" NUMBER(*,0), 
	"FACTOR" NUMBER(9,5), 
	"DESPER" NUMBER(9,4), 
	"STOMIN" NUMBER(9,2), 
	"STOMAX" NUMBER(9,2), 
	"ROTACI" NUMBER(*,0), 
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

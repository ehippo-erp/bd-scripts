--------------------------------------------------------
--  DDL for Table DOCUMENTOS_MATERIALES
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."DOCUMENTOS_MATERIALES" 
   (	"ID_CIA" NUMBER(*,0), 
	"NUMINT" NUMBER(*,0), 
	"NUMITE" NUMBER(*,0), 
	"NUMSEC" NUMBER(*,0), 
	"TIPINV" NUMBER(*,0), 
	"CODART" VARCHAR2(40 BYTE), 
	"CODALM" NUMBER(*,0), 
	"CANTID" NUMBER(16,5), 
	"PREUNI" NUMBER(16,5), 
	"PORDES1" NUMBER(9,5), 
	"PORDES2" NUMBER(9,5), 
	"PORDES3" NUMBER(9,5), 
	"PORDES4" NUMBER(9,5), 
	"LARGO" NUMBER(9,3), 
	"ANCHO" NUMBER(9,3), 
	"ALTURA" NUMBER(9,3), 
	"ETAPA" NUMBER(*,0), 
	"ETAPAUSO" NUMBER(*,0), 
	"OBSERV" VARCHAR2(1000 BYTE), 
	"STOCKREF" NUMBER(16,5), 
	"FSTOCKREF" TIMESTAMP (6), 
	"SITUAC" CHAR(1 BYTE), 
	"USUARI" VARCHAR2(10 BYTE), 
	"FCREAC" TIMESTAMP (6), 
	"FACTUA" TIMESTAMP (6), 
	"CODPRV" VARCHAR2(20 BYTE), 
	"POSITI" NUMBER(*,0), 
	"PEDIDO" NUMBER(16,5), 
	"CANT_OJO" NUMBER(*,0), 
	"CANT_OJO_GCABLE" NUMBER(*,0), 
	"CODADD01" VARCHAR2(10 BYTE), 
	"CODADD02" VARCHAR2(10 BYTE), 
	"SWIMPORTA" VARCHAR2(1 BYTE), 
	"PCOSTO" NUMBER(16,5), 
	"CPORDES1" NUMBER(9,5), 
	"CPORDES2" NUMBER(9,5), 
	"CPORDES3" NUMBER(9,5), 
	"CPORDES4" NUMBER(9,5), 
	"SWCOMPR" VARCHAR2(1 BYTE)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;
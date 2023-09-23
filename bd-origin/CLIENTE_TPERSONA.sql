--------------------------------------------------------
--  DDL for Table CLIENTE_TPERSONA
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."CLIENTE_TPERSONA" 
   (	"ID_CIA" NUMBER(*,0), 
	"CODCLI" VARCHAR2(20 BYTE), 
	"APEPAT" VARCHAR2(30 CHAR), 
	"APEMAT" VARCHAR2(30 CHAR), 
	"NOMBRE" VARCHAR2(35 CHAR), 
	"SEXO" CHAR(1 BYTE), 
	"FNACIM" DATE, 
	"EDAD" NUMBER(*,0), 
	"CODECI" NUMBER(*,0), 
	"EMAIL" VARCHAR2(50 BYTE), 
	"TELEFO" VARCHAR2(30 BYTE), 
	"CELULA" VARCHAR2(30 BYTE), 
	"NRODNI" VARCHAR2(20 BYTE), 
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
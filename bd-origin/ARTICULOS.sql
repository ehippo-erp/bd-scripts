--------------------------------------------------------
--  DDL for Table ARTICULOS
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."ARTICULOS" 
   (	"ID_CIA" NUMBER(*,0), 
	"TIPINV" NUMBER(*,0), 
	"CODART" VARCHAR2(40 BYTE), 
	"DESCRI" VARCHAR2(100 CHAR), 
	"CODMAR" NUMBER(*,0), 
	"CODUBI" NUMBER(*,0), 
	"CODPRC" NUMBER(*,0), 
	"CODMOD" NUMBER(*,0), 
	"MODELO" VARCHAR2(50 BYTE), 
	"CODOBS" NUMBER(*,0), 
	"CODUNI" VARCHAR2(3 BYTE), 
	"CODLIN" NUMBER(*,0), 
	"CODORI" VARCHAR2(40 BYTE), 
	"CODFAM" NUMBER(*,0), 
	"CODBAR" VARCHAR2(40 BYTE), 
	"PARARA" VARCHAR2(30 BYTE), 
	"PROART" VARCHAR2(50 BYTE), 
	"CONSTO" NUMBER(*,0), 
	"CODPRV" VARCHAR2(20 BYTE), 
	"AGRUPA" CHAR(1 BYTE), 
	"FCREAC" TIMESTAMP (6), 
	"FMATRI" TIMESTAMP (6), 
	"FACTUA" TIMESTAMP (6), 
	"USUARI" VARCHAR2(10 BYTE), 
	"SWACTI" CHAR(1 BYTE), 
	"WGLOSA" VARCHAR2(250 BYTE), 
	"FACCON" NUMBER(9,5), 
	"TUSOESP" NUMBER(*,0), 
	"TUSOING" NUMBER(*,0), 
	"DIACMM" NUMBER(9,4), 
	"CUENTA" VARCHAR2(16 BYTE), 
	"CONESP" NUMBER(*,0), 
	"LINEA" VARCHAR2(50 BYTE), 
	"PROINT" CHAR(1 BYTE), 
	"CODINT" VARCHAR2(40 BYTE), 
	"CODOPE" NUMBER(*,0), 
	"SITUAC" CHAR(1 BYTE), 
	"SIM" VARCHAR2(20 BYTE), 
	"TSYSTEM" VARCHAR2(20 BYTE), 
	"DESCRI2" VARCHAR2(100 BYTE)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;
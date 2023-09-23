--------------------------------------------------------
--  DDL for Table ORDEPRODDET
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."ORDEPRODDET" 
   (	"ID_CIA" NUMBER(*,0), 
	"NUMINT" NUMBER(*,0), 
	"NUMITE" NUMBER(*,0), 
	"TIPDOC" NUMBER(*,0), 
	"SERIES" VARCHAR2(5 BYTE), 
	"NUMDOC" NUMBER(*,0), 
	"CARGO" VARCHAR2(10 BYTE), 
	"TIPINV" NUMBER(*,0), 
	"CODART" VARCHAR2(40 BYTE), 
	"OBSERV" VARCHAR2(1000 BYTE), 
	"LINEA" VARCHAR2(50 BYTE), 
	"MODELO" VARCHAR2(50 BYTE), 
	"COLOR" VARCHAR2(50 BYTE), 
	"CODTAP" VARCHAR2(8 BYTE), 
	"TAPIZ" VARCHAR2(50 BYTE), 
	"CODAUX" VARCHAR2(3 BYTE), 
	"AUXILIAR" VARCHAR2(50 BYTE), 
	"LARGO" NUMBER(9,3), 
	"ANCHO" NUMBER(9,3), 
	"ALTURA" NUMBER(9,3), 
	"CANTID" NUMBER(11,2), 
	"SALDO" NUMBER(11,2), 
	"STOCK" CHAR(1 BYTE), 
	"SITUAC" CHAR(1 BYTE), 
	"CODOPE" NUMBER(*,0), 
	"FCREAC" TIMESTAMP (6), 
	"FACTUA" TIMESTAMP (6), 
	"USUARI" VARCHAR2(10 BYTE), 
	"SWACTI" CHAR(1 BYTE), 
	"WGLOSA" VARCHAR2(250 BYTE), 
	"CORTE" CHAR(1 BYTE), 
	"SWPRC" NUMBER(*,0), 
	"SWTRA" NUMBER(*,0), 
	"SWAVA" NUMBER(*,0), 
	"SWRPT001" NUMBER(*,0), 
	"FECTERMINADO" DATE, 
	"TERMINADO" CHAR(1 BYTE), 
	"FELIQUIDO" DATE, 
	"LIQUIDADO" CHAR(1 BYTE)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;

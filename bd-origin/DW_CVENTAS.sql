--------------------------------------------------------
--  DDL for Table DW_CVENTAS
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."DW_CVENTAS" 
   (	"ID_CIA" NUMBER(*,0), 
	"NUMINTFAC" NUMBER(*,0), 
	"NUMITEFAC" NUMBER(*,0), 
	"TIPDOC" NUMBER(*,0), 
	"TIPODOCUMENTO" VARCHAR2(120 BYTE), 
	"ID" VARCHAR2(1 CHAR), 
	"CODMOT" NUMBER(*,0), 
	"CODSUC" NUMBER(*,0), 
	"SUCURSAL" VARCHAR2(120 BYTE), 
	"DIASEMANA" VARCHAR2(25 BYTE), 
	"MES" VARCHAR2(25 BYTE), 
	"PERIODO" NUMBER(*,0), 
	"IDMES" NUMBER(*,0), 
	"MESID" NUMBER(*,0), 
	"SERIES" VARCHAR2(10 BYTE), 
	"NUMDOC" NUMBER(*,0), 
	"FEMISI" DATE, 
	"TIPCAM" NUMBER(20,8) DEFAULT 0, 
	"CODCPAG" NUMBER(*,0), 
	"CODCLI" VARCHAR2(20 BYTE), 
	"CLIENTE" VARCHAR2(120 BYTE), 
	"RUC" VARCHAR2(20 BYTE), 
	"CODVENCAR" NUMBER(*,0), 
	"CODVENDOC" NUMBER(*,0), 
	"MONEDA" VARCHAR2(120 BYTE), 
	"TIPINV" NUMBER(*,0), 
	"CODART" VARCHAR2(40 BYTE), 
	"ETIQUETA" VARCHAR2(200 BYTE), 
	"CODADD01" VARCHAR2(10 BYTE), 
	"CODADD02" VARCHAR2(10 BYTE), 
	"SIGNO" NUMBER(*,0), 
	"CANTID" NUMBER(20,8) DEFAULT 0, 
	"CSTSOL" NUMBER(20,8) DEFAULT 0, 
	"CSTDOL" NUMBER(20,8) DEFAULT 0, 
	"PRUSOL" NUMBER(20,8) DEFAULT 0, 
	"PRUDOL" NUMBER(20,8) DEFAULT 0, 
	"VNTSOL" NUMBER(20,8) DEFAULT 0, 
	"VNTDOL" NUMBER(20,8) DEFAULT 0, 
	"PORCOM" NUMBER(20,8) DEFAULT 0, 
	"PORIGV" NUMBER(20,8), 
	"IGVSOL" NUMBER(20,8) DEFAULT 0, 
	"IGVDOL" NUMBER(20,8) DEFAULT 0, 
	"FCREAC" TIMESTAMP (6), 
	"FACTUA" TIMESTAMP (6), 
	"ESTACIONAL" VARCHAR2(1 BYTE) DEFAULT 'N'
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;

--------------------------------------------------------
--  DDL for Table CVENTAS
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."CVENTAS" 
   (	"ID_CIA" NUMBER(*,0), 
	"NUMINTFAC" NUMBER(*,0), 
	"TIPDOC" VARCHAR2(50 BYTE), 
	"SUCURSAL" VARCHAR2(50 BYTE), 
	"MES" VARCHAR2(50 BYTE), 
	"PERIODO" NUMBER(*,0), 
	"MESID" NUMBER(*,0), 
	"SERIES" VARCHAR2(10 BYTE), 
	"NUMDOC" NUMBER(*,0), 
	"FEMISI" VARCHAR2(20 BYTE), 
	"TIPCAM" NUMBER(10,6), 
	"CODCLI" VARCHAR2(20 BYTE), 
	"CLIENTE" VARCHAR2(100 BYTE), 
	"RUC" VARCHAR2(50 BYTE), 
	"DESPAG" VARCHAR2(50 BYTE), 
	"CODVEN" NUMBER(*,0), 
	"VENDEDOR" VARCHAR2(50 BYTE), 
	"MONEDA" VARCHAR2(50 BYTE), 
	"TIPINV" NUMBER(*,0), 
	"CODIGO" VARCHAR2(40 BYTE), 
	"DESCRI" VARCHAR2(100 BYTE), 
	"CODADD01" VARCHAR2(10 BYTE), 
	"DCODADD01" VARCHAR2(50 BYTE), 
	"CODADD02" VARCHAR2(10 BYTE), 
	"DCODADD02" VARCHAR2(50 BYTE), 
	"CANTID" NUMBER(16,5), 
	"FACCON" NUMBER(9,5), 
	"TONELADAS" NUMBER(10,3), 
	"COSSOL" NUMBER(16,5), 
	"COSDOL" NUMBER(16,5), 
	"CSTSOL" NUMBER(16,2), 
	"CSTDOL" NUMBER(16,2), 
	"PRUSOL" NUMBER(16,5), 
	"PRUDOL" NUMBER(16,5), 
	"VNTSOL" NUMBER(16,2), 
	"VNTDOL" NUMBER(16,2), 
	"PORCOM" FLOAT(126), 
	"TIPVNT" VARCHAR2(50 BYTE), 
	"DESTIN" VARCHAR2(20 BYTE), 
	"CODENV" NUMBER(*,0), 
	"DESENV" VARCHAR2(50 BYTE), 
	"CIA" NUMBER(*,0), 
	"MOTIVO" VARCHAR2(50 BYTE), 
	"ANCHO" NUMBER(9,3), 
	"PORIGV" NUMBER(16,2), 
	"IGVSOL" NUMBER(16,2), 
	"IGVDOL" NUMBER(16,2), 
	"ETIQUETA" VARCHAR2(100 BYTE), 
	"CTIPDOC" NUMBER(*,0)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;

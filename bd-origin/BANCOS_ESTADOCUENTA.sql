--------------------------------------------------------
--  DDL for Table BANCOS_ESTADOCUENTA
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."BANCOS_ESTADOCUENTA" 
   (	"ID_CIA" NUMBER(*,0), 
	"B_CUENTA" VARCHAR2(16 BYTE), 
	"B_PERIODO" NUMBER(*,0), 
	"B_MES" NUMBER(*,0), 
	"B_NUMITE" NUMBER(*,0), 
	"B_FECHA" DATE, 
	"B_CONCEPTO" VARCHAR2(100 BYTE), 
	"B_DH" CHAR(1 BYTE), 
	"B_IMPORTE" NUMBER(16,2), 
	"M_CUENTA" VARCHAR2(16 BYTE), 
	"M_PERIODO" NUMBER(*,0), 
	"M_MES" NUMBER(*,0), 
	"M_LIBRO" VARCHAR2(3 BYTE), 
	"M_ASIENTO" NUMBER(*,0), 
	"M_ITEM" NUMBER(*,0), 
	"M_SITEM" NUMBER(*,0), 
	"FCREAC" TIMESTAMP (6), 
	"FACTUA" TIMESTAMP (6), 
	"USUARI" VARCHAR2(10 BYTE), 
	"SWCHKCONCILIA" VARCHAR2(1 BYTE)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;
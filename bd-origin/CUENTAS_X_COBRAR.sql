--------------------------------------------------------
--  DDL for Table CUENTAS_X_COBRAR
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."CUENTAS_X_COBRAR" 
   (	"ID_CIA" NUMBER(*,0), 
	"CODCLI" VARCHAR2(20 BYTE), 
	"CLIENTE" VARCHAR2(100 BYTE), 
	"DTIPDOC" VARCHAR2(50 BYTE), 
	"DOCUMENTO" VARCHAR2(20 BYTE), 
	"CODVEN" NUMBER(*,0), 
	"SUCURSAL" VARCHAR2(50 BYTE), 
	"UBICACION" VARCHAR2(50 BYTE), 
	"FEMISI" VARCHAR2(20 BYTE), 
	"FVENCI" VARCHAR2(20 BYTE), 
	"DIAS" NUMBER(*,0), 
	"MONEDA" VARCHAR2(3 BYTE), 
	"TIPCAM" FLOAT(126), 
	"IMPORTE" FLOAT(126), 
	"SALDOSOL" FLOAT(126), 
	"SALDODOL" FLOAT(126), 
	"SALDODOLAR" FLOAT(126), 
	"VENCIDOS" FLOAT(126), 
	"FED" VARCHAR2(15 BYTE), 
	"DESOPERAC" VARCHAR2(20 BYTE), 
	"NUMINT" NUMBER(*,0), 
	"COMENTARIO" VARCHAR2(200 BYTE)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;

--------------------------------------------------------
--  DDL for Table PCUENTAS
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."PCUENTAS" 
   (	"ID_CIA" NUMBER(*,0), 
	"CUENTA" VARCHAR2(16 BYTE), 
	"NOMBRE" VARCHAR2(160 BYTE), 
	"TIPGAS" NUMBER(*,0), 
	"CPADRE" VARCHAR2(16 BYTE), 
	"NIVEL" NUMBER(*,0), 
	"IMPUTA" CHAR(1 BYTE), 
	"CODTANA" NUMBER(*,0), 
	"DESTINO" CHAR(1 BYTE), 
	"DESTID" VARCHAR2(16 BYTE), 
	"DESTIH" VARCHAR2(16 BYTE), 
	"DH" CHAR(1 BYTE), 
	"MONEDA01" CHAR(3 BYTE), 
	"MONEDA02" CHAR(3 BYTE), 
	"CCOSTO" CHAR(1 BYTE), 
	"PROYEC" CHAR(1 BYTE), 
	"DOCORI" NUMBER(*,0), 
	"TIPO" CHAR(1 BYTE), 
	"REFERE" CHAR(1 BYTE), 
	"FHABDES" TIMESTAMP (6), 
	"FHABHAS" TIMESTAMP (6), 
	"BALANCE" CHAR(1 BYTE), 
	"REGCOMCOL" NUMBER(*,0), 
	"REGVENCOL" NUMBER(*,0), 
	"CLASIF" NUMBER(*,0), 
	"SITUAC" CHAR(1 BYTE), 
	"USUARI" VARCHAR2(10 BYTE), 
	"FCREAC" TIMESTAMP (6), 
	"FACTUA" TIMESTAMP (6), 
	"BALANCECOL" VARCHAR2(1 BYTE), 
	"HABILITADO" VARCHAR2(1 BYTE), 
	"CONCILIA" VARCHAR2(1 BYTE), 
	"TCUENTA" VARCHAR2(100 BYTE)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;

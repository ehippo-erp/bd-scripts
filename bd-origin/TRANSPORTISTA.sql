--------------------------------------------------------
--  DDL for Table TRANSPORTISTA
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."TRANSPORTISTA" 
   (	"ID_CIA" NUMBER(*,0), 
	"CODTRA" NUMBER(*,0), 
	"RAZONC" VARCHAR2(100 BYTE), 
	"DESCRI" VARCHAR2(50 CHAR), 
	"DOMICI" VARCHAR2(100 BYTE), 
	"RUC" VARCHAR2(15 BYTE), 
	"PUNPAR" VARCHAR2(50 CHAR), 
	"PUNLLE" VARCHAR2(50 CHAR), 
	"PLACA" VARCHAR2(50 BYTE), 
	"TELEF1" VARCHAR2(80 BYTE), 
	"LICENC" VARCHAR2(15 BYTE), 
	"CERTIF" VARCHAR2(15 BYTE), 
	"FCREAC" TIMESTAMP (6), 
	"FACTUA" TIMESTAMP (6), 
	"USUARI" VARCHAR2(10 BYTE), 
	"SWACTI" CHAR(1 BYTE), 
	"SWDATTRA" VARCHAR2(1 BYTE), 
	"CHOFER" VARCHAR2(100 BYTE), 
	"CHOFER_TIDENT" VARCHAR2(2 BYTE), 
	"CHOFER_DIDENT" VARCHAR2(20 BYTE), 
	"TELEFONO" VARCHAR2(80 BYTE), 
	"EMAIL" VARCHAR2(80 BYTE), 
	"OBSERV" VARCHAR2(3000 BYTE), 
	"CHOFER_APELL" VARCHAR2(100 CHAR), 
	"MODALIDAD" NUMBER(*,0)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;

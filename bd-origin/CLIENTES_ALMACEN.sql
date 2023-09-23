--------------------------------------------------------
--  DDL for Table CLIENTES_ALMACEN
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."CLIENTES_ALMACEN" 
   (	"ID_CIA" NUMBER(*,0), 
	"CODCLI" VARCHAR2(20 BYTE), 
	"CODENV" NUMBER(*,0), 
	"DESCRI" VARCHAR2(50 CHAR), 
	"DIREC1" VARCHAR2(150 BYTE), 
	"DIREC2" VARCHAR2(150 BYTE), 
	"TELENV" VARCHAR2(50 CHAR), 
	"FAXENV" VARCHAR2(50 BYTE), 
	"CODDEP" VARCHAR2(2 BYTE), 
	"CODPRV" VARCHAR2(2 BYTE), 
	"CODDIS" VARCHAR2(2 BYTE), 
	"CODZON" NUMBER(*,0), 
	"HENTINI" TIMESTAMP (6), 
	"HENTFIN" TIMESTAMP (6), 
	"FCREAC" TIMESTAMP (6), 
	"FACTUA" TIMESTAMP (6), 
	"USUARI" VARCHAR2(10 BYTE), 
	"SWACTI" CHAR(1 BYTE), 
	"CODCEN" VARCHAR2(50 CHAR), 
	"SUNAT_ANEXO" VARCHAR2(20 CHAR)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;

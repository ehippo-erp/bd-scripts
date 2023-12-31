--------------------------------------------------------
--  DDL for Table PCUENTAS_CLASE
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."PCUENTAS_CLASE" 
   (	"ID_CIA" NUMBER(*,0), 
	"CUENTA" VARCHAR2(16 BYTE), 
	"CLASE" NUMBER(*,0), 
	"CODIGO" VARCHAR2(20 BYTE), 
	"SWFLAG" VARCHAR2(1 BYTE), 
	"VREAL" NUMBER(9,2), 
	"VSTRG" VARCHAR2(30 BYTE), 
	"VCHAR" CHAR(1 BYTE), 
	"VDATE" DATE, 
	"VTIME" TIMESTAMP (6), 
	"VENTERO" NUMBER(*,0), 
	"CODUSERCREA" VARCHAR2(10 BYTE), 
	"CODUSERACTU" VARCHAR2(10 BYTE), 
	"FCREAC" TIMESTAMP (6), 
	"FACTUA" TIMESTAMP (6), 
	"NOMBRE" VARCHAR2(40 BYTE), 
	"VSTRING" VARCHAR2(30 BYTE)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;

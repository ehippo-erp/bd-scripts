--------------------------------------------------------
--  DDL for Table CLASE_PCUENTAS
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."CLASE_PCUENTAS" 
   (	"ID_CIA" NUMBER(*,0), 
	"CLASE" NUMBER(*,0), 
	"DESCRI" VARCHAR2(100 CHAR), 
	"VREAL" CHAR(1 BYTE), 
	"VSTRG" CHAR(1 BYTE), 
	"VCHAR" CHAR(1 BYTE), 
	"VDATE" CHAR(1 BYTE), 
	"VTIME" CHAR(1 BYTE), 
	"VENTERO" CHAR(1 BYTE), 
	"OBLIGA" VARCHAR2(1 BYTE), 
	"SWACTI" CHAR(1 BYTE), 
	"FCREAC" TIMESTAMP (6), 
	"FACTUA" TIMESTAMP (6), 
	"USUARI" VARCHAR2(10 BYTE), 
	"UCREAC" VARCHAR2(10 CHAR)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;

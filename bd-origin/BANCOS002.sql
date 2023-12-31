--------------------------------------------------------
--  DDL for Table BANCOS002
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."BANCOS002" 
   (	"ID_CIA" NUMBER(*,0), 
	"PERIODO" NUMBER(*,0), 
	"MES" NUMBER(*,0), 
	"LIBRO" VARCHAR2(3 BYTE), 
	"ASIENTO" NUMBER(*,0), 
	"ITEM" NUMBER(*,0), 
	"SITEM" NUMBER(*,0), 
	"C_PROCES" VARCHAR2(1 BYTE), 
	"C_PERIODO" NUMBER(*,0), 
	"C_MES" NUMBER(*,0), 
	"FCREAC" TIMESTAMP (6), 
	"FACTUA" TIMESTAMP (6), 
	"USUARI" VARCHAR2(10 BYTE)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;

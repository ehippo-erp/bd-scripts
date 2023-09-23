--------------------------------------------------------
--  DDL for Table KARDEX_COSTOVENTA
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."KARDEX_COSTOVENTA" 
   (	"ID_CIA" NUMBER(*,0), 
	"NUMINT" NUMBER(*,0), 
	"NUMITE" NUMBER(*,0), 
	"NUMINT_K" NUMBER(*,0), 
	"NUMITE_K" NUMBER(*,0), 
	"FEMISI" DATE, 
	"COSTOT01" NUMBER(16,2), 
	"COSTOT02" NUMBER(16,2), 
	"CANTID" NUMBER(16,4)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;

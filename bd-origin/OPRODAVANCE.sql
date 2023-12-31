--------------------------------------------------------
--  DDL for Table OPRODAVANCE
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."OPRODAVANCE" 
   (	"ID_CIA" NUMBER(*,0), 
	"CARGO" VARCHAR2(8 BYTE), 
	"ITEM" NUMBER(*,0), 
	"CANTID" NUMBER(11,2), 
	"SALDO" NUMBER(11,2), 
	"FSOR" DATE, 
	"SOR" NUMBER(11,2), 
	"FSPR" DATE, 
	"SPR" NUMBER(11,2), 
	"FSAL" DATE, 
	"SAL" NUMBER(11,2), 
	"FSAC" DATE, 
	"SAC" NUMBER(11,2), 
	"FCOR" DATE, 
	"COR" NUMBER(11,2), 
	"FCPR" DATE, 
	"CPR" NUMBER(11,2), 
	"FCAC" DATE, 
	"CAC" NUMBER(11,2)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;

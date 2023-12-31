--------------------------------------------------------
--  DDL for Table REG_ELIMINADOS
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."REG_ELIMINADOS" 
   (	"ID_CIA" NUMBER(*,0), 
	"NUMELI" NUMBER(*,0), 
	"TITTAB" NUMBER(*,0), 
	"TIPDOC" NUMBER(*,0), 
	"NUMINT" VARCHAR2(10 BYTE), 
	"NUMDOC" VARCHAR2(10 BYTE), 
	"CODIGO" VARCHAR2(40 BYTE), 
	"DESCRI" VARCHAR2(50 BYTE), 
	"USUARI" VARCHAR2(10 BYTE), 
	"TABLA" VARCHAR2(30 BYTE), 
	"FECHA" DATE
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;

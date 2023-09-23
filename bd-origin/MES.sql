--------------------------------------------------------
--  DDL for Table MES
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."MES" 
   (	"PERIODO" NUMBER, 
	"IDMES" NUMBER, 
	"DESMAY" VARCHAR2(20 CHAR), 
	"DESMIN" VARCHAR2(20 CHAR), 
	"ABRMAY" VARCHAR2(10 CHAR), 
	"ABRMIN" VARCHAR2(10 CHAR), 
	"DIAS" NUMBER, 
	"FDESDE" DATE, 
	"FHASTA" DATE
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;
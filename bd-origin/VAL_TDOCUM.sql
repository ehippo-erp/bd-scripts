--------------------------------------------------------
--  DDL for Table VAL_TDOCUM
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."VAL_TDOCUM" 
   (	"ID_VAL" NUMBER, 
	"DESVAL" VARCHAR2(4000 CHAR), 
	"LONSERRV" VARCHAR2(50 CHAR), 
	"VALSERRV" VARCHAR2(4000 CHAR), 
	"LONNUMRV" VARCHAR2(50 CHAR), 
	"VALNUMRV" VARCHAR2(4000 CHAR), 
	"LONSERRC" VARCHAR2(50 CHAR), 
	"VALSERRC" VARCHAR2(4000 CHAR), 
	"LONNUMRC" VARCHAR2(50 CHAR), 
	"VALNUMRC" VARCHAR2(4000 CHAR), 
	"LONSERRO" VARCHAR2(50 CHAR), 
	"VALSERRO" VARCHAR2(4000 CHAR), 
	"LONNUMRO" VARCHAR2(50 CHAR), 
	"VALNUMRO" VARCHAR2(4000 CHAR)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;

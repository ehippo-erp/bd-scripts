--------------------------------------------------------
--  DDL for Table PRODUCTO_LICENCIA
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."PRODUCTO_LICENCIA" 
   (	"CODPRO" VARCHAR2(10 CHAR), 
	"DESPRO" VARCHAR2(100 CHAR), 
	"COMENT" VARCHAR2(1000 CHAR), 
	"OBSERV" VARCHAR2(1000 CHAR), 
	"CODMODS" VARCHAR2(100 CHAR)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;

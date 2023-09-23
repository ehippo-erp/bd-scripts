--------------------------------------------------------
--  DDL for Table DOCUMENTOS_RELACION_HASH
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."DOCUMENTOS_RELACION_HASH" 
   (	"ID_CIA" NUMBER, 
	"NUMINT" NUMBER, 
	"HASH" NUMBER(16,0)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;

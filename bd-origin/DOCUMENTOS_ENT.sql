--------------------------------------------------------
--  DDL for Table DOCUMENTOS_ENT
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."DOCUMENTOS_ENT" 
   (	"ID_CIA" NUMBER(*,0), 
	"OPNUMDOC" NUMBER(*,0), 
	"OPNUMITE" NUMBER(*,0), 
	"ORINUMINT" NUMBER(*,0), 
	"ORINUMITE" NUMBER(*,0), 
	"ENTREG" NUMBER(11,4), 
	"PIEZAS" NUMBER(9,2)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;

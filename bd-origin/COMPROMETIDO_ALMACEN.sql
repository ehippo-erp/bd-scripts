--------------------------------------------------------
--  DDL for Table COMPROMETIDO_ALMACEN
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."COMPROMETIDO_ALMACEN" 
   (	"ID_CIA" NUMBER(*,0), 
	"TIPINV" NUMBER(*,0), 
	"CODART" VARCHAR2(40 BYTE), 
	"CODADD01" VARCHAR2(10 BYTE), 
	"CODADD02" VARCHAR2(10 BYTE), 
	"CODALM" NUMBER(*,0), 
	"INGRESO" NUMBER(11,4), 
	"SALIDA" NUMBER(11,4)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;

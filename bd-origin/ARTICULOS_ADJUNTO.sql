--------------------------------------------------------
--  DDL for Table ARTICULOS_ADJUNTO
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."ARTICULOS_ADJUNTO" 
   (	"ID_CIA" NUMBER(*,0), 
	"TIPINV" NUMBER(*,0), 
	"CODART" VARCHAR2(40 BYTE), 
	"ITEM" NUMBER(*,0), 
	"NOMBRE" VARCHAR2(100 CHAR), 
	"FORMATO" VARCHAR2(50 CHAR), 
	"ARCHIVO" BLOB, 
	"OBSERV" VARCHAR2(1000 CHAR), 
	"SWACTI" VARCHAR2(1 CHAR), 
	"UCREAC" VARCHAR2(10 CHAR), 
	"UACTUA" VARCHAR2(10 CHAR), 
	"FCREAC" TIMESTAMP (6), 
	"FACTUA" TIMESTAMP (6)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" 
 LOB ("ARCHIVO") STORE AS SECUREFILE (
  TABLESPACE "TBS_TSI_SUITE" ENABLE STORAGE IN ROW CHUNK 8192
  NOCACHE LOGGING  NOCOMPRESS  KEEP_DUPLICATES 
  STORAGE(INITIAL 106496 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)) ;

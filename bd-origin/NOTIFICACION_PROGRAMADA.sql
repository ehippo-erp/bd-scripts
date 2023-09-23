--------------------------------------------------------
--  DDL for Table NOTIFICACION_PROGRAMADA
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."NOTIFICACION_PROGRAMADA" 
   (	"ID_CIA" NUMBER, 
	"NUMINT" NUMBER, 
	"TITULO" VARCHAR2(100 CHAR), 
	"SQLNOT" BLOB, 
	"EMAILS" VARCHAR2(1000 CHAR), 
	"HEAD_HTML" BLOB, 
	"FOOTER_HTML" BLOB, 
	"SWACTI" VARCHAR2(1 BYTE), 
	"UCREAC" VARCHAR2(10 BYTE), 
	"UACTUA" VARCHAR2(10 BYTE), 
	"FCREAC" TIMESTAMP (6), 
	"FACTUA" TIMESTAMP (6)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" 
 LOB ("SQLNOT") STORE AS SECUREFILE (
  TABLESPACE "TBS_TSI_SUITE" ENABLE STORAGE IN ROW CHUNK 8192
  NOCACHE LOGGING  NOCOMPRESS  KEEP_DUPLICATES 
  STORAGE(INITIAL 106496 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)) 
 LOB ("HEAD_HTML") STORE AS SECUREFILE (
  TABLESPACE "TBS_TSI_SUITE" ENABLE STORAGE IN ROW CHUNK 8192
  NOCACHE LOGGING  NOCOMPRESS  KEEP_DUPLICATES 
  STORAGE(INITIAL 106496 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)) 
 LOB ("FOOTER_HTML") STORE AS SECUREFILE (
  TABLESPACE "TBS_TSI_SUITE" ENABLE STORAGE IN ROW CHUNK 8192
  NOCACHE LOGGING  NOCOMPRESS  KEEP_DUPLICATES 
  STORAGE(INITIAL 106496 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)) ;
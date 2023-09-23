--------------------------------------------------------
--  DDL for Table CLIENTE_POTENCIAL_XML
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."CLIENTE_POTENCIAL_XML" 
   (	"ID_CIA" NUMBER(*,0), 
	"CODIGO" NUMBER(*,0), 
	"NOMBRE" VARCHAR2(100 BYTE), 
	"CODCLI" VARCHAR2(20 BYTE), 
	"XML" BLOB, 
	"UCREAC" VARCHAR2(10 BYTE), 
	"FCREAC" TIMESTAMP (6), 
	"UACTUA" VARCHAR2(10 BYTE), 
	"FACTUA" TIMESTAMP (6)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" 
 LOB ("XML") STORE AS SECUREFILE (
  TABLESPACE "TBS_TSI_SUITE" ENABLE STORAGE IN ROW CHUNK 8192
  NOCACHE LOGGING  NOCOMPRESS  KEEP_DUPLICATES 
  STORAGE(INITIAL 106496 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)) ;
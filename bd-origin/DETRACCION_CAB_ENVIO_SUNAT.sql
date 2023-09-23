--------------------------------------------------------
--  DDL for Table DETRACCION_CAB_ENVIO_SUNAT
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."DETRACCION_CAB_ENVIO_SUNAT" 
   (	"ID_CIA" NUMBER(*,0), 
	"NUMINT" NUMBER(*,0), 
	"PERIODO" NUMBER(*,0), 
	"MES" NUMBER(*,0), 
	"NUMDOC" NUMBER(*,0), 
	"FENVIO" TIMESTAMP (6), 
	"FRESPUESTA" TIMESTAMP (6), 
	"ESTADO" NUMBER(*,0), 
	"TXT" BLOB, 
	"CTXT" NUMBER(*,0), 
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
 LOB ("TXT") STORE AS SECUREFILE (
  TABLESPACE "TBS_TSI_SUITE" ENABLE STORAGE IN ROW CHUNK 8192
  NOCACHE LOGGING  NOCOMPRESS  KEEP_DUPLICATES 
  STORAGE(INITIAL 106496 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)) ;
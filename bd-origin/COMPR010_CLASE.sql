--------------------------------------------------------
--  DDL for Table COMPR010_CLASE
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."COMPR010_CLASE" 
   (	"ID_CIA" NUMBER(*,0), 
	"TIPO" NUMBER(*,0), 
	"DOCUME" NUMBER(*,0), 
	"CLASE" NUMBER(*,0), 
	"CODIGO" VARCHAR2(20 BYTE), 
	"VREAL" NUMBER(9,2), 
	"VSTRG" VARCHAR2(80 BYTE), 
	"VCHAR" CHAR(1 BYTE), 
	"VDATE" DATE, 
	"VTIME" TIMESTAMP (6), 
	"VENTERO" NUMBER(*,0), 
	"VBLOB" BLOB, 
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
 LOB ("VBLOB") STORE AS SECUREFILE (
  TABLESPACE "TBS_TSI_SUITE" ENABLE STORAGE IN ROW CHUNK 8192
  NOCACHE LOGGING  NOCOMPRESS  KEEP_DUPLICATES 
  STORAGE(INITIAL 106496 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)) ;

--------------------------------------------------------
--  DDL for Table ESPECIFICACIONES_CERTIFICADOS
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."ESPECIFICACIONES_CERTIFICADOS" 
   (	"ID_CIA" NUMBER(*,0), 
	"TIPDOC" NUMBER(*,0), 
	"SERIES" VARCHAR2(5 BYTE), 
	"CODESP" NUMBER(*,0), 
	"DESCRI" VARCHAR2(30 BYTE), 
	"VREAL" CHAR(1 BYTE), 
	"VSTRG" CHAR(1 BYTE), 
	"VCHAR" CHAR(1 BYTE), 
	"VDATE" CHAR(1 BYTE), 
	"VTIME" CHAR(1 BYTE), 
	"VENTERO" CHAR(1 BYTE), 
	"FCREAC" TIMESTAMP (6), 
	"FACTUA" TIMESTAMP (6), 
	"CODUSER" VARCHAR2(10 BYTE), 
	"SWACTI" CHAR(1 BYTE), 
	"SWREQUE" CHAR(1 BYTE)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;

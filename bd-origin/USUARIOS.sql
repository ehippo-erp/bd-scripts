--------------------------------------------------------
--  DDL for Table USUARIOS
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."USUARIOS" 
   (	"ID_CIA" NUMBER(*,0), 
	"CODUSER" VARCHAR2(10 BYTE), 
	"NOMBRES" VARCHAR2(70 BYTE), 
	"CLAVE" VARCHAR2(32 BYTE), 
	"ATRIBUTOS" NUMBER(*,0), 
	"FEXPIRA" TIMESTAMP (6), 
	"SITUAC" CHAR(1 BYTE), 
	"FCREAC" TIMESTAMP (6), 
	"FACTUA" TIMESTAMP (6), 
	"SWACTI" CHAR(1 BYTE), 
	"USUARI" VARCHAR2(10 BYTE), 
	"COMENTARIO" VARCHAR2(520 BYTE), 
	"IMPETI" NUMBER(*,0), 
	"NUMCAJA" NUMBER(*,0), 
	"CARGO" VARCHAR2(70 BYTE), 
	"CODSUC" NUMBER(*,0), 
	"EMAIL" VARCHAR2(100 BYTE)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;
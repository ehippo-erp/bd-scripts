--------------------------------------------------------
--  DDL for Table DCTA103_APROBACION
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."DCTA103_APROBACION" 
   (	"ID_CIA" NUMBER(*,0), 
	"LIBRO" VARCHAR2(3 BYTE), 
	"PERIODO" NUMBER(*,0), 
	"MES" NUMBER(*,0), 
	"SECUENCIA" NUMBER(*,0), 
	"ITEM" NUMBER(*,0), 
	"NUMINT" NUMBER(*,0), 
	"TIPO" NUMBER(*,0), 
	"COMENTARIO" VARCHAR2(100 BYTE), 
	"CODOPERA" VARCHAR2(10 BYTE), 
	"CODAPROB" VARCHAR2(10 BYTE), 
	"VENTERO" NUMBER(*,0), 
	"VREAL" NUMBER(14,2), 
	"VSTRG" VARCHAR2(30 BYTE), 
	"VCHAR" CHAR(1 BYTE), 
	"VDATE" DATE, 
	"VTIME" TIMESTAMP (6), 
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
  TABLESPACE "TBS_TSI_SUITE" ;
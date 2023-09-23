--------------------------------------------------------
--  DDL for Table PROV105
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."PROV105" 
   (	"ID_CIA" NUMBER(*,0), 
	"TIPDOC" VARCHAR2(2 BYTE), 
	"SERIES" VARCHAR2(20 BYTE), 
	"NUMDOC" NUMBER(*,0), 
	"LIBRO" VARCHAR2(3 BYTE), 
	"PERIODO" NUMBER(*,0), 
	"MES" NUMBER(*,0), 
	"SECUENCIA" NUMBER(*,0), 
	"CODCLI" VARCHAR2(20 BYTE), 
	"FEMISI" DATE, 
	"FVENCI" DATE, 
	"REFERE" VARCHAR2(25 CHAR), 
	"TIPMON" VARCHAR2(5 BYTE), 
	"TIPCAM" NUMBER(16,6), 
	"IMPORTE" NUMBER(16,2), 
	"IMPORTEMN" NUMBER(16,2), 
	"IMPORTEME" NUMBER(16,2), 
	"TCAMB01" NUMBER(16,6), 
	"TCAMB02" NUMBER(16,6), 
	"IMPOR01" NUMBER(16,2), 
	"IMPOR02" NUMBER(16,2), 
	"CODCOB" NUMBER(*,0), 
	"COMISI" NUMBER(14,4), 
	"CODSUC" NUMBER(*,0), 
	"FCREAC" DATE, 
	"FACTUA" DATE, 
	"USUARI" VARCHAR2(10 BYTE), 
	"SITUAC" CHAR(1 BYTE), 
	"CUENTA" VARCHAR2(16 BYTE), 
	"DH" CHAR(1 BYTE), 
	"CODBAN" VARCHAR2(3 BYTE), 
	"CODVEN" NUMBER(*,0), 
	"OBSERV" VARCHAR2(1000 BYTE), 
	"TIPCAN" NUMBER(*,0), 
	"TIPO" NUMBER(*,0), 
	"DOCU" NUMBER(*,0), 
	"REFERE02" VARCHAR2(25 CHAR)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;

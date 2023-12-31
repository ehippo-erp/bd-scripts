--------------------------------------------------------
--  DDL for Table CLI_CONSULTA
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."CLI_CONSULTA" 
   (	"ID_CIA" NUMBER, 
	"ID_CONS" NUMBER, 
	"ID_PAC" NUMBER, 
	"ID_TRIA" NUMBER, 
	"ID_CITA" NUMBER, 
	"ID_DIAG" VARCHAR2(20 BYTE), 
	"MCONSULTA" VARCHAR2(100 BYTE), 
	"ANTECEDENTES" VARCHAR2(100 BYTE), 
	"TENFERMEDAD" NUMBER, 
	"OBSERVACIONES" VARCHAR2(200 BYTE), 
	"ALERGIAS" VARCHAR2(100 BYTE), 
	"IQUIRURGICAS" NUMBER, 
	"VCOMPLETAS" NUMBER, 
	"EFISICO" VARCHAR2(100 BYTE), 
	"PTRATAMIENTO" VARCHAR2(200 BYTE), 
	"FPROXCITA" DATE, 
	"POLIZA" VARCHAR2(50 BYTE), 
	"ESTADO" VARCHAR2(1 BYTE), 
	"CODUSERCREA" VARCHAR2(10 BYTE), 
	"CODUSERACTU" VARCHAR2(10 BYTE), 
	"FCREAC" TIMESTAMP (6), 
	"FACTUA" TIMESTAMP (6)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;

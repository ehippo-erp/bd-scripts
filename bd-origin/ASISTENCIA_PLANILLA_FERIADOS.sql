--------------------------------------------------------
--  DDL for Table ASISTENCIA_PLANILLA_FERIADOS
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."ASISTENCIA_PLANILLA_FERIADOS" 
   (	"ID_CIA" NUMBER, 
	"PERIODO" NUMBER, 
	"FECHA" DATE, 
	"DESFER" VARCHAR2(50 CHAR), 
	"FIJVAR" VARCHAR2(1 CHAR), 
	"SITUAC" VARCHAR2(1 CHAR), 
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

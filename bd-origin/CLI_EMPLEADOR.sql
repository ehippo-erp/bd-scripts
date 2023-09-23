--------------------------------------------------------
--  DDL for Table CLI_EMPLEADOR
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."CLI_EMPLEADOR" 
   (	"ID_CIA" NUMBER, 
	"ID_EMP" NUMBER, 
	"RAZONC" VARCHAR2(100 BYTE), 
	"TIDENT" VARCHAR2(2 BYTE), 
	"DIDENT" VARCHAR2(20 BYTE), 
	"DIRECCION" VARCHAR2(100 BYTE), 
	"TELEFONO" VARCHAR2(50 BYTE), 
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
  TABLESPACE "TBS_TSI_SUITE" ;
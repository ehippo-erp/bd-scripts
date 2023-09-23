--------------------------------------------------------
--  DDL for Table USUARIOS_CONECTA
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."USUARIOS_CONECTA" 
   (	"ID_CIA" NUMBER(*,0), 
	"CODUSER" VARCHAR2(15 BYTE), 
	"MODULO" VARCHAR2(30 BYTE), 
	"ID" VARCHAR2(1 BYTE), 
	"FECHA" TIMESTAMP (6), 
	"NOMUSER" VARCHAR2(50 BYTE), 
	"NOMPC" VARCHAR2(50 BYTE), 
	"IP" VARCHAR2(15 BYTE)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;

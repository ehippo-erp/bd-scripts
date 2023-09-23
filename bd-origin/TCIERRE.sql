--------------------------------------------------------
--  DDL for Table TCIERRE
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."TCIERRE" 
   (	"ID_CIA" NUMBER(*,0), 
	"SISTEMA" NUMBER(*,0), 
	"PERIODO" NUMBER(*,0), 
	"CIERR00" NUMBER(*,0), 
	"CIERR01" NUMBER(*,0), 
	"CIERR02" NUMBER(*,0), 
	"CIERR03" NUMBER(*,0), 
	"CIERR04" NUMBER(*,0), 
	"CIERR05" NUMBER(*,0), 
	"CIERR06" NUMBER(*,0), 
	"CIERR07" NUMBER(*,0), 
	"CIERR08" NUMBER(*,0), 
	"CIERR09" NUMBER(*,0), 
	"CIERR10" NUMBER(*,0), 
	"CIERR11" NUMBER(*,0), 
	"CIERR12" NUMBER(*,0), 
	"USUARIO" VARCHAR2(10 BYTE), 
	"FCREACION" TIMESTAMP (6), 
	"FOPERADO" TIMESTAMP (6)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;

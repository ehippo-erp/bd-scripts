--------------------------------------------------------
--  DDL for Table ARTICULOS_VENTAS
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."ARTICULOS_VENTAS" 
   (	"ID_CIA" NUMBER(*,0), 
	"TIPINV" NUMBER(*,0), 
	"CODART" VARCHAR2(40 BYTE), 
	"CODADD01" VARCHAR2(10 BYTE), 
	"CODADD02" VARCHAR2(10 BYTE), 
	"MESID" NUMBER(*,0), 
	"CANTID" FLOAT(126), 
	"TONELADAS" FLOAT(126), 
	"CSTSOL" FLOAT(126), 
	"CSTDOL" FLOAT(126), 
	"VNTSOL" FLOAT(126), 
	"VNTDOL" FLOAT(126)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;

--------------------------------------------------------
--  DDL for Table COMPANIA_FACELEC
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."COMPANIA_FACELEC" 
   (	"ID_CIA" NUMBER(*,0), 
	"ITEM" NUMBER(*,0), 
	"PATHZIP" VARCHAR2(200 BYTE), 
	"PATHXML" VARCHAR2(200 BYTE), 
	"PATHXMLRES" VARCHAR2(200 BYTE), 
	"PATHRESOK" VARCHAR2(200 BYTE), 
	"PATHTXT" VARCHAR2(200 BYTE), 
	"SUNAT_USER" VARCHAR2(20 CHAR), 
	"SUNAT_CLAVE" VARCHAR2(60 CHAR), 
	"SERV_RETEN" NUMBER(*,0), 
	"SERV_PERCEP" NUMBER(*,0), 
	"SERV_COMVEN" NUMBER(*,0), 
	"SERV_GUIREM" NUMBER(*,0), 
	"URLWS_TSI" VARCHAR2(300 BYTE), 
	"VERSION_UBL" NUMBER(*,0), 
	"SUNAT_USER_OSE" VARCHAR2(20 CHAR), 
	"SUNAT_CLAVE_OSE" VARCHAR2(60 CHAR), 
	"SUNAT_CLIENT_ID" VARCHAR2(200 CHAR), 
	"SUNAT_CLIENT_SECRET" VARCHAR2(200 CHAR)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;

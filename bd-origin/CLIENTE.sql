--------------------------------------------------------
--  DDL for Table CLIENTE
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."CLIENTE" 
   (	"ID_CIA" NUMBER(*,0), 
	"CODCLI" VARCHAR2(20 BYTE), 
	"RAZONC" VARCHAR2(80 CHAR), 
	"TIDENT" CHAR(2 BYTE), 
	"DIDENT" VARCHAR2(20 BYTE), 
	"DIREC1" VARCHAR2(100 CHAR), 
	"DIREC2" VARCHAR2(100 CHAR), 
	"EMAIL" VARCHAR2(50 CHAR), 
	"FAX" VARCHAR2(50 CHAR), 
	"REPRES" VARCHAR2(40 BYTE), 
	"CODTIT" NUMBER(*,0), 
	"CODPAG" NUMBER(*,0), 
	"CODPAGCOM" NUMBER(*,0), 
	"CODTSO" NUMBER(*,0), 
	"CODREG" NUMBER(*,0), 
	"CODFID" NUMBER(*,0), 
	"CODSEC" NUMBER(*,0), 
	"CODTNE" NUMBER(*,0), 
	"CODZON" NUMBER(*,0), 
	"CODDEP" VARCHAR2(2 BYTE), 
	"CODPRV" VARCHAR2(2 BYTE), 
	"CODDIS" VARCHAR2(2 BYTE), 
	"CODVOL" NUMBER(*,0), 
	"CODVEN" NUMBER(*,0), 
	"CTACLI" VARCHAR2(16 BYTE), 
	"CTAPRO" VARCHAR2(16 BYTE), 
	"TIPCLI" CHAR(1 BYTE), 
	"CODTPE" NUMBER(*,0), 
	"REGRET" NUMBER(*,0), 
	"TELEFONO" VARCHAR2(50 CHAR), 
	"ZONDES" VARCHAR2(20 BYTE), 
	"DCTOFIJO" NUMBER(4,2), 
	"LIMCRE1" NUMBER(9,2), 
	"LIMCRE2" NUMBER(9,2), 
	"CHEDEV" NUMBER(*,0), 
	"LETPRO" NUMBER(*,0), 
	"DEUDA1" NUMBER(*,0), 
	"DEUDA2" NUMBER(*,0), 
	"RENOVA" NUMBER(*,0), 
	"REFINA" NUMBER(*,0), 
	"CAPSOC" NUMBER(9,2), 
	"DIAMOR" NUMBER(*,0), 
	"FECING" DATE, 
	"FCIERRE" DATE, 
	"FCONST" DATE, 
	"SITUAC" CHAR(1 BYTE), 
	"FCREAC" TIMESTAMP (6), 
	"FACTUA" TIMESTAMP (6), 
	"USUARI" VARCHAR2(10 BYTE), 
	"SWACTI" CHAR(1 BYTE), 
	"CODTITCOM" NUMBER(*,0), 
	"OBSERV" VARCHAR2(2000 BYTE), 
	"VALIDENT" CHAR(1 BYTE)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;

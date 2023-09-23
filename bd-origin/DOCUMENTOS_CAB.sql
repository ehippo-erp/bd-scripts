--------------------------------------------------------
--  DDL for Table DOCUMENTOS_CAB
--------------------------------------------------------

  CREATE TABLE "USR_TSI_SUITE"."DOCUMENTOS_CAB" 
   (	"ID_CIA" NUMBER(*,0), 
	"NUMINT" NUMBER(*,0), 
	"TIPDOC" NUMBER(*,0), 
	"SERIES" VARCHAR2(5 BYTE), 
	"NUMDOC" NUMBER(*,0), 
	"FEMISI" DATE, 
	"LUGEMI" NUMBER(*,0), 
	"SITUAC" CHAR(1 BYTE), 
	"ID" CHAR(1 BYTE), 
	"CODMOT" NUMBER(*,0), 
	"MOTDOC" NUMBER(*,0), 
	"CODALM" NUMBER(*,0), 
	"ALMDES" NUMBER(*,0), 
	"CODCLI" VARCHAR2(20 BYTE), 
	"TIDENT" VARCHAR2(2 BYTE), 
	"RUC" VARCHAR2(20 BYTE), 
	"RAZONC" VARCHAR2(80 CHAR), 
	"DIREC1" VARCHAR2(100 CHAR), 
	"CODENV" NUMBER(*,0), 
	"CODCPAG" NUMBER(*,0), 
	"CODTRA" NUMBER(*,0), 
	"CODVEN" NUMBER(*,0), 
	"COMISI" NUMBER(9,3), 
	"INCIGV" CHAR(1 BYTE), 
	"DESTIN" NUMBER(*,0), 
	"TOTBRU" NUMBER(16,2), 
	"DESCUE" NUMBER(16,2), 
	"DESESP" NUMBER(16,2), 
	"MONAFE" NUMBER(16,2), 
	"MONINA" NUMBER(16,2), 
	"PORIGV" NUMBER(16,2), 
	"MONIGV" NUMBER(16,2), 
	"PREVEN" NUMBER(16,2), 
	"COSTO" NUMBER(16,2), 
	"TIPMON" VARCHAR2(5 BYTE), 
	"TIPCAM" NUMBER(10,6), 
	"ATENCI" VARCHAR2(50 CHAR), 
	"VALIDE" VARCHAR2(50 BYTE), 
	"PLAENT" VARCHAR2(50 CHAR), 
	"ORDCOM" VARCHAR2(20 BYTE), 
	"NUMPED" VARCHAR2(60 BYTE), 
	"GASVIN" NUMBER(16,2), 
	"SEGURO" NUMBER(16,2), 
	"FLETE" NUMBER(16,2), 
	"DESFLE" VARCHAR2(50 BYTE), 
	"DESEXP" NUMBER(16,2), 
	"GASADU" NUMBER(16,2), 
	"PESBRU" NUMBER(16,2), 
	"PESNET" NUMBER(16,2), 
	"BULTOS" NUMBER(*,0), 
	"PRESEN" VARCHAR2(200 CHAR), 
	"MARCAS" VARCHAR2(50 CHAR), 
	"NUMDUE" VARCHAR2(25 BYTE), 
	"FNUMDUE" DATE, 
	"FEMBARQ" DATE, 
	"FENTREG" DATE, 
	"VALFOB" NUMBER(16,2), 
	"GUIPRO" VARCHAR2(20 BYTE), 
	"FGUIPRO" DATE, 
	"FACPRO" VARCHAR2(20 BYTE), 
	"FFACPRO" DATE, 
	"CARGO" VARCHAR2(10 BYTE), 
	"CODSUC" NUMBER(*,0), 
	"FCREAC" TIMESTAMP (6), 
	"FACTUA" TIMESTAMP (6), 
	"ACUENTA" NUMBER(16,2), 
	"UCREAC" VARCHAR2(10 BYTE), 
	"USUARI" VARCHAR2(10 BYTE), 
	"SWACTI" CHAR(1 BYTE), 
	"CODAREA" NUMBER(*,0), 
	"CODUSO" NUMBER(*,0), 
	"OPNUMDOC" NUMBER(*,0), 
	"OPCARGO" VARCHAR2(10 BYTE), 
	"OPNUMITE" NUMBER(*,0), 
	"OPCODART" VARCHAR2(40 BYTE), 
	"OPTIPINV" NUMBER(*,0), 
	"TOTCAN" NUMBER(16,5), 
	"FORDCOM" DATE, 
	"ORDCOMNI" NUMBER(*,0), 
	"MOTVARIOS" NUMBER(*,0), 
	"HORING" TIMESTAMP (6), 
	"FECTER" DATE, 
	"HORTER" TIMESTAMP (6), 
	"CODTEC" NUMBER(*,0), 
	"GUIAREFE" VARCHAR2(15 BYTE), 
	"DESENV" VARCHAR2(60 CHAR), 
	"CODAUX" VARCHAR2(3 BYTE), 
	"CODETAPAUSO" NUMBER(*,0), 
	"CODSEC" NUMBER(*,0), 
	"NUMVALE" NUMBER(*,0), 
	"FECVALE" DATE, 
	"SWTRANS" NUMBER(*,0), 
	"DESSEG" VARCHAR2(50 BYTE), 
	"DESGASA" VARCHAR2(50 BYTE), 
	"DESNETX" VARCHAR2(50 BYTE), 
	"DESPREVEN" VARCHAR2(50 BYTE), 
	"CODCOB" NUMBER(*,0), 
	"CODVEH" NUMBER(*,0), 
	"CODPUNPAR" NUMBER(*,0), 
	"UBIGEOPAR" VARCHAR2(10 BYTE), 
	"DIRECCPAR" VARCHAR2(100 CHAR), 
	"MONISC" NUMBER(16,2), 
	"MONOTR" NUMBER(16,2), 
	"MONEXO" NUMBER(16,2), 
	"OBSERV" VARCHAR2(3000 CHAR), 
	"PROYEC" VARCHAR2(16 BYTE), 
	"MONTGR" NUMBER(16,2), 
	"COUNTADJ" NUMBER(*,0), 
	"NUMINTPER" NUMBER(*,0), 
	"MONCREDITO" NUMBER(16,2), 
	"SWMIGRA" VARCHAR2(1 CHAR) DEFAULT 'N', 
	"MONICBPER" NUMBER(16,2)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;
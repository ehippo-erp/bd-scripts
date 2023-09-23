--------------------------------------------------------
--  DDL for Index PK_MOTIVOS_CUENTAS
--------------------------------------------------------

  CREATE UNIQUE INDEX "USR_TSI_SUITE"."PK_MOTIVOS_CUENTAS" ON "USR_TSI_SUITE"."MOTIVOS_CUENTAS" ("ID_CIA", "TIPDOC", "ID", "CODMOT", "TIPINV", "CODFAM") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;

--------------------------------------------------------
--  DDL for Index PK_COMPR010
--------------------------------------------------------

  CREATE UNIQUE INDEX "USR_TSI_SUITE"."PK_COMPR010" ON "USR_TSI_SUITE"."COMPR010" ("ID_CIA", "TIPO", "DOCUME") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;

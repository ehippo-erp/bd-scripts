--------------------------------------------------------
--  DDL for Index PK_BANCO004
--------------------------------------------------------

  CREATE UNIQUE INDEX "USR_TSI_SUITE"."PK_BANCO004" ON "USR_TSI_SUITE"."BANCO004" ("ID_CIA", "CODBAN") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;

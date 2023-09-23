--------------------------------------------------------
--  DDL for Index PK_CLASE_CLIENTE_CODIGO
--------------------------------------------------------

  CREATE UNIQUE INDEX "USR_TSI_SUITE"."PK_CLASE_CLIENTE_CODIGO" ON "USR_TSI_SUITE"."CLASE_CLIENTE_CODIGO" ("ID_CIA", "TIPCLI", "CLASE", "CODIGO") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;

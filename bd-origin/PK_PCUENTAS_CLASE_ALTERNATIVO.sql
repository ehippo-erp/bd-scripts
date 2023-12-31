--------------------------------------------------------
--  DDL for Index PK_PCUENTAS_CLASE_ALTERNATIVO
--------------------------------------------------------

  CREATE UNIQUE INDEX "USR_TSI_SUITE"."PK_PCUENTAS_CLASE_ALTERNATIVO" ON "USR_TSI_SUITE"."PCUENTAS_CLASE_ALTERNATIVO" ("ID_CIA", "CUENTA", "CLASE", "CODIGO") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;

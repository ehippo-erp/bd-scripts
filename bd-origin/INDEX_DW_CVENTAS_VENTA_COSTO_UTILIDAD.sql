--------------------------------------------------------
--  DDL for Index INDEX_DW_CVENTAS_VENTA_COSTO_UTILIDAD
--------------------------------------------------------

  CREATE INDEX "USR_TSI_SUITE"."INDEX_DW_CVENTAS_VENTA_COSTO_UTILIDAD" ON "USR_TSI_SUITE"."DW_CVENTAS_VENTA_COSTO_UTILIDAD" ("ID_CIA", "FEMISI", "TIPINV", "CODART") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;

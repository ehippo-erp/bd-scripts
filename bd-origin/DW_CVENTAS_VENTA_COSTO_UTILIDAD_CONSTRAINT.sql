--------------------------------------------------------
--  Constraints for Table DW_CVENTAS_VENTA_COSTO_UTILIDAD
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."DW_CVENTAS_VENTA_COSTO_UTILIDAD" MODIFY ("ID_CIA" NOT NULL ENABLE);
  ALTER TABLE "USR_TSI_SUITE"."DW_CVENTAS_VENTA_COSTO_UTILIDAD" ADD CONSTRAINT "PK_DW_CVENTAS_VENTA_COSTO_UTILIDAD" PRIMARY KEY ("ID_CIA", "CODSUC", "FEMISI", "TIPINV", "CODART")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE"  ENABLE;

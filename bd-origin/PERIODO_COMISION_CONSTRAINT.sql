--------------------------------------------------------
--  Constraints for Table PERIODO_COMISION
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."PERIODO_COMISION" MODIFY ("ID_CIA" NOT NULL ENABLE);
  ALTER TABLE "USR_TSI_SUITE"."PERIODO_COMISION" MODIFY ("ID_PERIODO" NOT NULL ENABLE);
  ALTER TABLE "USR_TSI_SUITE"."PERIODO_COMISION" MODIFY ("FINICIO" NOT NULL ENABLE);
  ALTER TABLE "USR_TSI_SUITE"."PERIODO_COMISION" MODIFY ("FFIN" NOT NULL ENABLE);
  ALTER TABLE "USR_TSI_SUITE"."PERIODO_COMISION" ADD CONSTRAINT "PK_PERIODO_COMISION" PRIMARY KEY ("ID_CIA", "ID_PERIODO")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE"  ENABLE;

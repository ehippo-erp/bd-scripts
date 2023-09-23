--------------------------------------------------------
--  Constraints for Table PLANILLA_RANGO
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."PLANILLA_RANGO" MODIFY ("ID_CIA" NOT NULL ENABLE);
  ALTER TABLE "USR_TSI_SUITE"."PLANILLA_RANGO" MODIFY ("NUMPLA" NOT NULL ENABLE);
  ALTER TABLE "USR_TSI_SUITE"."PLANILLA_RANGO" MODIFY ("CODPER" NOT NULL ENABLE);
  ALTER TABLE "USR_TSI_SUITE"."PLANILLA_RANGO" MODIFY ("CODCON" NOT NULL ENABLE);
  ALTER TABLE "USR_TSI_SUITE"."PLANILLA_RANGO" MODIFY ("ITEM" NOT NULL ENABLE);
  ALTER TABLE "USR_TSI_SUITE"."PLANILLA_RANGO" ADD CONSTRAINT "PK_PLANILLA_RANGOS" PRIMARY KEY ("ID_CIA", "NUMPLA", "CODPER", "CODCON", "ITEM")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE"  ENABLE;
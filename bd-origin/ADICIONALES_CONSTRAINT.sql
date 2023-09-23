--------------------------------------------------------
--  Constraints for Table ADICIONALES
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."ADICIONALES" MODIFY ("ID_CIA" NOT NULL ENABLE);
  ALTER TABLE "USR_TSI_SUITE"."ADICIONALES" MODIFY ("TIPO" NOT NULL ENABLE);
  ALTER TABLE "USR_TSI_SUITE"."ADICIONALES" MODIFY ("CODIGO" NOT NULL ENABLE);
  ALTER TABLE "USR_TSI_SUITE"."ADICIONALES" ADD CONSTRAINT "PK_ADICIONALES" PRIMARY KEY ("ID_CIA", "TIPO", "CODIGO", "CPASOS")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE"  ENABLE;
  ALTER TABLE "USR_TSI_SUITE"."ADICIONALES" MODIFY ("CPASOS" NOT NULL ENABLE);
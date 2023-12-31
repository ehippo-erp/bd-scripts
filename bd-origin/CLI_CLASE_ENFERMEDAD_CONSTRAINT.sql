--------------------------------------------------------
--  Constraints for Table CLI_CLASE_ENFERMEDAD
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."CLI_CLASE_ENFERMEDAD" MODIFY ("ID_CIA" NOT NULL ENABLE);
  ALTER TABLE "USR_TSI_SUITE"."CLI_CLASE_ENFERMEDAD" MODIFY ("ID_TIPO" NOT NULL ENABLE);
  ALTER TABLE "USR_TSI_SUITE"."CLI_CLASE_ENFERMEDAD" MODIFY ("CLASE" NOT NULL ENABLE);
  ALTER TABLE "USR_TSI_SUITE"."CLI_CLASE_ENFERMEDAD" ADD CONSTRAINT "PK_CLASE_ENFERMEDAD" PRIMARY KEY ("ID_CIA", "ID_TIPO", "CLASE")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE"  ENABLE;

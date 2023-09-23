--------------------------------------------------------
--  Constraints for Table NOTIFICACION_PROGRAMADA_ADJUNTO
--------------------------------------------------------

  ALTER TABLE "USR_TSI_SUITE"."NOTIFICACION_PROGRAMADA_ADJUNTO" MODIFY ("ID_CIA" NOT NULL ENABLE);
  ALTER TABLE "USR_TSI_SUITE"."NOTIFICACION_PROGRAMADA_ADJUNTO" MODIFY ("NUMINT" NOT NULL ENABLE);
  ALTER TABLE "USR_TSI_SUITE"."NOTIFICACION_PROGRAMADA_ADJUNTO" MODIFY ("NUMITE" NOT NULL ENABLE);
  ALTER TABLE "USR_TSI_SUITE"."NOTIFICACION_PROGRAMADA_ADJUNTO" ADD CONSTRAINT "PK_NOTIFICACION_PROGRAMADA_ADJUNTO" PRIMARY KEY ("ID_CIA", "NUMINT", "NUMITE")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE"  ENABLE;
--------------------------------------------------------
--  DDL for Index IDX_DOCUMENTOS_RELACION_NUMINT
--------------------------------------------------------

  CREATE INDEX "USR_TSI_SUITE"."IDX_DOCUMENTOS_RELACION_NUMINT" ON "USR_TSI_SUITE"."DOCUMENTOS_RELACION" ("ID_CIA", "NUMINT") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;

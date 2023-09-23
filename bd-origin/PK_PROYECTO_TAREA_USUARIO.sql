--------------------------------------------------------
--  DDL for Index PK_PROYECTO_TAREA_USUARIO
--------------------------------------------------------

  CREATE UNIQUE INDEX "USR_TSI_SUITE"."PK_PROYECTO_TAREA_USUARIO" ON "USR_TSI_SUITE"."PROYECTO_TAREA_USUARIO" ("ID_CIA", "NUMINT_PROYEC", "CODUSER") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBS_TSI_SUITE" ;

--------------------------------------------------------
--  DDL for Trigger ANTES_ELIMINAR_DOCUMENTOS_CAB
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_ELIMINAR_DOCUMENTOS_CAB" BEFORE
    DELETE ON "USR_TSI_SUITE".documentos_cab
    FOR EACH ROW
BEGIN
    sp000_verifica_mes_cerrado_documentos_cab(:old.id_cia, :old.tipdoc, :old.numdoc, :old.femisi, :old.codcpag,
                                              :old.situac, :old.situac);
END;


/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_ELIMINAR_DOCUMENTOS_CAB" ENABLE;

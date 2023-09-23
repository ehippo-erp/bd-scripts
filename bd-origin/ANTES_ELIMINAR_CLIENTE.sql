--------------------------------------------------------
--  DDL for Trigger ANTES_ELIMINAR_CLIENTE
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_ELIMINAR_CLIENTE" BEFORE
    DELETE ON "USR_TSI_SUITE"."CLIENTE"
    FOR EACH ROW
BEGIN
    DELETE FROM cliente_clase
    WHERE
            id_cia = :old.id_cia
        AND codcli = :old.codcli;

    DELETE FROM cliente_codpag
    WHERE
            id_cia = :old.id_cia
        AND codcli = :old.codcli;

END;
/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_ELIMINAR_CLIENTE" ENABLE;

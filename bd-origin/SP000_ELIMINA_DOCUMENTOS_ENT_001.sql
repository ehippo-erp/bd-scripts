--------------------------------------------------------
--  DDL for Procedure SP000_ELIMINA_DOCUMENTOS_ENT_001
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP000_ELIMINA_DOCUMENTOS_ENT_001" (
    pid_cia     IN  NUMBER,
    pnumintori  IN  NUMBER
) IS
    wconteo NUMBER;
BEGIN
    IF (
        ( pnumintori IS NOT NULL ) AND ( pnumintori <> 0 )
    ) THEN
        DELETE FROM documentos_ent
        WHERE
            ( id_cia = pid_cia )
            AND ( orinumint = pnumintori );

        COMMIT;
    END IF;
END sp000_elimina_documentos_ent_001;

/

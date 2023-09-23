--------------------------------------------------------
--  DDL for Trigger DESPUES_ACTUALIZAR_DOCUMENTOS_RELACION
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."DESPUES_ACTUALIZAR_DOCUMENTOS_RELACION" AFTER
    UPDATE ON "USR_TSI_SUITE".documentos_relacion
    FOR EACH ROW
DECLARE
    v_tipdoc INTEGER;
BEGIN
    IF ( :new.numintre IS NOT NULL ) THEN
        BEGIN
            SELECT
                tipdoc
            INTO v_tipdoc
            FROM
                documentos_cab
            WHERE
                    id_cia = :new.id_cia
                AND numint = :new.numintre;

        EXCEPTION
            WHEN no_data_found THEN
                v_tipdoc := NULL;
        END;

        IF (
            ( v_tipdoc = 102 ) AND ( ( :new.tipdoc = 1 ) OR ( :new.tipdoc = 3 ) )
        ) THEN /* GUIA REMISION */
            UPDATE documentos_cab
            SET
                ffacpro = :new.femisi,
                facpro = :new.series
                         ||
                    CASE
                        WHEN length(:new.numdoc) > 7 THEN
                            CAST(to_char(:new.numdoc) AS VARCHAR2(50))
                        ELSE
                            CAST(substr2('00000000', 1, 7 -(length(to_char(:new.numdoc))))
                                 || to_char(:new.numdoc) AS VARCHAR2(50))
                    END
            WHERE
                    id_cia = :new.id_cia
                AND numint = :new.numintre;

        END IF;

    END IF;
END;


/
ALTER TRIGGER "USR_TSI_SUITE"."DESPUES_ACTUALIZAR_DOCUMENTOS_RELACION" ENABLE;

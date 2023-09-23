--------------------------------------------------------
--  DDL for Trigger DESPUES_ACTUALIZAR_DOCUMENTOS_CAB_ENVIO_SUNAT
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."DESPUES_ACTUALIZAR_DOCUMENTOS_CAB_ENVIO_SUNAT" AFTER
    UPDATE ON "USR_TSI_SUITE"."DOCUMENTOS_CAB_ENVIO_SUNAT"
    FOR EACH ROW
DECLARE
    v_locali NUMBER := 0;
BEGIN
    BEGIN
        SELECT
            NVL(MAX(locali),0)
        INTO v_locali
        FROM
            documentos_cab_envio_sunat_log
        WHERE
            id_cia = :new.id_cia;

    EXCEPTION
        WHEN no_data_found THEN
            v_locali := 0;
    END;

    IF ( (
        ( :new.numticket IS NOT NULL )
        AND ( :old.numticket IS NOT NULL )
        AND ( :new.numticket <> :old.numticket )
    ) OR (
        ( :new.mensaje IS NOT NULL )
        AND ( :old.mensaje IS NOT NULL )
        AND ( :new.mensaje <> :old.mensaje )
    ) ) THEN
        INSERT INTO documentos_cab_envio_sunat_log (
            id_cia,
            locali,
            numint,
            fenvio,
            frespuesta,
            estado,
            numticket,
            fcreac,
            mensaje
        ) VALUES (
            :new.id_cia,
            v_locali + 1,
            :new.numint,
            :new.fenvio,
            :new.frespuesta,
            :new.estado,
            :old.numticket,
            current_timestamp,
            :old.mensaje
        );

    END IF;

END;
/
ALTER TRIGGER "USR_TSI_SUITE"."DESPUES_ACTUALIZAR_DOCUMENTOS_CAB_ENVIO_SUNAT" ENABLE;

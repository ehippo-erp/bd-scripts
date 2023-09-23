--------------------------------------------------------
--  DDL for Trigger ANTES_INSERTAR_DOCUMENTOS_CAB_ENVIO_SUNAT
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_DOCUMENTOS_CAB_ENVIO_SUNAT" BEFORE
    INSERT ON "USR_TSI_SUITE".documentos_cab_envio_sunat
    FOR EACH ROW
BEGIN
    IF ( :new.fenvio IS NULL ) THEN
        :new.fenvio := current_timestamp;
    END IF;

    IF ( :new.frespuesta IS NULL ) THEN
        :new.frespuesta := current_timestamp;
    END IF;

    IF ( :new.inweb IS NULL ) THEN
        :new.inweb := 'S';
    END IF;

    IF ( :new.inwebbaj IS NULL ) THEN
        :new.inwebbaj := 'S';
    END IF;

END;


/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_DOCUMENTOS_CAB_ENVIO_SUNAT" ENABLE;

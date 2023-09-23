--------------------------------------------------------
--  DDL for Trigger DESPUES_INSERTAR_DOCUMENTOS_DET
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."DESPUES_INSERTAR_DOCUMENTOS_DET" AFTER
    INSERT ON "USR_TSI_SUITE".documentos_det
    FOR EACH ROW
BEGIN
   /*HEREDA LAS CLASES DEL DOCUMENTO PADRE RELACIONADO*/
    IF (
        ( :new.opnumdoc > 0 ) AND ( :new.opnumite > 0 )
    ) THEN
        INSERT INTO documentos_det_clieart_clase (
            id_cia,
            numint,
            numite,
            clase,
            codigo,
            vreal,
            vstrg,
            vchar,
            vdate,
            vtime,
            ventero
        )
            SELECT
                :new.id_cia,
                :new.numint,
                :new.numite,
                clase,
                codigo,
                vreal,
                vstrg,
                vchar,
                vdate,
                vtime,
                ventero
            FROM
                documentos_det_clieart_clase
            WHERE
                    id_cia = :new.id_cia
                AND numint = :new.opnumdoc
                AND numite = :new.opnumite;

    END IF;
END;


/
ALTER TRIGGER "USR_TSI_SUITE"."DESPUES_INSERTAR_DOCUMENTOS_DET" ENABLE;

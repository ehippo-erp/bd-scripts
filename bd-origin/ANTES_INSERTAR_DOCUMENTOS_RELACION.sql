--------------------------------------------------------
--  DDL for Trigger ANTES_INSERTAR_DOCUMENTOS_RELACION
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_DOCUMENTOS_RELACION" AFTER
    INSERT ON "USR_TSI_SUITE".documentos_relacion
    FOR EACH ROW
DECLARE
    v_tipdoc  INTEGER;
    v_situac  VARCHAR2(1);
BEGIN
    IF ( :new.numintre IS NOT NULL ) THEN
        BEGIN
            SELECT
                tipdoc,
                situac
            INTO
                v_tipdoc,
                v_situac
            FROM
                documentos_cab
            WHERE
                    id_cia = :new.id_cia
                AND numint = :new.numintre;

        EXCEPTION
            WHEN no_data_found THEN
                v_tipdoc := NULL;
                v_situac := NULL;
        END;

        IF ( v_situac = 'J' ) THEN
            RAISE pkg_exceptionuser.ex_documento_relacionado_anulado;
        END IF;
        IF ( v_tipdoc = 102 ) THEN /* GUIA REMISION */
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

        sp000_copia_documentos_cab_clase(:new.id_cia, :new.numintre, :new.numint, 'N');

    END IF;
EXCEPTION
    WHEN pkg_exceptionuser.ex_documento_relacionado_anulado THEN
        raise_application_error(pkg_exceptionuser.documento_relacionado_anulado, 'El documento relacionado se encuentra anulado');
END;
/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_DOCUMENTOS_RELACION" ENABLE;

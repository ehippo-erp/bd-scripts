--------------------------------------------------------
--  DDL for Trigger ANTES_INSERTAR_DOCUMENTOS_CAB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_DOCUMENTOS_CAB" BEFORE
    INSERT ON "USR_TSI_SUITE".documentos_cab
    FOR EACH ROW
DECLARE
    v_conteo NUMBER;
BEGIN
    sp000_verifica_mes_cerrado_documentos_cab(:new.id_cia, :new.tipdoc, :new.numdoc, :new.femisi, :new.codcpag,
                                             :new.situac, :new.situac);

    :new.fcreac := current_date;
    :new.factua := current_date;
    IF ( :new.codtra IS NULL ) THEN
        :new.codtra := 0;
    END IF;

    IF ( :new.numdoc <> 0 ) THEN
        BEGIN
            SELECT
                COUNT(0)
            INTO v_conteo
            FROM
                documentos_cab
            WHERE
                    id_cia = :new.id_cia
                AND tipdoc = :new.tipdoc
                AND series = :new.series
                AND numdoc = :new.numdoc;

        EXCEPTION
            WHEN no_data_found THEN
                v_conteo := NULL;
        END;

        IF ( v_conteo IS NULL ) THEN
            v_conteo := 0;
        END IF;
        IF ( v_conteo > 0 ) THEN
            RAISE pkg_exceptionuser.ex_numero_repetido_doccab;
        END IF;
    END IF;

EXCEPTION
    WHEN pkg_exceptionuser.ex_numero_repetido_doccab THEN
        raise_application_error(pkg_exceptionuser.numero_repetido_doccab, 'Número repetido en la cabecera del documento - '
                                                                          || :new.tipdoc
                                                                          || '-'
                                                                          || :new.series
                                                                          || '-'
                                                                          || :new.numdoc);
END;
/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_DOCUMENTOS_CAB" ENABLE;

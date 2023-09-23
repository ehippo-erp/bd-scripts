--------------------------------------------------------
--  DDL for Trigger ANTES_INSERTAR_COMPR010GUIA
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_COMPR010GUIA" BEFORE
    INSERT ON "USR_TSI_SUITE".compr010guia
    FOR EACH ROW
DECLARE
    v_serie   VARCHAR2(5);
    v_numero  VARCHAR2(20);
    v_femisi  DATE;
    v_conteo  NUMBER;
BEGIN
    :new.fcreac := current_date;
    BEGIN
        SELECT
            COUNT(0)
        INTO v_conteo
        FROM
            documentos_cab
        WHERE
                id_cia = :new.id_cia
            AND numint = :new.numint;

    EXCEPTION
        WHEN no_data_found THEN
            v_conteo := NULL;
    END;

    IF ( ( v_conteo IS NULL ) OR ( v_conteo = 0 ) ) THEN
        RAISE pkg_exceptionuser.ex_no_existe_numint;
    END IF;

    SELECT
        tipdoc,
        series,
        numdoc
    INTO
        :new.tipdoc,
        :new.series,
        :new.numdoc
    FROM
        documentos_cab
    WHERE
            id_cia = :new.id_cia
        AND numint = :new.numint;

    BEGIN
        SELECT
            nserie,
            numero,
            femisi
        INTO
            v_serie,
            v_numero,
            v_femisi
        FROM
            compr010
        WHERE
                id_cia = :new.id_cia
            AND tipo = :new.tipo
            AND docume = :new.docume;

    EXCEPTION
        WHEN no_data_found THEN
            v_serie := NULL;
            v_numero := NULL;
            v_femisi := NULL;
    END;

    UPDATE documentos_cab
    SET
        facpro = NULL,
        ffacpro = NULL
    WHERE
            id_cia = :new.id_cia
        AND numint = :new.numint;

    IF (
            ( v_serie <> NULL ) AND ( v_numero <> NULL )
        AND ( v_femisi <> NULL )
    ) THEN
        UPDATE documentos_cab
        SET
            facpro = substr(v_serie || v_numero, 1, 20),
            ffacpro = v_femisi
        WHERE
                id_cia = :new.id_cia
            AND numint = :new.numint;

    END IF;

EXCEPTION
    WHEN pkg_exceptionuser.ex_no_existe_numint THEN
        raise_application_error(pkg_exceptionuser.no_existe_numint, ' No existe documento en la cabecera de documentos');
END;
/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_COMPR010GUIA" ENABLE;

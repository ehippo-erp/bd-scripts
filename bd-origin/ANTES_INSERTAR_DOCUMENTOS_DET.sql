--------------------------------------------------------
--  DDL for Trigger ANTES_INSERTAR_DOCUMENTOS_DET
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_DOCUMENTOS_DET" BEFORE
    INSERT ON "USR_TSI_SUITE".documentos_det
    FOR EACH ROW
DECLARE
    v_id          VARCHAR2(1);
    v_codmot      NUMBER;
    v_numite      NUMBER;
    v_opnumdoc    VARCHAR2(14);
    v_opronumdoc  VARCHAR2(30);
BEGIN
    :new.fcreac := current_date;
    IF ( :new.numite IS NULL ) THEN
        BEGIN
            SELECT
                trunc((MAX(numite) / 1))
            INTO v_numite
            FROM
                documentos_det
            WHERE
                    id_cia = :new.id_cia
                AND numint = :new.numint;

        EXCEPTION
            WHEN no_data_found THEN
                v_numite := 0;
        END;

        :new.numite := v_numite + 1;
    END IF;

    IF ( ( :new.positi IS NULL ) OR ( :new.positi < 1 ) ) THEN
        BEGIN
            SELECT
                trunc((MAX(positi) / 1)) + 1
            INTO :new.positi
            FROM
                documentos_det
            WHERE
                    id_cia = :new.id_cia
                AND numint = :new.numint;

        EXCEPTION
            WHEN no_data_found THEN
                :new.positi := 0;
        END;
    END IF;

  /* SE DEMORA POR ESTA INSERCION
   IF (NOT(NEW.NUMITE IS NULL)) THEN
   BEGIN
    INSERT INTO DOCUMENTOS_STOCK         (    NUMINT,    NUMITE,    TIPINV,    CODART,    CODALM)
                                  VALUES (NEW.NUMINT,NEW.NUMITE,NEW.TIPINV,NEW.CODART,NEW.CODALM);
   END
   */

    IF ( :new.etiqueta IS NULL ) THEN
        :new.etiqueta := '';
    END IF;

    IF ( :new.etiqueta2 IS NULL ) THEN
        :new.etiqueta2 := '';
    END IF;

  /* 2014-06-19 -- SE COLOCO ESTO POR QUE LA SUBIDA AUTOMATICA NO RECIBE EL OPNUMDOC Y EL OPNUMITE NECESARIO PARA LOS COSTEOS.. */

    IF ( :new.tipdoc = 103 ) THEN
        v_id := NULL;
        v_codmot := NULL;
        BEGIN
            SELECT
                id,
                codmot
            INTO
                v_id,
                v_codmot
            FROM
                documentos_cab
            WHERE
                    id_cia = :new.id_cia
                AND numint = :new.numint;

        EXCEPTION
            WHEN no_data_found THEN
                v_id := NULL;
                v_codmot := NULL;
        END;    
       /* SOLO PASA POR INGRESO POR PRODUCCION */

        v_opnumdoc := to_char(:new.opnumdoc);
        v_opronumdoc := :new.opronumdoc;
        IF (
                    ( length(v_opnumdoc) < 2 ) AND ( length(v_opronumdoc) > 8 )
                AND ( v_id = 'I' )
            AND ( ( v_codmot = 6 ) OR ( v_codmot = 7 ) OR ( v_codmot = 9 ) OR ( v_codmot = 12 ) )
        ) THEN
            :new.opnumdoc := CAST ( substr2(:new.opronumdoc, 01, 10) AS NUMBER );

            :new.opnumite := CAST ( substr2(:new.opronumdoc, 12, 15) AS NUMBER );

        END IF;

    END IF;

    IF ( :new.monisc IS NULL ) THEN
        :new.monisc := 0;
    END IF;

    IF ( :new.seguro IS NULL ) THEN
        :new.seguro := 0;
    END IF;

    IF ( :new.flete IS NULL ) THEN
        :new.flete := 0;
    END IF;

    IF ( :new.monisc IS NULL ) THEN
        :new.monisc := 0;
    END IF;

    IF ( :new.valporisc IS NULL ) THEN
        :new.valporisc := 0;
    END IF;

    IF ( :new.monotr IS NULL ) THEN
        :new.monotr := 0;
    END IF;

    IF ( :new.monexo IS NULL ) THEN
        :new.monexo := 0;
    END IF;

END;


/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_DOCUMENTOS_DET" ENABLE;

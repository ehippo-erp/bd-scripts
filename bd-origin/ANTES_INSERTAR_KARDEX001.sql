--------------------------------------------------------
--  DDL for Trigger ANTES_INSERTAR_KARDEX001
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_KARDEX001" BEFORE
    INSERT ON kardex001
    FOR EACH ROW
DECLARE
    wtmp NUMBER;
BEGIN
    :new.cantid_ori := :new.ingreso;
    DECLARE BEGIN
        SELECT
            MAX(swingori)
        INTO wtmp
        FROM
            kardex001
        WHERE
                id_cia = :new.id_cia
            AND tipinv = :new.tipinv
            AND codart = :new.codart
            AND etiqueta = :new.etiqueta;

    EXCEPTION
        WHEN no_data_found THEN
            wtmp := NULL;
    END;

    IF ( wtmp IS NULL ) THEN
        :new.swingori := 1;
        BEGIN
            SELECT
                combina,
                empalme,
                lote,
                nrocarrete,
                ancho,
                largo,
                diseno,
                acabado,
                chasis,
                motor,
                fvenci,
                fmanuf
            INTO
                :new.combina,
                :new.empalme,
                :new.lote,
                :new.nrocarrete,
                :new.ancho,
                :new.largo,
                :new.diseno,
                :new.acabado,
                :new.chasis,
                :new.motor,
                :new.fvenci,
                :new.fmanuf
            FROM
                documentos_det
            WHERE
                    id_cia = :new.id_cia
                AND numint = :new.numint
                AND numite = :new.numite;

        EXCEPTION
            WHEN no_data_found THEN
                :new.combina := '';
                :new.empalme := '';
                :new.lote := '';
                :new.nrocarrete := '';
                :new.ancho := 0;
                :new.largo := 0;
                :new.diseno := '';
                :new.acabado := '';
                :new.chasis := '';
                :new.motor := '';
                :new.fvenci := '';
                :new.fmanuf := '';
        END;

    ELSE
        :new.swingori := wtmp + 1;
        BEGIN
            SELECT
                combina,
                empalme,
                lote,
                nrocarrete,
                ancho,
                largo,
                diseno,
                acabado,
                chasis,
                motor,
                fvenci,
                fmanuf
            INTO
                :new.combina,
                :new.empalme,
                :new.lote,
                :new.nrocarrete,
                :new.ancho,
                :new.largo,
                :new.diseno,
                :new.acabado,
                :new.chasis,
                :new.motor,
                :new.fvenci,
                :new.fmanuf
            FROM
                kardex001
            WHERE
                    id_cia = :new.id_cia
                AND tipinv = :new.tipinv
                AND codart = :new.codart
                AND swingori = 1
                AND etiqueta = :new.etiqueta;

        EXCEPTION
            WHEN no_data_found THEN
                :new.combina := '';
                :new.empalme := '';
                :new.lote := '';
                :new.nrocarrete := '';
                :new.ancho := 0;
                :new.largo := 0;
                :new.diseno := '';
                :new.acabado := '';
                :new.chasis := '';
                :new.motor := '';
                :new.fvenci := '';
                :new.fmanuf := '';
        END;

    END IF;

END;
/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_KARDEX001" ENABLE;

--------------------------------------------------------
--  DDL for Trigger ANTES_ACTUALIZAR_KARDEX
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_ACTUALIZAR_KARDEX" BEFORE
    UPDATE ON "USR_TSI_SUITE".kardex
    FOR EACH ROW
DECLARE
    v_cant NUMBER;
BEGIN
    IF ( :new.cantid IS NULL ) THEN
        :new.cantid := 0;
    END IF;

    IF ( :new.costot01 IS NULL ) THEN
        :new.costot01 := 0;
    END IF;

    IF ( :new.costot02 IS NULL ) THEN
        :new.costot02 := 0;
    END IF;

    IF ( :new.fobtot01 IS NULL ) THEN
        :new.fobtot01 := 0;
    END IF;

    IF ( :new.fobtot02 IS NULL ) THEN
        :new.fobtot02 := 0;
    END IF;

    IF ( :new.royos IS NULL ) THEN
        :new.royos := 0;
    END IF;

    IF ( :new.cosmat01 IS NULL ) THEN
        :new.cosmat01 := 0;
    END IF;

    IF ( :new.cosmob01 IS NULL ) THEN
        :new.cosmob01 := 0;
    END IF;

    IF ( :new.cosfab01 IS NULL ) THEN
        :new.cosfab01 := 0;
    END IF;

    IF ( :new.codadd01 IS NULL ) THEN
        :new.codadd01 := '';
    END IF;

    IF ( :new.codadd02 IS NULL ) THEN
        :new.codadd02 := '';
    END IF;

    IF (
        ( :new.etiqueta IS NOT NULL ) AND ( :new.etiqueta <> '' )
    ) THEN
    /* SOLO POR INGRESO  1 VES */
        IF ( :new.id = 'I' ) THEN

/* 2015-02-03 - SOLO INSERTA POR MOTIOS COMPRA, PRODUCCION , IMPORTACION Y TOMA DE INVENTARIO */
            BEGIN
                SELECT
                    COUNT(0)
                INTO v_cant
                FROM
                    kardex000
                WHERE
                        id_cia = :new.id_cia
                    AND etiqueta = :new.etiqueta;

            EXCEPTION
                WHEN no_data_found THEN
                    v_cant := NULL;
            END;

            IF ( v_cant IS NULL ) THEN
                v_cant := 0;
            END IF;
            IF ( v_cant = 0 ) THEN
                IF ( ( :new.codmot IN (
                    1,
                    5,
                    6,
                    7,
                    9,
                    12,
                    28
                ) ) OR (
                    :new.codmot IN (
                        3,
                        20
                    ) AND :new.tipdoc = 103
                ) ) THEN
                    INSERT INTO kardex000 (
                        id_cia,
                        etiqueta,
                        locali,
                        tipinv,
                        codart,
                        codalm,
                        cantid,
                        costot01,
                        costot02,
                        fingreso,
                        numint,
                        numite,
                        codmot,
                        coduseractu
                    ) VALUES (
                        :new.id_cia,
                        :new.etiqueta,
                        :new.locali,
                        :new.tipinv,
                        :new.codart,
                        :new.codalm,
                        :new.cantid,
                        :new.costot01,
                        :new.costot02,
                        :new.femisi,
                        :new.numint,
                        :new.numite,
                        :new.codmot,
                        :new.usuari
                    );

                ELSE
         /* SOLO SI YA FUE GRABADO ANTES */
                    UPDATE kardex000
                    SET
                        tipinv = :new.tipinv,
                        codart = :new.codart,
                        codalm = :new.codalm,
                        cantid = :new.cantid,
                        costot01 = :new.costot01,
                        costot02 = :new.costot02,
                        fingreso = :new.femisi,
                        numint = :new.numint,
                        numite = :new.numite,
                        codmot = :new.codmot,
                        coduseractu = :new.usuari
                    WHERE
                            id_cia = :new.id_cia
                        AND etiqueta = :new.etiqueta
                        AND locali = :new.locali;

                END IF;
            END IF;

        END IF;
    END IF;

END;


/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_ACTUALIZAR_KARDEX" ENABLE;

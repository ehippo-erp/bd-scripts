--------------------------------------------------------
--  DDL for Function SP_BUSCA_RELACION_KARDEX
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP_BUSCA_RELACION_KARDEX" (
    pin_id_cia INTEGER,
    pin_numint INTEGER,
    pin_numite INTEGER
) RETURN INTEGER AS
    v_opnumdoc INTEGER;
    v_opnumite INTEGER;
    v_locali   INTEGER := 0;
BEGIN
    BEGIN
        SELECT
            opnumdoc,
            opnumite
        INTO
            v_opnumdoc,
            v_opnumite
        FROM
            documentos_det
        WHERE
                id_cia = pin_id_cia
            AND numint = pin_numint
            AND numite = pin_numite;

    EXCEPTION
        WHEN no_data_found THEN
            v_opnumdoc := NULL;
            v_opnumite := NULL;
    END;

    IF (
        ( v_opnumdoc IS NOT NULL )
        AND ( v_opnumdoc > 0 )
        AND ( v_opnumite IS NOT NULL )
        AND ( v_opnumite > 0 )
    ) THEN
        BEGIN
            SELECT
                locali
            INTO v_locali
            FROM
                kardex
            WHERE
                    id_cia = pin_id_cia
                AND numint = v_opnumdoc
                AND numite = v_opnumite;

        EXCEPTION
            WHEN no_data_found THEN
                v_locali := NULL;
        END;

        IF ( v_locali IS NULL ) THEN
            v_locali := sp_busca_relacion_kardex(pin_id_cia, v_opnumdoc, v_opnumite);
        END IF;

    END IF;

    RETURN v_locali;
END sp_busca_relacion_kardex;

/

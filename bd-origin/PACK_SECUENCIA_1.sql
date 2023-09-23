--------------------------------------------------------
--  DDL for Package Body PACK_SECUENCIA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_SECUENCIA" AS

    FUNCTION sp_ultimo_valor (
        pin_id_cia IN NUMBER,
        pin_tipdoc IN NUMBER,
        pin_serie  IN VARCHAR2
    ) RETURN NUMBER AS
        v_secuencia VARCHAR2(200);
        v_numdoc    NUMBER;
    BEGIN
        v_secuencia := 'GEN_DOC_'
                       || to_char(pin_id_cia)
                       || '_'
                       || to_char(pin_tipdoc)
                       || '_'
                       || to_char(pin_serie);

        BEGIN
            SELECT
                last_number
            INTO v_numdoc
            FROM
                user_sequences
            WHERE
                sequence_name = v_secuencia;

        EXCEPTION
            WHEN no_data_found THEN
                v_numdoc := 1;
        END;

        RETURN v_numdoc;
    END sp_ultimo_valor;

    FUNCTION sp_verifica_existencia (
        pin_id_cia IN NUMBER,
        pin_tipdoc IN NUMBER,--610
        pin_serie  IN VARCHAR2--999
    ) RETURN NUMBER AS
        v_secuencia VARCHAR2(200);
        v_numdoc    NUMBER;
    BEGIN
        v_secuencia := 'GEN_DOC_'
                       || to_char(pin_id_cia)
                       || '_'
                       || to_char(pin_tipdoc)
                       || '_'
                       || to_char(pin_serie);

        BEGIN
            SELECT
                last_number
            INTO v_numdoc
            FROM
                user_sequences
            WHERE
                sequence_name = v_secuencia;

        EXCEPTION
            WHEN no_data_found THEN
                v_numdoc := 0;
        END;

        IF v_numdoc > 0 THEN
            v_numdoc := 1;
        END IF;
        RETURN v_numdoc;
    END sp_verifica_existencia;

END pack_secuencia;

/

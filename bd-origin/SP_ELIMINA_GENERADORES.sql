--------------------------------------------------------
--  DDL for Procedure SP_ELIMINA_GENERADORES
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_ELIMINA_GENERADORES" (
    pin_id_cia IN NUMBER
) AS

    CURSOR cur_documentos IS
    SELECT
        codigo,
        series,
        'GEN_DOC'
        || '_'
        || id_cia
        || '_'
        || codigo
        || '_'
        || series AS namesequence
    FROM
        documentos
    WHERE
        id_cia = pin_id_cia;

    CURSOR cur_tdocume (
        pid_cia NUMBER
    ) IS
    SELECT
        codigo
    FROM
        tdocume
    WHERE
        id_cia = pid_cia;

    v_namesequence  VARCHAR2(1000);
    v_count_exist   INTEGER := 0;
BEGIN
    v_namesequence := 'GEN_CLIENTE_' || pin_id_cia;
    v_count_exist := sp_existe_sequence(v_namesequence);
    IF v_count_exist = 1 THEN
        EXECUTE IMMEDIATE 'DROP SEQUENCE '
                          || 'USR_TSI_SUITE.'
                          || v_namesequence;
    END IF;
    v_namesequence := 'GEN_COMPROMETIDO_' || pin_id_cia;
    v_count_exist := sp_existe_sequence(v_namesequence);
    IF v_count_exist = 1 THEN
        EXECUTE IMMEDIATE 'DROP SEQUENCE '
                          || 'USR_TSI_SUITE.'
                          || v_namesequence;
    END IF;
    v_namesequence := 'GEN_DCTA102_CAJA_CAB_' || pin_id_cia;
    v_count_exist := sp_existe_sequence(v_namesequence);
    IF v_count_exist = 1 THEN
        EXECUTE IMMEDIATE 'DROP SEQUENCE '
                          || 'USR_TSI_SUITE.'
                          || v_namesequence;
    END IF;
    FOR registro IN cur_documentos LOOP
        v_count_exist := sp_existe_sequence(registro.namesequence);
        IF v_count_exist = 1 THEN
            EXECUTE IMMEDIATE 'DROP SEQUENCE '
                              || 'USR_TSI_SUITE.'
                              || registro.namesequence;
        END IF;

    END LOOP;

    v_namesequence := 'GEN_DOCUMENTOS_CAB_' || pin_id_cia;
    v_count_exist := sp_existe_sequence(v_namesequence);
    IF v_count_exist = 1 THEN
        EXECUTE IMMEDIATE 'DROP SEQUENCE '
                          || 'USR_TSI_SUITE.'
                          || v_namesequence;
    END IF;
    v_namesequence := 'GEN_DOCUMENTOS_CAB_LOG_' || pin_id_cia;
    v_count_exist := sp_existe_sequence(v_namesequence);
    IF v_count_exist = 1 THEN
        EXECUTE IMMEDIATE 'DROP SEQUENCE '
                          || 'USR_TSI_SUITE.'
                          || v_namesequence;
    END IF;
    v_namesequence := 'GEN_ETIQUETAS_KARDEX_' || pin_id_cia;
    v_count_exist := sp_existe_sequence(v_namesequence);
    IF v_count_exist = 1 THEN
        EXECUTE IMMEDIATE 'DROP SEQUENCE '
                          || 'USR_TSI_SUITE.'
                          || v_namesequence;
    END IF;
    v_namesequence := 'GEN_KARDEX_' || pin_id_cia;
    v_count_exist := sp_existe_sequence(v_namesequence);
    IF v_count_exist = 1 THEN
        EXECUTE IMMEDIATE 'DROP SEQUENCE '
                          || 'USR_TSI_SUITE.'
                          || v_namesequence;
    END IF;
    v_namesequence := 'GEN_KARDEX_' || pin_id_cia;
    v_count_exist := sp_existe_sequence(v_namesequence);
    IF v_count_exist = 1 THEN
        EXECUTE IMMEDIATE 'DROP SEQUENCE '
                          || 'USR_TSI_SUITE.'
                          || v_namesequence;
    END IF;
    FOR r_tdoc IN cur_tdocume(pin_id_cia) LOOP
        v_namesequence := 'GEN_PROV105_CXP_'
                          || pin_id_cia
                          || '_'
                          || r_tdoc.codigo;
        v_count_exist := sp_existe_sequence(v_namesequence);
        IF v_count_exist = 1 THEN
            EXECUTE IMMEDIATE 'DROP SEQUENCE '
                              || 'USR_TSI_SUITE.'
                              || v_namesequence;
        END IF;
    END LOOP;

END;

/

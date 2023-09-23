--------------------------------------------------------
--  DDL for Procedure SP_UPDATE_SEQUENCE_DOCUMENTS
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_UPDATE_SEQUENCE_DOCUMENTS" (
    pin_id_cia IN NUMBER,
    pin_tipdoc IN NUMBER,
    pin_serie  IN VARCHAR2
)
AS

    v_maxnum        NUMBER;
    v_name_sequence user_sequences.sequence_name%TYPE;
    v_start_value   NUMBER := 1;
    v_increment_by  NUMBER := 1;
    v_count_exist   NUMBER;
BEGIN
    v_name_sequence := 'GEN_DOC_'
                       || pin_id_cia
                       || '_'
                       || pin_tipdoc
                       || '_'
                       || pin_serie;

    -- VERIFICANDO LA EXISTENCIA DEL GENERADOR
    BEGIN
        SELECT
            1
        INTO v_count_exist
        FROM
            user_sequences us
        WHERE
            upper(us.sequence_name) = upper(v_name_sequence);

    EXCEPTION
        WHEN no_data_found THEN
        -- GENERADOR NO EXISTE
            v_count_exist := 0;
            EXECUTE IMMEDIATE 'CREATE SEQUENCE '
                              || upper(v_name_sequence)
                              || ' START WITH '
                              || v_start_value
                              || ' INCREMENT BY 1 ORDER'
                              || ' MINVALUE '
                              || v_increment_by
                              || ' NOCACHE ';
        -- INICANDO SECUENCIA
            EXECUTE IMMEDIATE 'SELECT '
                              || upper(v_name_sequence)
                              || '.nextval FROM dual';
    END;

    -- SI EL GENERADOR EXISTE
    IF v_count_exist > 0 THEN
        BEGIN
            SELECT
                MAX(nvl(numdoc,0))
            INTO v_maxnum
            FROM
                documentos_cab
            WHERE
                    id_cia = pin_id_cia
                AND tipdoc = pin_tipdoc
                AND series = pin_serie;

        EXCEPTION
            WHEN no_data_found THEN
                v_maxnum := 1;
        END;

        v_start_value := v_maxnum;
        EXECUTE IMMEDIATE 'DROP SEQUENCE ' || upper(v_name_sequence);
        EXECUTE IMMEDIATE 'CREATE SEQUENCE '
                          || upper(v_name_sequence)
                          || ' START WITH '
                          || v_start_value
                          || ' INCREMENT BY 1 ORDER'
                          || ' MINVALUE '
                          || v_increment_by
                          || ' NOCACHE ';

        EXECUTE IMMEDIATE 'SELECT '
                          || upper(v_name_sequence)
                          || '.nextval FROM dual';
    END IF;

    DBMS_OUTPUT.PUT_LINE(v_name_sequence || ' - ' || v_start_value || ' - ' || v_increment_by);

END "SP_UPDATE_SEQUENCE_DOCUMENTS";

/

--------------------------------------------------------
--  DDL for Trigger ANTES_INSERTAR_DOCUMENTOS_CAB_LOG
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_DOCUMENTOS_CAB_LOG" BEFORE
    INSERT ON "USR_TSI_SUITE".documentos_cab_log
    FOR EACH ROW
DECLARE
    v_namegenerador  VARCHAR2(60);
    v_count          NUMBER := 0;
BEGIN
    v_namegenerador := 'GEN_DOCUMENTOS_CAB_LOG_' || to_char(:new.id_cia);
    BEGIN
        SELECT
            COUNT(0)
        INTO v_count
        FROM
            user_sequences
        WHERE
            upper(sequence_name) = upper(v_namegenerador);

    EXCEPTION
        WHEN no_data_found THEN
            v_count := 0;
    END;

    IF ( ( v_count IS NULL ) OR ( v_count = 0 ) ) THEN
        RAISE pkg_exceptionuser.ex_gen_documentos_cab_log;
    END IF;

    EXECUTE IMMEDIATE 'SELECT '
                      || v_namegenerador
                      || '.nextval FROM dual'
    INTO v_count;
    :new.locali := v_count;
    :new.fcreac := current_date;
EXCEPTION
    WHEN pkg_exceptionuser.ex_gen_documentos_cab_log THEN
        raise_application_error(pkg_exceptionuser.gen_documentos_cab_log_no_existe, 'Generador ['
                                                                                    || v_namegenerador
                                                                                    || '] no existe');
END;

/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_DOCUMENTOS_CAB_LOG" ENABLE;

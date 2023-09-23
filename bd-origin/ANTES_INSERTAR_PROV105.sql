--------------------------------------------------------
--  DDL for Trigger ANTES_INSERTAR_PROV105
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_PROV105" BEFORE
    INSERT ON "USR_TSI_SUITE".prov105
    FOR EACH ROW
DECLARE
    v_namegenerador  VARCHAR2(60);
    v_count          NUMBER := 0;
BEGIN
    v_namegenerador := upper('GEN_PROV105_CXP_')
                       || :new.id_cia
                       || '_'
                       || :new.tipdoc;

    BEGIN
        SELECT
            COUNT(0)
        INTO v_count
        FROM
            user_sequences
        WHERE
            upper(sequence_name) = v_namegenerador;

    EXCEPTION
        WHEN no_data_found THEN
            v_count := 0;
    END;

    IF ( ( v_count IS NULL ) OR ( v_count = 0 ) ) THEN
        RAISE pkg_exceptionuser.ex_generador_no_existe;
    END IF;

    IF ( ( :new.numdoc IS NULL ) OR ( :new.numdoc <= 0 ) ) THEN
        EXECUTE IMMEDIATE 'select ' || v_namegenerador || '.NEXTVAL FROM DUAL'
        INTO v_count;
        :new.numdoc := v_count;
    END IF;

EXCEPTION
    WHEN pkg_exceptionuser.ex_generador_no_existe THEN
        raise_application_error(pkg_exceptionuser.generador_no_existe, 'Generador ['
                                                                       || v_namegenerador
                                                                       || '] no existe');
END;
/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_PROV105" ENABLE;

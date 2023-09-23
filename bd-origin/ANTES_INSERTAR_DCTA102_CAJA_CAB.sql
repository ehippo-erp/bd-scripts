--------------------------------------------------------
--  DDL for Trigger ANTES_INSERTAR_DCTA102_CAJA_CAB
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_DCTA102_CAJA_CAB" BEFORE
    INSERT ON "USR_TSI_SUITE".dcta102_caja_cab
    FOR EACH ROW
DECLARE
    v_namegenerador  VARCHAR2(60);
    v_count          NUMBER := 0;
BEGIN
    v_namegenerador := upper('GEN_DCTA102_CAJA_CAB_')
                       || :new.id_cia;
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
        RAISE pkg_exceptionuser.ex_gen_dcta102_caja_cab;
    END IF;

    IF ( ( :new.numcaja IS NULL ) OR ( :new.numcaja <= 0 ) ) THEN
        EXECUTE IMMEDIATE 'select '
                          || v_namegenerador
                          || '.NEXTVAL FROM DUAL'
        INTO v_count;
        :new.numcaja := v_count;
        UPDATE usuarios
        SET
            numcaja = :new.numcaja
        WHERE
                id_cia = :new.id_cia
            AND coduser = :new.coduser;

    END IF;

    IF ( :new.situac IS NULL ) THEN
        :new.situac := 0;
    END IF;

    :new.fcreac := current_timestamp;
    :new.factua := current_timestamp;
    :new.codusercrea := :new.coduseractu;
    BEGIN
        SELECT
            fventa,
            fcompra
        INTO
            :new.tipcamven,
            :new.tipcamcom
        FROM
            tcambio
        WHERE
                id_cia = :new.id_cia
            AND hmoneda = 'PEN'
            AND moneda = 'USD'
            AND fecha = ( CAST(:new.finicio AS DATE) );

    EXCEPTION
        WHEN no_data_found THEN
            :new.tipcamven := 0;
            :new.tipcamcom := 0;
    END;

EXCEPTION
    WHEN pkg_exceptionuser.ex_gen_dcta102_caja_cab THEN
        raise_application_error(pkg_exceptionuser.gen_dcta102_caja_cab_no_existe, 'Generador ['
                                                                                  || v_namegenerador
                                                                                  || '] no existe');
END;

/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_DCTA102_CAJA_CAB" ENABLE;

--------------------------------------------------------
--  DDL for Trigger ANTES_INSERTAR_DOCUMENTOS_DET_PERCEPCION
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_DOCUMENTOS_DET_PERCEPCION" BEFORE
    INSERT ON "USR_TSI_SUITE".documentos_det_percepcion
    FOR EACH ROW
DECLARE
    v_numite  NUMBER;
    v_tipcam  NUMERIC(16, 4);
    v_moneda  VARCHAR2(3);
BEGIN
    :new.fcreac := current_date;
    IF ( ( :new.numite IS NULL ) OR ( :new.numite <= 0 ) ) THEN
        BEGIN
            SELECT
                trunc((MAX(numite) / 1))
            INTO v_numite
            FROM
                documentos_det_percepcion
            WHERE
                    id_cia = :new.id_cia
                AND numint = :new.numint;

        EXCEPTION
            WHEN no_data_found THEN
                v_numite := 0;
        END;

        :new.numite := v_numite + 1;
    END IF;

    v_tipcam := 0;
    v_moneda := 'USD';
    IF ( :new.moneda <> 'PEN' ) THEN
        v_moneda := :new.moneda;
    END IF;

    BEGIN
        SELECT
            venta
        INTO v_tipcam
        FROM
            tcambio
        WHERE
                id_cia = :new.id_cia
            AND hmoneda = 'PEN'
            AND moneda = v_moneda
            AND fecha = :new.fcance;

    EXCEPTION
        WHEN no_data_found THEN
            v_tipcam := NULL;
    END;

    IF ( ( v_tipcam IS NULL ) OR ( v_tipcam = 0 ) ) THEN
        RAISE pkg_exceptionuser.ex_tcambio_no_existe;
    END IF;

    :new.tipcam := v_tipcam;
    :new.pago01 := :new.pago;
    :new.pago02 := :new.pago;
    :new.percepcion01 := :new.percepcion;
    :new.percepcion02 := :new.percepcion;
    IF ( :new.moneda = 'PEN' ) THEN
        :new.pago02 := :new.pago / v_tipcam;
        :new.percepcion02 := :new.percepcion / v_tipcam;
    ELSE
        :new.pago01 := :new.pago * v_tipcam;
        :new.percepcion01 := :new.percepcion * v_tipcam;
    END IF;

EXCEPTION
    WHEN pkg_exceptionuser.ex_tcambio_no_existe THEN
        raise_application_error(pkg_exceptionuser.tcambio_no_existe, 'Tipo de cambio del día no existe');
END;


/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_DOCUMENTOS_DET_PERCEPCION" ENABLE;

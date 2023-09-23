--------------------------------------------------------
--  DDL for Trigger ANTES_ELIMINAR_COMPR010
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_ELIMINAR_COMPR010" BEFORE
    DELETE ON "USR_TSI_SUITE".compr010
    FOR EACH ROW
DECLARE
    v_conteo    NUMBER;
    v_conteo20  NUMBER;
BEGIN
    sp000_verifica_mes_cerrado_compr010(:old.id_cia, :old.periodo, :old.mes, :old.situac, :old.situac,
                                        :old.motcaja);

    v_conteo20 := 0;
    BEGIN
        SELECT
            COUNT(tipo)
        INTO v_conteo
        FROM
            prov101
        WHERE
                id_cia = :old.id_cia
            AND tipo = :old.tipo
            AND docu = :old.docume;

    EXCEPTION
        WHEN no_data_found THEN
            v_conteo := 0;
    END;

    IF (
        ( :old.impdetrac > 0 ) AND ( :old.swafeccion = 2 )
    ) THEN
        IF ( :old.tdocum <> '02' ) THEN
            BEGIN
                SELECT
                    COUNT(tipo)
                INTO v_conteo20
                FROM
                    prov101
                WHERE
                        id_cia = :old.id_cia
                    AND tipo = 200
                    AND docu = :old.docume;

            EXCEPTION
                WHEN no_data_found THEN
                    v_conteo20 := 0;
            END;

        END IF;
    END IF;

    IF ( ( v_conteo > 0 ) OR ( v_conteo20 > 0 ) ) THEN
        RAISE pkg_exceptionuser.ex_documento_tiene_pagos;
    END IF;

EXCEPTION
    WHEN pkg_exceptionuser.ex_documento_tiene_pagos THEN
        raise_application_error(pkg_exceptionuser.documento_tiene_pagos, 'El documento ya tiene pagos');
END;


/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_ELIMINAR_COMPR010" ENABLE;

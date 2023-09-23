--------------------------------------------------------
--  DDL for Trigger ANTES_INSERTAR_MOVIMIENTOS
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_MOVIMIENTOS" BEFORE
    INSERT ON "USR_TSI_SUITE".movimientos
    FOR EACH ROW
DECLARE
    v_destind VARCHAR2(16);
    v_destino VARCHAR2(1);
BEGIN
    IF ( ( :new.libro IS NULL ) OR ( :new.libro = '' ) OR ( :new.libro = ' ' ) OR ( :new.libro = '  ' ) OR ( length(:new.libro) < 2 )
    ) THEN
        RAISE pkg_exceptionuser.ex_libro_en_blanco;
    END IF; 
    
    -- ACTUALIZADO '20/02/2023' POR PROBLEMAS EN TAGA* REPORTE DE ANALITICA
    IF ( :new.tdocum IS NULL ) THEN
        :new.tdocum := ' ';
    END IF;

    IF ( :new.serie IS NULL ) THEN
        :new.serie := ' ';
    END IF;

    IF ( ( :new.ccosto IS NULL ) OR ( :new.ccosto = '' ) ) THEN
        v_destino := '';
        v_destind := '';
     /* SACA LAS CUENTAS DESTINO (DH) DEL PLAN DE CUENTAS */
        BEGIN
            SELECT
                destino,
                destid
            INTO
                v_destino,
                v_destind
            FROM
                pcuentas
            WHERE
                    id_cia = :new.id_cia
                AND cuenta = :new.cuenta;

        EXCEPTION
            WHEN no_data_found THEN
                v_destino := NULL;
                v_destind := NULL;
        END;

        IF (
            ( v_destino IS NOT NULL )
            AND ( upper(v_destino) = 'S' )
            AND ( v_destind IS NOT NULL )
        ) THEN
            :new.ccosto := v_destind;
        END IF;

    END IF;

EXCEPTION
    WHEN pkg_exceptionuser.ex_libro_en_blanco THEN
        raise_application_error(pkg_exceptionuser.libro_en_blanco, ' El libro esta en blanco o es incorrecto');
END;
/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_INSERTAR_MOVIMIENTOS" ENABLE;

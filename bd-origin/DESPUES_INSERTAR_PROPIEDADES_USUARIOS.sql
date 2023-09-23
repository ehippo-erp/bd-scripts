--------------------------------------------------------
--  DDL for Trigger DESPUES_INSERTAR_PROPIEDADES_USUARIOS
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."DESPUES_INSERTAR_PROPIEDADES_USUARIOS" AFTER
    INSERT ON "PROPIEDADES_USUARIOS"
    FOR EACH ROW
DECLARE
    v_conteo NUMBER;
BEGIN
    FOR j IN (
        SELECT
            cia
        FROM
            companias
    ) LOOP
        MERGE INTO usuarios_propiedades up
        USING dual ddd ON ( up.id_cia = j.cia
                            AND up.coduser = 'admin'
                            AND up.codigo = :new.codigo )
        WHEN NOT MATCHED THEN
        INSERT (
            id_cia,
            coduser,
            codigo,
            nombre,
            swflag,
            vstring,
            observ )
        VALUES
            ( j.cia,
            'admin',
            :new.codigo,
            :new.nombre,
            :new.swflag,
            NULL,
            :new.observ );

    END LOOP;
END;
/
ALTER TRIGGER "USR_TSI_SUITE"."DESPUES_INSERTAR_PROPIEDADES_USUARIOS" ENABLE;

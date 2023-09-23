--------------------------------------------------------
--  DDL for Procedure SP_ACTUALIZA_USUARIO_PROPIEDADES
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_ACTUALIZA_USUARIO_PROPIEDADES" (
    pin_id_cia IN NUMBER
) AS
BEGIN

    -- AGREGAR PERMISOS A TODOS LOS USUARIOS DE LA EMPRESA  QUE SE INDICA EN EL PARAMETRO DE ENTRADA
    -- SE MIGRA LOS PERMISOS DEL USUARIO 'admin' DE LA EMPRESA MODELO ID_CIA : 5

        FOR i IN (
        SELECT id_cia, coduser FROM usuarios
        WHERE  pin_id_cia = -1 or id_cia = pin_id_cia
    ) LOOP


        INSERT INTO usuarios_propiedades (
            id_cia,
            coduser,
            codigo,
            nombre,
            swflag,
            vstring

        )
            SELECT
                i.id_cia,
                i.coduser,
                dp.codigo,
                dp.nombre,
                dp.swflag, 
                dp.vstring

            FROM
                usuarios_propiedades dp
            WHERE dp.id_cia = 5
            AND dp.coduser = 'admin'
            AND NOT EXISTS (
                    SELECT
                        *
                    FROM
                        usuarios_propiedades
                    WHERE
                            id_cia = i.id_cia
                        AND coduser = i.coduser
                        AND codigo = dp.codigo
                );

    END LOOP;
END sp_actualiza_usuario_propiedades;

/

--------------------------------------------------------
--  DDL for Procedure SP_GENERA_PROPIEDADES_Y_PERMISOS
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_GENERA_PROPIEDADES_Y_PERMISOS" (
    pin_id_cia  IN NUMBER,
    pin_coduser IN VARCHAR2
) AS
BEGIN


    -- AGREGAR PERMISOS A TODOS LOS USUARIOS DE LA EMPRESA  QUE SE INDICA EN EL PARAMETRO DE ENTRADA
    -- SE MIGRA LOS PERMISOS DEL USUARIO 'admin' DE LA EMPRESA MODELO ID_CIA : 5

    FOR i IN (
        SELECT
            *
        FROM
            usuarios
        WHERE
                id_cia = pin_id_cia
            AND coduser = pin_coduser
    ) LOOP
        INSERT INTO permisos (
            id_cia,
            codmod,
            codacc,
            coduser
        )
            SELECT
                i.id_cia,
                p.codmod,
                p.codacc,
                i.coduser
            FROM
                permisos p
            WHERE
                    p.id_cia = 5
                AND coduser = 'admin'
                AND NOT EXISTS (
                    SELECT
                        *
                    FROM
                        permisos
                    WHERE
                            id_cia = i.id_cia
                        AND codmod = p.codmod
                        AND codacc = p.codacc
                        AND coduser = i.coduser
                );

        INSERT INTO usuarios_propiedades (
            id_cia,
            coduser,
            codigo,
            nombre,
            swflag,
            vstring,
            observ
        )
            SELECT
                i.id_cia,
                i.coduser,
                dp.codigo,
                dp.nombre,
                CASE
                    WHEN dp.codigo IN ( 5, 10, 11, 12, 13,
                                        84, 111, 38, 39, 80,
                                        85, 108, 109 ) THEN
                        'N'
                    ELSE
                        dp.swflag
                END AS swflag,
                dp.vstring,
                dp.observ
            FROM
                usuarios_propiedades dp
            WHERE
                    dp.id_cia = 5
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
END sp_genera_propiedades_y_permisos;

/

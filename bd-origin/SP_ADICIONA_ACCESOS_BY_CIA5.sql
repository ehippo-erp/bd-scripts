--------------------------------------------------------
--  DDL for Procedure SP_ADICIONA_ACCESOS_BY_CIA5
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_ADICIONA_ACCESOS_BY_CIA5" (
    pin_id_cia IN INTEGER
) AS
        
    v_user_admin varchar2(16) := 'admin';
      v_cia5 number := 5;


    CURSOR cur_usuarios (
        ppcia INTEGER
    ) IS
    SELECT
        id_cia,
        coduser,
        nombres
    FROM
        usuarios
    WHERE
        (ppcia = -1 or id_cia = ppcia)
        and id_cia <> 5;
BEGIN

        FOR ruser IN cur_usuarios(pin_id_cia) LOOP
            INSERT INTO permisos (
                id_cia,
                codmod,
                codacc,
                coduser
            )
                SELECT
                    ruser.id_cia,
                    p.codmod,
                    p.codacc,
                    ruser.coduser
                FROM
                    permisos p
                WHERE
                        p.id_cia = 5
                    AND p.coduser = 'admin'

                    AND not EXISTS (
                        SELECT
                            p1.id_cia,
                            p1.codmod,
                            p1.codacc,
                            p1.coduser
                        FROM
                            permisos p1
                        WHERE
                                p1.id_cia = ruser.id_cia
                            AND p1.codmod = p.codmod
                            AND p1.codacc = p.codacc
                            AND p1.coduser = ruser.coduser
                    )
                ORDER BY
                    codmod,
                    codacc;

            COMMIT;

        END LOOP;

END;

/

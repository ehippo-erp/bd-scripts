--------------------------------------------------------
--  DDL for Package Body PACK_CF_USUARIOS_PROPIEDADES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_CF_USUARIOS_PROPIEDADES" AS

    FUNCTION sp_buscar_usuarios (
        pin_id_cia NUMBER,
        pin_codigo NUMBER
    ) RETURN datatable_usuarios
        PIPELINED
    AS
        v_table datatable_usuarios;
    BEGIN
        SELECT
            p.coduser,
            u.nombres
        BULK COLLECT
        INTO v_table
        FROM
            usuarios_propiedades p
            INNER JOIN usuarios             u ON u.id_cia = p.id_cia
                                          AND u.coduser = p.coduser
        WHERE
                p.id_cia = pin_id_cia
            AND p.codigo = pin_codigo
            AND NVL(u.situac,'S') IN ('A','S');

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar_usuarios;

END;

/

--------------------------------------------------------
--  DDL for Package Body PACK_TANALITICA
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_TANALITICA" AS

    FUNCTION sp_sel_tanalitica (
        pin_id_cia    IN  NUMBER,
        pin_swactivo  IN  CHAR
    ) RETURN t_tanalitica
        PIPELINED
    IS
        v_table t_tanalitica;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            tanalitica
        WHERE
                id_cia = pin_id_cia
            AND ( ( pin_swactivo IS NULL )
                  OR ( swacti = pin_swactivo ) );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        return;
    END sp_sel_tanalitica;

    PROCEDURE sp_save_tanalitica (
        pin_id_cia   IN   NUMBER,
        pin_datos    IN   VARCHAR2,
        pin_opcdml   INTEGER,
        pin_mensaje  OUT  VARCHAR2
    ) IS
        o               json_object_t;
        rec_tanalitica  tanalitica%rowtype;
        v_accion        VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_tanalitica.id_cia := pin_id_cia;
        rec_tanalitica.codtana := o.get_number('codtana');
        rec_tanalitica.descri := o.get_string('descri');
        rec_tanalitica.usuari := o.get_string('usuari');
        rec_tanalitica.swacti := o.get_string('swacti');
        rec_tanalitica.moneda := o.get_string('moneda');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                INSERT INTO tanalitica (
                    id_cia,
                    codtana,
                    descri,
                    usuari,
                    swacti,
                    moneda
                ) VALUES (
                    rec_tanalitica.id_cia,
                    rec_tanalitica.codtana,
                    rec_tanalitica.descri,
                    rec_tanalitica.usuari,
                    rec_tanalitica.swacti,
                    rec_tanalitica.moneda
                );

                COMMIT;
            WHEN 2 THEN
                UPDATE tanalitica
                SET
                    descri = rec_tanalitica.descri,
                    usuari = rec_tanalitica.usuari,
                    swacti = rec_tanalitica.swacti,
                    moneda = rec_tanalitica.moneda
                WHERE
                        id_cia = rec_tanalitica.id_cia
                    AND codtana = rec_tanalitica.codtana;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM tanalitica
                WHERE
                        id_cia = rec_tanalitica.id_cia
                    AND codtana = rec_tanalitica.codtana;

                COMMIT;
        END CASE;

        pin_mensaje := v_accion || ' se realizó satisfactoriamente';
    EXCEPTION
        WHEN dup_val_on_index THEN
            raise_application_error(pkg_exceptionuser.registro_duplicado, ' El registro ya existe');
    END;

END;

/

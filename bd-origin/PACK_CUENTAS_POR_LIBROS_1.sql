--------------------------------------------------------
--  DDL for Package Body PACK_CUENTAS_POR_LIBROS
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_CUENTAS_POR_LIBROS" AS

    FUNCTION sp_sel_pcuentas (
        pin_id_cia IN NUMBER
    ) RETURN t_pcuentas
        PIPELINED
    IS
        v_table t_pcuentas;
    BEGIN
        SELECT
            p.id_cia,
            p.cuenta,
            p.nombre
        BULK COLLECT
        INTO v_table
        FROM
                 pcuentas p
            INNER JOIN pcuentas_clase pc ON pc.cuenta = p.cuenta
                                            AND pc.clase = 11
                                            AND pc.codigo = '1'
        WHERE
            p.imputa = 'S'
        ORDER BY
            p.cuenta;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        return;
    END sp_sel_pcuentas;

    FUNCTION sp_sel_cuentas_cchica (
        pin_id_cia  IN  NUMBER,
        pin_motivo  IN  NUMBER
    ) RETURN t_cuentas_cchica
        PIPELINED
    IS
        v_table t_cuentas_cchica;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            cuentas_cchica
        WHERE
                id_cia = pin_id_cia
            AND motivo = pin_motivo;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        return;
    END sp_sel_cuentas_cchica;

    PROCEDURE sp_save_cuentas_cchica (
        pin_id_cia   IN   NUMBER,
        pin_datos    IN   VARCHAR2,
        pin_opcdml   INTEGER,
        pin_mensaje  OUT  VARCHAR2
    ) IS
        o                   json_object_t;
        rec_cuentas_cchica  cuentas_cchica%rowtype;
        v_accion            VARCHAR2(50) := '';
    BEGIN
--SET SERVEROUTPUT ON;
--
--DECLARE
--    cadjson  VARCHAR2(4000);
--    mensaje  VARCHAR(150);
--BEGIN
--    cadjson := '{"motivo":0,
--    "cuenta":"102101",
--    "nombre":"FONDOS FIJOS SOLES - RAFAEL RODRIGUEZ",
--    "dh":"D"}';
--    pack_cuentas_por_libros.sp_save_cuentas_cchica(13, cadjson, 1, mensaje);
--    dbms_output.put_line(mensaje);
--END;
        o := json_object_t.parse(pin_datos);
        rec_cuentas_cchica.id_cia := pin_id_cia;
        rec_cuentas_cchica.motivo := o.get_number('motivo');
        rec_cuentas_cchica.cuenta := o.get_string('cuenta');
        rec_cuentas_cchica.nombre := o.get_string('nombre');
        rec_cuentas_cchica.dh := o.get_string('dh');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                INSERT INTO cuentas_cchica (
                    id_cia,
                    motivo,
                    cuenta,
                    nombre,
                    dh
                ) VALUES (
                    rec_cuentas_cchica.id_cia,
                    rec_cuentas_cchica.motivo,
                    rec_cuentas_cchica.cuenta,
                    rec_cuentas_cchica.nombre,
                    rec_cuentas_cchica.dh
                );

                COMMIT;
            WHEN 2 THEN
                UPDATE cuentas_cchica
                SET
                    nombre = rec_cuentas_cchica.nombre,
                    dh = rec_cuentas_cchica.dh
                WHERE
                        id_cia = rec_cuentas_cchica.id_cia
                    AND motivo = rec_cuentas_cchica.motivo
                    AND cuenta = rec_cuentas_cchica.cuenta;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM cuentas_cchica
                WHERE
                        id_cia = rec_cuentas_cchica.id_cia
                    AND motivo = rec_cuentas_cchica.motivo
                    AND cuenta = rec_cuentas_cchica.cuenta;

                COMMIT;
        END CASE;

        pin_mensaje := v_accion || ' se realizó satisfactoriamente';
    EXCEPTION
        WHEN dup_val_on_index THEN
            raise_application_error(pkg_exceptionuser.registro_duplicado, ' El registro ya existe');
    END;

    PROCEDURE sp_ins_masivo_cuentas_cchica (
        pin_id_cia  IN  NUMBER,
        pin_datos   IN  CLOB
    ) AS
    BEGIN
--SET SERVEROUTPUT ON;
--
--DECLARE
--    dato     CLOB := empty_clob();
--BEGIN
--    dato := '[{"motivo": 0, "cuenta":"102101","nombre": "FONDOS FIJOS SOLES - RAFAEL RODRIGUEZ","dh":"D"},
--   {"motivo": 0, "cuenta":"102102","nombre": "FONDOS FIJOS DOLARES - RAFAEL RODRIGUEZ", "dh":"D"}]';
--    pack_cuentas_por_libros.sp_ins_masivo_cuentas_cchica(13, dato);
--END;
        FOR registro IN (
            WITH json AS (
                SELECT
                    pin_datos AS doc
                FROM
                    dual
            )
            SELECT
                motivo,
                cuenta,
                nombre,
                dh
            FROM
                JSON_TABLE ( (
                    SELECT
                        doc
                    FROM
                        json
                ), '$[*]'
                    COLUMNS (
                        motivo PATH '$.motivo',
                        cuenta PATH '$.cuenta',
                        nombre PATH '$.nombre',
                        dh PATH '$.dh'
                    )
                )
        ) LOOP
            INSERT INTO cuentas_cchica (
                id_cia,
                motivo,
                cuenta,
                nombre,
                dh
            ) VALUES (
                pin_id_cia,
                registro.motivo,
                registro.cuenta,
                registro.nombre,
                registro.dh
            );

            COMMIT;
        END LOOP;
    END;

END;

/

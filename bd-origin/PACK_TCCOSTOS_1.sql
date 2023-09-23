--------------------------------------------------------
--  DDL for Package Body PACK_TCCOSTOS
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_TCCOSTOS" AS

    FUNCTION sp_sel_tccostos (
        pin_id_cia IN NUMBER
    ) RETURN t_tccostos
        PIPELINED
    IS
        v_table t_tccostos;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            tccostos
        WHERE
            id_cia = pin_id_cia;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        return;
    END sp_sel_tccostos;

    PROCEDURE sp_save_tccostos (
        pin_id_cia   IN   NUMBER,
        pin_datos    IN   VARCHAR2,
        pin_opcdml   INTEGER,
        pin_mensaje  OUT  VARCHAR2
    ) IS
        o             json_object_t;
        rec_tccostos  tccostos%rowtype;
        v_accion      VARCHAR2(50) := '';
    BEGIN
--SET SERVEROUTPUT ON;
--
--DECLARE
--    cadjson  VARCHAR2(4000);
--    mensaje  VARCHAR(150);
--BEGIN
--    cadjson := '{"codigo":"791001",
--    "descri":"costo produccion",
--    "succcosto":"S",
--    "destino":"S",
--    "destin":"791002",
--    "usuari":"RAOJ",
--    "swacti":"S"}';
--    pack_tccostos.sp_save_tccostos(13, cadjson, 3, mensaje);
--    dbms_output.put_line(mensaje);
--END;
        o := json_object_t.parse(pin_datos);
        rec_tccostos.id_cia := pin_id_cia;
        rec_tccostos.codigo := o.get_string('codigo');
        rec_tccostos.descri := o.get_string('descri');
        rec_tccostos.succcosto := o.get_string('succcosto');
        rec_tccostos.destino := o.get_string('destino');
        rec_tccostos.destin := o.get_string('destin');
        rec_tccostos.usuari := o.get_string('usuari');
        rec_tccostos.swacti := o.get_string('swacti');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                INSERT INTO tccostos (
                    id_cia,
                    codigo,
                    descri,
                    succcosto,
                    destino,
                    destin,
                    usuari,
                    swacti
                ) VALUES (
                    rec_tccostos.id_cia,
                    rec_tccostos.codigo,
                    rec_tccostos.descri,
                    rec_tccostos.succcosto,
                    rec_tccostos.destino,
                    rec_tccostos.destin,
                    rec_tccostos.usuari,
                    rec_tccostos.swacti
                );

                COMMIT;
            WHEN 2 THEN
                UPDATE tccostos
                SET
                    descri = rec_tccostos.descri,
                    succcosto = rec_tccostos.succcosto,
                    destino = rec_tccostos.destino,
                    destin = rec_tccostos.destin,
                    usuari = rec_tccostos.usuari,
                    swacti = rec_tccostos.swacti
                WHERE
                        id_cia = rec_tccostos.id_cia
                    AND codigo = rec_tccostos.codigo;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM tccostos
                WHERE
                        id_cia = rec_tccostos.id_cia
                    AND codigo = rec_tccostos.codigo;

                COMMIT;
        END CASE;

        pin_mensaje := v_accion || ' se realizó satisfactoriamente';
    EXCEPTION
        WHEN dup_val_on_index THEN
            raise_application_error(pkg_exceptionuser.registro_duplicado, ' El registro ya existe');
    END;

END;

/

--------------------------------------------------------
--  DDL for Package Body PACK_M_DESTINO
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_M_DESTINO" AS

    FUNCTION sp_sel_m_destino (
        pin_id_cia IN NUMBER
    ) RETURN t_m_destino
        PIPELINED
    IS
        v_table t_m_destino;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            m_destino
        WHERE
            id_cia = pin_id_cia;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        return;
    END sp_sel_m_destino;

    PROCEDURE sp_save_m_destino (
        pin_id_cia   IN   NUMBER,
        pin_datos    IN   VARCHAR2,
        pin_opcdml   INTEGER,
        pin_mensaje  OUT  VARCHAR2
    ) IS
        o              json_object_t;
        rec_m_destino  m_destino%rowtype;
        v_accion       VARCHAR2(50) := '';
    BEGIN
--    SET SERVEROUTPUT ON;
--
--DECLARE
--    cadjson  VARCHAR2(4000);
--    mensaje  VARCHAR(150);
--BEGIN
--    cadjson := '{"codigo":10,
--    "descri":"mangos",
--    "situac":"A",
--    "usuari":"RAOJ" }';
--  
--    pack_M_DESTINO.sp_save_M_DESTINO(13, cadjson, 3, mensaje);
--    dbms_output.put_line(mensaje);
--END;
        o := json_object_t.parse(pin_datos);
        rec_m_destino.id_cia := pin_id_cia;
        rec_m_destino.codigo := o.get_number('codigo');
        rec_m_destino.descri := o.get_string('descri');
        rec_m_destino.situac := o.get_string('situac');
        rec_m_destino.usuari := o.get_string('usuari');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                INSERT INTO m_destino (
                    id_cia,
                    codigo,
                    descri,
                    situac,
                    usuari
                ) VALUES (
                    rec_m_destino.id_cia,
                    rec_m_destino.codigo,
                    rec_m_destino.descri,
                    rec_m_destino.situac,
                    rec_m_destino.usuari
                );

                COMMIT;
            WHEN 2 THEN
                UPDATE m_destino
                SET
                    descri = rec_m_destino.descri,
                    situac = rec_m_destino.situac,
                    usuari = rec_m_destino.usuari
                WHERE
                        id_cia = rec_m_destino.id_cia
                    AND codigo = rec_m_destino.codigo;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM m_destino
                WHERE
                        id_cia = rec_m_destino.id_cia
                    AND codigo = rec_m_destino.codigo;

                COMMIT;
        END CASE;

        pin_mensaje := v_accion || ' se realizó satisfactoriamente';
    EXCEPTION
        WHEN dup_val_on_index THEN
            raise_application_error(pkg_exceptionuser.registro_duplicado, ' El registro ya existe');
    END;

END;

/

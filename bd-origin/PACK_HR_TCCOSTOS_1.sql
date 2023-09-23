--------------------------------------------------------
--  DDL for Package Body PACK_HR_TCCOSTOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_HR_TCCOSTOS" AS

    FUNCTION sp_buscar (
        pin_id_cia IN NUMBER
    ) RETURN datatable_tccostos
        PIPELINED
    IS
        v_table datatable_tccostos;
    BEGIN
        SELECT
            tc.id_cia,
            tc.codigo,
            pc.nombre AS descodigo,
            tc.descri,
            tc.succcosto,
            tc.destino,
            tc.destin,
            pd.nombre AS desdestin,
            tc.swacti,
            tc.usuari,
            tc.fcreac,
            tc.factua
        BULK COLLECT
        INTO v_table
        FROM
            tccostos tc
            LEFT OUTER JOIN pcuentas pc ON pc.id_cia = tc.id_cia
                                           AND pc.cuenta = tc.codigo
            LEFT OUTER JOIN pcuentas pd ON pd.id_cia = tc.id_cia
                                           AND pd.cuenta = tc.destin
        WHERE
            tc.id_cia = pin_id_cia;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  INTEGER,
        pin_mensaje OUT VARCHAR2
    ) IS

        o            json_object_t;
        rec_tccostos tccostos%rowtype;
        v_accion     VARCHAR2(50) := '';
        pout_mensaje VARCHAR2(1000 CHAR);
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

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE v_accion || ' se realizó satisfactoriamente'
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
        WHEN dup_val_on_index THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE 'EL REGISTRO DE CENTRO DE COSTOS [ '
                                    || rec_tccostos.codigo
                                    || ' ] YA EXISTSTE Y NO PUEDE DUPLICARSE'
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN pkg_exceptionuser.ex_error_inesperado THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE pout_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

            ROLLBACK;
        WHEN OTHERS THEN
            pin_mensaje := 'mensaje : '
                           || sqlerrm
                           || ' codigo :'
                           || sqlcode;
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pin_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

            ROLLBACK;
    END sp_save;

END;

/

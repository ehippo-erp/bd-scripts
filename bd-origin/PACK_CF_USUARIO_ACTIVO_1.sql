--------------------------------------------------------
--  DDL for Package Body PACK_CF_USUARIO_ACTIVO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_CF_USUARIO_ACTIVO" AS

    FUNCTION sp_buscar (
        pin_id_cia NUMBER
    ) RETURN datatable_usuario_activo
        PIPELINED
    AS
        v_table datatable_usuario_activo;
    BEGIN
        SELECT
            ua.id_cia,
            ua.id,
            ua.coduser,
            u.nombres,
            ua.ip,
            ua.codpro,
            pl.despro,
            ua.factua,
            to_char(ua.factua, 'HH24:MI:SS')
        BULK COLLECT
        INTO v_table
        FROM
                 usuarios_activos ua
            INNER JOIN usuarios          u ON u.id_cia = ua.id_cia
                                     AND u.coduser = ua.coduser
            INNER JOIN producto_licencia pl ON pl.codpro = ua.codpro
        WHERE
                ua.id_cia = pin_id_cia
            AND ua.coduser NOT IN ( 'admin', 'admec' )
            AND ua.activo = 'S'
            AND ua.tokentipo = 1;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar;

    FUNCTION sp_alerta (
        pin_id_cia NUMBER
    ) RETURN datatable_alerta
        PIPELINED
    AS
        v_table datatable_alerta;
    BEGIN
        SELECT
            ppp.*
        BULK COLLECT
        INTO v_table
        FROM
            producto_licencia                                           pl
            LEFT OUTER JOIN pack_cf_usuario_activo.sp_alerta_aux(pin_id_cia, pl.codpro) ppp ON 0 = 0;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_alerta;

    FUNCTION sp_alerta_aux (
        pin_id_cia NUMBER,
        pin_codpro VARCHAR2
    ) RETURN datatable_alerta
        PIPELINED
    AS
        v_rec datarecord_alerta;
    BEGIN
        v_rec.id_cia := pin_id_cia;
        BEGIN
            SELECT
                nvl(COUNT(0),
                    0)
            INTO v_rec.connectuser
            FROM
                usuarios_activos ua
            WHERE
                    ua.id_cia = pin_id_cia
                AND ua.coduser NOT IN ( 'admin', 'admec' )
                AND ua.codpro = pin_codpro
                AND ua.activo = 'S'
                AND ua.tokentipo = 1;

        EXCEPTION
            WHEN no_data_found THEN
                v_rec.connectuser := 0;
        END;

        BEGIN
            SELECT
                nvl(ua.nrolicencia, 0)
            INTO v_rec.totaluser
            FROM
                licencia_resumen ua
            WHERE
                    ua.id_cia = pin_id_cia
                AND ua.codpro = pin_codpro;

        EXCEPTION
            WHEN no_data_found THEN
                v_rec.totaluser := 0;
        END;

        BEGIN
            SELECT
                despro
            INTO v_rec.despro
            FROM
                producto_licencia lp
            WHERE
                lp.codpro = pin_codpro;

        EXCEPTION
            WHEN no_data_found THEN
                v_rec.despro := 'NO DEFINIDO';
        END;

        v_rec.codpro := pin_codpro;
        v_rec.noconnectuser := v_rec.totaluser - v_rec.connectuser;
        PIPE ROW ( v_rec );
    END sp_alerta_aux;

    PROCEDURE sp_clean (
        pin_id_cia  IN INTEGER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS
    BEGIN
        FOR i IN (
            SELECT
                ua.id_cia,
                ua.id,
                ua.coduser,
                ua.ip,
                ua.fcreac,
                current_timestamp,
                ( current_timestamp - ua.factua ) AS diff
            FROM
                usuarios_activos ua
            WHERE
                    ua.id_cia = pin_id_cia
--                AND ua.coduser NOT IN ( 'admin', 'admec' )
                AND ua.activo = 'S'
                AND ua.tokentipo = 1
                AND ( current_timestamp - ua.factua ) > INTERVAL '1:15' HOUR TO MINUTE
        ) LOOP
            DELETE FROM usuarios_activos
            WHERE
                    id_cia = i.id_cia
                AND id = i.id
                AND coduser = i.coduser;

            dbms_output.put_line(i.id_cia
                                 || ' | '
                                 || i.id
                                 || ' | '
                                 || i.coduser);

        END LOOP;

        COMMIT;
        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Success!'
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
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
    END sp_clean;

    PROCEDURE sp_valida (
        pin_id_cia  IN INTEGER,
        pin_codpro  IN VARCHAR2,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS

        v_swacti       VARCHAR2(1 CHAR) := 'N';
        v_connectuser  INTEGER;
        v_nrolicencias INTEGER;
        v_factua       VARCHAR2(1000 CHAR);
        v_fcreac       VARCHAR2(1000 CHAR);
    BEGIN
        IF pin_coduser IN ( 'admin', 'admec' ) THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.0,
                    'message' VALUE 'Success!'
                )
            INTO pin_mensaje
            FROM
                dual;

            RETURN;
        END IF;

        BEGIN
        -- ELIMIANDO USUARIO INACTIVO POR UNA HORA
            DELETE FROM usuarios_activos ua
            WHERE
                    ua.id_cia = pin_id_cia
                AND ua.coduser = pin_coduser
                AND ua.codpro = pin_codpro
                AND ua.activo = 'S'
                AND ua.tokentipo = 1
                AND ( current_timestamp - ua.factua ) > INTERVAL '1:00' HOUR TO MINUTE;

            COMMIT;
            SELECT
                'S',
                to_char(fcreac, 'DD/MM/YY HH24:MI:SS'),
                to_char(factua, 'DD/MM/YY HH24:MI:SS')
            INTO
                v_swacti,
                v_fcreac,
                v_factua
            FROM
                usuarios_activos ua
            WHERE
                    ua.id_cia = pin_id_cia
                AND ua.coduser = pin_coduser
                AND ua.codpro = pin_codpro
                AND ua.activo = 'S'
                AND ua.tokentipo = 1
            FETCH NEXT 1 ROWS ONLY;

        EXCEPTION
            WHEN no_data_found THEN
                v_swacti := 'N';
                v_fcreac := 'ND';
                v_factua := 'ND';
        END;

        BEGIN
            SELECT
                nvl(ua.nrolicencia, 0)
            INTO v_nrolicencias
            FROM
                licencia_resumen ua
            WHERE
                    ua.id_cia = pin_id_cia
                AND ua.codpro = pin_codpro;

        EXCEPTION
            WHEN no_data_found THEN
                v_nrolicencias := 0;
        END;

        BEGIN
            SELECT
                nvl(COUNT(0),
                    0)
            INTO v_connectuser
            FROM
                usuarios_activos ua
            WHERE
                    ua.id_cia = pin_id_cia
                AND ua.coduser NOT IN ( 'admin', 'admec' )
                AND ua.codpro = pin_codpro
                AND ua.activo = 'S'
                AND ua.tokentipo = 1;

        EXCEPTION
            WHEN no_data_found THEN
                v_connectuser := 0;
        END;

        IF v_swacti = 'S' THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE 'EL USUARIO [ '
                                    || pin_coduser
                                    || ' ] YA TIENE UNA SESION ACTIVA EN EL MODULO '
                                    || pin_codpro
                                    || ', INICIADA EL '
                                    || v_fcreac
                                    || ' Y ACTUALIZADA '
                                    || v_factua
                )
            INTO pin_mensaje
            FROM
                dual;

            RETURN;
        END IF;

        IF v_nrolicencias <= 0 THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE 'EMPRESA SIN LICENCIA PARA INGRESAR AL MODULO '
                                    || pin_codpro
                                    || '!'
                )
            INTO pin_mensaje
            FROM
                dual;

            RETURN;
        END IF;

        IF v_connectuser >= v_nrolicencias THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                            'message' VALUE 'LA CANTIDAD DE USUARIOS CONCURRENTES [ '
                                            || to_char(v_connectuser)
                                            || ' ] A LLEGADO AL TOPE MAXIMO [ '
                                            || to_char(v_nrolicencias)
                                            || ' ] PERMITIDO EN EL MODULO '
                                            || pin_codpro
                                            || '!'
                )
            INTO pin_mensaje
            FROM
                dual;

            RETURN;
        END IF;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Success!'
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
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
--            SELECT
--                JSON_OBJECT(
--                    'status' VALUE 1.0,
--                    'message' VALUE 'Success!'
--                )
--            INTO pin_mensaje
--            FROM
--                dual;

    END sp_valida;

END;

/

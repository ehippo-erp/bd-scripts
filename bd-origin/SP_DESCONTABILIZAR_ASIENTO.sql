--------------------------------------------------------
--  DDL for Procedure SP_DESCONTABILIZAR_ASIENTO
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_DESCONTABILIZAR_ASIENTO" (
    pin_id_cia    IN NUMBER,
    pin_libro     IN VARCHAR2,
    pin_periodo   IN NUMBER,
    pin_mes       IN NUMBER,
    pin_secuencia IN NUMBER,--asiento
    pin_usuario   IN VARCHAR2,
    pin_mensaje   OUT VARCHAR2
) AS

    v_mensaje    VARCHAR2(1000) := '';
    v_deslib     VARCHAR2(1000) := '';
    pout_mensaje VARCHAR2(1000) := '';
    o            json_object_t;
    v_aux        VARCHAR2(1 CHAR);
BEGIN

--SET SERVEROUTPUT on;
--
--DECLARE
--    v_mensaje VARCHAR2(2000);
--BEGIN
--    sp_descontabilizar_asiento(66,'01',2022,01,1,'admin', v_mensaje);
--    dbms_output.put_line(v_mensaje);
--END;

    -- 1 : MODULO CONTABILIDAD 
    sp_chequea_mes_proceso(pin_id_cia, pin_periodo, pin_mes, 1, v_mensaje);
    o := json_object_t.parse(v_mensaje);
    IF ( o.get_number('status') <> 1.0 ) THEN
        pout_mensaje := o.get_string('message');
        RAISE pkg_exceptionuser.ex_error_inesperado;
    END IF;

    BEGIN
        SELECT
            'S'
        INTO v_aux
        FROM
            asienhea a
        WHERE
                a.id_cia = pin_id_cia
            AND a.libro = pin_libro
            AND a.periodo = pin_periodo
            AND a.mes = pin_mes
            AND a.asiento = pin_secuencia
            AND EXISTS (
                SELECT
                    p102.*
                FROM
                    prov102 p102
                WHERE
                        p102.id_cia = a.id_cia
                    AND p102.libro = a.libro
                    AND p102.periodo = a.periodo
                    AND p102.mes = a.mes
                    AND p102.secuencia = a.asiento
                    AND p102.situac <> 'J'
            );

        pout_mensaje := 'EL ASIENTO NO PUEDE SER DESCONTABILIZADO, PORQUE EXISTE UNA PLANILLA RELACIONADA EN EL MODULO DE CUENTAS POR PAGAR'
        ;
        RAISE pkg_exceptionuser.ex_error_inesperado;
    EXCEPTION
        WHEN no_data_found THEN
            NULL;
    END;

    BEGIN
        SELECT
            'S'
        INTO v_aux
        FROM
            asienhea a
        WHERE
                a.id_cia = pin_id_cia
            AND a.libro = pin_libro
            AND a.periodo = pin_periodo
            AND a.mes = pin_mes
            AND a.asiento = pin_secuencia
            AND EXISTS (
                SELECT
                    d102.*
                FROM
                    dcta102 d102
                WHERE
                        d102.id_cia = a.id_cia
                    AND d102.libro = a.libro
                    AND d102.periodo = a.periodo
                    AND d102.mes = a.mes
                    AND d102.secuencia = a.asiento
                    AND d102.situac <> 'J'
            );

        pout_mensaje := 'EL ASIENTO NO PUEDE SER DESCONTABILIZADO, PORQUE EXISTE UNA PLANILLA RELACIONADA EN EL MODULO DE CUENTAS POR COBRAR'
        ;
        RAISE pkg_exceptionuser.ex_error_inesperado;
    EXCEPTION
        WHEN no_data_found THEN
            NULL;
    END;

    IF TRIM(pin_libro) IN ( '01', '02', '03', '07' ) THEN
        BEGIN
            SELECT
                descri
            INTO v_deslib
            FROM
                tlibro
            WHERE
                    id_cia = pin_id_cia
                AND codlib = TRIM(pin_libro);

        EXCEPTION
            WHEN no_data_found THEN
                v_deslib := trim(pin_libro);
        END;

        pout_mensaje := 'NO SE PUEDE DESCONTABILIZAR, UN ASIENTO RELACIONADO A ESTE LIBRO - ' || upper(v_deslib);
        RAISE pkg_exceptionuser.ex_error_inesperado;
    END IF;

    UPDATE asienhea
    SET
        situac = 1,
        factua = TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
             'YYYY-MM-DD HH24:MI:SS'),
        usuari = pin_usuario
    WHERE
            id_cia = pin_id_cia
        AND libro = TRIM(pin_libro)
        AND periodo = pin_periodo
        AND mes = pin_mes
        AND asiento = pin_secuencia;

    DELETE FROM movimientos
    WHERE
            id_cia = pin_id_cia
        AND libro = TRIM(pin_libro)
        AND periodo = pin_periodo
        AND mes = pin_mes
        AND asiento = pin_secuencia;

    COMMIT;
    SELECT
        JSON_OBJECT(
            'status' VALUE 1.0,
            'message' VALUE 'El proceso completó correctamente.'
        )
    INTO pin_mensaje
    FROM
        dual;

EXCEPTION
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
END sp_descontabilizar_asiento;

/

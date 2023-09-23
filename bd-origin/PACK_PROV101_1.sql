--------------------------------------------------------
--  DDL for Package Body PACK_PROV101
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_PROV101" AS

    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_tipo   NUMBER,
        pin_docu   NUMBER
    ) RETURN datatable_prov101
        PIPELINED
    AS
        v_table datatable_prov101;
    BEGIN
        SELECT
            *
        BULK COLLECT
        INTO v_table
        FROM
            prov101
        WHERE
                id_cia = pin_id_cia
            AND tipo = pin_tipo
            AND docu = pin_docu;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    PROCEDURE delprov101 (
        pin_id_cia    IN NUMBER,
        pin_libro     IN VARCHAR2,
        pin_periodo   IN NUMBER,
        pin_mes       IN NUMBER,
        pin_secuencia IN NUMBER,
        pin_mensaje   OUT VARCHAR2
    ) AS
        v_accion VARCHAR2(50) := 'el proceso';
    BEGIN
        DELETE FROM prov101
        WHERE
            ( id_cia = pin_id_cia )
            AND NOT ( libro = 'hoa' )
            AND libro = pin_libro
            AND periodo = pin_periodo
            AND mes = pin_mes
            AND secuencia = pin_secuencia;

        COMMIT;
        v_accion := 'el proceso completó correctamente.';
        pin_mensaje := v_accion;
    EXCEPTION
        WHEN OTHERS THEN
            raise_application_error(pkg_exceptionuser.error_inesperado, 'No se pudo eliminar el Registro de Prov101 debido a : '
                                                                        || sqlcode
                                                                        || ' -ERROR- '
                                                                        || sqlerrm);
    END delprov101;

    PROCEDURE enviar_ctas_ctes_from_prov103 (
        pin_id_cia    IN NUMBER,
        pin_libro     IN VARCHAR2,
        pin_periodo   IN NUMBER,
        pin_mes       IN NUMBER,
        pin_secuencia IN NUMBER,
        pin_usuari    IN VARCHAR2,
        pin_mensaje   OUT VARCHAR2
    ) AS

        v_accion VARCHAR2(50) := 'el proceso';
        v_numite NUMBER := 0;
        CURSOR cur_select IS
        SELECT
            pin_id_cia,
            p.tipo,
            p.docu,
            p.libro,
            p.periodo,
            p.mes,
            p.secuencia,
            p.item,
            p.tipcan,
            p.doccan,
            p.refere01,
            p.refere02,
            c.codcob,
            p.cuenta,
            p.dh,
            p.tipmon,
            p.amorti,
            p.impor01,
            p.impor02,
            p.tcamb01,
            p.tcamb02,
            p.impor01 * cr.porcom AS comision,
            c.codsuc,
            c.femisi
        FROM
            prov103  p
            LEFT OUTER JOIN prov102  c ON c.id_cia = pin_id_cia
                                         AND c.libro = p.libro
                                         AND c.periodo = p.periodo
                                         AND c.mes = p.mes
                                         AND c.secuencia = p.secuencia
            LEFT OUTER JOIN cobrador cr ON cr.id_cia = pin_id_cia
                                           AND cr.codcob = c.codcob
        WHERE
            ( p.id_cia = pin_id_cia )
            AND ( p.libro = pin_libro )
            AND ( p.periodo = pin_periodo )
            AND ( p.mes = pin_mes )
            AND ( p.secuencia = pin_secuencia )
            AND NOT ( p.situac = 'J ' );

    BEGIN
            --eliminamos los registros en base a los parametros principales
--        DELETE FROM prov101
--        WHERE
--            ( id_cia = pin_id_cia )
--            AND NOT ( libro = 'hoa' )
--            AND libro = pin_libro
--            AND periodo = pin_periodo
--            AND mes = pin_mes
--            AND secuencia = pin_secuencia;
--
--        COMMIT;
        FOR reg IN cur_select LOOP
            BEGIN
                SELECT
                    trunc((MAX(nvl(numite, 0)) / 1))
                INTO v_numite
                FROM
                    prov101
                WHERE
                        id_cia = pin_id_cia
                    AND tipo = reg.tipo
                    AND docu = reg.docu;

            EXCEPTION
                WHEN no_data_found THEN
                    v_numite := NULL;
            END;

            IF ( v_numite IS NULL ) THEN
                v_numite := 0;
            END IF;
            v_numite := v_numite + 1;
            INSERT INTO prov101 (
                id_cia,
                tipo,
                docu,
                numite,
                fproce,
                libro,
                periodo,
                mes,
                secuencia,
                item,
                tipcan,
                doccan,
                refere01,
                refere02,
                codcob,
                cuenta,
                dh,
                tipmon,
                importe,
                impor01,
                impor02,
                tcamb01,
                tcamb02,
                comisi,
                codsuc,
                fcreac,
                factua,
                usuari,
                situac,
                femisi
            ) VALUES (
                pin_id_cia,
                reg.tipo,
                reg.docu,
                v_numite,
                current_date,
                reg.libro,
                reg.periodo,
                reg.mes,
                reg.secuencia,
                reg.item,
                reg.tipcan,
                reg.doccan,
                reg.refere01,
                reg.refere02,
                reg.codcob,
                reg.cuenta,
                reg.dh,
                reg.tipmon,
                reg.amorti,
                reg.impor01,
                reg.impor02,
                reg.tcamb01,
                reg.tcamb02,
                reg.comision,
                reg.codsuc,
                current_timestamp,
                current_timestamp,
                pin_usuari,
                'A',
                reg.femisi
            );

            COMMIT;
            sp_actualiza_saldo_prov100(pin_id_cia, reg.tipo, reg.docu);
            COMMIT;
        END LOOP;

        v_accion := 'el proceso completó correctamente.';
        pin_mensaje := v_accion;
    EXCEPTION
        WHEN OTHERS THEN
            raise_application_error(pkg_exceptionuser.error_inesperado, 'No se pudo envíar a cuentas corrientes debido a '
                                                                        || sqlcode
                                                                        || ' -ERROR- '
                                                                        || sqlerrm);
    END enviar_ctas_ctes_from_prov103;

    PROCEDURE delprov113 (
        pin_id_cia    IN NUMBER,
        pin_libro     IN VARCHAR2,
        pin_periodo   IN NUMBER,
        pin_mes       IN NUMBER,
        pin_secuencia IN NUMBER,
        pin_mensaje   OUT VARCHAR2
    ) AS
        v_accion VARCHAR(50) := 'el proceso ';
    BEGIN
        DELETE FROM prov113
        WHERE
            ( id_cia = pin_id_cia )
            AND NOT ( libro = 'hoa' )
            AND libro = pin_libro
            AND periodo = pin_periodo
            AND mes = pin_mes
            AND secuencia = pin_secuencia;

        COMMIT;
        v_accion := 'el proceso completó correctamente.';
        pin_mensaje := v_accion;
    EXCEPTION
        WHEN OTHERS THEN
            raise_application_error(pkg_exceptionuser.error_inesperado, 'No se pudo eliminar el Registro de Prov101 debido a : '
                                                                        || sqlcode
                                                                        || ' -ERROR- '
                                                                        || sqlerrm);
    END delprov113;

    PROCEDURE enviar_ctas_ctes_from_prov113 (
        pin_id_cia    IN NUMBER,
        pin_libro     IN VARCHAR2,
        pin_periodo   IN NUMBER,
        pin_mes       IN NUMBER,
        pin_secuencia IN NUMBER,
        pin_usuari    IN VARCHAR2,
        pin_mensaje   OUT VARCHAR2
    ) AS

        v_accion VARCHAR(50) := 'el proceso ';
        v_numite NUMBER := 0;
        CURSOR cur_select IS
        SELECT
            p.tipo,
            p.docu,
            p.libro,
            p.periodo,
            p.mes,
            p.secuencia,
            p.item,
            p.tipcan,
            p.doccan,
            p.refere01,
            p.refere02,
            c.codcob,
            p.cuenta,
            p.dh,
            p.tipmon,
            p.amorti,
            p.impor01,
            p.impor02,
            p.tcamb01,
            p.tcamb02,
            p.impor01 * cr.porcom AS comision,
            c.codsuc,
            c.femisi
        FROM
            prov113  p
            LEFT OUTER JOIN prov102  c ON c.id_cia = pin_id_cia
                                         AND c.libro = p.libro
                                         AND c.periodo = p.periodo
                                         AND c.mes = p.mes
                                         AND c.secuencia = p.secuencia
            LEFT OUTER JOIN cobrador cr ON cr.id_cia = pin_id_cia
                                           AND cr.codcob = c.codcob
        WHERE
            ( p.id_cia = pin_id_cia )
            AND ( p.libro = pin_libro )
            AND ( p.periodo = pin_periodo )
            AND ( p.mes = pin_mes )
            AND ( p.secuencia = pin_secuencia )
            AND NOT ( p.situac = 'J ' );

    BEGIN
        FOR reg IN cur_select LOOP
            BEGIN
                SELECT
                    trunc((MAX(nvl(numite, 0)) / 1))
                INTO v_numite
                FROM
                    prov101
                WHERE
                        id_cia = pin_id_cia
                    AND tipo = reg.tipo
                    AND docu = reg.docu;

            EXCEPTION
                WHEN no_data_found THEN
                    v_numite := NULL;
            END;

            IF ( v_numite IS NULL ) THEN
                v_numite := 0;
            END IF;
            v_numite := v_numite + 1;
            INSERT INTO prov101 (
                id_cia,
                tipo,
                docu,
                numite,
                fproce,
                libro,
                periodo,
                mes,
                secuencia,
                item,
                tipcan,
                doccan,
                refere01,
                refere02,
                codcob,
                cuenta,
                dh,
                tipmon,
                importe,
                impor01,
                impor02,
                tcamb01,
                tcamb02,
                comisi,
                codsuc,
                fcreac,
                factua,
                usuari,
                situac,
                femisi
            ) VALUES (
                pin_id_cia,
                reg.tipo,
                reg.docu,
                v_numite,
                current_date,
                reg.libro,
                reg.periodo,
                reg.mes,
                reg.secuencia,
                reg.item,
                reg.tipcan,
                reg.doccan,
                reg.refere01,
                reg.refere02,
                reg.codcob,
                reg.cuenta,
                reg.dh,
                reg.tipmon,
                reg.amorti,
                reg.impor01,
                reg.impor02,
                reg.tcamb01,
                reg.tcamb02,
                reg.comision,
                reg.codsuc,
                current_timestamp,
                current_timestamp,
                pin_usuari,
                'A',
                reg.femisi
            );

            COMMIT;
            sp_actualiza_saldo_prov100(pin_id_cia, reg.tipo, reg.docu);
            COMMIT;
        END LOOP;

        COMMIT;
        v_accion := 'el proceso completó correctamente.';
        pin_mensaje := v_accion;
    EXCEPTION
        WHEN OTHERS THEN
            raise_application_error(pkg_exceptionuser.error_inesperado, 'No se pudo envíar a cuentas corrientes debido a '
                                                                        || sqlcode
                                                                        || ' -ERROR- '
                                                                        || sqlerrm);
    END enviar_ctas_ctes_from_prov113;

END pack_prov101;

/

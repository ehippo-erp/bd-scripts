--------------------------------------------------------
--  DDL for Package Body PACK_ASIENHEA
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_ASIENHEA" AS

    PROCEDURE delasienhea (
        pin_id_cia            IN   NUMBER,
        pin_periodo           IN   NUMBER,
        pin_mes               IN   NUMBER,
        pin_libro             IN   VARCHAR2,
        pin_asiento           IN   NUMBER,
        pin_eliminarasienhea  IN   VARCHAR2,
        pin_mensaje           OUT  VARCHAR2
    ) AS
    BEGIN
        IF pin_eliminarasienhea = 'S' THEN
            DELETE FROM asienhea
            WHERE
                ( id_cia = pin_id_cia )
                AND periodo = pin_periodo
                AND mes = pin_mes
                AND libro = pin_libro
                AND asiento = pin_asiento;

        END IF;

        DELETE FROM asiendet
        WHERE
            ( id_cia = pin_id_cia )
            AND periodo = pin_periodo
            AND mes = pin_mes
            AND libro = pin_libro
            AND asiento = pin_asiento;

        DELETE FROM movimientos
        WHERE
            ( id_cia = pin_id_cia )
            AND periodo = pin_periodo
            AND mes = pin_mes
            AND libro = pin_libro
            AND asiento = pin_asiento;

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            raise_application_error(pkg_exceptionuser.error_inesperado, 'No se pudo eliminar asiento debido a : '
                                                                        || sqlcode
                                                                        || ' -ERROR- '
                                                                        || sqlerrm);
    END delasienhea;

    PROCEDURE borracontabilidad (
        pin_id_cia   IN   NUMBER,
        pin_periodo  IN   NUMBER,
        pin_mes      IN   NUMBER,
        pin_libro    IN   VARCHAR2,
        pin_asiento  IN   NUMBER,
        pin_mensaje  OUT  VARCHAR2
    ) AS
    BEGIN
        DELETE FROM movimientos
        WHERE
            ( id_cia = pin_id_cia )
            AND periodo = pin_periodo
            AND mes = pin_mes
            AND libro = pin_libro
            AND asiento = pin_asiento;

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            raise_application_error(pkg_exceptionuser.error_inesperado, 'Error al eliminar los movimientos debido a : '
                                                                        || sqlcode
                                                                        || ' -ERROR- '
                                                                        || sqlerrm);
    END borracontabilidad;

    PROCEDURE sp_save_asienhea (
        pin_id_cia   IN   NUMBER,
        pin_datos    IN   VARCHAR2,
        pin_opcdml   IN   NUMBER,
        pin_mensaje  OUT  VARCHAR2
    ) AS
        o             json_object_t;
        rec_asienhea  asienhea%rowtype;
        v_accion      VARCHAR2(50) := '';
    BEGIN
    -- TAREA: Se necesita implantación para PROCEDURE PACK_ASIENHEA.sp_save_ASIENHEA
        o := json_object_t.parse(pin_datos);
        rec_asienhea.id_cia := pin_id_cia;
        rec_asienhea.periodo := o.get_number('periodo');
        rec_asienhea.mes := o.get_number('mes');
        rec_asienhea.libro := o.get_string('libro');
        rec_asienhea.asiento := o.get_number('asiento');
        rec_asienhea.concep := o.get_string('concep');
        rec_asienhea.codigo := o.get_string('codigo');
        rec_asienhea.nombre := o.get_string('nombre');
        rec_asienhea.motivo := o.get_string('motivo');
        rec_asienhea.tasien := o.get_number('tasien');
        rec_asienhea.moneda := o.get_string('moneda');
        rec_asienhea.fecha := o.get_date('fecha');
        rec_asienhea.tcamb01 := o.get_number('tcamb01');
        rec_asienhea.tcamb02 := o.get_number('tcamb02');
        rec_asienhea.ncontab := o.get_number('ncontab');
        rec_asienhea.situac := o.get_number('situac');
        rec_asienhea.usuari := o.get_string('usuari');
        rec_asienhea.usrlck := o.get_string('usrlck');
        rec_asienhea.codban := o.get_string('codban');
        rec_asienhea.referencia := o.get_string('referencia');
        rec_asienhea.girara := o.get_string('girara');
        rec_asienhea.serret := o.get_string('serret');
        rec_asienhea.numret := o.get_number('numret');
        rec_asienhea.ucreac := o.get_string('ucreac');
        CASE pin_opcdml
            WHEN 1 THEN
                INSERT INTO asienhea (
                    id_cia,
                    periodo,
                    mes,
                    libro,
                    asiento,
                    concep,
                    codigo,
                    nombre,
                    motivo,
                    tasien,
                    moneda,
                    fecha,
                    tcamb01,
                    tcamb02,
                    ncontab,
                    situac,
                    usuari,
                    fcreac,
                    factua,
                    usrlck,
                    codban,
                    referencia,
                    girara,
                    serret,
                    numret,
                    ucreac
                ) VALUES (
                    rec_asienhea.id_cia,
                    rec_asienhea.periodo,
                    rec_asienhea.mes,
                    rec_asienhea.libro,
                    rec_asienhea.asiento,
                    rec_asienhea.concep,
                    rec_asienhea.codigo,
                    rec_asienhea.nombre,
                    rec_asienhea.motivo,
                    rec_asienhea.tasien,
                    rec_asienhea.moneda,
                    rec_asienhea.fecha,
                    rec_asienhea.tcamb01,
                    rec_asienhea.tcamb02,
                    rec_asienhea.ncontab,
                    rec_asienhea.situac,
                    rec_asienhea.usuari,
                    current_timestamp,
                    current_timestamp,
                    rec_asienhea.usrlck,
                    rec_asienhea.codban,
                    rec_asienhea.referencia,
                    rec_asienhea.girara,
                    rec_asienhea.serret,
                    rec_asienhea.numret,
                    rec_asienhea.ucreac
                );

                COMMIT;
            WHEN 2 THEN
                UPDATE asienhea
                SET
                    id_cia = rec_asienhea.id_cia,
                    periodo = rec_asienhea.periodo,
                    mes = rec_asienhea.mes,
                    libro = rec_asienhea.libro,
                    asiento = rec_asienhea.asiento,
                    concep = rec_asienhea.concep,
                    codigo = rec_asienhea.codigo,
                    nombre = rec_asienhea.nombre,
                    motivo = rec_asienhea.motivo,
                    tasien = rec_asienhea.tasien,
                    moneda = rec_asienhea.moneda,
                    fecha = rec_asienhea.fecha,
                    tcamb01 = rec_asienhea.tcamb01,
                    tcamb02 = rec_asienhea.tcamb02,
                    ncontab = rec_asienhea.ncontab,
                    situac = rec_asienhea.situac,
                    usuari = rec_asienhea.usuari,
                    factua = current_timestamp,
                    usrlck = rec_asienhea.usrlck,
                    codban = rec_asienhea.codban,
                    referencia = rec_asienhea.referencia,
                    girara = rec_asienhea.girara,
                    serret = rec_asienhea.serret,
                    numret = rec_asienhea.numret,
                    ucreac = rec_asienhea.ucreac
                WHERE
                        id_cia = rec_asienhea.id_cia
                    AND periodo = rec_asienhea.periodo
                    AND mes = rec_asienhea.mes
                    AND libro = rec_asienhea.libro
                    AND asiento = rec_asienhea.asiento;

                COMMIT;
            WHEN 3 THEN
                DELETE FROM asienhea
                WHERE
                        id_cia = rec_asienhea.id_cia
                    AND periodo = rec_asienhea.periodo
                    AND mes = rec_asienhea.mes
                    AND libro = rec_asienhea.libro
                    AND asiento = rec_asienhea.asiento;

                COMMIT;
            ELSE
                NULL;
        END CASE;

        pin_mensaje := v_accion || ' se realizó satisfactoriamente';
    END sp_save_asienhea;

END pack_asienhea;

/

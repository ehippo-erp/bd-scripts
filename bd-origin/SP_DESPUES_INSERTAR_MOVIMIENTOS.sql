--------------------------------------------------------
--  DDL for Procedure SP_DESPUES_INSERTAR_MOVIMIENTOS
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_DESPUES_INSERTAR_MOVIMIENTOS" (
    pin_id_cia   IN   NUMBER,
    pin_datos    IN   VARCHAR2,
    pin_mensaje  OUT  VARCHAR2
) AS

    wccosto         VARCHAR(16);
    wcuenta         VARCHAR(16);
    wdestind        VARCHAR(16);
    wdestinh        VARCHAR(16);
    swdestino       VARCHAR(1);
    swccosto        VARCHAR(1);
    wsitem          INTEGER;
    wfecing         TIMESTAMP;
    wfecsal         TIMESTAMP;
    wnogendes       VARCHAR(1);
    v_item          NUMBER;
    o               json_object_t;
    rec_movimiento  movimientos%rowtype;
    v_accion        VARCHAR2(50) := 'el proceso';
BEGIN
    o := json_object_t.parse(pin_datos);
    rec_movimiento.id_cia := pin_id_cia;
    rec_movimiento.periodo := o.get_number('periodo');
    rec_movimiento.mes := o.get_number('mes');
    rec_movimiento.libro := o.get_string('libro');
    rec_movimiento.asiento := o.get_number('asiento');
    rec_movimiento.item := o.get_number('item');
    rec_movimiento.sitem := o.get_number('sitem');
    rec_movimiento.concep := o.get_string('concep');
    rec_movimiento.fecha := o.get_date('fecha');
    rec_movimiento.tasien := o.get_number('tasien');
    rec_movimiento.topera := o.get_string('topera');
    rec_movimiento.cuenta := o.get_string('cuenta');
    rec_movimiento.dh := o.get_string('dh');
    rec_movimiento.moneda := o.get_string('moneda');
    rec_movimiento.importe := o.get_number('importe');
    rec_movimiento.impor01 := o.get_number('impor01');
    rec_movimiento.impor02 := o.get_number('impor02');
    rec_movimiento.debe := o.get_number('debe');
    rec_movimiento.debe01 := o.get_number('debe01');
    rec_movimiento.debe02 := o.get_number('debe02');
    rec_movimiento.haber := o.get_number('haber');
    rec_movimiento.haber01 := o.get_number('haber01');
    rec_movimiento.haber02 := o.get_number('haber02');
    rec_movimiento.tcambio01 := o.get_number('tcambio01');
    rec_movimiento.tcambio02 := o.get_number('tcambio02');
    rec_movimiento.ccosto := o.get_string('ccosto');
    rec_movimiento.proyec := o.get_string('proyec');
    rec_movimiento.subcco := o.get_string('subcco');
    rec_movimiento.tipo := o.get_number('tipo');
    rec_movimiento.docume := o.get_number('docume');
    rec_movimiento.codigo := o.get_string('codigo');
    rec_movimiento.razon := o.get_string('razon');
    rec_movimiento.tident := o.get_string('tident');
    rec_movimiento.dident := o.get_string('dident');
    rec_movimiento.tdocum := o.get_string('tdocum');
    rec_movimiento.serie := o.get_string('serie');
    rec_movimiento.numero := o.get_string('numero');
    rec_movimiento.fdocum := o.get_date('fdocum');
    rec_movimiento.usuari := o.get_string('usuari');
    rec_movimiento.fcreac := o.get_date('fcreac');
    rec_movimiento.factua := o.get_date('factua');
    rec_movimiento.regcomcol := o.get_number('regcomcol');
    rec_movimiento.swprovicion := o.get_string('swprovicion');
    rec_movimiento.saldo := o.get_number('saldo');
    rec_movimiento.swgasoper := o.get_number('swgasoper');
    rec_movimiento.codporret := o.get_string('codporret');
    rec_movimiento.swchkconcilia := o.get_string('swchkconcilia');
    rec_movimiento.ctaalternativa := o.get_string('ctaalternativa'); 


  /* 2014-06-30 - cambios realizados a raiz de cnabila..
                  nos quedamos con carlos en el comedor y los 2 realizamos estas modificaciones
                  las cuales agregan ccostos con la cuenta destino debe
  */
    wnogendes := 'N';
  /*muy lento no poner ->
    execute procedure sp000_actualiza_saldos_tanalitica(new.periodo,new.cuenta,new.codigo,new.tdocum,new.serie,new.numero);  */
  /*clase 2- cuando contabiliza no genera destinos s/n */

  --for  do begin wnogendes=wnogendes; end
    BEGIN
        SELECT
            vstrg
        INTO wnogendes
        FROM
            tlibros_clase
        WHERE
                id_cia = pin_id_cia
            AND codlib = rec_movimiento.libro
            AND clase = 2;

    EXCEPTION
        WHEN no_data_found THEN
            wnogendes := NULL;
    END;

    IF ( ( wnogendes IS NULL ) OR ( upper(wnogendes) <> 'S' ) ) THEN


          /* saca cuenta=codigo y  la cuenta destino de la tabla tccosto */
        IF
            ( rec_movimiento.ccosto IS NOT NULL ) AND ( rec_movimiento.ccosto <> '' )
        THEN
            BEGIN
                SELECT
                    codigo,
                    destin
                INTO
                    wccosto,
                    wcuenta
                FROM
                    tccostos
                WHERE
                        id_cia = pin_id_cia
                    AND codigo = rec_movimiento.ccosto;

            EXCEPTION
                WHEN no_data_found THEN
                    wccosto := NULL;
                    wcuenta := NULL;
            END;

            IF ( wccosto IS NULL ) THEN
                RAISE pkg_exceptionuser.ex_codigo_no_existe_tccostos;
            END IF;
            IF ( wcuenta IS NULL ) THEN
                RAISE pkg_exceptionuser.ex_destin_no_existe_tccostos;
            END IF;
        END IF;

          /* saca las cuentas destino (dh) del plan de cuentas */

        BEGIN
            SELECT
                destino,
                ccosto,
                destid,
                destih
            INTO
                swdestino,
                swccosto,
                wdestind,
                wdestinh
            FROM
                pcuentas
            WHERE
                    id_cia = pin_id_cia
                AND cuenta = rec_movimiento.cuenta;

        EXCEPTION
            WHEN no_data_found THEN
                swdestino := NULL;
                swccosto := NULL;
                wdestind := NULL;
                wdestinh := NULL;
        END;

        IF (
            ( swdestino = 'S' ) AND ( ( wdestind IS NULL ) OR ( wdestinh IS NULL ) )
        ) THEN
            RAISE pkg_exceptionuser.ex_destin_no_existe_pcuentas;
        END IF;
          /* saca el ultimo sitem de movimiento para auto incrementar */

        BEGIN
            SELECT
                MAX(sitem)
            INTO wsitem
            FROM
                movimientos
            WHERE
                    id_cia = pin_id_cia
                AND periodo = rec_movimiento.periodo
                AND mes = rec_movimiento.mes
                AND libro = rec_movimiento.libro
                AND asiento = rec_movimiento.asiento
                AND item = rec_movimiento.item;

        EXCEPTION
            WHEN no_data_found THEN
                wsitem := 0;
        END;

        IF (
            ( swccosto IS NOT NULL ) AND ( upper(swccosto) = 'S' )
        ) THEN

                      /* auto incrementa wsitem */
            wsitem := wsitem + 1;
                      /* adiciona registro automatico */
                      -- 2021-06-02 comentado porque genera un bucle infinito proabdo por oscar rojas
            INSERT INTO movimientos (
                id_cia,
                periodo,
                mes,
                libro,
                asiento,
                item,
                sitem,
                concep,
                fecha,
                cuenta,
                dh,
                moneda,
                importe,
                impor01,
                impor02,
                debe,
                debe01,
                debe02,
                haber,
                haber01,
                haber02,
                tcambio01,
                tcambio02
            ) VALUES (
                pin_id_cia,
                rec_movimiento.periodo,
                rec_movimiento.mes,
                rec_movimiento.libro,
                rec_movimiento.asiento,
                rec_movimiento.item,
                wsitem,
                rec_movimiento.concep,
                rec_movimiento.fecha,
                wccosto,
                rec_movimiento.dh,
                rec_movimiento.moneda,
                rec_movimiento.importe,
                rec_movimiento.impor01,
                rec_movimiento.impor02,
                rec_movimiento.debe,
                rec_movimiento.debe01,
                rec_movimiento.debe02,
                rec_movimiento.haber,
                rec_movimiento.haber01,
                rec_movimiento.haber02,
                rec_movimiento.tcambio01,
                rec_movimiento.tcambio02
            );

            COMMIT;
                       /* si tiene cuenta destino del centro de costo genera asiento automatico */
            IF (
                ( wcuenta IS NOT NULL ) AND ( length(wcuenta) > 3 )
            ) THEN   


                                    /* auto incrementa wsitem */
                wsitem := wsitem + 1;

                                    /* genera la inversa del dh */
                IF ( rec_movimiento.dh = 'D' ) THEN
                    rec_movimiento.dh := 'H';
                    rec_movimiento.haber := rec_movimiento.importe;
                    rec_movimiento.haber01 := rec_movimiento.impor01;
                    rec_movimiento.haber02 := rec_movimiento.impor02;
                    rec_movimiento.debe := 0;
                    rec_movimiento.debe01 := 0;
                    rec_movimiento.debe02 := 0;
                ELSE
                    rec_movimiento.dh := 'D';
                    rec_movimiento.haber := 0;
                    rec_movimiento.haber01 := 0;
                    rec_movimiento.haber02 := 0;
                    rec_movimiento.debe := rec_movimiento.importe;
                    rec_movimiento.debe01 := rec_movimiento.impor01;
                    rec_movimiento.debe02 := rec_movimiento.impor02;
                END IF;

                                     /* adiciona registro automatico */

                INSERT INTO movimientos (
                    id_cia,
                    periodo,
                    mes,
                    libro,
                    asiento,
                    item,
                    sitem,
                    concep,
                    fecha,
                    cuenta,
                    dh,
                    moneda,
                    importe,
                    impor01,
                    impor02,
                    debe,
                    debe01,
                    debe02,
                    haber,
                    haber01,
                    haber02,
                    tcambio01,
                    tcambio02
                ) VALUES (
                    pin_id_cia,
                    rec_movimiento.periodo,
                    rec_movimiento.mes,
                    rec_movimiento.libro,
                    rec_movimiento.asiento,
                    rec_movimiento.item,
                    wsitem,
                    rec_movimiento.concep,
                    rec_movimiento.fecha,
                    wcuenta,
                    rec_movimiento.dh,
                    rec_movimiento.moneda,
                    rec_movimiento.importe,
                    rec_movimiento.impor01,
                    rec_movimiento.impor02,
                    rec_movimiento.debe,
                    rec_movimiento.debe01,
                    rec_movimiento.debe02,
                    rec_movimiento.haber,
                    rec_movimiento.haber01,
                    rec_movimiento.haber02,
                    rec_movimiento.tcambio01,
                    rec_movimiento.tcambio02
                );

                COMMIT;
            END IF;

        END IF;

        IF (
            ( swdestino IS NOT NULL ) AND ( upper(swdestino) = 'S' )
        ) THEN

                 -- pendiente en implemenacion
                 /* si tiente cuenta destinod genera  asiento automatico */
            IF (
                ( wdestind IS NOT NULL ) AND ( length(wdestind) > 3 )
            ) THEN
                wsitem := wsitem + 1;

                          /* adiciona registro automatico */
                INSERT INTO movimientos (
                    id_cia,
                    periodo,
                    mes,
                    libro,
                    asiento,
                    item,
                    sitem,
                    concep,
                    fecha,
                    cuenta,
                    dh,
                    moneda,
                    importe,
                    impor01,
                    impor02,
                    debe,
                    debe01,
                    debe02,
                    haber,
                    haber01,
                    haber02,
                    tcambio01,
                    tcambio02
                ) VALUES (
                    pin_id_cia,
                    rec_movimiento.periodo,
                    rec_movimiento.mes,
                    rec_movimiento.libro,
                    rec_movimiento.asiento,
                    rec_movimiento.item,
                    wsitem,
                    rec_movimiento.concep,
                    rec_movimiento.fecha,
                    wdestind,
                    rec_movimiento.dh,
                    rec_movimiento.moneda,
                    rec_movimiento.importe,
                    rec_movimiento.impor01,
                    rec_movimiento.impor02,
                    rec_movimiento.debe,
                    rec_movimiento.debe01,
                    rec_movimiento.debe02,
                    rec_movimiento.haber,
                    rec_movimiento.haber01,
                    rec_movimiento.haber02,
                    rec_movimiento.tcambio01,
                    rec_movimiento.tcambio02
                );

                COMMIT;
            END IF;


                  /* si tiene cuenta destinoh  genera asiento automatico */

            IF (
                ( wdestinh IS NOT NULL ) AND ( length(wdestinh) > 3 )
            ) THEN

                     /* auto incrementa wsitem */
                wsitem := wsitem + 1;

                      /* genera la inversa del dh */
                IF ( rec_movimiento.dh = 'D' ) THEN
                    rec_movimiento.dh := 'H';
                    rec_movimiento.haber := rec_movimiento.importe;
                    rec_movimiento.haber01 := rec_movimiento.impor01;
                    rec_movimiento.haber02 := rec_movimiento.impor02;
                    rec_movimiento.debe := 0;
                    rec_movimiento.debe01 := 0;
                    rec_movimiento.debe02 := 0;
                ELSE
                    rec_movimiento.dh := 'D';
                    rec_movimiento.haber := 0;
                    rec_movimiento.haber01 := 0;
                    rec_movimiento.haber02 := 0;
                    rec_movimiento.debe := rec_movimiento.importe;
                    rec_movimiento.debe01 := rec_movimiento.impor01;
                    rec_movimiento.debe02 := rec_movimiento.impor02;
                END IF;

                      /* adiciona registro automatico */

                INSERT INTO movimientos (
                    id_cia,
                    periodo,
                    mes,
                    libro,
                    asiento,
                    item,
                    sitem,
                    concep,
                    fecha,
                    cuenta,
                    dh,
                    moneda,
                    importe,
                    impor01,
                    impor02,
                    debe,
                    debe01,
                    debe02,
                    haber,
                    haber01,
                    haber02,
                    tcambio01,
                    tcambio02
                ) VALUES (
                    pin_id_cia,
                    rec_movimiento.periodo,
                    rec_movimiento.mes,
                    rec_movimiento.libro,
                    rec_movimiento.asiento,
                    rec_movimiento.item,
                    wsitem,
                    rec_movimiento.concep,
                    rec_movimiento.fecha,
                    wdestinh,
                    rec_movimiento.dh,
                    rec_movimiento.moneda,
                    rec_movimiento.importe,
                    rec_movimiento.impor01,
                    rec_movimiento.impor02,
                    rec_movimiento.debe,
                    rec_movimiento.debe01,
                    rec_movimiento.debe02,
                    rec_movimiento.haber,
                    rec_movimiento.haber01,
                    rec_movimiento.haber02,
                    rec_movimiento.tcambio01,
                    rec_movimiento.tcambio02
                );

                COMMIT;
            END IF;

        END IF;

        IF rec_movimiento.sitem IS NULL THEN
            rec_movimiento.sitem := 0;
        END IF;
        BEGIN
            SELECT
                b2.periodo
            INTO v_item
            FROM
                bancos002 b2
            WHERE
                    b2.id_cia = pin_id_cia
                AND b2.periodo = rec_movimiento.periodo
                AND b2.mes = rec_movimiento.mes
                AND b2.libro = rec_movimiento.libro
                AND b2.asiento = rec_movimiento.asiento
                AND b2.item = rec_movimiento.item
                AND b2.sitem = rec_movimiento.sitem;

        EXCEPTION
            WHEN no_data_found THEN
                v_item := NULL;
        END;

        IF ( v_item IS NOT NULL ) THEN
            UPDATE bancos002
            SET
                periodo = rec_movimiento.periodo,
                mes = rec_movimiento.mes,
                libro = rec_movimiento.libro,
                asiento = rec_movimiento.asiento,
                item = rec_movimiento.item,
                sitem = rec_movimiento.sitem,
                usuari = rec_movimiento.usuari
            WHERE
                    id_cia = pin_id_cia
                AND periodo = rec_movimiento.periodo
                AND mes = rec_movimiento.mes
                AND libro = rec_movimiento.libro
                AND asiento = rec_movimiento.asiento
                AND item = rec_movimiento.item
                AND sitem = rec_movimiento.sitem;

            COMMIT;
        ELSE
            INSERT INTO bancos002 (
                id_cia,
                periodo,
                mes,
                libro,
                asiento,
                item,
                sitem,
                usuari
            ) VALUES (
                pin_id_cia,
                rec_movimiento.periodo,
                rec_movimiento.mes,
                rec_movimiento.libro,
                rec_movimiento.asiento,
                rec_movimiento.item,
                rec_movimiento.sitem,
                rec_movimiento.usuari
            );

            COMMIT;
        END IF;

    END IF;

    v_accion := 'el proceso completó correctamente.';
EXCEPTION
    WHEN pkg_exceptionuser.ex_codigo_no_existe_tccostos THEN
        raise_application_error(pkg_exceptionuser.codigo_no_existe_tccostos, 'Centro de costo ('
                                                                             || rec_movimiento.ccosto
                                                                             || ') no existe');
    WHEN pkg_exceptionuser.ex_destin_no_existe_tccostos THEN
        raise_application_error(pkg_exceptionuser.destin_no_existe_tccostos, 'Destino de centro de costo ('
                                                                             || rec_movimiento.ccosto
                                                                             || ') no existe');
    WHEN pkg_exceptionuser.ex_destin_no_existe_pcuentas THEN
        raise_application_error(pkg_exceptionuser.destin_no_existe_pcuentas, 'Cuenta ('
                                                                             || rec_movimiento.cuenta
                                                                             || ') no tine cuentas destino (dh) del plan de cuentas');
END sp_despues_insertar_movimientos;

/

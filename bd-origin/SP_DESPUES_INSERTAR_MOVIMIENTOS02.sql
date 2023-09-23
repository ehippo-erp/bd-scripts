--------------------------------------------------------
--  DDL for Procedure SP_DESPUES_INSERTAR_MOVIMIENTOS02
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_DESPUES_INSERTAR_MOVIMIENTOS02" (
    pin_id_cia     IN   NUMBER,
    pin_libro      IN   VARCHAR2,
    pin_periodo    IN   NUMBER,
    pin_mes        IN   NUMBER,
    pin_secuencia  IN   NUMBER,
    pin_usuario    IN   VARCHAR2,
    pin_mensaje    OUT  VARCHAR2
) AS

    CURSOR cur_asiendet IS
    SELECT
        id_cia,
        periodo,
        mes,
        libro,
        asiento,
        item,
        sitem,
        concep,
        fecha,
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
        tcambio02,
        ccosto,
        cuenta
    FROM
        asiendet
    WHERE
            id_cia = pin_id_cia
        AND libro = pin_libro
        AND periodo = pin_periodo
        AND mes = pin_mes
        AND asiento = pin_secuencia;

    v_ccosto          VARCHAR(16);
    v_codctacco       VARCHAR(16) := '';
    v_destincco       VARCHAR(16) := '';
    v_cuenta          VARCHAR(16) := '';
    v_destindpcuenta  VARCHAR(16) := '';
    v_destinhpcuenta  VARCHAR(16) := '';
    v_cuentaerr       VARCHAR(16) := '';
    wdestind          VARCHAR(16);
    wdestinh          VARCHAR(16);
    swdestino         VARCHAR(1);
    swccosto          VARCHAR(1);
    wsitem            INTEGER;
    wfecing           TIMESTAMP;
    wfecsal           TIMESTAMP;
    wnogendes         VARCHAR(1);
    v_item            NUMBER;
    v_accion          VARCHAR2(50) := 'el proceso';
BEGIN
    FOR r_asiendet IN cur_asiendet LOOP
        v_ccosto := r_asiendet.ccosto;
        v_cuentaerr := r_asiendet.cuenta;
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
                AND codlib = r_asiendet.libro
                AND clase = 2;

        EXCEPTION
            WHEN no_data_found THEN
                wnogendes := NULL;
        END;

        IF ( ( wnogendes IS NULL ) OR ( upper(trim(wnogendes)) <> 'S' ) ) THEN


          /* saca cuenta=codigo y  la cuenta destino de la tabla tccosto */
            IF
                ( r_asiendet.ccosto IS NOT NULL ) AND ( trim(r_asiendet.ccosto) <> '' )
            THEN
                BEGIN
                    SELECT
                        TRIM(codigo),
                        TRIM(destin)
                    INTO
                        v_codctacco,
                        v_destincco
                    FROM
                        tccostos
                    WHERE
                            id_cia = pin_id_cia
                        AND codigo = r_asiendet.ccosto;

                EXCEPTION
                    WHEN no_data_found THEN
                        v_codctacco := NULL;
                        v_destincco := NULL;
                END;

                IF ( v_codctacco IS NULL ) THEN
                    RAISE pkg_exceptionuser.ex_codigo_no_existe_tccostos;
                END IF;
                IF (
                    ( v_codctacco IS NOT NULL ) AND ( v_destincco IS NULL )
                ) THEN
                    RAISE pkg_exceptionuser.ex_destin_no_existe_tccostos;
                END IF;

            END IF;

          /* saca las cuentas destino (dh) del plan de cuentas */

            BEGIN
                SELECT
                    TRIM(cuenta),
                    TRIM(destino),
                    TRIM(ccosto),
                    TRIM(destid),
                    TRIM(destih)
                INTO
                    v_cuenta,
                    swdestino,
                    swccosto,
                    v_destindpcuenta,
                    v_destinhpcuenta
                FROM
                    pcuentas
                WHERE
                        id_cia = pin_id_cia
                    AND cuenta = r_asiendet.cuenta;

            EXCEPTION
                WHEN no_data_found THEN
                    v_cuenta := NULL;
                    swdestino := NULL;
                    swccosto := NULL;
                    v_destindpcuenta := NULL;
                    v_destinhpcuenta := NULL;
            END;

            IF ( v_cuenta IS NULL ) THEN
                RAISE pkg_exceptionuser.ex_cuenta_en_blanco;
            END IF;
            IF (
                ( swdestino = 'S' ) AND ( ( v_destindpcuenta IS NULL ) OR ( v_destinhpcuenta IS NULL ) )
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
                    AND periodo = r_asiendet.periodo
                    AND mes = r_asiendet.mes
                    AND libro = r_asiendet.libro
                    AND asiento = r_asiendet.asiento
                    AND item = r_asiendet.item;

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
                    r_asiendet.periodo,
                    r_asiendet.mes,
                    r_asiendet.libro,
                    r_asiendet.asiento,
                    r_asiendet.item,
                    wsitem,
                    r_asiendet.concep,
                    r_asiendet.fecha,
                    v_codctacco,
                    r_asiendet.dh,
                    r_asiendet.moneda,
                    r_asiendet.importe,
                    r_asiendet.impor01,
                    r_asiendet.impor02,
                    r_asiendet.debe,
                    r_asiendet.debe01,
                    r_asiendet.debe02,
                    r_asiendet.haber,
                    r_asiendet.haber01,
                    r_asiendet.haber02,
                    r_asiendet.tcambio01,
                    r_asiendet.tcambio02
                );

                COMMIT;
                       /* si tiene cuenta destino del centro de costo genera asiento automatico */
                IF (
                    ( v_destincco IS NOT NULL ) AND ( length(v_destincco) > 3 )
                ) THEN   


                                    /* auto incrementa wsitem */
                    wsitem := wsitem + 1;

                                    /* genera la inversa del dh */
                    IF ( r_asiendet.dh = 'D' ) THEN
                        r_asiendet.dh := 'H';
                        r_asiendet.haber := r_asiendet.importe;
                        r_asiendet.haber01 := r_asiendet.impor01;
                        r_asiendet.haber02 := r_asiendet.impor02;
                        r_asiendet.debe := 0;
                        r_asiendet.debe01 := 0;
                        r_asiendet.debe02 := 0;
                    ELSE
                        r_asiendet.dh := 'D';
                        r_asiendet.haber := 0;
                        r_asiendet.haber01 := 0;
                        r_asiendet.haber02 := 0;
                        r_asiendet.debe := r_asiendet.importe;
                        r_asiendet.debe01 := r_asiendet.impor01;
                        r_asiendet.debe02 := r_asiendet.impor02;
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
                        r_asiendet.periodo,
                        r_asiendet.mes,
                        r_asiendet.libro,
                        r_asiendet.asiento,
                        r_asiendet.item,
                        wsitem,
                        r_asiendet.concep,
                        r_asiendet.fecha,
                        v_destincco,
                        r_asiendet.dh,
                        r_asiendet.moneda,
                        r_asiendet.importe,
                        r_asiendet.impor01,
                        r_asiendet.impor02,
                        r_asiendet.debe,
                        r_asiendet.debe01,
                        r_asiendet.debe02,
                        r_asiendet.haber,
                        r_asiendet.haber01,
                        r_asiendet.haber02,
                        r_asiendet.tcambio01,
                        r_asiendet.tcambio02
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
                    ( v_destindpcuenta IS NOT NULL ) AND ( length(v_destindpcuenta) > 3 )
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
                        r_asiendet.periodo,
                        r_asiendet.mes,
                        r_asiendet.libro,
                        r_asiendet.asiento,
                        r_asiendet.item,
                        wsitem,
                        r_asiendet.concep,
                        r_asiendet.fecha,
                        v_destindpcuenta,
                        r_asiendet.dh,
                        r_asiendet.moneda,
                        r_asiendet.importe,
                        r_asiendet.impor01,
                        r_asiendet.impor02,
                        r_asiendet.debe,
                        r_asiendet.debe01,
                        r_asiendet.debe02,
                        r_asiendet.haber,
                        r_asiendet.haber01,
                        r_asiendet.haber02,
                        r_asiendet.tcambio01,
                        r_asiendet.tcambio02
                    );

                    COMMIT;
                END IF;


                  /* si tiene cuenta destinoh  genera asiento automatico */

                IF (
                    ( v_destinhpcuenta IS NOT NULL ) AND ( length(v_destinhpcuenta) > 3 )
                ) THEN

                     /* auto incrementa wsitem */
                    wsitem := wsitem + 1;

                      /* genera la inversa del dh */
                    IF ( r_asiendet.dh = 'D' ) THEN
                        r_asiendet.dh := 'H';
                        r_asiendet.haber := r_asiendet.importe;
                        r_asiendet.haber01 := r_asiendet.impor01;
                        r_asiendet.haber02 := r_asiendet.impor02;
                        r_asiendet.debe := 0;
                        r_asiendet.debe01 := 0;
                        r_asiendet.debe02 := 0;
                    ELSE
                        r_asiendet.dh := 'D';
                        r_asiendet.haber := 0;
                        r_asiendet.haber01 := 0;
                        r_asiendet.haber02 := 0;
                        r_asiendet.debe := r_asiendet.importe;
                        r_asiendet.debe01 := r_asiendet.impor01;
                        r_asiendet.debe02 := r_asiendet.impor02;
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
                        r_asiendet.periodo,
                        r_asiendet.mes,
                        r_asiendet.libro,
                        r_asiendet.asiento,
                        r_asiendet.item,
                        wsitem,
                        r_asiendet.concep,
                        r_asiendet.fecha,
                        v_destinhpcuenta,
                        r_asiendet.dh,
                        r_asiendet.moneda,
                        r_asiendet.importe,
                        r_asiendet.impor01,
                        r_asiendet.impor02,
                        r_asiendet.debe,
                        r_asiendet.debe01,
                        r_asiendet.debe02,
                        r_asiendet.haber,
                        r_asiendet.haber01,
                        r_asiendet.haber02,
                        r_asiendet.tcambio01,
                        r_asiendet.tcambio02
                    );

                    COMMIT;
                END IF;

            END IF;

            IF r_asiendet.sitem IS NULL THEN
                r_asiendet.sitem := 0;
            END IF;
            BEGIN
                SELECT
                    b2.periodo
                INTO v_item
                FROM
                    bancos002 b2
                WHERE
                        b2.id_cia = pin_id_cia
                    AND b2.periodo = r_asiendet.periodo
                    AND b2.mes = r_asiendet.mes
                    AND b2.libro = r_asiendet.libro
                    AND b2.asiento = r_asiendet.asiento
                    AND b2.item = r_asiendet.item
                    AND b2.sitem = r_asiendet.sitem;

            EXCEPTION
                WHEN no_data_found THEN
                    v_item := NULL;
            END;

            IF ( v_item IS NOT NULL ) THEN
                UPDATE bancos002
                SET
                    periodo = r_asiendet.periodo,
                    mes = r_asiendet.mes,
                    libro = r_asiendet.libro,
                    asiento = r_asiendet.asiento,
                    item = r_asiendet.item,
                    sitem = r_asiendet.sitem,
                    usuari = pin_usuario
                WHERE
                        id_cia = pin_id_cia
                    AND periodo = r_asiendet.periodo
                    AND mes = r_asiendet.mes
                    AND libro = r_asiendet.libro
                    AND asiento = r_asiendet.asiento
                    AND item = r_asiendet.item
                    AND sitem = r_asiendet.sitem;

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
                    r_asiendet.periodo,
                    r_asiendet.mes,
                    r_asiendet.libro,
                    r_asiendet.asiento,
                    r_asiendet.item,
                    r_asiendet.sitem,
                    pin_usuario
                );

                COMMIT;
            END IF;

        END IF;

    END LOOP;

    v_accion := 'el proceso completó correctamente.';
EXCEPTION
    WHEN pkg_exceptionuser.ex_cuenta_en_blanco THEN
        raise_application_error(pkg_exceptionuser.cuenta_en_blanco, 'Cuenta ('
                                                                    || v_cuentaerr
                                                                    || ') no existe en el plan de cuentas');
    WHEN pkg_exceptionuser.ex_codigo_no_existe_tccostos THEN
        raise_application_error(pkg_exceptionuser.codigo_no_existe_tccostos, 'Centro de costo ('
                                                                             || v_ccosto
                                                                             || ') no existe');
    WHEN pkg_exceptionuser.ex_destin_no_existe_tccostos THEN
        raise_application_error(pkg_exceptionuser.destin_no_existe_tccostos, 'Cuenta Destino '
                                                                             || v_destincco
                                                                             || ' de centro de costo ('
                                                                             || v_ccosto
                                                                             || ') no existe');
    WHEN pkg_exceptionuser.ex_destin_no_existe_pcuentas THEN
        raise_application_error(pkg_exceptionuser.destin_no_existe_pcuentas, 'Cuenta ('
                                                                             || v_cuenta
                                                                             || ') no tine cuentas destino (dh) del plan de cuentas');
END sp_despues_insertar_movimientos02;

/

--------------------------------------------------------
--  DDL for Package Body PACK_GENERA_ASIENTOS_PVENTA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_GENERA_ASIENTOS_PVENTA" AS

    FUNCTION sp_sel_caja_cab (
        pid_cia  NUMBER,
        pfinicio IN DATE,
        pffinal  IN DATE
    ) RETURN tbl_cajacab
        PIPELINED
    AS
        registro cur_caja_cab%rowtype;
    BEGIN
        FOR i IN cur_caja_cab(pid_cia, pfinicio, pffinal) LOOP
            registro.numcaja := i.numcaja;
            registro.codsuc := i.codsuc;
            registro.periodo := i.periodo;
            registro.mes := i.mes;
            PIPE ROW ( registro );
        END LOOP;
    END sp_sel_caja_cab;

    FUNCTION sp_sel_compr010_tipo604 (
        pid_cia   NUMBER,
        pdoc_caja NUMBER,
        pcod_suc  INTEGER
    ) RETURN tbl_compr010_tipo604
        PIPELINED
    AS
        registro cur_compr010_tipo604%rowtype;
    BEGIN
        FOR i IN cur_compr010_tipo604(pid_cia, pdoc_caja, pcod_suc) LOOP
            registro.asiento := i.asiento;
            registro.moneda := i.moneda;
            registro.tipdoc := i.tipdoc;
            registro.desdoc := i.desdoc;
            registro.desmoneda := i.desmoneda;
            registro.sucursal := i.sucursal;
            registro.tdoctipdoc := i.tdoctipdoc;
            registro.tdocdh := i.tdocdh;
            registro.clascodigo := i.clascodigo;
            registro.codmpag := i.codmpag;
            registro.desmpag := i.desmpag;
            registro.mpagdh := i.mpagdh;
            registro.mpagdh2 := i.mpagdh2;
            registro.mpagccodban := i.mpagccodban;
            registro.desbanco := i.desbanco;
            registro.cuentacon := i.cuentacon;
            registro.cuentagastocaja := i.cuentagastocaja;
            PIPE ROW ( registro );
        END LOOP;
    END sp_sel_compr010_tipo604;

    FUNCTION valida_cajatienda (
        pin_id_cia IN NUMBER,
        pin_fini   IN DATE,
        pin_ffin   IN DATE
    ) RETURN tbl_warning
        PIPELINED
    AS

        r_caja             pack_genera_asientos_pventa.cur_caja_cab%rowtype;
        r_compr010_tipo604 cur_compr010_tipo604%rowtype;
        registro           rec_warning;
        v_f376             VARCHAR2(20) := '';
    BEGIN
	   /* valores retorno procede */
       /* procede -1 no continuar */
       /* procede  1 continua  */

	   /************************************************************/
       /*  factor 376 - Libro para asiento automático caja tienda  */
       /************************************************************/
        registro.procede := 1;
        BEGIN
            SELECT
                vstrg
            INTO v_f376
            FROM
                factor
            WHERE
                    id_cia = pin_id_cia
                AND codfac = 376;

        EXCEPTION
            WHEN no_data_found THEN
                v_f376 := '';
        END;

        IF ( v_f376 = '' ) THEN
            registro.procede := -1;
            registro.mensaje := 'El factor ' || '[ 376 - Libro para asiento automático caja tienda]. No existe o está  en blanco.';
            PIPE ROW ( registro );
        END IF;

        IF ( registro.procede = 1 ) THEN
            OPEN cur_caja_cab(pin_id_cia, pin_fini, pin_ffin);
            LOOP
                FETCH cur_caja_cab INTO r_caja;
                IF cur_caja_cab%notfound THEN
                    IF cur_caja_cab%rowcount = 0 THEN
                        registro.procede := -1;
                        registro.mensaje := 'No existen cajas cerradas para este periodo';
                        PIPE ROW ( registro );
                    END IF;

                    EXIT;
                END IF;

            END LOOP;

            CLOSE cur_caja_cab;
        END IF;

        IF ( registro.procede = 1 ) THEN
            FOR reg IN (
                SELECT
                    numcaja,
                    codsuc,
                    periodo,
                    mes
                FROM
                    TABLE ( sp_sel_caja_cab(pin_id_cia, pin_fini, pin_ffin) )
            ) LOOP
                OPEN cur_compr010_tipo604(pin_id_cia, reg.numcaja, reg.codsuc);
                LOOP
                    FETCH cur_compr010_tipo604 INTO r_compr010_tipo604;
                    IF cur_compr010_tipo604%notfound THEN
                        IF cur_compr010_tipo604%rowcount = 0 THEN
                            registro.procede := 1;
                            registro.mensaje := 'La caja 604 - '
                                                || reg.numcaja
                                                || ' no tiene detalles que procesar';
                            PIPE ROW ( registro );
                        END IF;

                        EXIT;
                    ELSE
                        IF ( ( r_compr010_tipo604.cuentacon IS NULL ) OR ( r_compr010_tipo604.cuentacon = '' ) ) THEN
                            registro.procede := 1;
                            registro.mensaje := 'El tipo de Documento '
                                                || r_compr010_tipo604.tipdoc
                                                || ' ( '
                                                || r_compr010_tipo604.desdoc
                                                || ' ) '
                                                || 'No tiene configurada la cuenta contable (CUENTACON) para el Medio de Pago '
                                                || r_compr010_tipo604.codmpag
                                                || ' ( '
                                                || r_compr010_tipo604.desmpag
                                                || ' ) '
                                                || 'la cual debe salir del banco '
                                                || r_compr010_tipo604.mpagccodban
                                                || ' ( '
                                                || r_compr010_tipo604.desbanco
                                                || ' ) '
                                                || 'según la moneda '
                                                || r_compr010_tipo604.moneda
                                                || ' ( '
                                                || r_compr010_tipo604.desmoneda
                                                || ' ) '
                                                || 'y la Sucursal '
                                                || reg.codsuc
                                                || ' ( '
                                                || r_compr010_tipo604.sucursal
                                                || ' ) '
                                                || 'se recomienda verificar las tablas TDocume_Clases, M_Pago_Config y/o TBancos ';

                            PIPE ROW ( registro );
                        END IF;

                        IF ( ( r_compr010_tipo604.cuentagastocaja IS NULL ) OR ( r_compr010_tipo604.cuentagastocaja = '' ) ) THEN
                            registro.procede := 1;
                            registro.mensaje := 'El tipo de Documento '
                                                || r_compr010_tipo604.tipdoc
                                                || ' ( '
                                                || r_compr010_tipo604.desdoc
                                                || ' ) '
                                                || 'No tiene configurada la cuenta contable para la moneda '
                                                || r_compr010_tipo604.moneda
                                                || ' ( '
                                                || r_compr010_tipo604.desmoneda
                                                || ' ) '
                                                || 'y la Sucursal '
                                                || reg.codsuc
                                                || ' ( '
                                                || r_compr010_tipo604.sucursal
                                                || ' ) '
                                                || 'se recomienda verificar la tabla TDocume_Caja ';

                            PIPE ROW ( registro );
                        END IF;

                    END IF;

                END LOOP;

                CLOSE cur_compr010_tipo604;
            END LOOP;
        END IF;

    END valida_cajatienda;

    PROCEDURE sp_genera_asiento_caja_tienda (
        pin_id_cia  IN NUMBER,
        pin_fini    IN DATE,
        pin_ffin    IN DATE,
        pin_coduser IN VARCHAR2
    ) AS

        CURSOR cur_compr010 (
            pnumcaja INTEGER
        ) IS
        SELECT
            c.concep,
            tb.cuentacon,
            c.dh,
            c.moneda,
            c.tcamb01,
            c.tcamb02,
            c.importe,
            c.impor01,
            c.impor02,
            tc01.codigo AS clascodigo,
            c.codpro,
            c.razon,
            c.femisi,
            c.situac,
            tdc.cuenta  AS cuentagastocaja
        FROM
            compr010       c
            LEFT OUTER JOIN tmoneda        mo ON mo.id_cia = c.id_cia
                                          AND mo.codmon = c.moneda
            LEFT OUTER JOIN tdocume_clases tc01 ON tc01.id_cia = c.id_cia
                                                   AND tc01.tipdoc = c.tdocum
                                                   AND tc01.clase = 1
            LEFT OUTER JOIN tdocume_caja   tdc ON tdc.id_cia = c.id_cia
                                                AND tdc.tipdoc = c.tdocum
                                                AND tdc.codsuc = 1
                                                AND tdc.moneda = c.moneda
            LEFT OUTER JOIN m_pago_config  mpc ON mpc.id_cia = c.id_cia
                                                 AND mpc.codigo = tc01.codigo
                                                 AND mpc.codsuc = 1
                                                 AND mpc.moneda = c.moneda
            LEFT OUTER JOIN tbancos        tb ON tb.id_cia = c.id_cia
                                          AND tb.codban = mpc.codban
        WHERE
            ( c.id_cia = pin_id_cia )
            AND ( c.tipcaja = 604 )
            AND ( c.doccaja = pnumcaja )
            AND ( c.situac <> 9 )
            AND ( c.asiento <> 0 )
            AND ( ( tb.cuentacon IS NOT NULL )
                  OR ( tb.cuentacon <> '' ) )
            AND ( ( tdc.cuenta IS NOT NULL )
                  OR ( tdc.cuenta <> '' ) );

        v_asiento     INTEGER := 0;
        v_count_vacio INTEGER := 0;
        v_swactualiza BOOLEAN := false;
        r_asiendet    asiendet%rowtype;
        v_item        INTEGER := 0;
        v_f376        VARCHAR2(20) := '';
        v_razsoc      VARCHAR2(100) := '';
        v_ruc         VARCHAR(20) := '';
        msj           VARCHAR2(1000);
    BEGIN
        BEGIN
            SELECT
                ruc,
                razsoc
            INTO
                v_ruc,
                v_razsoc
            FROM
                companias
            WHERE
                cia = pin_id_cia;

        EXCEPTION
            WHEN no_data_found THEN
                v_ruc := '';
                v_razsoc := '';
        END;   
	   /************************************************************/
       /*  factor 376 - Libro para asiento automático caja tienda  */
       /************************************************************/

        BEGIN
            SELECT
                vstrg
            INTO v_f376
            FROM
                factor
            WHERE
                    id_cia = pin_id_cia
                AND codfac = 376;

        EXCEPTION
            WHEN no_data_found THEN
                v_f376 := '';
        END;

        FOR r_caja IN cur_caja_cab(pin_id_cia, pin_fini, pin_ffin) LOOP
            BEGIN
                SELECT
                    c.asiento
                INTO v_asiento
                FROM
                    compr010 c
                WHERE
                    ( c.id_cia = pin_id_cia )
                    AND ( c.tipcaja = 604 )
                    AND ( c.doccaja = r_caja.numcaja )
                    AND ( c.situac <> 9 )
                    AND ( ( c.asiento IS NOT NULL )
                          OR ( c.asiento <> 0 ) )
                FETCH NEXT 1 ROWS ONLY;

            EXCEPTION
                WHEN no_data_found THEN
                    v_asiento := NULL;
            END;

            IF ( v_asiento IS NULL ) THEN
                v_asiento := 0;
            END IF;
    /*verificamos la cantidad de asientos no asignados*/
            BEGIN
                SELECT
                    COUNT(0)
                INTO v_count_vacio
                FROM
                    compr010 c
                WHERE
                    ( c.id_cia = pin_id_cia )
                    AND ( c.tipcaja = 604 )
                    AND ( c.doccaja = r_caja.numcaja )
                    AND ( c.situac <> 9 )
                    AND ( ( c.asiento IS NULL )
                          OR ( c.asiento = 0 ) );

            EXCEPTION
                WHEN no_data_found THEN
                    v_count_vacio := 0;
            END;

            IF (
                ( v_asiento = 0 )
                AND ( v_count_vacio > 0 )
            ) THEN
                sp00_saca_secuencia_libro(pin_id_cia, v_f376, r_caja.periodo, r_caja.mes, pin_coduser,
                                         1, v_asiento);

                v_swactualiza := true;
            END IF;

            IF v_swactualiza THEN
                UPDATE compr010
                SET
                    libro = v_f376,
                    asiento = v_asiento
                WHERE
                    ( id_cia = pin_id_cia )
                    AND ( tipcaja = 604 )
                    AND ( doccaja = r_caja.numcaja );

                COMMIT;
            END IF;
------------------	

            DELETE FROM movimientos
            WHERE
                    id_cia = pin_id_cia
                AND libro = v_f376
                AND periodo = r_caja.periodo
                AND mes = r_caja.mes
                AND asiento = v_asiento;

            COMMIT;
            DELETE FROM asiendet
            WHERE
                    id_cia = pin_id_cia
                AND libro = v_f376
                AND periodo = r_caja.periodo
                AND mes = r_caja.mes
                AND asiento = v_asiento;

            COMMIT;
            DELETE FROM asienhea
            WHERE
                    id_cia = pin_id_cia
                AND libro = v_f376
                AND periodo = r_caja.periodo
                AND mes = r_caja.mes
                AND asiento = v_asiento;

            COMMIT;
            v_item := 0;
            FOR rec_compr010 IN cur_compr010(r_caja.numcaja) LOOP
                IF v_item = 0 THEN
    	     /*creando asienhea */
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
                        pin_id_cia,
                        r_caja.periodo,
                        r_caja.mes,
                        v_f376,
                        v_asiento,
                        'Pase automático Caja Tienda - Nro. ' || r_caja.numcaja,
                        '',
                        '',
                        '',
                        66,
                        'PEN',
                        r_caja.finicio,
                        1,
                        1,
                        0,
                        1,--contabilizado
                        pin_coduser,
                        current_timestamp,
                        current_timestamp,
                        '',
                        '',
                        '',
                        '',
                        '',
                        0,
                        pin_coduser
                    );

                    COMMIT;
                END IF;
           /*Grabando depositos*/

                v_item := v_item + 1;
                r_asiendet.id_cia := pin_id_cia;
                r_asiendet.periodo := r_caja.periodo;
                r_asiendet.mes := r_caja.mes;
                r_asiendet.libro := v_f376;
                r_asiendet.asiento := v_asiento;
                r_asiendet.item := v_item;
                r_asiendet.sitem := 0;
                r_asiendet.concep := rec_compr010.concep;
                r_asiendet.fecha := r_caja.finicio;
                r_asiendet.tasien := 66;
                r_asiendet.topera := rec_compr010.clascodigo;
                r_asiendet.cuenta := rec_compr010.cuentacon;
                r_asiendet.dh := rec_compr010.dh;
                r_asiendet.moneda := rec_compr010.moneda;
                r_asiendet.importe := rec_compr010.importe;
                r_asiendet.impor01 := rec_compr010.impor01;
                r_asiendet.impor02 := rec_compr010.impor02;
                CASE
                    WHEN r_asiendet.dh = 'D' THEN
                        r_asiendet.debe := r_asiendet.importe;
                        r_asiendet.debe01 := r_asiendet.impor01;
                        r_asiendet.debe02 := r_asiendet.impor02;
                    WHEN r_asiendet.dh = 'H' THEN
                        r_asiendet.haber := r_asiendet.importe;
                        r_asiendet.haber01 := r_asiendet.impor01;
                        r_asiendet.haber02 := r_asiendet.impor02;
                END CASE;

                r_asiendet.tcambio01 := rec_compr010.tcamb01;
                r_asiendet.tcambio02 := rec_compr010.tcamb02;
                r_asiendet.ccosto := '';
                r_asiendet.proyec := '';
                r_asiendet.subcco := '';
                r_asiendet.ctaalternativa := '';
                r_asiendet.tipo := 0;
                r_asiendet.docume := 0;
                r_asiendet.codigo := rec_compr010.codpro;
                r_asiendet.razon := substr(rec_compr010.razon, 1, 74);
                r_asiendet.tident := '';
                r_asiendet.dident := '';
                r_asiendet.tdocum := '';
                r_asiendet.serie := '';
                r_asiendet.numero := '';
                r_asiendet.fdocum := rec_compr010.femisi;
                r_asiendet.usuari := pin_coduser;
                r_asiendet.fcreac := current_timestamp;
                r_asiendet.factua := current_timestamp;
                r_asiendet.regcomcol := 0;
                r_asiendet.swprovicion := 'N';
                r_asiendet.saldo := 0;
                r_asiendet.swgasoper := 1;
                r_asiendet.codporret := '';
                r_asiendet.swchkconcilia := 'N';
                INSERT INTO asiendet VALUES r_asiendet;

                COMMIT;
            END LOOP;
---------------

            FOR rec_compr010 IN cur_compr010(r_caja.numcaja) LOOP
            /*Grabando pagos*/
                v_item := v_item + 1;
                r_asiendet.id_cia := pin_id_cia;
                r_asiendet.periodo := r_caja.periodo;
                r_asiendet.mes := r_caja.mes;
                r_asiendet.libro := v_f376;
                r_asiendet.asiento := v_asiento;
                r_asiendet.item := v_item;
                r_asiendet.sitem := 0;
                r_asiendet.concep := rec_compr010.concep;
                r_asiendet.fecha := r_caja.finicio;
                r_asiendet.tasien := 66;
                r_asiendet.topera := rec_compr010.clascodigo;
                r_asiendet.cuenta := rec_compr010.cuentagastocaja;
                CASE
                    WHEN rec_compr010.dh = 'D' THEN
                        r_asiendet.dh := 'H';
                    WHEN rec_compr010.dh = 'H' THEN
                        r_asiendet.dh := 'D';
                END CASE;

                r_asiendet.moneda := rec_compr010.moneda;
                r_asiendet.importe := rec_compr010.importe;
                r_asiendet.impor01 := rec_compr010.impor01;
                r_asiendet.impor02 := rec_compr010.impor02;
                CASE
                    WHEN r_asiendet.dh = 'D' THEN
                        r_asiendet.debe := r_asiendet.importe;
                        r_asiendet.debe01 := r_asiendet.impor01;
                        r_asiendet.debe02 := r_asiendet.impor02;
                    WHEN r_asiendet.dh = 'H' THEN
                        r_asiendet.haber := r_asiendet.importe;
                        r_asiendet.haber01 := r_asiendet.impor01;
                        r_asiendet.haber02 := r_asiendet.impor02;
                END CASE;

                r_asiendet.tcambio01 := rec_compr010.tcamb01;
                r_asiendet.tcambio02 := rec_compr010.tcamb02;
                r_asiendet.ccosto := '';
                r_asiendet.proyec := '';
                r_asiendet.subcco := '';
                r_asiendet.ctaalternativa := '';
                r_asiendet.tipo := 0;
                r_asiendet.docume := 0;
                r_asiendet.codigo := v_ruc;
                r_asiendet.razon := substr(v_razsoc, 1, 74);
                r_asiendet.tident := '06';
                r_asiendet.dident := v_ruc;
                r_asiendet.tdocum := 'AD';
                r_asiendet.serie := '604';
                r_asiendet.numero := to_number(r_caja.numcaja);
                r_asiendet.fdocum := NULL;
                r_asiendet.usuari := pin_coduser;
                r_asiendet.fcreac := current_timestamp;
                r_asiendet.factua := current_timestamp;
                r_asiendet.regcomcol := 0;
                r_asiendet.swprovicion := 'N';
                r_asiendet.saldo := 0;
                r_asiendet.swgasoper := 1;
                r_asiendet.codporret := '';
                r_asiendet.swchkconcilia := 'N';
                INSERT INTO asiendet VALUES r_asiendet;

                COMMIT;
            END LOOP;

            IF v_item > 0 THEN
                sp_contabilizar_asiento(pin_id_cia, v_f376, r_caja.periodo, r_caja.mes, v_asiento,
                                       pin_coduser, msj);
            END IF;
---------------

        END LOOP;

    END sp_genera_asiento_caja_tienda;

    PROCEDURE sp_genera_asiento_cobranza_tienda (
        pin_id_cia  IN NUMBER,
        pid_libro   IN VARCHAR2,
        pin_fini    IN DATE,
        pin_ffin    IN DATE,
        pin_coduser IN VARCHAR2
    ) AS

        CURSOR cur_depositos (
            plibro     VARCHAR2,
            pperiodo   INTEGER,
            pmes       INTEGER,
            psecuencia INTEGER,
            pcodsuc    INTEGER
        ) IS
        SELECT
            d.libro,
            d.periodo,
            d.mes,
            d.secuencia,
            d.item,
            d.situac,
            d.tipdep,
            b.cuentacta AS cuenta,
            d.dh,
            d.tipmon,
            d.op,
            d.deposito,
            d.tcamb01,
            d.tcamb02,
            d.impor01,
            d.impor02,
            d.concep,
            mp.filtro   AS tipdepfil
        FROM
            dcta104       d
            LEFT OUTER JOIN m_pago        mp ON ( mp.id_cia = d.id_cia )
                                         AND ( mp.codigo = d.tipdep )
            LEFT OUTER JOIN m_pago_config mpc ON ( mpc.id_cia = d.id_cia )
                                                 AND ( mpc.codigo = d.tipdep )
                                                 AND ( mpc.codsuc = pcodsuc )
                                                 AND ( mpc.moneda = d.tipmon )
            LEFT OUTER JOIN tbancos       b ON ( b.id_cia = d.id_cia )
                                         AND ( b.codban = mpc.codban )
        WHERE
            ( d.id_cia = pin_id_cia )
            AND ( d.libro = plibro )
            AND ( d.periodo = pperiodo )
            AND ( d.mes = pmes )
            AND ( d.secuencia = psecuencia );

        CURSOR cur_pagos (
            plibro     VARCHAR2,
            pperiodo   INTEGER,
            pmes       INTEGER,
            psecuencia INTEGER
        ) IS
        SELECT
            p.swchksepaga,
            d.codcli,
            c.razonc,
            d.femisi,
            d.serie,
            d.numero,
            d.tipmon AS tmondoc,
            d.tipcam AS tipcamdoc,
            p.periodo,
            p.mes,
            p.secuencia,
            p.tipcan,
            p.cuenta,
            p.dh,
            p.tipmon AS tmonpag,
            p.amorti,
            p.impor01,
            p.impor02,
            p.situac,
            td.codsunat
        FROM
            dcta103      p
            LEFT OUTER JOIN dcta100      d ON ( d.id_cia = p.id_cia )
                                         AND ( d.numint = p.numint )
            LEFT OUTER JOIN cliente      c ON ( c.id_cia = p.id_cia )
                                         AND ( c.codcli = d.codcli )
            LEFT OUTER JOIN tdoccobranza td ON ( td.id_cia = p.id_cia )
                                               AND ( td.tipdoc = d.tipdoc )
        WHERE
            ( p.id_cia = pin_id_cia )
            AND ( p.libro = plibro )
            AND ( p.periodo = pperiodo )
            AND ( p.mes = pmes )
            AND ( p.secuencia = psecuencia );

        r_asiendet asiendet%rowtype;
        r_pagos    cur_pagos%rowtype;
        v_item     INTEGER := 0;
        msj        VARCHAR2(1000);
    BEGIN
        FOR rdcta102 IN cur_dcta102(pin_id_cia, pid_libro, pin_fini, pin_ffin) LOOP
            DELETE FROM movimientos
            WHERE
                    id_cia = pin_id_cia
                AND libro = rdcta102.libro
                AND periodo = rdcta102.periodo
                AND mes = rdcta102.mes
                AND asiento = rdcta102.secuencia;

            COMMIT;
            DELETE FROM asiendet
            WHERE
                    id_cia = pin_id_cia
                AND libro = rdcta102.libro
                AND periodo = rdcta102.periodo
                AND mes = rdcta102.mes
                AND asiento = rdcta102.secuencia;

            COMMIT;
            DELETE FROM asienhea
            WHERE
                    id_cia = pin_id_cia
                AND libro = rdcta102.libro
                AND periodo = rdcta102.periodo
                AND mes = rdcta102.mes
                AND asiento = rdcta102.secuencia;

            IF ( rdcta102.situac = 'B' ) THEN
                v_item := 0;
      	     /*creando asienhea */
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
                    pin_id_cia,
                    rdcta102.periodo,
                    rdcta102.mes,
                    rdcta102.libro,
                    rdcta102.secuencia,
                    'Pase automático desde Cobranza',
                    '',
                    '',
                    '',
                    66,
                    'PEN',
                    rdcta102.femisi,
                    1,
                    1,
                    0,
                    2,--contabilizado
                    pin_coduser,
                    current_timestamp,
                    current_timestamp,
                    '',
                    '',
                    '',
                    '',
                    '',
                    0,
                    pin_coduser
                );

                COMMIT;
                FOR rdep IN cur_depositos(rdcta102.libro, rdcta102.periodo, rdcta102.mes, rdcta102.secuencia, rdcta102.codsuc) LOOP
                    IF ( rdep.situac <> 'J' ) THEN
             /*Grabando DEPOSITOS*/
                        v_item := v_item + 1;
                        --OPEN cur_pagos(rdcta102.libro, rdcta102.periodo, rdcta102.mes, rdcta102.secuencia);

                        --FETCH cur_pagos INTO r_pagos;
                        --CLOSE cur_pagos;
                        r_asiendet.id_cia := pin_id_cia;
                        r_asiendet.periodo := rdcta102.periodo;
                        r_asiendet.mes := rdcta102.mes;
                        r_asiendet.libro := rdcta102.libro;
                        r_asiendet.asiento := rdcta102.secuencia;
                        r_asiendet.item := v_item;
                        r_asiendet.sitem := 0;
                        r_asiendet.concep := 'Pase automático desde Cobranza';
                        r_asiendet.fecha := rdcta102.femisi;
                        r_asiendet.tasien := 66;
                        r_asiendet.topera := rdep.tipdep;
                        r_asiendet.cuenta := rdep.cuenta;
                        IF rdep.deposito < 0 THEN
                            CASE
                                WHEN rdep.dh = 'D' THEN
                                    r_asiendet.dh := 'H';
                                WHEN rdep.dh = 'H' THEN
                                    r_asiendet.dh := 'D';
                            END CASE;
                        ELSE
                            r_asiendet.dh := rdep.dh;
                        END IF;

                        r_asiendet.moneda := rdep.tipmon;
                        r_asiendet.importe := abs(rdep.deposito);
                        r_asiendet.impor01 := abs(rdep.impor01);
                        r_asiendet.impor02 := abs(rdep.impor02);
                        r_asiendet.debe := 0;
                        r_asiendet.debe01 := 0;
                        r_asiendet.debe02 := 0;
                        r_asiendet.haber := 0;
                        r_asiendet.haber01 := 0;
                        r_asiendet.haber02 := 0;
                        CASE
                            WHEN r_asiendet.dh = 'D' THEN
                                r_asiendet.debe := r_asiendet.importe;
                                r_asiendet.debe01 := r_asiendet.impor01;
                                r_asiendet.debe02 := r_asiendet.impor02;
                            WHEN r_asiendet.dh = 'H' THEN
                                r_asiendet.haber := r_asiendet.importe;
                                r_asiendet.haber01 := r_asiendet.impor01;
                                r_asiendet.haber02 := r_asiendet.impor02;
                        END CASE;

                        r_asiendet.tcambio01 := rdep.tcamb01;
                        r_asiendet.tcambio02 := rdep.tcamb02;
                        r_asiendet.ccosto := '';
                        r_asiendet.proyec := '';
                        r_asiendet.subcco := '';
                        r_asiendet.ctaalternativa := '';
                        r_asiendet.tipo := 0;
                        r_asiendet.docume := 0;
                        r_asiendet.tident := '';
                        r_asiendet.dident := '';
                        r_asiendet.codigo := '';
                        r_asiendet.razon := '';
                        r_asiendet.tdocum := '';
                        r_asiendet.serie := '';
                        r_asiendet.numero := '';
                        r_asiendet.fdocum := NULL;
                        r_asiendet.numero := rdep.op;
                        --IF ( rdep.tipdepfil = 6 ) THEN
                        --    r_asiendet.codigo := r_pagos.codcli;
                        --    r_asiendet.razon := substr(r_pagos.razonc, 1, 74);
                        --    r_asiendet.tdocum := r_pagos.codsunat;
                        --    r_asiendet.serie := r_pagos.serie;
                        --    r_asiendet.numero := r_pagos.numero;
                        --    r_asiendet.fdocum := r_pagos.femisi;
                        -- END IF;

                        r_asiendet.usuari := pin_coduser;
                        r_asiendet.fcreac := current_timestamp;
                        r_asiendet.factua := current_timestamp;
                        r_asiendet.regcomcol := 0;
                        r_asiendet.swprovicion := 'N';
                        r_asiendet.saldo := 0;
                        r_asiendet.swgasoper := 1;
                        r_asiendet.codporret := '';
                        r_asiendet.swchkconcilia := 'N';
                        INSERT INTO asiendet VALUES r_asiendet;

                        COMMIT;
                    END IF;
                END LOOP;
--pagos

                FOR rpag IN cur_pagos(rdcta102.libro, rdcta102.periodo, rdcta102.mes, rdcta102.secuencia) LOOP
                    IF ( rpag.situac <> 'J' ) THEN
             /*Grabando pagos*/
                        v_item := v_item + 1;
                        r_asiendet.id_cia := pin_id_cia;
                        r_asiendet.periodo := rdcta102.periodo;
                        r_asiendet.mes := rdcta102.mes;
                        r_asiendet.libro := rdcta102.libro;
                        r_asiendet.asiento := rdcta102.secuencia;
                        r_asiendet.item := v_item;
                        r_asiendet.sitem := 0;
                        r_asiendet.fecha := rdcta102.femisi;
                        r_asiendet.tasien := 66;
                        r_asiendet.topera := rpag.tipcan;
                        r_asiendet.cuenta := rpag.cuenta;
                        r_asiendet.dh := rpag.dh;
                        r_asiendet.moneda := rpag.tmonpag;
                        IF rpag.tmonpag = 'PEN' THEN
                            r_asiendet.tcambio01 := 1;
                            r_asiendet.tcambio02 := 1 / rpag.tipcamdoc;
                        END IF;

                        IF rpag.tmonpag <> 'PEN' THEN
                            r_asiendet.tcambio01 := rpag.tipcamdoc;
                            r_asiendet.tcambio02 := 1;
                        END IF;

                        r_asiendet.importe := rpag.amorti;
                        IF rpag.tmondoc = rpag.tmonpag THEN
                            r_asiendet.impor01 := r_asiendet.importe * r_asiendet.tcambio01;
                            r_asiendet.impor02 := r_asiendet.importe * r_asiendet.tcambio02;
                        ELSE
                            IF rpag.tmondoc = 'PEN' THEN
                                r_asiendet.impor01 := rpag.impor01;
                                r_asiendet.impor02 := rpag.impor01 / r_asiendet.tcambio01;
                                r_asiendet.importe := r_asiendet.impor02;
                            ELSIF ( rpag.tmondoc <> 'PEN' ) THEN
                                r_asiendet.impor01 := rpag.impor02 / r_asiendet.tcambio02;
                                r_asiendet.impor02 := rpag.impor02;
                                r_asiendet.importe := r_asiendet.impor01;
                            END IF;
                        END IF;

                        r_asiendet.debe := 0;
                        r_asiendet.debe01 := 0;
                        r_asiendet.debe02 := 0;
                        r_asiendet.haber := 0;
                        r_asiendet.haber01 := 0;
                        r_asiendet.haber02 := 0;
                        CASE
                            WHEN r_asiendet.dh = 'D' THEN
                                r_asiendet.debe := r_asiendet.importe;
                                r_asiendet.debe01 := r_asiendet.impor01;
                                r_asiendet.debe02 := r_asiendet.impor02;
                            WHEN r_asiendet.dh = 'H' THEN
                                r_asiendet.haber := r_asiendet.importe;
                                r_asiendet.haber01 := r_asiendet.impor01;
                                r_asiendet.haber02 := r_asiendet.impor02;
                        END CASE;

                        r_asiendet.ccosto := '';
                        r_asiendet.proyec := '';
                        r_asiendet.subcco := '';
                        r_asiendet.ctaalternativa := '';
                        r_asiendet.tipo := 0;
                        r_asiendet.docume := 0;
                        r_asiendet.tident := '';
                        r_asiendet.dident := '';
                        r_asiendet.codigo := rpag.codcli;
                        r_asiendet.razon := substr(rpag.razonc, 1, 74);
                        r_asiendet.concep := substr(rpag.razonc, 1, 74);
                        r_asiendet.tdocum := rpag.codsunat;
                        r_asiendet.serie := rpag.serie;
                        r_asiendet.numero := rpag.numero;
                        r_asiendet.fdocum := rpag.femisi;
                        r_asiendet.usuari := pin_coduser;
                        r_asiendet.fcreac := current_timestamp;
                        r_asiendet.factua := current_timestamp;
                        r_asiendet.regcomcol := 0;
                        r_asiendet.swprovicion := 'N';
                        r_asiendet.saldo := 0;
                        r_asiendet.swgasoper := 1;
                        r_asiendet.codporret := '';
                        r_asiendet.swchkconcilia := 'N';
                        INSERT INTO asiendet VALUES r_asiendet;

                        COMMIT;
                    END IF;
                END LOOP;
--pagos

            END IF;

            IF v_item > 0 THEN
                sp_contabilizar_asiento(pin_id_cia, rdcta102.libro, rdcta102.periodo, rdcta102.mes, rdcta102.secuencia,
                                       pin_coduser, msj);
            END IF;

        END LOOP;
    END sp_genera_asiento_cobranza_tienda;

END;

/

--------------------------------------------------------
--  DDL for Package Body PACK_IMPORT_ASIENTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_IMPORT_ASIENTO" AS

    FUNCTION valida_objeto (
        pin_id_cia IN NUMBER,
        pin_datos  IN CLOB
    ) RETURN datatable
        PIPELINED
    AS

        reg_errores  r_errores := r_errores(NULL, NULL);
        o            json_object_t;
        rec_asienhea asienhea%rowtype;
        rec_asiendet asiendet%rowtype;
        v_cuenta     pcuentas.cuenta%TYPE;
        v_codcli     cliente.codcli%TYPE;
        v_count      NUMBER;
    BEGIN
        o := json_object_t.parse(pin_datos);
                -- INSERTANDO CABEZERA
        rec_asienhea.id_cia := pin_id_cia;
        rec_asienhea.periodo := o.get_number('periodo');
        rec_asienhea.mes := o.get_number('mes');
        rec_asienhea.libro := o.get_string('libro');--Codigo de Libro
        rec_asienhea.asiento := o.get_number('asiento');
        
    -- VALIDAMOS QUE EXISTE EL LIBRO
        BEGIN
            SELECT
                codlib
            INTO v_cuenta
            FROM
                tlibro
            WHERE
                    id_cia = pin_id_cia
                AND codlib = rec_asienhea.libro;

        EXCEPTION
            WHEN no_data_found THEN
                reg_errores.valor := rec_asienhea.libro;
                reg_errores.deserror := 'El Libro [ '
                                        || rec_asienhea.libro
                                        || ' ] no Existe en el Libro de Cuentas';
                PIPE ROW ( reg_errores );
        END;
        
        
    -- VALIDAMOS QUE NO EXISTA EL ASIENTO
        BEGIN
            BEGIN
                SELECT
                    COUNT(1)
                INTO v_count
                FROM
                    asienhea
                WHERE
                        id_cia = rec_asienhea.id_cia
                    AND periodo = rec_asienhea.periodo
                    AND mes = rec_asienhea.mes
                    AND libro = rec_asienhea.libro
                    AND asiento = rec_asienhea.asiento;

            EXCEPTION
                WHEN no_data_found THEN
                    v_count := 0;
            END;

            IF v_count > 0 THEN
                reg_errores.valor := rec_asienhea.asiento;
                reg_errores.deserror := 'El Asiento con el Periodo [ '
                                        || rec_asienhea.periodo
                                        || '-'
                                        || rec_asienhea.mes
                                        || ', con el libro [ '
                                        || rec_asienhea.libro
                                        || ' y con Codigo [ '
                                        || rec_asienhea.asiento
                                        || ' ] ya existe y no puede duplicarse.';

                PIPE ROW ( reg_errores );
            END IF;

        END;

        RETURN;
    END valida_objeto;

    FUNCTION valida_objeto_detalle (
        pin_id_cia IN NUMBER,
        pin_datos  IN CLOB
    ) RETURN datatable
        PIPELINED
    AS

        reg_errores  r_errores := r_errores(NULL, NULL);
        o            json_object_t;
        rec_asienhea asienhea%rowtype;
        rec_asiendet asiendet%rowtype;
        v_cuenta     pcuentas.cuenta%TYPE;
        v_codcli     cliente.codcli%TYPE;
        v_count      NUMBER;
    BEGIN
        o := json_object_t.parse(pin_datos);
                -- INSERTANDO CABEZERA
        rec_asienhea.id_cia := pin_id_cia;
        rec_asienhea.periodo := o.get_number('periodo');
        rec_asienhea.mes := o.get_number('mes');
        rec_asienhea.libro := o.get_string('libro');--Codigo de Libro
        rec_asienhea.asiento := o.get_number('asiento');
        -- INSERTANDO DETALLE
        rec_asiendet.item := o.get_number('item'); -- NroItemAsiento
        rec_asiendet.cuenta := o.get_string('cuenta'); -- Cuenta Contable
        rec_asiendet.codigo := o.get_string('codigo'); -- Codigo del Cliente/Proveedor
        
    -- VALIDAMOS QUE NO EXISTA EL ASIENTDET
        BEGIN
            BEGIN
                SELECT
                    COUNT(1)
                INTO v_count
                FROM
                    asiendet
                WHERE
                        id_cia = rec_asienhea.id_cia
                    AND periodo = rec_asienhea.periodo
                    AND mes = rec_asienhea.mes
                    AND libro = rec_asienhea.libro
                    AND asiento = rec_asienhea.asiento
                    AND item = rec_asiendet.item;

            EXCEPTION
                WHEN no_data_found THEN
                    v_count := 0;
            END;

            IF v_count > 0 THEN
                reg_errores.valor := rec_asienhea.asiento;
                reg_errores.deserror := 'El ITEM del Asiento [ '
                                        || rec_asienhea.periodo
                                        || '-'
                                        || rec_asienhea.mes
                                        || ', con el libro [ '
                                        || rec_asienhea.libro
                                        || ' y con Codigo-Item [ '
                                        || rec_asienhea.asiento
                                        || '-'
                                        || rec_asiendet.item
                                        || ' ] ya existe y no puede duplicarse.';

                PIPE ROW ( reg_errores );
            END IF;

        END;
        
    -- VALIDAMOS SI LA CUENTA EXISTE
        BEGIN
            SELECT
                cuenta
            INTO v_cuenta
            FROM
                pcuentas
            WHERE
                    id_cia = pin_id_cia
                AND cuenta = rec_asiendet.cuenta;

        EXCEPTION
            WHEN no_data_found THEN
                reg_errores.valor := rec_asiendet.cuenta;
                reg_errores.deserror := 'La cuenta [ '
                                        || rec_asiendet.cuenta
                                        || ' ] no Existe en el Libro de Cuenta';
                PIPE ROW ( reg_errores );
        END;
    -- VALIDAMOS SI EXISTE EL CLIENTE/PROVEEDOR
      /*  IF rec_asiendet.codigo IS NOT NULL THEN
            BEGIN
                SELECT
                    codcli
                INTO v_codcli
                FROM
                    cliente
                WHERE
                        id_cia = pin_id_cia
                    AND codcli = rec_asiendet.codigo;

            EXCEPTION
                WHEN no_data_found THEN
                    reg_errores.valor := rec_asiendet.codigo;
                    reg_errores.deserror := 'No existe ningun Cliente/Proveedor con este Codigo ... !';
                    PIPE ROW ( reg_errores );
            END;
        END IF;*/

        RETURN;
    END valida_objeto_detalle;

    PROCEDURE importa_asiento (
        pin_id_cia  IN NUMBER,
        pin_usuari  IN VARCHAR2,
        pin_datos   IN CLOB,
        pin_mensaje OUT VARCHAR2
    ) AS
        o            json_object_t;
        rec_asienhea asienhea%rowtype;
        rec_asiendet asiendet%rowtype;
    BEGIN
        o := json_object_t.parse(pin_datos);
        -- INSERTANDO CABEZERA
        rec_asienhea.id_cia := pin_id_cia;
        rec_asienhea.periodo := o.get_number('periodo');
        rec_asienhea.mes := o.get_number('mes');
        rec_asienhea.libro := o.get_string('libro');--Codigo de Libro
        rec_asienhea.asiento := o.get_number('asiento');
        rec_asienhea.concep := o.get_string('concep');
        rec_asienhea.codigo := o.get_string('codigo'); --Codigo del Cliente/Proveedor
        rec_asienhea.nombre := o.get_string('nombre');-- Razon Social
        rec_asienhea.motivo := 0;
        rec_asienhea.tasien := 77; -- Migracion
        rec_asienhea.moneda := o.get_string('moneda');-- Moneda de Origen
        rec_asienhea.fecha := o.get_date('fecha'); -- Fecha de Operacion
        IF rec_asienhea.moneda = 'PEN' THEN -- Punto 2 TipCambio Segun Moneda ?
            rec_asienhea.tcamb01 := 1;-- Moneda Soles S/.100 X 1 = S/.100
            if o.get_number('tcamb_cab') > 0 then
                rec_asienhea.tcamb02 := ( 1 / o.get_number('tcamb_cab') ); -- Tipo de cambio - Cabecera
            end if;
            -- 1 / 3.89 = 0.25 -- Factor de Cambio
        ELSE
            rec_asienhea.tcamb01 := o.get_number('tcamb_cab'); -- Tipo de cambio - Cabecera
            -- 3.89 = 3.89 Tipo de Cambio
            rec_asienhea.tcamb02 := 1; -- Moneda Dolares $/.100 X 1 = $/.100
        END IF;

        rec_asienhea.ncontab := NULL;
        rec_asienhea.situac := 2;
        rec_asienhea.usuari := pin_usuari; -- EL usuario que Importa el Archivo

        INSERT INTO asienhea VALUES (
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
            current_date,
            current_date,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL
        );

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
        WHEN dup_val_on_index THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 2.0,
                    'message' VALUE 'El Asiento [ '
                                    || rec_asienhea.periodo
                                    || '-'
                                    || rec_asienhea.mes
                                    || ', con el libro [ '
                                    || rec_asienhea.libro
                                    || ' y con Codigo [ '
                                    || rec_asienhea.asiento
                                    || ' ] ya existe y no puede duplicarse.'
                )
            INTO pin_mensaje
            FROM
                dual;

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

    END importa_asiento;

    PROCEDURE importa_asiento_detalle (
        pin_id_cia  IN NUMBER,
        pin_usuari  IN VARCHAR2,
        pin_datos   IN CLOB,
        pin_mensaje OUT VARCHAR2
    ) AS
        o            json_object_t;
        rec_asienhea asienhea%rowtype;
        rec_asiendet asiendet%rowtype;
    BEGIN
        o := json_object_t.parse(pin_datos);
        -- INSERTANDO CABEZERA
        rec_asienhea.id_cia := pin_id_cia;
        rec_asienhea.periodo := o.get_number('periodo');
        rec_asienhea.mes := o.get_number('mes');
        rec_asienhea.libro := o.get_string('libro');--Codigo de Libro
        rec_asienhea.asiento := o.get_number('asiento');
        rec_asienhea.concep := o.get_string('concep');
        rec_asienhea.codigo := o.get_string('codigo'); --Codigo del Cliente/Proveedor
        rec_asienhea.nombre := o.get_string('nombre');-- Razon Social
        rec_asienhea.motivo := 0;
        rec_asienhea.tasien := 77; -- Migracion
        rec_asienhea.moneda := o.get_string('moneda');-- Moneda de Origen
        rec_asienhea.fecha := o.get_date('fecha'); -- Fecha de Operacion
        IF rec_asienhea.moneda = 'PEN' THEN -- Punto 2 TipCambio Segun Moneda ?
            rec_asienhea.tcamb01 := 1;-- Moneda Soles S/.100 X 1 = S/.100
            if o.get_number('tcamb_cab') > 0 then
                rec_asienhea.tcamb02 := ( 1 / o.get_number('tcamb_cab') ); -- Tipo de cambio - Cabecera
            end if;
            -- 1 / 3.89 = 0.25 -- Factor de Cambio
        ELSE
            rec_asienhea.tcamb01 := o.get_number('tcamb_cab'); -- Tipo de cambio - Cabecera
            -- 3.89 = 3.89 Tipo de Cambio
            rec_asienhea.tcamb02 := 1; -- Moneda Dolares $/.100 X 1 = $/.100
        END IF;

        rec_asienhea.ncontab := NULL;
        rec_asienhea.situac := 2;
        rec_asienhea.usuari := pin_usuari; -- EL usuario que Importa el Archivo
        
        -- INSERTANDO DETALLES
        rec_asiendet.item := o.get_number('item'); -- NroItemAsiento
        rec_asiendet.sitem := 0;
        rec_asiendet.concep := o.get_string('concep');
        rec_asiendet.fecha := o.get_date('fecha'); -- Fecha de Operacion
        rec_asiendet.tasien := 77; --Migracion
        rec_asiendet.topera := 0;
        rec_asiendet.cuenta := o.get_string('cuenta'); -- Cuenta Contable
        rec_asiendet.dh := o.get_string('dh'); --Debe/Haber
        rec_asiendet.moneda := o.get_string('moneda'); -- Moneda de Origen
        rec_asiendet.importe := o.get_number('importe');-- Importe Origen
        rec_asiendet.impor01 := o.get_number('impor01');-- Importe Soles
        rec_asiendet.impor02 := o.get_number('impor02');-- Importe Dolares
        IF rec_asiendet.dh = 'D' THEN
            rec_asiendet.debe := rec_asiendet.importe;
            rec_asiendet.debe01 := rec_asiendet.impor01;
            rec_asiendet.debe02 := rec_asiendet.impor02;
        ELSIF rec_asiendet.dh = 'H' THEN
            rec_asiendet.haber := rec_asiendet.importe;
            rec_asiendet.haber01 := rec_asiendet.impor01;
            rec_asiendet.haber02 := rec_asiendet.impor02;
        END IF;
        -- Tipo de Cambio se Calcula Segun los Importes
        IF rec_asiendet.moneda = 'PEN' THEN
            rec_asiendet.tcambio01 := 1; -- Moneda Soles S/.100 X 1 = S/.100
            if rec_asiendet.impor02 > 0 then
                rec_asiendet.tcambio02 := rec_asiendet.impor01 / rec_asiendet.impor02; -- 3.89 / Tipo Cambio
            end if;
             -- S/.389 / $/.100 = 3.89 
        ELSIF rec_asiendet.moneda = 'USD' THEN
            if  rec_asiendet.impor01 > 0 then
                rec_asiendet.tcambio01 := rec_asiendet.impor02 / rec_asiendet.impor01; -- 0.25 / Factor de Cambio
            end if;
             -- $/.100 / S/.389 = 0.25
            rec_asiendet.tcambio01 := 1; -- Moneda Dolares $/.100 X 1 = $/.100
        END IF;

        rec_asiendet.ccosto := o.get_string('ccosto'); -- Cuanto de Centro de Costo
        rec_asiendet.proyec := o.get_string('proyec'); -- Proyecto
        rec_asiendet.subcco := o.get_string('subcco'); -- Sub Centro Costo
        rec_asiendet.tipo := NULL;
        rec_asiendet.docume := NULL;
        rec_asiendet.codigo := o.get_string('codigo'); -- Codigo de Cliente/Proveedor
        rec_asiendet.razon := o.get_string('razon'); -- Razon Social
        rec_asiendet.tident := o.get_string('tident'); -- Tipo de Identidad
        rec_asiendet.dident := o.get_string('dident'); -- Documento Identidad
        rec_asiendet.tdocum := o.get_string('tdocum');-- Tipo Documento
        rec_asiendet.serie := o.get_string('serie'); -- Serie de Documento
        rec_asiendet.numero := o.get_string('numero'); -- Numero de Documento
        rec_asiendet.fdocum := o.get_date('fdocum'); -- Fecha de Documento
        rec_asiendet.ctaalternativa := o.get_string('ctaalternativa');-- Cuenta Contable Alternativa

        INSERT INTO asiendet VALUES (
            rec_asienhea.id_cia,
            rec_asienhea.periodo,
            rec_asienhea.mes,
            rec_asienhea.libro,
            rec_asienhea.asiento,
            rec_asiendet.item,
            rec_asiendet.sitem,
            rec_asiendet.concep,
            rec_asiendet.fecha,
            rec_asiendet.tasien,
            rec_asiendet.topera,
            rec_asiendet.cuenta,
            rec_asiendet.dh,
            rec_asiendet.moneda,
            rec_asiendet.importe,
            rec_asiendet.impor01,
            rec_asiendet.impor02,
            rec_asiendet.debe,
            rec_asiendet.debe01,
            rec_asiendet.debe02,
            rec_asiendet.haber,
            rec_asiendet.haber01,
            rec_asiendet.haber02,
            rec_asiendet.tcambio01,
            rec_asiendet.tcambio02,
            rec_asiendet.ccosto,
            rec_asiendet.proyec,
            rec_asiendet.subcco,
            rec_asiendet.tipo,
            rec_asiendet.docume,
            rec_asiendet.codigo,
            rec_asiendet.razon,
            rec_asiendet.tident,
            rec_asiendet.dident,
            rec_asiendet.tdocum,
            rec_asiendet.serie,
            rec_asiendet.numero,
            rec_asiendet.fdocum,
            rec_asiendet.usuari,
            current_date,
            current_date,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            rec_asiendet.ctaalternativa
        );

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
        WHEN dup_val_on_index THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 2.0,
                    'message' VALUE 'El ITEM del Asiento [ '
                                    || rec_asienhea.periodo
                                    || '-'
                                    || rec_asienhea.mes
                                    || ', con el libro [ '
                                    || rec_asienhea.libro
                                    || ' y con Codigo-Item [ '
                                    || rec_asienhea.asiento
                                    || '-'
                                    || rec_asiendet.item
                                    || ' ] ya existe y no puede duplicarse.'
                )
            INTO pin_mensaje
            FROM
                dual;

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

    END importa_asiento_detalle;

    PROCEDURE sp_contabilizar_asiento_importacion (
        pin_id_cia    IN NUMBER,
        pin_libro     IN VARCHAR2,
        pin_periodo   IN NUMBER,
        pin_mes       IN NUMBER,
        pin_secuencia IN NUMBER,
        pin_usuario   IN VARCHAR2,
        pin_mensaje   OUT VARCHAR2
    ) AS

        CURSOR cur_asiendet IS
        SELECT
            det.id_cia,
            det.periodo,
            det.mes,
            det.libro,
            det.asiento,
            det.item,
            det.sitem,
            det.concep,
            det.fecha,
            det.tasien,
            det.topera,
            det.cuenta,
            det.dh,
            det.moneda,
            det.importe,
            det.impor01,
            det.impor02,
            det.debe,
            det.debe01,
            det.debe02,
            det.haber,
            det.haber01,
            det.haber02,
            det.tcambio01,
            det.tcambio02,
            det.ccosto,
            det.proyec,
            det.subcco,
            det.tipo,
            det.docume,
            det.codigo,
            det.razon,
            det.tident,
            det.dident,
            det.tdocum,
            det.serie,
            det.numero,
            det.fdocum,
            det.usuari,
            det.fcreac,
            det.factua,
            det.regcomcol,
            det.swprovicion,
            det.saldo,
            det.swgasoper,
            det.codporret,
            det.swchkconcilia,
            det.ctaalternativa,
 --       TRIM(cco.codigo)         AS codigo,
            TRIM(cco.destin)   AS destincco,
 --       TRIM(pcta.cuenta)        AS cuenta,
            TRIM(pcta.ccosto)  AS swccosto,
            TRIM(pcta.destino) AS swdestino,
            TRIM(pcta.destid)  AS destid,
            TRIM(pcta.destih)  AS destih
        FROM
            movimientos det
            LEFT OUTER JOIN tccostos    cco ON ( cco.id_cia = pin_id_cia )
                                            AND ( cco.codigo = det.ccosto )
            LEFT OUTER JOIN pcuentas    pcta ON ( pcta.id_cia = pin_id_cia )
                                             AND ( pcta.cuenta = det.cuenta )
        WHERE
                det.id_cia = pin_id_cia
            AND det.libro = pin_libro
            AND det.periodo = pin_periodo
            AND det.mes = pin_mes
            AND det.asiento = pin_secuencia
        ORDER BY
            det.id_cia,
            det.periodo,
            det.mes,
            det.libro,
            det.asiento,
            det.item;

        v_ccosto         VARCHAR(16);
        v_codctacco      VARCHAR(16) := '';
        v_destincco      VARCHAR(16) := '';
        v_cuenta         VARCHAR2(100) := '';
        v_cuentadet      VARCHAR2(80) := '';
        v_destindpcuenta VARCHAR(16) := '';
        v_destinhpcuenta VARCHAR(16) := '';
        v_cuentaerr      VARCHAR(16) := '';
        v_sitem          INTEGER;
        v_no_genera_des  VARCHAR(1) := 'S';
        v_item           NUMBER;
        v_accion         VARCHAR2(50) := 'el proceso';
        v_result         VARCHAR2(1);
        v_error          VARCHAR2(100) := '';
        v_mensaje        VARCHAR2(250) := '';
        v_aux            VARCHAR2(25) := '';
    BEGIN
        DELETE FROM movimientos
        WHERE
                id_cia = pin_id_cia
            AND periodo = pin_periodo
            AND mes = pin_mes
            AND libro = pin_libro
            AND asiento = pin_secuencia;

        v_cuenta := '(AsientDet) - '; --INICIALIZANDO
    -- BUSCANDO CUENTAS DEL DOCUMENTOS_DET
        pack_pcuentas.sp_cuenta_no_existe(pin_id_cia, pin_periodo, pin_mes, pin_libro, pin_secuencia,
                                         v_cuentadet);
        v_cuenta := v_cuenta || v_cuentadet;
        INSERT INTO movimientos
            SELECT
                d.id_cia,
                d.periodo,
                d.mes,
                d.libro,
                d.asiento,
                d.item,
                d.sitem,
                d.concep,
                c.fecha,
                d.tasien,
                d.topera,
                d.cuenta,
                d.dh,
                d.moneda,
                d.importe,
                d.impor01,
                d.impor02,
                d.debe,
                d.debe01,
                d.debe02,
                d.haber,
                d.haber01,
                d.haber02,
                d.tcambio01,
                d.tcambio02,
                d.ccosto,
                d.proyec,
                d.subcco,
                d.tipo,
                d.docume,
                d.codigo,
                d.razon,
                d.tident,
                d.dident,
                d.tdocum,
                d.serie,
                d.numero,
                d.fdocum,
                d.usuari,
                d.fcreac,
                d.factua,
                d.regcomcol,
                d.swprovicion,
                d.saldo,
                d.swgasoper,
                d.codporret,
                d.swchkconcilia,
                d.ctaalternativa
            FROM
                asiendet d
                LEFT OUTER JOIN asienhea c ON c.id_cia = d.id_cia
                                              AND c.libro = d.libro
                                              AND c.periodo = d.periodo
                                              AND c.mes = d.mes
                                              AND c.asiento = d.asiento
            WHERE
                    d.id_cia = pin_id_cia
                AND d.periodo = pin_periodo
                AND d.mes = pin_mes
                AND d.libro = pin_libro
                AND d.asiento = pin_secuencia;

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
        WHEN OTHERS THEN
            IF sqlcode = -2291 THEN -- RESTRICCION FK
                sp_descontabilizar_asiento(pin_id_cia, pin_libro, pin_periodo, pin_mes, pin_secuencia,
                                          pin_usuario, v_mensaje);
                SELECT
                    JSON_OBJECT(
                        'status' VALUE 1.1,
                        'message' VALUE 'La cuenta [ '
                                        || v_cuenta
                                        || ' ] no existe o no se encuentra registrada en el Plan de Cuentas'
                    )
                INTO pin_mensaje
                FROM
                    dual;

            ELSIF sqlcode = -1400 THEN -- CUENTA NULL
                sp_descontabilizar_asiento(pin_id_cia, pin_libro, pin_periodo, pin_mes, pin_secuencia,
                                          pin_usuario, v_mensaje);
                SELECT
                    JSON_OBJECT(
                        'status' VALUE 1.1,
                        'message' VALUE 'La cuenta no ha a sido definida [ '
                                        || v_cuenta
                                        || ' ] Registre una Cuenta Contable para contabilizar este Asiento'
                    )
                INTO pin_mensaje
                FROM
                    dual;

            ELSE
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

            END IF;
    END sp_contabilizar_asiento_importacion;

    PROCEDURE contabiliza_asiento_migracion (
        pin_id_cia  IN NUMBER,
        pin_usuari  IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS
        v_msj     VARCHAR2(1000) := '';
        o         json_object_t;
        v_proceso NUMBER := 1;
    BEGIN
        FOR i IN (
            SELECT
                *
            FROM
                asienhea
            WHERE
                    id_cia = pin_id_cia
                AND tasien = 77 -- ASIENTO DE IMPORTACION
--                AND trunc(fcreac) BETWEEN ( trunc(current_date) - 3 ) AND ( trunc(current_date) + 1 )
                -- FILTRO DE FECHA - PLAZO DE 3 DIAS PARA CONTABILIZAR ASIENTO DE IMPORTACION
        ) LOOP
            pack_import_asiento.sp_contabilizar_asiento_importacion(pin_id_cia, i.libro, i.periodo, i.mes, i.asiento,
                                                                   pin_usuari, v_msj);

            o := json_object_t.parse(v_msj);
            dbms_output.put_line('CONTABILIZAR ASIENTO - ' || o.get_string('message'));
            IF ( o.get_number('status') <> 1.0 ) THEN
                v_proceso := 1;
                UPDATE asienhea
                SET
                    situac = 1, -- En Proceso / Fallo Contabilizacion
                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    usuari = pin_usuari
                WHERE
                        id_cia = pin_id_cia
                    AND periodo = i.periodo
                    AND mes = i.mes
                    AND libro = i.libro
                    AND asiento = i.asiento;

                COMMIT;
            ELSE
                UPDATE asienhea
                SET
                    situac = 2, -- Contabilizado
                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    usuari = pin_usuari
                WHERE
                        id_cia = pin_id_cia
                    AND periodo = i.periodo
                    AND mes = i.mes
                    AND libro = i.libro
                    AND asiento = i.asiento;

                COMMIT;
            END IF;

        END LOOP;

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

    END contabiliza_asiento_migracion;

END;

/

--------------------------------------------------------
--  DDL for Package Body PACK_IMPORT_KARDEX_DETALLADO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_IMPORT_KARDEX_DETALLADO" AS

    FUNCTION valida_objeto (
        pin_id_cia IN NUMBER,
        pin_datos  IN CLOB
    ) RETURN datatable
        PIPELINED
    AS

        reg_errores        r_errores := r_errores(NULL, NULL);
        o                  json_object_t;
        rec_documentos_cab documentos_cab%rowtype;
        rec_documentos_det documentos_det%rowtype;
        rec_kardex         kardex%rowtype;
        v_cuenta           pcuentas.cuenta%TYPE;
        v_codcli           cliente.codcli%TYPE;
        v_codart           articulos.codart%TYPE;
        v_codsuc           sucursal.codsuc%TYPE;
        v_count            NUMBER;
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_documentos_cab.numint := o.get_number('numint') * -1;
        rec_documentos_cab.codcli := o.get_string('codcli');-- CODIGO DE CLIENTE
        rec_documentos_cab.codsuc := o.get_number('codsuc');
        rec_documentos_cab.tipcam := o.get_number('tipcam');
        IF rec_documentos_cab.tipcam <= 0 THEN
            reg_errores.valor := rec_documentos_cab.numint;
            reg_errores.deserror := 'El Tipo  de Cambio [ '
                                    || rec_documentos_cab.tipcam
                                    || ' ] no puede ser menor a CERO.';
            PIPE ROW ( reg_errores );
        END IF;
    -- VALIDAMOS QUE NO EXISTA EL DOCUMENTO
        BEGIN
            BEGIN
                SELECT
                    COUNT(0)
                INTO v_count
                FROM
                    documentos_cab
                WHERE
                        id_cia = pin_id_cia
                    AND numint = rec_documentos_cab.numint;

            EXCEPTION
                WHEN no_data_found THEN
                    v_count := 0;
            END;

            IF v_count > 0 THEN
                reg_errores.valor := rec_documentos_cab.numint;
                reg_errores.deserror := 'El Documento con NUMINT [ '
                                        || rec_documentos_cab.numint
                                        || ' ] ya existe y no puede duplicarse.';
                PIPE ROW ( reg_errores );
            END IF;

        END;

    -- VALIDAMOS SI EXISTE EL CLIENTE/PROVEEDOR
--        BEGIN
--            SELECT
--                codcli
--            INTO v_codcli
--            FROM
--                cliente
--            WHERE
--                    id_cia = pin_id_cia
--                AND codcli = rec_documentos_cab.codcli;
--
--        EXCEPTION
--            WHEN no_data_found THEN
--                reg_errores.valor := rec_documentos_cab.codcli;
--                reg_errores.deserror := 'No existe ningun Cliente/Proveedor con este Codigo [ '
--                                        || rec_documentos_cab.codcli
--                                        || ' ] ';
--                PIPE ROW ( reg_errores );
--        END;

    -- VALIDAMOS SI EXISTE LA SUCURSAL
        BEGIN
            SELECT
                codsuc
            INTO v_codsuc
            FROM
                sucursal
            WHERE
                    id_cia = pin_id_cia
                AND codsuc = rec_documentos_cab.codsuc;

        EXCEPTION
            WHEN no_data_found THEN
                reg_errores.valor := rec_documentos_cab.codsuc;
                reg_errores.deserror := 'No existe ninguna Sucursal este Codigo [ '
                                        || rec_documentos_cab.codsuc
                                        || ' ] ';
                PIPE ROW ( reg_errores );
        END;

        RETURN;
    END valida_objeto;

    FUNCTION valida_objeto_detalle (
        pin_id_cia IN NUMBER,
        pin_datos  IN CLOB
    ) RETURN datatable
        PIPELINED
    AS

        reg_errores        r_errores := r_errores(NULL, NULL);
        o                  json_object_t;
        rec_documentos_cab documentos_cab%rowtype;
        rec_documentos_det documentos_det%rowtype;
        rec_kardex         kardex%rowtype;
        v_cuenta           pcuentas.cuenta%TYPE;
        v_codcli           cliente.codcli%TYPE;
        v_codart           articulos.codart%TYPE;
        v_codsuc           sucursal.codsuc%TYPE;
        v_count            NUMBER;
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_documentos_det.numint := o.get_number('numint');
        rec_documentos_det.numite := o.get_number('numite');
        rec_documentos_det.tipinv := o.get_number('tipinv');
        rec_documentos_det.codart := o.get_string('codart');

    -- VALIDAMOS QUE NO EXISTA EL ITEM
        BEGIN
            BEGIN
                SELECT
                    COUNT(0)
                INTO v_count
                FROM
                    documentos_det
                WHERE
                        id_cia = pin_id_cia
                    AND numint = rec_documentos_det.numint
                    AND numite = rec_documentos_det.numite;

            EXCEPTION
                WHEN no_data_found THEN
                    v_count := 0;
            END;

            IF v_count > 0 THEN
                reg_errores.valor := rec_documentos_det.numint;
                reg_errores.deserror := 'El Documento con NUMINT [ '
                                        || rec_documentos_det.numint
                                        || ' ] y NUMITE [ '
                                        || rec_documentos_det.numite
                                        || ' ] ya existe y no puede duplicarse.';

                PIPE ROW ( reg_errores );
            END IF;

        END;

    -- VALIDAMOS QUE EXISTA EL TIPO DE INVENTARIO
        BEGIN
            SELECT
                0
            INTO v_count
            FROM
                t_inventario
            WHERE
                    id_cia = pin_id_cia
                AND tipinv = rec_documentos_det.tipinv;

        EXCEPTION
            WHEN no_data_found THEN
                reg_errores.valor := rec_documentos_det.codart;
                reg_errores.deserror := 'No Existe el Tipo de Inventario [ '
                                        || rec_documentos_det.tipinv
                                        || ' ] ';
                PIPE ROW ( reg_errores );
        END;

        IF rec_documentos_det.codart IS NULL THEN
            reg_errores.valor := 'ND';
            reg_errores.deserror := 'No se ingreso el Codigo del Articulo';
            PIPE ROW ( reg_errores );
        END IF;

    -- VALIDAMOS SI EXISTE EL INVENTARIO Y EL ARTICULO
--        BEGIN
--            SELECT
--                codart
--            INTO v_codart
--            FROM
--                articulos
--            WHERE
--                    id_cia = pin_id_cia
--                AND tipinv = rec_documentos_det.tipinv
--                AND codart = rec_documentos_det.codart;
--
--        EXCEPTION
--            WHEN no_data_found THEN
--                reg_errores.valor := rec_documentos_det.codart;
--                reg_errores.deserror := 'No Existe el Articulo con Codigo [ '
--                                        || rec_documentos_det.codart
--                                        || ' ] asociado al Tipo de Inventario [ '
--                                        || rec_documentos_det.tipinv
--                                        || ' ] ';
--
--                PIPE ROW ( reg_errores );
--        END;

        RETURN;
    END valida_objeto_detalle;

    PROCEDURE importa_kardex (
        pin_id_cia  IN NUMBER,
        pin_usuari  IN VARCHAR2,
        pin_datos   IN CLOB,
        pin_mensaje OUT VARCHAR2
    ) AS
        o                  json_object_t;
        rec_documentos_cab documentos_cab%rowtype;
        rec_documentos_det documentos_det%rowtype;
        rec_kardex         kardex%rowtype;
    BEGIN
        o := json_object_t.parse(pin_datos);
        -- DOCUMENTOS_CAB
        rec_documentos_cab.id_cia := pin_id_cia;
        rec_documentos_cab.numint := o.get_number('numint') * -1; -- NUMERO INTERNO
        rec_documentos_cab.tipdoc := o.get_number('tipdoc'); -- TIPO DE DOCUMENTO
        rec_documentos_cab.series := o.get_string('series'); -- SERIE
        rec_documentos_cab.numdoc := o.get_number('numdoc'); -- NUMERO
        rec_documentos_cab.femisi := o.get_date('femisi'); -- FECHA DE EMISION
        rec_documentos_cab.lugemi := 2;
        rec_documentos_cab.situac := 'F';
        rec_documentos_cab.codcli := o.get_string('codcli');-- CODIGO DE CLIENTE
        rec_documentos_cab.razonc := o.get_string('razonc'); -- RAZON SOCIAL
        rec_documentos_cab.direc1 := '';
        rec_documentos_cab.tipmon := o.get_string('tipmon'); -- MONEDA
        rec_documentos_cab.tipcam := o.get_number('tipcam'); -- TIPO DE CAMBIO
        rec_documentos_cab.codmot := o.get_number('codmot'); -- CODIGO DE MOTIVO
        rec_documentos_cab.motdoc := 0;
        rec_documentos_cab.codalm := o.get_number('codalm');
        rec_documentos_cab.almdes := '';
        rec_documentos_cab.codsuc := o.get_number('codsuc'); -- CODIGO DE SUCURSAL
        rec_documentos_cab.id := o.get_string('id'); --ID
        rec_documentos_cab.incigv := o.get_string('incigv'); -- INC IGV?
        rec_documentos_cab.observ := o.get_string('observ'); --OBSERVACION
        rec_documentos_cab.usuari := pin_usuari;
        rec_documentos_cab.fcreac := rec_documentos_cab.femisi;
        rec_documentos_cab.factua := rec_documentos_cab.femisi;

        -- EXTRAYENDO DATOS DEL CODCLI 
        BEGIN
            SELECT
                tident,
                dident
            INTO
                rec_documentos_cab.tident,
                rec_documentos_cab.ruc
            FROM
                cliente
            WHERE
                    id_cia = pin_id_cia
                AND codcli = rec_documentos_cab.codcli;

        EXCEPTION
            WHEN no_data_found THEN
                INSERT INTO cliente (
                    id_cia,
                    codcli,
                    razonc,
                    situac,
                    usuari,
                    fcreac,
                    factua
                ) VALUES (
                    pin_id_cia,
                    rec_documentos_cab.codcli,
                    rec_documentos_cab.razonc,
                    'M',
                    rec_documentos_cab.usuari,
                    current_timestamp,
                    current_timestamp
                );

        END;

        INSERT INTO documentos_cab (
            id_cia,
            numint,
            tipdoc,
            series,
            numdoc,
            femisi,
            lugemi,
            situac,
            id,
            codmot,
            motdoc,
            codalm,
            almdes,
            codcli,
            tident,
            ruc,
            razonc,
            direc1,
            tipmon,
            tipcam,
            incigv,
            monafe,
            monina,
            monexo,
            monigv,
            totbru,
            ucreac,
            usuari,
            fcreac,
            factua
        ) VALUES (
            rec_documentos_cab.id_cia,
            rec_documentos_cab.numint,
            rec_documentos_cab.tipdoc,
            rec_documentos_cab.series,
            rec_documentos_cab.numdoc,
            rec_documentos_cab.femisi,
            rec_documentos_cab.lugemi,
            rec_documentos_cab.situac,
            rec_documentos_cab.id,
            rec_documentos_cab.codmot,
            rec_documentos_cab.motdoc,
            rec_documentos_cab.codalm,
            rec_documentos_cab.almdes,
            rec_documentos_cab.codcli,
            rec_documentos_cab.tident,
            rec_documentos_cab.ruc,
            rec_documentos_cab.razonc,
            rec_documentos_cab.direc1,
            rec_documentos_cab.tipmon,
            rec_documentos_cab.tipcam,
            rec_documentos_cab.incigv,
            0,
            0,
            0,
            0,
            0,
            rec_documentos_cab.ucreac,
            rec_documentos_cab.usuari,
            rec_documentos_cab.fcreac,
            rec_documentos_cab.factua
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
                    'status' VALUE 1.0,
                    'message' VALUE 'El Documento con NUMINT [ '
                                    || rec_documentos_cab.numint
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

    END importa_kardex;

    PROCEDURE importa_kardex_detallado (
        pin_id_cia  IN NUMBER,
        pin_usuari  IN VARCHAR2,
        pin_datos   IN CLOB,
        pin_mensaje OUT VARCHAR2
    ) AS

        o                  json_object_t;
        rec_documentos_cab documentos_cab%rowtype;
        rec_documentos_det documentos_det%rowtype;
        rec_kardex         kardex%rowtype;
        v_descri           VARCHAR2(1000 CHAR);
        v_codart           VARCHAR2(1000 CHAR);
    BEGIN
        o := json_object_t.parse(pin_datos);
        -- DOCUMENTOS_CAB
        rec_documentos_cab.id_cia := pin_id_cia;
        rec_documentos_cab.numint := o.get_number('numint') * -1; -- NUMERO INTERNO
        rec_documentos_cab.tipdoc := o.get_number('tipdoc'); -- TIPO DE DOCUMENTO
        rec_documentos_cab.series := o.get_string('series'); -- SERIE
        rec_documentos_cab.numdoc := o.get_number('numdoc'); -- NUMERO
        rec_documentos_cab.femisi := o.get_date('femisi'); -- FECHA DE EMISION
        rec_documentos_cab.lugemi := 2;
        rec_documentos_cab.situac := 'F';
        rec_documentos_cab.codcli := o.get_string('codcli');-- CODIGO DE CLIENTE
        rec_documentos_cab.razonc := o.get_string('razonc'); -- RAZON SOCIAL
        rec_documentos_cab.tipmon := o.get_string('tipmon'); -- MONEDA
        rec_documentos_cab.tipcam := o.get_number('tipcam'); -- TIPO DE CAMBIO
        rec_documentos_cab.codmot := o.get_number('codmot'); -- CODIGO DE MOTIVO
--        rec_documentos_cab.motdoc
        rec_documentos_cab.codalm := o.get_number('codalm');
        rec_documentos_cab.almdes := '';
        rec_documentos_cab.codsuc := o.get_number('codsuc'); -- CODIGO DE SUCURSAL
        rec_documentos_cab.id := o.get_string('id'); --ID
        rec_documentos_cab.incigv := o.get_string('incigv'); -- INC IGV?
        rec_documentos_cab.observ := o.get_string('observ'); --OBSERVACION
        rec_documentos_cab.usuari := pin_usuari;
        rec_documentos_cab.fcreac := rec_documentos_cab.femisi;
        rec_documentos_cab.factua := rec_documentos_cab.femisi;

        --- DOCUMENTOS DET
        rec_documentos_det.id_cia := pin_id_cia;
        rec_documentos_det.numint := rec_documentos_cab.numint;
        rec_documentos_det.tipdoc := rec_documentos_cab.tipdoc;
        rec_documentos_det.series := rec_documentos_cab.series;
        rec_documentos_det.situac := 'F';
        rec_documentos_det.numite := o.get_number('numite'); --ITEM
        rec_documentos_det.tipinv := o.get_number('tipinv'); --TIPO DE INVENTARIO
        rec_documentos_det.codart := o.get_string('codart'); --CODIGO DE ARTICULO   
        v_descri := o.get_string('desart');
        rec_documentos_det.codalm := o.get_number('codalm'); -- CODIGO DE ALMACEN
        rec_documentos_det.codund := o.get_string('coduni'); -- CODIGO DE UNIDAD
        rec_documentos_det.cantid := o.get_number('cantid'); -- CANTIDAD
        rec_documentos_det.preuni := o.get_number('preuni'); -- PRECIO
        rec_documentos_det.monafe := o.get_number('monafe');
        rec_documentos_det.monina := o.get_number('monina');
        rec_documentos_det.monexo := o.get_number('monexo');
        rec_documentos_det.monigv := o.get_number('monigv');
        rec_documentos_det.importe_bruto := rec_documentos_det.monafe + rec_documentos_det.monina + rec_documentos_det.monexo;
        rec_documentos_det.importe := o.get_number('importe'); -- IMPORTE TOTAL
        rec_documentos_det.observ := o.get_string('observ'); --OBSERVACION
        rec_documentos_det.costot01 := o.get_number('costot01'); -- COSTO TOTAL SOLES
        rec_documentos_det.costot02 := o.get_number('costot02'); -- COSTO TOTAL DOLARES
        rec_documentos_det.usuari := pin_usuari;
        rec_documentos_det.fcreac := rec_documentos_cab.femisi;
        rec_documentos_det.factua := rec_documentos_cab.femisi;


        -- KARDEX
        rec_kardex.id_cia := pin_id_cia;
        rec_kardex.locali := -1;
        rec_kardex.id := rec_documentos_cab.id;
        rec_kardex.numint := rec_documentos_det.numint;
        rec_kardex.numite := rec_documentos_det.numite;
        rec_kardex.periodo := extract(YEAR FROM rec_documentos_cab.femisi) * 100 + extract(MONTH FROM rec_documentos_cab.femisi);

        rec_kardex.tipdoc := rec_documentos_cab.tipdoc;
        rec_kardex.codmot := rec_documentos_cab.codmot;  -- PREGUNTAR
        rec_kardex.femisi := rec_documentos_cab.femisi;
        rec_kardex.tipinv := rec_documentos_det.tipinv;
        rec_kardex.codart := rec_documentos_det.codart;
        rec_kardex.cantid := rec_documentos_det.cantid;
        rec_kardex.codalm := rec_documentos_det.codalm;
        rec_kardex.almdes := '';
        rec_kardex.costot01 := o.get_number('costot01'); -- COSTO TOTAL SOLES
        rec_kardex.costot02 := o.get_number('costot02'); -- COSTO TOTAL DOLARES
        rec_kardex.codcli := rec_documentos_cab.codcli;
        rec_kardex.tipcam := rec_documentos_cab.tipcam;
        rec_kardex.situac := 'F';
        rec_kardex.usuari := pin_usuari;
        rec_kardex.fcreac := rec_documentos_cab.femisi;
        rec_kardex.factua := rec_documentos_cab.femisi;
        BEGIN
            SELECT
                codart
            INTO v_codart
            FROM
                articulos
            WHERE
                    id_cia = pin_id_cia
                AND tipinv = rec_documentos_det.tipinv
                AND codart = rec_documentos_det.codart;

        EXCEPTION
            WHEN no_data_found THEN
                INSERT INTO articulos (
                    id_cia,
                    tipinv,
                    codart,
                    descri,
                    situac,
                    usuari,
                    fcreac,
                    factua
                ) VALUES (
                    rec_documentos_det.id_cia,
                    rec_documentos_det.tipinv,
                    rec_documentos_det.codart,
                    v_descri,
                    'M', --Migrado
                    rec_documentos_det.usuari,
                    current_timestamp,
                    current_timestamp
                );

                MERGE INTO articulos_clase ac9 --  CONFIGURA EL ARTICULO COMO INACTIVO
                USING dual ddd ON ( ac9.id_cia = rec_documentos_det.id_cia
                                    AND ac9.tipinv = rec_documentos_det.tipinv
                                    AND ac9.codart = rec_documentos_det.codart
                                    AND ac9.clase = 9 )
                WHEN MATCHED THEN UPDATE
                SET codigo = '0',
                    situac = 'S'
                WHERE
                        id_cia = rec_documentos_det.id_cia
                    AND tipinv = rec_documentos_det.tipinv
                    AND codart = rec_documentos_det.codart
                    AND clase = 9
                WHEN NOT MATCHED THEN
                INSERT (
                    id_cia,
                    tipinv,
                    codart,
                    clase,
                    codigo,
                    situac )
                VALUES
                    ( rec_documentos_det.id_cia,
                      rec_documentos_det.tipinv,
                      rec_documentos_det.codart,
                    9,
                    '0',
                    'S' );

        END;

        INSERT INTO documentos_det (
            id_cia,
            numint,
            numite,
            tipdoc,
            series,
            tipinv,
            codart,
            situac,
            codalm,
            cantid,
            canref,
            canped,
            saldo,
            pordes1,
            pordes2,
            pordes3,
            pordes4,
            preuni,
            codund,
            observ,
            monafe,
            monina,
            monexo,
            monigv,
            importe_bruto,
            importe,
            costot01,
            costot02,
            usuari,
            fcreac,
            factua
        ) VALUES (
            rec_documentos_det.id_cia,
            rec_documentos_det.numint,
            rec_documentos_det.numite,
            rec_documentos_det.tipdoc,
            rec_documentos_det.series,
            rec_documentos_det.tipinv,
            rec_documentos_det.codart,
            rec_documentos_det.situac,
            rec_documentos_det.codalm,
            rec_documentos_det.cantid,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            rec_documentos_det.preuni,
            rec_documentos_det.codund,
            rec_documentos_det.observ,
            rec_documentos_det.monafe,
            rec_documentos_det.monina,
            rec_documentos_det.monexo,
            rec_documentos_det.monigv,
            rec_documentos_det.importe_bruto,
            rec_documentos_det.importe,
            rec_documentos_det.costot01,
            rec_documentos_det.costot02,
            rec_documentos_det.usuari,
            rec_documentos_det.fcreac,
            rec_documentos_det.factua
        );

        INSERT INTO kardex (
            id_cia,
            locali,
            id,
            tipdoc,
            numint,
            numite,
            periodo,
            codmot,
            femisi,
            tipinv,
            codart,
            cantid,
            codalm,
            almdes,
            costot01,
            costot02,
            codcli,
            tipcam,
            situac,
            usuari,
            fcreac,
            factua
        ) VALUES (
            rec_kardex.id_cia,
            rec_kardex.locali,
            rec_kardex.id,
            rec_kardex.tipdoc,
            rec_kardex.numint,
            rec_kardex.numite,
            rec_kardex.periodo,
            rec_kardex.codmot,
            rec_kardex.femisi,
            rec_kardex.tipinv,
            rec_kardex.codart,
            rec_kardex.cantid,
            rec_kardex.codalm,
            rec_kardex.almdes,
            rec_kardex.costot01,
            rec_kardex.costot02,
            rec_kardex.codcli,
            rec_kardex.tipcam,
            rec_kardex.situac,
            rec_kardex.usuari,
            rec_kardex.fcreac,
            rec_kardex.factua
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
                    'status' VALUE 1.2,
                    'message' VALUE 'El Documento con NUMINT [ '
                                    || rec_documentos_det.numint
                                    || ' ] y NUMITE [ '
                                    || rec_documentos_det.numite
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

    END importa_kardex_detallado;

    PROCEDURE sp_actualiza_saldos (
        pin_id_cia  IN NUMBER,
        pin_usuari  IN VARCHAR2,
        pin_datos   IN CLOB,
        pin_mensaje OUT VARCHAR2
    ) AS

        o                  json_object_t;
        rec_documentos_cab documentos_cab%rowtype;
        rec_documentos_det documentos_det%rowtype;
        v_importe          NUMBER(24, 8);
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_documentos_cab.id_cia := pin_id_cia;
        rec_documentos_cab.numint := o.get_number('numint'); -- NUMERO INTERNO

        SELECT
            SUM(nvl(monafe, 0)),
            SUM(nvl(monina, 0)),
            SUM(nvl(monexo, 0)),
            SUM(nvl(monigv, 0)),
            SUM(nvl(importe_bruto, 0)),
            SUM(nvl(importe, 0))
        INTO
            rec_documentos_cab.monafe,
            rec_documentos_cab.monina,
            rec_documentos_cab.monexo,
            rec_documentos_cab.monigv,
            rec_documentos_cab.totbru,
            v_importe
        FROM
            documentos_det
        WHERE
                id_cia = pin_id_cia
            AND numint = rec_documentos_cab.numint;

        UPDATE documentos_cab
        SET
            monafe = rec_documentos_cab.monafe,
            monina = rec_documentos_cab.monina,
            monexo = rec_documentos_cab.monexo,
            monigv = rec_documentos_cab.monigv,
            totbru = rec_documentos_cab.totbru,
            preven = nvl(rec_documentos_cab.monafe, 0) + nvl(rec_documentos_cab.monina, 0) + nvl(rec_documentos_cab.monexo, 0) + nvl(
            rec_documentos_cab.totbru, 0)
        WHERE
                id_cia = pin_id_cia
            AND numint = rec_documentos_cab.numint;

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

    END sp_actualiza_saldos;

END;

/

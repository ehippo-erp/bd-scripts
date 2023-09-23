--------------------------------------------------------
--  DDL for Package Body PACK_DOCUMENTOS_MATERIALES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_DOCUMENTOS_MATERIALES" AS

    FUNCTION sp_obtener (
        pin_id_cia IN NUMBER,
        pin_numint IN NUMBER,
        pin_numite IN NUMBER,
        pin_numsec IN NUMBER
    ) RETURN datatable_documentos_materiales
        PIPELINED
    IS
        v_table datatable_documentos_materiales;
    BEGIN
        SELECT
            dm.id_cia,
            dm.numint,
            dm.numite,
            dm.numsec,
            dm.tipinv,
            dm.codart,
            dm.codalm,
            dm.cantid,
            dm.preuni,
            dm.pordes1,
            dm.pordes2,
            dm.pordes3,
            dm.pordes4,
            dm.largo,
            dm.ancho,
            dm.altura,
            dm.etapa,
            dm.etapauso,
            dm.observ,
            dm.stockref,
            dm.fstockref,
            dm.situac,
            dm.usuari,
            dm.fcreac,
            dm.factua,
            dm.codprv,
            dm.positi,
            dm.pedido,
            dm.cant_ojo,
            dm.cant_ojo_gcable,
            dm.codadd01,
            dm.codadd02,
            dm.swimporta,
            dm.pcosto,
            dm.cpordes1,
            dm.cpordes2,
            dm.cpordes3,
            dm.cpordes4,
            dm.swcompr,
            kk.stock,
            current_date AS fstock
        BULK COLLECT
        INTO v_table
        FROM
            documentos_materiales             dm
            LEFT OUTER JOIN sp000_saca_stock_costo_articulos_almacen(dm.id_cia,
                                                                     dm.tipinv,
                                                                     dm.codalm,
                                                                     dm.codart,
                                                                     EXTRACT(YEAR FROM current_date),
                                                                     EXTRACT(MONTH FROM current_date),
                                                                     EXTRACT(MONTH FROM current_date)) kk ON 0 = 0
        WHERE
                dm.id_cia = pin_id_cia
            AND dm.numint = pin_numint
            AND dm.numite = pin_numite
            AND dm.numsec = pin_numsec;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia IN NUMBER,
        pin_numint IN NUMBER,
        pin_numite IN NUMBER,
        pin_numsec IN NUMBER,
        pin_tipinv IN NUMBER,
        pin_codart IN VARCHAR2,
        pin_codalm IN NUMBER
    ) RETURN datatable_documentos_materiales
        PIPELINED
    IS
        v_table datatable_documentos_materiales;
    BEGIN
        SELECT
            dm.id_cia,
            dm.numint,
            dm.numite,
            dm.numsec,
            dm.tipinv,
            dm.codart,
            dm.codalm,
            dm.cantid,
            dm.preuni,
            dm.pordes1,
            dm.pordes2,
            dm.pordes3,
            dm.pordes4,
            dm.largo,
            dm.ancho,
            dm.altura,
            dm.etapa,
            dm.etapauso,
            dm.observ,
            dm.stockref,
            dm.fstockref,
            dm.situac,
            dm.usuari,
            dm.fcreac,
            dm.factua,
            dm.codprv,
            dm.positi,
            dm.pedido,
            dm.cant_ojo,
            dm.cant_ojo_gcable,
            dm.codadd01,
            dm.codadd02,
            dm.swimporta,
            dm.pcosto,
            dm.cpordes1,
            dm.cpordes2,
            dm.cpordes3,
            dm.cpordes4,
            dm.swcompr,
            kk.stock,
            current_date AS fstock
        BULK COLLECT
        INTO v_table
        FROM
            documentos_materiales             dm
            LEFT OUTER JOIN sp000_saca_stock_costo_articulos_almacen(dm.id_cia,
                                                                     dm.tipinv,
                                                                     dm.codalm,
                                                                     dm.codart,
                                                                     EXTRACT(YEAR FROM current_date),
                                                                     EXTRACT(MONTH FROM current_date),
                                                                     EXTRACT(MONTH FROM current_date)) kk ON 0 = 0
        WHERE
                dm.id_cia = pin_id_cia
            AND ( ( pin_numint = - 1
                    OR pin_numint IS NULL )
                  OR dm.numint = pin_numint )
            AND ( ( pin_numite = - 1
                    OR pin_numite IS NULL )
                  OR dm.numite = pin_numite )
            AND ( ( pin_numsec = - 1
                    OR pin_numsec IS NULL )
                  OR dm.numsec = pin_numsec )
            AND ( ( pin_tipinv = - 1
                    OR pin_tipinv IS NULL )
                  OR dm.tipinv = pin_tipinv )
            AND ( pin_codart IS NULL
                  OR dm.codart = pin_codart )
            AND ( ( pin_codalm = - 1
                    OR pin_codalm IS NULL )
                  OR dm.codalm = pin_codalm );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar;

--set SERVEROUTPUT on;
--
--DECLARE 
--mensaje VARCHAR2(500);
--cadjson VARCHAR2(5000);
--BEGIN
--    cadjson := '{
--        "numint":100,
--        "numite":100,
--        "numsec":100,
--        "tipinv":1,
--        "codart":"Articulo Prueba 01",
--        "codalm":100,
--        "cantid":100,
--        "preuni":100,
--        "pordes1":100,
--        "pordes2":100,
--        "pordes3":100,
--        "pordes4":100,
--        "largo":100,
--        "ancho":100,
--        "altura":100,
--        "etapa":100,
--        "etapauso":100,
--        "observ":"Prueba - Hola",
--        "stockref":100,
--        "fstockref":"",
--        "situac":"P",
--        "usuari":"ADMIN",
--        "codprv":"Prueba",
--        "positi":100,
--        "pedido":100,
--        "cant_ojo":100,
--        "cant_ojo_gcable":100,
--        "codadd01":"",
--        "codadd02":"",
--        "swimporta":"",
--        "pcosto":100,
--        "cpordes1":100,
--        "cpordes2":100,
--        "cpordes3":100,
--        "cpordes4":100,
--        "swcompr":"S"
--        }';
--        PACK_DOCUMENTOS_MATERIALES.SP_SAVE(100,cadjson,1,mensaje);
--        DBMS_OUTPUT.PUT_LINE(mensaje);
--END;
--
--select * from pack_documentos_materiales.sp_obtener(100,100,100,100);
--
--select * from pack_documentos_materiales.sp_buscar(100,100,100,100,-1,NULL,-1);


    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) IS
        o                         json_object_t;
        rec_documentos_materiales documentos_materiales%rowtype;
        v_accion                  VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_documentos_materiales.id_cia := pin_id_cia;
        rec_documentos_materiales.numint := o.get_number('numint');
        rec_documentos_materiales.numite := o.get_number('numite');
        rec_documentos_materiales.numsec := o.get_number('numsec');
        rec_documentos_materiales.tipinv := o.get_number('tipinv');
        rec_documentos_materiales.codart := o.get_string('codart');
        rec_documentos_materiales.codalm := o.get_number('codalm');
        rec_documentos_materiales.cantid := o.get_number('cantid');
        rec_documentos_materiales.preuni := o.get_number('preuni');
        rec_documentos_materiales.pordes1 := o.get_number('pordes1');
        rec_documentos_materiales.pordes2 := o.get_number('pordes2');
        rec_documentos_materiales.pordes3 := o.get_number('pordes3');
        rec_documentos_materiales.pordes4 := o.get_number('pordes4');
        rec_documentos_materiales.largo := o.get_number('largo');
        rec_documentos_materiales.ancho := o.get_number('ancho');
        rec_documentos_materiales.altura := o.get_number('altura');
        rec_documentos_materiales.etapa := o.get_number('etapa');
        rec_documentos_materiales.etapauso := o.get_number('etapauso');
        rec_documentos_materiales.observ := o.get_string('observ');
        rec_documentos_materiales.stockref := o.get_number('stockref');
        rec_documentos_materiales.fstockref := o.get_timestamp('fstockref');
        rec_documentos_materiales.situac := o.get_string('situac');
        rec_documentos_materiales.codprv := o.get_string('codprv');
        rec_documentos_materiales.positi := o.get_number('positi');
        rec_documentos_materiales.pedido := o.get_number('pedido');
        rec_documentos_materiales.cant_ojo := o.get_number('cant_ojo');
        rec_documentos_materiales.cant_ojo_gcable := o.get_number('cant_ojo_gcable');
        rec_documentos_materiales.codadd01 := o.get_string('codadd01');
        rec_documentos_materiales.codadd02 := o.get_string('codadd02');
        rec_documentos_materiales.swimporta := o.get_string('swimporta');
        rec_documentos_materiales.pcosto := o.get_number('pcosto');
        rec_documentos_materiales.cpordes1 := o.get_number('cpordes1');
        rec_documentos_materiales.cpordes2 := o.get_number('cpordes2');
        rec_documentos_materiales.cpordes3 := o.get_number('cpordes3');
        rec_documentos_materiales.cpordes4 := o.get_number('cpordes4');
        rec_documentos_materiales.swcompr := o.get_string('swcompr');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                BEGIN
                    SELECT
                        nvl(dm.numsec, 0) + 1
                    INTO rec_documentos_materiales.numsec
                    FROM
                        documentos_materiales dm
                    WHERE
                            id_cia = rec_documentos_materiales.id_cia
                        AND numint = rec_documentos_materiales.numint
                        AND numite = rec_documentos_materiales.numite
                    ORDER BY
                        dm.numsec DESC
                    FETCH NEXT 1 ROWS ONLY;

                EXCEPTION
                    WHEN no_data_found THEN
                        rec_documentos_materiales.numsec := 1;
                END;

                INSERT INTO documentos_materiales (
                    id_cia,
                    numint,
                    numite,
                    numsec,
                    tipinv,
                    codart,
                    codalm,
                    cantid,
                    preuni,
                    pordes1,
                    pordes2,
                    pordes3,
                    pordes4,
                    largo,
                    ancho,
                    altura,
                    etapa,
                    etapauso,
                    observ,
                    stockref,
                    fstockref,
                    situac,
                    usuari,
                    fcreac,
                    factua,
                    codprv,
                    positi,
                    pedido,
                    cant_ojo,
                    cant_ojo_gcable,
                    codadd01,
                    codadd02,
                    swimporta,
                    pcosto,
                    cpordes1,
                    cpordes2,
                    cpordes3,
                    cpordes4,
                    swcompr
                ) VALUES (
                    rec_documentos_materiales.id_cia,
                    rec_documentos_materiales.numint,
                    rec_documentos_materiales.numite,
                    rec_documentos_materiales.numsec,
                    rec_documentos_materiales.tipinv,
                    rec_documentos_materiales.codart,
                    rec_documentos_materiales.codalm,
                    rec_documentos_materiales.cantid,
                    rec_documentos_materiales.preuni,
                    rec_documentos_materiales.pordes1,
                    rec_documentos_materiales.pordes2,
                    rec_documentos_materiales.pordes3,
                    rec_documentos_materiales.pordes4,
                    rec_documentos_materiales.largo,
                    rec_documentos_materiales.ancho,
                    rec_documentos_materiales.altura,
                    rec_documentos_materiales.etapa,
                    rec_documentos_materiales.etapauso,
                    rec_documentos_materiales.observ,
                    rec_documentos_materiales.stockref,
                    rec_documentos_materiales.fstockref,
                    rec_documentos_materiales.situac,
                    rec_documentos_materiales.usuari,
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS'),
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS'),
                    rec_documentos_materiales.codprv,
                    rec_documentos_materiales.positi,
                    rec_documentos_materiales.pedido,
                    rec_documentos_materiales.cant_ojo,
                    rec_documentos_materiales.cant_ojo_gcable,
                    rec_documentos_materiales.codadd01,
                    rec_documentos_materiales.codadd02,
                    rec_documentos_materiales.swimporta,
                    rec_documentos_materiales.pcosto,
                    rec_documentos_materiales.cpordes1,
                    rec_documentos_materiales.cpordes2,
                    rec_documentos_materiales.cpordes3,
                    rec_documentos_materiales.cpordes4,
                    rec_documentos_materiales.swcompr
                );

                COMMIT;
            WHEN 2 THEN
                v_accion := 'La actualización';
                UPDATE documentos_materiales
                SET
                    tipinv =
                        CASE
                            WHEN rec_documentos_materiales.tipinv IS NULL THEN
                                tipinv
                            ELSE
                                rec_documentos_materiales.tipinv
                        END,
                    codart =
                        CASE
                            WHEN rec_documentos_materiales.codart IS NULL THEN
                                codart
                            ELSE
                                rec_documentos_materiales.codart
                        END,
                    codalm =
                        CASE
                            WHEN rec_documentos_materiales.codalm IS NULL THEN
                                codalm
                            ELSE
                                rec_documentos_materiales.codalm
                        END,
                    cantid =
                        CASE
                            WHEN rec_documentos_materiales.cantid IS NULL THEN
                                cantid
                            ELSE
                                rec_documentos_materiales.cantid
                        END,
                    preuni =
                        CASE
                            WHEN rec_documentos_materiales.preuni IS NULL THEN
                                preuni
                            ELSE
                                rec_documentos_materiales.preuni
                        END,
                    pordes1 =
                        CASE
                            WHEN rec_documentos_materiales.pordes1 IS NULL THEN
                                pordes1
                            ELSE
                                rec_documentos_materiales.pordes1
                        END,
                    pordes2 =
                        CASE
                            WHEN rec_documentos_materiales.pordes2 IS NULL THEN
                                pordes2
                            ELSE
                                rec_documentos_materiales.pordes2
                        END,
                    pordes3 =
                        CASE
                            WHEN rec_documentos_materiales.pordes3 IS NULL THEN
                                pordes3
                            ELSE
                                rec_documentos_materiales.pordes3
                        END,
                    pordes4 =
                        CASE
                            WHEN rec_documentos_materiales.pordes4 IS NULL THEN
                                pordes4
                            ELSE
                                rec_documentos_materiales.pordes4
                        END,
                    largo =
                        CASE
                            WHEN rec_documentos_materiales.largo IS NULL THEN
                                largo
                            ELSE
                                rec_documentos_materiales.largo
                        END,
                    ancho =
                        CASE
                            WHEN rec_documentos_materiales.ancho IS NULL THEN
                                ancho
                            ELSE
                                rec_documentos_materiales.ancho
                        END,
                    altura =
                        CASE
                            WHEN rec_documentos_materiales.altura IS NULL THEN
                                altura
                            ELSE
                                rec_documentos_materiales.altura
                        END,
                    etapa =
                        CASE
                            WHEN rec_documentos_materiales.etapa IS NULL THEN
                                etapa
                            ELSE
                                rec_documentos_materiales.etapa
                        END,
                    etapauso =
                        CASE
                            WHEN rec_documentos_materiales.etapauso IS NULL THEN
                                etapauso
                            ELSE
                                rec_documentos_materiales.etapauso
                        END,
                    observ =
                        CASE
                            WHEN rec_documentos_materiales.observ IS NULL THEN
                                observ
                            ELSE
                                rec_documentos_materiales.observ
                        END,
                    stockref =
                        CASE
                            WHEN rec_documentos_materiales.stockref IS NULL THEN
                                stockref
                            ELSE
                                rec_documentos_materiales.stockref
                        END,
                    fstockref =
                        CASE
                            WHEN rec_documentos_materiales.fstockref IS NULL THEN
                                fstockref
                            ELSE
                                rec_documentos_materiales.fstockref
                        END,
                    situac =
                        CASE
                            WHEN rec_documentos_materiales.situac IS NULL THEN
                                situac
                            ELSE
                                rec_documentos_materiales.situac
                        END,
                    usuari =
                        CASE
                            WHEN rec_documentos_materiales.usuari IS NULL THEN
                                usuari
                            ELSE
                                rec_documentos_materiales.usuari
                        END,
                    codprv =
                        CASE
                            WHEN rec_documentos_materiales.codprv IS NULL THEN
                                codprv
                            ELSE
                                rec_documentos_materiales.codprv
                        END,
                    positi =
                        CASE
                            WHEN rec_documentos_materiales.positi IS NULL THEN
                                positi
                            ELSE
                                rec_documentos_materiales.positi
                        END,
                    pedido =
                        CASE
                            WHEN rec_documentos_materiales.pedido IS NULL THEN
                                pedido
                            ELSE
                                rec_documentos_materiales.pedido
                        END,
                    cant_ojo =
                        CASE
                            WHEN rec_documentos_materiales.cant_ojo IS NULL THEN
                                cant_ojo
                            ELSE
                                rec_documentos_materiales.cant_ojo
                        END,
                    cant_ojo_gcable =
                        CASE
                            WHEN rec_documentos_materiales.cant_ojo_gcable IS NULL THEN
                                cant_ojo_gcable
                            ELSE
                                rec_documentos_materiales.cant_ojo_gcable
                        END,
                    codadd01 =
                        CASE
                            WHEN rec_documentos_materiales.codadd01 IS NULL THEN
                                codadd01
                            ELSE
                                rec_documentos_materiales.codadd01
                        END,
                    codadd02 =
                        CASE
                            WHEN rec_documentos_materiales.codadd02 IS NULL THEN
                                codadd02
                            ELSE
                                rec_documentos_materiales.codadd02
                        END,
                    swimporta =
                        CASE
                            WHEN rec_documentos_materiales.swimporta IS NULL THEN
                                swimporta
                            ELSE
                                rec_documentos_materiales.swimporta
                        END,
                    pcosto =
                        CASE
                            WHEN rec_documentos_materiales.pcosto IS NULL THEN
                                pcosto
                            ELSE
                                rec_documentos_materiales.pcosto
                        END,
                    cpordes1 =
                        CASE
                            WHEN rec_documentos_materiales.cpordes1 IS NULL THEN
                                cpordes1
                            ELSE
                                rec_documentos_materiales.cpordes1
                        END,
                    cpordes2 =
                        CASE
                            WHEN rec_documentos_materiales.cpordes2 IS NULL THEN
                                cpordes2
                            ELSE
                                rec_documentos_materiales.cpordes2
                        END,
                    cpordes3 =
                        CASE
                            WHEN rec_documentos_materiales.cpordes3 IS NULL THEN
                                cpordes3
                            ELSE
                                rec_documentos_materiales.cpordes3
                        END,
                    cpordes4 =
                        CASE
                            WHEN rec_documentos_materiales.cpordes4 IS NULL THEN
                                cpordes4
                            ELSE
                                rec_documentos_materiales.cpordes4
                        END,
                    swcompr =
                        CASE
                            WHEN rec_documentos_materiales.swcompr IS NULL THEN
                                swcompr
                            ELSE
                                rec_documentos_materiales.swcompr
                        END,
                    factua = TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
             'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_documentos_materiales.id_cia
                    AND numint = rec_documentos_materiales.numint
                    AND numite = rec_documentos_materiales.numite
                    AND numsec = rec_documentos_materiales.numsec;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM documentos_materiales
                WHERE
                        id_cia = rec_documentos_materiales.id_cia
                    AND numint = rec_documentos_materiales.numint
                    AND numite = rec_documentos_materiales.numite
                    AND numsec = rec_documentos_materiales.numsec;

                COMMIT;
            WHEN 5 THEN
                v_accion := 'La eliminación';
                DELETE FROM documentos_materiales
                WHERE
                        id_cia = rec_documentos_materiales.id_cia
                    AND numint = rec_documentos_materiales.numint
                    AND numite = rec_documentos_materiales.numite;

                COMMIT;
            WHEN 6 THEN
                v_accion := 'La eliminación';
                DELETE FROM documentos_materiales
                WHERE
                        id_cia = rec_documentos_materiales.id_cia
                    AND numint = rec_documentos_materiales.numint;

                COMMIT;
        END CASE;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE v_accion || ' se realizó satisfactoriamente...!'
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
        WHEN dup_val_on_index THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE 'El registro con numero interno [ '
                                    || rec_documentos_materiales.numint
                                    || ' ], numero item [ '
                                    || rec_documentos_materiales.numite
                                    || ' ] y numero de secuencia [ '
                                    || rec_documentos_materiales.numsec
                                    || ' ] ya existe y no puede duplicarse ...!'
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN value_error THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE 'El registro execede el limite permitido por el campo y/o se encuentra en un formato incorrecto'
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

    END;

END;

/

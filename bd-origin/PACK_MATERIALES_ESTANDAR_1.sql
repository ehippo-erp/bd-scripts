--------------------------------------------------------
--  DDL for Package Body PACK_MATERIALES_ESTANDAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_MATERIALES_ESTANDAR" AS

    FUNCTION sp_obtener (
        pin_id_cia      IN NUMBER,
        pin_tipinvpro   IN NUMBER,
        pin_codartpro   IN VARCHAR2,
        pin_codclase    IN VARCHAR2,
        pin_codadd01pro IN VARCHAR2,
        pin_codadd02pro IN VARCHAR2,
        pin_item        IN NUMBER
    ) RETURN datatable_materiales_estandar
        PIPELINED
    IS
        v_table datatable_materiales_estandar;
    BEGIN
        SELECT
            me.id_cia,
            me.tipinvpro,
            tpro.dtipinv,
            me.codartpro,
            apro.descri,
            me.codclase,
            me.codadd01pro,
            me.codadd02pro,
            me.item,
            me.tipinvstd,
            tstd.dtipinv,
            me.codartstd,
            astd.descri,
            me.etapa,
            me.etapauso,
            me.acabado,
            me.largo,
            me.ancho,
            me.factor,
            me.cantid,
            me.glosa,
            me.codaux,
            me.swacti,
            me.fcreac,
            me.factua,
            me.usuari,
            me.cant_ojo,
            me.cant_ojo_gcable,
            me.codadd01std,
            me.codadd02std,
            kk.stock,
            current_date AS fstock
        BULK COLLECT
        INTO v_table
        FROM
            materiales_estandar               me
            LEFT OUTER JOIN t_inventario                      tpro ON tpro.id_cia = me.id_cia
                                                 AND tpro.tipinv = me.tipinvpro
            LEFT OUTER JOIN articulos                         apro ON apro.id_cia = me.id_cia
                                              AND apro.tipinv = me.tipinvpro
                                              AND apro.codart = me.codartpro
            LEFT OUTER JOIN t_inventario                      tstd ON tstd.id_cia = me.id_cia
                                                 AND tstd.tipinv = me.tipinvstd
            LEFT OUTER JOIN articulos                         astd ON astd.id_cia = me.id_cia
                                              AND astd.tipinv = me.tipinvstd
                                              AND astd.codart = me.codartstd
            LEFT OUTER JOIN sp000_saca_stock_costo_articulos_almacen(me.id_cia,
                                                                     me.tipinvstd,
                                                                     0,
                                                                     me.codartstd,
                                                                     EXTRACT(YEAR FROM current_date),
                                                                     EXTRACT(MONTH FROM current_date),
                                                                     EXTRACT(MONTH FROM current_date)) kk ON 0 = 0
        WHERE
                me.id_cia = pin_id_cia
            AND me.tipinvpro = pin_tipinvpro
            AND me.codartpro = pin_codartpro
            AND me.codclase = pin_codclase
            AND me.codadd01pro = pin_codadd01pro
            AND me.codadd02pro = pin_codadd02pro
            AND me.item = pin_item;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia      IN NUMBER,
        pin_tipinvpro   IN NUMBER,
        pin_codartpro   IN VARCHAR2,
        pin_codclase    IN VARCHAR2,
        pin_codadd01pro IN VARCHAR2,
        pin_codadd02pro IN VARCHAR2,
        pin_item        IN NUMBER,
        pin_tipinvstd   IN NUMBER,
        pin_codartstd   IN VARCHAR2,
        pin_etapa       IN NUMBER,
        pin_swacti      IN VARCHAR2
    ) RETURN datatable_materiales_estandar
        PIPELINED
    IS
        v_table datatable_materiales_estandar;
    BEGIN
        SELECT
            me.id_cia,
            me.tipinvpro,
            tpro.dtipinv,
            me.codartpro,
            apro.descri,
            me.codclase,
            me.codadd01pro,
            me.codadd02pro,
            me.item,
            me.tipinvstd,
            tstd.dtipinv,
            me.codartstd,
            astd.descri,
            me.etapa,
            me.etapauso,
            me.acabado,
            me.largo,
            me.ancho,
            me.factor,
            me.cantid,
            me.glosa,
            me.codaux,
            me.swacti,
            me.fcreac,
            me.factua,
            me.usuari,
            me.cant_ojo,
            me.cant_ojo_gcable,
            me.codadd01std,
            me.codadd02std,
            kk.stock,
            current_date AS fstock
        BULK COLLECT
        INTO v_table
        FROM
            materiales_estandar               me
            LEFT OUTER JOIN t_inventario                      tpro ON tpro.id_cia = me.id_cia
                                                 AND tpro.tipinv = me.tipinvpro
            LEFT OUTER JOIN articulos                         apro ON apro.id_cia = me.id_cia
                                              AND apro.tipinv = me.tipinvpro
                                              AND apro.codart = me.codartpro
            LEFT OUTER JOIN t_inventario                      tstd ON tstd.id_cia = me.id_cia
                                                 AND tstd.tipinv = me.tipinvstd
            LEFT OUTER JOIN articulos                         astd ON astd.id_cia = me.id_cia
                                              AND astd.tipinv = me.tipinvstd
                                              AND astd.codart = me.codartstd
            LEFT OUTER JOIN sp000_saca_stock_costo_articulos_almacen(me.id_cia,
                                                                     me.tipinvstd,
                                                                     0,
                                                                     me.codartstd,
                                                                     EXTRACT(YEAR FROM current_date),
                                                                     EXTRACT(MONTH FROM current_date),
                                                                     EXTRACT(MONTH FROM current_date)) kk ON 0 = 0
        WHERE
                me.id_cia = pin_id_cia
            AND ( me.tipinvpro = pin_tipinvpro
                  OR ( pin_tipinvpro = - 1
                       OR pin_tipinvpro IS NULL ) )
            AND ( me.codartpro = pin_codartpro
                  OR pin_codartpro IS NULL )
            AND ( me.codclase = pin_codclase
                  OR pin_codclase IS NULL )
            AND ( me.codadd01pro = pin_codadd01pro
                  OR pin_codadd01pro IS NULL )
            AND ( me.codadd02pro = pin_codadd02pro
                  OR pin_codadd02pro IS NULL )
            AND ( me.item = pin_item
                  OR ( pin_item IS NULL
                       OR pin_item = - 1 ) )
            AND ( me.tipinvstd = pin_tipinvstd
                  OR ( pin_tipinvstd = - 1
                       OR pin_tipinvstd IS NULL ) )
            AND ( me.codartstd = pin_codartstd
                  OR pin_codartstd IS NULL )
            AND ( me.etapa = pin_etapa
                  OR ( pin_etapa = - 1
                       OR pin_etapa IS NULL ) )
            AND ( me.swacti = pin_swacti
                  OR pin_swacti IS NULL );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar;

--set SERVEROUTPUT on;
--
--DECLARE
--    mensaje VARCHAR2(500);
--    cadjson VARCHAR2(5000);
--BEGIN
--cadjson := '{
--                "tipinvpro":100,
--                "codartpro":"P0010",
--                "codclase":"100",
--                "codadd01pro":"100",
--                "codadd02pro":"100",
--                "item":100,
--                "tipinvstd":100,
--                "codartstd":"P0010",
--                "etapa":100,
--                "estapauso":100,
--                "acabado":100,
--                "largo":100,
--                "ancho":100,
--                "factor":100,
--                "cantid":100,
--                "glosa":"PRUBA", 
--                "codaux":"PPP",
--                "swacti":"S",
--                "usuari":"ADMIN",
--                "cant_ojo":100,
--                "cant_ojo_gcacle":100,
--                "codadd01std":"P100PRUEBA",
--                "codadd02std":"P100PRUEBA"
--                }';
--    pack_materiales_estandar.sp_save(100, cadjson, 3, mensaje);
--    dbms_output.put_line(mensaje);
--END;
--
--select * from pack_materiales_estandar.sp_obtener(100,100,'P0010','100',100,100,100);
--
--select * from pack_materiales_estandar.sp_buscar(100,100,'P0010','100',100,100,100,-1,NULL,-1,NULL);

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) IS
        o                       json_object_t;
        rec_materiales_estandar materiales_estandar%rowtype;
        v_accion                VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_materiales_estandar.id_cia := pin_id_cia;
        rec_materiales_estandar.tipinvpro := o.get_number('tipinvpro');
        rec_materiales_estandar.codartpro := o.get_string('codartpro');
        rec_materiales_estandar.codclase := o.get_string('codclase');
        rec_materiales_estandar.codadd01pro := o.get_string('codadd01pro');
        rec_materiales_estandar.codadd02pro := o.get_string('codadd02pro');
        rec_materiales_estandar.item := o.get_number('item');
        rec_materiales_estandar.tipinvstd := o.get_number('tipinvstd');
        rec_materiales_estandar.codartstd := o.get_string('codartstd');
        rec_materiales_estandar.etapa := o.get_number('etapa');
        rec_materiales_estandar.etapauso := o.get_number('etapauso');
        rec_materiales_estandar.acabado := o.get_string('acabado');
        rec_materiales_estandar.largo := o.get_number('largo');
        rec_materiales_estandar.ancho := o.get_number('ancho');
        rec_materiales_estandar.factor := o.get_number('factor');
        rec_materiales_estandar.cantid := o.get_number('cantid');
        rec_materiales_estandar.glosa := o.get_string('glosa');
        rec_materiales_estandar.codaux := o.get_string('codaux');
        rec_materiales_estandar.swacti := o.get_string('swacti');
        rec_materiales_estandar.usuari := o.get_string('usuari');
        rec_materiales_estandar.cant_ojo := o.get_string('cant_ojo');
        rec_materiales_estandar.cant_ojo_gcable := o.get_string('cant_ojo_gcacle');
        rec_materiales_estandar.codadd01std := o.get_string('codadd01std');
        rec_materiales_estandar.codadd02std := o.get_string('codadd02std');
        v_accion := 'La grabación';
        CASE pin_opcdml
            WHEN 1 THEN
                BEGIN
                    SELECT
                        nvl(item, 0) + 1
                    INTO rec_materiales_estandar.item
                    FROM
                        materiales_estandar
                    WHERE
                            id_cia = rec_materiales_estandar.id_cia
                        AND tipinvpro = rec_materiales_estandar.tipinvpro
                        AND codartpro = rec_materiales_estandar.codartpro
                        AND codclase = rec_materiales_estandar.codclase
                        AND codadd01pro = rec_materiales_estandar.codadd01pro
                        AND codadd02pro = rec_materiales_estandar.codadd02pro
                    ORDER BY
                        item DESC
                    FETCH NEXT 1 ROWS ONLY;

                EXCEPTION
                    WHEN no_data_found THEN
                        rec_materiales_estandar.item := 1;
                END;

                INSERT INTO materiales_estandar (
                    id_cia,
                    tipinvpro,
                    codartpro,
                    codclase,
                    codadd01pro,
                    codadd02pro,
                    item,
                    tipinvstd,
                    codartstd,
                    etapa,
                    etapauso,
                    largo,
                    ancho,
                    factor,
                    cantid,
                    glosa,
                    codaux,
                    swacti,
                    usuari,
                    cant_ojo,
                    cant_ojo_gcable,
                    codadd01std,
                    codadd02std,
                    fcreac,
                    factua
                ) VALUES (
                    rec_materiales_estandar.id_cia,
                    rec_materiales_estandar.tipinvpro,
                    rec_materiales_estandar.codartpro,
                    rec_materiales_estandar.codclase,
                    rec_materiales_estandar.codadd01pro,
                    rec_materiales_estandar.codadd02pro,
                    rec_materiales_estandar.item,
                    rec_materiales_estandar.tipinvstd,
                    rec_materiales_estandar.codartstd,
                    rec_materiales_estandar.etapa,
                    rec_materiales_estandar.etapauso,
                    rec_materiales_estandar.largo,
                    rec_materiales_estandar.ancho,
                    rec_materiales_estandar.factor,
                    rec_materiales_estandar.cantid,
                    rec_materiales_estandar.glosa,
                    rec_materiales_estandar.codaux,
                    rec_materiales_estandar.swacti,
                    rec_materiales_estandar.usuari,
                    rec_materiales_estandar.cant_ojo,
                    rec_materiales_estandar.cant_ojo_gcable,
                    rec_materiales_estandar.codadd01std,
                    rec_materiales_estandar.codadd02std,
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS'),
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS')
                );

                COMMIT;
            WHEN 2 THEN
                v_accion := 'La actualización';
                UPDATE materiales_estandar
                SET
                    tipinvstd =
                        CASE
                            WHEN rec_materiales_estandar.tipinvstd IS NULL THEN
                                tipinvstd
                            ELSE
                                rec_materiales_estandar.tipinvstd
                        END,
                    codartstd =
                        CASE
                            WHEN rec_materiales_estandar.codartstd IS NULL THEN
                                codartstd
                            ELSE
                                rec_materiales_estandar.codartstd
                        END,
                    etapa =
                        CASE
                            WHEN rec_materiales_estandar.etapa IS NULL THEN
                                etapa
                            ELSE
                                rec_materiales_estandar.etapa
                        END,
                    etapauso =
                        CASE
                            WHEN rec_materiales_estandar.etapauso IS NULL THEN
                                etapauso
                            ELSE
                                rec_materiales_estandar.etapauso
                        END,
                    acabado =
                        CASE
                            WHEN rec_materiales_estandar.acabado IS NULL THEN
                                acabado
                            ELSE
                                rec_materiales_estandar.acabado
                        END,
                    ancho =
                        CASE
                            WHEN rec_materiales_estandar.ancho IS NULL THEN
                                ancho
                            ELSE
                                rec_materiales_estandar.ancho
                        END,
                    largo =
                        CASE
                            WHEN rec_materiales_estandar.largo IS NULL THEN
                                largo
                            ELSE
                                rec_materiales_estandar.largo
                        END,
                    factor =
                        CASE
                            WHEN rec_materiales_estandar.factor IS NULL THEN
                                factor
                            ELSE
                                rec_materiales_estandar.factor
                        END,
                    cantid =
                        CASE
                            WHEN rec_materiales_estandar.cantid IS NULL THEN
                                cantid
                            ELSE
                                rec_materiales_estandar.cantid
                        END,
                    glosa =
                        CASE
                            WHEN rec_materiales_estandar.glosa IS NULL THEN
                                glosa
                            ELSE
                                rec_materiales_estandar.glosa
                        END,
                    codaux =
                        CASE
                            WHEN rec_materiales_estandar.codaux IS NULL THEN
                                codaux
                            ELSE
                                rec_materiales_estandar.codaux
                        END,
                    swacti =
                        CASE
                            WHEN rec_materiales_estandar.swacti IS NULL THEN
                                swacti
                            ELSE
                                rec_materiales_estandar.swacti
                        END,
                    usuari =
                        CASE
                            WHEN rec_materiales_estandar.usuari IS NULL THEN
                                usuari
                            ELSE
                                rec_materiales_estandar.usuari
                        END,
                    cant_ojo =
                        CASE
                            WHEN rec_materiales_estandar.cant_ojo IS NULL THEN
                                cant_ojo
                            ELSE
                                rec_materiales_estandar.cant_ojo
                        END,
                    cant_ojo_gcable =
                        CASE
                            WHEN rec_materiales_estandar.cant_ojo_gcable IS NULL THEN
                                cant_ojo_gcable
                            ELSE
                                rec_materiales_estandar.cant_ojo_gcable
                        END,
                    codadd01std =
                        CASE
                            WHEN rec_materiales_estandar.codadd01std IS NULL THEN
                                codadd01std
                            ELSE
                                rec_materiales_estandar.codadd01std
                        END,
                    codadd02std =
                        CASE
                            WHEN rec_materiales_estandar.codadd02std IS NULL THEN
                                codadd02std
                            ELSE
                                rec_materiales_estandar.codadd02std
                        END,
                    factua = TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
             'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_materiales_estandar.id_cia
                    AND tipinvpro = rec_materiales_estandar.tipinvpro
                    AND codartpro = rec_materiales_estandar.codartpro
                    AND codclase = rec_materiales_estandar.codclase
                    AND codadd01pro = rec_materiales_estandar.codadd01pro
                    AND codadd02pro = rec_materiales_estandar.codadd02pro
                    AND item = rec_materiales_estandar.item;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM materiales_estandar
                WHERE
                        id_cia = rec_materiales_estandar.id_cia
                    AND tipinvpro = rec_materiales_estandar.tipinvpro
                    AND codartpro = rec_materiales_estandar.codartpro
                    AND codclase = rec_materiales_estandar.codclase
                    AND codadd01pro = rec_materiales_estandar.codadd01pro
                    AND codadd02pro = rec_materiales_estandar.codadd02pro
                    AND item = rec_materiales_estandar.item;

                COMMIT;
            WHEN 5 THEN
                v_accion := 'La eliminación';
                DELETE FROM materiales_estandar
                WHERE
                        id_cia = rec_materiales_estandar.id_cia
                    AND tipinvpro = rec_materiales_estandar.tipinvpro
                    AND codartpro = rec_materiales_estandar.codartpro
                    AND codclase = rec_materiales_estandar.codclase
                    AND codadd01pro = rec_materiales_estandar.codadd01pro
                    AND codadd02pro = rec_materiales_estandar.codadd02pro
                    AND tipinvstd = rec_materiales_estandar.tipinvstd
                    AND codartstd = rec_materiales_estandar.codartstd;

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
                    'message' VALUE 'El registro con ARTICULO [ '
                                    || rec_materiales_estandar.tipinvpro
                                    || ' - '
                                    || rec_materiales_estandar.codartpro
                                    || ' ], CLASE [ '
                                    || rec_materiales_estandar.codclase
                                    || ' ], CODADD01PRO [ '
                                    || rec_materiales_estandar.codadd01pro
                                    || ' ], CODADD02PRO [ '
                                    || rec_materiales_estandar.codadd02pro
                                    || ' ] y ITEM [ '
                                    || rec_materiales_estandar.item
                                    || ' ] ya existe y no puede duplicarse ...!'
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN value_error THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE 'El registro execede el limite permitido por el campo y/o se encuentra en un formato incorrecto ...!'
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN OTHERS THEN
--            IF sqlcode = -1400 THEN
--                SELECT
--                    JSON_OBJECT(
--                        'status' VALUE 1.2,
--                        'message' VALUE 'Este campo no puede ir en NULL, verifique ...!'
--                    )
--                INTO pin_mensaje
--                FROM
--                    dual;

--            ELSE
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

--            END IF;
    END;

END;

/

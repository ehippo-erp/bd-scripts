--------------------------------------------------------
--  DDL for Package Body PACK_KANBAN_CAB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_KANBAN_CAB" AS

    FUNCTION sp_stock_recibir (
        pin_id_cia NUMBER,
        pin_tipinv NUMBER,
        pin_codalm NUMBER
    ) RETURN datatable_stock_recibir
        PIPELINED
    AS
        v_table datatable_stock_recibir;
    BEGIN
        SELECT
            d.id_cia,
            d.tipinv,
            d.codart,
            SUM(d.cantid) stock
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab        c
            LEFT OUTER JOIN documentos_det        d ON d.id_cia = c.id_cia
                                                AND d.numint = c.numint
            LEFT OUTER JOIN documentos_aprobacion da ON da.id_cia = c.id_cia
                                                        AND da.numint = c.numint
        WHERE
                c.id_cia = pin_id_cia
            AND c.tipdoc = 105
            AND c.situac IN ( 'B', 'G' )
            AND da.situac = 'B'
            AND d.tipinv = pin_tipinv
            AND d.codalm = pin_codalm
        GROUP BY
            d.id_cia,
            d.tipinv,
            d.codart;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_stock_recibir;

    FUNCTION sp_pedido (
        pin_id_cia NUMBER,
        pin_codkan VARCHAR2,
        pin_tipinv NUMBER,
        pin_codalm NUMBER,
        pin_pdesde NUMBER,
        pin_phasta NUMBER
    ) RETURN datatable_pedido
        PIPELINED
    AS
        v_table datatable_pedido;
        v_desde NUMBER;
        v_hasta NUMBER;
    BEGIN
        v_desde := extract(YEAR FROM current_date) * 100;
        v_hasta := ( extract(YEAR FROM current_date) * 100 ) + extract(MONTH FROM current_date);

        IF pin_pdesde IS NOT NULL OR pin_pdesde <> -1 THEN
            v_desde := pin_pdesde;
        ELSIF pin_phasta IS NOT NULL OR pin_phasta <> -1 THEN
            v_hasta := pin_phasta;
        END IF;

        dbms_output.put_line(v_desde
                             || ' - '
                             || v_hasta);
--        WITH pendiente AS (
--            SELECT
--                d.tipinv,
--                d.codart,
--                SUM(d.cantid) stock
--            FROM
--                documentos_cab        c
--                LEFT OUTER JOIN documentos_det        d ON d.id_cia = c.id_cia
--                                                    AND d.numint = c.numint
--                LEFT OUTER JOIN documentos_aprobacion da ON da.id_cia = c.id_cia
--                                                            AND da.numint = c.numint
--            WHERE
--                    c.id_cia = pin_id_cia
--                AND c.tipdoc = 105
--                AND c.situac IN ( 'B', 'G' )
--                AND da.situac = 'B'
--                AND d.tipinv = pin_tipinv
--                AND d.codalm = pin_codalm
--            GROUP BY
--                d.tipinv,
--                d.codart
--        )
        SELECT
            f.id_cia,
            f.codkan,
            f.deskan,
            f.tipinv,
            f.dtipinv,
            f.codalm,
            f.abralm,
            f.desalm,
            f.codart,
            f.desart,
            f.cantid,
            f.cantidmin,
            f.cantidmax,
            f.faccon,
            f.cantidabs,
            f.desclase01,
            f.descodigo01,
            f.desclase02,
            f.descodigo02,
            f.stocktotal,
            f.stock,
            f.stockrecibir,
            CASE
                WHEN f.stock <= f.cantidmin THEN
                    0
                ELSE
                    f.cantidmax - f.stock - f.stockrecibir
            END AS cantidped
        BULK COLLECT
        INTO v_table
        FROM
            (
                SELECT
                    kd.id_cia,
                    kd.codkan,
                    kc.descri                        AS deskan,
                    t.tipinv,
                    t.dtipinv,
                    alm.codalm,
                    alm.abrevi                       AS abralm,
                    alm.descri                       AS desalm,
                    a.codart,
                    a.descri                         AS desart,
                    kd.cantid,
                    kd.cantidmin,
                    kd.cantidmax,
                    a.faccon,
                    abs(kd.cantid)                   AS cantidabs,
                    ac02.desclase                    AS desclase01,
                    ac02.descodigo                   AS descodigo01,
                    ac03.desclase                    AS desclase02,
                    ac03.descodigo                   AS descodigo02,
                    SUM(al.ingreso) - SUM(al.salida) AS stocktotal,
                    SUM((
                        CASE
                            WHEN al.codalm = pin_codalm THEN
                                al.ingreso
                            ELSE
                                0
                        END
                    )) - SUM((
                        CASE
                            WHEN al.codalm = pin_codalm THEN
                                al.salida
                            ELSE
                                0
                        END
                    ))                               AS stock,
                    nvl(sr.stock, 0)                 AS stockrecibir
                FROM
                         kanban_det kd
                    INNER JOIN kanban_cab                                                        kc ON kc.id_cia = kd.id_cia
                                                AND kc.codkan = kd.codkan
                                                AND kc.tipinv = kd.tipinv
                                                AND kc.codalm = kd.codalm
                    INNER JOIN t_inventario                                                      t ON t.id_cia = kd.id_cia
                                                 AND kd.tipinv = t.tipinv
                    INNER JOIN articulos                                                         a ON a.id_cia = kd.id_cia
                                              AND a.tipinv = kd.tipinv
                                              AND a.codart = kd.codart
                    LEFT OUTER JOIN sp_select_articulo_clase(kd.id_cia, kd.tipinv, kd.codart, 02)     ac02 ON 0 = 0
                    LEFT OUTER JOIN sp_select_articulo_clase(kd.id_cia, kd.tipinv, kd.codart, 03)     ac03 ON 0 = 0
                    LEFT OUTER JOIN almacen                                                           alm ON alm.id_cia = kd.id_cia
                                                   AND alm.tipinv = kd.tipinv
                                                   AND alm.codalm = pin_codalm
                    LEFT OUTER JOIN articulos_almacen                                                 al ON al.id_cia = kd.id_cia
                                                            AND al.tipinv = a.tipinv
                                                            AND al.codart = a.codart
                    LEFT OUTER JOIN pack_kanban_cab.sp_stock_recibir(kd.id_cia, kd.tipinv, kd.codalm) sr ON sr.id_cia = kd.id_cia
                                                                                                            AND sr.tipinv = kd.tipinv
                                                                                                            AND sr.codart = kd.codart
                WHERE
                        kd.id_cia = pin_id_cia
                    AND al.periodo BETWEEN v_desde AND v_hasta
                    AND kd.tipinv = pin_tipinv
                    AND kd.codkan = pin_codkan
                    AND kd.cantidmin <> 0
                    AND kd.cantidmax <> 0
                GROUP BY
                    kd.id_cia,
                    kd.codkan,
                    kc.descri,
                    t.tipinv,
                    t.dtipinv,
                    alm.codalm,
                    alm.abrevi,
                    alm.descri,
                    a.codart,
                    a.descri,
                    kd.cantid,
                    abs(kd.cantid),
                    kd.cantidmax,
                    kd.cantidmin,
                    a.faccon,
                    ac02.desclase,
                    ac02.descodigo,
                    ac03.desclase,
                    ac03.descodigo,
                    nvl(sr.stock, 0)
                HAVING
                    ( SUM((
                        CASE
                            WHEN al.codalm = pin_codalm THEN
                                al.ingreso
                            ELSE
                                0
                        END
                    )) - SUM((
                        CASE
                            WHEN al.codalm = pin_codalm THEN
                                al.salida
                            ELSE
                                0
                        END
                    )) ) <= kd.cantidmin
                ORDER BY
                    kd.codkan,
                    ac02.descodigo,
                    ac03.descodigo,
                    a.descri
            ) f;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_pedido;

    FUNCTION sp_reporte (
        pin_id_cia NUMBER,
        pin_codkan VARCHAR2,
        pin_tipinv NUMBER,
        pin_codalm NUMBER
    ) RETURN datatable_reporte
        PIPELINED
    AS
        v_table datatable_reporte;
    BEGIN
        SELECT
            kd.id_cia,
            kc.codkan,
            kc.descri AS deskan,
            t.tipinv,
            t.dtipinv,
            al.codalm,
            al.descri AS desalm,
            a.codart,
            a.descri  AS desart,
            CASE
                WHEN ac9.codigo = '1' THEN
                    'S'
                ELSE
                    'N'
            END       AS swactiart,
            CASE
                WHEN ac9.codigo = '1' THEN
                    'Activo'
                ELSE
                    'No Activo'
            END       AS swactidesart,
            kd.cantid,
            kd.cantidmin,
            kd.cantidmax
        BULK COLLECT
        INTO v_table
        FROM
            kanban_det      kd
            LEFT OUTER JOIN kanban_cab      kc ON kc.id_cia = kd.id_cia
                                             AND kd.codkan = kc.codkan
                                             AND kd.tipinv = kc.tipinv
                                             AND kd.codalm = kc.codalm
            LEFT OUTER JOIN articulos       a ON a.id_cia = kd.id_cia
                                           AND a.tipinv = kd.tipinv
                                           AND a.codart = kd.codart
            LEFT OUTER JOIN articulos_clase ac9 ON ac9.id_cia = kd.id_cia
                                                   AND ac9.tipinv = kd.tipinv
                                                   AND ac9.codart = kd.codart
                                                   AND ac9.clase = 9
            LEFT OUTER JOIN t_inventario    t ON t.id_cia = kd.id_cia
                                              AND kd.tipinv = t.tipinv
            LEFT OUTER JOIN almacen         al ON al.id_cia = kd.id_cia
                                          AND kd.codalm = al.codalm
                                          AND al.tipinv = kd.tipinv
        WHERE
                kd.id_cia = pin_id_cia
            AND kd.codkan = pin_codkan
            AND kd.tipinv = pin_tipinv
            AND kd.codalm = pin_codalm;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_reporte;

    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_codkan VARCHAR2,
        pin_tipinv NUMBER,
        pin_codalm NUMBER
    ) RETURN datatable_kanban_cab
        PIPELINED
    AS
        v_table datatable_kanban_cab;
    BEGIN
        SELECT
            kc.id_cia,
            kc.codkan,
            kc.tipinv,
            i.dtipinv,
            kc.codalm,
            a.descri,
            kc.descri,
            kc.swacti,
            kc.ucreac,
            kc.uactua,
            kc.fcreac,
            kc.factua
        BULK COLLECT
        INTO v_table
        FROM
            kanban_cab   kc
            LEFT OUTER JOIN t_inventario i ON i.id_cia = kc.id_cia
                                              AND i.tipinv = kc.tipinv
            LEFT OUTER JOIN almacen      a ON a.id_cia = kc.id_cia
                                         AND a.tipinv = kc.tipinv
                                         AND a.codalm = kc.codalm
        WHERE
                kc.id_cia = pin_id_cia
            AND kc.codkan = pin_codkan
            AND kc.tipinv = pin_tipinv
            AND kc.codalm = pin_codalm;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_codkan VARCHAR2,
        pin_tipinv NUMBER,
        pin_codalm NUMBER,
        pin_swacti VARCHAR2
    ) RETURN datatable_kanban_cab
        PIPELINED
    AS
        v_table datatable_kanban_cab;
    BEGIN
        SELECT
            kc.id_cia,
            kc.codkan,
            kc.tipinv,
            i.dtipinv,
            kc.codalm,
            a.descri,
            kc.descri,
            kc.swacti,
            kc.ucreac,
            kc.uactua,
            kc.fcreac,
            kc.factua
        BULK COLLECT
        INTO v_table
        FROM
            kanban_cab   kc
            LEFT OUTER JOIN t_inventario i ON i.id_cia = kc.id_cia
                                              AND i.tipinv = kc.tipinv
            LEFT OUTER JOIN almacen      a ON a.id_cia = kc.id_cia
                                         AND a.tipinv = kc.tipinv
                                         AND a.codalm = kc.codalm
        WHERE
                kc.id_cia = pin_id_cia
            AND ( pin_codkan IS NULL
                  OR kc.codkan = pin_codkan )
            AND ( pin_tipinv IS NULL
                  OR pin_tipinv = - 1
                  OR kc.tipinv = pin_tipinv )
            AND ( pin_codalm IS NULL
                  OR pin_codalm = - 1
                  OR kc.codalm = pin_codalm )
            AND ( pin_swacti = 'N'
                  OR pin_swacti IS NULL
                  OR kc.swacti = pin_swacti );

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
--                "codkan":"KP01",
--                "tipinv":1,
--                "codalm":1,
--                "deskan":"MERCADERIA - PRUEBA",
--                "swacti":"S",
--                "ucreac":"admin",
--                "uactua":"admin"
--                }';
--pack_kanban_cab.sp_save(66, cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_kanban_cab.sp_obtener(66,'KP01',1,1);
--
--SELECT * FROM pack_kanban_cab.sp_buscar(66,NULL,NULL,NULL,'S');

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS
        o              json_object_t;
        rec_kanban_cab kanban_cab%rowtype;
        v_accion       VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_kanban_cab.id_cia := pin_id_cia;
        rec_kanban_cab.codkan := o.get_string('codkan');
        rec_kanban_cab.tipinv := o.get_number('tipinv');
        rec_kanban_cab.codalm := o.get_number('codalm');
        rec_kanban_cab.descri := o.get_string('deskan');
        rec_kanban_cab.ucreac := o.get_string('ucreac');
        rec_kanban_cab.uactua := o.get_string('uactua');
        rec_kanban_cab.swacti := o.get_string('swacti');
        v_accion := '';
        CASE pin_opcdml
            WHEN 1 THEN
                v_accion := 'La insercion';
                INSERT INTO kanban_cab (
                    id_cia,
                    codkan,
                    tipinv,
                    codalm,
                    descri,
                    swacti,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_kanban_cab.id_cia,
                    rec_kanban_cab.codkan,
                    rec_kanban_cab.tipinv,
                    rec_kanban_cab.codalm,
                    rec_kanban_cab.descri,
                    rec_kanban_cab.swacti,
                    rec_kanban_cab.ucreac,
                    rec_kanban_cab.uactua,
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                    to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                );

            WHEN 2 THEN
                v_accion := 'La actualizacion';
                UPDATE kanban_cab
                SET
                    descri =
                        CASE
                            WHEN rec_kanban_cab.descri IS NULL THEN
                                descri
                            ELSE
                                rec_kanban_cab.descri
                        END,
                    swacti =
                        CASE
                            WHEN rec_kanban_cab.swacti IS NULL THEN
                                swacti
                            ELSE
                                rec_kanban_cab.swacti
                        END,
                    uactua =
                        CASE
                            WHEN rec_kanban_cab.uactua IS NULL THEN
                                uactua
                            ELSE
                                rec_kanban_cab.uactua
                        END,
                    factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_kanban_cab.id_cia
                    AND codkan = rec_kanban_cab.codkan
                    AND tipinv = rec_kanban_cab.tipinv
                    AND codalm = rec_kanban_cab.codalm;

            WHEN 3 THEN
                v_accion := 'La eliminacion';
                DELETE FROM kanban_cab
                WHERE
                        id_cia = rec_kanban_cab.id_cia
                    AND codkan = rec_kanban_cab.codkan
                    AND tipinv = rec_kanban_cab.tipinv
                    AND codalm = rec_kanban_cab.codalm;

        END CASE;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE v_accion || ' se realizo satisfactoriamente...!'
            )
        INTO pin_mensaje
        FROM
            dual;

        COMMIT;
    EXCEPTION
        WHEN dup_val_on_index THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE 'El registro con codigo de KANBAN [ '
                                    || rec_kanban_cab.codkan
                                    || ' ], con el tipo de inventario [ '
                                    || rec_kanban_cab.tipinv
                                    || ' ] y con el almacen [ '
                                    || rec_kanban_cab.codalm
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
                           || ' descri :'
                           || sqlcode;
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pin_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

    END sp_save;

END;

/

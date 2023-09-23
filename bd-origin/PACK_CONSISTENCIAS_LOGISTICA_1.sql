--------------------------------------------------------
--  DDL for Package Body PACK_CONSISTENCIAS_LOGISTICA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_CONSISTENCIAS_LOGISTICA" AS

    FUNCTION sp_stock_kardex (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER,
        pin_mes     NUMBER,
        pin_tipinv  NUMBER
    ) RETURN datatable_stock
        PIPELINED
    AS

        v_table  datatable_stock;
        v_pdesde NUMBER := pin_periodo * 100;
        v_phasta NUMBER := ( pin_periodo * 100 ) + pin_mes;
    BEGIN
        SELECT
            t.valida,
            pin_periodo,
            pin_mes,
            t.tipinv,
            ti.dtipinv,
            t.codart,
            a.descri AS desart,
            t.cantid,
            t.costot01,
            t.costot02
        BULK COLLECT
        INTO v_table
        FROM
            (
                SELECT
                    k.id_cia,
                    'CANTIDAD MENOR A CERO CON O SIN COSTO' AS valida,
                    k.tipinv,
                    k.codart,
                    SUM(
                        CASE
                            WHEN k.id = 'I' THEN
                                1
                            ELSE
                                - 1
                        END
                        * k.cantid)                             AS cantid,
                    SUM(
                        CASE
                            WHEN k.id = 'I' THEN
                                1
                            ELSE
                                - 1
                        END
                        * k.costot01)                           AS costot01,
                    SUM(
                        CASE
                            WHEN k.id = 'I' THEN
                                1
                            ELSE
                                - 1
                        END
                        * k.costot02)                           AS costot02
                FROM
                    kardex k
                WHERE
                        k.id_cia = pin_id_cia
                    AND k.tipinv = pin_tipinv
                    AND k.periodo BETWEEN v_pdesde AND v_phasta
                GROUP BY
                    k.id_cia,
                    'CANTIDAD MENOR A CERO CON O SIN COSTO',
                    k.tipinv,
                    k.codart
                HAVING
                    SUM(
                        CASE
                            WHEN k.id = 'I' THEN
                                1
                            ELSE
                                - 1
                        END
                        * k.cantid) < 0
                UNION ALL
                SELECT
                    k.id_cia,
                    'CANTIDAD EN CERO, PERO CON COSTO' AS valida,
                    k.tipinv,
                    k.codart,
                    SUM(
                        CASE
                            WHEN k.id = 'I' THEN
                                1
                            ELSE
                                - 1
                        END
                        * k.cantid)                        AS cantid,
                    SUM(
                        CASE
                            WHEN k.id = 'I' THEN
                                1
                            ELSE
                                - 1
                        END
                        * k.costot01)                      AS costot01,
                    SUM(
                        CASE
                            WHEN k.id = 'I' THEN
                                1
                            ELSE
                                - 1
                        END
                        * k.costot02)                      AS costot02
                FROM
                    kardex k
                WHERE
                        k.id_cia = pin_id_cia
                    AND k.tipinv = pin_tipinv
                    AND k.periodo BETWEEN v_pdesde AND v_phasta
                GROUP BY
                    k.id_cia,
                    'CANTIDAD EN CERO, PERO CON COSTO',
                    k.tipinv,
                    k.codart
                HAVING SUM(
                        CASE
                            WHEN k.id = 'I' THEN
                                1
                            ELSE
                                - 1
                        END
                        * k.cantid) = 0
                       AND ( SUM(
                    CASE
                        WHEN k.id = 'I' THEN
                            1
                        ELSE
                            - 1
                    END
                    * k.costot01) <> 0
                             OR SUM(
                    CASE
                        WHEN k.id = 'I' THEN
                            1
                        ELSE
                            - 1
                    END
                    * k.costot02) <> 0 )
                UNION ALL
                SELECT
                    k.id_cia,
                    'CANTIDAD MAYOR A CERO, PERO SIN COSTO O EN NEGATIVO' AS valida,
                    k.tipinv,
                    k.codart,
                    SUM(
                        CASE
                            WHEN k.id = 'I' THEN
                                1
                            ELSE
                                - 1
                        END
                        * k.cantid)                                           AS cantid,
                    SUM(
                        CASE
                            WHEN k.id = 'I' THEN
                                1
                            ELSE
                                - 1
                        END
                        * k.costot01)                                         AS costot01,
                    SUM(
                        CASE
                            WHEN k.id = 'I' THEN
                                1
                            ELSE
                                - 1
                        END
                        * k.costot02)                                         AS costot02
                FROM
                    kardex k
                WHERE
                        k.id_cia = pin_id_cia
                    AND k.tipinv = pin_tipinv
                    AND k.periodo BETWEEN v_pdesde AND v_phasta
                GROUP BY
                    k.id_cia,
                    'CANTIDAD MAYOR A CERO, PERO SIN COSTO O EN NEGATIVO',
                    k.tipinv,
                    k.codart
                HAVING SUM(
                        CASE
                            WHEN k.id = 'I' THEN
                                1
                            ELSE
                                - 1
                        END
                        * k.cantid) > 0
                       AND ( SUM(
                    CASE
                        WHEN k.id = 'I' THEN
                            1
                        ELSE
                            - 1
                    END
                    * k.costot01) <= 0
                             OR SUM(
                    CASE
                        WHEN k.id = 'I' THEN
                            1
                        ELSE
                            - 1
                    END
                    * k.costot02) <= 0 )
            )            t
            LEFT OUTER JOIN t_inventario ti ON ti.id_cia = t.id_cia
                                               AND ti.tipinv = t.tipinv
            LEFT OUTER JOIN articulos    a ON a.id_cia = t.id_cia
                                           AND a.tipinv = t.tipinv
                                           AND a.codart = t.codart
        ORDER BY
            t.valida,
            t.tipinv,
            t.codart;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

    END sp_stock_kardex;

    FUNCTION sp_stock_articulos_costo (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER,
        pin_mes     NUMBER,
        pin_tipinv  NUMBER
    ) RETURN datatable_stock
        PIPELINED
    AS

        v_table  datatable_stock;
        v_pdesde NUMBER := pin_periodo * 100;
        v_phasta NUMBER := ( pin_periodo * 100 ) + pin_mes;
    BEGIN
        SELECT
            t.valida,
            pin_periodo,
            pin_mes,
            t.tipinv,
            ti.dtipinv,
            t.codart,
            a.descri AS desart,
            t.cantid,
            t.costo01,
            t.costo02
        BULK COLLECT
        INTO v_table
        FROM
            (
                SELECT
                    ac.id_cia,
                    'CANTIDAD MENOR A CERO CON O SIN COSTO' AS valida,
                    ac.tipinv,
                    ac.codart,
                    ac.cantid,
                    ac.costo01,
                    ac.costo02
                FROM
                    articulos_costo ac
                WHERE
                        ac.id_cia = pin_id_cia
                    AND ac.tipinv = pin_tipinv
                    AND ac.periodo = v_phasta
                    AND ac.cantid < 0
                UNION ALL
                SELECT
                    ac.id_cia,
                    'CANTIDAD EN CERO, PERO CON COSTO' AS valida,
                    ac.tipinv,
                    ac.codart,
                    ac.cantid,
                    ac.costo01,
                    ac.costo02
                FROM
                    articulos_costo ac
                WHERE
                        ac.id_cia = pin_id_cia
                    AND ac.tipinv = pin_tipinv
                    AND ac.periodo = v_phasta
                    AND ac.cantid = 0
                    AND ( ac.costo01 <> 0
                          OR ac.costo02 <> 0 )
                UNION ALL
                SELECT
                    ac.id_cia,
                    'CANTIDAD MAYOR A CERO, PERO SIN COSTO O EN NEGATIVO' AS valida,
                    ac.tipinv,
                    ac.codart,
                    ac.cantid,
                    ac.costo01,
                    ac.costo02
                FROM
                    articulos_costo ac
                WHERE
                        ac.id_cia = pin_id_cia
                    AND ac.tipinv = pin_tipinv
                    AND ac.periodo = v_phasta
                    AND ac.cantid > 0
                    AND ( ac.costo01 <= 0
                          OR ac.costo02 <= 0 )
            )            t
            LEFT OUTER JOIN t_inventario ti ON ti.id_cia = t.id_cia
                                               AND ti.tipinv = t.tipinv
            LEFT OUTER JOIN articulos    a ON a.id_cia = t.id_cia
                                           AND a.tipinv = t.tipinv
                                           AND a.codart = t.codart
        ORDER BY
            t.valida,
            t.tipinv,
            t.codart;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_stock_articulos_costo;

    FUNCTION sp_buscar_cantidad_cero (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER,
        pin_mes     NUMBER,
        pin_tipinv  NUMBER
    ) RETURN datatable_stock_cero
        PIPELINED
    AS

        v_table  datatable_stock_cero;
        v_rec    datarecord_stock_cero;
        v_pdesde NUMBER := pin_periodo * 100;
        v_phasta NUMBER := ( pin_periodo * 100 ) + pin_mes;
    BEGIN
        FOR i IN (
            SELECT
                c.tipinv,
                t.dtipinv,
                c.codart,
                a.descri AS desart,
                c.cantid,
                c.costo01,
                c.costo02
            FROM
                articulos_costo c
                LEFT OUTER JOIN t_inventario    t ON t.id_cia = c.id_cia
                                                  AND t.tipinv = c.tipinv
                LEFT OUTER JOIN articulos       a ON a.id_cia = c.id_cia
                                               AND a.tipinv = c.tipinv
                                               AND a.codart = c.codart
            WHERE
                    c.id_cia = pin_id_cia
                AND c.periodo = v_phasta
                AND c.tipinv = pin_tipinv
                AND c.cantid = 0
                AND ( c.costo01 <> 0
                      OR c.costo02 <> 0 )
        ) LOOP
      /* Solo Aparecen los que tienen movimienos de SALIDA en el mes */
            v_rec.observacion := 'CANTIDAD EN CERO, PERO CON COSTO';
            v_rec.periodo := pin_periodo;
            v_rec.mes := pin_mes;
            v_rec.tipinv := i.tipinv;
            v_rec.tipo_inventario := i.dtipinv;
            v_rec.codart := i.codart;
            v_rec.articulo := i.desart;
            v_rec.cantidad := i.cantid;
            v_rec.costo_soles := i.costo01;
            v_rec.costo_dolares := i.costo02;
            BEGIN
                SELECT
                    COUNT(0),
                    MAX(locali)
                INTO
                    v_rec.salidas,
                    v_rec.maxlocalisal
                FROM
                    kardex k
                WHERE
                        k.id_cia = pin_id_cia
                    AND k.tipinv = i.tipinv
                    AND k.codart = i.codart
                    AND k.id = 'S'
                    AND k.periodo = v_phasta;

            EXCEPTION
                WHEN no_data_found THEN
                    v_rec.salidas := 0;
                    v_rec.maxlocalisal := -1;
            END;

            IF v_rec.salidas > 0 THEN
                PIPE ROW ( v_rec );
            END IF;
        END LOOP;
    END sp_buscar_cantidad_cero;

    PROCEDURE sp_ajustar_cantidad_cero (
        pin_id_cia  IN NUMBER,
        pin_periodo IN NUMBER,
        pin_mes     IN NUMBER,
        pin_tipinv  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS

        v_pdesde     NUMBER := pin_periodo * 100;
        v_phasta     NUMBER := ( pin_periodo * 100 ) + pin_mes;
        v_count      NUMBER := 0;
        pout_mensaje VARCHAR2(1000 CHAR);
    BEGIN
        FOR i IN (
            SELECT
                tipinv,
                codart,
                costo_soles,
                costo_dolares,
                maxlocalisal
            FROM
                pack_consistencias_logistica.sp_buscar_cantidad_cero(pin_id_cia, pin_periodo, pin_mes, pin_tipinv)
            WHERE
                salidas > 0  /*SOLO los que tengan salidas dentro del MES */
        ) LOOP
            v_count := 1;
    /* Actualiza un Costo diferencial a la ULTIMA SALODA para que ajuste y que al final se CERO */
            UPDATE kardex
            SET
                costot01 = costot01 + i.costo_soles,
                costot02 = costot02 + i.costo_dolares
            WHERE
                    id_cia = pin_id_cia
                AND locali = i.maxlocalisal;

    /* Actualiza Articulos_COSTO  con valores en CERO ( QUIZA Seria Preferible Re-Calcular el Total en este proceso...)  */
    /* 2014-11-06 CARlos - La totalizacion de Articulos_Costos sera por un proceso aparte.
                           El Cual sera colocaldo en el mismo formulario . Execute Procedure SP000_ASIGNA_COSTOS_TOTALES
    */
            UPDATE articulos_costo
            SET
                costo01 = costo01 - i.costo_soles,
                costo02 = costo02 - i.costo_dolares
            WHERE
                    id_cia = pin_id_cia
                AND periodo = v_phasta
                AND tipinv = i.tipinv
                AND codart = i.codart;

        END LOOP;

        IF v_count = 0 THEN
            pout_mensaje := 'NO SE ENCONTRO NINGUN REGISTRO PARA ACTUALIZAR';
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;
        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Success ...!'
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
        WHEN pkg_exceptionuser.ex_error_inesperado THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE pout_mensaje
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

    END sp_ajustar_cantidad_cero;

END;

/

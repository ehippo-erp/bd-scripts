--------------------------------------------------------
--  DDL for Function SP02_SACA_SALDO_ARTICULO_ALMACENES
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP02_SACA_SALDO_ARTICULO_ALMACENES" (
    pin_id_cia  NUMBER,
    pin_tipinv  NUMBER,
    pin_codart  VARCHAR2,
    pin_anopro  NUMBER,
    pin_mes     NUMBER,
    pin_tipdoc  NUMBER,
    pin_sitdoc  VARCHAR2,
    pin_codmot  NUMBER,
    pin_id      VARCHAR2
) RETURN tbl_saldo_articulo_almacenes
    PIPELINED
AS

    v_saldos_articulo_almacenes  rec_saldo_articulo_almacenes := rec_saldo_articulo_almacenes(NULL, NULL, NULL, NULL, NULL,
                             NULL, NULL, NULL, NULL, NULL);
    v_periododes                 NUMBER := pin_anopro * 100;
    v_periodohas                 NUMBER := ( pin_anopro * 100 ) + pin_mes;
    v_fisico                     NUMERIC(16, 4) := 0;
    v_comprometido               NUMERIC(16, 4) := 0;
    v_disponible                 NUMERIC(16, 4) := 0;
    v_xrecibir                   NUMERIC(16, 4) := 0;
    v_comprometido_cv            NUMERIC(16, 4) := 0;
    v_importacion                NUMERIC(16, 4) := 0;
    CURSOR cur_almacen IS
    SELECT
        a1.tipinv,
        a1.codalm,
        a1.descri AS desalm
    FROM
        almacen a1
    WHERE
        ( a1.id_cia = pin_id_cia )
        AND ( a1.tipinv = pin_tipinv )
    ORDER BY
        a1.tipinv,
        a1.codalm;

BEGIN
    FOR registropadre IN cur_almacen LOOP
        BEGIN
            SELECT
                SUM(s.ingreso) - SUM(s.salida)
            INTO v_fisico
            FROM
                articulos_almacen s
            WHERE
                    s.id_cia = pin_id_cia
                AND s.tipinv = registropadre.tipinv
                AND s.codalm = registropadre.codalm
                AND s.codart = pin_codart
                AND s.periodo >= v_periododes
                AND s.periodo <= v_periodohas;

        EXCEPTION
            WHEN no_data_found THEN
                v_fisico := 0;
        END;

        BEGIN
            SELECT
                saldo
            INTO v_comprometido
            FROM
                TABLE ( sp01_saca_acumula_saldos_ordenes_pedidos(pin_id_cia, registropadre.tipinv, pin_codart, registropadre.codalm) );

        EXCEPTION
            WHEN no_data_found THEN
                v_comprometido := 0;
        END;

        BEGIN
            SELECT
                SUM(ingreso) - SUM(salida)
            INTO v_comprometido_cv
            FROM
                comprometido_almacen
            WHERE
                ( id_cia = pin_id_cia )
                AND ( tipinv = registropadre.tipinv )
                AND ( codart = pin_codart )
                AND ( codalm = registropadre.codalm );

        EXCEPTION
            WHEN no_data_found THEN
                v_comprometido_cv := 0;
        END;

        v_disponible := nvl(v_fisico, 0) - nvl(v_comprometido, 0) - nvl(v_comprometido_cv, 0);

        BEGIN
            SELECT
                saldo
            INTO v_xrecibir
            FROM
                TABLE ( sp01_saca_acumula_saldos_documentos(pin_id_cia, registropadre.tipinv, pin_codart, registropadre.codalm, pin_tipdoc,
                                                            pin_sitdoc, pin_codmot, pin_id) );

        EXCEPTION
            WHEN no_data_found THEN
                v_xrecibir := 0;
        END;
		--en deposito o importacion

        BEGIN
            SELECT
                saldo
            INTO v_importacion
            FROM
                TABLE ( sp01_saca_acumula_saldos_documentos(pin_id_cia, registropadre.tipinv, pin_codart, registropadre.codalm, 115,
                                                            pin_sitdoc, pin_codmot, pin_id) );

        EXCEPTION
            WHEN no_data_found THEN
                v_importacion := 0;
        END;

        v_saldos_articulo_almacenes.tipinv := registropadre.tipinv;
        v_saldos_articulo_almacenes.codalm := registropadre.codalm;
        v_saldos_articulo_almacenes.desalm := registropadre.desalm;
        v_saldos_articulo_almacenes.codart := pin_codart;
        v_saldos_articulo_almacenes.fisico := nvl(v_fisico, 0);
        v_saldos_articulo_almacenes.comprometido := nvl(v_comprometido, 0);
        v_saldos_articulo_almacenes.disponible := nvl(v_disponible, 0);
        v_saldos_articulo_almacenes.xrecibir := nvl(v_xrecibir, 0);
        v_saldos_articulo_almacenes.comprometido_cv := nvl(v_comprometido_cv, 0);
        v_saldos_articulo_almacenes.importacion := nvl(v_importacion, 0);
        PIPE ROW ( v_saldos_articulo_almacenes );
    END LOOP;
END sp02_saca_saldo_articulo_almacenes;

/

--------------------------------------------------------
--  DDL for Function SP000_SACA_CANTIDADES_SALDO_ARTICULO
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP000_SACA_CANTIDADES_SALDO_ARTICULO" (
    pin_id_cia     NUMBER,
    pin_femisi     DATE,
    pin_codalm     INTEGER,
    pin_tipinv     INTEGER,
    pin_codart     VARCHAR2,
    pin_codadd01   VARCHAR2,
    pin_codadd02   VARCHAR2,
    pin_etiqueta   VARCHAR2
) RETURN tbl_cantidades_saldo_articulo
    PIPELINED
AS

    r_saldo_articulo   rec_cantidades_saldo_articulo := rec_cantidades_saldo_articulo(NULL, NULL, NULL, NULL, NULL,
                              NULL, NULL, NULL, NULL, NULL,
                              NULL, NULL, NULL, NULL, NULL,
                              NULL);
    v_esnumero         INTEGER;
    v_codcla28         VARCHAR(10) := '00';
    v_saldo_ori        NUMERIC(16, 4);
    v_tipo             INTEGER;
    v_descri           VARCHAR2(100);
    v_coduni           VARCHAR2(3);
    v_consto           SMALLINT := 0;
    v_saldo            NUMERIC(16, 4) := 0;
    v_salidamax        NUMERIC(16, 4) := 0;
    v_comprometido     NUMERIC(16, 4) := 0;
    v_swstkneg         VARCHAR2(1) := 'N';
    v_portotsal        NUMERIC(16, 4) := 0;
    v_etiqueta         VARCHAR2(100) := '';
    v_saldo_alm        NUMERIC(16, 4) := 0;
    CURSOR cur_saldo_stock_almacen (
        p_femisi     DATE,
        p_tipinv     NUMBER,
        p_codalm     NUMBER,
        p_codart     VARCHAR2,
        p_consto     VARCHAR2,
        p_etiqueta   VARCHAR2
    ) IS
    SELECT
        saldo,
        saldo_ori
    FROM
        TABLE ( sp_sel_saldo_stock_almacen(pin_id_cia, p_femisi, p_tipinv, p_codalm, p_codart,
                                           p_consto, p_etiqueta) );

BEGIN
    BEGIN
        SELECT
            a.descri,
            a.coduni,
            a.consto
        INTO
            v_descri,
            v_coduni,
            v_consto
        FROM
            articulos a
        WHERE
            a.id_cia = pin_id_cia
            AND a.tipinv = pin_tipinv
            AND a.codart = pin_codart;

    EXCEPTION
        WHEN no_data_found THEN
            v_descri := '';
            v_coduni := '';
            v_consto := 0;
    END;

    BEGIN
        SELECT
            upper(codigo) AS swstkneg
        INTO v_swstkneg
        FROM
            articulos_clase
        WHERE
            id_cia = pin_id_cia
            AND tipinv = pin_tipinv
            AND codart = pin_codart
            AND clase = 67
            AND upper(codigo) = 'S';

    EXCEPTION
        WHEN no_data_found THEN
            v_swstkneg := 'N';
    END;

    IF ( v_swstkneg IS NULL ) THEN
        v_swstkneg := 'N';
    END IF;
    BEGIN
        SELECT
            c.codigo,
            sp000_valida_datos_numericos(c.codigo) AS numerico
        INTO
            v_codcla28,
            v_esnumero
        FROM
            articulos_clase c
        WHERE
            c.id_cia = pin_id_cia
            AND c.tipinv = pin_tipinv
            AND c.codart = pin_codart
            AND c.clase = 28;    /* TOLERANCIA SALIDAS */

    EXCEPTION
        WHEN no_data_found THEN
            v_codcla28 := '0';
            v_esnumero := 0;
    END;

    IF ( ( v_esnumero IS NOT NULL ) AND ( v_esnumero = 1 ) ) THEN
        v_portotsal := to_number(v_codcla28, '99999999999.9999');
    END IF;

    v_etiqueta := pin_etiqueta;
    IF ( v_etiqueta IS NULL ) THEN
        v_etiqueta := '';
    END IF;

  /* CONSTO=0 (NO CONTROLA STOCK)
  SWTKNES=N (NO PERMITE STOCK EN NEGATIVOS)
  v_TIPO=0 (SI TIENE CERO ES PORQUE NO TIENE APROBACION POR SALIDA MAXIMA)
  */
    IF ( ( v_consto > 0 ) AND ( v_swstkneg = 'N' ) ) THEN
        FOR registro IN cur_saldo_stock_almacen(pin_femisi, pin_tipinv, pin_codalm, pin_codart, v_consto,
                        pin_etiqueta) LOOP
            v_saldo := registro.saldo;
            v_saldo_ori := registro.saldo_ori;
            IF ( v_saldo IS NULL ) THEN
                v_saldo := 0;
            END IF;
            IF ( v_saldo_ori IS NULL ) THEN
                v_saldo_ori := 0;
            END IF;
        END LOOP;

        BEGIN
            SELECT
                saldo,
                saldo_alm
            INTO
                v_comprometido,
                v_saldo_alm
            FROM
                TABLE ( sp_sel_saldo_stock_comprometido(pin_id_cia, pin_tipinv, pin_codart, pin_codadd01, pin_codadd02,
                                                        pin_codalm, pin_femisi) )
            FETCH FIRST 1 ROW ONLY;

        EXCEPTION
            WHEN no_data_found THEN
                v_comprometido := 0;
                v_saldo_alm := 0;
        END;

        IF ( v_comprometido IS NULL ) THEN
            v_comprometido := 0;
        END IF;
        IF ( v_saldo_alm IS NULL ) THEN
            v_saldo_alm := 0;
        END IF;
    END IF;

    IF ( v_tipo = 2 ) THEN
        v_swstkneg := 'S';/*LO TOMARA COMO CONTROL STOCK EN NEGATIVO, PARA QUE EL SISTEMA LO DEJE PASAR*/
    END IF;
    v_salidamax := v_saldo + ( ( v_saldo_ori * v_portotsal ) / 100 ); /* + PORCENTAJE DE SALIDA MAXIMA */
    r_saldo_articulo.femisi := pin_femisi;
    r_saldo_articulo.tipinv := pin_tipinv;
    r_saldo_articulo.codalm := pin_codalm;
    r_saldo_articulo.codart := pin_codart;
    r_saldo_articulo.descri := v_descri;
    r_saldo_articulo.codadd01 := pin_codadd01;
    r_saldo_articulo.codadd02 := pin_codadd02;
    r_saldo_articulo.coduni := v_coduni;
    r_saldo_articulo.consto := v_consto;
    r_saldo_articulo.swstkneg := v_swstkneg;
    r_saldo_articulo.etiqueta := v_etiqueta;
    r_saldo_articulo.saldo := v_saldo;
    r_saldo_articulo.salidamax := v_salidamax;
    r_saldo_articulo.portotsal := v_portotsal;
    r_saldo_articulo.comprometido := v_comprometido;
    r_saldo_articulo.saldo_alm := v_saldo_alm;
    PIPE ROW ( r_saldo_articulo );
END sp000_saca_cantidades_saldo_articulo;

/

--------------------------------------------------------
--  DDL for Function SP000_SACA_CANTIDADES_SALDO_DOCUMENTO
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP000_SACA_CANTIDADES_SALDO_DOCUMENTO" (
    pin_id_cia              NUMBER,
    pin_numint              NUMBER,
    pin_swsoloetiqueta2     VARCHAR2,
    pin_swsoloetiqueta2no   VARCHAR2
) RETURN tbl_cantidades_saldo_documento
    PIPELINED
AS

    r_saldo_documento   rec_cantidades_saldo_documento := rec_cantidades_saldo_documento(NULL, NULL, NULL, NULL, NULL,
                               NULL, NULL, NULL, NULL, NULL,
                               NULL, NULL, NULL, NULL, NULL,
                               NULL, NULL, NULL, NULL);
    v_esnumero          NUMBER := 0;
    v_tipo              NUMBER := 0;
    v_codcla28          VARCHAR2(10) := '0';
    v_saldo_ori         NUMERIC(16, 4);
    CURSOR cur_select IS
    SELECT
        c.tipdoc,
        c.numdoc,
        d.tipinv,
        d.codalm,
        d.codart,
        a.descri,
        a.coduni,
        a.consto,
        d.etiqueta,
        c.femisi,
        SUM(
            CASE
                WHEN d.codund <> a.coduni
                     AND ca1.vreal IS NOT NULL THEN
                    ca1.vreal
                ELSE
                    1
            END
            * d.cantid) AS cantid,
        CASE
            WHEN ad.tipo IS NULL THEN
                0
            ELSE
                ad.tipo
        END AS tipo,
        d.codadd01,
        d.codadd02
    FROM
        documentos_det                d
        INNER JOIN documentos_cab                c ON ( c.id_cia = pin_id_cia )
                                       AND c.numint = d.numint
        INNER JOIN articulos                     a ON ( a.id_cia = pin_id_cia )
                                  AND a.tipinv = d.tipinv
                                  AND a.codart = d.codart
        LEFT OUTER JOIN documentos_det_aprobacion     ad ON ( ad.id_cia = pin_id_cia )
                                                        AND ad.tipo = 2
                                                        AND ad.numint = d.numint
                                                        AND ad.numite = d.numite
        LEFT OUTER JOIN articulos_clase_alternativo   ca1 ON ( ca1.id_cia = pin_id_cia )
                                                           AND ca1.tipinv = d.tipinv
                                                           AND ca1.codart = d.codart
                                                           AND ca1.clase =
            CASE
                WHEN c.tipdoc IN (
                    1,
                    3,
                    7,
                    8,
                    100,
                    101,
                    102,
                    210
                ) THEN
                    1
                ELSE
                    0
            END
                                                           AND ca1.codigo = d.codund
    WHERE
        ( d.id_cia = pin_id_cia )
        AND ( d.numint = pin_numint )
        AND ( ( upper(pin_swsoloetiqueta2) <> 'S' )
              OR ( length(etiqueta2) > 2 ) )
        AND ( ( upper(pin_swsoloetiqueta2no) <> 'S' )
              OR ( upper(etiqueta2) = 'NO' ) )
    GROUP BY
        c.tipdoc,
        c.numdoc,
        d.tipinv,
        d.codalm,
        d.codart,
        a.descri,
        a.coduni,
        a.consto,
        d.etiqueta,
        c.femisi,
        ad.tipo,
        d.codadd01,
        d.codadd02;

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
 /* EJEMPLO DE USO
    SELECT * FROM SP000_SACA_CANTIDADES_SALDO_DOCUMENTO(108031,'S','N')
 */
    FOR registro IN cur_select LOOP
        r_saldo_documento.tipdoc := registro.tipdoc;
        r_saldo_documento.numdoc := registro.numdoc;
        r_saldo_documento.tipinv := registro.tipinv;
        r_saldo_documento.codalm := registro.codalm;
        r_saldo_documento.codart := registro.codart;
        r_saldo_documento.descri := registro.descri;
        r_saldo_documento.coduni := registro.coduni;
        r_saldo_documento.consto := registro.consto;
        r_saldo_documento.etiqueta := registro.etiqueta;
        r_saldo_documento.femisi := registro.femisi;
        r_saldo_documento.cantid := registro.cantid;
        v_tipo := registro.tipo;
        r_saldo_documento.codadd01 := registro.codadd01;
        r_saldo_documento.codadd02 := registro.codadd02;
        r_saldo_documento.saldo := 0;
        r_saldo_documento.salidamax := 0;
        r_saldo_documento.comprometido := 0;
        r_saldo_documento.swstkneg := 'N';
        r_saldo_documento.portotsal := 0;
        r_saldo_documento.saldo_alm := 0;
        v_codcla28 := '00';
        BEGIN
            SELECT
                upper(codigo)
            INTO r_saldo_documento.swstkneg
            FROM
                articulos_clase
            WHERE
                id_cia = pin_id_cia
                AND tipinv = registro.tipinv
                AND codart = registro.codart
                AND clase = 67
                AND upper(codigo) = 'S';

        EXCEPTION
            WHEN no_data_found THEN
                r_saldo_documento.swstkneg := 'N';
        END;

        IF ( r_saldo_documento.swstkneg IS NULL ) THEN
            r_saldo_documento.swstkneg := 'N';
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
                ( c.id_cia = pin_id_cia )
                AND c.tipinv = registro.tipinv
                AND c.codart = registro.codart
                AND c.clase = 28;    /* TOLERANCIA SALIDAS */

        EXCEPTION
            WHEN no_data_found THEN
                v_codcla28 := '00';
                v_esnumero := 0;
        END;

        IF ( ( v_esnumero IS NOT NULL ) AND ( v_esnumero = 1 ) ) THEN
            r_saldo_documento.portotsal := to_number(v_codcla28, '99999999999.9999');
        END IF;

        IF ( r_saldo_documento.etiqueta IS NULL ) THEN
            r_saldo_documento.etiqueta := '';
        END IF;
     /* CONSTO=0 (NO CONTROLA STOCK)
       SWTKNES=N (NO PERMITE STOCK EN NEGATIVOS)
       V_TIPO=0 (SI TIENE CERO ES PORQUE NO TIENE APROBACION POR SALIDA MAXIMA)
     */

        IF ( ( r_saldo_documento.consto > 0 ) AND ( r_saldo_documento.swstkneg = 'N' ) AND ( v_tipo = 0 ) ) THEN
            FOR registro2 IN cur_saldo_stock_almacen(r_saldo_documento.femisi, r_saldo_documento.tipinv, r_saldo_documento.codalm
            , r_saldo_documento.codart, r_saldo_documento.consto,
                        r_saldo_documento.etiqueta) LOOP
                r_saldo_documento.saldo := registro2.saldo;
                v_saldo_ori := registro2.saldo_ori;
                IF ( r_saldo_documento.saldo IS NULL ) THEN
                    r_saldo_documento.saldo := 0;
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
                    r_saldo_documento.comprometido,
                    r_saldo_documento.saldo_alm
                FROM
                    TABLE ( sp_sel_saldo_stock_comprometido(pin_id_cia, r_saldo_documento.tipinv, r_saldo_documento.codart, r_saldo_documento
                    .codadd01, r_saldo_documento.codadd02,
                                                            r_saldo_documento.codalm, registro.femisi) )
                FETCH FIRST 1 ROW ONLY;

            EXCEPTION
                WHEN no_data_found THEN
                    r_saldo_documento.comprometido := 0;
                    r_saldo_documento.saldo_alm := 0;
            END;

            IF ( r_saldo_documento.comprometido IS NULL ) THEN
                r_saldo_documento.comprometido := 0;
            END IF;

            IF ( r_saldo_documento.saldo_alm IS NULL ) THEN
                r_saldo_documento.saldo_alm := 0;
            END IF;

            IF ( v_tipo = 2 ) THEN
                r_saldo_documento.swstkneg := 'S';/*LO TOMARA COMO CONTROL STOCK EN NEGATIVO, PARA QUE EL SISTEMA LO DEJE PASAR*/
            END IF;
            r_saldo_documento.salidamax := r_saldo_documento.saldo + ( ( v_saldo_ori * r_saldo_documento.portotsal ) / 100 ); /* + PORCENTAJE DE SALIDA MAXIMA */

        END IF;

        PIPE ROW ( r_saldo_documento );
    END LOOP;
END sp000_saca_cantidades_saldo_documento;

/

--------------------------------------------------------
--  DDL for Procedure SP_IMPORTA_ARTICULOS_TOMA_INVENTARIO_FISICO
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_IMPORTA_ARTICULOS_TOMA_INVENTARIO_FISICO" (
    pin_id_cia   IN   NUMBER,
    pin_femisi   IN   DATE,
    pin_codmot   NUMBER,
    pin_tipinv   NUMBER,
    pin_codalm   NUMBER,
    pin_numint   NUMBER
) AS

    CURSOR cur_res_articulos_almacen (
        pdesde   NUMBER,
        phasta   NUMBER
    ) IS
    SELECT
        aa.codalm,
        aa.codart,
        SUM(aa.ingreso),
        SUM(aa.salida)
    FROM
        articulos_almacen aa
    WHERE
        aa.id_cia = pin_id_cia
        AND aa.tipinv = pin_tipinv
        AND aa.periodo BETWEEN pdesde AND phasta
    GROUP BY
        aa.codalm,
        aa.codart
    ORDER BY
        aa.codalm,
        aa.codart;

    ac_costo01        NUMBER(11, 4);
    ac_costo02        NUMBER(11, 4);
    ac_cantid         NUMBER(11, 4);
    v_situac          VARCHAR2(1);
    v_porigv          NUMERIC(16, 2);
    v_tipmon          VARCHAR2(5);
    v_tipdoc          NUMBER;
    v_series          VARCHAR2(5);
    v_numite          NUMBER := 0;
    r_docdet          documentos_det%rowtype;
    v_periodo_desde   INTEGER;
    v_periodo_hasta   INTEGER;
    v_femisi          DATE;
    v_estado          INTEGER := 1;
BEGIN

    SELECT
        situac,
        porigv,
        tipmon,
        tipdoc,
        series
    INTO
        v_situac,
        v_porigv,
        v_tipmon,
        v_tipdoc,
        v_series
    FROM
        documentos_cab
    WHERE
        id_cia = pin_id_cia
        AND numint = pin_numint;

    sp_elimina_detalle_tomainventario(pin_id_cia, pin_numint);
    v_femisi := pin_femisi;
    v_femisi := pin_femisi - 1;

--    v_periodo := ( extract(YEAR FROM v_femisi) * 100 ) + extract(MONTH FROM v_femisi);
    v_periodo_desde := extract(YEAR FROM v_femisi) * 100;
    v_periodo_hasta := (extract(YEAR FROM v_femisi) * 100 +extract(MONTH FROM v_femisi))-1 ;
    FOR reg_artalm IN cur_res_articulos_almacen(v_periodo_desde, v_periodo_hasta) LOOP
        BEGIN
            SELECT
                ac.costo01,
                ac.costo02,
                ac.cantid
            INTO
                ac_costo01,
                ac_costo02,
                ac_cantid
            FROM
                articulos_costo ac
            WHERE
                ac.id_cia = pin_id_cia
                AND ac.periodo = v_periodo_hasta
                AND ac.tipinv = pin_tipinv
                AND ac.codart = reg_artalm.codart;

        EXCEPTION
            WHEN no_data_found THEN
                ac_costo01 := 0;
                ac_costo02 := 0;
                ac_cantid := 0;
        END;

        IF ac_cantid > 0 THEN
            ac_costo01 := ( ac_costo01 / ac_cantid );
            ac_costo02 := ( ac_costo02 / ac_cantid );
        END IF;

        v_numite := v_numite + 1;
        r_docdet.id_cia := pin_id_cia;
        r_docdet.numint := pin_numint;
        r_docdet.numite := v_numite;
        r_docdet.tipinv := pin_tipinv;
        r_docdet.codart := reg_artalm.codart;
        r_docdet.codalm := reg_artalm.codalm;
        r_docdet.situac := v_situac;
        r_docdet.porigv := v_porigv;
        r_docdet.canped := 0;
        r_docdet.codund := '';
        r_docdet.cantid := ac_cantid;
        r_docdet.preuni := ac_costo01;
        r_docdet.cosuni := ac_costo01;
        r_docdet.importe_bruto := r_docdet.preuni * r_docdet.cantid;
        r_docdet.canref := 0;
        r_docdet.canped := 0;
        r_docdet.saldo := 0;
        r_docdet.pordes1 := 0;
        r_docdet.pordes2 := 0;
        r_docdet.pordes3 := 0;
        r_docdet.pordes4 := 0;
        r_docdet.importe := 0;
        r_docdet.monafe := 0;
        r_docdet.monina := 0;
        r_docdet.monigv := 0;
        r_docdet.monafe := 0;
        r_docdet.situac := v_situac;
        r_docdet.porigv := v_porigv;
        r_docdet.tipdoc := v_tipdoc;
        r_docdet.series := v_series;
        IF ( r_docdet.cantid > 0 ) THEN
            INSERT INTO documentos_det VALUES r_docdet;

        END IF;
    END LOOP;

    COMMIT;
END SP_IMPORTA_ARTICULOS_TOMA_INVENTARIO_FISICO;

/

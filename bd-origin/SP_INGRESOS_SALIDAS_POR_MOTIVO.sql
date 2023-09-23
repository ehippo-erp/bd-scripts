--------------------------------------------------------
--  DDL for Function SP_INGRESOS_SALIDAS_POR_MOTIVO
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP_INGRESOS_SALIDAS_POR_MOTIVO" (
    pin_id_cia  IN  INTEGER,
    pin_pdesde  IN  INTEGER,
    pin_phasta  IN  INTEGER,
    pin_tipinv  IN  SMALLINT,
    pin_codalm  IN  SMALLINT
) RETURN tbl_ingresos_salidas_por_motivo
    PIPELINED
AS

    rec         rec_ingresos_salidas_por_motivo := rec_ingresos_salidas_por_motivo(NULL, NULL, NULL, NULL, NULL,
                                NULL, NULL, NULL, NULL, NULL,
                                NULL);
    v_dtipinv   VARCHAR2(50) := '';
    v_dalmacen  VARCHAR2(50) := '';
BEGIN
    IF ( pin_tipinv <> -1 ) THEN
        BEGIN
            SELECT
                dtipinv
            INTO v_dtipinv
            FROM
                t_inventario t
            WHERE
                    t.id_cia = pin_id_cia
                AND t.tipinv = pin_tipinv;

        EXCEPTION
            WHEN no_data_found THEN
                v_dtipinv := '';
        END;
    END IF;

    IF (
        ( pin_tipinv <> -1 ) AND ( pin_codalm <> -1 )
    ) THEN
        BEGIN
            SELECT
                a.descri AS desalm
            INTO v_dalmacen
            FROM
                almacen a
            WHERE
                    a.id_cia = pin_id_cia
                AND a.tipinv = pin_tipinv
                AND a.codalm = pin_codalm;

        EXCEPTION
            WHEN no_data_found THEN
                v_dalmacen := '';
        END;

    END IF;

    FOR i IN (
        SELECT
            mk.valor,
            k.id,
            m.codmot,
            m.desmot,
            dt.abrevi,
            dt.descri,
            SUM(k.cantid)         AS totcan,
            SUM(k.costot01)       AS totsol,
            SUM(k.costot02)       AS totdol
        FROM
            kardex           k
            LEFT OUTER JOIN motivos          m ON m.id_cia = k.id_cia
                                         AND ( m.id = k.id )
                                         AND ( m.tipdoc = k.tipdoc )
                                         AND ( m.codmot = k.codmot )
            LEFT OUTER JOIN motivos_clase    mk ON mk.id_cia = k.id_cia
                                                AND mk.tipdoc = k.tipdoc
                                                AND mk.id = k.id
                                                AND mk.codmot = k.codmot
                                                AND mk.codigo = 46 /*OCULTO EN KARDEX VALORIZADO Y PLE*/
            LEFT OUTER JOIN documentos_tipo  dt ON dt.id_cia = k.id_cia
                                                  AND dt.tipdoc = k.tipdoc
        WHERE
                k.id_cia = pin_id_cia
            AND ( ( pin_codalm = - 1 )
                  OR ( k.codalm = pin_codalm ) )
            AND ( ( pin_tipinv = - 1 )
                  OR ( k.tipinv = pin_tipinv ) )
            AND ( ( k.periodo >= pin_pdesde )
                  AND ( k.periodo <= pin_phasta ) )
        GROUP BY
            mk.valor,
            k.id,
            dt.abrevi,
            dt.descri,
            m.codmot,
            m.desmot
        ORDER BY
            mk.valor,
            k.id,
            dt.abrevi,
            m.codmot,
            m.desmot
    ) LOOP
        CASE
            WHEN i.valor = 'S' THEN
                rec.ocultokardex := 'B';
            ELSE
                rec.ocultokardex := 'A';
        END CASE;

        rec.dalmacen := v_dalmacen;
        rec.dtipinv := v_dtipinv;
        rec.id := i.id;
        rec.codmot := i.codmot;
        rec.desmot := i.desmot;
        rec.desdoc := i.abrevi;
        rec.desdocmot := i.descri
                         || '-'
                         || i.codmot
                         || '-'
                         || i.desmot;

        rec.totcan := i.totcan;
        rec.totsol := i.totsol;
        rec.totdol := i.totdol;
        PIPE ROW ( rec );
    END LOOP;

END sp_ingresos_salidas_por_motivo;

/

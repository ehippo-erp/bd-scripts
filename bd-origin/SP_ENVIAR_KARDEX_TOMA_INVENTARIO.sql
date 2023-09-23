--------------------------------------------------------
--  DDL for Procedure SP_ENVIAR_KARDEX_TOMA_INVENTARIO
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_ENVIAR_KARDEX_TOMA_INVENTARIO" (
    pin_id_cia   IN   NUMBER,
    pin_numint   IN   NUMBER
) AS

    v_conteo       INTEGER;
    v_almdes1      SMALLINT;
    v_almdes2      SMALLINT;
    v_wcostocero   VARCHAR(3);
    v_wcostea      VARCHAR2(3);
    v_wcantid2     NUMERIC(16, 4);
    v_sid          VARCHAR2(1);
    v_scodalm      INTEGER;
    v_validaubi    VARCHAR(10);
    v_clase6       SMALLINT;
 -- ok
    v_locali       INTEGER;
    v_id           CHAR(1);
    v_tipdoc       INTEGER;
    v_numint       INTEGER;
    v_numite       INTEGER;
    v_periodo      INTEGER;
    v_codmot       SMALLINT;
    v_femisi       DATE;
    v_tipinv       INTEGER;
    v_codart       VARCHAR(40);
    v_cantid       NUMERIC(16, 4);
    v_codalm       INTEGER;
    v_almdes       INTEGER;
    v_costot01     NUMERIC(16, 2);
    v_costot02     NUMERIC(16, 2);
    v_fobtot01     NUMERIC(16, 2);
    v_fobtot02     NUMERIC(16, 2);
    v_situac       CHAR(1);
    v_usuari       VARCHAR(10);
    v_tipcam       NUMERIC(11, 4);
    v_opnumdoc     VARCHAR(30);
    v_opcargo      VARCHAR(8);
    v_opnumite     SMALLINT;
    v_opcodart     VARCHAR(40);
    v_optipinv     SMALLINT;
    v_optramo      SMALLINT;
    v_etiqueta     VARCHAR(100);
    v_codcli       VARCHAR(20);
    v_movimiento   INTEGER;
    v_royos        NUMERIC(16, 5);
    v_cosmat01     NUMERIC(16, 4);
    v_cosmob01     NUMERIC(16, 4);
    v_cosfab01     NUMERIC(16, 4);
    v_ubica        VARCHAR(10);
    v_swacti       INTEGER;
    v_codadd01     VARCHAR(10);
    v_codadd02     VARCHAR(10);
    v_numintpre    INTEGER;
    v_numitepre    INTEGER;
BEGIN


    -- GENERA ETIQUETAS PARA LOS ARTICULOS CON CONTROL STOCK 8, 5
    SP00_GENERA_ETIQUETAS_GENERADOR(pin_id_cia, pin_numint);
    COMMIT;


    DELETE FROM kardex
    WHERE
        id_cia = pin_id_cia
        AND numint = pin_numint;

  /*  SELECT VSTRG INTO v_VALIDAUBI FROM FACTOR 
   WHERE id_cia = pin_id_cia 
   and CODFAC = 349;
  */

    SELECT
        c.tipdoc,
        c.id,
        c.almdes,
        (
            CASE
                WHEN m6.valor = '' THEN
                    0
                ELSE
                    CAST(m6.valor AS SMALLINT)
            END
        ),
        m.costea,
        m47.valor,
        m6.codigo
    INTO
        v_tipdoc,
        v_id,
        v_almdes1,
        v_almdes2,
        v_wcostea,
        v_wcostocero,
        v_clase6
    FROM
        documentos_cab   c
        LEFT OUTER JOIN motivos          m ON m.id_cia = c.id_cia
                                     AND m.tipdoc = c.tipdoc
                                     AND m.id = c.id
                                     AND m.codmot = c.codmot
        LEFT OUTER JOIN motivos_clase    m6 ON m6.id_cia = c.id_cia
                                            AND m6.tipdoc = c.tipdoc
                                            AND m6.id = c.id
                                            AND m6.codmot = c.codmot
                                            AND m6.codigo = 6
        LEFT OUTER JOIN motivos_clase    m47 ON m47.id_cia = c.id_cia
                                             AND m47.tipdoc = c.tipdoc
                                             AND m47.id = c.id
                                             AND m47.codmot = c.codmot
                                             AND m47.codigo = 47
    WHERE
        c.id_cia = pin_id_cia
        AND c.numint = pin_numint;

    FOR i IN (
        SELECT
            - 1 AS locali,
            d.tipdoc,
            d.numint,
            d.numite,
            ( EXTRACT(YEAR FROM c.femisi) * 100 ) + EXTRACT(MONTH FROM c.femisi) AS periodo,
            c.codmot,
            c.femisi,
            d.tipinv,
            d.codart,
            d.cantid,
            d.codalm,
            c.tipcam,
            d.opronumdoc   AS opnumdoc,
            d.optipinv,
            d.costot01,
            d.costot02,
            d.nrotramo     AS optramo,
            d.etiqueta,
            c.codcli,
            d.royos,
            d.ubica,
            d.swacti,
            d.codadd01,
            d.codadd02,
            d.numintpre,
            d.numitepre
        FROM
            documentos_det   d
            LEFT JOIN articulos        a ON a.id_cia = d.id_cia
                                     AND a.tipinv = d.tipinv
                                     AND a.codart = d.codart
            LEFT OUTER JOIN documentos_cab   c ON c.id_cia = d.id_cia
                                                AND c.numint = d.numint
        WHERE
            d.id_cia = pin_id_cia
            AND ( d.numint = pin_numint )
    ) LOOP INSERT INTO kardex (
        id_cia,
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
        costot01,
        costot02,
        codalm,
        tipcam,
        opnumdoc,
        optipinv,
        optramo,
        etiqueta,
        codcli,
        royos,
        ubica,
        swacti,
        codadd01,
        codadd02,
        numintpre,
        numitepre
    ) VALUES (
        pin_id_cia,
        v_id,
        i.tipdoc,
        i.numint,
        i.numite,
        i.periodo,
        i.codmot,
        i.femisi,
        i.tipinv,
        i.codart,
        i.cantid,
        i.costot01,
        i.costot02,
        i.codalm,
        i.tipcam,
        i.opnumdoc,
        i.optipinv,
        i.optramo,
        i.etiqueta,
        i.codcli,
        i.royos,
        i.ubica,
        i.swacti,
        i.codadd01,
        i.codadd02,
        i.numintpre,
        i.numitepre
    );

    END LOOP;

    COMMIT;
  /* SI TODO PASO BIEN CAMBIA DE SITUACION F = EN KARDEX*/
    UPDATE documentos_cab
    SET
        situac = 'F'
    WHERE
        id_cia = pin_id_cia
        AND numint = pin_numint;

    COMMIT;
END sp_enviar_kardex_toma_inventario;

/

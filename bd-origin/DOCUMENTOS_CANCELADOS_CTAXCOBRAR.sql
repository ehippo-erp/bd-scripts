--------------------------------------------------------
--  DDL for Function DOCUMENTOS_CANCELADOS_CTAXCOBRAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "USR_TSI_SUITE"."DOCUMENTOS_CANCELADOS_CTAXCOBRAR" (
    pin_id_cia   IN  NUMBER,
    pin_finicio  IN  DATE,
    pin_fhasta   IN  DATE,
    pin_codcli   IN  VARCHAR2,
    pin_codsuc   IN  NUMBER,
    pin_codven   IN  NUMBER,
    pin_tipdocs  IN  VARCHAR2
) RETURN tbl_documentos_cancelados_ctaxcobrar
    PIPELINED
AS

    rec     rec_documentos_cancelados_ctaxcobrar := rec_documentos_cancelados_ctaxcobrar(NULL, NULL, NULL, NULL, NULL,
                                     NULL, NULL, NULL, NULL, NULL,
                                     NULL, NULL, NULL, NULL, NULL,
                                     NULL, NULL, NULL, NULL, NULL,
                                     NULL, NULL, NULL, NULL, NULL,
                                     NULL, NULL, NULL, NULL, NULL,
                                     NULL, NULL, NULL, NULL, NULL,
                                     NULL, NULL);
    CURSOR cur_cancelados (
        plibro IN VARCHAR2
    ) IS
    SELECT
        td.abrevi                 AS atipdoc,
        p.libro,
        p.periodo,
        p.mes,
        p.secuencia,
        d.tipdoc,
        d.docume,
        d.codcli,
        c.razonc,
        c.limcre1,
        c.limcre2,
        c.chedev,
        c.letpro,
        c.renova,
        c.refina,
        c.fecing,
        d.refere01,
        d.femisi,
        d.fvenci,
        d.fcance,
        p.femisi                  AS fproce,
        d.numbco,
        p.impor01 * td.signo      AS impor01,
        p.impor02 * td.signo      AS impor02,
        p.doccan,
        p.tipcan,
        d.codban,
        td.descri                 AS dtipdoc,
        tc.descri                 AS dtipcan,
        d.tipmon,
        CASE
                WHEN d.tipmon = 'PEN' THEN
                    p.impor01
                ELSE
                    p.impor02
            END
        * td.signo AS importe,
        d.comisi,
        d.tipcam,
        d.codven,
        d.concpag,
        cp.despag,
        v.desven                  AS vendedor
    FROM
             dcta101 p
        INNER JOIN dcta100       d ON d.id_cia = p.id_cia
                                AND d.numint = p.numint
        LEFT OUTER JOIN cliente       c ON c.id_cia = p.id_cia
                                     AND c.codcli = d.codcli
        LEFT OUTER JOIN vendedor      v ON v.id_cia = p.id_cia
                                      AND v.codven = d.codven
        LEFT OUTER JOIN c_pago        cp ON cp.id_cia = p.id_cia
                                     AND cp.codpag = d.concpag
        INNER JOIN tdoccobranza  td ON td.id_cia = p.id_cia
                                      AND td.tipdoc = d.tipdoc
        INNER JOIN m_pago        tc ON tc.id_cia = p.id_cia
                                AND tc.codigo = p.tipcan
    WHERE
        ( p.id_cia = pin_id_cia )
        AND ( p.libro = plibro )
        AND p.femisi BETWEEN pin_finicio AND pin_fhasta
        AND ( ( pin_codcli IS NULL )
              OR ( d.codcli = pin_codcli ) )
        AND ( ( pin_codsuc IS NULL )
              OR ( d.codsuc = pin_codsuc ) )
        AND ( ( pin_codven IS NULL )
              OR ( d.codven = pin_codven ) )
        AND ( ( ( pin_tipdocs IS NULL )
                OR ( pin_tipdocs = '' ) )
              OR ( d.tipdoc IN (
            SELECT
                *
            FROM
                TABLE ( f_convert(pin_tipdocs) )
        ) ) )
    ORDER BY
        d.tipdoc,
        d.docume;

    v_f100  VARCHAR2(20) := '';
BEGIN
    BEGIN
        SELECT
            vstrg
        INTO v_f100
        FROM
            factor
        WHERE
                id_cia = pin_id_cia
            AND codfac = 100; /*Planilla de Cobranza*/

    EXCEPTION
        WHEN no_data_found THEN
            v_f100 := '';
    END;

    FOR rcalidad IN cur_cancelados(v_f100) LOOP
        rec.atipdoc := rcalidad.atipdoc;
        rec.libro := rcalidad.libro;
        rec.periodo := rcalidad.periodo;
        rec.mes := rcalidad.mes;
        rec.secuencia := rcalidad.secuencia;
        rec.tipdoc := rcalidad.tipdoc;
        rec.docume := rcalidad.docume;
        rec.codcli := rcalidad.codcli;
        rec.razonc := rcalidad.razonc;
        rec.limcre1 := rcalidad.limcre1;
        rec.limcre2 := rcalidad.limcre2;
        rec.chedev := rcalidad.chedev;
        rec.letpro := rcalidad.letpro;
        rec.renova := rcalidad.renova;
        rec.refina := rcalidad.refina;
        rec.fecing := rcalidad.fecing;
        rec.refere01 := rcalidad.refere01;
        rec.femisi := rcalidad.femisi;
        rec.fvenci := rcalidad.fvenci;
        rec.fcance := rcalidad.fcance;
        rec.fproce := rcalidad.fproce;
        rec.numbco := rcalidad.numbco;
        rec.impor01 := rcalidad.impor01;
        rec.impor02 := rcalidad.impor02;
        rec.doccan := rcalidad.doccan;
        rec.tipcan := rcalidad.tipcan;
        rec.codban := rcalidad.codban;
        rec.dtipdoc := rcalidad.dtipdoc;
        rec.dtipcan := rcalidad.dtipcan;
        rec.tipmon := rcalidad.tipmon;
        rec.importe := rcalidad.importe;
        rec.comisi := rcalidad.comisi;
        rec.tipcam := rcalidad.tipcam;
        rec.codven := rcalidad.codven;
        rec.concpag := rcalidad.concpag;
        rec.despag := rcalidad.despag;
        rec.vendedor := rcalidad.vendedor;
        PIPE ROW ( rec );
    END LOOP;

END documentos_cancelados_ctaxcobrar;

/

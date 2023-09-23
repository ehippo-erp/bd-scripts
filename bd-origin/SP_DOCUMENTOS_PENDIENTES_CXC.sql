--------------------------------------------------------
--  DDL for Function SP_DOCUMENTOS_PENDIENTES_CXC
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP_DOCUMENTOS_PENDIENTES_CXC" (
    pin_id_cia      IN  NUMBER,
    pin_codcli      IN  VARCHAR2,
    pin_codsuc      IN  NUMBER,
    pin_codven      IN  NUMBER,
    pin_tipdocs     IN  VARCHAR2,
    pin_codubis     IN  VARCHAR2,
    pin_incdocdes   IN  VARCHAR2,
    pin_incfacanti  IN  VARCHAR2
) RETURN tbl_documentos_pendientes_cxc
    PIPELINED
AS

    rec rec_sp_documentos_pendientes_cxc := rec_sp_documentos_pendientes_cxc(NULL, NULL, NULL, NULL, NULL,
                                 NULL, NULL, NULL, NULL, NULL,
                                 NULL, NULL, NULL, NULL, NULL,
                                 NULL, NULL, NULL, NULL, NULL,
                                 NULL, NULL, NULL, NULL, NULL,
                                 NULL, NULL, NULL, NULL, NULL,
                                 NULL, NULL, NULL, NULL, NULL,
                                 NULL, NULL, NULL, NULL, NULL);
BEGIN
    /* SELECT * FROM TABLE(sp_documentos_pendientes_cxc(23,NULL,1,NULL,'XXX','XXX','N','S')) */
    FOR i IN (
        SELECT
            EXTRACT(YEAR FROM c.fvenci)        AS periodo,
            EXTRACT(MONTH FROM c.fvenci)       AS mes,
            c.numint,
            c.tipdoc,
            c.docume,
            c.refere01,
            c.femisi,
            c.fvenci,
            dc.series                          AS seriesdoc,
            dc.numdoc                          AS numerodoc,
            c.fcance,
            c.numbco,
            c.tipmon,
            c.importe,
            c.saldo                            AS saldox,
            c.codban,
            c.codcli,
            c.razonc,
            c.limcre1,
            c.limcre2,
            nvl(c.chedev, 0)                    AS chedev,
            nvl(c.letpro, 0)                    AS letpro,
            nvl(c.renova, 0)                    AS renova,
            nvl(c.refina, 0)                    AS refina,
            c.fecing,
            c.abrevi                           AS dtido,
            c.desdoc                           AS destipdoc,
            c.tipcam,
            c.codven,
            CAST(
                CASE
                    WHEN c.codven IS NOT NULL THEN
                        c.desven
                    ELSE
                        'no asignado'
                END
            AS VARCHAR2(15)) AS desven,
            c.desban,
            c.operac,
            CAST(
                CASE
                    WHEN c.codpag = 1 THEN
                        'Abierto'
                    ELSE
                        'Cerrado'
                END
            AS VARCHAR2(10)) AS credito,
            c.desven_car                       AS vencar,
            c.saldopercep,
            c.tpercepcion,
            c.concpag,
            c.descpag
        FROM
            TABLE ( sp000_documentos_pendientes_ctaxcobrar_2(pin_id_cia, pin_codcli, pin_codsuc, pin_codven, pin_tipdocs,
                                                             pin_codubis, pin_incdocdes, NULL, pin_incfacanti) ) c
            LEFT OUTER JOIN documentos_cab dc ON dc.id_cia = pin_id_cia
                                                 AND dc.numint = c.numint
        ORDER BY
            c.codcli,
            c.codsuc,
            c.tipdoc,
            c.femisi,
            c.docume
    ) LOOP
        IF ( i.operac IS NOT NULL ) THEN
            rec.operacion :=
                CASE
                    WHEN ( i.operac = 0 ) THEN
                        'CARTERA'
                    WHEN ( i.operac = 1 ) THEN
                        'COBRANZA'
                    WHEN ( i.operac = 2 ) THEN
                        'DESCUENTO'
                    WHEN ( i.operac = 3 ) THEN
                        'GARANTÍA'
                    WHEN ( i.operac = 4 ) THEN
                        'CANCELACIÓN'
                    WHEN ( i.operac = 5 ) THEN
                        'PROTESTO'
                    WHEN ( i.operac = 6 ) THEN
                        'RETIRADA'
                    WHEN ( i.operac = 7 ) THEN
                        'EMITIDA'
                    WHEN ( i.operac = 8 ) THEN
                        'PROTESTO EN BANCO'
                    WHEN ( i.operac = 9 ) THEN
                        'INGRESO A BANCO'
                END;
        END IF;

        rec.id_cia := pin_id_cia;
        rec.periodo := i.periodo;
        rec.mes := i.mes;
        rec.numint := i.numint;
        rec.tipdoc := i.tipdoc;
        rec.docume := i.docume;
        rec.refere01 := i.refere01;
        rec.femisi := i.femisi;
        rec.fvenci := i.fvenci;
        rec.seriesdoc := i.seriesdoc;
        rec.numerodoc := i.numerodoc;
        rec.fcance := i.fcance;
        rec.numbco := i.numbco;
        rec.tipmon := i.tipmon;
        rec.importe := i.importe;
        rec.saldox := i.saldox;
        rec.codban := i.codban;
        rec.codcli := i.codcli;
        rec.razonc := i.razonc;
        rec.limcre1 := i.limcre1;
        rec.limcre2 := i.limcre2;
        rec.chedev := i.chedev;
        rec.letpro := i.letpro;
        rec.renova := i.renova;
        rec.refina := i.refina;
        rec.fecing := i.fecing;
        rec.dtido := i.dtido;
        rec.destipdoc := i.destipdoc;
        rec.tipcam := i.tipcam;
        rec.codven := i.codven;
        rec.desven := i.desven;
        rec.desban := i.desban;
        rec.operac := i.operac;
        rec.credito := i.credito;
        rec.vencar := i.vencar;
        rec.saldopercep := i.saldopercep;
        rec.tpercepcion := i.tpercepcion;
        rec.concpag := i.concpag;
        rec.descpag := i.descpag;
        PIPE ROW ( rec );
    END LOOP;
END sp_documentos_pendientes_cxc;

/

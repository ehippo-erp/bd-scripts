--------------------------------------------------------
--  DDL for Package Body PACK_CONSULTAS_CXC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_CONSULTAS_CXC" AS

    FUNCTION ecc_resumen_pendientes (
        pin_id_cia      IN NUMBER,---1
        pin_codcli      IN VARCHAR2,---2
        pin_swsolpend   IN VARCHAR2,---3
        pin_swincdocdes IN VARCHAR2,---4
        pin_subicacion  IN VARCHAR2,---5
        pin_numint      IN NUMBER,---6
        pin_swcancela   IN VARCHAR2,---7
        pin_swdcta106   IN VARCHAR2---8
    ) RETURN datatable_ecc_resumen_pendientes
        PIPELINED
    AS
        v_table datatable_ecc_resumen_pendientes;
    BEGIN

/*
SELECT
    desdoc,
    tipdoc,
    tipmon,
    solven,
    dolven,
    eurven,
    solxven,
    dolxven,
    eurxven,
    totsol,
    totdol,
    toteur
FROM
    PACK_consultas_cxc.ECC_RESUMEN_PENDIENTES(61, '20207313204', 'S', 'S', '-1,1',
                                                 NULL, NULL, 'N') ;
*/

        SELECT
            desdoc,
            tipdoc,
            tipmon,
            SUM(
                CASE
                    WHEN((tipmon = 'PEN')
                         AND(fvenci <= current_date)) THEN
                        saldo * signo
                    ELSE
                        0
                END
            ) AS solven,
            SUM(
                CASE
                    WHEN((tipmon = 'USD')
                         AND(fvenci <= current_date)) THEN
                        saldo * signo
                    ELSE
                        0
                END
            ) AS dolven,
            SUM(
                CASE
                    WHEN((tipmon = 'EUR')
                         AND(fvenci <= current_date)) THEN
                        saldo * signo
                    ELSE
                        0
                END
            ) AS eurven,
            SUM(
                CASE
                    WHEN((tipmon = 'PEN')
                         AND(fvenci > current_date)) THEN
                        saldo * signo
                    ELSE
                        0
                END
            ) AS solxven,
            SUM(
                CASE
                    WHEN((tipmon = 'USD')
                         AND(fvenci > current_date)) THEN
                        saldo * signo
                    ELSE
                        0
                END
            ) AS dolxven,
            SUM(
                CASE
                    WHEN((tipmon = 'EUR')
                         AND(fvenci > current_date)) THEN
                        saldo * signo
                    ELSE
                        0
                END
            ) AS eurxven,
            SUM(
                CASE
                    WHEN(tipmon = 'PEN') THEN
                        saldo * signo
                    ELSE
                        0
                END
            ) AS totsol,
            SUM(
                CASE
                    WHEN(tipmon = 'USD') THEN
                        saldo * signo
                    ELSE
                        0
                END
            ) AS totdol,
            SUM(
                CASE
                    WHEN(tipmon = 'EUR') THEN
                        saldo * signo
                    ELSE
                        0
                END
            ) AS toteur
        BULK COLLECT
        INTO v_table
        FROM
            TABLE ( sp000_saca_estado_de_cuenta_clientes(pin_id_cia, pin_codcli, pin_swsolpend, pin_swincdocdes, pin_subicacion,
                                                         pin_numint, pin_swcancela, pin_swdcta106) )
        GROUP BY
            desdoc,
            tipdoc,
            tipmon
        ORDER BY
            tipdoc;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END ecc_resumen_pendientes;

    FUNCTION sp_documentos_cancelados (
        pin_id_cia  NUMBER,
        pin_codcli  VARCHAR2,
        pin_codven  NUMBER,
        pin_codsuc  NUMBER,
        pin_fdesde  DATE,
        pin_fhasta  DATE,
        pin_tipdocs VARCHAR2,
        pin_libros  VARCHAR2,
        pin_orderby NUMBER
    ) RETURN datatable_documentos_cancelados
        PIPELINED
    AS
        v_table datatable_documentos_cancelados;
    BEGIN
        SELECT
            p.id_cia,
            ( p.libro
              || ' - '
              || TRIM(to_char(p.periodo, '0000'))
              || TRIM(to_char(p.mes, '00'))
              || TRIM(to_char(p.secuencia, '000000')) ) AS planilla,
            td.abrevi                                 AS atipdoc,
            p.libro,
            l.descri                                  AS deslib,
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
            p.femisi                                  AS fproce,
            d.numbco,
            p.impor01 * td.signo                      AS impor01,
            p.impor02 * td.signo                      AS impor02,
            p.doccan,
            p.tipcan,
            d.codban,
            td.descri                                 AS dtipdoc,
            tc.codigo                                 AS dcodtipcan,
            tc.descri                                 AS dtipcan,
            p.tipmon,
            p.importe * td.signo,
            d.tipmon,
            CASE
                WHEN d.tipmon = 'PEN' THEN
                        p.impor01
                ELSE
                    p.impor02
            END
            * td.signo                                AS importe,
            d.comisi,
            d.tipcam,
            d.codven,
            v.desven                                  AS vendedor,
            d4.codban                                 AS d4codban,
            b.descri                                  AS d4desban,
            p.usuari,
            u1.nombres
        BULK COLLECT
        INTO v_table
        FROM
                 dcta101 p
            INNER JOIN dcta100      d ON d.id_cia = p.id_cia
                                    AND d.numint = p.numint
            LEFT OUTER JOIN dcta104      d4 ON d4.id_cia = p.id_cia
                                          AND d4.libro = p.libro
                                          AND d4.periodo = p.periodo
                                          AND d4.mes = p.mes
                                          AND d4.secuencia = p.secuencia
                                          AND d4.item = 1
            LEFT OUTER JOIN cliente      c ON c.id_cia = p.id_cia
                                         AND c.codcli = d.codcli
            LEFT OUTER JOIN vendedor     v ON v.id_cia = p.id_cia
                                          AND v.codven = d.codven
            INNER JOIN tdoccobranza td ON td.id_cia = p.id_cia
                                          AND td.tipdoc = d.tipdoc
            LEFT OUTER JOIN m_pago       tc ON tc.id_cia = p.id_cia
                                         AND tc.codigo = p.tipcan
            LEFT OUTER JOIN tlibro       l ON l.id_cia = p.id_cia
                                        AND l.codlib = p.libro
            LEFT OUTER JOIN tbancos      b ON b.id_cia = d4.id_cia
                                         AND b.codban = d4.codban
            LEFT OUTER JOIN usuarios     u1 ON u1.id_cia = p.id_cia
                                           AND u1.coduser = p.usuari
        WHERE
                p.id_cia = pin_id_cia
            AND p.tipcan < 50
            AND ( p.femisi BETWEEN pin_fdesde AND pin_fhasta )
            AND ( pin_codcli IS NULL
                  OR d.codcli = pin_codcli )
            AND ( pin_codven IS NULL
                  OR d.codven = pin_codven )
            AND ( pin_codsuc IS NULL
                  OR d.codsuc = pin_codsuc )
            AND ( pin_libros IS NULL
                  OR p.libro IN (
                SELECT
                    *
                FROM
                    TABLE ( convert_in(pin_libros) )
            ) )
            AND ( pin_tipdocs IS NULL
                  OR d.tipdoc IN (
                SELECT
                    *
                FROM
                    TABLE ( convert_in(pin_tipdocs) )
            ) )
        ORDER BY
            d.tipdoc,
            d.docume,
            CASE
                    WHEN pin_orderby = 1 THEN
                        p.tipcan
                    WHEN pin_orderby = 2 THEN
                        v.codven
            END;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_documentos_cancelados;

END pack_consultas_cxc;

/

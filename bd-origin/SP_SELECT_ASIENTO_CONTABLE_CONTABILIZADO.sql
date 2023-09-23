--------------------------------------------------------
--  DDL for Function SP_SELECT_ASIENTO_CONTABLE_CONTABILIZADO
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP_SELECT_ASIENTO_CONTABLE_CONTABILIZADO" (
    pin_id_cia    IN   NUMBER,
    pin_libro     IN   VARCHAR2,
    pin_periodo   IN   NUMBER,
    pin_mes       IN   NUMBER,
    pin_asiento   IN   NUMBER
) RETURN tbl_sp_select_asiento_contable_contabilizado
    PIPELINED
AS

    rec rec_sp_select_asiento_contable_contabilizado := rec_sp_select_asiento_contable_contabilizado(NULL, NULL, NULL, NULL, NULL
    ,
                                             NULL, NULL, NULL, NULL, NULL,
                                             NULL, NULL, NULL, NULL, NULL,
                                             NULL, NULL, NULL, NULL, NULL,
                                             NULL, NULL, NULL, NULL, NULL,
                                             NULL, NULL, NULL, NULL, NULL,
                                             NULL, NULL, NULL, NULL, NULL,
                                             NULL, NULL, NULL, NULL);
BEGIN
    FOR i IN (
        SELECT
            d1.periodo,
            d1.mes,
            d1.libro,
            d1.asiento,
            d1.item,
            d1.sitem,
            d1.cuenta,
            d2.nombre    AS dcuenta,
            d1.fecha,
            d1.dh,
            d1.debe,
            d1.haber,
            d1.debe01,
            d1.haber01,
            d1.debe02,
            d1.haber02,
            d1.concep,
            d1.importe,
            d1.impor01,
            d1.impor02,
            d1.tcambio01,
            d1.tcambio02,
            d1.ccosto,
            d1.proyec,
            d1.subcco,
            d1.codigo,
            d1.serie
            || '-'
            || d1.numero AS numero,
            l1.descri    AS deslib,
            dc.abrevi    AS tdocto,
            d1.usuari    AS coduser,
            ur.nombres   AS nomuser,
            CAST(
                CASE d1.tcambio02
                    WHEN 0 THEN
                        tcambio01 / 1
                    ELSE
                        tcambio01 / tcambio02
                END
            AS NUMERIC(14, 6)) AS tc,
            a.ucreac,
            a.usuari,
            a.fcreac,
            ua.nombres   AS nomucreac,
            a.factua,
            a.fecha      AS fecha_asiento
        FROM
            movimientos   d1
            LEFT OUTER JOIN pcuentas      d2 ON d2.id_cia = pin_id_cia
                                           AND ( d1.cuenta = d2.cuenta )
            LEFT OUTER JOIN tlibro        l1 ON l1.id_cia = pin_id_cia
                                         AND ( l1.codlib = d1.libro )
            LEFT OUTER JOIN tdocume       dc ON dc.id_cia = pin_id_cia
                                          AND ( dc.codigo = d1.tdocum )
            LEFT OUTER JOIN usuarios      ur ON ( ur.id_cia = pin_id_cia
                                             AND ur.coduser = d1.usuari )
            LEFT OUTER JOIN asienhea      a ON a.id_cia = pin_id_cia
                                          AND a.periodo = d1.periodo
                                          AND a.mes = d1.mes
                                          AND a.libro = d1.libro
                                          AND a.asiento = d1.asiento
            LEFT OUTER JOIN usuarios      ua ON ( ua.id_cia = pin_id_cia
                                             AND ua.coduser = a.ucreac )
        WHERE
            d1.id_cia = pin_id_cia
            AND ( d1.libro = pin_libro )
            AND ( d1.periodo = pin_periodo )
            AND ( d1.mes = pin_mes )
            AND ( d1.asiento = pin_asiento )
        ORDER BY
            d1.periodo,
            d1.mes,
            d1.libro,
            d1.asiento,
            d1.item,
            d1.sitem
    ) LOOP
        rec.id_cia := pin_id_cia;
        rec.periodo := i.periodo;
        rec.mes := i.mes;
        rec.libro := i.libro;
        rec.asiento := i.asiento;
        rec.item := i.item;
        rec.sitem := i.sitem;
        rec.cuenta := i.cuenta;
        rec.dcuenta := i.dcuenta;
        rec.fecha := i.fecha;
        rec.dh := i.dh;
        rec.debe := i.debe;
        rec.haber := i.haber;
        rec.debe01 := i.debe01;
        rec.haber01 := i.haber01;
        rec.debe02 := i.debe02;
        rec.haber02 := i.haber02;
        rec.concep := i.concep;
        rec.importe := i.importe;
        rec.impor01 := i.impor01;
        rec.impor02 := i.impor02;
        rec.tcambio01 := i.tcambio01;
        rec.tcambio02 := i.tcambio02;
        rec.ccosto := i.ccosto;
        rec.proyec := i.proyec;
        rec.subcco := i.subcco;
        rec.codigo := i.codigo;
        rec.numero := i.numero;
        rec.deslib := i.deslib;
        rec.tdocto := i.tdocto;
        rec.coduser := i.coduser;
        rec.nomuser := i.nomuser;
        rec.tc := i.tc;
        rec.ucreac := i.ucreac;
        rec.usuari := i.usuari;
        rec.fcreac := i.fcreac;
        rec.nomucreac := i.nomucreac;
        rec.factua := i.factua;
        rec.fecha_asiento := i.fecha_asiento;
        PIPE ROW ( rec );
    END LOOP;
END sp_select_asiento_contable_contabilizado;

/

--------------------------------------------------------
--  DDL for Function SP_CONTABILIDAD_CUENTAS_PARA_ASIENTO_IMPORTACION
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP_CONTABILIDAD_CUENTAS_PARA_ASIENTO_IMPORTACION" (
    pin_id_cia     IN  NUMBER,
    pin_periodo    IN  NUMBER,
    pin_mes        IN  NUMBER,
    pin_dia        IN  NUMBER,
    pin_libro      IN  VARCHAR2,
    pin_concepto   IN  VARCHAR2,
    pin_femisi     IN  DATE,
    pin_series     IN  VARCHAR2,
    pin_numdoc     IN  NUMBER,
    pin_tipmon     IN  VARCHAR2,
    pin_coduser    IN  VARCHAR2
) RETURN tbl_detalle_asiento
    PIPELINED
AS

    rasiendet  rec_detalle_asiento := rec_detalle_asiento(NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL);
    CURSOR cur_gasvinclase_10(cia number,pseries varchar2,pnumdoc number) IS
    SELECT
        t.codigo               AS cuenta,
        SUM(c.tgeneral1)       AS totsol,
        SUM(c.tgeneral2)       AS totdol
    FROM
        TABLE ( sp00_gastos_vinculados_orden_importacion_v2(pin_id_cia, 103, pin_series, pin_numdoc) ) c
        LEFT OUTER JOIN tdocume_clases  t ON t.id_cia = pin_id_cia
                                            AND t.tipdoc = c.tdocum
                                            AND t.clase = ( 10 + c.swgasoper )
                                            AND t.moneda = c.moneda
    GROUP BY
        c.swgasoper,
        t.codigo;

    CURSOR cur_gasvinclase_12(cia number,pseries varchar2,pnumdoc number)  IS
    SELECT
        c.codcli,
        c.razon,
        c.tdocum,
        c.nserie,
        c.numero,
        t.codigo       AS cuenta,
        c.tgeneral1    AS totsol,
        c.tgeneral2    AS totdol
    FROM
        TABLE ( sp00_gastos_vinculados_orden_importacion_v2(pin_id_cia, 103, pin_series, pin_numdoc) )        c
        LEFT OUTER JOIN tdocume_clases                                                                                        t ON t.id_cia = pin_id_cia
                                            AND t.tipdoc = c.tdocum
                                            AND t.clase = 12
                                            AND t.moneda = c.moneda
    ORDER BY
        c.swgasoper,
        t.codigo,
        c.nserie,
        c.numero,
        c.tdocum;

    CURSOR cur_gasvin_18_29(cia number,pseries varchar2,pnumdoc number)  IS
    SELECT
        c1.codigo               AS cuenta,
        CASE
            WHEN c1.clase = 18 THEN
                'D'
            ELSE
                'H'
        END AS dh,
        SUM(g.tcostotsol)       AS totsol,
        SUM(g.tcostotdol)       AS totdol
    FROM
        TABLE ( sp01_costos_orden_importacion_02_v2(pin_id_cia, 103, pin_series, pin_numdoc) )        g
        LEFT OUTER JOIN articulos_clase                                                                               c1 ON c1.id_cia = pin_id_cia
                                              AND c1.tipinv = g.tipinv
                                              AND c1.codart = g.codart
                                              AND c1.clase IN (
            18,
            29
        )
    GROUP BY
        c1.clase,
        c1.codigo;

    contador   NUMBER := 0;
    v_fecha    DATE := to_date(pin_dia
                            || '/'
                            || pin_mes
                            || '/'
                            || pin_periodo, 'DD/MM/YYYY');
BEGIN
    FOR reg_clase10 IN cur_gasvinclase_10(pin_id_cia,pin_series, pin_numdoc) LOOP

        contador := contador + 1;
        rasiendet.id_cia := pin_id_cia;
        rasiendet.periodo := pin_periodo;
        rasiendet.mes := pin_mes;
        rasiendet.libro := pin_libro;
        rasiendet.asiento := 0;
        rasiendet.item := contador;
        rasiendet.sitem := 0;
        rasiendet.concep := pin_concepto;
        rasiendet.fecha := v_fecha;
        rasiendet.tasien := 1;
        rasiendet.topera := 0;
        rasiendet.cuenta := reg_clase10.cuenta;
        rasiendet.dh := 'D';
        rasiendet.moneda := pin_tipmon;
        IF ( pin_tipmon = 'PEN' ) THEN
            rasiendet.tcambio01 := 1;
            rasiendet.tcambio02 := reg_clase10.totdol / reg_clase10.totsol;
            rasiendet.importe := reg_clase10.totsol;
        ELSE
            rasiendet.tcambio01 := reg_clase10.totsol / reg_clase10.totdol;
            rasiendet.tcambio02 := 1;
            rasiendet.importe := reg_clase10.totdol;
        END IF;

        rasiendet.impor01 := reg_clase10.totsol;
        rasiendet.impor02 := reg_clase10.totdol;
        rasiendet.debe := 0;
        rasiendet.debe01 := 0;
        rasiendet.debe02 := 0;
        rasiendet.haber := 0;
        rasiendet.haber01 := 0;
        rasiendet.haber02 := 0;
        CASE
            WHEN rasiendet.dh = 'D' THEN
                rasiendet.debe := rasiendet.importe;
                rasiendet.debe01 := rasiendet.impor01;
                rasiendet.debe02 := rasiendet.impor02;
            WHEN rasiendet.dh = 'H' THEN
                rasiendet.haber := rasiendet.importe;
                rasiendet.haber01 := rasiendet.impor01;
                rasiendet.haber02 := rasiendet.impor02;
        END CASE;

        rasiendet.ccosto := ' ';
        rasiendet.proyec := ' ';
        rasiendet.subcco := ' ';
        rasiendet.ctaalternativa := ' ';
        rasiendet.tipo := 0;
        rasiendet.docume := 0;
        rasiendet.codigo := ' ';
        rasiendet.razon := '';
        rasiendet.tident := ' ';
        rasiendet.dident := ' ';
        rasiendet.tdocum := ' ';
        rasiendet.serie := ' ';
        rasiendet.numero := '';
        rasiendet.fdocum := null;
        rasiendet.usuari := pin_coduser;
        rasiendet.fcreac := sysdate;
        rasiendet.factua := sysdate;
        rasiendet.regcomcol := 0;
        rasiendet.swprovicion := 'N';
        rasiendet.saldo := 0;
        rasiendet.swgasoper := 1;
        rasiendet.codporret := '';
        rasiendet.swchkconcilia := 'N';
        PIPE ROW ( rasiendet );
    END LOOP;

    FOR reg_clase_12 IN cur_gasvinclase_12(pin_id_cia,pin_series, pin_numdoc) LOOP
        contador := contador + 1;
        rasiendet.id_cia := pin_id_cia;
        rasiendet.periodo := pin_periodo;
        rasiendet.mes := pin_mes;
        rasiendet.libro := pin_libro;
        rasiendet.asiento := 0;
        rasiendet.item := contador;
        rasiendet.sitem := 0;
        rasiendet.concep := pin_concepto;
        rasiendet.fecha := v_fecha;
        rasiendet.tasien := 1;
        rasiendet.topera := 0;
        rasiendet.cuenta := reg_clase_12.cuenta;
        rasiendet.dh := 'H';
        rasiendet.moneda := pin_tipmon;
        IF ( pin_tipmon = 'PEN' ) THEN
            rasiendet.tcambio01 := 1;
            rasiendet.tcambio02 := reg_clase_12.totdol / reg_clase_12.totsol;
            rasiendet.importe := reg_clase_12.totsol;
        ELSE
            rasiendet.tcambio01 := reg_clase_12.totsol / reg_clase_12.totdol;
            rasiendet.tcambio02 := 1;
            rasiendet.importe := reg_clase_12.totdol;
        END IF;
        rasiendet.impor01 := reg_clase_12.totsol;
        rasiendet.impor02 := reg_clase_12.totdol;
        rasiendet.debe := 0;
        rasiendet.debe01 := 0;
        rasiendet.debe02 := 0;
        rasiendet.haber := 0;
        rasiendet.haber01 := 0;
        rasiendet.haber02 := 0;
        CASE
            WHEN rasiendet.dh = 'D' THEN
                rasiendet.debe := rasiendet.importe;
                rasiendet.debe01 := rasiendet.impor01;
                rasiendet.debe02 := rasiendet.impor02;
            WHEN rasiendet.dh = 'H' THEN
                rasiendet.haber := rasiendet.importe;
                rasiendet.haber01 := rasiendet.impor01;
                rasiendet.haber02 := rasiendet.impor02;
        END CASE;

        rasiendet.ccosto := ' ';
        rasiendet.proyec := ' ';
        rasiendet.subcco := ' ';
        rasiendet.ctaalternativa := ' ';
        rasiendet.tipo := 0;
        rasiendet.docume := 0;
        rasiendet.codigo := reg_clase_12.codcli;
        rasiendet.razon := reg_clase_12.razon;
        rasiendet.tident := ' ';
        rasiendet.dident := ' ';
        rasiendet.tdocum := reg_clase_12.tdocum;
        rasiendet.serie := reg_clase_12.nserie;
        rasiendet.numero := reg_clase_12.numero;
        rasiendet.fdocum := null;
        rasiendet.usuari := pin_coduser;
        rasiendet.fcreac := sysdate;
        rasiendet.factua := sysdate;
        rasiendet.regcomcol := 0;
        rasiendet.swprovicion := 'N';
        rasiendet.saldo := 0;
        rasiendet.swgasoper := 1;
        rasiendet.codporret := '';
        rasiendet.swchkconcilia := 'N';
        PIPE ROW ( rasiendet );
    END LOOP;

    FOR reg_clase_18_29 IN cur_gasvin_18_29(pin_id_cia,pin_series, pin_numdoc) LOOP
        contador := contador + 1;
        rasiendet.id_cia := pin_id_cia;
        rasiendet.periodo := pin_periodo;
        rasiendet.mes := pin_mes;
        rasiendet.libro := pin_libro;
        rasiendet.asiento := 0;
        rasiendet.item := contador;
        rasiendet.sitem := 0;
        rasiendet.concep := pin_concepto;
        rasiendet.fecha := v_fecha;
        rasiendet.tasien := 1;
        rasiendet.topera := 0;
        rasiendet.cuenta := reg_clase_18_29.cuenta;
        rasiendet.dh := reg_clase_18_29.dh;
        rasiendet.moneda := pin_tipmon;
        IF ( pin_tipmon = 'PEN' ) THEN
            rasiendet.tcambio01 := 1;
            rasiendet.tcambio02 := reg_clase_18_29.totdol / reg_clase_18_29.totsol;
            rasiendet.importe := reg_clase_18_29.totsol;
        ELSE
            rasiendet.tcambio01 := reg_clase_18_29.totsol / reg_clase_18_29.totdol;
            rasiendet.tcambio02 := 1;
            rasiendet.importe := reg_clase_18_29.totdol;
        END IF;
        rasiendet.impor01 := reg_clase_18_29.totsol;
        rasiendet.impor02 := reg_clase_18_29.totdol;
        rasiendet.debe := 0;
        rasiendet.debe01 := 0;
        rasiendet.debe02 := 0;
        rasiendet.haber := 0;
        rasiendet.haber01 := 0;
        rasiendet.haber02 := 0;
        CASE
            WHEN rasiendet.dh = 'D' THEN
                rasiendet.debe := rasiendet.importe;
                rasiendet.debe01 := rasiendet.impor01;
                rasiendet.debe02 := rasiendet.impor02;
            WHEN rasiendet.dh = 'H' THEN
                rasiendet.haber := rasiendet.importe;
                rasiendet.haber01 := rasiendet.impor01;
                rasiendet.haber02 := rasiendet.impor02;
        END CASE;

        rasiendet.ccosto := ' ';
        rasiendet.proyec := ' ';
        rasiendet.subcco := ' ';
        rasiendet.ctaalternativa := ' ';
        rasiendet.tipo := 0;
        rasiendet.docume := 0;
        rasiendet.codigo := '';
        rasiendet.razon := '';
        rasiendet.tident := ' ';
        rasiendet.dident := ' ';
        rasiendet.tdocum := '';
        rasiendet.serie := '';
        rasiendet.numero := '';
        rasiendet.fdocum := null;
        rasiendet.usuari := pin_coduser;
        rasiendet.fcreac := sysdate;
        rasiendet.factua := sysdate;
        rasiendet.regcomcol := 0;
        rasiendet.swprovicion := 'N';
        rasiendet.saldo := 0;
        rasiendet.swgasoper := 1;
        rasiendet.codporret := '';
        rasiendet.swchkconcilia := 'N';
        PIPE ROW ( rasiendet );
    END LOOP;

END sp_contabilidad_cuentas_para_asiento_importacion;

/

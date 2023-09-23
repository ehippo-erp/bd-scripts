--------------------------------------------------------
--  DDL for Procedure SP_GENERA_ASIENTO_VENTA_DETALLADO_DOCUMENTO01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_GENERA_ASIENTO_VENTA_DETALLADO_DOCUMENTO01" (
    pin_id_cia    IN  NUMBER,
    pin_numint    IN  NUMBER,
    pin_libro     IN  VARCHAR2,
    pin_periodo   IN  NUMBER,
    pin_mes       IN  NUMBER,
    pin_asiento   IN  NUMBER,
    pin_item      IN OUT NUMBER,
    pin_codsunat  IN  VARCHAR2
) AS

    CURSOR cur_gen_asiento_det IS
    SELECT
        s.cuenta,
        s.dh,
        s.codcli,
        s.razonc,
        s.tident,
        s.ruc,
        s.femisi,
        s.series,
        s.numdoc,
        s.tipmon,
        s.tipcam,
        s.importe01,
        s.importe02
    FROM
        TABLE ( sp_genera_detalle_asiento_venta_documento(pin_id_cia, pin_numint) ) s;

    v_tipcam    NUMERIC(10, 6);
    v_concep    VARCHAR2(75);
    r_asiendet  asiendet%rowtype;

BEGIN

    FOR i IN cur_gen_asiento_det LOOP
        r_asiendet.cuenta := i.cuenta;
        r_asiendet.dh := i.dh;
        r_asiendet.codigo := i.codcli;
        r_asiendet.razon := i.razonc;
        r_asiendet.tident := i.tident;
        r_asiendet.dident := i.ruc;
        r_asiendet.fecha := i.femisi;
        r_asiendet.tdocum := pin_codsunat;
        r_asiendet.serie := i.series;
        r_asiendet.numero := i.numdoc;
        r_asiendet.moneda := i.tipmon;
        v_tipcam := i.tipcam;
        r_asiendet.tcambio01 := ( CASE
            WHEN i.tipmon = 'PEN' THEN
                1.0
            ELSE v_tipcam
        END );

        r_asiendet.tcambio02 := ( CASE
            WHEN i.tipmon = 'PEN' THEN
                1.0 / v_tipcam
            ELSE 1
        END );

        r_asiendet.importe := ( CASE
            WHEN i.tipmon = 'PEN' THEN
                i.importe01
            ELSE i.importe02
        END );

        r_asiendet.impor01 := i.importe01;
        r_asiendet.impor02 := i.importe02;
        r_asiendet.debe := 0.0;
        r_asiendet.debe01 := 0.0;
        r_asiendet.debe02 := 0.0;
        r_asiendet.haber := 0.0;
        r_asiendet.haber01 := 0.0;
        r_asiendet.haber02 := 0.0;
        IF ( i.dh = 'D' ) THEN
            r_asiendet.debe := r_asiendet.importe;
            r_asiendet.debe01 := r_asiendet.impor01;
            r_asiendet.debe02 := r_asiendet.impor02;
        END IF;

        IF ( i.dh = 'H' ) THEN
            r_asiendet.haber := r_asiendet.importe;
            r_asiendet.haber01 := r_asiendet.impor01;
            r_asiendet.haber02 := r_asiendet.impor02;
        END IF;

        v_concep := ( substr(i.razonc, 1, 74) );
        INSERT INTO asiendet (
            id_cia,
            periodo,
            mes,
            libro,
            asiento,
            item,
            sitem,
            concep,
            fecha,
            tasien,
            topera,
            cuenta,
            dh,
            moneda,
            importe,
            impor01,
            impor02,
            debe,
            debe01,
            debe02,
            haber,
            haber01,
            haber02,
            tcambio01,
            tcambio02,
            ccosto,
            proyec,
            subcco,
            tipo,
            docume,
            codigo,
            razon,
            tident,
            dident,
            tdocum,
            serie,
            numero,
            fdocum,
            regcomcol,
            swprovicion,
            saldo,
            swgasoper,
            codporret,
            swchkconcilia,
            ctaalternativa
        ) VALUES (
            pin_id_cia,
            pin_periodo,
            pin_mes,
            pin_libro,
            pin_asiento,
            pin_item,
            0,
            v_concep,
            r_asiendet.fecha,
            66,
            NULL,
            r_asiendet.cuenta,
            r_asiendet.dh,
            r_asiendet.moneda,
            r_asiendet.importe,
            r_asiendet.impor01,
            r_asiendet.impor02,
            r_asiendet.debe,
            r_asiendet.debe01,
            r_asiendet.debe02,
            r_asiendet.haber,
            r_asiendet.haber01,
            r_asiendet.haber02,
            r_asiendet.tcambio01,
            r_asiendet.tcambio02,
            NULL,
            NULL,
            NULL,
            0,
            0,
            r_asiendet.codigo,
            r_asiendet.razon,
            r_asiendet.tident,
            r_asiendet.dident,
            r_asiendet.tdocum,
            r_asiendet.serie,
            r_asiendet.numero,
            r_asiendet.fecha,
            0,
            'N',
            0,
            1,
            '',
            'N',
            ''
        );
        pin_item:=pin_item+1;
    END LOOP;

END sp_genera_asiento_venta_detallado_documento01;

/

--------------------------------------------------------
--  DDL for Function SP_CONTABILIDAD_CUENTAS_PREDETERMINADAS_CAJA_CHICA
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP_CONTABILIDAD_CUENTAS_PREDETERMINADAS_CAJA_CHICA" (
    pin_id_cia  IN  NUMBER,
    pin_tipo    IN  NUMBER,
    pin_docume  IN  NUMBER
) RETURN tbl_cuentas_predeterminadas
    PIPELINED
AS

    registro     rec_cuentas_predeterminadas := rec_cuentas_predeterminadas(NULL, NULL, NULL, NULL, NULL,
                            NULL, NULL, NULL, NULL, NULL,
                            NULL, NULL, NULL, NULL, NULL,
                            NULL, NULL, NULL, NULL, NULL,
                            NULL, NULL, NULL, NULL, NULL,
                            NULL, NULL, NULL, NULL, NULL,
                            NULL, NULL, NULL, NULL, NULL,
                            NULL, NULL, NULL, NULL);
    CURSOR cur_compr010 IS
    SELECT
        a.tipo,
        a.docume,
        a.periodo,
        a.mes,
        a.libro,
        a.asiento,
        a.femisi,
        a.tdocum,
        a.codpro,
        a.razon,
        a.tident,
        a.dident,
        a.nserie,
        a.numero,
        a.moneda,
        a.concep,
        a.cuenta,
        a.dh,
        a.ctaalternativa,
        a.tcamb01,
        a.tcamb02,
        a.ctagasto,
        a.ccosto,
        a.subccosto,
        a.proyec,
        a.importe * d.signo              AS importe,
        abs(
            CASE
                WHEN a.tdocum = '02' THEN
                    a.importep - a.igv
                ELSE
                    a.importep
            END
        ) * d.signo AS importepx,
        abs(
            CASE
                WHEN a.tdocum = '02' THEN
                    a.impor01p - a.igv01
                ELSE
                    a.impor01p
            END
        ) * d.signo AS impor01px,
        abs(
            CASE
                WHEN a.tdocum = '02' THEN
                    a.impor02p - a.igv02
                ELSE
                    a.impor02p
            END
        ) * d.signo AS impor02px,
        abs(a.impor01) * d.signo         AS impor01,
        abs(a.impor02) * d.signo         AS impor02,
        abs(a.base) * d.signo            AS base,
        abs(a.base01) * d.signo          AS base01,
        abs(a.base02) * d.signo          AS base02,
        tf.cuenta                        AS cuentadetrac,
        c40.femisi                       AS fecha
    FROM
             compr040 c40
        INNER JOIN compr010  a ON a.id_cia = c40.id_cia
                                 AND a.tipcaja = c40.tipo
                                 AND a.doccaja = c40.docume
                                 AND a.situac = 2
        INNER JOIN tdocume   d ON d.id_cia = a.id_cia
                                AND d.codigo = a.tdocum
        LEFT OUTER JOIN tfactor   tf ON tf.id_cia = a.id_cia
                                      AND tf.tipo = 64
                                      AND tf.vreal = a.tdetrac / 10
    WHERE
            c40.id_cia = pin_id_cia
        AND c40.tipo = pin_tipo
        AND c40.docume = pin_docume;

    CURSOR cur_compr040 IS
    SELECT
        c40.tipo,
        c40.docume,
        c40.femisi,
        c40.tcambio,
        c40.ctapago,
        c40.concep,
        cli.razonc,
        c40.moneda,
        c40.codper,
        c40.ccosto,
        c40.fondo,
        cli.tident,
        cli.dident
    FROM
        compr040  c40
        LEFT OUTER JOIN cliente   cli ON cli.id_cia = c40.id_cia
                                       AND cli.codcli = c40.codper
    WHERE
            c40.id_cia = pin_id_cia
        AND ( c40.tipo = pin_tipo )
        AND ( c40.docume = pin_docume );

    item         NUMBER;
    v_cuenta     VARCHAR2(16);
    v_dh         VARCHAR2(2);
    v_tipo       NUMBER;
    v_regcomcol  NUMBER;
    v_vstrg      VARCHAR2(1);
    v_totalsol   NUMERIC(16, 4) := 0;
    v_totaldol   NUMERIC(16, 4) := 0;
    v_item       INTEGER := 0;
BEGIN
    FOR c10 IN cur_compr010 LOOP
    /* para que cargue las cuentas de 42..*/
    /* Carga Cuenta Destino..*/
        v_item := v_item + 1;
        registro.id_cia := pin_id_cia;
        registro.periodo := c10.periodo;
        registro.fecha := c10.fecha;
        registro.mes := c10.mes;
        registro.libro := c10.libro;
        registro.item := v_item;
        registro.sitem := 0;
        registro.topera := 0;
        registro.tipo := c10.tipo;
        registro.docume := c10.docume;
        registro.cuenta := '';
        registro.cuenta := c10.cuenta;
        registro.concep := c10.concep;
        registro.fdocum := c10.femisi;
        registro.tcambio01 := c10.tcamb01;
        registro.tcambio02 := c10.tcamb02;
        registro.moneda := c10.moneda;
        registro.importe := 0;
        registro.impor01 := 0;
        registro.impor02 := 0;
        IF ( c10.tdocum = '02' ) THEN
            registro.importe := c10.base;
            registro.impor01 := c10.base01;
            registro.impor02 := c10.base02;
        ELSE
            registro.importe := c10.importe;
            registro.impor01 := c10.impor01;
            registro.impor02 := c10.impor02;
        END IF;

        v_totalsol := v_totalsol + registro.impor01;
        v_totaldol := v_totaldol + registro.impor02;
        registro.ccosto := '';
        registro.subccosto := '';
        registro.proyec := '';
        IF (
            ( registro.cuenta <> '' ) AND ( substr(c10.cuenta, 1, 2) <> '42' )
        ) THEN
            registro.ccosto := c10.ccosto;
            registro.subccosto := c10.subccosto;
            registro.proyec := c10.proyec;
        END IF;

        registro.tident := c10.tident;
        registro.dident := c10.dident;
        registro.codigo := c10.codpro;
        registro.razon := c10.razon;
        registro.tdocum := c10.tdocum;
        registro.serie := c10.nserie;
        registro.numero := c10.numero;
       /* la Cta sera Contrapartida para que mate la Provicion.*/
        registro.debe := 0;
        registro.debe01 := 0;
        registro.debe02 := 0;
        registro.haber := 0;
        registro.haber01 := 0;
        registro.haber02 := 0;
        CASE c10.dh
            WHEN 'D' THEN
                registro.dh := 'H';
                registro.haber := registro.importe;
                registro.haber01 := registro.impor01;
                registro.haber02 := registro.impor02;
            WHEN 'H' THEN
                registro.dh := 'D';
                registro.debe := registro.importe;
                registro.debe01 := registro.impor01;
                registro.debe02 := registro.impor02;
            ELSE
                NULL;
        END CASE;

        registro.tasien := 66;
        PIPE ROW ( registro );
    END LOOP;
    /*   para que cargue las cuentas default.. */

    FOR c40 IN cur_compr040 LOOP
        v_item := v_item + 1;
        registro.item := v_item;
        registro.cuenta := c40.ctapago;
        registro.concep := c40.concep;
        registro.fecha := c40.femisi;
        registro.tcambio01 := 0;
        registro.tcambio02 := 0;
        registro.importe := 0;
        registro.impor01 := 0;
        registro.impor02 := 0;
        registro.tcambio01 := 0;
        registro.tcambio02 := 0;
        registro.moneda := c40.moneda;
        IF ( c40.moneda = 'PEN' ) THEN
            registro.importe := v_totalsol;
            registro.tcambio01 := 1;
            registro.tcambio02 := 1 / c40.tcambio;
        ELSE
            registro.importe := v_totaldol;
            registro.tcambio01 := c40.tcambio;
            registro.tcambio02 := 1;
        END IF;

        registro.impor01 := v_totalsol;
        registro.impor02 := v_totaldol;
        registro.ccosto := '';
        registro.subccosto := '';
        registro.proyec := '';
        registro.dh := 'H';
        registro.debe := 0;
        registro.debe01 := 0;
        registro.debe02 := 0;
        registro.haber := registro.importe;
        registro.haber01 := registro.impor01;
        registro.haber02 := registro.impor02;
        registro.tident := registro.tident;
        registro.dident := registro.dident;
        registro.tdocum := '';
        registro.serie := '';
        registro.numero := '';
        registro.codigo := c40.codper;
        registro.razon := c40.razonc;
        registro.tasien := 66;
        registro.fondo := c40.fondo;
        PIPE ROW ( registro );
    END LOOP;

END sp_contabilidad_cuentas_predeterminadas_caja_chica;

/

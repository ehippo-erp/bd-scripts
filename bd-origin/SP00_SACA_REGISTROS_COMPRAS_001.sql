--------------------------------------------------------
--  DDL for Function SP00_SACA_REGISTROS_COMPRAS_001
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP00_SACA_REGISTROS_COMPRAS_001" (
    pin_id_cia   NUMBER,
    pin_periodo  NUMBER,
    pin_mes      NUMBER,
    pin_libro    VARCHAR2
) RETURN tbl_registros_compras_001
    PIPELINED
AS

    v_registros_compras_001  rec_registros_compras_001 := rec_registros_compras_001(NULL, NULL, NULL, NULL, NULL,
                          NULL, NULL, NULL, NULL, NULL,
                          NULL, NULL, NULL, NULL, NULL,
                          NULL, NULL, NULL, NULL, NULL,
                          NULL, NULL, NULL, NULL, NULL,
                          NULL, NULL, NULL, NULL, NULL,
                          NULL, NULL, NULL, NULL, NULL,
                          NULL, NULL, NULL, NULL, NULL,
                          NULL, NULL, NULL, NULL, NULL,
                          NULL, NULL);
    v_swsalio                VARCHAR2(1);
    CURSOR cur_select IS
    SELECT
        a.libro,
        a.periodo,
        a.mes,
        t.descri    AS deslib,
        a.asiento,
        a.situac,
        c.tipo,
        c.docume,
        c.femisi,
        c.moneda,
        c.tdocum,
        c.nserie    AS serie,
        c.numero,
        c.codpro,
        c.razon,
        c.tcamb01,
        c.tcamb02,
        a.concep,
        c.porigv,
        c.usuari,
        u.nombres,
        c.factua
    FROM
        asienhea  a
        LEFT OUTER JOIN compr010  c ON c.id_cia = pin_id_cia
                                      AND c.periodo = a.periodo
                                      AND c.mes = a.mes
                                      AND c.libro = a.libro
                                      AND c.asiento = a.asiento
                                      AND c.situac = a.situac
        LEFT OUTER JOIN usuarios  u ON u.id_cia = pin_id_cia
                                      AND u.coduser = c.usuari
        LEFT OUTER JOIN tlibro    t ON t.id_cia = pin_id_cia
                                    AND t.codlib = a.libro
    WHERE
            a.id_cia = pin_id_cia
        AND a.periodo = pin_periodo
        AND ( ( pin_mes IS NULL )
              OR ( a.mes = pin_mes ) )
        AND a.libro = pin_libro
        AND a.situac IN (
            2,
            9
        )
    ORDER BY
        a.asiento;

    CURSOR cur_select02 (
        plibro    VARCHAR2,
        pperiodo  NUMBER,
        pmes      NUMBER,       
        pasiento  NUMBER
    ) IS
    SELECT
        t.signo,
        SUM(CASE WHEN(a1.regcomcol IN(1, 2, 5 )) THEN a1.debe01 + a1.haber01 ELSE 0 END ) * t.signo AS tcrefis,
        SUM(CASE WHEN(a1.regcomcol IN(1, 2, 5 )) THEN a1.debe02 + a1.haber02 ELSE 0 END ) * t.signo AS tcrefis2,
        SUM(CASE WHEN a1.regcomcol = 4 THEN a1.debe01 - a1.haber01 ELSE 0 END ) AS tinafecto, /* NO USARA EL SIGNO PARA QUE SALGA NEGATIVOS*/
        SUM(CASE WHEN a1.regcomcol = 4 THEN a1.debe02 - a1.haber02 ELSE 0 END ) AS tinafecto2, /* NO USARA EL SIGNO PARA QUE SALGA NEGATIVOS*/
        SUM(CASE WHEN a1.regcomcol = 5 THEN a1.debe01 + a1.haber01 ELSE 0 END ) * t.signo AS tncrefis,
        SUM(CASE WHEN a1.regcomcol = 5 THEN a1.debe02 + a1.haber02 ELSE 0 END ) * t.signo AS tncrefis2,
        SUM(CASE WHEN(a1.regcomcol = 1) THEN a1.debe01 + a1.haber01 ELSE 0 END ) * t.signo AS tbaseimp_c1,
        SUM(CASE WHEN(a1.regcomcol = 2) THEN a1.debe01 + a1.haber01 ELSE 0 END ) * t.signo AS tbaseimp_c2,
        SUM(CASE WHEN(a1.regcomcol = 5) THEN a1.debe01 + a1.haber01 ELSE 0 END ) * t.signo AS tbaseimp_c3,
        SUM(CASE WHEN(a1.regcomcol IN(1, 2, 5 )) THEN a1.debe01 + a1.haber01 ELSE 0 END ) * t.signo AS tbaseimp,
        SUM(CASE WHEN(a1.regcomcol IN(1, 2, 5 )) THEN a1.debe02 + a1.haber02 ELSE 0 END ) * t.signo AS tbaseimp2,
        SUM(CASE WHEN a1.regcomcol IN(6, 7, 8 ) THEN a1.debe01 + a1.haber01 ELSE 0 END ) * t.signo AS timpuesto,
        SUM(CASE WHEN(a1.regcomcol = 6) THEN a1.debe01 + a1.haber01 ELSE 0 END ) * t.signo AS timpuesto_c1,
        SUM(CASE WHEN(a1.regcomcol = 8) THEN a1.debe01 + a1.haber01 ELSE 0 END ) * t.signo AS timpuesto_c2,
        SUM(CASE WHEN(a1.regcomcol = 7) THEN a1.debe01 + a1.haber01 ELSE 0 END ) * t.signo AS timpuesto_c3,
        SUM(CASE WHEN a1.regcomcol IN(6, 7, 8 ) THEN a1.debe02 + a1.haber02 ELSE 0 END ) * t.signo AS timpuesto2,
        SUM(CASE WHEN(a1.regcomcol = 10) THEN a1.debe01 - a1.haber01 ELSE 0 END ) * t.signo AS tisc,
        SUM(CASE WHEN(a1.regcomcol = 10) THEN a1.debe02 - a1.haber02 ELSE 0 END ) * t.signo AS tisc2,
        SUM(CASE WHEN(a1.regcomcol = 11) THEN a1.debe01 - a1.haber01 ELSE 0 END ) * t.signo AS totrostri,
        SUM(CASE WHEN(a1.regcomcol = 11) THEN a1.debe02 - a1.haber02 ELSE 0 END ) * t.signo AS totrostri2,
        SUM(CASE WHEN(a1.regcomcol = 12) THEN a1.debe01 - a1.haber01 ELSE 0 END ) * t.signo AS ticbper,
        SUM(CASE WHEN(a1.regcomcol = 12) THEN a1.debe02 - a1.haber02 ELSE 0 END ) * t.signo AS ticbper2,
        SUM(CASE WHEN a1.regcomcol = 9 THEN a1.debe01 + a1.haber01 ELSE 0 END ) * t.signo AS tgeneral,
        SUM(CASE WHEN a1.regcomcol = 9 AND a1.moneda <> 'PEN' THEN a1.debe02 + a1.haber02 ELSE 0 END ) * t.signo AS tgeneral2
    FROM
        movimientos  a1
        LEFT OUTER JOIN tdocume      t ON t.id_cia = a1.id_cia
                                     AND ( t.codigo = a1.tdocum )
    WHERE
            a1.id_cia = pin_id_cia
        AND ( a1.periodo = pperiodo )
        AND ( a1.mes = pmes )
        AND ( a1.libro = plibro )
        AND ( a1.asiento = pasiento )
        AND t.signo IS NOT NULL
    GROUP BY
        a1.asiento,
        t.signo;

BEGIN
    FOR registro IN cur_select LOOP
        v_registros_compras_001.libro := registro.libro;
        v_registros_compras_001.periodo := registro.periodo;
        v_registros_compras_001.mes := registro.mes;
        v_registros_compras_001.deslib := registro.deslib;
        v_registros_compras_001.asiento := registro.asiento;
        v_registros_compras_001.situac := registro.situac;
        v_registros_compras_001.tipo := registro.tipo;
        v_registros_compras_001.docume := registro.docume;
        v_registros_compras_001.femisi := registro.femisi;
        v_registros_compras_001.moneda := registro.moneda;
        v_registros_compras_001.tdocum := registro.tdocum;
        v_registros_compras_001.serie := registro.serie;
        v_registros_compras_001.numero := registro.numero;
        v_registros_compras_001.codigo := registro.codpro;
        v_registros_compras_001.razon := registro.razon;
        v_registros_compras_001.TCAMBIO01 := registro.tcamb01;
        v_registros_compras_001.TCAMBIO02 := registro.tcamb02;
        v_registros_compras_001.concep := registro.concep;
        v_registros_compras_001.porigv := registro.porigv;
        v_registros_compras_001.coduser := registro.usuari;
        v_registros_compras_001.usuario := registro.nombres;
        v_registros_compras_001.factua := registro.factua;
        v_registros_compras_001.signo := 0;
        v_registros_compras_001.tcrefis := 0;
        v_registros_compras_001.tcrefis2 := 0;
        v_registros_compras_001.tinafecto := 0;
        v_registros_compras_001.tinafecto2 := 0;
        v_registros_compras_001.tncrefis := 0;
        v_registros_compras_001.tncrefis2 := 0;
        v_registros_compras_001.tbaseimp_c1 := 0;
        v_registros_compras_001.tbaseimp_c2 := 0;
        v_registros_compras_001.tbaseimp_c3 := 0;
        v_registros_compras_001.tbaseimp := 0;
        v_registros_compras_001.tbaseimp2 := 0;
        v_registros_compras_001.timpuesto := 0;
        v_registros_compras_001.timpuesto_c1 := 0;
        v_registros_compras_001.timpuesto_c2 := 0;
        v_registros_compras_001.timpuesto_c3 := 0;
        v_registros_compras_001.timpuesto2 := 0;
        v_registros_compras_001.tisc := 0;
        v_registros_compras_001.tisc2 := 0;
        v_registros_compras_001.totrostri := 0;
        v_registros_compras_001.totrostri2 := 0;
        v_registros_compras_001.ticbper := 0;
        v_registros_compras_001.ticbper2 := 0;
        v_registros_compras_001.tgeneral := 0;
        v_registros_compras_001.tgeneral2 := 0;
        v_swsalio := 'N';
        FOR registro2 IN cur_select02(registro.libro, registro.periodo, registro.mes, registro.asiento) LOOP
            v_registros_compras_001.signo := registro2.signo;
            v_registros_compras_001.tcrefis := registro2.tcrefis;
            v_registros_compras_001.tcrefis2 := registro2.tcrefis2;
            v_registros_compras_001.tinafecto := registro2.tinafecto;
            v_registros_compras_001.tinafecto2 := registro2.tinafecto2;
            v_registros_compras_001.tncrefis := registro2.tncrefis;
            v_registros_compras_001.tncrefis2 := registro2.tncrefis2;
            v_registros_compras_001.tbaseimp_c1 := registro2.tbaseimp_c1;
            v_registros_compras_001.tbaseimp_c2 := registro2.tbaseimp_c2;
            v_registros_compras_001.tbaseimp_c3 := registro2.tbaseimp_c3;
            v_registros_compras_001.tbaseimp := registro2.tbaseimp;
            v_registros_compras_001.tbaseimp2 := registro2.tbaseimp2;
            v_registros_compras_001.timpuesto := registro2.timpuesto;
            v_registros_compras_001.timpuesto_c1 := registro2.timpuesto_c1;
            v_registros_compras_001.timpuesto_c2 := registro2.timpuesto_c2;
            v_registros_compras_001.timpuesto_c3 := registro2.timpuesto_c3;
            v_registros_compras_001.timpuesto2 := registro2.timpuesto2;
            v_registros_compras_001.tisc := registro2.tisc;
            v_registros_compras_001.tisc2 := registro2.tisc2;
            v_registros_compras_001.totrostri := registro2.totrostri;
            v_registros_compras_001.totrostri2 := registro2.totrostri2;
            v_registros_compras_001.ticbper := registro2.ticbper;
            v_registros_compras_001.ticbper2 := registro2.ticbper2;
            v_registros_compras_001.tgeneral := registro2.tgeneral;
            v_registros_compras_001.tgeneral2 := registro2.tgeneral2;
            IF ( v_registros_compras_001.signo < 0 ) THEN
                v_registros_compras_001.tinafecto := abs(v_registros_compras_001.tinafecto) * -1;
                v_registros_compras_001.tinafecto2 := abs(v_registros_compras_001.tinafecto2) * -1;
            END IF;

            v_swsalio := 'S';
            PIPE ROW ( v_registros_compras_001 );
        END LOOP;

        IF ( v_swsalio = 'N' ) THEN
            PIPE ROW ( v_registros_compras_001 );
        END IF;
    END LOOP;
END sp00_saca_registros_compras_001;

/

--------------------------------------------------------
--  DDL for Function SP_REGCOMPRASCONSISTENCIA
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP_REGCOMPRASCONSISTENCIA" (
    pin_id_cia    IN  NUMBER,
    pin_periodo   IN  NUMBER,
    pin_mes       IN  NUMBER,
    pin_libro     IN  VARCHAR2,
    pin_asiento1  IN  NUMBER,
    pin_asiento2  IN  NUMBER
) RETURN tbl_sp_regcomprasconsistencia
    PIPELINED
AS

    rec rec_sp_regcomprasconsistencia := rec_sp_regcomprasconsistencia(NULL, NULL, NULL, NULL, NULL,
                              NULL, NULL, NULL, NULL, NULL,
                              NULL, NULL, NULL, NULL, NULL,
                              NULL, NULL, NULL, NULL, NULL,
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
            d1.*,
            d2.descri    AS deslib,
            d3.nombre,
            d4.descri    AS descos,
            dm.desmon,
            dm.simbolo,
            tc.abrevi
        FROM
                 asiendet d1
            INNER JOIN tlibro    d2 ON d1.id_cia = d2.id_cia
                                    AND ( d1.libro = d2.codlib )
            INNER JOIN pcuentas  d3 ON d1.id_cia = d3.id_cia
                                      AND ( d1.cuenta = d3.cuenta )
            LEFT OUTER JOIN tccostos  d4 ON d1.id_cia = d4.id_cia
                                           AND ( d1.ccosto = d4.codigo )
            LEFT OUTER JOIN tmoneda   dm ON dm.id_cia = d1.id_cia
                                          AND ( dm.codmon = d1.moneda )
            LEFT OUTER JOIN tdocume   tc ON tc.id_cia = d1.id_cia
                                          AND ( tc.codigo = d1.tdocum )
        WHERE
            ( d1.id_cia = pin_id_cia )
            AND ( d1.periodo = pin_periodo )
            AND ( d1.mes = pin_mes )
            AND ( d1.libro = pin_libro )
            AND ( d1.asiento BETWEEN pin_asiento1 AND pin_asiento2 )
        ORDER BY
            d1.periodo,
            d1.mes,
            d1.libro,
            d1.asiento,
            d1.item,
            d1.sitem
    ) LOOP
        rec.id_cia := i.id_cia;
        rec.periodo := i.periodo;
        rec.mes := i.mes;
        rec.libro := i.libro;
        rec.asiento := i.asiento;
        rec.item := i.item;
        rec.sitem := i.sitem;
        rec.concep := i.concep;
        rec.fecha := i.fecha;
        rec.tasien := i.tasien;
        rec.topera := i.topera;
        rec.cuenta := i.cuenta;
        rec.dh := i.dh;
        rec.moneda := i.moneda;
        rec.importe := i.importe;
        rec.impor01 := i.impor01;
        rec.impor02 := i.impor02;
        rec.debe := i.debe;
        rec.debe01 := i.debe01;
        rec.debe02 := i.debe02;
        rec.haber := i.haber;
        rec.haber01 := i.haber01;
        rec.haber02 := i.haber02;
        rec.tcambio01 := i.tcambio01;
        rec.tcambio02 := i.tcambio02;
        rec.ccosto := i.ccosto;
        rec.proyec := i.proyec;
        rec.subcco := i.subcco;
        rec.tipo := i.tipo;
        rec.docume := i.docume;
        rec.codigo := i.codigo;
        rec.razon := i.razon;
        rec.tident := i.tident;
        rec.dident := i.dident;
        rec.tdocum := i.tdocum;
        rec.serie := i.serie;
        rec.numero := i.numero;
        rec.fdocum := i.fdocum;
        rec.usuari := i.usuari;
        rec.fcreac := i.fcreac;
        rec.factua := i.factua;
        rec.regcomcol := i.regcomcol;
        rec.swprovicion := i.swprovicion;
        rec.saldo := i.saldo;
        rec.swgasoper := i.swgasoper;
        rec.codporret := i.codporret;
        rec.swchkconcilia := i.swchkconcilia;
        rec.ctaalternativa := i.ctaalternativa;
        rec.deslib := i.deslib;
        rec.nombre := i.nombre;
        rec.descos := i.descos;
        rec.desmon := i.desmon;
        rec.simbolo := i.simbolo;
        rec.abrevi := i.abrevi;
        PIPE ROW ( rec );
    END LOOP;
END sp_regcomprasconsistencia;

/

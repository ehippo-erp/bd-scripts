--------------------------------------------------------
--  DDL for Function SP_RPT_CAJACHICA_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "USR_TSI_SUITE"."SP_RPT_CAJACHICA_001" (
    pin_id_cia   IN  INTEGER,
    pin_tipcaja  IN  INTEGER,
    pin_doccaja  IN  INTEGER
) RETURN tbl_cajachica_001
    PIPELINED
AS

    rec rec_cajachica_001 := rec_cajachica_001(NULL, NULL, NULL, NULL, NULL,
                  NULL, NULL, NULL, NULL, NULL,
                  NULL, NULL, NULL, NULL, NULL,
                  NULL, NULL, NULL, NULL, NULL,
                  NULL, NULL, NULL, NULL, NULL,
                  NULL, NULL, NULL, NULL, NULL,
                  NULL, NULL, NULL, NULL, NULL,
                  NULL, NULL, NULL, NULL, NULL,
                  NULL, NULL, NULL, NULL, NULL,
                  NULL, NULL, NULL, NULL, NULL,
                  NULL, NULL, NULL, NULL, NULL,
                  NULL, NULL, NULL, NULL, NULL,
                  NULL, NULL, NULL, NULL, NULL,
                  NULL, NULL, NULL);
    CURSOR cur_select IS
    SELECT
        da.codpro,
        da.razon,
        da.tdocum,
        da.nserie,
        da.numero,
        da.femisi,
        da.tident,
        da.dident,
        da.fvenci,
        (
            CASE
                WHEN da.tdocum = '02' THEN
                    da.base01
                ELSE
                    da.impor01
            END
        ) * dc.signo AS impor01,
        (
            CASE
                WHEN da.tdocum = '02' THEN
                    da.impor01
                ELSE
                    da.base01
            END
        ) * dc.signo AS base01,
        da.igv01 * dc.signo      AS igv01,
        da.ddetrac,
        da.fdetrac,
        da.impdetrac,
        da.tipcaja,
        da.doccaja,
        da.tipo,
        da.docume,
        da.situac                AS sitdoc,
        da.ccosto                AS ccosdoc,
        da.ctagasto,
        da.concep                AS concepd,
        (
            CASE
                WHEN da.situac = 9 THEN
                    0
                ELSE
                    (
                        CASE
                            WHEN da.tdocum = '02' THEN
                                da.base01
                            ELSE
                                da.impor01
                        END
                    )
            END
        ) * dc.signo AS impor01p,
        (
            CASE
                WHEN da.situac = 9 THEN
                    0
                ELSE
                    (
                        CASE
                            WHEN da.tdocum = '02' THEN
                                da.base02
                            ELSE
                                da.impor02
                        END
                    )
            END
        ) * dc.signo AS impor02p,
        abs(
            CASE
                WHEN da.situac = 9 THEN
                    0
                ELSE
                    (
                        CASE
                            WHEN da.tdocum = '02' THEN
                                da.impor01 - da.igv01
                            ELSE
                                da.impor01
                        END
                    )
            END
        ) * dc.signo AS impor01px,
        abs(
       --     CASE
           --     WHEN da.moneda <> 'PEN' THEN
            CASE
                WHEN da.situac = 9 THEN
                    0
                ELSE
                    (
                        CASE
                            WHEN da.tdocum = '02' THEN
                                da.impor02 - da.igv02
                            ELSE
                                da.impor02
                        END
                    )
            END
 --               ELSE
  --                  0
   --         END
        ) * dc.signo AS impor02px,
        CASE
            WHEN da.moneda <> 'PEN' THEN
                da.impor01 / da.impor02
            ELSE
                0
        END AS tcambiop,
        da.moneda                AS monprov,
        ca.femisi                AS feccaja,
        ca.codper,
        ca.concep,
        ca.motivo,
        ca.moneda,
        ca.codarea,
        ca.ccosto,
        da.subccosto,
        da.proyec,
        da.ctaalternativa,
        ca.aprobado,
        ca.caprob,
        ca.faprob,
        ca.tippago,
        ca.ctapago,
        ca.periodo,
        ca.mes,
        ca.librop                AS libro,
        ca.asientop              AS asiento,
        ca.situac,
        ca.fondo,
        dc.abrevi,
        pe.razonc                AS nomper,
        mo.desmon,
        mo.simbolo,
        ar.desarea,
        cc.descri                AS desccos,
        us.nombres               AS nomuser,
        mp.descri                AS despago,
        pc.nombre                AS nomcta,
        li.descri                AS deslib,
        dc.descri                AS desdoc,
        c2.descri                AS ncosdoc,
        p2.nombre                AS nctagasto,
        (
            CASE
                WHEN da.moneda = 'USD' THEN
                    (
                        CASE
                            WHEN da.tdocum = '02' THEN
                                da.base
                            ELSE
                                da.importe
                        END
                    )
                ELSE
                    0
            END
        ) * dc.signo AS impord
    FROM
        compr010  da
        LEFT OUTER JOIN compr040  ca ON ( ca.id_cia = da.id_cia )
                                       AND ( ca.tipo = da.tipcaja )
                                       AND ( ca.docume = da.doccaja )
        LEFT OUTER JOIN tdocume   dc ON ( dc.id_cia = da.id_cia )
                                      AND ( dc.codigo = da.tdocum )
        LEFT OUTER JOIN cliente   pe ON ( pe.id_cia = da.id_cia )
                                      AND ( pe.codcli = ca.codper )
        LEFT OUTER JOIN tmoneda   mo ON ( mo.id_cia = da.id_cia )
                                      AND ( mo.codmon = ca.moneda )
        LEFT OUTER JOIN areas     ar ON ( ar.id_cia = da.id_cia )
                                    AND ( ar.codarea = ca.codarea )
        LEFT OUTER JOIN tccostos  cc ON ( cc.id_cia = da.id_cia )
                                       AND ( cc.codigo = ca.ccosto )
        LEFT OUTER JOIN usuarios  us ON ( us.id_cia = da.id_cia )
                                       AND ( us.coduser = ca.caprob )
        LEFT OUTER JOIN m_pago    mp ON ( mp.id_cia = da.id_cia )
                                     AND ( mp.codigo = ca.tippago )
        LEFT OUTER JOIN pcuentas  pc ON ( pc.id_cia = da.id_cia )
                                       AND ( pc.cuenta = ca.ctapago )
        LEFT OUTER JOIN tlibro    li ON ( li.id_cia = da.id_cia )
                                     AND ( li.codlib = ca.librop )
        LEFT OUTER JOIN tccostos  c2 ON ( c2.id_cia = da.id_cia )
                                       AND ( c2.codigo = da.ccosto )
        LEFT OUTER JOIN pcuentas  p2 ON ( p2.id_cia = da.id_cia )
                                       AND ( p2.cuenta = da.ctagasto )
    WHERE
            da.id_cia = pin_id_cia
        AND da.tipcaja = pin_tipcaja
        AND da.doccaja = pin_doccaja;

BEGIN
    FOR r IN cur_select LOOP
        rec.id_cia := pin_id_cia;
        rec.codpro := r.codpro;
        rec.razon := r.razon;
        rec.tdocum := r.tdocum;
        rec.nserie := r.nserie;
        rec.numero := r.numero;
        rec.femisi := r.femisi;
        rec.tident := r.tident;
        rec.dident := r.dident;
        rec.fvenci := r.fvenci;
        rec.impor01 := r.impor01;
        rec.base01 := r.base01;
        rec.igv01 := r.igv01;
        rec.ddetrac := r.ddetrac;
        rec.fdetrac := r.fdetrac;
        rec.impdetrac := r.impdetrac;
        rec.tipcaja := r.tipcaja;
        rec.doccaja := r.doccaja;
        rec.tipo := r.tipo;
        rec.docume := r.docume;
        rec.sitdoc := r.sitdoc;
        rec.abrsitdoc :=
            CASE
                WHEN r.sitdoc = 0 THEN
                    'Lib'
                WHEN r.sitdoc = 1 THEN
                    'Pro'
                WHEN r.sitdoc = 2 THEN
                    'Con'
                WHEN r.sitdoc = 8 THEN
                    'Eli'
                WHEN r.sitdoc = 9 THEN
                    'Anu'
                ELSE ''
            END;

        rec.ccosdoc := r.ccosdoc;
        rec.ctagasto := r.ctagasto;
        rec.concepd := r.concepd;
        rec.impor01p := r.impor01p;
        rec.impor02p := r.impor02p;
        rec.impor01px := r.impor01px;
        rec.impor02px := r.impor02px;
        rec.tcambiop := r.tcambiop;
        rec.monprov := r.monprov;
        rec.feccaja := r.feccaja;
        rec.codper := r.codper;
        rec.concep := r.concep;
        rec.motivo := r.motivo;
        rec.desmot :=
            CASE
                WHEN r.motivo = 0 THEN
                    'Registro de compras'
                WHEN r.motivo = 1 THEN
                    'Caja chica'
                WHEN r.motivo = 2 THEN
                    'Gastos de viaje'
                WHEN r.motivo = 3 THEN
                    'Bancos'
                WHEN r.motivo = 4 THEN
                    'Caja tienda'
                WHEN r.motivo = 5 THEN
                    'Costeo de importación'
                ELSE 'ninguno'
            END;

        rec.moneda := r.moneda;
        rec.codarea := r.codarea;
        rec.ccosto := r.ccosto;
        rec.subccosto := r.subccosto;
        rec.proyec := r.proyec;
        rec.ctaalternativa := r.ctaalternativa;
        rec.aprobado := r.aprobado;
        rec.caprob := r.caprob;
        rec.faprob := r.faprob;
        rec.tippago := r.tippago;
        rec.ctapago := r.ctapago;
        rec.periodo := r.periodo;
        rec.mes := r.mes;
        rec.libro := r.libro;
        rec.asiento := r.asiento;
        rec.situac := r.situac;
        rec.dessit :=
            CASE
                WHEN r.situac = 0 THEN
                    'Libre'
                WHEN r.situac = 1 THEN
                    'En proceso'
                WHEN r.situac = 2 THEN
                    'Contabilizado'
                WHEN r.situac = 8 THEN
                    'Eliminado'
                WHEN r.situac = 9 THEN
                    'Anulado'
                ELSE ''
            END;

        rec.abrevi := r.abrevi;
        rec.nomper := r.nomper;
        rec.desmon := r.desmon;
        rec.simbolo := r.simbolo;
        rec.desarea := r.desarea;
        rec.desccos := r.desccos;
        rec.nomuser := r.nomuser;
        rec.despago := r.despago;
        rec.nomcta := r.nomcta;
        rec.deslib := r.deslib;
        rec.desdoc := r.desdoc;
        rec.ncosdoc := r.ncosdoc;
        rec.nctagasto := r.nctagasto;
        rec.impord := r.impord;
        rec.fondo := r.fondo;
        PIPE ROW ( rec );
    END LOOP;
END sp_rpt_cajachica_001;

/

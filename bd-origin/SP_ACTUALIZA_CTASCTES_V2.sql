--------------------------------------------------------
--  DDL for Procedure SP_ACTUALIZA_CTASCTES_V2
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_ACTUALIZA_CTASCTES_V2" (
    pin_id_cia IN NUMBER
) AS
BEGIN
    FOR j IN (
        SELECT
            d.id_cia,
            d.numint,
            d.tipdoc,
            d.series,
            d.numdoc,
            d.femisi,
            d.lugemi,
            d.situac,
            d.id,
            d.codmot,
            d.motdoc,
            d.codalm,
            d.almdes,
            d.codcli,
            d.tident,
            d.ruc,
            d.razonc,
            d.direc1,
            d.codenv,
            d.codcpag,
            d.codtra,
            d.codven,
            d.comisi,
            d.incigv,
            d.destin,
            d.totbru,
            d.descue,
            d.desesp,
            d.monafe,
            d.monina,
            d.porigv,
            d.monigv,
            d.preven,
            d.costo,
            d.tipmon,
            d.tipcam,
            d.atenci,
            d.valide,
            d.plaent,
            d.ordcom,
            d.numped,
            d.gasvin,
            d.seguro,
            d.flete,
            d.desfle,
            d.desexp,
            d.gasadu,
            d.pesbru,
            d.pesnet,
            d.bultos,
            d.presen,
            d.marcas,
            d.numdue,
            d.fnumdue,
            d.fembarq,
            d.fentreg,
            d.valfob,
            d.guipro,
            d.fguipro,
            d.facpro,
            d.ffacpro,
            d.cargo,
            d.codsuc,
            d.fcreac,
            d.factua,
            d.acuenta,
            d.ucreac,
            d.usuari,
            d.swacti,
            d.codarea,
            d.coduso,
            d.opnumdoc,
            d.opcargo,
            d.opnumite,
            d.opcodart,
            d.optipinv,
            d.totcan,
            d.fordcom,
            d.ordcomni,
            d.motvarios,
            d.horing,
            d.fecter,
            d.horter,
            d.codtec,
            d.guiarefe,
            d.desenv,
            d.codaux,
            d.codetapauso,
            d.codsec,
            d.numvale,
            d.fecvale,
            d.swtrans,
            d.desseg,
            d.desgasa,
            d.desnetx,
            d.despreven,
            d.codcob,
            d.codveh,
            d.codpunpar,
            d.ubigeopar,
            d.direccpar,
            d.monisc,
            d.monotr,
            d.monexo,
            d.observ,
            d.proyec,
            d.countadj
        FROM
            documentos_cab d
        WHERE
                d.id_cia = pin_id_cia
            AND d.tipdoc IN ( 1, 3, 7, 8 )
            AND d.situac = 'F'
            AND NOT EXISTS (
                SELECT
                    *
                FROM
                    dcta100
                WHERE
                        id_cia = d.id_cia
                    AND numint = d.numint
            )
    ) LOOP
        INSERT INTO dcta100 (
            id_cia,
            numint,
            codcli,
            tipdoc,
            docume,
            serie,
            numero,
            periodo,
            mes,
            femisi,
            fvenci,
            codban,
            refere01,
            refere02,
            tipmon,
            importe,
            importemn,
            importeme,
            saldomn,
            saldome,
            concpag,
            codcob,
            codven,
            comisi,
            codsuc,
            fcreac,
            factua,
            usuari,
            tipcam,
            operac,
            codubi
        ) VALUES (
            j.id_cia,
            j.numint,
            j.codcli,
            j.tipdoc,
            j.series
            || sp000_ajusta_string(to_char(j.numdoc), 7, '0', 'R'),
            j.series,
            j.numdoc,
            EXTRACT(YEAR FROM j.femisi),
            EXTRACT(MONTH FROM j.femisi),
            j.femisi,
            j.fecter,
            0,
            j.numped,
            j.ordcom,
            j.tipmon,
            j.preven,
            j.preven,
            j.preven,
            0,
            0,
            j.codcpag,
            j.codcob,
            j.codven,
            j.comisi,
            j.codsuc,
            current_timestamp,
            current_timestamp,
            j.usuari,
            j.tipcam,
            0,
            1
        );
        COMMIT;
        sp_actualiza_saldo_dcta100(j.id_cia, j.numint);
    END LOOP;

    

END sp_actualiza_ctasctes_v2;

/

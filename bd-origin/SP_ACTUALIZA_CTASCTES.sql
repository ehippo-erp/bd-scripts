--------------------------------------------------------
--  DDL for Procedure SP_ACTUALIZA_CTASCTES
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_ACTUALIZA_CTASCTES" 
(
  PIN_ID_CIA IN NUMBER 
, pin_numint IN NUMBER 
) AS 
BEGIN


    FOR j IN (

        select 
            d.ID_CIA,
            d.NUMINT,
            d.TIPDOC,
            d.SERIES,
            d.NUMDOC,
            d.FEMISI,
            d.LUGEMI,
            d.SITUAC,
            d.ID,
            d.CODMOT,
            d.MOTDOC,
            d.CODALM,
            d.ALMDES,
            d.CODCLI,
            d.TIDENT,
            d.RUC,
            d.RAZONC,
            d.DIREC1,
            d.CODENV,
            d.CODCPAG,
            d.CODTRA,
            d.CODVEN,
            d.COMISI,
            d.INCIGV,
            d.DESTIN,
            d.TOTBRU,
            d.DESCUE,
            d.DESESP,
            d.MONAFE,
            d.MONINA,
            d.PORIGV,
            d.MONIGV,
            d.PREVEN,
            d.COSTO,
            d.TIPMON,
            d.TIPCAM,
            d.ATENCI,
            d.VALIDE,
            d.PLAENT,
            d.ORDCOM,
            d.NUMPED,
            d.GASVIN,
            d.SEGURO,
            d.FLETE,
            d.DESFLE,
            d.DESEXP,
            d.GASADU,
            d.PESBRU,
            d.PESNET,
            d.BULTOS,
            d.PRESEN,
            d.MARCAS,
            d.NUMDUE,
            d.FNUMDUE,
            d.FEMBARQ,
            d.FENTREG,
            d.VALFOB,
            d.GUIPRO,
            d.FGUIPRO,
            d.FACPRO,
            d.FFACPRO,
            d.CARGO,
            d.CODSUC,
            d.FCREAC,
            d.FACTUA,
            d.ACUENTA,
            d.UCREAC,
            d.USUARI,
            d.SWACTI,
            d.CODAREA,
            d.CODUSO,
            d.OPNUMDOC,
            d.OPCARGO,
            d.OPNUMITE,
            d.OPCODART,
            d.OPTIPINV,
            d.TOTCAN,
            d.FORDCOM,
            d.ORDCOMNI,
            d.MOTVARIOS,
            d.HORING,
            d.FECTER,
            d.HORTER,
            d.CODTEC,
            d.GUIAREFE,
            d.DESENV,
            d.CODAUX,
            d.CODETAPAUSO,
            d.CODSEC,
            d.NUMVALE,
            d.FECVALE,
            d.SWTRANS,
            d.DESSEG,
            d.DESGASA,
            d.DESNETX,
            d.DESPREVEN,
            d.CODCOB,
            d.CODVEH,
            d.CODPUNPAR,
            d.UBIGEOPAR,
            d.DIRECCPAR,
            d.MONISC,
            d.MONOTR,
            d.MONEXO,
            d.OBSERV,
            d.PROYEC,
            d.COUNTADJ
        from documentos_cab d
        where d.id_cia = pin_id_cia 
        and d.numint = pin_numint
        and d.situac = 'F'
        and not EXISTS (select * from dcta100 
                    where id_cia = d.id_cia
                    and numint = d.numint)
    ) LOOP

        insert into dcta100(
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

		)
		values (
			j.id_cia,
			j.numint,
			j.codcli,
			j.tipdoc,

			j.series ||  SP000_AJUSTA_STRING(to_char(j.numdoc), 7, '0', 'R'),
			j.series,
			j.numdoc,

		 	EXTRACT(YEAR FROM j.femisi),
			EXTRACT(month FROM j.femisi),
			j.femisi,

			j.fecter,


			0,


			substr(j.numped,1,24),
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

			CURRENT_TIMESTAMP,
			CURRENT_TIMESTAMP,
			j.usuari,


			j.tipcam,

			0,

			1

		);
        COMMIT; 
        sp_actualiza_saldo_dcta100(j.id_cia, j.numint);

      END LOOP;



END SP_ACTUALIZA_CTASCTES;

/

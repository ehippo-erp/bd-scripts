--------------------------------------------------------
--  DDL for Trigger DESPUES_ACTUALIZAR_DOCUMENTOS_CAB
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."DESPUES_ACTUALIZAR_DOCUMENTOS_CAB" AFTER
    UPDATE ON "USR_TSI_SUITE".documentos_cab
    FOR EACH ROW
DECLARE
    v_conteo        INTEGER;
    v_totmonafecto  NUMERIC(16, 2);
    v_totpercepcion NUMERIC(16, 2);
    v_moninafecto   NUMERIC(16, 4);
    v_swgenper      VARCHAR(2);
    v_lfactordesesp DOUBLE PRECISION;
    v_lpreven       DOUBLE PRECISION;
    v_ldesesp       DOUBLE PRECISION;
BEGIN

  /*CADA QUE SE CAMBIA EL TIPO DE DOCUMENTO SE ACTUALIZARA EL DETALLE, PARA LOS REPORTES */
  /* UPDATE DOCUMENTOS_DET SET TIPDOC=NEW.TIPDOC WHERE NUMINT=NEW.NUMINT;*/
    IF ( ( :old.situac <> :new.situac ) ) THEN
        v_conteo := 0;
        BEGIN
            SELECT
                COUNT(0)
            INTO v_conteo
            FROM
                documentos_situac_max
            WHERE
                    id_cia = :new.id_cia
                AND numint = :new.numint
                AND situac = :new.situac;

        EXCEPTION
            WHEN no_data_found THEN
                v_conteo := 0;
        END;

        IF ( v_conteo = 0 ) THEN
            INSERT INTO documentos_situac_max (
                id_cia,
                numint,
                situac,
                usuari
            ) VALUES (
                :new.id_cia,
                :new.numint,
                :new.situac,
                :new.usuari
            );

        END IF;
   /* FACTURACION ELECTRÓNICA Y GUIAS DE REMISION ELECTRONICAS*/

        BEGIN
            SELECT
                COUNT(0)
            INTO v_conteo
            FROM
                documentos_cab_envio_sunat
            WHERE
                    id_cia = :new.id_cia
                AND numint = :new.numint;

        EXCEPTION
            WHEN no_data_found THEN
                v_conteo := 0;
        END;

        IF (
            ( v_conteo = 0 )
            AND ( :new.situac = 'F' )
            AND ( ( :new.tipdoc = 1 ) OR ( :new.tipdoc = 3 ) OR ( :new.tipdoc = 7 ) OR ( :new.tipdoc = 8 ) OR ( :new.tipdoc = 41 ) OR
            ( :new.tipdoc = 102 ) )
        ) THEN
            INSERT INTO documentos_cab_envio_sunat (
                id_cia,
                numint,
                estado,
                fenvio,
                frespuesta,
                xml,
                cxml,
                ctxt,
                cres,
                cbaj,
                inweb
            ) VALUES (
                :new.id_cia,
                :new.numint,
                0,
                NULL,
                NULL,
                NULL,
                0,
                0,
                0,
                0,
                0
            );

        END IF;

    END IF;
    -----------------------------

    IF :new.numint <> :old.numint OR :new.tipdoc <> :old.tipdoc OR :new.series <> :old.series OR :new.numdoc <> :old.numdoc OR :new.femisi <> :old.femisi

    OR :new.situac <> :old.situac OR :new.codcli <> :old.codcli OR :new.tipmon <> :old.tipmon OR :new.tipcam <> :old.tipcam OR :new.totbru <> :old.totbru

    OR :new.descue <> :old.descue OR :new.desesp <> :old.desesp OR :new.monafe <> :old.monafe OR :new.monina <> :old.monina OR :new.porigv <> :old.porigv

    OR :new.monigv <> :old.monigv OR :new.preven <> :old.preven THEN
        INSERT INTO documentos_cab_log (
            id_cia,
            locali,
            numint,
            tipdoc,
            series,
            numdoc,
            femisi,
            situac,
            codcli,
            tipmon,
            tipcam,
            totbru,
            descue,
            desesp,
            monafe,
            monina,
            porigv,
            monigv,
            preven,
            usuari
        ) VALUES (
            :new.id_cia,
            - 1,
            :new.numint,
            :new.tipdoc,
            :new.series,
            :new.numdoc,
            :new.femisi,
            :new.situac,
            :new.codcli,
            :new.tipmon,
            :new.tipcam,
            :new.totbru,
            :new.descue,
            :new.desesp,
            :new.monafe,
            :new.monina,
            :new.porigv,
            :new.monigv,
            :new.preven,
            :new.usuari
        );

    END IF;

END;
/
ALTER TRIGGER "USR_TSI_SUITE"."DESPUES_ACTUALIZAR_DOCUMENTOS_CAB" ENABLE;

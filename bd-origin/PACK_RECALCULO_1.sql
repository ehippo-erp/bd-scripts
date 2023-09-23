--------------------------------------------------------
--  DDL for Package Body PACK_RECALCULO
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_RECALCULO" AS

    FUNCTION calculadesesp (
        preven         NUMERIC,
        montoanterior  NUMERIC,
        nuevototal     NUMERIC
    ) RETURN NUMERIC IS
        descuentoesp NUMERIC(16, 5) := 0;
    BEGIN
        descuentoesp := nuevototal - montoanterior;
        RETURN descuentoesp;
    END;

    FUNCTION acumuladetalles (
        pin_id_cia  IN  NUMBER,
        pin_numint  IN  NUMBER
    ) RETURN tacumuladetalle IS

        CURSOR cur_detalle IS
        SELECT
            d.numint,
            d.numite,
            d.monafe,
            d.monina,
            d.monigv,
            d.importe,
            d.importe_bruto,
            d.porigv,
            d.saldo,
            c.tipdoc,
            d.cantid,
            d.seguro,
            d.flete,
            d.tara,
            d.canref,
            d.monisc,
            d.monotr,
            d.monexo,
            d.montgr
        FROM
            documentos_det  d
            LEFT OUTER JOIN documentos_cab  c ON c.id_cia = pin_id_cia
                                                AND c.numint = d.numint
        WHERE
                d.id_cia = pin_id_cia
            AND d.numint = pin_numint;

        v_record         tacumuladetalle := tacumuladetalle(0, 0, 0, 0, 0,
                0, 0, 0, 0, 0,
                0, 0, 0, 0, 0,
                0, 0, 0, 0, 0,
                0, 0, 0, 0, 0);
        facfelectronica  VARCHAR2(1) := 'N';
    BEGIN
        BEGIN
            SELECT
                TRIM(vstrg)
            INTO facfelectronica
            FROM
                factor
            WHERE
                    id_cia = pin_id_cia
                AND codfac = 375;

        EXCEPTION
            WHEN no_data_found THEN
                facfelectronica := 'N';
        END;

        v_record.totalacuenta := 0;
        v_record.totalimporteinafecto := 0;
        FOR registro IN cur_detalle LOOP
            v_record.totalcantidad := v_record.totalcantidad + registro.cantid;
            v_record.totalneto := v_record.totalneto + registro.importe - registro.montgr;
            v_record.totalbruto := v_record.totalbruto + registro.importe_bruto - registro.montgr;
            v_record.totalsaldo := v_record.totalsaldo + registro.saldo;
            v_record.totalisc := v_record.totalisc + registro.monisc;
            v_record.totalotrotributos := v_record.totalotrotributos + registro.monotr;
            v_record.totalexonerado := v_record.totalexonerado + registro.monexo;
            v_record.totalafecto := v_record.totalafecto + registro.monafe;
            v_record.totalgratuito := v_record.totalgratuito + registro.montgr;
            IF registro.monafe <> 0 THEN 
	  /*Importante que considere los valores en negativo */
                v_record.totalimporteafecto := v_record.totalimporteafecto + registro.importe;
            END IF;

            v_record.totalinafecto := v_record.totalinafecto + registro.monina;
            IF registro.monina <> 0 THEN /* Importante que considere los valores en negativo */
                v_record.totalimporteinafecto := v_record.totalimporteinafecto + registro.importe;
            END IF;

            IF ( facfelectronica = 'S' ) THEN
                v_record.totaligv := v_record.totaligv + registro.monigv;
            ELSE
                v_record.totaligv := v_record.totaligv + ( ( ( registro.monafe + registro.monisc ) * registro.porigv ) / 100 );
            END IF;

            v_record.totalpesotara := v_record.totalpesotara + registro.tara;




      /* Modificado 16-02-16 Oscar Campo ACUENTA solo tendrá un valor en el caso de
        facturas que se aplica un anticipo , ya que el item con importe en negativo
        viene a ser el valor del anticipo a aplicar, 2018-05-02 adicionalmente se condiciona las NC */
            IF (
                ( ( registro.tipdoc = 1 ) OR ( registro.tipdoc = 3 ) OR ( registro.tipdoc = 7 ) ) AND ( registro.importe < 0 )
            ) THEN
                v_record.totalacuenta := v_record.totalacuenta + abs(registro.importe);
            END IF;

        END LOOP;

        RETURN v_record;
    END acumuladetalles;

    PROCEDURE recalcula_toles (
        pin_id_cia           IN  NUMBER,
        pin_numint           IN  NUMBER,
        pin_sw_actualizacab  IN  VARCHAR2 DEFAULT 'S',
        pin_montoredondeo    IN  NUMERIC DEFAULT 0,
        pin_reverdesesp      IN  VARCHAR2 DEFAULT 'S'
    ) AS

        rtotales                  tacumuladetalle;
        rdoccab                   documentos_cab%rowtype;
        v_netofordesesp           NUMERIC(15, 6) := 0;
        v_montoredondeo           NUMERIC(15, 6) := pin_montoredondeo;
        faccalculatotalsinicbper  VARCHAR2(1) := 'N';
    BEGIN
        BEGIN
            SELECT
                TRIM(vstrg)
            INTO faccalculatotalsinicbper
            FROM
                factor
            WHERE
                    id_cia = pin_id_cia
                AND codfac = 432;

        EXCEPTION
            WHEN no_data_found THEN
                faccalculatotalsinicbper := 'N';
        END;

        SELECT
            *
        INTO rdoccab
        FROM
            documentos_cab
        WHERE
                id_cia = pin_id_cia
            AND numint = pin_numint;

        rtotales := acumuladetalles(pin_id_cia, pin_numint);

  /* Calcula el monto afecto según el importe afecto */
        IF rtotales.totalimporteafecto > 0 THEN
            IF upper(rdoccab.incigv) = 'S' THEN
                rtotales.totalafecto := round(rtotales.totalimporteafecto /(1 +(rdoccab.porigv / 100)), 2) - rtotales.totalisc;

            ELSE
                rtotales.totalafecto := rtotales.totalimporteafecto - rtotales.totalisc;
            END IF;
        END IF;

  /* Descuento especial - Si no tiene descuento no hace nada */

        IF ( rdoccab.incigv = 'S' ) THEN
            v_netofordesesp := rtotales.totalneto;
        ELSE
            v_netofordesesp := rtotales.totalneto + rtotales.totaligv;
        END IF;

        IF pin_reverdesesp = 'S' THEN
            v_montoredondeo := v_netofordesesp;
        END IF;
        IF NOT ( v_montoredondeo = 0 ) THEN
            rtotales.totaldesesp := round((calculadesesp(rdoccab.preven, v_netofordesesp, v_montoredondeo)), 2);
        ELSE
            IF ( rdoccab.desesp <> 0 ) THEN
                rtotales.totaldesesp := rdoccab.desesp;
            ELSE
                rtotales.totaldesesp := 0;
            END IF;
        END IF;

        IF rtotales.totaldesesp <> 0 THEN
            rtotales.totaldesespigv := rtotales.totaldesesp / ( ( 100 + rdoccab.porigv ) / 100 );
        ELSE
            rtotales.totaldesespigv := 0;
        END IF;

        IF rtotales.totalbruto <> 0 THEN
            rtotales.pordes := rtotales.totalneto / rtotales.totalbruto;
        ELSE
            rtotales.pordes := 0;
        END IF;

        rtotales.totaligv := ( ( rtotales.totalafecto + rtotales.totalisc + rtotales.totaldesespigv ) * rdoccab.porigv ) / 100;

        IF
            ( upper(rdoccab.incigv) = 'S' ) AND ( rtotales.totalisc = 0 )
        THEN
            rtotales.totalafecto := rtotales.totalneto + rtotales.totaldesesp - ( rtotales.totalinafecto + rtotales.totaligv + rtotales.
            totalexonerado );

            rtotales.totalprecioventa := rtotales.totalneto + rtotales.totaldesesp + rtotales.totalisc;
            rtotales.totalneto := rtotales.totalafecto + rtotales.totalinafecto + rtotales.totalexonerado;
        ELSE

   -- En caso tenga descuento especial y no tenga afecto el IGV 
            IF rtotales.totalafecto <> 0 THEN
                rtotales.totalafecto := rtotales.totalafecto + rtotales.totaldesespigv;
            ELSE
                rtotales.totalinafecto := rtotales.totalinafecto + rtotales.totaldesespigv;
            END IF;

            rtotales.totalprecioventa := rtotales.totalafecto + rtotales.totalinafecto + rtotales.totalexonerado + rtotales.totaligv +
            rtotales.totalisc;

            rtotales.totalneto := ( rtotales.totalafecto + rtotales.totaldesespigv ) + rtotales.totalinafecto + rtotales.totalexonerado;

        END IF;

        IF rtotales.pordes <> 0 THEN
            rtotales.totalbruto := ( rtotales.totalafecto + rtotales.totalinafecto + rtotales.totalexonerado ) / rtotales.pordes;
        ELSE
            rtotales.totalbruto := 0;
        END IF;

        rtotales.totaldescuento := ( rtotales.totalbruto - rtotales.totalneto );
        rtotales.totalsaldo := round(rtotales.totalsaldo, 3);
        rtotales.totalcantidad := round(rtotales.totalcantidad, 3);
        rdoccab.desesp := rtotales.totaldesesp;
        rdoccab.totcan := rtotales.totalcantidad;
        rdoccab.totbru := rtotales.totalbruto;
        rdoccab.descue := rtotales.totaldescuento;
        rdoccab.monigv := rtotales.totaligv;
        rdoccab.monisc := rtotales.totalisc;
        rdoccab.monotr := rtotales.totalotrotributos;
        rdoccab.monexo := rtotales.totalexonerado;
        rdoccab.montgr := rtotales.totalgratuito;
        IF faccalculatotalsinicbper = 'S' THEN
            rdoccab.preven := rtotales.totalprecioventa + rdoccab.seguro + rdoccab.flete + rdoccab.gasadu;
        ELSE
            rdoccab.preven := rtotales.totalprecioventa + rdoccab.seguro + rdoccab.flete + rdoccab.gasadu + rdoccab.monotr;
        END IF;

        rdoccab.monafe := rtotales.totalafecto;
        rdoccab.monina := rtotales.totalinafecto;
--        rdoccab.totalclase90 := rtotales.totalclase90;
        IF
            ( round(rdoccab.preven, 2) = 0 ) AND ( round(rdoccab.monafe + rdoccab.monina + rdoccab.monigv, 2) = 0 )
        THEN
            rdoccab.monafe := 0;
            rdoccab.monina := 0;
            rdoccab.monigv := 0;
        END IF;

 --       rdoccab.wtotnetx := rdoccab.monafe + rdoccab.monina;

        rdoccab.pesbru := round(rtotales.totalpeso, 0);
        rdoccab.pesnet := rtotales.totalpeso;
--        rdoccab.pesonetocanref := rtotales.totalpesoneto;
--        rdoccab.pesotara := rtotales.totalpesotara;
--        rdoccab.pesobrutocalc := rtotales.totalpesobruto;
        IF ( ( rdoccab.tipdoc = 1 ) OR ( rdoccab.tipdoc = 3 ) OR ( rdoccab.tipdoc = 7 ) ) THEN
            rdoccab.acuenta := rtotales.totalacuenta;
        END IF;

        IF
            ( ( rdoccab.tipdoc = 1 ) OR ( rdoccab.tipdoc = 3 ) OR ( rdoccab.tipdoc = 7 ) OR ( rdoccab.tipdoc = 8 ) ) AND ( rdoccab.
            swtrans = 1 )
        THEN
            IF
                ( rdoccab.monafe > 0 ) AND ( rdoccab.monina = 0 )
            THEN
                rdoccab.monafe := rdoccab.monafe - ( rdoccab.seguro + rdoccab.flete + rdoccab.gasadu );
            ELSE
                IF
                    ( rdoccab.monina > 0 ) AND ( rdoccab.monafe = 0 )
                THEN
                    rdoccab.monina := rdoccab.monina - ( rdoccab.seguro + rdoccab.flete + rdoccab.gasadu );

                END IF;
            END IF;

            rdoccab.totbru := rdoccab.totbru - ( rdoccab.seguro + rdoccab.flete + rdoccab.gasadu );

            rdoccab.preven := rdoccab.preven - ( rdoccab.seguro + rdoccab.flete + rdoccab.gasadu );

        END IF;

        IF pin_sw_actualizacab = 'S' THEN
            UPDATE documentos_cab
            SET
                desesp = rdoccab.desesp,
                totcan = rdoccab.totcan,
                totbru = rdoccab.totbru,
                descue = rdoccab.descue,
                monigv = rdoccab.monigv,
                monisc = rdoccab.monisc,
                monotr = rdoccab.monotr,
                monexo = rdoccab.monexo,
                montgr = rdoccab.montgr,
                preven = rdoccab.preven,
                monafe = rdoccab.monafe,
                monina = rdoccab.monina,
                pesbru = rdoccab.pesbru,
                pesnet = rdoccab.pesnet,
                acuenta = rdoccab.acuenta
            WHERE
                    id_cia = pin_id_cia
                AND numint = pin_numint;

            COMMIT;
        END IF;

    END recalcula_toles;

END pack_recalculo;

/

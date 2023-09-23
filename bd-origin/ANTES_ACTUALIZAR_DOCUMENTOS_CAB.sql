--------------------------------------------------------
--  DDL for Trigger ANTES_ACTUALIZAR_DOCUMENTOS_CAB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "USR_TSI_SUITE"."ANTES_ACTUALIZAR_DOCUMENTOS_CAB" BEFORE
    UPDATE ON "USR_TSI_SUITE".documentos_cab
    FOR EACH ROW
DECLARE
    v_verifica VARCHAR2(1);
BEGIN
    IF (
        ( :old.tipdoc = 1 OR :old.tipdoc = 3 OR :old.tipdoc = 7 OR :old.tipdoc = 8 )
        AND ( :new.numint = :old.numint )
        AND ( :new.tipdoc = :old.tipdoc )
        AND ( :new.series = :old.series )
        AND ( :new.numdoc = :old.numdoc )
        AND ( :new.femisi = :old.femisi )
        AND ( :new.id = :old.id )
        AND ( :new.codmot = :old.codmot )
        AND ( :new.motdoc = :old.motdoc )
        AND ( :new.codalm = :old.codalm )
        AND ( :new.almdes = :old.almdes )
        AND ( :new.codcli = :old.codcli )
        AND ( :new.ruc = :old.ruc )
        AND ( :new.razonc = :old.razonc )
        AND ( :new.direc1 = :old.direc1 )
        AND ( :new.codcpag = :old.codcpag )
        AND ( :new.comisi = :old.comisi )
        AND ( :new.incigv = :old.incigv )
        AND ( :new.destin = :old.destin )
        AND ( :new.totbru = :old.totbru )
        AND ( :new.descue = :old.descue )
        AND ( :new.desesp = :old.desesp )
        AND ( :new.monafe = :old.monafe )
        AND ( :new.monina = :old.monina )
        AND ( :new.porigv = :old.porigv )
        AND ( :new.monigv = :old.monigv )
        AND ( :new.preven = :old.preven )
        AND ( :new.costo = :old.costo )
        AND ( :new.tipmon = :old.tipmon )
        AND ( :new.tipcam = :old.tipcam )
        AND ( nvl(:new.ordcom, '0') = nvl(:old.ordcom, '0') )
        AND ( nvl(:new.numped, '0') = nvl(:old.numped, '0') )
        AND ( nvl(:new.gasvin, 0) = nvl(:old.gasvin, 0) )
        AND ( nvl(:new.seguro, 0) = nvl(:old.seguro, 0) )
        AND ( nvl(:new.flete, 0) = nvl(:old.flete, 0) )
        AND ( nvl(:new.desfle, '0') = nvl(:old.desfle, '0') )
        AND ( nvl(:new.desexp, 0) = nvl(:old.desexp, 0) )
        AND ( nvl(:new.gasadu, 0) = nvl(:old.gasadu, 0) )
        AND ( nvl(:new.valfob, 0) = nvl(:old.valfob, 0) )
        AND ( nvl(:new.acuenta, 0) = nvl(:old.acuenta, 0) )
        AND ( nvl(:new.totcan, 0) = nvl(:old.totcan, 0) )
        AND ( nvl(:new.guiarefe, '0') = nvl(:old.guiarefe, '0') )
        AND ( nvl(:new.codsec, 0) = nvl(:old.codsec, 0) )
        AND ( nvl(:new.despreven, '0') = nvl(:old.despreven, '0') )
    ) THEN
        v_verifica := 'N';
    ELSE
        v_verifica := 'S';
    END IF;

    IF v_verifica = 'S' THEN
        sp000_verifica_mes_cerrado_documentos_cab(:old.id_cia, :old.tipdoc, :old.numdoc, :old.femisi, :old.codcpag,
                                                 :old.situac, :new.situac);

        sp000_verifica_mes_cerrado_documentos_cab(:old.id_cia, :new.tipdoc, :new.numdoc, :new.femisi, :new.codcpag,
                                                 :old.situac, :new.situac);

    END IF;

    :new.factua := current_date;
/* CUANDO SE "ELIMINA" = "K"  UN DOCUMENTO DEBE BORRA EL NRO DE DOCUMENTO */
    IF (
        ( :old.situac <> 'K' )
        AND ( :new.situac = 'K' )
    ) THEN
        :new.numdoc := 0;
    END IF;

END;
/
ALTER TRIGGER "USR_TSI_SUITE"."ANTES_ACTUALIZAR_DOCUMENTOS_CAB" ENABLE;

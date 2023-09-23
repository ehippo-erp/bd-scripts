--------------------------------------------------------
--  DDL for Package Body PACK_DOCUMENTOS_DET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_DOCUMENTOS_DET" AS

    PROCEDURE sp_save (
        pin_id_cia       IN NUMBER,
        pin_datos        IN VARCHAR2,
        pin_opcdml       INTEGER,
        pin_responsecode OUT NUMBER,
        pin_response     OUT VARCHAR2
    ) AS

        o          json_object_t;
        rec_docdet documentos_det%rowtype;
        v_response VARCHAR2(1200) := '';
        e_integrity EXCEPTION;
        PRAGMA exception_init ( e_integrity, -2291 );
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_docdet.id_cia := pin_id_cia;
        rec_docdet.numint := o.get_number('numint');
        rec_docdet.numite := o.get_number('numite');
        rec_docdet.tipdoc := o.get_number('tipdoc');
        rec_docdet.series := o.get_string('series');
        rec_docdet.tipinv := o.get_number('tipinv');
        rec_docdet.codart := o.get_string('codart');
        rec_docdet.situac := o.get_string('situac');
        rec_docdet.codalm := o.get_string('codalm');
        rec_docdet.cantid := o.get_number('cantid');
        rec_docdet.canref := o.get_number('canref');
        rec_docdet.canped := o.get_number('canped');
        rec_docdet.saldo := o.get_number('saldo');
        rec_docdet.pordes1 := o.get_number('pordes1');
        rec_docdet.pordes2 := o.get_number('pordes2');
        rec_docdet.pordes3 := o.get_number('pordes3');
        rec_docdet.pordes4 := o.get_number('pordes4');
        rec_docdet.preuni := o.get_number('preuni');
        rec_docdet.cosuni := o.get_number('cosuni');
        rec_docdet.observ := o.get_string('observ');
        rec_docdet.usuari := o.get_string('usuari');
        rec_docdet.importe_bruto := o.get_number('importe_bruto');
        rec_docdet.importe := o.get_number('importe');
        rec_docdet.opnumdoc := o.get_number('opnumdoc');
        rec_docdet.opcargo := o.get_string('opcargo');
        rec_docdet.opnumite := o.get_number('opnumite');
        rec_docdet.optipinv := o.get_number('optipinv');
        rec_docdet.codund := o.get_string('codund');
        rec_docdet.largo := o.get_number('largo');
        rec_docdet.ancho := o.get_number('ancho');
        rec_docdet.altura := o.get_number('altura');
        rec_docdet.porigv := o.get_number('porigv');
        rec_docdet.monafe := o.get_number('monafe');
        rec_docdet.monina := o.get_number('monina');
        rec_docdet.monigv := o.get_number('monigv');
        rec_docdet.optramo := o.get_number('optramo');
        rec_docdet.etiqueta := o.get_string('etiqueta');
        rec_docdet.piezas := o.get_number('piezas');
        rec_docdet.opronumdoc := o.get_string('opronumdoc');
        rec_docdet.numguia := o.get_number('numguia');
        rec_docdet.fecguia := o.get_date('fecguia');
        rec_docdet.numfact := o.get_number('numfact');
        rec_docdet.fecfact := o.get_date('fecfact');
        rec_docdet.lote := o.get_string('lote');
        rec_docdet.fecfabr := o.get_date('fecfabr');
        rec_docdet.nrocarrete := o.get_string('nrocarrete');
        rec_docdet.nrotramo := o.get_number('nrotramo');
        rec_docdet.tottramo := o.get_number('tottramo');
        rec_docdet.norma := o.get_number('norma');
        rec_docdet.etiqueta2 := o.get_string('etiqueta2');
        rec_docdet.codcli := o.get_string('codcli');
        rec_docdet.tara := o.get_number('tara');
        rec_docdet.royos := o.get_number('royos');
        rec_docdet.positi := o.get_number('positi');
        rec_docdet.codadd01 := o.get_string('codadd01');
        rec_docdet.codadd02 := o.get_string('codadd02');
        rec_docdet.ubica := o.get_string('ubica');
        rec_docdet.opnumsec := o.get_number('opnumsec');
        rec_docdet.combina := o.get_string('combina');
        rec_docdet.empalme := o.get_string('empalme');
        rec_docdet.swacti := o.get_number('swacti');
        rec_docdet.diseno := o.get_string('diseno');
        rec_docdet.acabado := o.get_string('acabado');
        rec_docdet.fvenci := o.get_date('fvenci');
        rec_docdet.seguro := o.get_number('seguro');
        rec_docdet.flete := o.get_number('flete');
        rec_docdet.fmanuf := o.get_date('fmanuf');
        rec_docdet.monisc := o.get_number('monisc');
        rec_docdet.valporisc := o.get_number('valporisc');
        rec_docdet.tipisc := o.get_string('tipisc');
        rec_docdet.monotr := o.get_number('monotr');
        rec_docdet.monexo := o.get_number('monexo');
        rec_docdet.costot01 := o.get_number('costot01');
        rec_docdet.costot02 := o.get_number('costot02');
        rec_docdet.cargamin := o.get_number('cargamin');
        rec_docdet.dam := o.get_string('dam');
        rec_docdet.dam_item := o.get_number('dam_item');
        rec_docdet.chasis := o.get_string('chasis');
        rec_docdet.motor := o.get_string('motor');
        rec_docdet.monicbper := o.get_number('monicbper');
        rec_docdet.tipcam := o.get_number('tipcam');
        v_response := 'La grabación';
        DECLARE BEGIN
            CASE pin_opcdml
                WHEN 1 THEN
                    INSERT INTO documentos_det (
                        id_cia,
                        numint,
                        numite,
                        tipdoc,
                        series,
                        tipinv,
                        codart,
                        situac,
                        codalm,
                        cantid,
                        canref,
                        canped,
                        saldo,
                        pordes1,
                        pordes2,
                        pordes3,
                        pordes4,
                        preuni,
                        cosuni,
                        observ,
                        fcreac,
                        factua,
                        usuari,
                        importe_bruto,
                        importe,
                        opnumdoc,
                        opcargo,
                        opnumite,
                        optipinv,
                        codund,
                        largo,
                        ancho,
                        altura,
                        porigv,
                        monafe,
                        monina,
                        monigv,
                        optramo,
                        etiqueta,
                        piezas,
                        opronumdoc,
                        numguia,
                        fecguia,
                        numfact,
                        fecfact,
                        lote,
                        fecfabr,
                        nrocarrete,
                        nrotramo,
                        tottramo,
                        norma,
                        etiqueta2,
                        codcli,
                        tara,
                        royos,
                        positi,
                        codadd01,
                        codadd02,
                        ubica,
                        opnumsec,
                        combina,
                        empalme,
                        swacti,
                        diseno,
                        acabado,
                        fvenci,
                        seguro,
                        flete,
                        fmanuf,
                        monisc,
                        valporisc,
                        tipisc,
                        monotr,
                        monexo,
                        costot01,
                        costot02,
                        cargamin,
                        dam,
                        dam_item,
                        chasis,
                        motor,
                        monicbper,
                        tipcam
                    ) VALUES (
                        rec_docdet.id_cia,
                        rec_docdet.numint,
                        rec_docdet.numite,
                        rec_docdet.tipdoc,
                        rec_docdet.series,
                        rec_docdet.tipinv,
                        rec_docdet.codart,
                        rec_docdet.situac,
                        rec_docdet.codalm,
                        rec_docdet.cantid,
                        rec_docdet.canref,
                        rec_docdet.canped,
                        rec_docdet.saldo,
                        rec_docdet.pordes1,
                        rec_docdet.pordes2,
                        rec_docdet.pordes3,
                        rec_docdet.pordes4,
                        rec_docdet.preuni,
                        rec_docdet.cosuni,
                        rec_docdet.observ,
                        current_timestamp,
                        current_timestamp,
                        rec_docdet.usuari,
                        rec_docdet.importe_bruto,
                        rec_docdet.importe,
                        rec_docdet.opnumdoc,
                        rec_docdet.opcargo,
                        rec_docdet.opnumite,
                        rec_docdet.optipinv,
                        rec_docdet.codund,
                        rec_docdet.largo,
                        rec_docdet.ancho,
                        rec_docdet.altura,
                        rec_docdet.porigv,
                        rec_docdet.monafe,
                        rec_docdet.monina,
                        rec_docdet.monigv,
                        rec_docdet.optramo,
                        rec_docdet.etiqueta,
                        rec_docdet.piezas,
                        rec_docdet.opronumdoc,
                        rec_docdet.numguia,
                        rec_docdet.fecguia,
                        rec_docdet.numfact,
                        rec_docdet.fecfact,
                        rec_docdet.lote,
                        rec_docdet.fecfabr,
                        rec_docdet.nrocarrete,
                        rec_docdet.nrotramo,
                        rec_docdet.tottramo,
                        rec_docdet.norma,
                        rec_docdet.etiqueta2,
                        rec_docdet.codcli,
                        rec_docdet.tara,
                        rec_docdet.royos,
                        rec_docdet.positi,
                        rec_docdet.codadd01,
                        rec_docdet.codadd02,
                        rec_docdet.ubica,
                        rec_docdet.opnumsec,
                        rec_docdet.combina,
                        rec_docdet.empalme,
                        rec_docdet.swacti,
                        rec_docdet.diseno,
                        rec_docdet.acabado,
                        rec_docdet.fvenci,
                        rec_docdet.seguro,
                        rec_docdet.flete,
                        rec_docdet.fmanuf,
                        rec_docdet.monisc,
                        rec_docdet.valporisc,
                        rec_docdet.tipisc,
                        rec_docdet.monotr,
                        rec_docdet.monexo,
                        rec_docdet.costot01,
                        rec_docdet.costot02,
                        rec_docdet.cargamin,
                        rec_docdet.dam,
                        rec_docdet.dam_item,
                        rec_docdet.chasis,
                        rec_docdet.motor,
                        rec_docdet.monicbper,
                        rec_docdet.tipcam
                    );

                    COMMIT;
                    pin_responsecode := 1.0;
                    v_response := 'Success';
                WHEN 2 THEN
                    dbms_output.put_line('Very Good');
                WHEN 3 THEN
                    dbms_output.put_line('Good');
                ELSE
                    NULL;
            END CASE;
        EXCEPTION
            WHEN e_integrity THEN
                pin_responsecode := -2291;
                v_response := ' <br> Código referencial no existe : '
                              || ' Articulo : '
                              || rec_docdet.tipinv
                              || '-'
                              || rec_docdet.codart
                              || ', Unidad : '
                              || rec_docdet.codund;

        END;

        pin_response := v_response;
    END sp_save;

END pack_documentos_det;

/

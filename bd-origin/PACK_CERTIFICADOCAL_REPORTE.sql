--------------------------------------------------------
--  DDL for Package PACK_CERTIFICADOCAL_REPORTE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_CERTIFICADOCAL_REPORTE" AS
    TYPE datarecord_reporte_calidad IS RECORD (
        -- CERTIFICADOCAL_CAB
        id_cia            certificadocal_cab.id_cia%TYPE,
        numint            certificadocal_cab.numint%TYPE,
        femisicert        certificadocal_cab.femisi%TYPE,
        situaccert        certificadocal_cab.situac%TYPE,
        referencia        certificadocal_cab.referencia%TYPE,
        ocfecha           certificadocal_cab.ocfecha%TYPE,
        ocnumero          certificadocal_cab.ocnumero%TYPE,
        codcli            certificadocal_cab.codcli%TYPE,
        razonc            cliente.razonc%TYPE,
        direcc            cliente.direc1%TYPE,
        ubigeo            VARCHAR2(250 CHAR),
        ordpeddoc         VARCHAR2(250 CHAR),
        -- CERTICADOCAL_DET
        numite            certificadocal_det.numite%TYPE,
        opnumint          certificadocal_det.opnumint%TYPE,
        opnumite          certificadocal_det.opnumite%TYPE,
        periodo           certificadocal_det.periodo%TYPE,
        agrupa            certificadocal_det.agrupa%TYPE,
        numero            certificadocal_det.numero%TYPE,
        xml               certificadocal_det.xml%TYPE,
        etiqueta          certificadocal_det.etiqueta%TYPE,
        -- AUDITORIA
        ucreac            certificadocal_det.ucreac%TYPE,
        nomucreac         VARCHAR2(250 CHAR),
        uactua            certificadocal_det.uactua%TYPE,
        nomuactua         VARCHAR2(250 CHAR),
        -- INFO DEL USUARIO QUE IMPRIME
        uimpri            certificadocal_det.uimpri%TYPE,
        nomuimpri         VARCHAR2(250 CHAR),
        imgfirma          usuarios_imagen.imagen%TYPE,
        imgformato        usuarios_imagen.formato%TYPE,
        -- DETALLE DEL DOCUMENTO
        tipinv            documentos_det.tipinv%TYPE,
        codart            documentos_det.codart%TYPE,
        desart            articulos.descri%TYPE,
        piezas            documentos_det.piezas%TYPE,
        cantid            documentos_det.cantid%TYPE,
        largo             documentos_det.largo%TYPE,
        ancho             documentos_det.ancho%TYPE,
        altura            documentos_det.altura%TYPE,
        lote              documentos_det.lote%TYPE,
        nrotramo          documentos_det.nrotramo%TYPE,
        tottramo          documentos_det.tottramo%TYPE,
        usocantidce       documentos_det.cantid%TYPE,
        numeroop          VARCHAR(250 CHAR),
        numeroopitem      VARCHAR(250 CHAR),
        femisiop          documentos_cab.femisi%TYPE,
        -- DESCRIPCION DE CODIGOS DE LOS ARTICULOS
        descodigo02       clase_codigo.descri%TYPE,
        descodigo03       clase_codigo.descri%TYPE,
        descodigo04       clase_codigo.descri%TYPE,
        descodigo05       clase_codigo.descri%TYPE,
        descodigo06       clase_codigo.descri%TYPE,
        descodigo07       clase_codigo.descri%TYPE,
        descodigo08       clase_codigo.descri%TYPE,
        descodigo12       clase_codigo.descri%TYPE,
        descodigo13       clase_codigo.descri%TYPE,
        descodigo25       clase_codigo.descri%TYPE,
        descodigo26       clase_codigo.descri%TYPE,
        descodigo27       clase_codigo.descri%TYPE,
        descodigo76       clase_codigo.descri%TYPE,
        descodigo88       clase_codigo.descri%TYPE,
        descodigo91       clase_codigo.descri%TYPE,
        descodigo92       clase_codigo.descri%TYPE,
        descodigo93       clase_codigo.descri%TYPE,
        descodigo96       clase_codigo.descri%TYPE,
        descodigo97       clase_codigo.descri%TYPE,
        descodigo98       clase_codigo.descri%TYPE,
        descodigo100      clase_codigo.descri%TYPE,
        descodigo101      clase_codigo.descri%TYPE,
        descodigo102      clase_codigo.descri%TYPE,
        descodigo104      clase_codigo.descri%TYPE,
        -- ESPECIFICACIONES Y/O CLASES DEL DOCUMENTO
        tipotermina       clase_documentos_det_codigo.descri%TYPE,
        tipoterminaabrevi clase_documentos_det_codigo.abrevi%TYPE,
        nrocapas          documentos_det_clase.ventero%TYPE,
        longojos          articulo_especificacion.vreal%TYPE,
        numramales        documentos_det_clase.ventero%TYPE,
        numtermina        documentos_det_clase.ventero%TYPE,
        espec11           articulo_especificacion.vreal%TYPE,
        espec12           articulo_especificacion.vreal%TYPE,
        clasedetgi51      clase_documentos_det_codigo.descri%TYPE,
        clasedetgi52      clase_documentos_det_codigo.descri%TYPE,
        clasedetgi53      clase_documentos_det_codigo.descri%TYPE,
        clasedetgi54      articulo_especificacion.vreal%TYPE,
        clasedetgi55      articulo_especificacion.vreal%TYPE,
        clasedetgi56      documentos_det_clase.vstrg%TYPE,
        clasedetgi57      clase_documentos_det_codigo.descri%TYPE
    );
    TYPE datatable_reporte_calidad IS
        TABLE OF datarecord_reporte_calidad;
    FUNCTION sp_reporte_calidad (
        pin_id_cia NUMBER,
        pin_numint NUMBER,
        pin_numite NUMBER
    ) RETURN datatable_reporte_calidad
        PIPELINED;

END;

/

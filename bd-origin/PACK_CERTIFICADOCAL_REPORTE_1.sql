--------------------------------------------------------
--  DDL for Package Body PACK_CERTIFICADOCAL_REPORTE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_CERTIFICADOCAL_REPORTE" AS

    FUNCTION sp_reporte_calidad (
        pin_id_cia NUMBER,
        pin_numint NUMBER,
        pin_numite NUMBER
    ) RETURN datatable_reporte_calidad
        PIPELINED
    AS
        v_table datatable_reporte_calidad;
    BEGIN
        SELECT
            ce.id_cia,
            ce.numint,
            ce.femisi           AS femisicert,
            ce.situac           AS situaccert,
            ce.referencia,
            ce.ocfecha,
            ce.ocnumero,
            ce.codcli,
            cl.razonc,
            cl.direc1           AS direcc,
            ( cc14.descodigo
              || ','
              || cc15.descodigo
              || ','
              || cc16.descodigo ) AS ubigeo,
            top1.series
            || '-'
            || top1.numdoc      AS ordpeddoc,
            de.numite,
            de.opnumint,
            de.opnumite,
            de.periodo,
            de.agrupa,
            de.numero,
            de.xml,
            de.etiqueta,
            de.ucreac,
            u1.nombres          AS nomucreac,
            de.uactua,
            u2.nombres          AS nomuactua,
            de.uimpri,
            u3.nombres          AS nomuimpri,
            u2i.imagen          AS imgfirma,
            u2i.formato         AS imgformato,
            dd.tipinv,
            dd.codart,
            ar.descri           AS desart,
            dd.piezas,
            dd.cantid,
            dd.largo,
            dd.ancho,
            dd.altura,
            dd.lote,
            dd.nrotramo,
            dd.tottramo,
            CASE
                WHEN ce.usocantid IS NULL
                     OR ce.usocantid = 0 THEN
                    dd.cantid
                ELSE
                    1.0
            END                 usocantidce,
            dc.series
            || '-'
            || dc.numdoc        AS numeroop,
            dc.series
            || '-'
            || dc.numdoc
            || '-'
            || dd.positi        AS numeroopitem,
            dc.femisi           AS femisiop,
            ac02.descodigo      AS descodigo02,
            ac03.descodigo      AS descodigo03,
            ac04.descodigo      AS descodigo04,
            ac05.descodigo      AS descodigo05,
            ac06.descodigo      AS descodigo06,
            ac07.descodigo      AS descodigo07,
            ac08.descodigo      AS descodigo08,
            ac12.descodigo      AS descodigo12,
            ac13.descodigo      AS descodigo13,
            ac25.descodigo      AS descodigo25,
            ac26.descodigo      AS descodigo26,
            ac27.descodigo      AS descodigo27,
            ac76.descodigo      AS descodigo76,
            ac88.descodigo      AS descodigo88,
            ac91.descodigo      AS descodigo91,
            ac92.descodigo      AS descodigo92,
            ac93.descodigo      AS descodigo93,
            ac96.descodigo      AS descodigo96,
            ac97.descodigo      AS descodigo97,
            ac98.descodigo      AS descodigo98,
            ac100.descodigo     AS descodigo100,
            ac101.descodigo     AS descodigo101,
            ac102.descodigo     AS descodigo102,
            ac104.descodigo     AS descodigo104,
            dpc1.descri         AS tipotermina,
            dpc1.abrevi         AS tipoterminaabrevi,
            opc2.ventero        AS nrocapas,
            opc3.vreal          AS longojos,
            opc4.ventero        AS numramales,
            opc5.ventero        AS numtermina,
            ae11.vreal          AS espec11,
            ae12.vreal          AS espec12,
            cdg51d.descri       AS clasedetgi51,
            cdg52d.descri       AS clasedetgi52,
            cdg53d.descri       AS clasedetgi53,
            cdg54.vreal         AS clasedetgi54,
            cdg55.vreal         AS clasedetgi55,
            cdg56.vstrg         AS clasedetgi56,
            cdg57d.descri       AS clasedetgi57
        BULK COLLECT
        INTO 
        v_table
        FROM
            certificadocal_cab                                                          ce
            LEFT OUTER JOIN certificadocal_det                                                          de ON de.id_cia = ce.id_cia
                                                     AND de.numint = ce.numint
            LEFT OUTER JOIN usuarios                                                                    u1 ON u1.id_cia = de.id_cia
                                           AND u1.coduser = de.ucreac
            LEFT OUTER JOIN usuarios                                                                    u2 ON u2.id_cia = ce.id_cia
                                           AND u2.coduser = ce.uactua
            LEFT OUTER JOIN usuarios_imagen                                                             u2i ON u2i.id_cia = ce.id_cia
                                                   AND u2i.coduser = ce.ufirma
                                                   AND u2i.item = 2
            LEFT OUTER JOIN usuarios                                                                    u3 ON u3.id_cia = de.id_cia
                                           AND u3.coduser = de.uimpri
            LEFT OUTER JOIN cliente                                                                     cl ON cl.id_cia = ce.id_cia
                                          AND cl.codcli = ce.codcli
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(cl.id_cia, 'A', cl.codcli, 14)          cc14 ON cc14.codigo <> 'ND'
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(cl.id_cia, 'A', cl.codcli, 15)          cc15 ON cc15.codigo <> 'ND'
            LEFT OUTER JOIN pack_cliente.sp_buscar_clase_codigo(cl.id_cia, 'A', cl.codcli, 16)          cc16 ON cc16.codigo <> 'ND'
            LEFT OUTER JOIN documentos_cab                                                              dc ON dc.id_cia = de.id_cia
                                                 AND dc.numint = de.opnumint
            LEFT OUTER JOIN pack_trazabilidad.sp_trazabilidad_tipdoc(dc.id_cia, dc.numint, 101)         top1 ON 0 = 0
            LEFT OUTER JOIN documentos_det                                                              dd ON dd.id_cia = de.id_cia
                                                 AND dd.numint = de.opnumint
                                                 AND dd.numite = de.opnumite
            LEFT OUTER JOIN kardex000                                                                   k0 ON k0.id_cia = dd.id_cia
                                            AND k0.etiqueta = dd.etiqueta
            LEFT OUTER JOIN articulos                                                                   ar ON ar.id_cia = dd.id_cia
                                            AND ar.tipinv = dd.tipinv
                                            AND ar.codart = dd.codart
            LEFT OUTER JOIN articulo_especificacion                                                     ae11 ON ae11.id_cia = ar.id_cia
                                                            AND ae11.tipinv = ar.tipinv
                                                            AND ae11.codart = ar.codart
                                                            AND ae11.codesp = 11
            LEFT OUTER JOIN articulo_especificacion                                                     ae12 ON ae12.id_cia = ar.id_cia
                                                            AND ae12.tipinv = ar.tipinv
                                                            AND ae12.codart = ar.codart
                                                            AND ae12.codesp = 12
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(ar.id_cia, ar.tipinv, ar.codart, 02)  ac02 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(ar.id_cia, ar.tipinv, ar.codart, 03)  ac03 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(ar.id_cia, ar.tipinv, ar.codart, 04)  ac04 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(ar.id_cia, ar.tipinv, ar.codart, 05)  ac05 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(ar.id_cia, ar.tipinv, ar.codart, 06)  ac06 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(ar.id_cia, ar.tipinv, ar.codart, 07)  ac07 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(ar.id_cia, ar.tipinv, ar.codart, 08)  ac08 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(ar.id_cia, ar.tipinv, ar.codart, 12)  ac12 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(ar.id_cia, ar.tipinv, ar.codart, 13)  ac13 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(ar.id_cia, ar.tipinv, ar.codart, 25)  ac25 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(ar.id_cia, ar.tipinv, ar.codart, 26)  ac26 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(ar.id_cia, ar.tipinv, ar.codart, 27)  ac27 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(ar.id_cia, ar.tipinv, ar.codart, 76)  ac76 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(ar.id_cia, ar.tipinv, ar.codart, 88)  ac88 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(ar.id_cia, ar.tipinv, ar.codart, 89)  ac89 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(ar.id_cia, ar.tipinv, ar.codart, 91)  ac91 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(ar.id_cia, ar.tipinv, ar.codart, 92)  ac92 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(ar.id_cia, ar.tipinv, ar.codart, 93)  ac93 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(ar.id_cia, ar.tipinv, ar.codart, 96)  ac96 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(ar.id_cia, ar.tipinv, ar.codart, 97)  ac97 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(ar.id_cia, ar.tipinv, ar.codart, 98)  ac98 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(ar.id_cia, ar.tipinv, ar.codart, 100) ac100 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(ar.id_cia, ar.tipinv, ar.codart, 101) ac101 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(ar.id_cia, ar.tipinv, ar.codart, 102) ac102 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(ar.id_cia, ar.tipinv, ar.codart, 104) ac104 ON 0 = 0
            LEFT OUTER JOIN documentos_det_clase                                                        opc1 ON opc1.id_cia = dd.id_cia
                                                         AND opc1.numint = dd.numint
                                                         AND opc1.numite = dd.numite
                                                         AND opc1.clase = 1
            LEFT OUTER JOIN clase_documentos_det_codigo                                                 dpc1 ON dpc1.id_cia = dd.id_cia
                                                                AND dpc1.tipdoc = 104
                                                                AND dpc1.clase = 1
                                                                AND dpc1.codigo = opc1.codigo
            LEFT OUTER JOIN documentos_det_clase                                                        opc2 ON opc2.id_cia = dd.id_cia
                                                         AND opc2.numint = dd.numint
                                                         AND opc2.numite = dd.numite
                                                         AND opc2.clase = 2
            LEFT OUTER JOIN documentos_det_clase                                                        opc3 ON opc3.id_cia = dd.id_cia
                                                         AND opc3.numint = dd.numint
                                                         AND opc3.numite = dd.numite
                                                         AND opc3.clase = 3
            LEFT OUTER JOIN documentos_det_clase                                                        opc4 ON opc4.id_cia = dd.id_cia
                                                         AND opc4.numint = dd.numint
                                                         AND opc4.numite = dd.numite
                                                         AND opc4.clase = 4
            LEFT OUTER JOIN documentos_det_clase                                                        opc5 ON opc5.id_cia = dd.id_cia
                                                         AND opc5.numint = dd.numint
                                                         AND opc5.numite = dd.numite
                                                         AND opc5.clase = 5
            LEFT OUTER JOIN documentos_det_clase                                                        cdg51 ON cdg51.id_cia = k0.id_cia
                                                          AND cdg51.numint = k0.numint
                                                          AND cdg51.numite = k0.numite
                                                          AND cdg51.clase = 51
            LEFT OUTER JOIN clase_documentos_det_codigo                                                 cdg51d ON cdg51d.id_cia = dd.id_cia
                                                                  AND cdg51d.tipdoc = 103
                                                                  AND cdg51d.clase = cdg51.clase
                                                                  AND cdg51d.codigo = cdg51.codigo
            LEFT OUTER JOIN documentos_det_clase                                                        cdg52 ON cdg52.id_cia = k0.id_cia
                                                          AND cdg52.numint = k0.numint
                                                          AND cdg52.numite = k0.numite
                                                          AND cdg52.clase = 52
            LEFT OUTER JOIN clase_documentos_det_codigo                                                 cdg52d ON cdg52d.id_cia = cdg52.id_cia
                                                                  AND cdg52d.tipdoc = 103
                                                                  AND cdg52d.clase = cdg52.clase
                                                                  AND cdg52d.codigo = cdg52.codigo
            LEFT OUTER JOIN documentos_det_clase                                                        cdg53 ON cdg53.id_cia = k0.id_cia
                                                          AND cdg53.numint = k0.numint
                                                          AND cdg53.numite = k0.numite
                                                          AND cdg53.clase = 53
            LEFT OUTER JOIN clase_documentos_det_codigo                                                 cdg53d ON cdg53d.id_cia = k0.id_cia
                                                                  AND cdg53d.tipdoc = 103
                                                                  AND cdg53d.clase = cdg53.clase
                                                                  AND cdg53d.codigo = cdg53.codigo
            LEFT OUTER JOIN documentos_det_clase                                                        cdg54 ON cdg54.id_cia = k0.id_cia
                                                          AND cdg54.numint = k0.numint
                                                          AND cdg54.numite = k0.numite
                                                          AND cdg54.clase = 54
            LEFT OUTER JOIN documentos_det_clase                                                        cdg55 ON cdg55.id_cia = k0.id_cia
                                                          AND cdg55.numint = k0.numint
                                                          AND cdg55.numite = k0.numite
                                                          AND cdg55.clase = 55
            LEFT OUTER JOIN documentos_det_clase                                                        cdg56 ON cdg56.id_cia = k0.id_cia
                                                          AND cdg56.numint = k0.numint
                                                          AND cdg56.numite = k0.numite
                                                          AND cdg56.clase = 56
            LEFT OUTER JOIN documentos_det_clase                                                        cdg57 ON cdg57.id_cia = k0.id_cia
                                                          AND cdg57.numint = k0.numint
                                                          AND cdg57.numite = k0.numite
                                                          AND cdg57.clase = 57
            LEFT OUTER JOIN clase_documentos_det_codigo                                                 cdg57d ON cdg57d.id_cia = cdg57.id_cia
                                                                  AND cdg57d.tipdoc = 103
                                                                  AND cdg57d.clase = cdg57.clase
                                                                  AND cdg57d.codigo = cdg57.codigo
        WHERE
                de.id_cia = pin_id_cia
            AND de.numint = pin_numint
            AND ( nvl(pin_numite, - 1) = - 1
                  OR de.numite = pin_numite );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_reporte_calidad;

END;

/

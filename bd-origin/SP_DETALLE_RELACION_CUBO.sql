--------------------------------------------------------
--  DDL for Function SP_DETALLE_RELACION_CUBO
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP_DETALLE_RELACION_CUBO" (
    pin_id_cia        IN  NUMBER,
    pin_nunintfac     IN  NUMBER,
    pin_fecfac_desde  IN  VARCHAR2,
    pin_fecfac_hasta  IN  VARCHAR2
) RETURN tbl_detalle_relacion_cubo
    PIPELINED
IS

    r_detalle_relacion_cubo  rec_detalle_relacion_cubo := rec_detalle_relacion_cubo(NULL, NULL, NULL, NULL, NULL,
                          NULL, NULL, NULL, NULL, NULL,
                          NULL, NULL, NULL, NULL, NULL,
                          NULL, NULL, NULL, NULL, NULL,
                          NULL, NULL, NULL, NULL, NULL,
                          NULL, NULL, NULL, NULL, NULL,
                          NULL, NULL, NULL, NULL, NULL,
                          NULL, NULL);
    CURSOR cur_detalle IS
    SELECT DISTINCT
        dcf.numint      AS numintfac,
        dcf.tipdoc      AS tipdocfac,
        dcf.femisi      AS femisifac,
        dcf.id          AS idfac,
        dcf.series      AS seriefac,
        dcf.numdoc      AS numdocfac,
        dcf.situac      AS situacfac,
        dcf.codsuc      AS codsucfac,
        dcf.codmot      AS codmotfac,
        dcf.codcli      AS codclifac,
        dcf.ruc         AS rucfac,
        dcf.razonc      AS razoncfac,
        dcf.direc1      AS direc1fac,
        dcf.tipmon      AS tipmonfac,
        dcf.tipcam      AS tipcamfac,
        dcf.codven      AS codvenfac,
        dcf.codcpag     AS codcpagfac,
        dcf.comisi      AS comisifac,
        ddf.numite      AS numitefac,
        ddf.opnumdoc    AS numintgui,
        ddf.opnumite    AS numitegui,
        dcg.tipdoc      AS tipdocgui,
        dcg.femisi      AS femisigui,
        dcg.id          AS idgui,
        dcg.series      AS seriegui,
        dcg.numdoc      AS numdocgui,
        dcg.situac      AS situacgui,
        dcg.codsuc      AS codsucgui,
        dcg.codmot      AS codmotgui,
      /*  (
            SELECT
                vreal
            FROM
                documentos_det_clase
            WHERE
                    id_cia = pin_id_cia
                AND numint = dcf.numint
                AND numite = ddf.numite
                AND clase = 1
        )*/ 0 AS porcomisi,
        /*(
            SELECT
                c.descri
            FROM
                documentos_det_clase         d
                LEFT OUTER JOIN clase_documentos_det_codigo  c ON c.id_cia = pin_id_cia
                                                                 AND c.tipdoc = dcf.tipdoc
                                                                 AND c.clase = d.clase
                                                                 AND c.codigo = d.codigo
            WHERE
                    d.id_cia = pin_id_cia
                AND d.numint = dcf.numint
                AND d.numite = ddf.numite
                AND d.clase = 2
        )*/ null AS tipoventa,
        dv.descri       AS destin,
        ca.codenv       AS codenvfac,
        ca.descri       AS desenvfac,
        ddf.codadd01,
        ddf.codadd02
    FROM
        documentos_cab          dcf
        LEFT OUTER JOIN documentos_det          ddf ON ddf.id_cia = pin_id_cia 
                                                   AND ddf.numint = dcf.numint
        LEFT OUTER JOIN documentos_cab          dcg ON dcg.id_cia = pin_id_cia
                                                   AND dcg.numint = ddf.opnumdoc
                                               AND ( ( dcg.situac = 'C' )
                                                  OR ( dcg.situac = 'F' )
                                                  OR ( dcg.situac = 'H' )
                                                  OR ( dcg.situac = 'G' ) )
       /* LEFT OUTER JOIN documentos_cab          dca ON dca.id_cia = pin_id_cia
                                              AND ( dcf.numint = dca.numint )*/
        LEFT OUTER JOIN destino_ventas          dv ON dv.id_cia = pin_id_cia
                                             AND dv.coddes = dcf.destin
        LEFT OUTER JOIN documentos_cab_almacen  da ON da.id_cia = pin_id_cia
                                                     AND da.numint = dcf.numint
        LEFT OUTER JOIN clientes_almacen        ca ON ca.id_cia = pin_id_cia
                                               AND ca.codcli = dcf.codcli
                                               AND ca.codenv = da.codenv
    WHERE
            dcf.id_cia = pin_id_cia
      /*  AND ( pin_nunintfac = - 1
              OR dcf.numint = pin_nunintfac )*/
        AND ( dcf.tipdoc IN ( 1, 3, 7, 8 ) )
        AND ( ( dcf.situac = 'C' )
              OR ( dcf.situac = 'B' )
              OR ( dcf.situac = 'H' )
              OR ( dcf.situac = 'G' )
              OR ( dcf.situac = 'F' ) )
        AND ( pin_fecfac_desde IS NULL
              OR dcf.femisi >=TO_DATE(pin_fecfac_desde,'DD/MM/RR'))
        AND ( pin_fecfac_hasta IS NULL
              OR dcf.femisi <= TO_DATE(pin_fecfac_hasta,'DD/MM/RR') )
    ORDER BY
        dcf.numint,
        ddf.numite;

    v_count                  NUMBER := 0;
BEGIN
    FOR registro IN cur_detalle LOOP
        r_detalle_relacion_cubo.numintfac := registro.numintfac;
        r_detalle_relacion_cubo.tipdocfac := registro.tipdocfac;
        r_detalle_relacion_cubo.femisifac := registro.femisifac;
        r_detalle_relacion_cubo.idfac := registro.idfac;
        r_detalle_relacion_cubo.seriefac := registro.seriefac;
        r_detalle_relacion_cubo.numdocfac := registro.numdocfac;
        r_detalle_relacion_cubo.situacfac := registro.situacfac;
        r_detalle_relacion_cubo.codsucfac := registro.codsucfac;
        r_detalle_relacion_cubo.numitefac := registro.numitefac;
        r_detalle_relacion_cubo.codmotfac := registro.codmotfac;
        r_detalle_relacion_cubo.codclifac := registro.codclifac;
        r_detalle_relacion_cubo.rucfac := registro.rucfac;
        r_detalle_relacion_cubo.razoncfac := registro.razoncfac;
        r_detalle_relacion_cubo.direc1fac := registro.direc1fac;
        r_detalle_relacion_cubo.tipmonfac := registro.tipmonfac;
        r_detalle_relacion_cubo.tipcamfac := registro.tipcamfac;
        r_detalle_relacion_cubo.codvenfac := registro.codvenfac;
        r_detalle_relacion_cubo.codcpagfac := registro.codcpagfac;
        r_detalle_relacion_cubo.comisifac := registro.comisifac;
        r_detalle_relacion_cubo.numintgui := registro.numintgui;
        r_detalle_relacion_cubo.tipdocgui := registro.tipdocgui;
        r_detalle_relacion_cubo.femisigui := registro.femisigui;
        r_detalle_relacion_cubo.idgui := registro.idgui;
        r_detalle_relacion_cubo.seriegui := registro.seriegui;
        r_detalle_relacion_cubo.numdocgui := registro.numdocgui;
        r_detalle_relacion_cubo.situacgui := registro.situacgui;
        r_detalle_relacion_cubo.codsucgui := registro.codsucgui;
        r_detalle_relacion_cubo.numitegui := registro.numitegui;
        r_detalle_relacion_cubo.codmotgui := registro.codmotgui;
        r_detalle_relacion_cubo.porcomisi := registro.porcomisi;
        r_detalle_relacion_cubo.tipoventa := registro.tipoventa;
        r_detalle_relacion_cubo.destin := registro.destin;
        r_detalle_relacion_cubo.codenvfac := registro.codenvfac;
        r_detalle_relacion_cubo.desenvfac := registro.desenvfac;
        r_detalle_relacion_cubo.codadd01 := registro.codadd01;
        r_detalle_relacion_cubo.codadd02 := registro.codadd02;
        r_detalle_relacion_cubo.deskardex := 'F'; -- FACTURA 
        BEGIN
            SELECT
                COUNT(0) AS valor
            INTO v_count
            FROM
                kardex
            WHERE
                    id_cia = pin_id_cia
                AND numint = registro.numintfac
                AND numite = registro.numitefac;

        EXCEPTION
            WHEN no_data_found THEN
                v_count := NULL;
        END;

        IF ( ( v_count IS NULL ) OR ( v_count = 0 ) ) THEN
            r_detalle_relacion_cubo.deskardex := 'G';
        END IF;

        PIPE ROW ( r_detalle_relacion_cubo );
    END LOOP;

    return;
END sp_detalle_relacion_cubo;

/

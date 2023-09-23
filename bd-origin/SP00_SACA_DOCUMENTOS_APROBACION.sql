--------------------------------------------------------
--  DDL for Function SP00_SACA_DOCUMENTOS_APROBACION
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP00_SACA_DOCUMENTOS_APROBACION" (
    pin_id_cia  NUMBER,
    pin_numint  NUMBER
) RETURN tbl_documentos_aprobacion
    PIPELINED
AS

    rdocumentos_aprobacion rec_documentos_aprobacion := rec_documentos_aprobacion(NULL, NULL, NULL, NULL, NULL,
                          NULL, NULL, NULL, NULL, NULL,
                          NULL, NULL, NULL, NULL, NULL,
                          NULL, NULL, NULL, NULL, NULL,
                          NULL, NULL, NULL);
BEGIN
    FOR registro IN (
        SELECT
            d.numint,
            d.tipdoc,
            d.series,
            d.numdoc,
            d.femisi,
            d.codcli,
            d.ruc,
            d.razonc,
            d.tipmon,
            d.preven,
            d.tipcam,
            CASE
                WHEN d.tipmon = 'PEN' THEN
                    d.preven
                ELSE
                    d.preven * d.tipcam
            END AS prevensol,
            d.codcpag,
            a.situac,
            a.fcreac,
            a.factua,
            a.ucreac,
            u1.nombres    AS usercre,
            a.uactua,
            u2.nombres    AS useract,
            t.descri      AS dtipdoc,
            d.observ,
            d.fecter
        FROM
            documentos_cab         d
            LEFT OUTER JOIN documentos_aprobacion  a ON a.id_cia = pin_id_cia
                                                       AND a.numint = d.numint
            LEFT OUTER JOIN documentos             t ON t.id_cia = pin_id_cia
                                            AND t.codigo = d.tipdoc
                                            AND t.series = d.series
            LEFT OUTER JOIN usuarios               u1 ON u1.id_cia = pin_id_cia
                                           AND u1.coduser = a.ucreac
            LEFT OUTER JOIN usuarios               u2 ON u2.id_cia = pin_id_cia
                                           AND u2.coduser = a.uactua
        WHERE
            ( d.id_cia = pin_id_cia )
            AND ( d.numint = pin_numint )
    ) LOOP
        rdocumentos_aprobacion.numint := registro.numint;
        rdocumentos_aprobacion.tipdoc := registro.tipdoc;
        rdocumentos_aprobacion.dtipdoc := registro.dtipdoc;
        rdocumentos_aprobacion.series := registro.series;
        rdocumentos_aprobacion.numdoc := registro.numdoc;
        rdocumentos_aprobacion.femisi := registro.femisi;
        rdocumentos_aprobacion.codcli := registro.codcli;
        rdocumentos_aprobacion.ruc := registro.ruc;
        rdocumentos_aprobacion.razonc := registro.razonc;
        rdocumentos_aprobacion.tipmon := registro.tipmon;
        rdocumentos_aprobacion.preven := registro.preven;
        rdocumentos_aprobacion.tipcam := registro.tipcam;
        rdocumentos_aprobacion.prevensol := registro.prevensol;
        rdocumentos_aprobacion.situac := registro.situac;
        rdocumentos_aprobacion.fcreac := registro.fcreac;
        rdocumentos_aprobacion.factua := registro.factua;
        rdocumentos_aprobacion.ucreac := registro.ucreac;
        rdocumentos_aprobacion.usercre := registro.usercre;
        rdocumentos_aprobacion.uactua := registro.uactua;
        rdocumentos_aprobacion.useract := registro.useract;
        rdocumentos_aprobacion.codpag := registro.codcpag;
        rdocumentos_aprobacion.observ := registro.observ;
        rdocumentos_aprobacion.fecter := registro.fecter;
        PIPE ROW ( rdocumentos_aprobacion );
    END LOOP;
EXCEPTION
    WHEN no_data_needed THEN
        dbms_output.put_line('error inesperado');
        return;
END sp00_saca_documentos_aprobacion;

/

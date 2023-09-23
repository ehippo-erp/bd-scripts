--------------------------------------------------------
--  DDL for Package Body PACK_DOCUMENTOS_SUNAT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_DOCUMENTOS_SUNAT" AS

    FUNCTION sp_enviar_correo (
        pin_id_cia NUMBER,
        pin_tipdoc VARCHAR2,
        pin_codcli VARCHAR2,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_enviar_correo
        PIPELINED
    AS
        v_table datatable_enviar_correo;
    BEGIN
        SELECT
            t.*
        BULK COLLECT
        INTO v_table
        FROM
            (
                SELECT
                    c.id_cia,
                    c.numint                   AS numint,
                    CAST(
                        CASE
                            WHEN(c.tipdoc = 41) THEN
                                40
                            ELSE
                                c.tipdoc
                        END
                    AS SMALLINT)               AS sc_tipdoc,
                    c.series                   AS sc_serie,
                    c.numdoc                   AS sc_numero,
                    c.femisi                   AS sc_femisi,
                    c.tipmon                   AS sc_moneda,
                    c.codcli                   AS sc_codcli,
                    c.razonc                   AS sc_razsoc,
                    CAST(c.ruc AS VARCHAR(20)) AS sc_ruc,
                    c.preven                   AS sc_preven,
                    s.estado,
                    ees.descri                 AS desest
                FROM
                    documentos_cab             c
                    LEFT OUTER JOIN documentos_cab_envio_sunat s ON s.id_cia = c.id_cia
                                                                    AND s.numint = c.numint
                    LEFT OUTER JOIN estado_envio_sunat         ees ON ees.id_cia = s.id_cia
                                                              AND ees.codest = s.estado
                WHERE
                        c.id_cia = pin_id_cia
                    AND ( c.tipdoc IN (
                        SELECT
                            *
                        FROM
                            TABLE ( convert_in(pin_tipdoc) )
                    ) )
                    AND c.femisi BETWEEN pin_fdesde AND pin_fhasta
                    AND ( pin_codcli IS NULL
                          OR c.codcli = pin_codcli )
                    AND c.situac = 'F'
                    AND ( ( s.estado = 1
                            AND s.xml IS NOT NULL
                            AND s.cdr IS NOT NULL )
                          OR s.estado = 6 )
                UNION ALL
                SELECT
                    c.id_cia,
                    c.numint                   AS numint,
                    CAST(
                        CASE
                            WHEN(c.tipdoc = 41) THEN
                                40
                            ELSE
                                c.tipdoc
                        END
                    AS SMALLINT)               AS sc_tipdoc,
                    c.series                   AS sc_serie,
                    c.numdoc                   AS sc_numero,
                    c.femisi                   AS sc_femisi,
                    c.tipmon                   AS sc_moneda,
                    c.codcli                   AS sc_codcli,
                    c.razonc                   AS sc_razsoc,
                    CAST(c.ruc AS VARCHAR(20)) AS sc_ruc,
                    c.preven                   AS sc_preven,
                    6,
                    'Aceptado R.Dia'           AS desest
                FROM
                    documentos_cab             c
                    LEFT OUTER JOIN documentos_cab_envio_sunat s ON s.id_cia = c.id_cia
                                                                    AND s.numint = c.numint
                    LEFT OUTER JOIN estado_envio_sunat         ees ON ees.id_cia = s.id_cia
                                                              AND ees.codest = s.estado
                WHERE
                        c.id_cia = pin_id_cia
                    AND c.tipdoc IN ( 3, 7, 8 )
                    AND ( c.tipdoc IN (
                        SELECT
                            *
                        FROM
                            TABLE ( convert_in(pin_tipdoc) )
                    ) )
                    AND c.femisi BETWEEN pin_fdesde AND pin_fhasta
                    AND ( pin_codcli IS NULL
                          OR c.codcli = pin_codcli )
                    AND c.situac = 'F'
                    AND s.estado = 0
                    AND s.cres >= 1
            ) t
        ORDER BY
            t.numint DESC;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_enviar_correo;

END;

/

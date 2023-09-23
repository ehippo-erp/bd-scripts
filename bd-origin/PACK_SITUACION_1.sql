--------------------------------------------------------
--  DDL for Package Body PACK_SITUACION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_SITUACION" AS

    FUNCTION sp_relacion (
        pin_id_cia NUMBER,
        pin_numint NUMBER
    ) RETURN datatable_relacion
        PIPELINED
    AS
        rec      datarecord_relacion;
        v_permis VARCHAR2(20);
        v_tipdoc NUMBER;
    BEGIN
        BEGIN
            SELECT
                c.tipdoc,
                s.permis
            INTO v_tipdoc, v_permis
            FROM
                documentos_cab c
                LEFT OUTER JOIN situacion      s ON s.id_cia = c.id_cia
                                               AND s.tipdoc = c.tipdoc
                                               AND s.situac = c.situac
            WHERE
                    c.id_cia = pin_id_cia
                AND c.numint = pin_numint;

        EXCEPTION
            WHEN no_data_found THEN
                v_permis := '';
                v_tipdoc := NULL;
        END;

        IF ( TRIM(v_permis) IS NOT NULL ) THEN
            FOR i IN 1..length(trim(v_permis)) LOOP
                rec.id_cia := pin_id_cia;
                rec.numint := pin_numint;
                rec.tipdoc := v_tipdoc;
                rec.situac := substr(v_permis, i, 1);
                rec.dessit := 'ND';
                FOR j IN (
                    SELECT
                        s.dessit
                    FROM
                        situacion s
                    WHERE
                            s.id_cia = pin_id_cia
                        AND s.situac = rec.situac
                        AND s.tipdoc = rec.tipdoc
                ) LOOP
                    rec.dessit := j.dessit;
                END LOOP;

                PIPE ROW ( rec );
            END LOOP;

        END IF;

        RETURN;
    END sp_relacion;

END;

/

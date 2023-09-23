--------------------------------------------------------
--  DDL for Procedure SP000_GENERA_DOCUMENTOS_ENT_001
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP000_GENERA_DOCUMENTOS_ENT_001" (
    pid_cia     IN  NUMBER,
    pnumintori  IN  NUMBER
) AS
BEGIN
 ---------------------
    IF (
        ( pnumintori IS NOT NULL ) AND ( pnumintori <> 0 )
    ) THEN
        INSERT INTO documentos_ent (
		    id_cia,
            opnumdoc,
            opnumite,
            orinumint,
            orinumite,
            entreg,
            piezas
        )
            SELECT
			    c.id_cia,
                CASE
                    WHEN c.opnumdoc = d.opnumdoc THEN
                        c.ordcomni
                    ELSE
                        CASE
                            WHEN d.opnumdoc IS NULL THEN
                                0
                            ELSE
                                d.opnumdoc
                        END
                END,
                CASE
                    WHEN d.opnumite IS NULL THEN
                        0
                    ELSE
                        d.opnumite
                END,
                d.numint,
                d.numite,
                d.cantid,
                d.piezas
            FROM
                     documentos_det d
                INNER JOIN documentos_cab c ON ( c.id_cia = d.id_cia )
                                               AND ( c.numint = d.numint )
            WHERE
                ( d.id_cia = pid_cia )
                AND ( d.numint = pnumintori )
                AND ( d.cantid > 0 );

        COMMIT;
    END IF;
----------------------------
END sp000_genera_documentos_ent_001;

/

--------------------------------------------------------
--  DDL for Procedure SP000_COPIA_DOCUMENTOS_CAB_CLASE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP000_COPIA_DOCUMENTOS_CAB_CLASE" (
    pin_id_cia         IN  NUMBER,
    pin_numintorigen   IN  NUMBER,
    pin_numintdestino  IN  NUMBER,
    pin_swreemplaza    IN  VARCHAR2
) IS
BEGIN
    DELETE FROM documentos_cab_clase
    WHERE
            id_cia = pin_id_cia
        AND numint = pin_numintdestino
        AND codigo = 'ND';

    IF ( upper(pin_swreemplaza) = 'S' ) THEN
    /* BORRA LAS CLASES DESTINO PARA REEMPLAZARLAS */
        DELETE FROM documentos_cab_clase d
        WHERE
                d.id_cia = pin_id_cia
            AND d.numint = pin_numintdestino
            AND ( EXISTS (
                SELECT
                    o.numint
                FROM
                    documentos_cab_clase o
                WHERE
                        o.id_cia = pin_id_cia
                    AND o.numint = pin_numintorigen
                    AND o.clase = d.clase
            ) );

    END IF;

    INSERT INTO documentos_cab_clase (
        id_cia,
        numint,
        clase,
        codigo,
        vreal,
        vstrg,
        vchar,
        vdate,
        vtime,
        ventero,
        vblob,
        codusercrea,
        coduseractu,
        fcreac,
        factua
    )
        SELECT
            o.id_cia,
            pin_numintdestino,
            o.clase,
            o.codigo,
            o.vreal,
            o.vstrg,
            o.vchar,
            o.vdate,
            o.vtime,
            o.ventero,
            o.vblob,
            o.codusercrea,
            o.coduseractu,
            o.fcreac,
            o.factua
        FROM
            documentos_cab_clase  o
            LEFT OUTER JOIN documentos_cab        p ON p.id_cia = pin_id_cia
                                                AND p.numint = pin_numintdestino
        WHERE
                o.id_cia = pin_id_cia
            AND ( o.numint = pin_numintorigen )
            AND ( NOT ( EXISTS (
                SELECT
                    d.numint
                FROM
                    documentos_cab_clase d
                WHERE
                        d.id_cia = pin_id_cia
                    AND d.numint = pin_numintdestino
                    AND d.clase = o.clase
            ) ) )
            AND EXISTS (
                SELECT
                    a.clase
                FROM
                    clase_documentos_cab a
                WHERE
                        a.id_cia = pin_id_cia
                    AND a.tipdoc = p.tipdoc
                    AND a.clase = o.clase
            );

  /* PARA QUE RE-COLOQUE LOS ND OBLIGATORIOS */

    UPDATE documentos_cab
    SET
        situac = situac
    WHERE
            id_cia = pin_id_cia
        AND numint = pin_numintdestino;

END sp000_copia_documentos_cab_clase;

/

--------------------------------------------------------
--  DDL for Trigger DESPUES_INSERTAR_DOCUMENTOS_CAB
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE TRIGGER "USR_TSI_SUITE"."DESPUES_INSERTAR_DOCUMENTOS_CAB" AFTER
    INSERT ON "USR_TSI_SUITE".documentos_cab
    FOR EACH ROW
DECLARE
    v_conteo NUMBER;
BEGIN
    v_conteo := 0;
    BEGIN
        SELECT
            COUNT(0)
        INTO v_conteo
        FROM
            documentos_situac_max
        WHERE
                id_cia = :new.id_cia
            AND numint = :new.numint
            AND situac = :new.situac;

    EXCEPTION
        WHEN no_data_found THEN
            v_conteo := NULL;
    END;

    IF ( v_conteo IS NULL ) THEN
        v_conteo := 0;
    END IF;
    IF ( v_conteo = 0 ) THEN
        INSERT INTO documentos_situac_max (
            id_cia,
            numint,
            situac,
            usuari
        ) VALUES (
            :new.id_cia,
            :new.numint,
            :new.situac,
            :new.usuari
        );

    ELSE
        UPDATE documentos_situac_max
        SET
            usuari = :new.usuari
        WHERE
                id_cia = :new.id_cia
            AND numint = :new.numint
            AND situac = :new.situac;

    END IF;

/* INSERTA LAS CLASES OBLIGATORIAS */

    INSERT INTO documentos_cab_clase (
        id_cia,
        numint,
        clase,
        codigo,
        codusercrea,
        coduseractu,
        fcreac,
        factua
    )
        SELECT
            :new.id_cia,
            :new.numint,
            c.clase,
            'ND',
            'MAN',
            'MAN',
            current_timestamp,
            current_timestamp
--                CAST('NOW' AS TIMESTAMP),
--                CAST('NOW' AS TIMESTAMP)
        FROM
            clase_documentos_cab c
        WHERE
                id_cia = :new.id_cia
            AND ( c.tipdoc = :new.tipdoc )
            AND ( upper(c.obliga) = 'S' )
            AND ( upper(c.swacti) = 'S' )
            AND NOT ( EXISTS (
                SELECT
                    a2.clase
                FROM
                    documentos_cab_clase a2
                WHERE
                        a2.id_cia = :new.id_cia
                    AND a2.numint = :new.numint
                    AND a2.clase = c.clase
            ) );


-------------------------

    INSERT INTO documentos_cab_log (
        id_cia,
        locali,
        numint,
        tipdoc,
        series,
        numdoc,
        femisi,
        situac,
        codcli,
        tipmon,
        tipcam,
        totbru,
        descue,
        desesp,
        monafe,
        monina,
        porigv,
        monigv,
        preven,
        usuari
    ) VALUES (
        :new.id_cia,
        - 1,
        :new.numint,
        :new.tipdoc,
        :new.series,
        :new.numdoc,
        :new.femisi,
        :new.situac,
        :new.codcli,
        :new.tipmon,
        :new.tipcam,
        :new.totbru,
        :new.descue,
        :new.desesp,
        :new.monafe,
        :new.monina,
        :new.porigv,
        :new.monigv,
        :new.preven,
        :new.usuari
    );

  /* FACTURACION ELECTRÓNICA Y GUIAS DE REMISION ELECTRONICAS*/

    BEGIN
        SELECT
            COUNT(0)
        INTO v_conteo
        FROM
            documentos_cab_envio_sunat
        WHERE
                id_cia = :new.id_cia
            AND numint = :new.numint;

    EXCEPTION
        WHEN no_data_found THEN
            v_conteo := 0;
    END;

    IF (
        ( v_conteo = 0 )
        AND ( ( :new.tipdoc = 1 ) OR ( :new.tipdoc = 3 ) OR ( :new.tipdoc = 7 ) OR ( :new.tipdoc = 8 ) OR ( :new.tipdoc = 41 ) OR ( :
        new.tipdoc = 102 ) )
    ) THEN
        INSERT INTO documentos_cab_envio_sunat (
            id_cia,
            numint,
            estado,
            fenvio,
            frespuesta,
            xml,
            cxml,
            ctxt,
            cres,
            cbaj,
            inweb
        ) VALUES (
            :new.id_cia,
            :new.numint,
            0,
            NULL,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0
        );

    END IF;

END;
/
ALTER TRIGGER "USR_TSI_SUITE"."DESPUES_INSERTAR_DOCUMENTOS_CAB" ENABLE;

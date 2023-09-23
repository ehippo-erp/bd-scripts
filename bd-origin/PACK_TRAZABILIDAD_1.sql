--------------------------------------------------------
--  DDL for Package Body PACK_TRAZABILIDAD
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_TRAZABILIDAD" AS

    FUNCTION sp_trazabilidad_ordpro (
        pid_cia NUMBER,
        pnumint NUMBER
    ) RETURN datatable
        PIPELINED
    IS

        output_record datarecord;
        orden         NUMBER;
        CURSOR cselectordpro (
            wid_cia NUMBER,
            wnumint NUMBER
        ) IS
        SELECT
            c.id_cia,
            c.numint,
            c.tipdoc,
            c.series,
            c.numdoc,
            c.femisi,
            c.codmot,
            c.situac
        FROM
            documentos_relacion r
            LEFT OUTER JOIN documentos_cab      c ON c.id_cia = r.id_cia
                                                AND c.numint = r.numint
        WHERE
                r.id_cia = wid_cia
            AND r.numintre = wnumint
            AND r.tipdoc = 104;

    BEGIN
        orden := 0;
        FOR input_record IN cselectordpro(pid_cia, pnumint) LOOP
            output_record.indice := orden;
            output_record.id_cia := input_record.id_cia;
            output_record.numint := input_record.numint;
            output_record.tipdoc := input_record.tipdoc;
            output_record.series := input_record.series;
            output_record.numdoc := input_record.numdoc;
            output_record.femisi := input_record.femisi;
            output_record.codmot := input_record.codmot;
            output_record.situac := input_record.situac;
            PIPE ROW ( output_record );
            orden := orden + 1;
        END LOOP;

    END sp_trazabilidad_ordpro;

    FUNCTION sp_trazabilidad_fin (
        pid_cia NUMBER,
        pnumint NUMBER
    ) RETURN datatable
        PIPELINED
    IS

        output_record datarecord;
        orden         NUMBER;
        tmp_idcia     NUMBER;
        tmpnumint     NUMBER;
        CURSOR cselect (
            wid_cia NUMBER,
            wnumint NUMBER
        ) IS
        SELECT
            r.id_cia,
            r.numintre,
            c.tipdoc,
            c.series,
            c.numdoc,
            c.femisi,
            c.codmot,
            c.situac
        FROM
            documentos_relacion r
            LEFT OUTER JOIN documentos_cab      c ON c.id_cia = r.id_cia
                                                AND c.numint = r.numintre
        WHERE
                r.id_cia = wid_cia
            AND r.numint = wnumint;

    BEGIN
        orden := 0;
        FOR input_record IN cselect(pid_cia, pnumint) LOOP
            tmp_idcia := input_record.id_cia;
            tmpnumint := input_record.numintre;
            IF tmpnumint IS NOT NULL THEN
                output_record.indice := orden;
                output_record.id_cia := input_record.id_cia;
                output_record.numint := input_record.numintre;
                output_record.tipdoc := input_record.tipdoc;
                output_record.series := input_record.series;
                output_record.numdoc := input_record.numdoc;
                output_record.femisi := input_record.femisi;
                output_record.codmot := input_record.codmot;
                output_record.situac := input_record.situac;
                PIPE ROW ( output_record );
                FOR input_recordfin IN (
                    SELECT
                        id_cia,
                        numint,
                        tipdoc,
                        series,
                        numdoc,
                        femisi,
                        codmot,
                        situac
                    FROM
                        TABLE ( pack_trazabilidad.sp_trazabilidad_fin(tmp_idcia, tmpnumint) )
                ) LOOP
                    output_record.indice := orden;
                    output_record.id_cia := input_recordfin.id_cia;
                    output_record.numint := input_recordfin.numint;
                    output_record.tipdoc := input_recordfin.tipdoc;
                    output_record.series := input_recordfin.series;
                    output_record.numdoc := input_recordfin.numdoc;
                    output_record.femisi := input_recordfin.femisi;
                    output_record.codmot := input_recordfin.codmot;
                    output_record.situac := input_recordfin.situac;
                    PIPE ROW ( output_record );
                END LOOP;

                orden := orden + 1;
            END IF;

        END LOOP;

    END sp_trazabilidad_fin;

    FUNCTION sp_trazabilidad_finv2 (
        pid_cia NUMBER,
        pnumint NUMBER
    ) RETURN datatable_documento_origen
        PIPELINED
    IS

        output_record datarecord_documento_origen;
        orden         NUMBER;
        tmp_idcia     NUMBER;
        tmpnumint     NUMBER;
        CURSOR cselect (
            wid_cia NUMBER,
            wnumint NUMBER
        ) IS
        SELECT
            r.id_cia,
            r.numintre,
            c.tipdoc,
            c.series,
            c.numdoc,
            c.femisi,
            c.codmot,
            c.situac,
            c.tipcam,
            c.porigv
        FROM
            documentos_relacion r
            LEFT OUTER JOIN documentos_cab      c ON c.id_cia = r.id_cia
                                                AND c.numint = r.numintre
        WHERE
                r.id_cia = wid_cia
            AND r.numint = wnumint;

    BEGIN
        orden := 0;
        FOR input_record IN cselect(pid_cia, pnumint) LOOP
            tmp_idcia := input_record.id_cia;
            tmpnumint := input_record.numintre;
            IF tmpnumint IS NOT NULL THEN
                output_record.indice := orden;
                output_record.id_cia := input_record.id_cia;
                output_record.numint := input_record.numintre;
                output_record.tipdoc := input_record.tipdoc;
                output_record.series := input_record.series;
                output_record.numdoc := input_record.numdoc;
                output_record.femisi := input_record.femisi;
                output_record.codmot := input_record.codmot;
                output_record.situac := input_record.situac;
                output_record.tipcam := input_record.tipcam;
                output_record.porigv := input_record.porigv;
                PIPE ROW ( output_record );
                FOR input_recordfin IN (
                    SELECT
                        id_cia,
                        numint,
                        tipdoc,
                        series,
                        numdoc,
                        femisi,
                        codmot,
                        situac,
                        tipcam,
                        porigv
                    FROM
                        TABLE ( pack_trazabilidad.sp_trazabilidad_finv2(tmp_idcia, tmpnumint) )
                ) LOOP
                    output_record.indice := orden;
                    output_record.id_cia := input_recordfin.id_cia;
                    output_record.numint := input_recordfin.numint;
                    output_record.tipdoc := input_recordfin.tipdoc;
                    output_record.series := input_recordfin.series;
                    output_record.numdoc := input_recordfin.numdoc;
                    output_record.femisi := input_recordfin.femisi;
                    output_record.codmot := input_recordfin.codmot;
                    output_record.situac := input_recordfin.situac;
                    output_record.tipcam := input_recordfin.tipcam;
                    output_record.porigv := input_recordfin.porigv;
                    PIPE ROW ( output_record );
                END LOOP;

                orden := orden + 1;
            END IF;

        END LOOP;

    END sp_trazabilidad_finv2;

    FUNCTION sp_trazabilidad_ini (
        pid_cia NUMBER,
        pnumint NUMBER
    ) RETURN datatable
        PIPELINED
    IS

        output_record datarecord;
        orden         NUMBER;
        tmp_idcia     NUMBER;
        tmpnumint     NUMBER;
        CURSOR cselect (
            wid_cia NUMBER,
            wnumint NUMBER
        ) IS
        SELECT
            c.id_cia,
            c.numint,
            c.tipdoc,
            c.series,
            c.numdoc,
            c.femisi,
            c.codmot,
            c.situac
        FROM
            documentos_relacion r
            LEFT OUTER JOIN documentos_cab      c ON c.id_cia = r.id_cia
                                                AND c.numint = r.numint
        WHERE
                r.id_cia = wid_cia
            AND r.numintre = wnumint;

    BEGIN
        orden := 0;
        FOR input_record IN cselect(pid_cia, pnumint) LOOP
            tmp_idcia := input_record.id_cia;
            tmpnumint := input_record.numint;
            IF tmpnumint IS NOT NULL THEN
                output_record.indice := orden;
                output_record.id_cia := input_record.id_cia;
                output_record.numint := input_record.numint;
                output_record.tipdoc := input_record.tipdoc;
                output_record.series := input_record.series;
                output_record.numdoc := input_record.numdoc;
                output_record.femisi := input_record.femisi;
                output_record.codmot := input_record.codmot;
                output_record.situac := input_record.situac;
                PIPE ROW ( output_record );
                FOR input_recordini IN (
                    SELECT
                        id_cia,
                        numint,
                        tipdoc,
                        series,
                        numdoc,
                        femisi,
                        codmot,
                        situac
                    FROM
                        TABLE ( pack_trazabilidad.sp_trazabilidad_ini(tmp_idcia, tmpnumint) )
                ) LOOP
                    output_record.indice := orden;
                    output_record.id_cia := input_recordini.id_cia;
                    output_record.numint := input_recordini.numint;
                    output_record.tipdoc := input_recordini.tipdoc;
                    output_record.series := input_recordini.series;
                    output_record.numdoc := input_recordini.numdoc;
                    output_record.femisi := input_recordini.femisi;
                    output_record.codmot := input_recordini.codmot;
                    output_record.situac := input_recordini.situac;
                    PIPE ROW ( output_record );
                END LOOP;

                orden := orden + 1;
            END IF;

        END LOOP;

    END sp_trazabilidad_ini;

    FUNCTION sp_trazabilidadv2 (
        pid_cia NUMBER,
        pnumint NUMBER
    ) RETURN datatable
        PIPELINED
    IS

        output_record datarecord;
        orden         NUMBER;
        cont_ini      NUMBER;
        tmp_idcia     NUMBER;
        tmp_numint    NUMBER;
        wnumdocop     NUMBER;
        CURSOR cselectfin (
            wid_cia NUMBER,
            wnumint NUMBER
        ) IS
        SELECT
            id_cia,
            numint,
            tipdoc,
            series,
            numdoc,
            femisi,
            codmot,
            situac
        FROM
            TABLE ( pack_trazabilidad.sp_trazabilidad_fin(wid_cia, wnumint) )
        WHERE
            tipdoc IN ( 105, 127 )
        ORDER BY
            id_cia,
            indice;

    BEGIN
        cont_ini := 0;
        FOR input_recordfin IN cselectfin(pid_cia, pnumint) LOOP
            tmp_idcia := input_recordfin.id_cia;
            tmp_numint := input_recordfin.numint;
            IF ( length(tmp_numint) = 10 ) THEN
                NULL;
            ELSE
                cont_ini := cont_ini - 1;
                orden := cont_ini;
                output_record.indice := orden;
                output_record.id_cia := input_recordfin.id_cia;
                output_record.numint := input_recordfin.numint;
                output_record.tipdoc := input_recordfin.tipdoc;
                output_record.series := input_recordfin.series;
                output_record.numdoc := input_recordfin.numdoc;
                output_record.femisi := input_recordfin.femisi;
                output_record.codmot := input_recordfin.codmot;
                output_record.situac := input_recordfin.situac;
            END IF;

            PIPE ROW ( output_record );
        END LOOP;

    END sp_trazabilidadv2;

    FUNCTION sp_trazabilidad (
        pid_cia NUMBER,
        pnumint NUMBER
    ) RETURN datatable
        PIPELINED
    IS

        output_record datarecord;
        orden         NUMBER;
        cont_ini      NUMBER;
        tmp_idcia     NUMBER;
        tmp_numint    NUMBER;
        wnumdocop     NUMBER;
        -- OBTIENE EL DOCUMENTO ACTUAL
        CURSOR cselectdoccab (
            wid_cia NUMBER,
            wnumint NUMBER
        ) IS
        SELECT
            id_cia,
            numint,
            tipdoc,
            series,
            numdoc,
            femisi,
            codmot,
            situac
        FROM
            documentos_cab
        WHERE
                id_cia = wid_cia
            AND numint = wnumint;
        -- OBTIENE LOS DOCUMENTOS PADRES
        CURSOR cselectfin (
            wid_cia NUMBER,
            wnumint NUMBER
        ) IS
        SELECT
            id_cia,
            numint,
            tipdoc,
            series,
            numdoc,
            femisi,
            codmot,
            situac
        FROM
            TABLE ( pack_trazabilidad.sp_trazabilidad_fin(wid_cia, wnumint) ) -- RECURSIVO
        ORDER BY
            id_cia,
            indice;
        --- OBTIENE LOS DOCUMENTOS HIJOS 
        CURSOR cselectini (
            wid_cia NUMBER,
            wnumint NUMBER
        ) IS
        SELECT
            id_cia,
            numint,
            tipdoc,
            series,
            numdoc,
            femisi,
            codmot,
            situac
        FROM
            TABLE ( pack_trazabilidad.sp_trazabilidad_ini(wid_cia, wnumint) ) -- RECURSIVO
        GROUP BY
            id_cia,
            numint,
            tipdoc,
            series,
            numdoc,
            femisi,
            codmot,
            situac;

    BEGIN
        cont_ini := 0;
        -- PASO 1 - OBTENER DOCUMENTOS PADRES
        -- (cselectfin) CURSOR RECURSIVO
        FOR input_recordfin IN cselectfin(pid_cia, pnumint) LOOP
            cont_ini := cont_ini - 1; -- RESTANDO, DOCUMENTOS PADRES, SALEN CON ID NEGATIVO
            orden := cont_ini;
            output_record.indice := orden;
            output_record.id_cia := input_recordfin.id_cia;
            output_record.numint := input_recordfin.numint;
            output_record.tipdoc := input_recordfin.tipdoc;
            output_record.series := input_recordfin.series;
            output_record.numdoc := input_recordfin.numdoc;
            output_record.femisi := input_recordfin.femisi;
            output_record.codmot := input_recordfin.codmot;
            output_record.situac := input_recordfin.situac;
            PIPE ROW ( output_record ); -- IMPRIME
        END LOOP;

        -- PASO 2 - OBTENER DOCUMENTO ACTUAL
        FOR input_recorddoccab IN cselectdoccab(pid_cia, pnumint) LOOP
            output_record.indice := 0; -- DOCUMENTO ACTUAL SALE CON ID EN CERO
            output_record.id_cia := input_recorddoccab.id_cia;
            output_record.numint := input_recorddoccab.numint;
            output_record.tipdoc := input_recorddoccab.tipdoc;
            output_record.series := input_recorddoccab.series;
            output_record.numdoc := input_recorddoccab.numdoc;
            output_record.femisi := input_recorddoccab.femisi;
            output_record.codmot := input_recorddoccab.codmot;
            output_record.situac := input_recorddoccab.situac;
            PIPE ROW ( output_record ); -- IMPRIME
        END LOOP;

        cont_ini := 0;
        -- PASO 3 OBTENER DOCUMENTOS HIJOS
        -- (cselectini) CURSOR RECURSIVO
        FOR input_recordini IN cselectini(pid_cia, pnumint) LOOP
            cont_ini := cont_ini + 1; -- SUMANDO, DOCUMENTOS HIJOS SALEN CON ID POSITIVO
            orden := cont_ini;
            output_record.indice := orden;
            output_record.id_cia := input_recordini.id_cia;
            output_record.numint := input_recordini.numint;
            output_record.tipdoc := input_recordini.tipdoc;
            output_record.series := input_recordini.series;
            output_record.numdoc := input_recordini.numdoc;
            output_record.femisi := input_recordini.femisi;
            output_record.codmot := input_recordini.codmot;
            output_record.situac := input_recordini.situac;
            PIPE ROW ( output_record ); -- IMPRIME
        END LOOP;

    END sp_trazabilidad;

    -- POR PROBLEMAS EN TAGA  GI. -> 2 O.D. -> 2 101  -> 2 102 -> 2 Facturas ..
    FUNCTION sp_saca_documento_origen (
        pid_cia NUMBER,
        pnumint NUMBER
    ) RETURN datatable_documento_origen
        PIPELINED
    AS
        v_table datatable_documento_origen;
    BEGIN
        SELECT
            p.*
        BULK COLLECT
        INTO v_table
        FROM
            pack_trazabilidad.sp_saca_documento_origen2(pid_cia, pnumint) p
        ORDER BY
            p.numint DESC
        FETCH NEXT 1 ROWS ONLY;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_saca_documento_origen;

    FUNCTION sp_saca_documento_origen2 (
        pid_cia NUMBER,
        pnumint NUMBER
    ) RETURN datatable_documento_origen
        PIPELINED
    IS

        output_record datarecord_documento_origen;
        orden         NUMBER;
        cont_ini      NUMBER;
        wnumdocop     NUMBER;
        CURSOR cselectfin (
            wid_cia NUMBER,
            wnumint NUMBER
        ) IS
        SELECT
            id_cia,
            numint,
            tipdoc,
            series,
            numdoc,
            femisi,
            codmot,
            situac,
            tipcam,
            porigv
        FROM
            TABLE ( pack_trazabilidad.sp_trazabilidad_finv2(wid_cia, wnumint) )
        WHERE
            tipdoc IN ( 1, 3 )
        ORDER BY
            id_cia,
            indice;

    BEGIN
        cont_ini := 0;
        FOR input_recordfin IN cselectfin(pid_cia, pnumint) LOOP
            cont_ini := cont_ini - 1;
            orden := cont_ini;
            output_record.indice := orden;
            output_record.id_cia := input_recordfin.id_cia;
            output_record.numint := input_recordfin.numint;
            output_record.tipdoc := input_recordfin.tipdoc;
            output_record.series := input_recordfin.series;
            output_record.numdoc := input_recordfin.numdoc;
            output_record.femisi := input_recordfin.femisi;
            output_record.codmot := input_recordfin.codmot;
            output_record.situac := input_recordfin.situac;
            output_record.tipcam := input_recordfin.tipcam;
            output_record.porigv := input_recordfin.porigv;
            PIPE ROW ( output_record );
        END LOOP;

    END sp_saca_documento_origen2;

    FUNCTION sp_trazabilidad_tipdoc (
        pid_cia NUMBER,
        pnumint NUMBER,
        ptipdoc NUMBER
    ) RETURN table_tipdoc
        PIPELINED
    IS

        output_record record_tipdoc;
        CURSOR cselecttipdoc (
            wid_cia NUMBER,
            wnumint NUMBER,
            wtipdoc NUMBER
        ) IS
        SELECT
            id_cia,
            numint,
            tipdoc,
            series,
            numdoc,
            femisi,
            codmot,
            situac
        FROM
            TABLE ( pack_trazabilidad.sp_trazabilidad(wid_cia, wnumint) )
        WHERE
            tipdoc = wtipdoc
        ORDER BY
            numint DESC
        FETCH FIRST 1 ROW ONLY;

    BEGIN
        FOR registro IN cselecttipdoc(pid_cia, pnumint, ptipdoc) LOOP
            output_record.id_cia := registro.id_cia;
            output_record.numint := registro.numint;
            output_record.tipdoc := registro.tipdoc;
            output_record.series := registro.series;
            output_record.numdoc := registro.numdoc;
            output_record.femisi := registro.femisi;
            output_record.codmot := registro.codmot;
            output_record.situac := registro.situac;
            PIPE ROW ( output_record );
        END LOOP;
    END sp_trazabilidad_tipdoc;

END pack_trazabilidad;

/

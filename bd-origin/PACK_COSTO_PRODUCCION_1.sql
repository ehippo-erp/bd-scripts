--------------------------------------------------------
--  DDL for Package Body PACK_COSTO_PRODUCCION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_COSTO_PRODUCCION" AS

    PROCEDURE sp_update_kardex (
        pin_id_cia   IN INTEGER,
        pin_numint   IN INTEGER,
        pin_numite   IN INTEGER,
        pin_codmot   IN INTEGER,
        pin_cosuni01 IN NUMBER,
        pin_cosuni02 IN NUMBER,
        pin_coduser  IN VARCHAR2,
        pin_mensaje  OUT VARCHAR2
    ) AS

        v_gi_id_cia  INTEGER := 0;
        v_gi_numint  NUMBER := 0;
        v_gi_numite  INTEGER := 0;
        v_gi_cantid  NUMBER := 0;
        pout_mensaje VARCHAR2(1000 CHAR);
    BEGIN
        FOR i IN (
            SELECT
                dr.id_cia,
                dr.numint, -- GUIA INTERNA DE INGRESO, POR EL PRODUCTO PRODUCIDO
                d.numite,
                d.cantid
            FROM
                documentos_relacion dr
                LEFT OUTER JOIN documentos_cab      c ON c.id_cia = dr.id_cia
                                                    AND c.numint = dr.numint
                LEFT OUTER JOIN documentos_det      d ON d.id_cia = dr.id_cia
                                                    AND d.numint = dr.numint
                                                    AND d.numite = pin_numite
                INNER JOIN kardex              k ON k.id_cia = d.id_cia
                                       AND k.numint = d.numint
                                       AND k.numite = d.numite
            WHERE
                    dr.id_cia = pin_id_cia
                AND dr.numintre = pin_numint
                AND c.tipdoc = 103
                AND c.id = 'I'
                AND c.codmot = pin_codmot
                AND c.situac IN ( 'F' )
        ) LOOP
            dbms_output.put_line('UPDATE KARDEX '
                                 || v_gi_numint
                                 || ' - '
                                 || v_gi_numite
                                 || ' | '
                                 || pin_cosuni01
                                 || ' | '
                                 || pin_cosuni02
                                 || ' | '
                                 || i.cantid);

            UPDATE kardex
            SET
                cosmat01 = pin_cosuni01 * i.cantid,
                cosmob01 = 0,
                cosfab01 = 0,
                costot01 = pin_cosuni01 * i.cantid,
                costot02 = pin_cosuni02 * i.cantid,
                usuari = pin_coduser
            WHERE
                    id_cia = i.id_cia
                AND numint = i.numint
                AND numite = i.numite;

        END LOOP;

        COMMIT;
        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'El proceso se realizó satisfactoriamente'
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
        WHEN pkg_exceptionuser.ex_error_inesperado THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE pout_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN OTHERS THEN
            pin_mensaje := 'mensaje : '
                           || sqlerrm
                           || ' codigo :'
                           || sqlcode;
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pin_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

            ROLLBACK;
    END sp_update_kardex;

    PROCEDURE sp_procesar (
        pin_id_cia  IN INTEGER,
        pin_codmot  IN INTEGER,
        pin_periodo IN INTEGER,
        pin_mes     IN INTEGER,
        pin_totobra IN NUMBER,
        pin_totfrab IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS

        pout_mensaje VARCHAR2(1000 CHAR);
        v_fdesde     DATE;
        v_fhasta     DATE;
        v_numint     INTEGER := -1;
        v_numite     INTEGER := -1;
        v_cantid     NUMBER := 0;
        v_costot01   NUMBER := 0;
        v_costot02   NUMBER := 0;
        v_cosuni01   NUMBER := 0;
        v_cosuni02   NUMBER := 0;
        v_kcostot01  NUMBER := 0;
        v_kcostot02  NUMBER := 0;
        v_cosmat01   NUMBER := 0;
        v_cosmob01   NUMBER := 0;
        v_cosfab01   NUMBER := 0;
        v_mensaje    VARCHAR2(1000 CHAR);
        o            json_object_t;
    BEGIN
--     Ultima dia del Mes
        v_fhasta := last_day(trunc(TO_DATE(to_char('01'
                                                   || '/'
                                                   || pin_mes
                                                   || '/'
                                                   || pin_periodo), 'DD/MM/YYYY')));
    -- Primer dia del Mes
        v_fdesde := TO_DATE ( to_char('01'
                                      || '/'
                                      || pin_mes
                                      || '/'
                                      || pin_periodo), 'DD/MM/YYYY' );

        FOR i IN (
            SELECT
                c.id_cia,
                c.numint,
                d.numite,
                d.cantid,
                k.locali   AS klocali,
                dt.numint  AS knumint,
                dt.numite  AS knumite,
                k.femisi   AS kfemisi,
                k.tipinv   AS ktipinv,
                k.codart   AS kcodart,
                k.cantid   AS kcantid,
                k.id       AS kid,
                k.costot01 AS kcostot01,
                k.costot02 AS kcostot02,
                k.codadd01 AS codcalid,
                k.codadd02 AS codcolor
            FROM
                documentos_cab c
                LEFT OUTER JOIN documentos_det d ON d.id_cia = c.id_cia
                                                    AND d.numint = c.numint
                LEFT OUTER JOIN documentos_det dt ON dt.id_cia = d.id_cia
                                                     AND dt.opnumdoc = d.numint
                                                     AND dt.opnumite = d.numite
                INNER JOIN kardex         k ON k.id_cia = dt.id_cia
                                       AND k.numint = dt.numint
                                       AND k.numite = dt.numite
                LEFT OUTER JOIN motivos_clase  mc ON mc.id_cia = k.id_cia
                                                    AND mc.tipdoc = k.tipdoc
                                                    AND mc.id = k.id
                                                    AND mc.codmot = k.codmot
                                                    AND mc.codigo = 22
            WHERE
                    c.id_cia = pin_id_cia
                AND c.femisi BETWEEN v_fdesde AND v_fhasta
                AND c.tipdoc = 104
                AND c.situac NOT IN ( 'J', 'K' )
                AND c.codmot = pin_codmot
                AND k.id = 'S'
                AND nvl(mc.valor, 'N') <> 'S'
            ORDER BY
                c.id_cia,
                c.razonc,
                c.numint,
                d.numite,
                dt.numite
        ) LOOP
            IF v_numint <> i.numint OR v_numite <> i.numite THEN
                dbms_output.put_line('NUEVO DOCUMENTO Y/O ITEM '
                                     || v_numint
                                     || ' - '
                                     || v_numite);
                IF
                    v_costot01 > 0
                    AND v_costot02 > 0
                THEN
                    dbms_output.put_line('ASIGNANDO COSTOS');
                    v_cosuni01 := v_costot01 / v_cantid;
                    v_cosuni02 := v_costot02 / v_cantid;
                    dbms_output.put_line('COSTO UNITARIO : '
                                         || v_cosuni01
                                         || ' | '
                                         || v_cosuni02);
                    pack_costo_produccion.sp_update_kardex(pin_id_cia, v_numint, v_numite, pin_codmot, v_cosuni01,
                                                          v_cosuni02, pin_coduser, v_mensaje);

                    o := json_object_t.parse(v_mensaje);
                    IF ( o.get_number('status') <> 1.0 ) THEN
                        pout_mensaje := o.get_string('message');
                        RAISE pkg_exceptionuser.ex_error_inesperado;
                    END IF;

                END IF;

                v_costot01 := 0;
                v_costot02 := 0;
            END IF;

            v_costot01 := v_costot01 + i.kcostot01;
            v_costot02 := v_costot02 + i.kcostot02;
            dbms_output.put_line(i.kcostot01
                                 || ' | '
                                 || i.kcostot02
                                 || ' - '
                                 || v_costot01
                                 || ' | '
                                 || v_costot02);

            v_numint := i.numint;
            v_numite := i.numite;
            v_cantid := i.cantid;
        END LOOP;
        -- EJECUTANDO UNA VEZ MAS, POR EL ULTIMO DOCUMENTO O ITEM
        dbms_output.put_line('NUEVO DOCUMENTO Y/O ITEM '
                             || v_numint
                             || ' - '
                             || v_numite);
        dbms_output.put_line('ASIGNANDO COSTOS');
        v_cosuni01 := v_costot01 / v_cantid;
        v_cosuni02 := v_costot02 / v_cantid;
        dbms_output.put_line('COSTO UNITARIO : '
                             || v_cosuni01
                             || ' | '
                             || v_cosuni02);
        pack_costo_produccion.sp_update_kardex(pin_id_cia, v_numint, v_numite, pin_codmot, v_cosuni01,
                                              v_cosuni02, pin_coduser, v_mensaje);

        o := json_object_t.parse(v_mensaje);
        IF ( o.get_number('status') <> 1.0 ) THEN
            pout_mensaje := o.get_string('message');
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;

        COMMIT;

        -- PRORATEANDO COSTOS
        IF pin_totobra > 0 OR pin_totfrab > 0 THEN
            SELECT --- SUMANDO TODAS LAS GUIAS POR INGRESO DE MATERIALES
                SUM(k.costot01) AS costotsol,
                SUM(k.costot02) AS costotdol
            INTO
                v_kcostot01,
                v_kcostot02
            FROM
                documentos_cab c
                LEFT OUTER JOIN documentos_det d ON d.id_cia = c.id_cia
                                                    AND d.numint = c.numint
                INNER JOIN kardex         k ON k.id_cia = d.id_cia
                                       AND k.numint = d.numint
                                       AND k.numite = d.numite
                LEFT OUTER JOIN motivos_clase  mc ON mc.id_cia = k.id_cia
                                                    AND mc.tipdoc = k.tipdoc
                                                    AND mc.id = k.id
                                                    AND mc.codmot = k.codmot
                                                    AND mc.codigo = 22
            WHERE
                    c.id_cia = pin_id_cia
                AND c.femisi BETWEEN v_fdesde AND v_fhasta
                AND c.tipdoc = 103
                AND c.situac = 'F'
                AND c.codmot = pin_codmot
                AND k.id = 'I'
                AND nvl(mc.valor, 'N') <> 'S';

            dbms_output.put_line('TOTAL COSTEADO : '
                                 || v_kcostot01
                                 || ' | '
                                 || v_kcostot02);
            FOR j IN (
                SELECT
                    k.id_cia,
                    k.locali,
                    d.opnumdoc,
                    d.opnumite,
                    c.tipcam,
                    k.femisi,
                    k.tipinv,
                    k.codart,
                    k.cantid,
                    k.id,
                    k.costot01,
                    k.costot02,
                    k.codadd01 AS codcalid,
                    k.codadd02 AS codcolor
                FROM
                    documentos_cab c
                    LEFT OUTER JOIN documentos_det d ON d.id_cia = c.id_cia
                                                        AND d.numint = c.numint
                    INNER JOIN kardex         k ON k.id_cia = d.id_cia
                                           AND k.numint = d.numint
                                           AND k.numite = d.numite
                    LEFT OUTER JOIN motivos_clase  mc ON mc.id_cia = k.id_cia
                                                        AND mc.tipdoc = k.tipdoc
                                                        AND mc.id = k.id
                                                        AND mc.codmot = k.codmot
                                                        AND mc.codigo = 22
                WHERE
                        c.id_cia = pin_id_cia
                    AND c.femisi BETWEEN v_fdesde AND v_fhasta
                    AND c.tipdoc = 103
                    AND c.situac = 'F'
                    AND c.codmot = pin_codmot
                    AND k.id = 'I'
                    AND nvl(mc.valor, 'N') <> 'S'
                ORDER BY
                    k.id_cia,
                    k.locali
            ) LOOP
                IF j.costot01 > 0 OR j.costot02 > 0 THEN
                    v_cosmat01 := j.costot01;
                    v_cosmob01 := ( j.costot01 * pin_totobra ) / v_kcostot01;
                    v_cosfab01 := ( j.costot01 * pin_totfrab ) / v_kcostot01;
                    v_costot01 := v_cosmat01 + v_cosmob01 + v_cosfab01;
                    v_costot02 := v_costot01 / j.tipcam;
                END IF;

                UPDATE kardex
                SET
                    cosmat01 = v_cosmat01,
                    cosmob01 = v_cosmob01,
                    cosfab01 = v_cosfab01,
                    costot01 = v_costot01,
                    costot02 = v_costot02,
                    usuari = pin_coduser
                WHERE
                        id_cia = j.id_cia
                    AND locali = j.locali;

            END LOOP;

        ELSE
            FOR j IN (
                SELECT
                    k.id_cia,
                    k.locali,
                    d.opnumdoc,
                    d.opnumite,
                    c.tipcam,
                    k.femisi,
                    k.tipinv,
                    k.codart,
                    k.cantid,
                    k.id,
                    k.costot01,
                    k.costot02,
                    k.codadd01 AS codcalid,
                    k.codadd02 AS codcolor
                FROM
                    documentos_cab c
                    LEFT OUTER JOIN documentos_det d ON d.id_cia = c.id_cia
                                                        AND d.numint = c.numint
                    INNER JOIN kardex         k ON k.id_cia = d.id_cia
                                           AND k.numint = d.numint
                                           AND k.numite = d.numite
                    LEFT OUTER JOIN motivos_clase  mc ON mc.id_cia = k.id_cia
                                                        AND mc.tipdoc = k.tipdoc
                                                        AND mc.id = k.id
                                                        AND mc.codmot = k.codmot
                                                        AND mc.codigo = 22
                WHERE
                        c.id_cia = pin_id_cia
                    AND c.femisi BETWEEN v_fdesde AND v_fhasta
                    AND c.tipdoc = 103
                    AND c.situac = 'F'
                    AND c.codmot = pin_codmot
                    AND k.id = 'I'
                    AND nvl(mc.valor, 'N') <> 'S'
                ORDER BY
                    k.id_cia,
                    k.locali
            ) LOOP
                UPDATE kardex
                SET
                    cosmat01 = j.costot01,
                    cosmob01 = 0,
                    cosfab01 = 0,
                    costot01 = j.costot01,
                    costot02 = j.costot02,
                    usuari = pin_coduser
                WHERE
                        id_cia = j.id_cia
                    AND locali = j.locali;

            END LOOP;
        END IF;

        COMMIT;
        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'El proceso se realizó satisfactoriamente'
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
        WHEN pkg_exceptionuser.ex_error_inesperado THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE pout_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN OTHERS THEN
            pin_mensaje := 'mensaje : '
                           || sqlerrm
                           || ' codigo :'
                           || sqlcode;
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pin_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

    END;

END;

/

--------------------------------------------------------
--  DDL for Package Body PACK_DW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_DW" AS

    PROCEDURE sp_dw_cventas_all (
        pin_fdesde IN DATE,
        pin_fhasta IN DATE
    ) AS

        v_fdesde        DATE;
        v_fhasta        DATE;
        o               json_object_t;
        o_hijas         json_object_t;
        mensaje         VARCHAR2(1000);
        v_mensaje_hijas VARCHAR2(1000);
        v_mensaje       VARCHAR2(1000);
        v_situac        VARCHAR2(1);
        v_situac_hijas  VARCHAR2(1);
        CURSOR registro_cia IS
        SELECT DISTINCT
            cia
        FROM
            companias
        WHERE
            swacti = 'S';
-- Companias Ignoradas 8,50,47,39,30,19,14 (Menos de 10 Registros en Documentos_Cab)
    BEGIN
    --  ACTUALIZACION MASICA DEL CVENTAS
        IF pin_fhasta IS NULL THEN
            v_fhasta := trunc(sysdate);
        ELSE
            v_fhasta := trunc(pin_fhasta);
        END IF;

        IF pin_fdesde IS NULL THEN
            v_fdesde := trunc(v_fhasta - 180);
        ELSE
            v_fdesde := trunc(pin_fdesde);
        END IF;

        BEGIN
            FOR i IN registro_cia LOOP
                v_mensaje := '';
                v_situac := 'F';
                v_mensaje_hijas := '';
                v_situac_hijas := 'F';
                pack_dw.sp_dw_cventas(i.cia, v_fdesde, v_fhasta, mensaje);
                o := json_object_t.parse(mensaje);
                v_mensaje := o.get_string('message');
                IF ( o.get_number('status') <> 1.0 ) THEN
                    v_situac := 'F';
                ELSE
                    v_situac := 'S';
                    --  ACTUALIZACION MASICA DEL CVENTAS HIJAS
                    pack_dw.sp_dw_actualiza_cventas_hijas(i.cia, 0, mensaje);
                    o_hijas := json_object_t.parse(mensaje);
                    v_mensaje_hijas := o_hijas.get_string('message');
                    IF ( o.get_number('status') <> 1.0 ) THEN
                        v_situac_hijas := 'F';
                    ELSE
                        v_situac_hijas := 'S';
                    END IF;

                END IF;

                INSERT INTO dw_log_cventas (
                    id_cia,
                    situac,
                    mensaje,
                    situac_hijas,
                    mensaje_hijas,
                    fdesde,
                    fhasta,
                    fcreac,
                    factua
                ) VALUES (
                    i.cia,
                    v_situac,
                    v_mensaje,
                    v_situac_hijas,
                    v_mensaje_hijas,
                    v_fdesde,
                    v_fhasta,
                    sysdate,
                    sysdate
                );

                COMMIT;
            END LOOP;
        END;

    END sp_dw_cventas_all;

    FUNCTION sp_deskardex (
        pin_id_cia IN NUMBER,
        pin_numint IN NUMBER,
        pin_numite IN NUMBER
    ) RETURN VARCHAR2 AS
        v_count NUMBER;
        v_valor VARCHAR2(1);
    BEGIN
        BEGIN
            SELECT
                COUNT(0) AS valor
            INTO v_count
            FROM
                kardex
            WHERE
                    id_cia = pin_id_cia
                AND numint = pin_numint
                AND numite = pin_numite;

        EXCEPTION
            WHEN no_data_found THEN
                v_count := 0;
        END;

        IF ( ( v_count IS NULL ) OR ( v_count = 0 ) ) THEN
            v_valor := 'G';
        ELSE
            v_valor := 'F';
        END IF;

        RETURN v_valor;
    END sp_deskardex;

    PROCEDURE sp_dw_cventas (
        pin_id_cia  IN NUMBER,
        pin_fdesde  IN DATE,
        pin_fhasta  IN DATE,
        pin_mensaje OUT VARCHAR2
    ) AS
    BEGIN
        DELETE FROM dw_cventas
        WHERE
                id_cia = pin_id_cia
            AND ( femisi BETWEEN pin_fdesde AND pin_fhasta );

        COMMIT;
        INSERT ALL INTO dw_cventas VALUES (
            id_cia,
            numint,
            numite,
            tipdoc,
            tipodocumento,
            id,
            codmot,
            codsuc,
            sucursal,
            diasemana,
            mes,
            periodo,
            idmes,
            mesid,
            series,
            numdoc,
            femisi,
            tipcam,
            codcpag,
            codcli,
            cliente,
            ruc,
            codvencar,
            codvendoc,
            moneda,
            tipinv,
            codart,
            etiqueta,
            codadd01,
            codadd02,
            signo,
            cantid,
            cstsol,
            cstdol,
            prusol,
            prudol,
            vntsol,
            vntdol,
            porcom,
            porigv,
            igvsol,
            igvdol,
            current_date,
            current_date,
            'N'
        ) SELECT
                dr.id_cia                                                                         AS id_cia,
                dr.numint                                                                         AS numint,
                df.numite                                                                         AS numite,
                dr.tipdoc                                                                         AS tipdoc,
                dc.desdoc                                                                         AS tipodocumento,
                dr.id                                                                             AS id,
                dr.codmot                                                                         AS codmot,
                dr.codsuc,
                upper(s.sucursal)                                                                 AS sucursal,
                to_char(dr.femisi, 'DAY', 'NLS_DATE_LANGUAGE=SPANISH')                            AS diasemana,
                to_char(dr.femisi, 'MONTH', 'NLS_DATE_LANGUAGE=SPANISH')                          AS mes,
                TO_NUMBER(to_char(dr.femisi, 'YYYY'))                                             AS periodo,
                TO_NUMBER(to_char(dr.femisi, 'MM'))                                               AS idmes,
                TO_NUMBER(to_char(dr.femisi, 'YYYY')) * 100 + TO_NUMBER(to_char(dr.femisi, 'MM')) AS mesid,
                dr.series                                                                         AS series,
                dr.numdoc                                                                         AS numdoc,
                dr.femisi                                                                         AS femisi,
                dr.tipcam                                                                         AS tipcam,
                dr.codcpag                                                                        AS codcpag,
                dr.codcli                                                                         AS codcli,
                dr.razonc                                                                         AS cliente,
                dr.ruc                                                                            AS ruc,
                cl.codven                                                                         AS codvencar,
                dr.codven                                                                         AS codvendoc,
                dr.tipmon                                                                         AS moneda,
                df.tipinv                                                                         AS tipinv,
                df.codart                                                                         AS codart,
                df.etiqueta                                                                       AS etiqueta,
                df.codadd01                                                                       AS codadd01,
                df.codadd02                                                                       AS codadd02,
                dc.signo                                                                          AS signo,
                df.cantid * dc.signo                                                              AS cantid,
--                a.faccon                                                                          AS faccon,
--                CAST((
--                    CASE
--                        WHEN a.faccon <> 0 THEN
--                            (df.cantid * a.faccon / 1000)
--                        ELSE
--                            (
--                                CASE
--                                    WHEN ks.kilosunit IS NULL THEN
--                                        0
--                                    ELSE
--                                        (ks.kilosunit * df.cantid) / 1000
--                                END
--                            )
--                    END
--                    * dc.signo) AS NUMERIC(20, 8))                                                    AS toneladas,
                nvl(k.costot01 * dc.signo, 0)                                                     AS cstsol,
                nvl(k.costot02 * dc.signo, 0)                                                     AS cstdol,
                CAST(
                    CASE
                        WHEN(df.cantid IS NULL)
                            OR(df.cantid = 0) THEN
                            0
                        ELSE
                            CASE
                                WHEN dr.tipmon = 'PEN' THEN
                                        (df.monafe + df.monina) / CAST(df.cantid AS NUMERIC(20, 8))
                                ELSE
                                    ((df.monafe + df.monina) * dr.tipcam) / CAST(df.cantid AS NUMERIC(20, 8))
                            END
                            * dc.signo
                    END
                AS NUMERIC(20,
                     8))                                                                          AS prusol,
                CAST(
                    CASE
                        WHEN(df.cantid IS NULL)
                            OR(df.cantid = 0) THEN
                            0
                        ELSE
                            CASE
                                WHEN dr.tipmon = 'USD' THEN
                                        (df.monafe + df.monina) / CAST(df.cantid AS NUMERIC(20, 8))
                                ELSE
                                    ((df.monafe + df.monina) / dr.tipcam) / CAST(df.cantid AS NUMERIC(20, 8))
                            END
                            * dc.signo
                    END
                AS NUMERIC(20,
                     8))                                                                          AS prudol,
                CAST(
                    CASE
                        WHEN dr.tipmon = 'PEN' THEN
                            (df.monafe + df.monina)
                        ELSE
                            ((df.monafe + df.monina) * dr.tipcam)
                    END
                    * dc.signo AS NUMERIC(20, 8))                                                     AS vntsol,
                CAST(
                    CASE
                        WHEN dr.tipmon = 'USD' THEN
                            (df.monafe + df.monina)
                        ELSE
                            ((df.monafe + df.monina) / dr.tipcam)
                    END
                    * dc.signo AS NUMERIC(20, 8))                                                     AS vntdol,
                NULL                                                                              AS porcom,
                df.porigv                                                                         AS porigv,
                CAST(
                    CASE
                        WHEN dr.tipmon = 'USD' THEN
                            (df.monigv)
                        ELSE
                            ((df.monigv) / dr.tipcam)
                    END
                    * dc.signo AS NUMERIC(18, 8))                                                     AS igvdol,
                CAST(
                    CASE
                        WHEN dr.tipmon = 'PEN' THEN
                            (df.monigv)
                        ELSE
                            ((df.monigv) * dr.tipcam)
                    END
                    * dc.signo AS NUMERIC(20, 8))                                                     AS igvsol
            FROM
                     documentos_cab dr
                INNER JOIN documentos_det    df ON df.id_cia = dr.id_cia
                                                AND df.numint = dr.numint
                LEFT OUTER JOIN kardex_costoventa k ON k.id_cia = dr.id_cia
                                                       AND k.numint = dr.numint
                                                       AND k.numite = df.numite
                LEFT OUTER JOIN dw_tipodocumento  dc ON dc.tipdoc = dr.tipdoc
                LEFT OUTER JOIN sucursal          s ON s.id_cia = dr.id_cia
                                              AND s.codsuc = dr.codsuc
                LEFT OUTER JOIN cliente           cl ON cl.id_cia = dr.id_cia
                                              AND cl.codcli = dr.codcli
--                LEFT OUTER JOIN kilos_unitario          ks ON ks.id_cia = dr.id_cia
--                                                     AND ks.tipinv = df.tipinv
--                                                     AND ks.codart = df.codart
--                                                     AND ks.etiqueta = df.etiqueta
--                LEFT OUTER JOIN articulos               a ON a.id_cia = dr.id_cia
--                                               AND a.tipinv = df.tipinv
--                                               AND a.codart = df.codart
                LEFT OUTER JOIN motivos_clase     mt44 ON mt44.id_cia = dr.id_cia
                                                      AND mt44.tipdoc = dr.tipdoc
                                                      AND mt44.codmot = dr.codmot
                                                      AND mt44.id = dr.id
                                                      AND mt44.codigo = 44
          WHERE
                  dr.id_cia = pin_id_cia
              AND ( dr.femisi BETWEEN pin_fdesde AND pin_fhasta )
              AND dr.tipdoc IN ( 1, 3, 7, 8, 210 )
              AND dr.situac IN ( 'C', 'B', 'H', 'G', 'F' )
              AND nvl(mt44.valor, 'N') <> 'S';

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'El Cubo para la Compañia [ '
                                || pin_id_cia
                                || ' ] y para el periodo [ '
                                || pin_fdesde
                                || ' - '
                                || pin_fhasta
                                || ' ] se a actualizado con exito ...!'
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
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

    END sp_dw_cventas;

    PROCEDURE sp_dw_cventasv2 (
        pin_id_cia IN NUMBER,
        pin_fdesde IN DATE,
        pin_fhasta IN DATE
    ) AS
    BEGIN
        DELETE FROM dw_cventas
        WHERE
                id_cia = pin_id_cia
            AND ( femisi BETWEEN pin_fdesde AND pin_fhasta );

        COMMIT;
        INSERT ALL INTO dw_cventas VALUES (
            id_cia,
            numint,
            numite,
            tipdoc,
            tipodocumento,
            id,
            codmot,
            codsuc,
            sucursal,
            diasemana,
            mes,
            periodo,
            idmes,
            mesid,
            series,
            numdoc,
            femisi,
            tipcam,
            codcpag,
            codcli,
            cliente,
            ruc,
            codvencar,
            codvendoc,
            moneda,
            tipinv,
            codart,
            etiqueta,
            codadd01,
            codadd02,
            signo,
            cantid,
            cstsol,
            cstdol,
            prusol,
            prudol,
            vntsol,
            vntdol,
            porcom,
            porigv,
            igvsol,
            igvdol,
            current_date,
            current_date,
            'N'
        ) SELECT
                dr.id_cia                                                                         AS id_cia,
                dr.numint                                                                         AS numint,
                df.numite                                                                         AS numite,
                dr.tipdoc                                                                         AS tipdoc,
                dc.desdoc                                                                         AS tipodocumento,
                dr.id                                                                             AS id,
                dr.codmot                                                                         AS codmot,
                dr.codsuc,
                upper(s.sucursal)                                                                 AS sucursal,
                to_char(dr.femisi, 'DAY', 'NLS_DATE_LANGUAGE=SPANISH')                            AS diasemana,
                to_char(dr.femisi, 'MONTH', 'NLS_DATE_LANGUAGE=SPANISH')                          AS mes,
                TO_NUMBER(to_char(dr.femisi, 'YYYY'))                                             AS periodo,
                TO_NUMBER(to_char(dr.femisi, 'MM'))                                               AS idmes,
                TO_NUMBER(to_char(dr.femisi, 'YYYY')) * 100 + TO_NUMBER(to_char(dr.femisi, 'MM')) AS mesid,
                dr.series                                                                         AS series,
                dr.numdoc                                                                         AS numdoc,
                dr.femisi                                                                         AS femisi,
                dr.tipcam                                                                         AS tipcam,
                dr.codcpag                                                                        AS codcpag,
                dr.codcli                                                                         AS codcli,
                dr.razonc                                                                         AS cliente,
                dr.ruc                                                                            AS ruc,
                cl.codven                                                                         AS codvencar,
                dr.codven                                                                         AS codvendoc,
                dr.tipmon                                                                         AS moneda,
                df.tipinv                                                                         AS tipinv,
                df.codart                                                                         AS codart,
                df.etiqueta                                                                       AS etiqueta,
                df.codadd01                                                                       AS codadd01,
                df.codadd02                                                                       AS codadd02,
                dc.signo                                                                          AS signo,
                df.cantid * dc.signo                                                              AS cantid,
--                a.faccon                                                                          AS faccon,
--                CAST((
--                    CASE
--                        WHEN a.faccon <> 0 THEN
--                            (df.cantid * a.faccon / 1000)
--                        ELSE
--                            (
--                                CASE
--                                    WHEN ks.kilosunit IS NULL THEN
--                                        0
--                                    ELSE
--                                        (ks.kilosunit * df.cantid) / 1000
--                                END
--                            )
--                    END
--                    * dc.signo) AS NUMERIC(20, 8))                                                    AS toneladas,
                nvl(k.costot01 * dc.signo, 0)                                                     AS cstsol,
                nvl(k.costot02 * dc.signo, 0)                                                     AS cstdol,
                CAST(
                    CASE
                        WHEN(df.cantid IS NULL)
                            OR(df.cantid = 0) THEN
                            0
                        ELSE
                            CASE
                                WHEN dr.tipmon = 'PEN' THEN
                                        (df.monafe + df.monina) / CAST(df.cantid AS NUMERIC(20, 8))
                                ELSE
                                    ((df.monafe + df.monina) * dr.tipcam) / CAST(df.cantid AS NUMERIC(20, 8))
                            END
                            * dc.signo
                    END
                AS NUMERIC(20,
                     8))                                                                          AS prusol,
                CAST(
                    CASE
                        WHEN(df.cantid IS NULL)
                            OR(df.cantid = 0) THEN
                            0
                        ELSE
                            CASE
                                WHEN dr.tipmon = 'USD' THEN
                                        (df.monafe + df.monina) / CAST(df.cantid AS NUMERIC(20, 8))
                                ELSE
                                    ((df.monafe + df.monina) / dr.tipcam) / CAST(df.cantid AS NUMERIC(20, 8))
                            END
                            * dc.signo
                    END
                AS NUMERIC(20,
                     8))                                                                          AS prudol,
                CAST(
                    CASE
                        WHEN dr.tipmon = 'PEN' THEN
                            (df.monafe + df.monina)
                        ELSE
                            ((df.monafe + df.monina) * dr.tipcam)
                    END
                    * dc.signo AS NUMERIC(20, 8))                                                     AS vntsol,
                CAST(
                    CASE
                        WHEN dr.tipmon = 'USD' THEN
                            (df.monafe + df.monina)
                        ELSE
                            ((df.monafe + df.monina) / dr.tipcam)
                    END
                    * dc.signo AS NUMERIC(20, 8))                                                     AS vntdol,
                NULL                                                                              AS porcom,
                df.porigv                                                                         AS porigv,
                CAST(
                    CASE
                        WHEN dr.tipmon = 'USD' THEN
                            (df.monigv)
                        ELSE
                            ((df.monigv) / dr.tipcam)
                    END
                    * dc.signo AS NUMERIC(18, 8))                                                     AS igvdol,
                CAST(
                    CASE
                        WHEN dr.tipmon = 'PEN' THEN
                            (df.monigv)
                        ELSE
                            ((df.monigv) * dr.tipcam)
                    END
                    * dc.signo AS NUMERIC(20, 8))                                                     AS igvsol
            FROM
                     documentos_cab dr
                INNER JOIN documentos_det    df ON df.id_cia = dr.id_cia
                                                AND df.numint = dr.numint
                LEFT OUTER JOIN kardex_costoventa k ON k.id_cia = dr.id_cia
                                                       AND k.numint = dr.numint
                                                       AND k.numite = df.numite
                LEFT OUTER JOIN dw_tipodocumento  dc ON dc.tipdoc = dr.tipdoc
                LEFT OUTER JOIN sucursal          s ON s.id_cia = dr.id_cia
                                              AND s.codsuc = dr.codsuc
                LEFT OUTER JOIN cliente           cl ON cl.id_cia = dr.id_cia
                                              AND cl.codcli = dr.codcli
--                LEFT OUTER JOIN kilos_unitario          ks ON ks.id_cia = dr.id_cia
--                                                     AND ks.tipinv = df.tipinv
--                                                     AND ks.codart = df.codart
--                                                     AND ks.etiqueta = df.etiqueta
--                LEFT OUTER JOIN articulos               a ON a.id_cia = dr.id_cia
--                                               AND a.tipinv = df.tipinv
--                                               AND a.codart = df.codart
                LEFT OUTER JOIN motivos_clase     mt44 ON mt44.id_cia = dr.id_cia
                                                      AND mt44.tipdoc = dr.tipdoc
                                                      AND mt44.codmot = dr.codmot
                                                      AND mt44.id = dr.id
                                                      AND mt44.codigo = 44
          WHERE
                  dr.id_cia = pin_id_cia
              AND ( dr.femisi BETWEEN pin_fdesde AND pin_fhasta )
              AND dr.tipdoc IN ( 1, 3, 7, 8, 210 )
              AND dr.situac IN ( 'C', 'B', 'H', 'G', 'F' )
              AND nvl(mt44.valor, 'N') <> 'S';

    END sp_dw_cventasv2;

    PROCEDURE sp_dw_cventas_actualiza (
        pin_id_cia  IN NUMBER,
        pin_numint  IN NUMBER,
        pin_mensaje OUT VARCHAR2
    ) AS
    BEGIN
        DELETE FROM dw_cventas
        WHERE
                id_cia = pin_id_cia
            AND numintfac = pin_numint;

        COMMIT;
        INSERT ALL INTO dw_cventas VALUES (
            id_cia,
            numint,
            numite,
            tipdoc,
            tipodocumento,
            id,
            codmot,
            codsuc,
            sucursal,
            diasemana,
            mes,
            periodo,
            idmes,
            mesid,
            series,
            numdoc,
            femisi,
            tipcam,
            codcpag,
            codcli,
            cliente,
            ruc,
            codvencar,
            codvendoc,
            moneda,
            tipinv,
            codart,
            etiqueta,
            codadd01,
            codadd02,
            signo,
            cantid,
            cstsol,
            cstdol,
            prusol,
            prudol,
            vntsol,
            vntdol,
            porcom,
            porigv,
            igvsol,
            igvdol,
            current_date,
            current_date,
            'N'
        ) SELECT
                dr.id_cia                                                                         AS id_cia,
                dr.numint                                                                         AS numint,
                df.numite                                                                         AS numite,
                dr.tipdoc                                                                         AS tipdoc,
                dc.desdoc                                                                         AS tipodocumento,
                dr.id                                                                             AS id,
                dr.codmot                                                                         AS codmot,
                dr.codsuc,
                upper(s.sucursal)                                                                 AS sucursal,
                to_char(dr.femisi, 'DAY', 'NLS_DATE_LANGUAGE=SPANISH')                            AS diasemana,
                to_char(dr.femisi, 'MONTH', 'NLS_DATE_LANGUAGE=SPANISH')                          AS mes,
                TO_NUMBER(to_char(dr.femisi, 'YYYY'))                                             AS periodo,
                TO_NUMBER(to_char(dr.femisi, 'MM'))                                               AS idmes,
                TO_NUMBER(to_char(dr.femisi, 'YYYY')) * 100 + TO_NUMBER(to_char(dr.femisi, 'MM')) AS mesid,
                dr.series                                                                         AS series,
                dr.numdoc                                                                         AS numdoc,
                dr.femisi                                                                         AS femisi,
                dr.tipcam                                                                         AS tipcam,
                dr.codcpag                                                                        AS codcpag,
                dr.codcli                                                                         AS codcli,
                dr.razonc                                                                         AS cliente,
                dr.ruc                                                                            AS ruc,
                cl.codven                                                                         AS codvencar,
                dr.codven                                                                         AS codvendoc,
                dr.tipmon                                                                         AS moneda,
                df.tipinv                                                                         AS tipinv,
                df.codart                                                                         AS codart,
                df.etiqueta                                                                       AS etiqueta,
                df.codadd01                                                                       AS codadd01,
                df.codadd02                                                                       AS codadd02,
                dc.signo                                                                          AS signo,
                df.cantid * dc.signo                                                              AS cantid,
--                a.faccon                                                                          AS faccon,
--                CAST((
--                    CASE
--                        WHEN a.faccon <> 0 THEN
--                            (df.cantid * a.faccon / 1000)
--                        ELSE
--                            (
--                                CASE
--                                    WHEN ks.kilosunit IS NULL THEN
--                                        0
--                                    ELSE
--                                        (ks.kilosunit * df.cantid) / 1000
--                                END
--                            )
--                    END
--                    * dc.signo) AS NUMERIC(20, 8))                                                    AS toneladas,
                nvl(k.costot01 * dc.signo, 0)                                                     AS cstsol,
                nvl(k.costot02 * dc.signo, 0)                                                     AS cstdol,
                CAST(
                    CASE
                        WHEN(df.cantid IS NULL)
                            OR(df.cantid = 0) THEN
                            0
                        ELSE
                            CASE
                                WHEN dr.tipmon = 'PEN' THEN
                                        (df.monafe + df.monina) / CAST(df.cantid AS NUMERIC(20, 8))
                                ELSE
                                    ((df.monafe + df.monina) * dr.tipcam) / CAST(df.cantid AS NUMERIC(20, 8))
                            END
                            * dc.signo
                    END
                AS NUMERIC(20,
                     8))                                                                          AS prusol,
                CAST(
                    CASE
                        WHEN(df.cantid IS NULL)
                            OR(df.cantid = 0) THEN
                            0
                        ELSE
                            CASE
                                WHEN dr.tipmon = 'USD' THEN
                                        (df.monafe + df.monina) / CAST(df.cantid AS NUMERIC(20, 8))
                                ELSE
                                    ((df.monafe + df.monina) / dr.tipcam) / CAST(df.cantid AS NUMERIC(20, 8))
                            END
                            * dc.signo
                    END
                AS NUMERIC(20,
                     8))                                                                          AS prudol,
                CAST(
                    CASE
                        WHEN dr.tipmon = 'PEN' THEN
                            (df.monafe + df.monina)
                        ELSE
                            ((df.monafe + df.monina) * dr.tipcam)
                    END
                    * dc.signo AS NUMERIC(20, 8))                                                     AS vntsol,
                CAST(
                    CASE
                        WHEN dr.tipmon = 'USD' THEN
                            (df.monafe + df.monina)
                        ELSE
                            ((df.monafe + df.monina) / dr.tipcam)
                    END
                    * dc.signo AS NUMERIC(20, 8))                                                     AS vntdol,
                NULL                                                                              AS porcom,
                df.porigv                                                                         AS porigv,
                CAST(
                    CASE
                        WHEN dr.tipmon = 'USD' THEN
                            (df.monigv)
                        ELSE
                            ((df.monigv) / dr.tipcam)
                    END
                    * dc.signo AS NUMERIC(18, 8))                                                     AS igvdol,
                CAST(
                    CASE
                        WHEN dr.tipmon = 'PEN' THEN
                            (df.monigv)
                        ELSE
                            ((df.monigv) * dr.tipcam)
                    END
                    * dc.signo AS NUMERIC(20, 8))                                                     AS igvsol
            FROM
                     documentos_cab dr
                INNER JOIN documentos_det    df ON df.id_cia = dr.id_cia
                                                AND df.numint = dr.numint
                LEFT OUTER JOIN kardex_costoventa k ON k.id_cia = dr.id_cia
                                                       AND k.numint = dr.numint
                                                       AND k.numite = df.numite
                LEFT OUTER JOIN dw_tipodocumento  dc ON dc.tipdoc = dr.tipdoc
                LEFT OUTER JOIN sucursal          s ON s.id_cia = dr.id_cia
                                              AND s.codsuc = dr.codsuc
                LEFT OUTER JOIN cliente           cl ON cl.id_cia = dr.id_cia
                                              AND cl.codcli = dr.codcli
--                LEFT OUTER JOIN kilos_unitario          ks ON ks.id_cia = dr.id_cia
--                                                     AND ks.tipinv = df.tipinv
--                                                     AND ks.codart = df.codart
--                                                     AND ks.etiqueta = df.etiqueta
--                LEFT OUTER JOIN articulos               a ON a.id_cia = dr.id_cia
--                                               AND a.tipinv = df.tipinv
--                                               AND a.codart = df.codart
                LEFT OUTER JOIN motivos_clase     mt44 ON mt44.id_cia = dr.id_cia
                                                      AND mt44.tipdoc = dr.tipdoc
                                                      AND mt44.codmot = dr.codmot
                                                      AND mt44.id = dr.id
                                                      AND mt44.codigo = 44
          WHERE
                  dr.id_cia = pin_id_cia
              AND dr.numint = pin_numint
              AND dr.tipdoc IN ( 1, 3, 7, 8, 210 )
              AND dr.situac IN ( 'C', 'B', 'H', 'G', 'F' )
              AND nvl(mt44.valor, 'N') <> 'S';

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Success ...!'
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
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

    END sp_dw_cventas_actualiza;

    PROCEDURE sp_dw_actualiza_cventas_hijas (
        pin_id_cia  IN NUMBER,
        pin_tipact  IN NUMBER,
        pin_mensaje OUT VARCHAR2
    ) AS
    BEGIN
        DELETE dw_cventas_x_dia
        WHERE
            id_cia = pin_id_cia;

        DELETE dw_cventas_x_mes
        WHERE
            id_cia = pin_id_cia;

        DELETE dw_cventas_vendedor_cartera_x_dia
        WHERE
            id_cia = pin_id_cia;

        DELETE dw_cventas_vendedor_cartera_x_mes
        WHERE
            id_cia = pin_id_cia;

        DELETE dw_cventas_vendedor_documento_x_dia
        WHERE
            id_cia = pin_id_cia;

        DELETE dw_cventas_vendedor_documento_x_mes
        WHERE
            id_cia = pin_id_cia;

        DELETE dw_cventas_venta_costo_utilidad
        WHERE
            id_cia = pin_id_cia;

        COMMIT;
        INSERT ALL
            INTO dw_cventas_vendedor_cartera_x_dia (
                id_cia,
                codven,
                vendedor,
                abrevi,
                tipdoc,
                tipodocumento,
                codsuc,
                sucursal,
                diasemana,
                mes,
                periodo,
                idmes,
                mesid,
                femisi,
                cantid,
                toneladas,
                cstsol,
                cstdol,
                vntsol,
                vntdol,
                igvsol,
                igvdol
            )
        SELECT
            dw.id_cia,
            nvl(dw.codvencar, 999),
            nvl(v.desven, 'ND'),
            nvl(v.abrevi,
                substr(nvl(v.desven, 'ND'),
                       1,
                       5)),
            dw.tipdoc,
            dw.tipodocumento,
            dw.codsuc,
            dw.sucursal,
            dw.diasemana,
            dw.mes,
            dw.periodo,
            dw.idmes,
            dw.mesid,
            trunc(dw.femisi),
            round(SUM(nvl(dw.cantid, 0)),
                  2),
            round(SUM(nvl(0, 0)),
                  2),
            round(SUM(nvl(dw.cstsol, 0)),
                  2),
            round(SUM(nvl(dw.cstdol, 0)),
                  2),
            round(SUM(nvl(dw.vntsol, 0)),
                  2),
            round(SUM(nvl(dw.vntdol, 0)),
                  2),
            round(SUM(nvl(dw.igvsol, 0)),
                  2),
            round(SUM(nvl(dw.igvdol, 0)),
                  2)
        FROM
            dw_cventas dw
            LEFT OUTER JOIN vendedor   v ON v.id_cia = dw.id_cia
                                          AND v.codven = dw.codvencar
        WHERE
            dw.id_cia = pin_id_cia
        GROUP BY
            dw.id_cia,
            nvl(dw.codvencar, 999),
            nvl(v.desven, 'ND'),
            nvl(v.abrevi,
                substr(nvl(v.desven, 'ND'),
                       1,
                       5)),
            dw.tipdoc,
            dw.tipodocumento,
            dw.codsuc,
            dw.sucursal,
            dw.diasemana,
            dw.mes,
            dw.periodo,
            dw.idmes,
            dw.mesid,
            trunc(dw.femisi);

        INSERT ALL
            INTO dw_cventas_vendedor_cartera_x_mes (
                id_cia,
                codven,
                vendedor,
                abrevi,
                codsuc,
                sucursal,
                mes,
                periodo,
                idmes,
                mesid,
                cantid,
                toneladas,
                cstsol,
                cstdol,
                vntsol,
                vntdol,
                igvsol,
                igvdol
            )
        SELECT
            dw.id_cia,
            dw.codven,
            dw.vendedor,
            dw.abrevi,
            dw.codsuc,
            dw.sucursal,
            dw.mes,
            dw.periodo,
            dw.idmes,
            dw.mesid,
            SUM(dw.cantid),
            SUM(0),
            SUM(dw.cstsol),
            SUM(dw.cstdol),
            SUM(dw.vntsol),
            SUM(dw.vntdol),
            SUM(dw.igvsol),
            SUM(dw.igvdol)
        FROM
            dw_cventas_vendedor_cartera_x_dia dw
        WHERE
            dw.id_cia = pin_id_cia
        GROUP BY
            dw.id_cia,
            dw.codven,
            dw.vendedor,
            dw.abrevi,
            dw.codsuc,
            dw.sucursal,
            dw.mes,
            dw.periodo,
            dw.idmes,
            dw.mesid;

        INSERT ALL
            INTO dw_cventas_vendedor_documento_x_dia (
                id_cia,
                codven,
                vendedor,
                abrevi,
                tipdoc,
                tipodocumento,
                codsuc,
                sucursal,
                diasemana,
                mes,
                periodo,
                idmes,
                mesid,
                femisi,
                cantid,
                toneladas,
                cstsol,
                cstdol,
                vntsol,
                vntdol,
                igvsol,
                igvdol
            )
        SELECT
            dw.id_cia,
            nvl(dw.codvendoc, 999),
            nvl(v.desven, 'ND'),
            nvl(v.abrevi,
                substr(nvl(v.desven, 'ND'),
                       1,
                       5)),
            dw.tipdoc,
            dw.tipodocumento,
            dw.codsuc,
            dw.sucursal,
            dw.diasemana,
            dw.mes,
            dw.periodo,
            dw.idmes,
            dw.mesid,
            trunc(dw.femisi),
            round(SUM(nvl(dw.cantid, 0)),
                  2),
            round(SUM(nvl(0, 0)),
                  2),
            round(SUM(nvl(dw.cstsol, 0)),
                  2),
            round(SUM(nvl(dw.cstdol, 0)),
                  2),
            round(SUM(nvl(dw.vntsol, 0)),
                  2),
            round(SUM(nvl(dw.vntdol, 0)),
                  2),
            round(SUM(nvl(dw.igvsol, 0)),
                  2),
            round(SUM(nvl(dw.igvdol, 0)),
                  2)
        FROM
            dw_cventas dw
            LEFT OUTER JOIN vendedor   v ON v.id_cia = dw.id_cia
                                          AND v.codven = dw.codvendoc
        WHERE
            dw.id_cia = pin_id_cia
        GROUP BY
            dw.id_cia,
            nvl(dw.codvendoc, 999),
            nvl(v.desven, 'ND'),
            nvl(v.abrevi,
                substr(nvl(v.desven, 'ND'),
                       1,
                       5)),
            dw.tipdoc,
            dw.tipodocumento,
            dw.codsuc,
            dw.sucursal,
            dw.diasemana,
            dw.mes,
            dw.periodo,
            dw.idmes,
            dw.mesid,
            trunc(dw.femisi);

        INSERT ALL
            INTO dw_cventas_vendedor_documento_x_mes (
                id_cia,
                codven,
                vendedor,
                abrevi,
                codsuc,
                sucursal,
                mes,
                periodo,
                idmes,
                mesid,
                cantid,
                toneladas,
                cstsol,
                cstdol,
                vntsol,
                vntdol,
                igvsol,
                igvdol
            )
        SELECT
            dw.id_cia,
            dw.codven,
            dw.vendedor,
            dw.abrevi,
            dw.codsuc,
            dw.sucursal,
            dw.mes,
            dw.periodo,
            dw.idmes,
            dw.mesid,
            SUM(dw.cantid),
            SUM(0),
            SUM(dw.cstsol),
            SUM(dw.cstdol),
            SUM(dw.vntsol),
            SUM(dw.vntdol),
            SUM(dw.igvsol),
            SUM(dw.igvdol)
        FROM
            dw_cventas_vendedor_documento_x_dia dw
        WHERE
            dw.id_cia = pin_id_cia
        GROUP BY
            dw.id_cia,
            dw.codven,
            dw.vendedor,
            dw.abrevi,
            dw.codsuc,
            dw.sucursal,
            dw.mes,
            dw.periodo,
            dw.idmes,
            dw.mesid;

        INSERT ALL
            INTO dw_cventas_x_dia (
                id_cia,
                femisi,
                tipdoc,
                tipodocumento,
                codsuc,
                sucursal,
                diasemana,
                mes,
                periodo,
                idmes,
                mesid,
                cantid,
                toneladas,
                cstsol,
                cstdol,
                vntsol,
                vntdol,
                igvsol,
                igvdol
            )
        SELECT
            dw.id_cia,
            trunc(dw.femisi),
            dw.tipdoc,
            dw.tipodocumento,
            dw.codsuc,
            dw.sucursal,
            dw.diasemana,
            dw.mes,
            dw.periodo,
            dw.idmes,
            dw.mesid,
            round(SUM(nvl(dw.cantid, 0)),
                  2),
            round(SUM(nvl(0, 0)),
                  2),
            round(SUM(nvl(dw.cstsol, 0)),
                  2),
            round(SUM(nvl(dw.cstdol, 0)),
                  2),
            round(SUM(nvl(dw.vntsol, 0)),
                  2),
            round(SUM(nvl(dw.vntdol, 0)),
                  2),
            round(SUM(nvl(dw.igvsol, 0)),
                  2),
            round(SUM(nvl(dw.igvdol, 0)),
                  2)
        FROM
            dw_cventas dw
        WHERE
            dw.id_cia = pin_id_cia
        GROUP BY
            dw.id_cia,
            trunc(dw.femisi),
            dw.tipdoc,
            dw.tipodocumento,
            dw.codsuc,
            dw.sucursal,
            dw.diasemana,
            dw.mes,
            dw.periodo,
            dw.idmes,
            dw.mesid;

        INSERT ALL
            INTO dw_cventas_x_mes (
                id_cia,
                codsuc,
                sucursal,
                mes,
                periodo,
                idmes,
                mesid,
                cantid,
                toneladas,
                cstsol,
                cstdol,
                vntsol,
                vntdol,
                igvsol,
                igvdol
            )
        SELECT
            dw.id_cia,
            dw.codsuc,
            dw.sucursal,
            dw.mes,
            dw.periodo,
            dw.idmes,
            dw.mesid,
            round(SUM(nvl(dw.cantid, 0)),
                  2),
            round(SUM(nvl(0, 0)),
                  2),
            round(SUM(nvl(dw.cstsol, 0)),
                  2),
            round(SUM(nvl(dw.cstdol, 0)),
                  2),
            round(SUM(nvl(dw.vntsol, 0)),
                  2),
            round(SUM(nvl(dw.vntdol, 0)),
                  2),
            round(SUM(nvl(dw.igvsol, 0)),
                  2),
            round(SUM(nvl(dw.igvdol, 0)),
                  2)
        FROM
            dw_cventas dw
        WHERE
            dw.id_cia = pin_id_cia
        GROUP BY
            dw.id_cia,
            dw.codsuc,
            dw.sucursal,
            dw.mes,
            dw.periodo,
            dw.idmes,
            dw.mesid;

        INSERT ALL
            INTO dw_cventas_venta_costo_utilidad (
                id_cia,
                codsuc,
                sucursal,
                periodo,
                mes,
                idmes,
                mesid,
                femisi,
                tipinv,
                dtipinv,
                codart,
                desart,
                cantid,
                toneladas,
                cstsol,
                cstdol,
                vntsol,
                vntdol,
                igvsol,
                igvdol,
                rentabsol,
                rentabdol
            )
        SELECT
            dw.id_cia,
            dw.codsuc,
            dw.sucursal,
            dw.periodo,
            dw.mes,
            dw.idmes,
            dw.mesid,
            dw.femisi,
            dw.tipinv,
            t.dtipinv,
            dw.codart,
            a.descri AS desart,
            round(SUM(decode(nvl(mt60.valor, 'N'),
                             'S',
                             0,
                             nvl(dw.cantid, 0))),
                  2),
            round(SUM(nvl(0, 0)),
                  2),
            round(SUM(decode(nvl(mt60.valor, 'N'),
                             'S',
                             0,
                             nvl(dw.cstsol, 0))),
                  2),
            round(SUM(decode(nvl(mt60.valor, 'N'),
                             'S',
                             0,
                             nvl(dw.cstdol, 0))),
                  2),
            round(SUM(nvl(dw.vntsol, 0)),
                  2),
            round(SUM(nvl(dw.vntdol, 0)),
                  2),
            round(SUM(nvl(dw.igvsol, 0)),
                  2),
            round(SUM(nvl(dw.igvdol, 0)),
                  2),
            round(SUM(nvl(dw.vntsol, 0) - decode(nvl(mt60.valor, 'N'),
                                                 'S',
                                                 0,
                                                 nvl(dw.cstsol, 0))),
                  2),
            round(SUM(nvl(dw.vntdol, 0) - decode(nvl(mt60.valor, 'N'),
                                                 'S',
                                                 0,
                                                 nvl(dw.cstdol, 0))),
                  2)
        FROM
            dw_cventas     dw
            LEFT OUTER JOIN t_inventario   t ON t.id_cia = dw.id_cia
                                              AND t.tipinv = dw.tipinv
            LEFT OUTER JOIN articulos      a ON a.id_cia = dw.id_cia
                                           AND a.tipinv = dw.tipinv
                                           AND a.codart = dw.codart
            LEFT OUTER JOIN motivos_clase  mt44 ON mt44.id_cia = dw.id_cia
                                                  AND mt44.tipdoc = dw.tipdoc
                                                  AND mt44.codmot = dw.codmot
                                                  AND mt44.id = dw.id
                                                  AND mt44.codigo = 44 -- TRANFERENCIA GRATUITA, NO SALE EN EL REPORTE
            LEFT OUTER JOIN motivos_clase  mt60 ON mt60.id_cia = dw.id_cia
                                                  AND mt60.tipdoc = dw.tipdoc
                                                  AND mt60.codmot = dw.codmot
                                                  AND mt60.id = dw.id
                                                  AND mt60.codigo = 60 -- COSTO Y CANTIDAD EN CERO, SOLO SI ESTA EN 'S'
            LEFT OUTER JOIN motivos_clase  mt3 ON mt3.id_cia = dw.id_cia
                                                 AND mt3.tipdoc = dw.tipdoc
                                                 AND mt3.codmot = dw.codmot
                                                 AND mt3.id = dw.id
                                                 AND mt3.codigo = 3 -- IMPRIME EN REPORTE?, SOLO SI ES 'S'
        WHERE
                dw.id_cia = pin_id_cia
            AND nvl(mt44.valor, 'N') = 'N'
            AND nvl(mt3.valor, 'N') = 'S'
        GROUP BY
            dw.id_cia,
            dw.codsuc,
            dw.sucursal,
            dw.periodo,
            dw.mes,
            dw.idmes,
            dw.mesid,
            dw.femisi,
            dw.tipinv,
            t.dtipinv,
            dw.codart,
            a.descri;

        COMMIT;
        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Success...!'
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
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

    END sp_dw_actualiza_cventas_hijas;

    PROCEDURE sp_dw_actualiza_costo_cventas (
        pin_id_cia  IN NUMBER,
        pin_fdesde  IN DATE,
        pin_fhasta  IN DATE,
        pin_mensaje OUT VARCHAR
    ) AS

        CURSOR cursor_costo IS
        SELECT
            k.numint,
            k.numite,
            k.costot01,
            k.costot02,
            k.cantid
        FROM
            kardex_costoventa k
        WHERE
                k.id_cia = pin_id_cia
            AND k.femisi BETWEEN pin_fdesde AND pin_fhasta;

    BEGIN
        FOR i IN cursor_costo LOOP
            UPDATE dw_cventas
            SET
                cstsol = i.costot01 * signo,
                cstdol = i.costot02 * signo
            WHERE
                    id_cia = pin_id_cia
                AND numintfac = i.numint
                AND numitefac = i.numite;

        END LOOP;

        COMMIT;
        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Success...!'
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
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

    END sp_dw_actualiza_costo_cventas;

    PROCEDURE sp_dw_actualiza_cventas_hijas_costo (
        pin_id_cia  IN NUMBER,
        pin_periodo IN NUMBER,
        pin_mes     IN NUMBER,
        pin_mensaje OUT VARCHAR
    ) AS

        pin_fdesde   DATE;
        pin_fhasta   DATE;
        v_mensaje    VARCHAR2(1000) := '';
        pout_mensaje VARCHAR2(1000) := '';
        o            json_object_t;
    BEGIN
        pin_fhasta := last_day(trunc(TO_DATE(to_char('01'
                                                     || '/'
                                                     || pin_mes
                                                     || '/'
                                                     || pin_periodo), 'DD/MM/YYYY')));

        pin_fdesde := TO_DATE ( to_char('01'
                                        || '/'
                                        || pin_mes
                                        || '/'
                                        || pin_periodo), 'DD/MM/YYYY' );

    -- PASO 1 PROCESAMOS EL KARDEX_COSTO_VENTA
        sp_actualiza_kardex_costoventa(pin_id_cia, pin_fdesde, pin_fhasta, v_mensaje);
        o := json_object_t.parse(v_mensaje);
        IF ( o.get_number('status') <> 1.0 ) THEN
            pout_mensaje := o.get_string('message');
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;
    -- PASO 2 ACTUALIZA EL COSTO EN EL CUBO 
        pack_dw.sp_dw_actualiza_costo_cventas(pin_id_cia, pin_fdesde, pin_fhasta, v_mensaje);
        o := json_object_t.parse(v_mensaje);
        IF ( o.get_number('status') <> 1.0 ) THEN
            pout_mensaje := o.get_string('message');
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;
    -- PASO 3 PROCESA LA TABLA HIJA DEL COSTO
        DELETE dw_cventas_venta_costo_utilidad
        WHERE
                id_cia = pin_id_cia
            AND femisi BETWEEN pin_fdesde AND pin_fhasta;

        INSERT ALL
            INTO dw_cventas_venta_costo_utilidad (
                id_cia,
                codsuc,
                sucursal,
                periodo,
                mes,
                idmes,
                mesid,
                femisi,
                tipinv,
                dtipinv,
                codart,
                desart,
                cantid,
                toneladas,
                cstsol,
                cstdol,
                vntsol,
                vntdol,
                igvsol,
                igvdol,
                rentabsol,
                rentabdol
            )
        SELECT
            dw.id_cia,
            dw.codsuc,
            dw.sucursal,
            dw.periodo,
            dw.mes,
            dw.idmes,
            dw.mesid,
            dw.femisi,
            dw.tipinv,
            t.dtipinv,
            dw.codart,
            a.descri AS desart,
            round(SUM(decode(nvl(mt60.valor, 'N'),
                             'S',
                             0,
                             nvl(dw.cantid, 0))),
                  2),
            round(SUM(nvl(0, 0)),
                  2),
            round(SUM(decode(nvl(mt60.valor, 'N'),
                             'S',
                             0,
                             nvl(dw.cstsol, 0))),
                  2),
            round(SUM(decode(nvl(mt60.valor, 'N'),
                             'S',
                             0,
                             nvl(dw.cstdol, 0))),
                  2),
            round(SUM(nvl(dw.vntsol, 0)),
                  2),
            round(SUM(nvl(dw.vntdol, 0)),
                  2),
            round(SUM(nvl(dw.igvsol, 0)),
                  2),
            round(SUM(nvl(dw.igvdol, 0)),
                  2),
            round(SUM(nvl(dw.vntsol, 0) - decode(nvl(mt60.valor, 'N'),
                                                 'S',
                                                 0,
                                                 nvl(dw.cstsol, 0))),
                  2),
            round(SUM(nvl(dw.vntdol, 0) - decode(nvl(mt60.valor, 'N'),
                                                 'S',
                                                 0,
                                                 nvl(dw.cstdol, 0))),
                  2)
        FROM
            dw_cventas     dw
            LEFT OUTER JOIN t_inventario   t ON t.id_cia = dw.id_cia
                                              AND t.tipinv = dw.tipinv
            LEFT OUTER JOIN articulos      a ON a.id_cia = dw.id_cia
                                           AND a.tipinv = dw.tipinv
                                           AND a.codart = dw.codart
            LEFT OUTER JOIN documentos_cab dc ON dc.id_cia = dw.id_cia
                                                 AND dc.numint = dw.numintfac
            LEFT OUTER JOIN motivos_clase  mt44 ON mt44.id_cia = dc.id_cia
                                                  AND mt44.tipdoc = dc.tipdoc
                                                  AND mt44.codmot = dc.codmot
                                                  AND mt44.id = dc.id
                                                  AND mt44.codigo = 44 -- TRANFERENCIA GRATUITA, NO SALE EN EL REPORTE
            LEFT OUTER JOIN motivos_clase  mt60 ON mt60.id_cia = dc.id_cia
                                                  AND mt60.tipdoc = dc.tipdoc
                                                  AND mt60.codmot = dc.codmot
                                                  AND mt60.id = dc.id
                                                  AND mt60.codigo = 60 -- COSTO Y CANTIDAD EN CERO, SOLO SI ESTA EN 'S'
            LEFT OUTER JOIN motivos_clase  mt3 ON mt3.id_cia = dc.id_cia
                                                 AND mt3.tipdoc = dc.tipdoc
                                                 AND mt3.codmot = dc.codmot
                                                 AND mt3.id = dc.id
                                                 AND mt3.codigo = 3 -- IMPRIME EN REPORTE?, SOLO SI ES 'S'
        WHERE
                dw.id_cia = pin_id_cia
            AND dw.femisi BETWEEN pin_fdesde AND pin_fhasta
            AND nvl(mt44.valor, 'N') = 'N'
            AND nvl(mt3.valor, 'N') = 'S'
        GROUP BY
            dw.id_cia,
            dw.codsuc,
            dw.sucursal,
            dw.periodo,
            dw.mes,
            dw.idmes,
            dw.mesid,
            dw.femisi,
            dw.tipinv,
            t.dtipinv,
            dw.codart,
            a.descri;

        COMMIT;
        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Actualización de los Costos del DashBoard finalizada con Exito ...!'
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

            ROLLBACK;
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
    END sp_dw_actualiza_cventas_hijas_costo;

END;

/

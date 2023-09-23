--------------------------------------------------------
--  DDL for Package Body PACK_REPORTES_TSI_DOCUMENTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_REPORTES_TSI_DOCUMENTO" AS

    FUNCTION sp_buscar_documento_cxc (
        pin_id_cia    NUMBER,
        pin_codsuc    NUMBER,
        pin_codcli    VARCHAR2,
        pin_codven    NUMBER,
        pin_tipdocs   VARCHAR2,
        pin_codubis   VARCHAR2,
        pin_fhasta    DATE,
        pin_numint    NUMBER,
        pin_incletdes VARCHAR2
    ) RETURN datatable_buscar_documento_cxc
        PIPELINED
    AS
        v_table datatable_buscar_documento_cxc;
    BEGIN
        SELECT
            d.id_cia,
            d.codcli,
            'O',
            d.tipdoc,
            td.descri AS desdoc,
            td.abrevi AS abrdoc,
            d.docume,
            d.numint,
            d.operac,
            d.femisi,
            d.fvenci,
            d.dh,
            d.tipmon,  /* PARA IGUALAR CON LOS PENDIENTES SIN FECHA ESTADO DE CUENTA */
            CASE
                WHEN d.dh = 'D' THEN
                    CAST(
                        CASE
                            WHEN nvl(o.saldo, 0) > 0 THEN
                                o.saldo
                            ELSE
                                d.importe
                        END
                    AS DOUBLE PRECISION) * CAST(td.signo AS DOUBLE PRECISION)
                ELSE
                    0
            END,
            CASE
                WHEN d.dh = 'H' THEN
                    CAST(
                        CASE
                            WHEN nvl(o.saldo, 0) > 0 THEN
                                o.saldo
                            ELSE
                                d.importe
                        END
                    AS DOUBLE PRECISION) * CAST(td.signo AS DOUBLE PRECISION)
                ELSE
                    0
            END,
            CASE
                WHEN d.dh = 'D' THEN
                    CAST(
                        CASE
                            WHEN d.tipmon = 'PEN'
                                 AND nvl(o.saldo, 0) > 0 THEN
                                o.saldo
                            ELSE
                                d.importemn
                        END
                    AS DOUBLE PRECISION) * CAST(td.signo AS DOUBLE PRECISION)
                ELSE
                    0
            END,
            CASE
                WHEN d.dh = 'H' THEN
                    CAST(
                        CASE
                            WHEN d.tipmon = 'PEN'
                                 AND nvl(o.saldo, 0) > 0 THEN
                                o.saldo
                            ELSE
                                d.importemn
                        END
                    AS DOUBLE PRECISION) * CAST(td.signo AS DOUBLE PRECISION)
                ELSE
                    0
            END,
            CASE
                WHEN d.dh = 'D' THEN
                    CAST(
                        CASE
                            WHEN d.tipmon <> 'PEN'
                                 AND nvl(o.saldo, 0) > 0 THEN
                                o.saldo
                            ELSE
                                d.importeme
                        END
                    AS DOUBLE PRECISION) * CAST(td.signo AS DOUBLE PRECISION)
                ELSE
                    0
            END,
            CASE
                WHEN d.dh = 'H' THEN
                    CAST(
                        CASE
                            WHEN d.tipmon <> 'PEN'
                                 AND nvl(o.saldo, 0) > 0 THEN
                                o.saldo
                            ELSE
                                d.importeme
                        END
                    AS DOUBLE PRECISION) * CAST(td.signo AS DOUBLE PRECISION)
                ELSE
                    0
            END,
            o.saldo
        BULK COLLECT
        INTO v_table
        FROM
            dcta100      d
            LEFT OUTER JOIN dcta100_ori  o ON o.id_cia = d.id_cia
                                             AND o.numint = d.numint
            LEFT OUTER JOIN dcta105      d5 ON d5.id_cia = d.id_cia
                                          AND d5.numint = d.numint
            LEFT OUTER JOIN dcta102      d2 ON d2.id_cia = d.id_cia
                                          AND d2.libro = d5.libro
                                          AND d2.periodo = d5.periodo
                                          AND d2.mes = d5.mes
                                          AND d2.secuencia = d5.secuencia
            LEFT OUTER JOIN tdoccobranza td ON td.id_cia = d.id_cia
                                               AND td.tipdoc = d.tipdoc
        WHERE
                d.id_cia = pin_id_cia
            AND nvl(d.femisi, d.fcreac) <= pin_fhasta
            AND ( pin_codsuc IS NULL
                  OR pin_codsuc < 0
                  OR nvl(d.codsuc, 1) = pin_codsuc )
            AND ( pin_tipdocs IS NULL
                  OR d.tipdoc IN (
                SELECT
                    *
                FROM
                    TABLE ( convert_in(pin_tipdocs) )
            ) )
            AND ( pin_codubis IS NULL
                  OR d.codubi IN (
                SELECT
                    *
                FROM
                    TABLE ( convert_in(pin_codubis) )
            ) )
            AND ( pin_incletdes = 'S'
                  OR abs(
                CASE
                    WHEN d.operac IS NULL THEN
                        d.operac
                END
            ) <> 2 )
            AND ( pin_codcli IS NULL
                  OR d.codcli = pin_codcli )
            AND ( pin_codven IS NULL
                  OR pin_codven < 0
                  OR d.codven = pin_codven )
            AND ( pin_numint IS NULL
                  OR pin_numint = - 1
                  OR d.numint = pin_numint )
            /* EN CASO EL DOCUMENTO SE HAYA GENERADO DESDE EL DCTA105, LA FECHA DE LA PLANILLA DETERMINARA SI ENTRA AL REPORTE */
            AND NOT ( d5.numint IS NOT NULL
                      AND d2.femisi IS NOT NULL
                      AND d2.femisi > pin_fhasta );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        SELECT
            o.id_cia,
            o.codcli,
            'P',
            o.tipdoc,
            td.descri AS desdoc,
            td.abrevi AS abrdoc,
            o.docume,
            d.numint,
            d.operac,
            d.femisi,
            CAST(NULL AS DATE),
            d.dh,
            d.tipmon,    /* PARA IGUALAR CON LOS PENDIENTES SIN FECHA ESTADO DE CUENTA */
            CASE
                WHEN d.dh = 'D' THEN
                    d.importe * CAST(td.signo AS DOUBLE PRECISION)
                ELSE
                    0
            END,
            CASE
                WHEN d.dh = 'H' THEN
                    d.importe * CAST(td.signo AS DOUBLE PRECISION)
                ELSE
                    0
            END,
            CASE
                WHEN d.dh = 'D' THEN
                    d.impor01 * CAST(td.signo AS DOUBLE PRECISION)
                ELSE
                    0
            END,
            CASE
                WHEN d.dh = 'H' THEN
                    d.impor01 * CAST(td.signo AS DOUBLE PRECISION)
                ELSE
                    0
            END,
            CASE
                WHEN d.dh = 'D' THEN
                    d.impor02 * CAST(td.signo AS DOUBLE PRECISION)
                ELSE
                    0
            END,
            CASE
                WHEN d.dh = 'H' THEN
                    d.impor02 * CAST(td.signo AS DOUBLE PRECISION)
                ELSE
                    0
            END,
            0         AS orisaldo
        BULK COLLECT
        INTO v_table
        FROM
            dcta101      d
            LEFT OUTER JOIN dcta100      o ON o.id_cia = d.id_cia
                                         AND o.numint = d.numint
            LEFT OUTER JOIN tdoccobranza td ON td.id_cia = d.id_cia
                                               AND td.tipdoc = o.tipdoc
        WHERE
                d.id_cia = pin_id_cia
            AND nvl(d.femisi, d.fcreac) <= pin_fhasta
            /* ESTOS SON POR OTROS MOTIVOS QUE NO DESCUENTAN SALDO IGUAL QUE SP_ACTUALIZA_SALDO_DCTA100 */
            AND d.tipcan <= 50
            AND ( pin_codsuc IS NULL
                  OR pin_codsuc < 0
                  OR nvl(o.codsuc, 1) = pin_codsuc )
            AND ( pin_tipdocs IS NULL
                  OR o.tipdoc IN (
                SELECT
                    *
                FROM
                    TABLE ( convert_in(pin_tipdocs) )
            ) )
            AND ( pin_codubis IS NULL
                  OR o.codubi IN (
                SELECT
                    *
                FROM
                    TABLE ( convert_in(pin_codubis) )
            ) )
            AND ( pin_incletdes = 'S'
                  OR abs(
                CASE
                    WHEN o.operac IS NULL THEN
                        o.operac
                END
            ) <> 2 )
            AND ( pin_codcli IS NULL
                  OR o.codcli = pin_codcli )
            AND ( pin_codven IS NULL
                  OR pin_codven < 0
                  OR o.codven = pin_codven )
            AND ( pin_numint IS NULL
                  OR pin_numint = - 1
                  OR d.numint = pin_numint );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar_documento_cxc;

    FUNCTION sp_buscar_saldo_cxc (
        pin_id_cia    NUMBER,
        pin_codsuc    NUMBER,
        pin_codcli    VARCHAR2,
        pin_codven    NUMBER,
        pin_tipdocs   VARCHAR2,
        pin_codubis   VARCHAR2,
        pin_fhasta    DATE,
        pin_numint    NUMBER,
        pin_incletdes VARCHAR2,
        pin_incfacant VARCHAR2
    ) RETURN datatable_buscar_saldo_cxc
        PIPELINED
    AS

        v_table      datatable_buscar_saldo_cxc;
        v_rec        datarecord_buscar_saldo_cxc;
        v_aux        datarecord_buscar_documento_cxc;
        v_numintant  NUMBER := -666;
        v_dh_ori     VARCHAR2(100) := '';
        v_tipmon_ori VARCHAR2(100) := '';
    BEGIN
        FOR i IN (
            SELECT
                *
            FROM
                pack_reportes_tsi_documento.sp_buscar_documento_cxc(pin_id_cia, pin_codsuc, pin_codcli, pin_codven, pin_tipdocs,
                                                                    pin_codubis, pin_fhasta, pin_numint, pin_incletdes)
            ORDER BY
                codcli,
                numint,
                swflag,
                femisi
        ) LOOP
            IF v_numintant <> i.numint THEN
                IF v_numintant <> -666 THEN
                    PIPE ROW ( v_rec );
                END IF;
                v_rec.id_cia := i.id_cia;
                v_numintant := i.numint;
                v_rec.codcli := i.codcli;
                v_rec.tipdoc := i.tipdoc;
                v_rec.desdoc := i.desdoc;
                v_rec.abrdoc := i.abrdoc;
                v_rec.docume := i.docume;
                v_rec.numint := i.numint;
                v_rec.femisi := i.femisi;
                v_rec.fvenci := i.fvenci;
                v_rec.dh := i.dh;
                v_rec.tipmon := i.tipmon;
                v_rec.saldo := 0;
            END IF;

            IF i.swflag = 'O' THEN
--                dbms_output.put_line('O');
                v_dh_ori := v_rec.dh;
                v_tipmon_ori := v_rec.tipmon;
                IF i.tipmon = 'PEN' THEN
                    v_rec.saldo := i.importedebe01 + i.importehaber01;
                ELSE
                    v_rec.saldo := i.importedebe02 + i.importehaber02;
                END IF;
--                v_rec.saldo := i.importedebe + i.importehaber;
                IF ( i.orisaldo = -1 ) THEN
                    v_rec.saldo := 0;
                END IF;

            ELSIF i.swflag = 'P' THEN
--                dbms_output.put_line('P');
                IF ( v_tipmon_ori = i.tipmon ) THEN
                    IF i.tipmon = 'PEN' THEN
                        v_aux.importedebe := i.importedebe01;
                        v_aux.importehaber := i.importehaber01;
                    ELSE
                        v_aux.importedebe := i.importedebe02;
                        v_aux.importehaber := i.importehaber02;
                    END IF;
--                    v_aux.importedebe := i.importedebe;
--                    v_aux.importehaber := i.importehaber;
                ELSE
                    IF ( v_tipmon_ori = 'PEN' ) THEN
                        v_aux.importedebe := i.importedebe01;
                        v_aux.importehaber := i.importehaber01;
                    ELSE
                        v_aux.importedebe := i.importedebe02;
                        v_aux.importehaber := i.importehaber02;
                    END IF;
                END IF;

                IF ( v_dh_ori = 'D' ) THEN
                    v_rec.saldo := v_rec.saldo + ( v_aux.importedebe - v_aux.importehaber );

                ELSIF ( v_dh_ori = 'H' ) THEN
                    v_rec.saldo := v_rec.saldo + ( v_aux.importehaber - v_aux.importedebe );
                END IF;

--                dbms_output.put_line(v_rec.saldo);
            END IF;

        END LOOP;
        -- IMPRIMIENDO EL ULTIMO REGISTRO
        PIPE ROW ( v_rec );
        IF ( pin_incfacant = 'S' ) THEN
            FOR e IN (
                SELECT
                    d6.id_cia,
                    d6.codcli,
                    d6.tipdoc,
                    d.descri
                    || ' - '
                    || 'ANTICIPO'   AS desdoc,
                    d.abrevi        AS abrdoc,
                    d6.docume,
                    d6.numint,
                    d6.femisi,
                    d6.fvenci,
                    'D'             AS dh,
                    d6.tipmon,
                    d16.saldo * - 1 AS saldo
                FROM
                    sp000_saca_saldo_a_fecha_dcta106(pin_numint, 0, pin_fhasta) d16
                    LEFT OUTER JOIN dcta100                                                     d6 ON d6.id_cia = pin_id_cia
                                                  AND d6.numint = d16.numint
                    LEFT OUTER JOIN tdoccobranza                                                d ON d.id_cia = pin_id_cia
                                                      AND d.tipdoc = d6.tipdoc
                WHERE
                        d16.saldo <> 0
                    AND ( pin_tipdocs IS NULL
                          OR d6.tipdoc IN (
                        SELECT
                            *
                        FROM
                            TABLE ( convert_in(pin_tipdocs) )
                    ) )
                    AND ( pin_codubis IS NULL
                          OR d6.codubi IN (
                        SELECT
                            *
                        FROM
                            TABLE ( convert_in(pin_codubis) )
                    ) )
                    AND ( pin_codcli IS NULL
                          OR d6.codcli = pin_codcli )
                    AND ( pin_codven IS NULL
                          OR pin_codven < 0
                          OR d6.codven = pin_codven )
            ) LOOP
                v_rec.id_cia := e.id_cia;
                v_rec.codcli := e.codcli;
                v_rec.tipdoc := e.tipdoc;
                v_rec.docume := e.docume;
                v_rec.desdoc := e.desdoc;
                v_rec.abrdoc := e.abrdoc;
                v_rec.numint := e.numint;
                v_rec.femisi := e.femisi;
                v_rec.fvenci := e.fvenci;
                v_rec.dh := e.dh;
                v_rec.tipmon := e.tipmon;
                v_rec.saldo := e.saldo;
                PIPE ROW ( v_rec );
            END LOOP;
        END IF;

    END sp_buscar_saldo_cxc;

    FUNCTION sp_buscar_cxc (
        pin_id_cia NUMBER,
        pin_fhasta DATE
    ) RETURN datatable_buscar_cxc
        PIPELINED
    AS
        v_table datatable_buscar_cxc;
    BEGIN
        SELECT
--            p.id_cia,
            EXTRACT(YEAR FROM p.fvenci)                              AS periodo,
            EXTRACT(MONTH FROM p.fvenci)                             AS mes,
            p.tipdoc,
            p.abrdoc                                                 AS abrtipdoc,
            p.desdoc                                                 AS destipdoc,
            p.docume,
            d.serie,
            d.numero,
            d.refere01,
            to_char(p.femisi, 'DD/MM/YYYY'),
            to_char(p.fvenci, 'DD/MM/YYYY'),
            CAST(trunc(pin_fhasta) - trunc(d.fvenci) AS INTEGER) - 1 AS diasmora,
            to_char(d.fcance, 'DD/MM/YYYY'),
            d.numbco,
            p.tipmon,
            d.tipcam,
            d.importe * td.signo                                     AS importe,
            d.codsuc,
            p.saldo                                                  AS saldox,
            d.codban,
            b.descri                                                 AS desban,
            p.codcli,
            c.razonc,
            c.limcre1,
            c.limcre2,
            c.chedev,
            c.letpro,
            c.renova,
            c.refina,
            to_char(c.fecing, 'DD/MM/YYYY'),
            d.codven,
            CASE
                WHEN d.codven IS NOT NULL THEN
                    v.desven
                ELSE
                    'No Asignado'
            END                                                      AS desven,
            d.protes,
            d.operac,
            (
                CASE
                    WHEN codpag = 1 THEN
                        'Abierto'
                    ELSE
                        'Cerrado'
                END
            )                                                        AS credito,
--            v.desven                                                    AS "Vendedor Cartera",
            d.cuenta,
            m.nombre                                                 AS descuenta
        BULK COLLECT
        INTO v_table
        FROM
            pack_reportes_tsi_documento.sp_buscar_saldo_cxc(pin_id_cia, - 1, NULL, - 1, '1,3,4,5,6,7,8,9,12,41,43,44,102,210',
                                                            '-1,1', pin_fhasta, - 1, 'S', 'N') p
            LEFT OUTER JOIN dcta100                                                                            d ON d.id_cia = p.id_cia
                                         AND d.numint = p.numint
            LEFT OUTER JOIN tdoccobranza                                                                       td ON td.id_cia = d.id_cia
                                               AND td.tipdoc = d.tipdoc
            LEFT OUTER JOIN cliente                                                                            c ON c.id_cia = d.id_cia
                                         AND c.codcli = d.codcli
            LEFT OUTER JOIN vendedor                                                                           v ON v.id_cia = d.id_cia
                                          AND v.codven = d.codven
            LEFT OUTER JOIN tbancos                                                                            b ON b.id_cia = d.id_cia
                                         AND b.codban = CAST(d.codban AS VARCHAR(3))
            LEFT OUTER JOIN pcuentas                                                                           m ON m.id_cia = d.id_cia
                                          AND m.cuenta = d.cuenta
        WHERE
                d.id_cia = pin_id_cia
            AND p.saldo <> 0
        ORDER BY
            d.cuenta,
            d.codcli,
            d.codsuc,
            d.tipdoc,
            d.femisi,
            d.docume;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar_cxc;

    FUNCTION sp_buscar_documento_cxp (
        pin_id_cia  NUMBER,
        pin_codcli  VARCHAR2,
        pin_tipdocs VARCHAR2,
        pin_fhasta  DATE,
        pin_tipo    NUMBER,
        pin_docu    NUMBER
    ) RETURN datatable_buscar_documento_cxp
        PIPELINED
    AS
        v_table datatable_buscar_documento_cxp;
    BEGIN
        SELECT
            d.id_cia,
            d.codcli,
            'O',
            d.tipdoc,
            td.descri AS desdoc,
            td.abrevi AS abrdoc,
            d.docume,
            d.tipo,
            d.docu,
            d.operac,
            d.femisi,
            d.fvenci,
            d.dh,
            d.tipmon,  /* PARA IGUALAR CON LOS PENDIENTES SIN FECHA ESTADO DE CUENTA */
            CASE
                WHEN d.dh = 'D' THEN
                    d.importe * CAST(td.signo AS DOUBLE PRECISION)
                ELSE
                    0
            END,
            CASE
                WHEN d.dh = 'H' THEN
                    d.importe * CAST(td.signo AS DOUBLE PRECISION)
                ELSE
                    0
            END,
            CASE
                WHEN d.dh = 'D' THEN
                    d.importemn * CAST(td.signo AS DOUBLE PRECISION)
                ELSE
                    0
            END,
            CASE
                WHEN d.dh = 'H' THEN
                    d.importemn * CAST(td.signo AS DOUBLE PRECISION)
                ELSE
                    0
            END,
            CASE
                WHEN d.dh = 'D' THEN
                    d.importeme * CAST(td.signo AS DOUBLE PRECISION)
                ELSE
                    0
            END,
            CASE
                WHEN d.dh = 'H' THEN
                    d.importeme * CAST(td.signo AS DOUBLE PRECISION)
                ELSE
                    0
            END
        BULK COLLECT
        INTO v_table
        FROM
            prov100 d
            LEFT OUTER JOIN tdocume td ON td.id_cia = d.id_cia
                                          AND td.codigo = d.tipdoc
        WHERE
                d.id_cia = pin_id_cia
            AND nvl(d.fvenci, d.fcreac) <= pin_fhasta
            AND ( pin_tipo IS NULL
                  OR pin_tipo < 0
                  OR nvl(d.tipo, 0) = pin_tipo )
            AND ( pin_docu IS NULL
                  OR pin_docu < 0
                  OR nvl(d.docu, 0) = pin_docu )
            AND ( pin_codcli IS NULL
                  OR d.codcli = pin_codcli )
            AND ( pin_tipdocs IS NULL
                  OR d.tipdoc IN (
                SELECT
                    *
                FROM
                    TABLE ( convert_in(pin_tipdocs) )
            ) );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        SELECT
            o.id_cia,
            o.codcli,
            'P',
            o.tipdoc,
            td.descri AS desdoc,
            td.abrevi AS abrdoc,
            o.docume,
            d.tipo,
            d.docu,
            o.operac,
            d.femisi,
            CAST(NULL AS DATE),
            d.dh,
            d.tipmon,    /* PARA IGUALAR CON LOS PENDIENTES SIN FECHA ESTADO DE CUENTA */
            CASE
                WHEN d.dh = 'D' THEN
                    d.importe * CAST(td.signo AS DOUBLE PRECISION)
                ELSE
                    0
            END,
            CASE
                WHEN d.dh = 'H' THEN
                    d.importe * CAST(td.signo AS DOUBLE PRECISION)
                ELSE
                    0
            END,
            CASE
                WHEN d.dh = 'D' THEN
                    d.impor01 * CAST(td.signo AS DOUBLE PRECISION)
                ELSE
                    0
            END,
            CASE
                WHEN d.dh = 'H' THEN
                    d.impor01 * CAST(td.signo AS DOUBLE PRECISION)
                ELSE
                    0
            END,
            CASE
                WHEN d.dh = 'D' THEN
                    d.impor02 * CAST(td.signo AS DOUBLE PRECISION)
                ELSE
                    0
            END,
            CASE
                WHEN d.dh = 'H' THEN
                    d.impor02 * CAST(td.signo AS DOUBLE PRECISION)
                ELSE
                    0
            END
        BULK COLLECT
        INTO v_table
        FROM
            prov101 d
            LEFT OUTER JOIN prov100 o ON o.id_cia = d.id_cia
                                         AND o.tipo = d.tipo
                                         AND o.docu = d.docu
            LEFT OUTER JOIN tdocume td ON td.id_cia = d.id_cia
                                          AND td.codigo = o.tipdoc
        WHERE
                d.id_cia = pin_id_cia
            AND nvl(o.fvenci, d.fcreac) <= pin_fhasta
            AND ( pin_tipo IS NULL
                  OR pin_tipo < 0
                  OR nvl(d.tipo, 0) = pin_tipo )
            AND ( pin_docu IS NULL
                  OR pin_docu < 0
                  OR nvl(d.docu, 0) = pin_docu )
            AND ( pin_codcli IS NULL
                  OR o.codcli = pin_codcli )
            AND ( pin_tipdocs IS NULL
                  OR o.tipdoc IN (
                SELECT
                    *
                FROM
                    TABLE ( convert_in(pin_tipdocs) )
            ) );
        /* NO SE USA (D.TIPCAN<=50) AND /* ESTOS SON POR OTROS MOTIVOS QUE NO DESCUENTAN SALDO IGUAL QUE SP_ACTUALIZA_SALDO_PROV100 */

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar_documento_cxp;

    FUNCTION sp_buscar_saldo_cxp (
        pin_id_cia  NUMBER,
        pin_codcli  VARCHAR2,
        pin_tipdocs VARCHAR2,
        pin_fhasta  DATE,
        pin_tipo    NUMBER,
        pin_docu    NUMBER
    ) RETURN datatable_buscar_saldo_cxp
        PIPELINED
    AS

        v_rec        datarecord_buscar_saldo_cxp;
        v_table      datatable_buscar_saldo_cxp;
        v_aux        datarecord_buscar_documento_cxp;
        v_tipoant    NUMBER := -666;
        v_docuant    NUMBER := -666;
        v_dh_ori     VARCHAR2(10) := '';
        v_tipmon_ori VARCHAR2(10) := '';
    BEGIN
        FOR i IN (
            SELECT
                *
            FROM
                pack_reportes_tsi_documento.sp_buscar_documento_cxp(pin_id_cia, pin_codcli, pin_tipdocs, pin_fhasta, pin_tipo,
                                                                    pin_docu)
            ORDER BY
                codcli,
                tipo,
                docu,
                swflag,
                femisi
        ) LOOP
            IF v_tipoant <> i.tipo OR v_docuant <> i.docu THEN
                IF v_tipoant <> -666 OR v_docuant <> -666 THEN
                    PIPE ROW ( v_rec );
                END IF;

                v_rec.id_cia := i.id_cia;
                v_tipoant := i.tipo;
                v_docuant := i.docu;
                v_rec.codcli := i.codcli;
                v_rec.tipdoc := i.tipdoc;
                v_rec.desdoc := i.desdoc;
                v_rec.abrdoc := i.abrdoc;
                v_rec.docume := i.docume;
                v_rec.tipo := i.tipo;
                v_rec.docu := i.docu;
                v_rec.femisi := i.femisi;
                v_rec.fvenci := i.fvenci;
                v_rec.dh := i.dh;
                v_rec.tipmon := i.tipmon;
                v_rec.saldo := 0;
            END IF;

            IF i.swflag = 'O' THEN
--                dbms_output.put_line('O');
                v_dh_ori := v_rec.dh;
                v_tipmon_ori := v_rec.tipmon;
                IF i.tipmon = 'PEN' THEN
                    v_rec.saldo := i.importedebe01 + i.importehaber01;
                ELSE
                    v_rec.saldo := i.importedebe02 + i.importehaber02;
                END IF;
--                v_rec.saldo := i.importedebe + i.importehaber;
            ELSIF i.swflag = 'P' THEN
--                dbms_output.put_line('P');
                IF ( v_tipmon_ori = i.tipmon ) THEN
                    IF i.tipmon = 'PEN' THEN
                        v_aux.importedebe := i.importedebe01;
                        v_aux.importehaber := i.importehaber01;
                    ELSE
                        v_aux.importedebe := i.importedebe02;
                        v_aux.importehaber := i.importehaber02;
                    END IF;
--                    v_aux.importedebe := i.importedebe;
--                    v_aux.importehaber := i.importehaber;
                ELSE
                    IF ( v_tipmon_ori = 'PEN' ) THEN
                        v_aux.importedebe := i.importedebe01;
                        v_aux.importehaber := i.importehaber01;
                    ELSE
                        v_aux.importedebe := i.importedebe02;
                        v_aux.importehaber := i.importehaber02;
                    END IF;
                END IF;

                IF ( v_dh_ori = 'D' ) THEN
                    v_rec.saldo := v_rec.saldo + ( v_aux.importedebe - v_aux.importehaber );

                ELSIF ( v_dh_ori = 'H' ) THEN
                    v_rec.saldo := v_rec.saldo + ( v_aux.importehaber - v_aux.importedebe );
                END IF;

--                dbms_output.put_line(v_rec.saldo);
            END IF;

        END LOOP;
        -- IMPRIMIENDO EL ULTIMO REGISTRO
        PIPE ROW ( v_rec );
    END sp_buscar_saldo_cxp;

    FUNCTION sp_buscar_cxp (
        pin_id_cia NUMBER,
        pin_fhasta DATE
    ) RETURN datatable_buscar_cxp
        PIPELINED
    AS
        v_table datatable_buscar_cxp;
    BEGIN
        SELECT
            EXTRACT(YEAR FROM p.fvenci)                              AS periodo,
            EXTRACT(MONTH FROM p.fvenci)                             AS mes,
            p.tipdoc,
            p.abrdoc                                                 AS dtido,
            p.desdoc                                                 AS destipdoc,
            p.docume,
            p.tipo,
            p.docu,
            d.refere01,
            to_char(d.femisi, 'DD/MM/YYYY'),
            to_char(d.fvenci, 'DD/MM/YYYY'),
            CAST(trunc(pin_fhasta) - trunc(d.fvenci) AS INTEGER) - 1 AS diasmora,
            to_char(d.fcance, 'DD/MM/YYYY'),
            d.numbco,
            d.tipmon,
            ( d.importe * td.signo ),
            d.codsuc,
            p.saldo                                                  AS saldox,
            d.codban,
            b.descri                                                 AS desban,
            p.codcli,
            c.razonc,
            c.limcre1,
            c.limcre2,
            c.chedev,
            c.letpro,
            c.renova,
            c.refina,
            to_char(c.fecing, 'DD/MM/YYYY'),
            d.operac,
            (
                CASE
                    WHEN codpag = 1 THEN
                        'Abierto'
                    ELSE
                        'Cerrado'
                END
            )                                                        AS credito,
            d.cuenta,
            m.nombre                                                 AS descuenta
        BULK COLLECT
        INTO v_table
        FROM
            pack_reportes_tsi_documento.sp_buscar_saldo_cxp(pin_id_cia, NULL, NULL, pin_fhasta, NULL,
                                                            NULL) p
            LEFT OUTER JOIN prov100                                               d ON d.id_cia = p.id_cia
                                         AND d.tipo = p.tipo
                                         AND d.docu = p.docu
            LEFT OUTER JOIN tdocume                                               td ON td.id_cia = d.id_cia
                                          AND td.codigo = d.tipdoc
            LEFT OUTER JOIN cliente                                               c ON c.id_cia = p.id_cia
                                         AND c.codcli = d.codcli
            LEFT OUTER JOIN tbancos                                               b ON b.id_cia = p.id_cia
                                         AND b.codban = CAST(d.codban AS VARCHAR(3))
            LEFT OUTER JOIN pcuentas                                              m ON m.id_cia = p.id_cia
                                          AND m.cuenta = d.cuenta
        WHERE
                p.id_cia = pin_id_cia
            AND p.saldo <> 0
        ORDER BY
            d.cuenta,
            d.codcli,
            d.codsuc,
            d.tipdoc,
            d.femisi,
            d.docume;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar_cxp;

    FUNCTION sp_reporte_cxc (
        pin_id_cia  NUMBER,
        pin_fhasta  DATE,
        pin_codcli  VARCHAR2,
        pin_tipdocs VARCHAR2,
        pin_codalms VARCHAR2
    ) RETURN datatable_buscar_cxc
        PIPELINED
    AS
        v_table datatable_buscar_cxc;
    BEGIN
        SELECT
--            p.id_cia,
            EXTRACT(YEAR FROM p.fvenci)                              AS periodo,
            EXTRACT(MONTH FROM p.fvenci)                             AS mes,
            p.tipdoc,
            p.abrdoc                                                 AS abrtipdoc,
            p.desdoc                                                 AS destipdoc,
            p.docume,
            d.serie,
            d.numero,
            d.refere01,
            to_char(p.femisi, 'DD/MM/YYYY'),
            to_char(p.fvenci, 'DD/MM/YYYY'),
            CAST(trunc(pin_fhasta) - trunc(d.fvenci) AS INTEGER) - 1 AS diasmora,
            to_char(d.fcance, 'DD/MM/YYYY'),
            d.numbco,
            p.tipmon,
            d.tipcam,
            d.importe * td.signo                                     AS importe,
            d.codsuc,
            p.saldo                                                  AS saldox,
            d.codban,
            b.descri                                                 AS desban,
            p.codcli,
            c.razonc,
            c.limcre1,
            c.limcre2,
            c.chedev,
            c.letpro,
            c.renova,
            c.refina,
            to_char(c.fecing, 'DD/MM/YYYY'),
            d.codven,
            CASE
                WHEN d.codven IS NOT NULL THEN
                    v.desven
                ELSE
                    'No Asignado'
            END                                                      AS desven,
            d.protes,
            d.operac,
            (
                CASE
                    WHEN codpag = 1 THEN
                        'Abierto'
                    ELSE
                        'Cerrado'
                END
            )                                                        AS credito,
--            v.desven                                                    AS "Vendedor Cartera",
            d.cuenta,
            m.nombre                                                 AS descuenta
        BULK COLLECT
        INTO v_table
        FROM
            pack_reportes_tsi_documento.sp_buscar_saldo_cxc(pin_id_cia, - 1, pin_codcli, - 1, pin_tipdocs,
                                                            pin_codalms, pin_fhasta, - 1, 'S', 'N') p
            LEFT OUTER JOIN dcta100                                                                                 d ON d.id_cia = p.
            id_cia
                                         AND d.numint = p.numint
            LEFT OUTER JOIN tdoccobranza                                                                            td ON td.id_cia =
            d.id_cia
                                               AND td.tipdoc = d.tipdoc
            LEFT OUTER JOIN cliente                                                                                 c ON c.id_cia = d.
            id_cia
                                         AND c.codcli = d.codcli
            LEFT OUTER JOIN vendedor                                                                                v ON v.id_cia = d.
            id_cia
                                          AND v.codven = d.codven
            LEFT OUTER JOIN tbancos                                                                                 b ON b.id_cia = d.
            id_cia
                                         AND b.codban = CAST(d.codban AS VARCHAR(3))
            LEFT OUTER JOIN pcuentas                                                                                m ON m.id_cia = d.
            id_cia
                                          AND m.cuenta = d.cuenta
        WHERE
                d.id_cia = pin_id_cia
            AND p.saldo <> 0
        ORDER BY
            d.cuenta,
            d.codcli,
            d.codsuc,
            d.tipdoc,
            d.femisi,
            d.docume;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_reporte_cxc;

    FUNCTION sp_reporte_cxp (
        pin_id_cia  NUMBER,
        pin_fhasta  DATE,
        pin_codcli  VARCHAR2,
        pin_tipdocs VARCHAR2
    ) RETURN datatable_buscar_cxp
        PIPELINED
    AS
        v_table datatable_buscar_cxp;
    BEGIN
        SELECT
            EXTRACT(YEAR FROM p.fvenci)                              AS periodo,
            EXTRACT(MONTH FROM p.fvenci)                             AS mes,
            p.tipdoc,
            p.abrdoc                                                 AS dtido,
            p.desdoc                                                 AS destipdoc,
            p.docume,
            p.tipo,
            p.docu,
            d.refere01,
            to_char(d.femisi, 'DD/MM/YYYY'),
            to_char(d.fvenci, 'DD/MM/YYYY'),
            CAST(trunc(pin_fhasta) - trunc(d.fvenci) AS INTEGER) - 1 AS diasmora,
            to_char(d.fcance, 'DD/MM/YYYY'),
            d.numbco,
            d.tipmon,
            ( d.importe * td.signo ),
            d.codsuc,
            p.saldo                                                  AS saldox,
            d.codban,
            b.descri                                                 AS desban,
            p.codcli,
            c.razonc,
            c.limcre1,
            c.limcre2,
            c.chedev,
            c.letpro,
            c.renova,
            c.refina,
            to_char(c.fecing, 'DD/MM/YYYY'),
            d.operac,
            (
                CASE
                    WHEN codpag = 1 THEN
                        'Abierto'
                    ELSE
                        'Cerrado'
                END
            )                                                        AS credito,
            d.cuenta,
            m.nombre                                                 AS descuenta
        BULK COLLECT
        INTO v_table
        FROM
            pack_reportes_tsi_documento.sp_buscar_saldo_cxp(pin_id_cia, pin_codcli, pin_tipdocs, pin_fhasta, NULL,
                                                            NULL) p
            LEFT OUTER JOIN prov100                                               d ON d.id_cia = p.id_cia
                                         AND d.tipo = p.tipo
                                         AND d.docu = p.docu
            LEFT OUTER JOIN tdocume                                               td ON td.id_cia = d.id_cia
                                          AND td.codigo = d.tipdoc
            LEFT OUTER JOIN cliente                                               c ON c.id_cia = p.id_cia
                                         AND c.codcli = d.codcli
            LEFT OUTER JOIN tbancos                                               b ON b.id_cia = p.id_cia
                                         AND b.codban = CAST(d.codban AS VARCHAR(3))
            LEFT OUTER JOIN pcuentas                                              m ON m.id_cia = p.id_cia
                                          AND m.cuenta = d.cuenta
        WHERE
                p.id_cia = pin_id_cia
            AND p.saldo <> 0
        ORDER BY
            d.cuenta,
            d.codcli,
            d.codsuc,
            d.tipdoc,
            d.femisi,
            d.docume;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_reporte_cxp;

END;

/

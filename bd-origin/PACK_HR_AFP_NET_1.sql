--------------------------------------------------------
--  DDL for Package Body PACK_HR_AFP_NET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_HR_AFP_NET" AS

    FUNCTION sp_buscar (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER,
        pin_mes     NUMBER
    ) RETURN datatable_afp_net
        PIPELINED
    AS
        v_table datatable_afp_net;
    BEGIN
        SELECT
            p.id_cia,
            ccp.abrevi           AS coddid,
            nvl(ccp.codigo, ' ') AS coddidsunat,
            nvl(pd.nrodoc, ' ')  AS desdid,
            p.codper,
            p.apepat,
            p.apemat,
            p.nombre,
            MAX(pa.finicio),
            MAX(pa.ffinal),
            SUM(
                CASE
                    WHEN(ddd.esjubinv = 1
                         OR ddd.estrabmay65 = 1
                         OR ddd.esjubretfon = 1
                         OR ddd.esjubconpen = 1) THEN
                        0
                    ELSE
                        pc.valcon
                END
            )                    AS sueldoneto,
            SUM(pc.valcon)       AS sueldobruto,
            p.tiptra,
            p.direcc             AS direccion,
            p.situac,
            pd1.nrodoc           AS dni,
            pd2.nrodoc           AS cuss,
            ddd.codafp,
            ddd.abrafp,
            pcl.codigo,
            ddd.esjubinv,
            ddd.estrabmay65,
            ddd.esjubretfon,
            ddd.esjubconpen,
            ddd.relavig,
            ddd.inicrel,
            ddd.ceserel,
            ddd.exception_apt,
            SUM(
                CASE
                    WHEN(ddd.esjubinv = 1
                         OR ddd.estrabmay65 = 1
                         OR ddd.esjubretfon = 1
                         OR ddd.esjubconpen = 1) THEN
                        0
                    ELSE
                        pc.valcon
                END
            )                    AS apt_remaseg,
            ddd.apt_voluntario_finprov,
            ddd.apt_voluntario_sinfinprov,
            ddd.apt_voluntario_empleador,
            ddd.tipo_trabajo,
            ddd.rotulo
        BULK COLLECT
        INTO v_table
        FROM
            planilla                                                                    pl
            LEFT OUTER JOIN planilla_auxiliar                                                           pa ON pa.id_cia = pl.id_cia
                                                    AND pa.numpla = pl.numpla
            LEFT OUTER JOIN planilla_concepto                                                           pc ON pc.id_cia = pa.id_cia
                                                    AND pc.numpla = pa.numpla
                                                    AND pc.codper = pa.codper
            INNER JOIN tipoplanilla_concepto                                                       tc ON tc.id_cia = pc.id_cia
                                                   AND tc.codcon = pc.codcon
                                                   AND tc.tippla = pl.tippla
            LEFT OUTER JOIN personal                                                                    p ON p.id_cia = pc.id_cia
                                          AND p.codper = pc.codper
            LEFT OUTER JOIN personal_documento                                                          pd1 ON pd1.id_cia = p.id_cia
                                                      AND pd1.codper = p.codper
                                                      AND pd1.codtip = 'DO'
                                                      AND pd1.codite = 201
            LEFT OUTER JOIN personal_documento                                                          pd2 ON pd2.id_cia = p.id_cia
                                                      AND p.codper = pd2.codper
                                                      AND pd2.codtip = 'DO'
                                                      AND pd2.codite = 205
            LEFT OUTER JOIN personal_clase                                                              pcl ON p.codper = pcl.codper
                                                  AND pcl.clase = 1001
            LEFT OUTER JOIN personal_documento                                                          pd ON pd.id_cia = p.id_cia -- DOCUMENTO IDENTIDAD
                                                     AND pd.codper = p.codper
                                                     AND pd.codtip = 'DO'
                                                     AND pd.codite = 201
            LEFT OUTER JOIN clase_codigo_personal                                                       ccp ON ccp.id_cia = p.id_cia -- CLASE ASOCIADA AL DOCUMENTO IDENTIDAD
                                                         AND ccp.clase = pd.clase
                                                         AND ccp.codigo = pd.codigo
            LEFT OUTER JOIN pack_hr_afp_net.sp_detalle_relacionlaboral(pa.id_cia, pa.numpla, pa.codper) ddd ON 0 = 0
        WHERE
                pl.id_cia = pin_id_cia
            AND pl.anopla = pin_periodo
            AND pl.mespla = pin_mes
            AND pc.codcon IN ( '009', '509', 'B03' )
            AND pc.situac = 'S'
            AND p.codafp <> '0000'
            AND ( pa.situacper IN ( '01', '02', '03' )
                  OR pa.situacper = (
                CASE
                    WHEN EXTRACT(YEAR FROM pa.ffinal) = pin_periodo
                         AND EXTRACT(MONTH FROM pa.ffinal) <= pin_mes THEN
                        '05'
                    ELSE
                        'XX'
                END
            ) )
        GROUP BY
            p.id_cia,
            ccp.abrevi,
            ccp.codigo,
            pd.nrodoc,
            p.codper,
            p.apepat,
            p.apemat,
            p.nombre,
--            pa.finicio,
--            pa.ffinal,
            p.tiptra,
            p.direcc,
            p.situac,
            pd1.nrodoc,
            pd2.nrodoc,
            ddd.codafp,
            ddd.abrafp,
            pcl.codigo,
            ddd.esjubinv,
            ddd.estrabmay65,
            ddd.esjubretfon,
            ddd.esjubconpen,
            ddd.relavig,
            ddd.inicrel,
            ddd.ceserel,
            ddd.exception_apt,
            ddd.apt_remaseg,
            ddd.apt_voluntario_finprov,
            ddd.apt_voluntario_sinfinprov,
            ddd.apt_voluntario_empleador,
            ddd.tipo_trabajo,
            ddd.rotulo
        ORDER BY
            p.codper;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar;

    FUNCTION sp_detalle_relacionlaboral (
        pin_id_cia NUMBER,
        pin_numpla NUMBER,
        pin_codper VARCHAR2
    ) RETURN datatable_detalle_relacionlaboral
        PIPELINED
    AS

        v_rec       datarecord_detalle_relacionlaboral;
        esjubinv    personal_concepto.valcon%TYPE;
        estrabmay65 personal_concepto.valcon%TYPE;
        esjubretfon personal_concepto.valcon%TYPE;
        esjubconpen personal_concepto.valcon%TYPE;
        pin_periodo NUMBER;
        pin_mes     NUMBER;
    BEGIN
        BEGIN
            SELECT
                pl.anopla,
                pl.mespla,
                a.codafp,
                a.nombre,
                a.abrevi,
                pa.situacper,
                pa.finicio,
                pa.ffinal,
                pec1.valcon AS esjubinv,
                pec2.valcon AS estrabmay65,
                pec3.valcon AS esjubretfon,
                pec4.valcon AS esjubconpen
            INTO
                pin_periodo,
                pin_mes,
                v_rec.codafp,
                v_rec.desafp,
                v_rec.abrafp,
                v_rec.situacper,
                v_rec.finicio,
                v_rec.ffinal,
                v_rec.esjubinv,
                v_rec.estrabmay65,
                v_rec.esjubretfon,
                v_rec.esjubconpen
            FROM
                     planilla pl
                INNER JOIN planilla_auxiliar     pa ON pa.id_cia = pl.id_cia
                                                   AND pa.numpla = pl.numpla
                INNER JOIN planilla_afp          pafp ON pafp.id_cia = pa.id_cia
                                                AND pafp.numpla = pa.numpla
                                                AND pafp.codper = pa.codper
                INNER JOIN personal              p ON p.id_cia = pa.id_cia
                                         AND p.codper = pa.codper
                LEFT OUTER JOIN afp                   a ON a.id_cia = pafp.id_cia
                                         AND a.codafp = pafp.codafp
                LEFT OUTER JOIN factor_clase_planilla fcp1 ON fcp1.id_cia = p.id_cia
                                                              AND fcp1.codfac = '418'
                                                              AND fcp1.codcla = p.tiptra
                LEFT OUTER JOIN personal_concepto     pec1 ON pec1.id_cia = p.id_cia
                                                          AND pec1.codper = p.codper
                                                          AND pec1.periodo = pl.anopla
                                                          AND pec1.mes = pl.mespla
                                                          AND pec1.codcon IN ( fcp1.vstrg, '000' )
                LEFT OUTER JOIN factor_clase_planilla fcp2 ON fcp2.id_cia = p.id_cia
                                                              AND fcp2.codfac = '420'
                                                              AND fcp2.codcla = p.tiptra
                LEFT OUTER JOIN personal_concepto     pec2 ON pec2.id_cia = p.id_cia
                                                          AND pec2.codper = p.codper
                                                          AND pec2.periodo = pl.anopla
                                                          AND pec2.mes = pl.mespla
                                                          AND pec2.codcon IN ( fcp2.vstrg, '000' )
                LEFT OUTER JOIN factor_clase_planilla fcp3 ON fcp3.id_cia = p.id_cia
                                                              AND fcp3.codfac = '423'
                                                              AND fcp3.codcla = p.tiptra
                LEFT OUTER JOIN personal_concepto     pec3 ON pec3.id_cia = p.id_cia
                                                          AND pec3.codper = p.codper
                                                          AND pec3.periodo = pl.anopla
                                                          AND pec3.mes = pl.mespla
                                                          AND pec3.codcon IN ( fcp3.vstrg, '000' )
                LEFT OUTER JOIN factor_clase_planilla fcp4 ON fcp4.id_cia = p.id_cia
                                                              AND fcp4.codfac = '425'
                                                              AND fcp4.codcla = p.tiptra
                LEFT OUTER JOIN personal_concepto     pec4 ON pec4.id_cia = p.id_cia
                                                          AND pec4.codper = p.codper
                                                          AND pec4.periodo = pl.anopla
                                                          AND pec4.mes = pl.mespla
                                                          AND pec4.codcon IN ( fcp4.vstrg, '000' )
            WHERE
                    pl.id_cia = pin_id_cia
                AND pl.numpla = pin_numpla
                AND pa.codper = pin_codper
                AND pa.situac = 'S';

        END;

        v_rec.perdev := ( pin_periodo * 100 ) + pin_mes;
        v_rec.pering := ( extract(YEAR FROM v_rec.finicio) * 100 ) + extract(MONTH FROM v_rec.finicio);

        CASE
            WHEN v_rec.ffinal IS NOT NULL THEN
                v_rec.perces := ( extract(YEAR FROM v_rec.ffinal) * 100 ) + extract(MONTH FROM v_rec.ffinal);
            ELSE
                v_rec.perces := -1;
        END CASE;

        IF v_rec.situacper <> '05' OR (
            v_rec.situacper = '05'
            AND v_rec.perdev = v_rec.perces
        ) THEN
            v_rec.relavig := 'S'; -- RELACION LABORAL VIGENTE EN EL MES
        ELSE
            v_rec.relavig := 'N';
        END IF;

        IF v_rec.pering < v_rec.perdev THEN
            v_rec.inicrel := 'N';
        ELSE
            v_rec.inicrel := 'S'; -- RELACION LABORAL INICIA ESTE MES
        END IF;

        IF v_rec.situacper = '05' THEN
            v_rec.ceserel := 'S'; -- RELACION LABORAL TERMINA ESTE MES
        ELSE
            v_rec.ceserel := 'N';
        END IF;

        v_rec.finalrel := v_rec.relavig
                          || v_rec.inicrel
                          || v_rec.ceserel;

        CASE
            WHEN v_rec.esjubinv = 1 THEN
                v_rec.exception_apt := 'I';
            WHEN v_rec.estrabmay65 = 1 THEN
                v_rec.exception_apt := ' ';
            WHEN v_rec.esjubretfon = 1 THEN
                v_rec.exception_apt := 'O';
            WHEN v_rec.esjubconpen = 1 THEN
                v_rec.exception_apt := 'J';
            ELSE
                v_rec.exception_apt := ' ';
        END CASE;

        v_rec.apt_remaseg := 0;
        v_rec.apt_voluntario_finprov := 0;
        v_rec.apt_voluntario_sinfinprov := 0;
        v_rec.apt_voluntario_empleador := 0;
        v_rec.tipo_trabajo := 'N';
        v_rec.rotulo := v_rec.finalrel
                        || nvl(v_rec.exception_apt, ' ')
                        || to_char(sp000_ajusta_string('0', 09, '0', 'R'))
                        || to_char(sp000_ajusta_string(to_char(v_rec.apt_voluntario_finprov), 09, '0', 'R'))
                        || to_char(sp000_ajusta_string(to_char(v_rec.apt_voluntario_sinfinprov), 09, '0', 'R'))
                        || to_char(sp000_ajusta_string(to_char(v_rec.apt_voluntario_empleador), 09, '0', 'R'))
                        || nvl(v_rec.tipo_trabajo, ' ')
                        || nvl(substr(v_rec.abrafp, 1, 2), '  ');

        PIPE ROW ( v_rec );
    END sp_detalle_relacionlaboral;

END;

/

--------------------------------------------------------
--  DDL for Package Body PACK_HR_EMPRESA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_HR_EMPRESA" AS

    PROCEDURE sp_generar (
        pin_id_cia      IN NUMBER,
        pin_id_cia_orig IN NUMBER,
        pin_coduser     IN VARCHAR2,
        pin_mensaje     OUT VARCHAR2
    ) AS

        empresa_modelo_id NUMBER := 5;
        v_mensaje         VARCHAR2(1000 CHAR);
        pout_mensaje      VARCHAR2(1000 CHAR);
        m                 json_object_t;
    BEGIN
        IF pin_id_cia_orig IS NOT NULL THEN
            empresa_modelo_id := pin_id_cia_orig;
        END IF;
        dbms_output.put_line('SITUACION PERSONAL');
        INSERT INTO situacion_personal
            (
                SELECT
                    pin_id_cia,
                    sp.codsit,
                    sp.nombre,
                    pin_coduser,
                    pin_coduser,
                    current_timestamp,
                    current_timestamp
                FROM
                    situacion_personal sp
                WHERE
                        sp.id_cia = empresa_modelo_id
                    AND NOT EXISTS (
                        SELECT
                            sp1.*
                        FROM
                            situacion_personal sp1
                        WHERE
                                sp1.id_cia = pin_id_cia
                            AND sp1.codsit = sp.codsit
                    )
            );

        dbms_output.put_line('ESTADO CIVIL');
        INSERT INTO estado_civil
            (
                SELECT
                    pin_id_cia,
                    ec.codeci,
                    ec.deseci,
                    ec.swacti,
                    pin_coduser,
                    pin_coduser,
                    current_timestamp,
                    current_timestamp
                FROM
                    estado_civil ec
                WHERE
                        ec.id_cia = empresa_modelo_id
                    AND NOT EXISTS (
                        SELECT
                            ec1.*
                        FROM
                            estado_civil ec1
                        WHERE
                                ec1.id_cia = pin_id_cia
                            AND ec1.codeci = ec.codeci
                    )
            );

        dbms_output.put_line('ESTADO PERSONAL');
        INSERT INTO estado_personal
            (
                SELECT
                    pin_id_cia,
                    ep.codest,
                    ep.nombre,
                    pin_coduser,
                    pin_coduser,
                    current_timestamp,
                    current_timestamp
                FROM
                    estado_personal ep
                WHERE
                        ep.id_cia = empresa_modelo_id
                    AND NOT EXISTS (
                        SELECT
                            ep1.*
                        FROM
                            estado_personal ep1
                        WHERE
                                ep1.id_cia = pin_id_cia
                            AND ep1.codest = ep.codest
                    )
            );

        dbms_output.put_line('TIPO');
        INSERT INTO tipo
            (
                SELECT
                    pin_id_cia,
                    t.codtip,
                    t.nombre,
                    pin_coduser,
                    pin_coduser,
                    current_timestamp,
                    current_timestamp
                FROM
                    tipo t
                WHERE
                        t.id_cia = empresa_modelo_id
                    AND NOT EXISTS (
                        SELECT
                            t1.*
                        FROM
                            tipo t1
                        WHERE
                                t1.id_cia = pin_id_cia
                            AND t1.codtip = t.codtip
                    )
            );

        dbms_output.put_line('TIPO ITEM');
        INSERT INTO tipoitem
            (
                SELECT
                    pin_id_cia,
                    t.codtip,
                    t.codite,
                    t.nombre,
                    t.obliga,
                    pin_coduser,
                    pin_coduser,
                    current_timestamp,
                    current_timestamp
                FROM
                    tipoitem t
                WHERE
                        t.id_cia = empresa_modelo_id
                    AND NOT EXISTS (
                        SELECT
                            t1.*
                        FROM
                            tipoitem t1
                        WHERE
                                t1.id_cia = pin_id_cia
                            AND t1.codtip = t.codtip
                            AND t1.codite = t.codite
                    )
            );

        dbms_output.put_line('TIPO TRABAJADOR');
        INSERT INTO tipo_trabajador
            (
                SELECT
                    pin_id_cia,
                    tt.tiptra,
                    tt.nombre,
                    tt.noper,
                    tt.conpre,
                    tt.cuenta,
                    tt.libro,
                    tt.conred,
                    pin_coduser,
                    pin_coduser,
                    current_timestamp,
                    current_timestamp
                FROM
                    tipo_trabajador tt
                WHERE
                        tt.id_cia = empresa_modelo_id
                    AND NOT EXISTS (
                        SELECT
                            tt1.*
                        FROM
                            tipo_trabajador tt1
                        WHERE
                                tt1.id_cia = pin_id_cia
                            AND tt1.tiptra = tt.tiptra
                    )
            );

        dbms_output.put_line('TIPO PLANILLA');
        INSERT INTO tipoplanilla
            (
                SELECT
                    pin_id_cia,
                    tp.tippla,
                    tp.nombre,
                    tp.diapla,
                    tp.horpla,
                    tp.redond,
                    tp.codcta,
                    tp.facade,
                    tp.dh,
                    tp.agrupa,
                    tp.libro,
                    tp.swcuenta,
                    tp.swacti,
                    tp.codctaobr,
                    pin_coduser,
                    pin_coduser,
                    current_timestamp,
                    current_timestamp
                FROM
                    tipoplanilla tp
                WHERE
                        tp.id_cia = empresa_modelo_id
                    AND NOT EXISTS (
                        SELECT
                            tp1.*
                        FROM
                            tipoplanilla tp1
                        WHERE
                                tp1.id_cia = pin_id_cia
                            AND tp1.tippla = tp.tippla
                    )
            );

        dbms_output.put_line('CLASE PERSONAL');
        INSERT INTO clase_personal
            (
                SELECT
                    pin_id_cia,
                    cp.clase,
                    cp.descri,
                    cp.secuen,
                    cp.longit,
                    cp.situac,
                    cp.obliga,
                    pin_coduser,
                    pin_coduser,
                    current_timestamp,
                    current_timestamp
                FROM
                    clase_personal cp
                WHERE
                        cp.id_cia = empresa_modelo_id
                    AND NOT EXISTS (
                        SELECT
                            cp1.*
                        FROM
                            clase_personal cp1
                        WHERE
                                cp1.id_cia = pin_id_cia
                            AND cp1.clase = cp.clase
                    )
            );

        dbms_output.put_line('CLASE_CODIGO_PERSONAL');
        INSERT INTO clase_codigo_personal
            (
                SELECT
                    pin_id_cia,
                    ccp.clase,
                    ccp.codigo,
                    ccp.descri,
                    ccp.abrevi,
                    ccp.situac,
                    ccp.swdefault,
                    ccp.tiptra,
                    pin_coduser,
                    pin_coduser,
                    current_timestamp,
                    current_timestamp
                FROM
                    clase_codigo_personal ccp
                WHERE
                        ccp.id_cia = empresa_modelo_id
                    AND NOT EXISTS (
                        SELECT
                            ccp1.*
                        FROM
                            clase_codigo_personal ccp1
                        WHERE
                                ccp1.id_cia = pin_id_cia
                            AND ccp1.clase = ccp.clase
                            AND ccp1.codigo = ccp.codigo
                    )
            );

        dbms_output.put_line('CLASE_CONCEPTO');
        INSERT INTO clase_concepto
            (
                SELECT
                    pin_id_cia,
                    cc.clase,
                    cc.descri,
                    cc.indsubcod,
                    cc.indrotulo,
                    pin_coduser,
                    pin_coduser,
                    current_timestamp,
                    current_timestamp
                FROM
                    clase_concepto cc
                WHERE
                        cc.id_cia = empresa_modelo_id
                    AND NOT EXISTS (
                        SELECT
                            cc1.*
                        FROM
                            clase_concepto cc1
                        WHERE
                                cc1.id_cia = pin_id_cia
                            AND cc1.clase = cc.clase
                    )
            );

        dbms_output.put_line('CLASE_CONCEPTO_CODIGO');
        INSERT INTO clase_concepto_codigo
            (
                SELECT
                    pin_id_cia,
                    ccc.clase,
                    ccc.codigo,
                    ccc.descri,
                    ccc.abrevi,
                    ccc.vstrg,
                    pin_coduser,
                    pin_coduser,
                    current_timestamp,
                    current_timestamp
                FROM
                    clase_concepto_codigo ccc
                WHERE
                        ccc.id_cia = empresa_modelo_id
                    AND NOT EXISTS (
                        SELECT
                            ccc1.*
                        FROM
                            clase_concepto_codigo ccc1
                        WHERE
                                ccc1.id_cia = pin_id_cia
                            AND ccc1.clase = ccc.clase
                            AND ccc1.codigo = ccc.codigo
                    )
            );

        dbms_output.put_line('FACTOR_PLANILLA');
        INSERT INTO factor_planilla
            (
                SELECT
                    pin_id_cia,
                    fp.codfac,
                    fp.nombre,
                    fp.valfa1,
                    fp.valfa2,
                    fp.tipfac,
                    fp.indafp,
                    pin_coduser,
                    pin_coduser,
                    current_timestamp,
                    current_timestamp
                FROM
                    factor_planilla fp
                WHERE
                        fp.id_cia = empresa_modelo_id
                    AND NOT EXISTS (
                        SELECT
                            fp1.*
                        FROM
                            factor_planilla fp1
                        WHERE
                                fp1.id_cia = pin_id_cia
                            AND fp1.codfac = fp.codfac
                    )
            );

        dbms_output.put_line('FACTOR_CLASE_PLANILLA');
        INSERT INTO factor_clase_planilla
            (
                SELECT
                    pin_id_cia,
                    fcp.codfac,
                    fcp.codcla,
                    fcp.tipcla,
                    fcp.tipvar,
                    fcp.nombre,
                    fcp.vreal,
                    fcp.vstrg,
                    fcp.vchar,
                    fcp.vdate,
                    fcp.vtime,
                    fcp.ventero,
                    pin_coduser,
                    pin_coduser,
                    current_timestamp,
                    current_timestamp
                FROM
                    factor_clase_planilla fcp
                WHERE
                        fcp.id_cia = empresa_modelo_id
                    AND NOT EXISTS (
                        SELECT
                            cp1.*
                        FROM
                            factor_clase_planilla fcp1
                        WHERE
                                fcp1.id_cia = pin_id_cia
                            AND fcp1.codfac = fcp.codfac
                            AND fcp1.codcla = fcp.codcla
                    )
            );

        dbms_output.put_line('FUNCION_PLANILLA');
        INSERT INTO funcion_planilla
            (
                SELECT
                    pin_id_cia,
                    fp.codfun,
                    fp.nombre,
                    fp.nomfun,
                    fp.tipfun,
                    fp.nummes,
                    fp.pactual,
                    fp.mactual,
                    fp.observ,
                    pin_coduser,
                    pin_coduser,
                    current_timestamp,
                    current_timestamp
                FROM
                    funcion_planilla fp
                WHERE
                        fp.id_cia = empresa_modelo_id
                    AND NOT EXISTS (
                        SELECT
                            fp1.*
                        FROM
                            funcion_planilla fp1
                        WHERE
                                fp1.id_cia = pin_id_cia
                            AND fp1.codfun = fp.codfun
                    )
            );

        dbms_output.put_line('MOTIVO_PLANILLA');
        INSERT INTO motivo_planilla
            (
                SELECT
                    pin_id_cia,
                    mp.codmot,
                    mp.descri,
                    mp.permite,
                    mp.codrel,
                    mp.tipo,
                    mp.pagado,
                    pin_coduser,
                    pin_coduser,
                    current_timestamp,
                    current_timestamp
                FROM
                    motivo_planilla mp
                WHERE
                        mp.id_cia = empresa_modelo_id
                    AND NOT EXISTS (
                        SELECT
                            mp1.*
                        FROM
                            motivo_planilla mp1
                        WHERE
                                mp1.id_cia = pin_id_cia
                            AND mp1.codmot = mp.codmot
                    )
            );

        dbms_output.put_line('NACIONALIDAD');
        INSERT INTO nacionalidad
            (
                SELECT
                    pin_id_cia,
                    n.codnac,
                    n.nombre,
                    pin_coduser,
                    pin_coduser,
                    current_timestamp,
                    current_timestamp
                FROM
                    nacionalidad n
                WHERE
                        n.id_cia = empresa_modelo_id
                    AND NOT EXISTS (
                        SELECT
                            n1.*
                        FROM
                            nacionalidad n1
                        WHERE
                                n1.id_cia = pin_id_cia
                            AND n1.codnac = n.codnac
                    )
            );

        dbms_output.put_line('CONCEPTOS_PDT');
        INSERT INTO conceptos_pdt
            (
                SELECT
                    pin_id_cia,
                    cc.codpdt,
                    cc.descri,
                    pin_coduser,
                    pin_coduser,
                    current_timestamp,
                    current_timestamp
                FROM
                    conceptos_pdt cc
                WHERE
                        cc.id_cia = empresa_modelo_id
                    AND NOT EXISTS (
                        SELECT
                            cc1.*
                        FROM
                            conceptos_pdt cc1
                        WHERE
                                cc1.id_cia = pin_id_cia
                            AND cc1.codpdt = cc.codpdt
                    )
            );

        dbms_output.put_line('CONCEPTO');
        BEGIN
            INSERT INTO concepto
                (
                    SELECT
                        pin_id_cia,
                        c.codcon,
                        c.empobr,
                        c.ingdes,
                        c.nombre,
                        c.abrevi,
                        c.fijvar,
                        c.codcta,
                        c.formul,
                        c.indprc,
                        c.posimp,
                        c.indimp,
                        c.nomimp,
                        c.nomcts,
                        c.indcts,
                        c.dh,
                        c.agrupa,
                        c.ctagasto,
                        c.conrel,
                        c.tipo,
                        c.nomtipo,
                        c.codpdt,
                        c.idliq,
                        c.swacti,
                        pin_coduser,
                        pin_coduser,
                        current_timestamp,
                        current_timestamp
                    FROM
                        concepto c
                    WHERE
                            c.id_cia = empresa_modelo_id
                        AND NOT EXISTS (
                            SELECT
                                c1.*
                            FROM
                                concepto c1
                            WHERE
                                    c1.id_cia = pin_id_cia
                                AND c1.codcon = c.codcon
                        )
                );

        EXCEPTION
            WHEN OTHERS THEN
                IF sqlcode = -2291 THEN
                    INSERT INTO concepto
                        (
                            SELECT
                                pin_id_cia,
                                c.codcon,
                                c.empobr,
                                c.ingdes,
                                c.nombre,
                                c.abrevi,
                                c.fijvar,
                                NULL,
                                c.formul,
                                c.indprc,
                                c.posimp,
                                c.indimp,
                                c.nomimp,
                                c.nomcts,
                                c.indcts,
                                c.dh,
                                c.agrupa,
                                NULL,
                                c.conrel,
                                c.tipo,
                                c.nomtipo,
                                c.codpdt,
                                c.idliq,
                                c.swacti,
                                pin_coduser,
                                pin_coduser,
                                current_timestamp,
                                current_timestamp
                            FROM
                                concepto c
                            WHERE
                                    c.id_cia = empresa_modelo_id
                                AND NOT EXISTS (
                                    SELECT
                                        c1.*
                                    FROM
                                        concepto c1
                                    WHERE
                                            c1.id_cia = pin_id_cia
                                        AND c1.codcon = c.codcon
                                )
                        );

                ELSE
                    pin_mensaje := 'mensaje : '
                                   || sqlerrm
                                   || ' fijvar :'
                                   || sqlcode;
                    SELECT
                        JSON_OBJECT(
                            'status' VALUE 1.2,
                            'message' VALUE pin_mensaje
                        )
                    INTO pin_mensaje
                    FROM
                        dual;

                    RETURN;
                END IF;
        END;

        dbms_output.put_line('CONCEPTOS_FUNCION');
        INSERT INTO concepto_funcion
            (
                SELECT
                    pin_id_cia,
                    cf.condes,
                    cf.conori,
                    cf.codfun,
                    pin_coduser,
                    pin_coduser,
                    current_timestamp,
                    current_timestamp
                FROM
                    concepto_funcion cf
                WHERE
                        cf.id_cia = empresa_modelo_id
                    AND NOT EXISTS (
                        SELECT
                            c1.*
                        FROM
                            concepto_funcion cf1
                        WHERE
                                cf1.id_cia = pin_id_cia
                            AND cf1.condes = cf.condes
                            AND cf1.conori = cf.conori
                    )
            );

        dbms_output.put_line('CONCEPTO_CLASE');
        INSERT INTO concepto_clase
            (
                SELECT
                    pin_id_cia,
                    cc.codcon,
                    cc.clase,
                    cc.codigo,
                    cc.vstrg,
                    cc.vresult,
                    cc.vposition,
                    cc.vprefijo,
                    cc.vsufijo,
                    cc.codfor,
                    pin_coduser,
                    pin_coduser,
                    current_timestamp,
                    current_timestamp
                FROM
                    concepto_clase cc
                WHERE
                        cc.id_cia = empresa_modelo_id
                    AND NOT EXISTS (
                        SELECT
                            cc1.*
                        FROM
                            concepto_clase cc1
                        WHERE
                                cc1.id_cia = pin_id_cia
                            AND cc1.codcon = cc.codcon
                            AND cc1.clase = cc.clase
                    )
            );

        dbms_output.put_line('TIPOPLANILLA_CONCEPTO');
        INSERT INTO tipoplanilla_concepto
            (
                SELECT
                    pin_id_cia,
                    tpc.tippla,
                    tpc.codcon,
                    pin_coduser,
                    pin_coduser,
                    current_timestamp,
                    current_timestamp
                FROM
                    tipoplanilla_concepto tpc
                WHERE
                        tpc.id_cia = empresa_modelo_id
                    AND NOT EXISTS (
                        SELECT
                            tpc1.*
                        FROM
                            tipoplanilla_concepto tpc1
                        WHERE
                                tpc1.id_cia = pin_id_cia
                            AND tpc1.tippla = tpc.tippla
                            AND tpc1.codcon = tpc.codcon
                    )
            );

        dbms_output.put_line('AFP');
        INSERT INTO afp
            (
                SELECT
                    pin_id_cia,
                    a.codafp,
                    a.nombre,
                    a.codcla,
                    a.codcta,
                    a.dh,
                    a.codigo,
                    a.abrevi,
                    pin_coduser,
                    pin_coduser,
                    current_timestamp,
                    current_timestamp
                FROM
                    afp a
                WHERE
                        a.id_cia = empresa_modelo_id
                    AND NOT EXISTS (
                        SELECT
                            a1.*
                        FROM
                            afp a1
                        WHERE
                                a1.id_cia = pin_id_cia
                            AND a1.codafp = a.codafp
                    )
            );
    
        dbms_output.put_line('CONCEPTO FORMULA');
        INSERT INTO concepto_formula
            (
                SELECT
                    pin_id_cia,
                    cf.codcon,
                    cf.tiptra,
                    cf.tippla,
                    cf.formul,
                    cf.swacti,
                    pin_coduser,
                    pin_coduser,
                    current_timestamp,
                    current_timestamp,
                    cf.codcta,
                    cf.ctagasto
                FROM
                    concepto_formula cf
                WHERE
                        cf.id_cia = empresa_modelo_id
                    AND NOT EXISTS (
                        SELECT
                            cf1.*
                        FROM
                            concepto_formula cf1
                        WHERE
                                cf1.id_cia = pin_id_cia
                            AND cf1.codcon = cf.codcon
                            AND cf1.tiptra = cf.tiptra
                            AND cf1.tippla = cf.tippla
                    )
            );

        pack_hr_personal_concepto.sp_asigna_conceptos_fijos(pin_id_cia, NULL, extract(YEAR FROM current_timestamp), 0, pin_coduser,
                                                           v_mensaje);

        m := json_object_t.parse(v_mensaje);
        IF ( m.get_number('status') <> 1.0 ) THEN
            pout_mensaje := m.get_string('message');
            RAISE pkg_exceptionuser.ex_error_inesperado;
        END IF;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'Succes ...!'
            )
        INTO pin_mensaje
        FROM
            dual;

        COMMIT;
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
                           || ' fijvar :'
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
    END sp_generar;

    PROCEDURE sp_eliminar (
        pin_id_cia  IN NUMBER,
        pin_coduser IN VARCHAR2,
        pin_mensaje OUT VARCHAR2
    ) AS
    BEGIN
        NULL;
    END sp_eliminar;

END;

/

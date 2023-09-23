--------------------------------------------------------
--  DDL for Package Body PACK_HR_CONCEPTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_HR_CONCEPTO" AS

    FUNCTION sp_buscar_ingdes (
        pin_id_cia NUMBER
    ) RETURN datatable_ingdes
        PIPELINED
    AS
        v_rec datarecord_ingdes;
    BEGIN
        v_rec := datarecord_ingdes(pin_id_cia, 'A', 'INGRESO');
        PIPE ROW ( v_rec );
        v_rec := datarecord_ingdes(pin_id_cia, 'B', 'DESCUENTO');
        PIPE ROW ( v_rec );
        v_rec := datarecord_ingdes(pin_id_cia, 'C', 'APORTE TRABAJADOR');
        PIPE ROW ( v_rec );
        v_rec := datarecord_ingdes(pin_id_cia, 'D', 'APORTE EMPLEADO');
        PIPE ROW ( v_rec );
        v_rec := datarecord_ingdes(pin_id_cia, 'E', 'REFERENCIA');
        PIPE ROW ( v_rec );
        RETURN;
    END sp_buscar_ingdes;

    FUNCTION sp_buscar_fijvar (
        pin_id_cia NUMBER
    ) RETURN datatable_fijvar
        PIPELINED
    AS
        v_rec datarecord_fijvar;
    BEGIN
        v_rec := datarecord_fijvar(pin_id_cia, 'C', 'CALCULADO');
        PIPE ROW ( v_rec );
        v_rec := datarecord_fijvar(pin_id_cia, 'F', 'FIJO');
        PIPE ROW ( v_rec );
        v_rec := datarecord_fijvar(pin_id_cia, 'V', 'VARIABLE');
        PIPE ROW ( v_rec );
        v_rec := datarecord_fijvar(pin_id_cia, 'S', 'SISTEMA');
        PIPE ROW ( v_rec );
        v_rec := datarecord_fijvar(pin_id_cia, 'P', 'PRESTAMO');
        PIPE ROW ( v_rec );
        RETURN;
    END sp_buscar_fijvar;

    FUNCTION sp_buscar_idliq (
        pin_id_cia NUMBER
    ) RETURN datatable_idliq
        PIPELINED
    AS
        v_rec datarecord_idliq;
    BEGIN
        v_rec := datarecord_idliq(pin_id_cia, 'A', 'REMUN. COMPUTABLE');
        PIPE ROW ( v_rec );
        v_rec := datarecord_idliq(pin_id_cia, 'B', 'INGRESO');
        PIPE ROW ( v_rec );
        v_rec := datarecord_idliq(pin_id_cia, 'C', 'DESCUENTO');
        PIPE ROW ( v_rec );
        v_rec := datarecord_idliq(pin_id_cia, 'D', 'APORTE TRABAJADOR');
        PIPE ROW ( v_rec );
        v_rec := datarecord_idliq(pin_id_cia, 'E', 'APORTE EMP');
        PIPE ROW ( v_rec );
        v_rec := datarecord_idliq(pin_id_cia, 'F', 'REFERENCIA');
        PIPE ROW ( v_rec );
        v_rec := datarecord_idliq(pin_id_cia, 'G', 'CONCEPTOS REMUNERATIVOS COMPUTABLES');
        PIPE ROW ( v_rec );
        v_rec := datarecord_idliq(pin_id_cia, 'H', 'TOTAL REMUNERACIÓN COMPUTABLE');
        PIPE ROW ( v_rec );
        RETURN;
    END sp_buscar_idliq;

    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_codcon VARCHAR2
    ) RETURN datatable_concepto
        PIPELINED
    AS
        v_table datatable_concepto;
    BEGIN
        SELECT
            c.id_cia,
            c.codcon,
            c.empobr,
            c.ingdes,
            c.nombre,
            c.abrevi,
            c.fijvar,
            c.codcta,
            p1.nombre  AS descodcta,
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
            p2.nombre  AS desctagasto,
            c.conrel,
            c.tipo,
            c.nomtipo,
            c.codpdt,
            pdt.descri AS despdt,
            c.idliq,
            c.swacti,
            c.ucreac,
            c.uactua,
            c.fcreac,
            c.factua
        BULK COLLECT
        INTO v_table
        FROM
            concepto      c
            LEFT OUTER JOIN conceptos_pdt pdt ON pdt.id_cia = c.id_cia
                                                 AND pdt.codpdt = c.codpdt
            LEFT OUTER JOIN pcuentas      p1 ON p1.id_cia = c.id_cia
                                           AND p1.cuenta = c.codcta
            LEFT OUTER JOIN pcuentas      p2 ON p2.id_cia = c.id_cia
                                           AND p2.cuenta = c.ctagasto
        WHERE
                c.id_cia = pin_id_cia
            AND c.codcon = pin_codcon;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_list_conceptos (
        pin_id_cia NUMBER,
        pin_empobr VARCHAR2
    ) RETURN datatable_list_conceptos
        PIPELINED
    AS
        v_table datatable_list_conceptos;
    BEGIN
        SELECT
            c.id_cia,
            c.codcon,
            c.nombre
        BULK COLLECT
        INTO v_table
        FROM
            concepto c
        WHERE
                c.id_cia = pin_id_cia
            AND c.empobr = pin_empobr;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END;

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_empobr VARCHAR2,
        pin_tippla VARCHAR2,
        pin_ingdes VARCHAR2,
        pin_indimp VARCHAR2,
        pin_dh     VARCHAR2,
        pin_fijvar VARCHAR2,
        pin_idliq  VARCHAR2,
        pin_agrupa VARCHAR2
    ) RETURN datatable_concepto
        PIPELINED
    AS
        v_table datatable_concepto;
    BEGIN
        IF pin_tippla IS NULL THEN
            SELECT
                c.id_cia,
                c.codcon,
                c.empobr,
                c.ingdes,
                c.nombre,
                c.abrevi,
                c.fijvar,
                c.codcta,
                p1.nombre  AS descodcta,
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
                p2.nombre  AS desctagasto,
                c.conrel,
                c.tipo,
                c.nomtipo,
                c.codpdt,
                pdt.descri AS despdt,
                c.idliq,
                c.swacti,
                c.ucreac,
                c.uactua,
                c.fcreac,
                c.factua
            BULK COLLECT
            INTO v_table
            FROM
                concepto      c
--            INNER JOIN tipoplanilla_concepto tpc ON tpc.id_cia = c.id_cia
--                                                    AND tpc.tippla = pin_tippla
--                                                    AND tpc.codcon = c.codcon
                LEFT OUTER JOIN conceptos_pdt pdt ON pdt.id_cia = c.id_cia
                                                     AND pdt.codpdt = c.codpdt
                LEFT OUTER JOIN pcuentas      p1 ON p1.id_cia = c.id_cia
                                               AND p1.cuenta = c.codcta
                LEFT OUTER JOIN pcuentas      p2 ON p2.id_cia = c.id_cia
                                               AND p2.cuenta = c.ctagasto
            WHERE
                    c.id_cia = pin_id_cia
                AND c.empobr = pin_empobr
                AND ( pin_ingdes IS NULL
                      OR c.ingdes = pin_ingdes )
                AND ( pin_indimp IS NULL
                      OR c.indimp = pin_indimp )
                AND ( pin_dh IS NULL
                      OR c.dh = pin_dh )
                AND ( pin_fijvar IS NULL
                      OR c.fijvar = pin_fijvar )
                AND ( pin_idliq IS NULL
                      OR c.idliq = pin_idliq )
                AND ( pin_agrupa IS NULL
                      OR c.agrupa = pin_agrupa );

            FOR registro IN 1..v_table.count LOOP
                PIPE ROW ( v_table(registro) );
            END LOOP;

            RETURN;
        ELSE
            SELECT
                c.id_cia,
                c.codcon,
                c.empobr,
                c.ingdes,
                c.nombre,
                c.abrevi,
                c.fijvar,
                c.codcta,
                p1.nombre  AS descodcta,
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
                p2.nombre  AS desctagasto,
                c.conrel,
                c.tipo,
                c.nomtipo,
                c.codpdt,
                pdt.descri AS despdt,
                c.idliq,
                c.swacti,
                c.ucreac,
                c.uactua,
                c.fcreac,
                c.factua
            BULK COLLECT
            INTO v_table
            FROM
                     concepto c
                INNER JOIN tipoplanilla_concepto tpc ON tpc.id_cia = c.id_cia
                                                        AND tpc.tippla = pin_tippla
                                                        AND tpc.codcon = c.codcon
                LEFT OUTER JOIN conceptos_pdt         pdt ON pdt.id_cia = c.id_cia
                                                     AND pdt.codpdt = c.codpdt
                LEFT OUTER JOIN pcuentas              p1 ON p1.id_cia = c.id_cia
                                               AND p1.cuenta = c.codcta
                LEFT OUTER JOIN pcuentas              p2 ON p2.id_cia = c.id_cia
                                               AND p2.cuenta = c.ctagasto
            WHERE
                    c.id_cia = pin_id_cia
                AND c.empobr = pin_empobr
                AND ( pin_ingdes IS NULL
                      OR c.ingdes = pin_ingdes )
                AND ( pin_indimp IS NULL
                      OR c.indimp = pin_indimp )
                AND ( pin_dh IS NULL
                      OR c.dh = pin_dh )
                AND ( pin_fijvar IS NULL
                      OR c.fijvar = pin_fijvar )
                AND ( pin_idliq IS NULL
                      OR c.idliq = pin_idliq )
                AND ( pin_agrupa IS NULL
                      OR c.agrupa = pin_agrupa );

            FOR registro IN 1..v_table.count LOOP
                PIPE ROW ( v_table(registro) );
            END LOOP;

        END IF;
    END sp_buscar;

    FUNCTION sp_buscar_nombre (
        pin_id_cia NUMBER,
        pin_nombre IN VARCHAR2
    ) RETURN datatable_concepto
        PIPELINED
    AS
        v_table datatable_concepto;
    BEGIN
        SELECT
            c.id_cia,
            c.codcon,
            c.empobr,
            c.ingdes,
            c.nombre,
            c.abrevi,
            c.fijvar,
            c.codcta,
            p1.nombre  AS descodcta,
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
            p2.nombre  AS desctagasto,
            c.conrel,
            c.tipo,
            c.nomtipo,
            c.codpdt,
            pdt.descri AS despdt,
            c.idliq,
            c.swacti,
            c.ucreac,
            c.uactua,
            c.fcreac,
            c.factua
        BULK COLLECT
        INTO v_table
        FROM
            concepto      c
            LEFT OUTER JOIN conceptos_pdt pdt ON pdt.id_cia = c.id_cia
                                                 AND pdt.codpdt = c.codpdt
            LEFT OUTER JOIN pcuentas      p1 ON p1.id_cia = c.id_cia
                                           AND p1.cuenta = c.codcta
            LEFT OUTER JOIN pcuentas      p2 ON p2.id_cia = c.id_cia
                                           AND p2.cuenta = c.ctagasto
        WHERE
                c.id_cia = pin_id_cia
            AND ( instr(upper(c.nombre),
                        upper(pin_nombre)) > 0
                  OR pin_nombre IS NULL );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar_nombre;

--set SERVEROUTPUT on;
--
--DECLARE
--    mensaje VARCHAR2(500);
--    cadjson VARCHAR2(5000);
--BEGIN
--cadjson := '{
--                "codcon":"POP",
--                "empobr":"E",
--                "ingdes":"A",
--                "nombre":"CONCEPTO PRUEBA",
--                "abrevi":"PRUEBA",
--                "fijvar":"P",
--                "codcta":"PRUEBA",
--                "formul":"",
--                "indprc":"C",
--                "posimp":1,
--                "indimp":"S",
--                "nomimp":"PRUEBA",
--                "nomcts":"PRUEBA",
--                "indcts":"P",
--                "dh":"D",
--                "agrupa":"S",
--                "ctagasto":"15646",
--                "conrel":"PPP",
--                "tipo":"P",
--                "nomtipo":"PP",
--                "codpdt":"0118",
--                "idliq":"A",
--                "swacti":"S",
--                "ucreac":"Admin",
--                "uactua":"Admin"
--                }';
--
--pack_hr_concepto.sp_save(66, 'HOLA', cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--end;
--
--
--SELECT
--    *
--FROM
--    pack_hr_concepto.sp_obtener(66, 'POP');
--
--
--SELECT
--    *
--FROM
--    pack_hr_concepto.sp_buscar(66, 'E', 'N', NULL, NULL,
--                               NULL, NULL, NULL, 'S');
--
--SELECT
--    *
--FROM
--    pack_hr_concepto.sp_list_conceptos(66, 'E');

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_formula IN VARCHAR2,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS

        o             json_object_t;
        m             json_object_t;
        rec_concepto  concepto%rowtype;
        v_accion      VARCHAR2(50) := '';
        v_mensaje     VARCHAR2(1000) := '';
        v_formula     VARCHAR2(4000) := pin_formula;
        v_poutformula VARCHAR2(4000 CHAR);
        v_nrodoc      VARCHAR2(20);
        v_clase       NUMBER;
        v_codigo      VARCHAR2(20);
        pout_mensaje  VARCHAR2(1000);
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_concepto.id_cia := pin_id_cia;
        rec_concepto.codcon := o.get_string('codcon');
        rec_concepto.empobr := o.get_string('empobr');
        rec_concepto.ingdes := o.get_string('ingdes');
        rec_concepto.nombre := o.get_string('nombre');
        rec_concepto.abrevi := o.get_string('abrevi');
        rec_concepto.fijvar := o.get_string('fijvar');
        rec_concepto.codcta := o.get_string('codcta');
        rec_concepto.formul := pin_formula;
        rec_concepto.indprc := o.get_string('indprc');
        rec_concepto.posimp := o.get_number('posimp');
        rec_concepto.indimp := o.get_string('indimp');
        rec_concepto.nomimp := o.get_string('nomimp');
        rec_concepto.nomcts := o.get_string('nomcts');
        rec_concepto.indcts := o.get_string('indcts');
        rec_concepto.dh := o.get_string('dh');
        rec_concepto.agrupa := o.get_string('agrupa');
        rec_concepto.ctagasto := o.get_string('ctagasto');
        rec_concepto.conrel := o.get_string('conrel');
        rec_concepto.tipo := o.get_string('tipo');
        rec_concepto.nomtipo := o.get_string('nomtipo');
        rec_concepto.codpdt := o.get_string('codpdt');
        rec_concepto.idliq := o.get_string('idliq');
        rec_concepto.swacti := o.get_string('swacti');
        rec_concepto.ucreac := o.get_string('ucreac');
        rec_concepto.uactua := o.get_string('uactua');
        v_accion := '';
--        IF v_formula IS NOT NULL THEN
--            pack_hr_concepto_formula.sp_sintaxis(pin_id_cia, rec_concepto.codcon, v_formula, v_poutformula, v_mensaje);
--            m := json_object_t.parse(v_mensaje);
--            IF ( m.get_number('status') <> 1.0 ) THEN
--                pout_mensaje := m.get_string('message');
--                RAISE pkg_exceptionuser.ex_error_inesperado;
--            END IF;
--
--        END IF;

        CASE pin_opcdml
            WHEN 1 THEN
                v_accion := 'La inserción';
                INSERT INTO concepto (
                    id_cia,
                    codcon,
                    empobr,
                    ingdes,
                    nombre,
                    abrevi,
                    fijvar,
                    codcta,
                    formul,
                    indprc,
                    posimp,
                    indimp,
                    nomimp,
                    nomcts,
                    indcts,
                    dh,
                    agrupa,
                    ctagasto,
                    conrel,
                    tipo,
                    nomtipo,
                    codpdt,
                    idliq,
                    swacti,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_concepto.id_cia,
                    rec_concepto.codcon,
                    rec_concepto.empobr,
                    rec_concepto.ingdes,
                    rec_concepto.nombre,
                    rec_concepto.abrevi,
                    rec_concepto.fijvar,
                    rec_concepto.codcta,
                    rec_concepto.formul,
                    rec_concepto.indprc,
                    rec_concepto.posimp,
                    rec_concepto.indimp,
                    rec_concepto.nomimp,
                    rec_concepto.nomcts,
                    rec_concepto.indcts,
                    rec_concepto.dh,
                    rec_concepto.agrupa,
                    rec_concepto.ctagasto,
                    rec_concepto.conrel,
                    rec_concepto.tipo,
                    rec_concepto.nomtipo,
                    rec_concepto.codpdt,
                    rec_concepto.idliq,
                    rec_concepto.swacti,
                    rec_concepto.ucreac,
                    rec_concepto.uactua,
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS'),
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS')
                );

                INSERT INTO tipoplanilla_concepto
                    (
                        SELECT
                            c.id_cia,
                            tp.tippla,
                            c.codcon,
                            c.ucreac,
                            c.ucreac,
                            TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                         'YYYY-MM-DD HH24:MI:SS'),
                            TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                         'YYYY-MM-DD HH24:MI:SS')
                        FROM
                                 concepto c
                            INNER JOIN tipoplanilla tp ON tp.id_cia = c.id_cia
                                                          AND tp.swacti = 'S'
                                                          AND tp.tippla NOT IN ( 'X', 'Y', 'Z', 'S' )
                        WHERE
                                c.id_cia = pin_id_cia
                            AND c.codcon = rec_concepto.codcon
                    );

                INSERT INTO concepto_formula (
                    id_cia,
                    codcon,
                    tiptra,
                    tippla,
                    formul,
                    codcta,
                    ctagasto,
                    swacti,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    pin_id_cia,
                    rec_concepto.codcon,
                    'A',
                    'A',
                    rec_concepto.formul,
                    rec_concepto.codcta,
                    rec_concepto.ctagasto,
                    'S',
                    rec_concepto.ucreac,
                    rec_concepto.uactua,
                    current_timestamp,
                    current_timestamp
                );

                IF rec_concepto.fijvar = 'F' THEN
                    pack_hr_personal_concepto.sp_asigna_conceptos_fijos(pin_id_cia, rec_concepto.codcon, extract(YEAR FROM current_timestamp
                    ), extract(MONTH FROM current_timestamp), rec_concepto.ucreac,
                                                                       v_mensaje);

                    m := json_object_t.parse(v_mensaje);
                    IF ( m.get_number('status') <> 1.0 ) THEN
                        pout_mensaje := m.get_string('message');
                        RAISE pkg_exceptionuser.ex_error_inesperado;
                    END IF;

                END IF;

            WHEN 2 THEN
                v_accion := 'La actualización';
--                UPDATE concepto_formula
--                SET
--                    codcta =
--                        CASE
--                            WHEN rec_concepto.codcta IS NULL THEN
--                                codcta
--                            ELSE
--                                rec_concepto.codcta
--                        END,
--                    formul =
--                        CASE
--                            WHEN rec_concepto.formul IS NULL THEN
--                                formul
--                            ELSE
--                                rec_concepto.formul
--                        END,
--                    ctagasto =
--                        CASE
--                            WHEN rec_concepto.ctagasto IS NULL THEN
--                                ctagasto
--                            ELSE
--                                rec_concepto.ctagasto
--                        END,
--                    uactua = rec_concepto.uactua,
--                    factua = current_timestamp
--                WHERE
--                        id_cia = rec_concepto.id_cia
--                    AND codcon = rec_concepto.codcon
--                    AND tiptra = 'A'
--                    AND tippla = 'A';

                UPDATE concepto
                SET
                    empobr =
                        CASE
                            WHEN rec_concepto.empobr IS NULL THEN
                                empobr
                            ELSE
                                rec_concepto.empobr
                        END,
                    ingdes =
                        CASE
                            WHEN rec_concepto.ingdes IS NULL THEN
                                ingdes
                            ELSE
                                rec_concepto.ingdes
                        END,
                    nombre =
                        CASE
                            WHEN rec_concepto.nombre IS NULL THEN
                                nombre
                            ELSE
                                rec_concepto.nombre
                        END,
                    abrevi =
                        CASE
                            WHEN rec_concepto.abrevi IS NULL THEN
                                abrevi
                            ELSE
                                rec_concepto.abrevi
                        END,
                    fijvar =
                        CASE
                            WHEN rec_concepto.fijvar IS NULL THEN
                                fijvar
                            ELSE
                                rec_concepto.fijvar
                        END,
                    codcta =
                        CASE
                            WHEN rec_concepto.codcta IS NULL THEN
                                codcta
                            ELSE
                                rec_concepto.codcta
                        END,
                    formul =
                        CASE
                            WHEN rec_concepto.formul IS NULL THEN
                                formul
                            ELSE
                                rec_concepto.formul
                        END,
                    indprc =
                        CASE
                            WHEN rec_concepto.indprc IS NULL THEN
                                indprc
                            ELSE
                                rec_concepto.indprc
                        END,
                    posimp =
                        CASE
                            WHEN rec_concepto.posimp IS NULL THEN
                                posimp
                            ELSE
                                rec_concepto.posimp
                        END,
                    indimp =
                        CASE
                            WHEN rec_concepto.indimp IS NULL THEN
                                indimp
                            ELSE
                                rec_concepto.indimp
                        END,
                    nomimp =
                        CASE
                            WHEN rec_concepto.nomimp IS NULL THEN
                                nomimp
                            ELSE
                                rec_concepto.nomimp
                        END,
                    nomcts =
                        CASE
                            WHEN rec_concepto.nomcts IS NULL THEN
                                nomcts
                            ELSE
                                rec_concepto.nomcts
                        END,
                    indcts =
                        CASE
                            WHEN rec_concepto.indcts IS NULL THEN
                                indcts
                            ELSE
                                rec_concepto.indcts
                        END,
                    dh =
                        CASE
                            WHEN rec_concepto.dh IS NULL THEN
                                dh
                            ELSE
                                rec_concepto.dh
                        END,
                    agrupa =
                        CASE
                            WHEN rec_concepto.agrupa IS NULL THEN
                                agrupa
                            ELSE
                                rec_concepto.agrupa
                        END,
                    ctagasto =
                        CASE
                            WHEN rec_concepto.ctagasto IS NULL THEN
                                ctagasto
                            ELSE
                                rec_concepto.ctagasto
                        END,
                    conrel =
                        CASE
                            WHEN rec_concepto.conrel IS NULL THEN
                                conrel
                            ELSE
                                rec_concepto.conrel
                        END,
                    tipo =
                        CASE
                            WHEN rec_concepto.tipo IS NULL THEN
                                tipo
                            ELSE
                                rec_concepto.tipo
                        END,
                    nomtipo =
                        CASE
                            WHEN rec_concepto.nomtipo IS NULL THEN
                                nomtipo
                            ELSE
                                rec_concepto.nomtipo
                        END,
                    codpdt =
                        CASE
                            WHEN rec_concepto.codpdt IS NULL THEN
                                codpdt
                            ELSE
                                rec_concepto.codpdt
                        END,
                    idliq =
                        CASE
                            WHEN rec_concepto.idliq IS NULL THEN
                                idliq
                            ELSE
                                rec_concepto.idliq
                        END,
                    swacti =
                        CASE
                            WHEN rec_concepto.swacti IS NULL THEN
                                swacti
                            ELSE
                                rec_concepto.swacti
                        END,
                    uactua =
                        CASE
                            WHEN rec_concepto.uactua IS NULL THEN
                                uactua
                            ELSE
                                rec_concepto.uactua
                        END,
                    factua = TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
             'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_concepto.id_cia
                    AND codcon = rec_concepto.codcon;

            WHEN 3 THEN
                v_accion := 'La eliminación';
                DELETE FROM concepto_clase
                WHERE
                        id_cia = pin_id_cia
                    AND codcon = rec_concepto.codcon;

                DELETE FROM concepto_formula
                WHERE
                        id_cia = pin_id_cia
                    AND codcon = rec_concepto.codcon;

                DELETE FROM tipoplanilla_concepto
                WHERE
                        id_cia = pin_id_cia
                    AND codcon = rec_concepto.codcon;

                DELETE FROM concepto
                WHERE
                        id_cia = rec_concepto.id_cia
                    AND codcon = rec_concepto.codcon;

        END CASE;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE v_accion || ' se realizó satisfactoriamente...!'
            )
        INTO pin_mensaje
        FROM
            dual;

        COMMIT;
    EXCEPTION
        WHEN dup_val_on_index THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE 'El registro con codigo de Concepto [ '
                                    || rec_concepto.codcon
                                    || ' ] ya existe y no puede duplicarse ...!'
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN pkg_exceptionuser.ex_error_inesperado THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE pout_mensaje
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN value_error THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE 'El registro execede el limite permitido por el campo y/o se encuentra en un formato incorrecto'
                )
            INTO pin_mensaje
            FROM
                dual;

        WHEN OTHERS THEN
            IF sqlcode = -2291 THEN
                SELECT
                    JSON_OBJECT(
                        'status' VALUE 1.1,
                        'message' VALUE 'No se puede INSERTAR O MODIFICAR este registro porque el CONCEPTO PDT [ '
                                        || rec_concepto.codpdt
                                        || ' ] o la CUENTA DE GASTO [ '
                                        || rec_concepto.ctagasto
                                        || ' ] NO EXISTE'
                    )
                INTO pin_mensaje
                FROM
                    dual;

            ELSIF sqlcode = -2292 THEN
                SELECT
                    JSON_OBJECT(
                        'status' VALUE 1.1,
                        'message' VALUE 'No se puede ELIMINAR este registro porque TIENE PLANILLAS RELACIONADAS'
                    )
                INTO pin_mensaje
                FROM
                    dual;

            ELSIF sqlcode = -1400 THEN
                SELECT
                    JSON_OBJECT(
                        'status' VALUE 1.1,
                        'message' VALUE 'No se insertar o modificar este registro porque no se han registrado todos los campos obligatorios'
                    )
                INTO pin_mensaje
                FROM
                    dual;

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

            END IF;
    END sp_save;

END;

/

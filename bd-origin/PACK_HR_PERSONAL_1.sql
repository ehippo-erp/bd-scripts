--------------------------------------------------------
--  DDL for Package Body PACK_HR_PERSONAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_HR_PERSONAL" AS

    FUNCTION sp_validaciones (
        pin_id_cia IN NUMBER,
        pin_codper IN VARCHAR2
    ) RETURN datatable_validacion
        PIPELINED
    AS
        rec     datarecord_validacion := datarecord_validacion(NULL, NULL);
        v_count NUMBER;
        v_item  NUMBER := 0;
    BEGIN
        BEGIN
            SELECT
                1 AS count
            INTO v_count
            FROM
                personal_periodo_rpension
            WHERE
                    id_cia = pin_id_cia
                AND codper = pin_codper
            FETCH NEXT 1 ROWS ONLY;

        EXCEPTION
            WHEN no_data_found THEN
                v_item := v_item + 1;
                v_count := 0;
                rec.id := v_item;
                rec.observ := 'El personal no tiene un regimen de pensiones';
                PIPE ROW ( rec );
        END;

        BEGIN
            SELECT
                1 AS count
            INTO v_count
            FROM
                personal_periodolaboral
            WHERE
                    id_cia = pin_id_cia
                AND codper = pin_codper
            FETCH NEXT 1 ROWS ONLY;

        EXCEPTION
            WHEN no_data_found THEN
                v_item := v_item + 1;
                v_count := 0;
                rec.id := v_item;
                rec.observ := 'El personal no tiene un periodo laboral';
                PIPE ROW ( rec );
        END;

        BEGIN
            SELECT
                COUNT(*)
            INTO v_count
            FROM
                personal_documento
            WHERE
                    id_cia = pin_id_cia
                AND codper = pin_codper
                AND situac = 'N';

            IF v_count > 0 THEN
                v_item := v_item + 1;
                rec.id := v_item;
                rec.observ := 'Hay '
                              || v_count
                              || ' documentos obligatorios sin especificacion';
                v_count := 0;
                PIPE ROW ( rec );
            END IF;

        END;

        BEGIN
            SELECT
                COUNT(*)
            INTO v_count
            FROM
                personal_clase
            WHERE
                    id_cia = pin_id_cia
                AND codper = pin_codper
                AND situac = 'N';

            IF v_count > 0 THEN
                v_item := v_item + 1;
                rec.id := v_item;
                rec.observ := 'Hay '
                              || v_count
                              || ' documentos obligatorios sin especificacion';
                v_count := 0;
                PIPE ROW ( rec );
            END IF;

        END;

    END sp_validaciones;

    PROCEDURE sp_update_situacion_validacion (
        pin_id_cia IN NUMBER,
        pin_codper IN VARCHAR2
    ) AS
    BEGIN
        UPDATE personal
        SET
            situac = '04',
            uactua = 'Admin',
            factua = TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
             'YYYY-MM-DD HH24:MI:SS')
        WHERE
                id_cia = pin_id_cia
            AND codper = pin_codper;

        COMMIT;
    END sp_update_situacion_validacion;

    FUNCTION sp_periodolaboral (
        pin_id_cia NUMBER,
        pin_tiptra VARCHAR2,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_periodolaboral
        PIPELINED
    AS
        v_table datatable_periodolaboral;
    BEGIN
        SELECT
            p.id_cia,
            p.codper,
            p.apepat
            || ' '
            || p.apemat
            || ' '
            || p.nombre AS nomper,
            p.tiptra,
            p.situac,
            fs.id_plab,
            trunc(fs.finicio),
            trunc(fs.ffinal),
            trunc(pin_fhasta) - trunc(fs.finicio),
            nvl(fs.ffinal,(fs.finicio + 1000000)) - trunc(pin_fdesde)
        BULK COLLECT
        INTO v_table
        FROM
            personal                p
            LEFT OUTER JOIN personal_periodolaboral fs ON fs.id_cia = p.id_cia
                                                          AND fs.codper = p.codper
        WHERE
                p.id_cia = pin_id_cia
            AND p.tiptra = pin_tiptra;
--            AND ( trunc(pin_fhasta) - trunc(fs.finicio) ) >= 0
--            AND ( trunc(nvl(fs.ffinal,(fs.finicio + 1000000))) - trunc(pin_fdesde) >= 0 );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_periodolaboral;

    FUNCTION sp_ultimo_ingreso (
        pin_id_cia IN NUMBER,
        pin_codper IN VARCHAR2
    ) RETURN NUMBER AS
        v_ultimo_id NUMBER;
    BEGIN
        BEGIN
            SELECT
                id_plab
            INTO v_ultimo_id
            FROM
                personal_periodolaboral
            WHERE
                    id_cia = pin_id_cia
                AND codper = pin_codper
            ORDER BY
                id_plab DESC
            FETCH NEXT 1 ROWS ONLY;

        EXCEPTION
            WHEN no_data_found THEN
                v_ultimo_id := 1;
        END;

        RETURN v_ultimo_id;
    END sp_ultimo_ingreso;

    FUNCTION sp_obtener (
        pin_id_cia IN NUMBER,
        pin_codper IN VARCHAR2
    ) RETURN datatable_personal
        PIPELINED
    AS
        v_table datatable_personal;
    BEGIN
        SELECT
            p.id_cia,
            p.codper,
            pcl.codigo   AS codsunat,
            cpc.descri   AS dessunat,
            p.apepat,
            p.apemat,
            p.nombre,
            p.apepat
            || ' '
            || p.apemat
            || ' '
            || p.nombre  AS nomper,
            p.direcc,
            p.nrotlf,
            p.sexper,
            p.fecnac,
            p.codeci,
            civ.deseci,
            p.tiptra,
            p.codnac,
            n.nombre     AS desnac,
            p.codcar,
            car.nombre   AS descar,
            fi.finicio   AS fecing,
            fs.finicio   AS fecrei,
            fs.ffinal    AS fecces,
            p.forpag,
            p.codban,
            ban.descri   AS desban,
            p.tipcta,
            tcta.descri  AS destcta,
            p.codmon,
            p.nrocta,
            p.situac,
            --sit.nombre   AS situac,
            p.codest,
            est.nombre   AS desest,
            p.glonot,
            p.codafp,
            afp.nombre   AS nomafp,
            p.fotogr,
            p.formato,
            p.codsuc,
            suc.sucursal AS dessuc,
            p.email,
            p.ucreac,
            p.uactua,
            p.fcreac,
            p.factua
        BULK COLLECT
        INTO v_table
        FROM
            personal                p
            LEFT OUTER JOIN estado_civil            civ ON civ.id_cia = p.id_cia
                                                AND civ.codeci = p.codeci
            LEFT OUTER JOIN cargo                   car ON car.id_cia = p.id_cia
                                         AND car.codcar = p.codcar
            LEFT OUTER JOIN estado_personal         est ON est.id_cia = p.id_cia
                                                   AND est.codest = p.codest
            LEFT OUTER JOIN nacionalidad            n ON n.id_cia = p.id_cia
                                              AND n.codnac = p.codnac
            /*LEFT OUTER JOIN situacion_personal sit ON sit.id_cia = p.id_cia
                                                      AND sit.codsit = p.codsit
            */
            LEFT OUTER JOIN afp                     afp ON afp.id_cia = p.id_cia
                                       AND afp.codafp = p.codafp
            LEFT OUTER JOIN sucursal                suc ON suc.id_cia = p.id_cia
                                            AND suc.codsuc = p.codsuc
            LEFT OUTER JOIN e_financiera            ban ON ban.id_cia = p.id_cia
                                                AND ban.codigo = p.codban
            LEFT OUTER JOIN e_financiera_tipo       tcta ON tcta.id_cia = p.id_cia
                                                      AND tcta.tipcta = p.tipcta
            LEFT OUTER JOIN personal_clase          pcl ON pcl.id_cia = p.id_cia -- TODO TRABAJADOR TIENE SI O SI UNA CLASE SUNAT
                                                  AND pcl.codper = p.codper
                                                  AND pcl.clase = 8 -- Clase SUNAT
            LEFT OUTER JOIN clase_codigo_personal   cpc ON cpc.id_cia = p.id_cia
                                                         AND cpc.clase = 8
                                                         AND cpc.codigo = pcl.codigo
            LEFT OUTER JOIN personal_periodolaboral fi ON fi.id_cia = p.id_cia
                                                          AND fi.codper = p.codper
                                                          AND fi.id_plab = 1 -- Primer Ingreso
            LEFT OUTER JOIN personal_periodolaboral fs ON fs.id_cia = p.id_cia
                                                          AND fs.codper = p.codper
                                                          AND fs.id_plab = pack_hr_personal.sp_ultimo_ingreso(p.id_cia, p.codper) -- Ultimo Ingreso
        WHERE
                p.id_cia = pin_id_cia
            AND p.codper = pin_codper;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_obtener;

    FUNCTION sp_buscar_nombre (
        pin_id_cia IN NUMBER,
        pin_nombre IN VARCHAR2
    ) RETURN datatable_personal
        PIPELINED
    AS
        v_table datatable_personal;
    BEGIN
        SELECT
            p.id_cia,
            p.codper,
            pcl.codigo   AS codsunat,
            cpc.descri   AS dessunat,
            p.apepat,
            p.apemat,
            p.nombre,
            p.apepat
            || ' '
            || p.apemat
            || ' '
            || p.nombre  AS nomper,
            p.direcc,
            p.nrotlf,
            p.sexper,
            p.fecnac,
            p.codeci,
            civ.deseci,
            p.tiptra,
            p.codnac,
            n.nombre     AS desnac,
            p.codcar,
            car.nombre   AS descar,
            fi.finicio   AS fecing,
            fs.finicio   AS fecrei,
            fs.ffinal    AS fecces,
            p.forpag,
            p.codban,
            ban.descri   AS desban,
            p.tipcta,
            tcta.descri  AS destcta,
            p.codmon,
            p.nrocta,
            p.situac,
            --sit.nombre   AS situac,
            p.codest,
            est.nombre   AS desest,
            p.glonot,
            p.codafp,
            afp.nombre   AS nomafp,
            p.fotogr,
            p.formato,
            p.codsuc,
            suc.sucursal AS dessuc,
            p.email,
            p.ucreac,
            p.uactua,
            p.fcreac,
            p.factua
        BULK COLLECT
        INTO v_table
        FROM
            personal                p
            LEFT OUTER JOIN estado_civil            civ ON civ.id_cia = p.id_cia
                                                AND civ.codeci = p.codeci
            LEFT OUTER JOIN cargo                   car ON car.id_cia = p.id_cia
                                         AND car.codcar = p.codcar
            LEFT OUTER JOIN estado_personal         est ON est.id_cia = p.id_cia
                                                   AND est.codest = p.codest
            LEFT OUTER JOIN nacionalidad            n ON n.id_cia = p.id_cia
                                              AND n.codnac = p.codnac
            /*LEFT OUTER JOIN situacion_personal sit ON sit.id_cia = p.id_cia
                                                      AND sit.codsit = p.codsit
            */
            LEFT OUTER JOIN afp                     afp ON afp.id_cia = p.id_cia
                                       AND afp.codafp = p.codafp
            LEFT OUTER JOIN sucursal                suc ON suc.id_cia = p.id_cia
                                            AND suc.codsuc = p.codsuc
            LEFT OUTER JOIN e_financiera            ban ON ban.id_cia = p.id_cia
                                                AND ban.codigo = p.codban
            LEFT OUTER JOIN e_financiera_tipo       tcta ON tcta.id_cia = p.id_cia
                                                      AND tcta.tipcta = p.tipcta
            LEFT OUTER JOIN personal_clase          pcl ON pcl.id_cia = p.id_cia -- TODO TRABAJADOR TIENE SI O SI UNA CLASE SUNAT
                                                  AND pcl.codper = p.codper
                                                  AND pcl.clase = 8 -- Clase SUNAT
            LEFT OUTER JOIN clase_codigo_personal   cpc ON cpc.id_cia = p.id_cia
                                                         AND cpc.clase = 8
                                                         AND cpc.codigo = pcl.codigo
            LEFT OUTER JOIN personal_periodolaboral fi ON fi.id_cia = p.id_cia
                                                          AND fi.codper = p.codper
                                                          AND fi.id_plab = 1 -- Primer Ingreso
            LEFT OUTER JOIN personal_periodolaboral fs ON fs.id_cia = p.id_cia
                                                          AND fs.codper = p.codper
                                                          AND fs.id_plab = pack_hr_personal.sp_ultimo_ingreso(p.id_cia, p.codper) -- Primer Ingreso
        WHERE
                p.id_cia = pin_id_cia
            AND (
--            AND ( instr(upper(p.apepat
--                              || ' '
--                              || p.apemat
--                              || ' '
--                              || p.nombre), upper(pin_nombre)) > 0
             ( upper(p.apepat
                          || ' '
                          || p.apemat
                          || ' '
                          || p.nombre) LIKE ( upper('%'
                                                    || pin_nombre
                                                    || '%') ) )
                  OR ( upper(p.nombre
                             || p.apepat
                             || ' '
                             || p.apemat) LIKE ( upper('%'
                                                       || pin_nombre
                                                       || '%') ) ) )
        ORDER BY
            p.apepat ASC;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

    END sp_buscar_nombre;

    FUNCTION sp_buscar (
        pin_id_cia   NUMBER,-- Compania
        pin_situac   VARCHAR2,-- Situacion
        pin_codeci   VARCHAR2,-- Estado Civil
        pin_tiptra   VARCHAR2,-- Tipo Trabajador
        pin_codcar   IN VARCHAR2,-- Cargo
        pin_forpag   VARCHAR2,-- Forma de Pago
        pin_codnac   VARCHAR2,-- Nacionalidad
        pin_codest   VARCHAR2, -- Estado
        pin_codafp   VARCHAR2,-- Regimen Pensionario
        pin_codsuc   NUMBER, -- Sucursal
        pin_codban   NUMBER, -- Codigo de Banco
        pin_codigo   VARCHAR2, -- Codigo de Clase - 8 Sunat 
        pin_criterio NUMBER, -- Selecciona el Criterio de Busqueda de Fecha
        pin_fdesde   DATE,
        pin_fhasta   DATE
    ) RETURN datatable_personal
        PIPELINED
    AS
        v_table datatable_personal;
    BEGIN
        CASE
            WHEN pin_criterio = 0 THEN
                SELECT
                    p.id_cia,
                    p.codper,
                    pcl.codigo   AS codsunat,
                    cpc.descri   AS dessunat,
                    p.apepat,
                    p.apemat,
                    p.nombre,
                    p.apepat
                    || ' '
                    || p.apemat
                    || ' '
                    || p.nombre  AS nomper,
                    p.direcc,
                    p.nrotlf,
                    p.sexper,
                    p.fecnac,
                    p.codeci,
                    civ.deseci,
                    p.tiptra,
                    p.codnac,
                    n.nombre     AS desnac,
                    p.codcar,
                    car.nombre   AS descar,
                    fi.finicio   AS fecing,
                    fs.finicio   AS fecrei,
                    fs.ffinal    AS fecces,
                    p.forpag,
                    p.codban,
                    ban.descri   AS desban,
                    p.tipcta,
                    tcta.descri  AS destcta,
                    p.codmon,
                    p.nrocta,
                    p.situac,
            --sit.nombre   AS situac,
                    p.codest,
                    est.nombre   AS desest,
                    p.glonot,
                    p.codafp,
                    afp.nombre   AS nomafp,
                    p.fotogr,
                    p.formato,
                    p.codsuc,
                    suc.sucursal AS dessuc,
                    p.email,
                    p.ucreac,
                    p.uactua,
                    p.fcreac,
                    p.factua
                BULK COLLECT
                INTO v_table
                FROM
                    personal                p
                    LEFT OUTER JOIN estado_civil            civ ON civ.id_cia = p.id_cia
                                                        AND civ.codeci = p.codeci
                    LEFT OUTER JOIN cargo                   car ON car.id_cia = p.id_cia
                                                 AND car.codcar = p.codcar
                    LEFT OUTER JOIN estado_personal         est ON est.id_cia = p.id_cia
                                                           AND est.codest = p.codest
--                    LEFT OUTER JOIN situacion_personal sit ON sit.id_cia = p.id_cia
--                                                      AND sit.codsit = p.codsit
                    LEFT OUTER JOIN nacionalidad            n ON n.id_cia = p.id_cia
                                                      AND n.codnac = p.codnac
                    LEFT OUTER JOIN afp                     afp ON afp.id_cia = p.id_cia
                                               AND afp.codafp = p.codafp
                    LEFT OUTER JOIN sucursal                suc ON suc.id_cia = p.id_cia
                                                    AND suc.codsuc = p.codsuc
                    LEFT OUTER JOIN e_financiera            ban ON ban.id_cia = p.id_cia
                                                        AND ban.codigo = p.codban
                    LEFT OUTER JOIN e_financiera_tipo       tcta ON tcta.id_cia = p.id_cia
                                                              AND tcta.tipcta = p.tipcta
                    LEFT OUTER JOIN personal_clase          pcl ON pcl.id_cia = p.id_cia -- TODO TRABAJADOR TIENE SI O SI UNA CLASE SUNAT
                                                          AND pcl.codper = p.codper
                                                          AND pcl.clase = 8 -- Clase SUNAT
                    LEFT OUTER JOIN clase_codigo_personal   cpc ON cpc.id_cia = p.id_cia
                                                                 AND cpc.clase = 8
                                                                 AND cpc.codigo = pcl.codigo
                    LEFT OUTER JOIN personal_periodolaboral fi ON fi.id_cia = p.id_cia
                                                                  AND fi.codper = p.codper
                                                                  AND fi.id_plab = 1 -- Primer Ingreso
                    LEFT OUTER JOIN personal_periodolaboral fs ON fs.id_cia = p.id_cia
                                                                  AND fs.codper = p.codper
                                                                  AND fs.id_plab = pack_hr_personal.sp_ultimo_ingreso(p.id_cia, p.codper
                                                                  ) -- Primer Ingreso
                WHERE
                        p.id_cia = pin_id_cia
--                AND ( instr(upper(p.apepat
--                              || ' '
--                              || p.apemat
--                              || ' '
--                              || p.nombre), upper(pin_nombre)) > 0
--                         OR pin_nombre IS NULL )
                    AND ( pin_codigo IS NULL
                          OR pcl.codigo = pin_codigo )
                    AND ( pin_codeci IS NULL
                          OR p.codeci = pin_codeci )
                    AND ( pin_tiptra IS NULL
                          OR p.tiptra = pin_tiptra )
                    AND ( pin_codcar IS NULL
                          OR p.codcar = pin_codcar )
                    AND ( pin_forpag IS NULL
                          OR p.forpag = pin_forpag )
                    AND ( pin_codban IS NULL
                          OR p.codban = pin_codban )
                    AND ( pin_codest IS NULL
                          OR p.codest = pin_codest )
                    AND ( pin_codafp IS NULL
                          OR p.codafp = pin_codafp )
                    AND ( pin_codnac IS NULL
                          OR p.codnac = pin_codnac )
                    AND ( pin_codsuc IS NULL
                          OR pin_codsuc = - 1
                          OR p.codsuc = pin_codsuc )
                    AND ( ( pin_situac IS NULL )
                          OR ( p.situac IN (
                        SELECT
                            *
                        FROM
                            TABLE ( convert_in(pin_situac) )
                    ) ) )
                ORDER BY
                    p.apepat ASC;

                FOR registro IN 1..v_table.count LOOP
                    PIPE ROW ( v_table(registro) );
                END LOOP;

            WHEN pin_criterio = 1 THEN
                SELECT
                    p.id_cia,
                    p.codper,
                    pcl.codigo   AS codsunat,
                    cpc.descri   AS dessunat,
                    p.apepat,
                    p.apemat,
                    p.nombre,
                    p.apepat
                    || ' '
                    || p.apemat
                    || ' '
                    || p.nombre  AS nomper,
                    p.direcc,
                    p.nrotlf,
                    p.sexper,
                    p.fecnac,
                    p.codeci,
                    civ.deseci,
                    p.tiptra,
                    p.codnac,
                    n.nombre     AS desnac,
                    p.codcar,
                    car.nombre   AS descar,
                    fi.finicio   AS fecing,
                    fs.finicio   AS fecrei,
                    fs.ffinal    AS fecces,
                    p.forpag,
                    p.codban,
                    ban.descri   AS desban,
                    p.tipcta,
                    tcta.descri  AS destcta,
                    p.codmon,
                    p.nrocta,
                    p.situac,
            --sit.nombre   AS situac,
                    p.codest,
                    est.nombre   AS desest,
                    p.glonot,
                    p.codafp,
                    afp.nombre   AS nomafp,
                    p.fotogr,
                    p.formato,
                    p.codsuc,
                    suc.sucursal AS dessuc,
                    p.email,
                    p.ucreac,
                    p.uactua,
                    p.fcreac,
                    p.factua
                BULK COLLECT
                INTO v_table
                FROM
                    personal                p
                    LEFT OUTER JOIN estado_civil            civ ON civ.id_cia = p.id_cia
                                                        AND civ.codeci = p.codeci
                    LEFT OUTER JOIN cargo                   car ON car.id_cia = p.id_cia
                                                 AND car.codcar = p.codcar
                    LEFT OUTER JOIN estado_personal         est ON est.id_cia = p.id_cia
                                                           AND est.codest = p.codest
--                    LEFT OUTER JOIN situacion_personal sit ON sit.id_cia = p.id_cia
--                                                      AND sit.codsit = p.codsit
                    LEFT OUTER JOIN nacionalidad            n ON n.id_cia = p.id_cia
                                                      AND n.codnac = p.codnac
                    LEFT OUTER JOIN afp                     afp ON afp.id_cia = p.id_cia
                                               AND afp.codafp = p.codafp
                    LEFT OUTER JOIN sucursal                suc ON suc.id_cia = p.id_cia
                                                    AND suc.codsuc = p.codsuc
                    LEFT OUTER JOIN e_financiera            ban ON ban.id_cia = p.id_cia
                                                        AND ban.codigo = p.codban
                    LEFT OUTER JOIN e_financiera_tipo       tcta ON tcta.id_cia = p.id_cia
                                                              AND tcta.tipcta = p.tipcta
                    LEFT OUTER JOIN personal_clase          pcl ON pcl.id_cia = p.id_cia -- TODO TRABAJADOR TIENE SI O SI UNA CLASE SUNAT
                                                          AND pcl.codper = p.codper
                                                          AND pcl.clase = 8 -- Clase SUNAT
                    LEFT OUTER JOIN clase_codigo_personal   cpc ON cpc.id_cia = p.id_cia
                                                                 AND cpc.clase = 8
                                                                 AND cpc.codigo = pcl.codigo
                    LEFT OUTER JOIN personal_periodolaboral fi ON fi.id_cia = p.id_cia
                                                                  AND fi.codper = p.codper
                                                                  AND fi.id_plab = 1 -- Primer Ingreso
                    LEFT OUTER JOIN personal_periodolaboral fs ON fs.id_cia = p.id_cia
                                                                  AND fs.codper = p.codper
                                                                  AND fs.id_plab = pack_hr_personal.sp_ultimo_ingreso(p.id_cia, p.codper
                                                                  ) -- Primer Ingreso
                WHERE
                        p.id_cia = pin_id_cia
--                AND ( instr(upper(p.apepat
--                              || ' '
--                              || p.apemat
--                              || ' '
--                              || p.nombre), upper(pin_nombre)) > 0
--                         OR pin_nombre IS NULL )
                    AND ( pin_codigo IS NULL
                          OR pcl.codigo = pin_codigo )
                    AND ( pin_codeci IS NULL
                          OR p.codeci = pin_codeci )
                    AND ( pin_tiptra IS NULL
                          OR p.tiptra = pin_tiptra )
                    AND ( pin_codcar IS NULL
                          OR p.codcar = pin_codcar )
                    AND ( pin_forpag IS NULL
                          OR p.forpag = pin_forpag )
                    AND ( pin_codban IS NULL
                          OR p.codban = pin_codban )
                    AND ( pin_codest IS NULL
                          OR p.codest = pin_codest )
                    AND ( pin_codafp IS NULL
                          OR p.codafp = pin_codafp )
                    AND ( pin_codnac IS NULL
                          OR p.codnac = pin_codnac )
                    AND ( pin_codsuc IS NULL
                          OR pin_codsuc = - 1
                          OR p.codsuc = pin_codsuc )
                    AND ( ( pin_situac IS NULL )
                          OR ( p.situac IN (
                        SELECT
                            *
                        FROM
                            TABLE ( convert_in(pin_situac) )
                    ) ) )
                    AND ( ( pin_fdesde IS NULL
                            AND pin_fhasta IS NULL )
                          OR ( fs.finicio BETWEEN pin_fdesde AND pin_fhasta ) )
                ORDER BY
                    p.apepat ASC;

                FOR registro IN 1..v_table.count LOOP
                    PIPE ROW ( v_table(registro) );
                END LOOP;

                RETURN;
            WHEN pin_criterio = 2 THEN
                SELECT
                    p.id_cia,
                    p.codper,
                    pcl.codigo   AS codsunat,
                    cpc.descri   AS dessunat,
                    p.apepat,
                    p.apemat,
                    p.nombre,
                    p.apepat
                    || ' '
                    || p.apemat
                    || ' '
                    || p.nombre  AS nomper,
                    p.direcc,
                    p.nrotlf,
                    p.sexper,
                    p.fecnac,
                    p.codeci,
                    civ.deseci,
                    p.tiptra,
                    p.codnac,
                    n.nombre     AS desnac,
                    p.codcar,
                    car.nombre   AS descar,
                    fi.finicio   AS fecing,
                    fs.finicio   AS fecrei,
                    fs.ffinal    AS fecces,
                    p.forpag,
                    p.codban,
                    ban.descri   AS desban,
                    p.tipcta,
                    tcta.descri  AS destcta,
                    p.codmon,
                    p.nrocta,
                    p.situac,
            --sit.nombre   AS situac,
                    p.codest,
                    est.nombre   AS desest,
                    p.glonot,
                    p.codafp,
                    afp.nombre   AS nomafp,
                    p.fotogr,
                    p.formato,
                    p.codsuc,
                    suc.sucursal AS dessuc,
                    p.email,
                    p.ucreac,
                    p.uactua,
                    p.fcreac,
                    p.factua
                BULK COLLECT
                INTO v_table
                FROM
                    personal                p
                    LEFT OUTER JOIN estado_civil            civ ON civ.id_cia = p.id_cia
                                                        AND civ.codeci = p.codeci
                    LEFT OUTER JOIN cargo                   car ON car.id_cia = p.id_cia
                                                 AND car.codcar = p.codcar
                    LEFT OUTER JOIN estado_personal         est ON est.id_cia = p.id_cia
                                                           AND est.codest = p.codest
                    LEFT OUTER JOIN nacionalidad            n ON n.id_cia = p.id_cia
                                                      AND n.codnac = p.codnac
--                    LEFT OUTER JOIN situacion_personal sit ON sit.id_cia = p.id_cia
--                                                      AND sit.codsit = p.codsit
                    LEFT OUTER JOIN afp                     afp ON afp.id_cia = p.id_cia
                                               AND afp.codafp = p.codafp
                    LEFT OUTER JOIN sucursal                suc ON suc.id_cia = p.id_cia
                                                    AND suc.codsuc = p.codsuc
                    LEFT OUTER JOIN e_financiera            ban ON ban.id_cia = p.id_cia
                                                        AND ban.codigo = p.codban
                    LEFT OUTER JOIN e_financiera_tipo       tcta ON tcta.id_cia = p.id_cia
                                                              AND tcta.tipcta = p.tipcta
                    LEFT OUTER JOIN personal_clase          pcl ON pcl.id_cia = p.id_cia -- TODO TRABAJADOR TIENE SI O SI UNA CLASE SUNAT
                                                          AND pcl.codper = p.codper
                                                          AND pcl.clase = 8 -- Clase SUNAT
                    LEFT OUTER JOIN clase_codigo_personal   cpc ON cpc.id_cia = p.id_cia
                                                                 AND cpc.clase = 8
                                                                 AND cpc.codigo = pcl.codigo
                    LEFT OUTER JOIN personal_periodolaboral fi ON fi.id_cia = p.id_cia
                                                                  AND fi.codper = p.codper
                                                                  AND fi.id_plab = 1 -- Primer Ingreso
                    LEFT OUTER JOIN personal_periodolaboral fs ON fs.id_cia = p.id_cia
                                                                  AND fs.codper = p.codper
                                                                  AND fs.id_plab = pack_hr_personal.sp_ultimo_ingreso(p.id_cia, p.codper
                                                                  ) -- Primer Ingreso
                WHERE
                        p.id_cia = pin_id_cia
--                AND ( instr(upper(p.apepat
--                              || ' '
--                              || p.apemat
--                              || ' '
--                              || p.nombre), upper(pin_nombre)) > 0
--                         OR pin_nombre IS NULL )
                    AND ( pin_codigo IS NULL
                          OR pcl.codigo = pin_codigo )
                    AND ( pin_codeci IS NULL
                          OR p.codeci = pin_codeci )
                    AND ( pin_tiptra IS NULL
                          OR p.tiptra = pin_tiptra )
                    AND ( pin_codcar IS NULL
                          OR p.codcar = pin_codcar )
                    AND ( pin_forpag IS NULL
                          OR p.forpag = pin_forpag )
                    AND ( pin_codban IS NULL
                          OR p.codban = pin_codban )
                    AND ( pin_codest IS NULL
                          OR p.codest = pin_codest )
                    AND ( pin_codafp IS NULL
                          OR p.codafp = pin_codafp )
                    AND ( pin_codnac IS NULL
                          OR p.codnac = pin_codnac )
                    AND ( pin_codsuc IS NULL
                          OR pin_codsuc = - 1
                          OR p.codsuc = pin_codsuc )
                    AND ( ( pin_situac IS NULL )
                          OR ( p.situac IN (
                        SELECT
                            *
                        FROM
                            TABLE ( convert_in(pin_situac) )
                    ) ) )
                    AND ( ( pin_fdesde IS NULL
                            AND pin_fhasta IS NULL )
                          OR ( fs.ffinal BETWEEN pin_fdesde AND pin_fhasta ) )
                ORDER BY
                    p.apepat ASC;

                FOR registro IN 1..v_table.count LOOP
                    PIPE ROW ( v_table(registro) );
                END LOOP;

                RETURN;
            WHEN pin_criterio = 3 THEN
                SELECT
                    p.id_cia,
                    p.codper,
                    pcl.codigo   AS codsunat,
                    cpc.descri   AS dessunat,
                    p.apepat,
                    p.apemat,
                    p.nombre,
                    p.apepat
                    || ' '
                    || p.apemat
                    || ' '
                    || p.nombre  AS nomper,
                    p.direcc,
                    p.nrotlf,
                    p.sexper,
                    p.fecnac,
                    p.codeci,
                    civ.deseci,
                    p.tiptra,
                    p.codnac,
                    n.nombre     AS desnac,
                    p.codcar,
                    car.nombre   AS descar,
                    fi.finicio   AS fecing,
                    fs.finicio   AS fecrei,
                    fs.ffinal    AS fecces,
                    p.forpag,
                    p.codban,
                    ban.descri   AS desban,
                    p.tipcta,
                    tcta.descri  AS destcta,
                    p.codmon,
                    p.nrocta,
                    p.situac,
            --sit.nombre   AS situac,
                    p.codest,
                    est.nombre   AS desest,
                    p.glonot,
                    p.codafp,
                    afp.nombre   AS nomafp,
                    p.fotogr,
                    p.formato,
                    p.codsuc,
                    suc.sucursal AS dessuc,
                    p.email,
                    p.ucreac,
                    p.uactua,
                    p.fcreac,
                    p.factua
                BULK COLLECT
                INTO v_table
                FROM
                    personal                p
                    LEFT OUTER JOIN estado_civil            civ ON civ.id_cia = p.id_cia
                                                        AND civ.codeci = p.codeci
                    LEFT OUTER JOIN cargo                   car ON car.id_cia = p.id_cia
                                                 AND car.codcar = p.codcar
                    LEFT OUTER JOIN estado_personal         est ON est.id_cia = p.id_cia
                                                           AND est.codest = p.codest
                    LEFT OUTER JOIN nacionalidad            n ON n.id_cia = p.id_cia
                                                      AND n.codnac = p.codnac
--                    LEFT OUTER JOIN situacion_personal sit ON sit.id_cia = p.id_cia
--                                                      AND sit.codsit = p.codsit
                    LEFT OUTER JOIN afp                     afp ON afp.id_cia = p.id_cia
                                               AND afp.codafp = p.codafp
                    LEFT OUTER JOIN sucursal                suc ON suc.id_cia = p.id_cia
                                                    AND suc.codsuc = p.codsuc
                    LEFT OUTER JOIN e_financiera            ban ON ban.id_cia = p.id_cia
                                                        AND ban.codigo = p.codban
                    LEFT OUTER JOIN e_financiera_tipo       tcta ON tcta.id_cia = p.id_cia
                                                              AND tcta.tipcta = p.tipcta
                    LEFT OUTER JOIN personal_clase          pcl ON pcl.id_cia = p.id_cia -- TODO TRABAJADOR TIENE SI O SI UNA CLASE SUNAT
                                                          AND pcl.codper = p.codper
                                                          AND pcl.clase = 8 -- Clase SUNAT
                    LEFT OUTER JOIN clase_codigo_personal   cpc ON cpc.id_cia = p.id_cia
                                                                 AND cpc.clase = 8
                                                                 AND cpc.codigo = pcl.codigo
                    LEFT OUTER JOIN personal_periodolaboral fi ON fi.id_cia = p.id_cia
                                                                  AND fi.codper = p.codper
                                                                  AND fi.id_plab = 1 -- Primer Ingreso
                    LEFT OUTER JOIN personal_periodolaboral fs ON fs.id_cia = p.id_cia
                                                                  AND fs.codper = p.codper
                                                                  AND fs.id_plab = pack_hr_personal.sp_ultimo_ingreso(p.id_cia, p.codper
                                                                  ) -- Primer Ingreso
                WHERE
                        p.id_cia = pin_id_cia
--                AND ( instr(upper(p.apepat
--                              || ' '
--                              || p.apemat
--                              || ' '
--                              || p.nombre), upper(pin_nombre)) > 0
--                         OR pin_nombre IS NULL )
                    AND ( pin_codigo IS NULL
                          OR pcl.codigo = pin_codigo )
                    AND ( pin_codeci IS NULL
                          OR p.codeci = pin_codeci )
                    AND ( pin_tiptra IS NULL
                          OR p.tiptra = pin_tiptra )
                    AND ( pin_codcar IS NULL
                          OR p.codcar = pin_codcar )
                    AND ( pin_forpag IS NULL
                          OR p.forpag = pin_forpag )
                    AND ( pin_codban IS NULL
                          OR p.codban = pin_codban )
                    AND ( pin_codest IS NULL
                          OR p.codest = pin_codest )
                    AND ( pin_codafp IS NULL
                          OR p.codafp = pin_codafp )
                    AND ( pin_codnac IS NULL
                          OR p.codnac = pin_codnac )
                    AND ( pin_codsuc IS NULL
                          OR pin_codsuc = - 1
                          OR p.codsuc = pin_codsuc )
                    AND ( ( pin_situac IS NULL )
                          OR ( p.situac IN (
                        SELECT
                            *
                        FROM
                            TABLE ( convert_in(pin_situac) )
                    ) ) )
                    AND ( ( pin_fdesde IS NULL
                            AND pin_fhasta IS NULL )
                          OR ( p.fecnac BETWEEN pin_fdesde AND pin_fhasta ) )
                ORDER BY
                    p.apepat ASC;

                FOR registro IN 1..v_table.count LOOP
                    PIPE ROW ( v_table(registro) );
                END LOOP;

                RETURN;
        END CASE;
    END sp_buscar;

--set SERVEROUTPUT on;
--
--DECLARE
--    mensaje VARCHAR2(500);
--    cadjson VARCHAR2(5000);
--BEGIN
--cadjson := '{
--                "codper":"P002",
--                "apepat":"Calvo",
--                "apemat":"Quispe",
--                "nombre":"Luis Antonio",
--                "direcc":"Lima, Lima, ...",
--                "nrotlf":"999999999",
--                "sexper":"M",
--                "fecnac":"2022-05-22",
--                "codeci":1,
--                "tiptra":"",
--                "codcar":"01",
--                "fecing":"2022-05-22",
--                "fecrei":"2022-05-22",
--                "fecces":"2022-05-22",
--                "forpag":"C",
--                "codban":10,
--                "tipcta":1,
--                "codmon":"PEN",
--                "nrocta":"9999999999",
--                "situac":"01",
--                "codest":"1",
--                "globot":"",
--                "codafp":"01",
--                "fotogr":"",
--                "indreg":"",
--                "inddep":"",
--                "audcre":"",
--                "audmod":"",
--                "formato":"",
--                 "codsuc":1,
--                "email":"luisffffff@fffffff",
--                "ucreac":"Admin",
--                "uactua":"Admin"
--                }';
--pack_hr_personal.sp_save(30, cadjson, 1, mensaje);
--
--dbms_output.put_line(mensaje);
--
--END;
--
--SELECT * FROM pack_hr_personal.sp_obtener(30,'P002');
--
--SELECT * FROM pack_hr_personal.sp_buscar(30,'01,02,03','1',NULL,'01','C',NULL,'1','01',1,NULL,1,
--to_date('01/01/2022','DD/MM/YYYY'),to_date('30/05/2040','DD/MM/YYYY'));

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_codigo  IN VARCHAR2,
        pin_imagen  IN BLOB,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS

        o            json_object_t;
        rec_personal personal%rowtype;
        v_accion     VARCHAR2(50) := '';
        v_nombre     afp.nombre%TYPE;
        v_codcla     afp.codcla%TYPE;
        pout_mensaje VARCHAR2(1000) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_personal.id_cia := pin_id_cia;
        rec_personal.codper := o.get_string('codper');
        rec_personal.apepat := o.get_string('apepat');
        rec_personal.apemat := o.get_string('apemat');
        rec_personal.nombre := o.get_string('nombre');
        rec_personal.direcc := o.get_string('direcc');
        rec_personal.nrotlf := o.get_string('nrotlf');
        rec_personal.sexper := o.get_string('sexper');
        rec_personal.fecnac := o.get_timestamp('fecnac');
        rec_personal.codeci := o.get_string('codeci');
        rec_personal.tiptra := o.get_string('tiptra');
        rec_personal.codnac := o.get_string('codnac');
        rec_personal.codcar := o.get_string('codcar');
        rec_personal.forpag := o.get_string('forpag');
        rec_personal.codban := o.get_number('codban');
        rec_personal.tipcta := o.get_number('tipcta');
        rec_personal.codmon := o.get_string('codmon');
        rec_personal.nrocta := o.get_string('nrocta');
        rec_personal.situac := o.get_string('situac');
        rec_personal.codest := o.get_string('codest');
        rec_personal.glonot := o.get_string('glonot');
        rec_personal.codafp := o.get_string('codafp');
        rec_personal.fotogr := pin_imagen;
        rec_personal.formato := o.get_string('formato');
        rec_personal.codsuc := o.get_number('codsuc');
        rec_personal.email := o.get_string('email');
        rec_personal.ucreac := o.get_string('ucreac');
        rec_personal.uactua := o.get_string('uactua');
        v_accion := '';
        CASE pin_opcdml
            WHEN 1 THEN
                v_accion := 'La grabacion';
                BEGIN
                    SELECT
                        nombre,
                        codcla
                    INTO
                        v_nombre,
                        v_codcla
                    FROM
                        afp
                    WHERE
                            id_cia = pin_id_cia
                        AND codafp = rec_personal.codafp;

                EXCEPTION
                    WHEN no_data_found THEN
                        pout_mensaje := 'La AFP con codigo [ '
                                        || rec_personal.codafp
                                        || ' ] no existe ...!';
                        RAISE pkg_exceptionuser.ex_error_inesperado;
                END;

                INSERT INTO personal (
                    id_cia,
                    codper,
                    apepat,
                    apemat,
                    nombre,
                    direcc,
                    nrotlf,
                    sexper,
                    fecnac,
                    codeci,
                    tiptra,
                    codnac,
                    codcar,
                    forpag,
                    codban,
                    tipcta,
                    codmon,
                    nrocta,
                    situac,
                    codest,
                    glonot,
                    codafp,
                    fotogr,
                    formato,
                    codsuc,
                    email,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    rec_personal.id_cia,
                    rec_personal.codper,
                    rec_personal.apepat,
                    rec_personal.apemat,
                    rec_personal.nombre,
                    rec_personal.direcc,
                    rec_personal.nrotlf,
                    rec_personal.sexper,
                    rec_personal.fecnac,
                    rec_personal.codeci,
                    rec_personal.tiptra,
                    rec_personal.codnac,
                    rec_personal.codcar,
                    rec_personal.forpag,
                    rec_personal.codban,
                    rec_personal.tipcta,
                    rec_personal.codmon,
                    rec_personal.nrocta,
                    rec_personal.situac,
                    rec_personal.codest,
                    rec_personal.glonot,
                    rec_personal.codafp,
                    rec_personal.fotogr,
                    rec_personal.formato,
                    rec_personal.codsuc,
                    rec_personal.email,
                    rec_personal.ucreac,
                    rec_personal.uactua,
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS'),
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS')
                );

                dbms_output.put_line('CLASES OBLIGATORIA');
                -- INSERTANDO LA CLASE REFERENTE AL TIPO DE TRABAJADOR - SUNAT
                BEGIN
                    INSERT INTO personal_clase (
                        id_cia,
                        codper,
                        clase,
                        codigo,
                        situac,
                        ucreac,
                        uactua,
                        fcreac,
                        factua
                    ) VALUES (
                        pin_id_cia,
                        rec_personal.codper,
                        8,
                        pin_codigo,
                        'S',
                        rec_personal.ucreac,
                        rec_personal.uactua,
                        TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                     'YYYY-MM-DD HH24:MI:SS'),
                        TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                     'YYYY-MM-DD HH24:MI:SS')
                    );

                EXCEPTION
                    WHEN OTHERS THEN
                        IF sqlcode = -2291 THEN
                            pout_mensaje := 'La Clase [ 8 - TIPO DE TRABAJADOR PENSIONISTA O PRESTADOR DE SERVICIOS ] con el Codigo [ '
                                            || pin_codigo
                                            || ' - '
                                            || ' ] no existe ...!';
                            RAISE pkg_exceptionuser.ex_error_inesperado;
                        ELSE
                            pout_mensaje := 'mensaje : '
                                            || sqlerrm
                                            || ' codigo :'
                                            || sqlcode;
                            RAISE pkg_exceptionuser.ex_error_inesperado;
                        END IF;
                END;

                BEGIN
                -- INSERTANDO CLASE REFERENTE AL REGIMEN PENSIONARIO
                    INSERT INTO personal_clase (
                        id_cia,
                        codper,
                        clase,
                        codigo,
                        situac,
                        ucreac,
                        uactua,
                        fcreac,
                        factua
                    ) VALUES (
                        pin_id_cia,
                        rec_personal.codper,
                        11,
                        v_codcla,
                        'S',
                        rec_personal.ucreac,
                        rec_personal.uactua,
                        TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                     'YYYY-MM-DD HH24:MI:SS'),
                        TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                     'YYYY-MM-DD HH24:MI:SS')
                    );

                EXCEPTION
                    WHEN OTHERS THEN
                        IF sqlcode = -2291 THEN
                            pout_mensaje := 'La Clase [ 11 - REGIMEN PENSIONARIO ] con el Codigo [ '
                                            || v_codcla
                                            || ' - '
                                            || v_nombre
                                            || ' ] no existe ...!';
                            RAISE pkg_exceptionuser.ex_error_inesperado;
                        ELSE
                            pout_mensaje := 'mensaje : '
                                            || sqlerrm
                                            || ' codigo :'
                                            || sqlcode;
                            RAISE pkg_exceptionuser.ex_error_inesperado;
                        END IF;
                END;

                dbms_output.put_line('DEMAS CLASES OBLIGATORIA');
                -- INSERTANDO LAS DEMAS CLASES OBLIGATORIA
                BEGIN
                    FOR j IN (
                        SELECT
                            clase
                        FROM
                            clase_personal
                        WHERE
                                id_cia = pin_id_cia
                            AND situac = 'S'
                            AND obliga = 'S'
                            AND clase NOT IN ( 8, 11 )
                    ) LOOP
                        INSERT INTO personal_clase (
                            id_cia,
                            codper,
                            clase,
                            codigo,
                            situac,
                            ucreac,
                            uactua,
                            fcreac,
                            factua
                        ) VALUES (
                            pin_id_cia,
                            rec_personal.codper,
                            j.clase,
                            'ND',
                            'N',
                            rec_personal.ucreac,
                            rec_personal.uactua,
                            TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                         'YYYY-MM-DD HH24:MI:SS'),
                            TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                         'YYYY-MM-DD HH24:MI:SS')
                        );

                    END LOOP;
                EXCEPTION
                    WHEN OTHERS THEN
                        IF sqlcode = -2291 THEN
                            pout_mensaje := 'Ocurrio un problema al Registrar las Clases Obligatorias predefinidas en el Sistema, por favor revisar que tengan la clase NO DEFINIDO con codigo ND '
                            ;
                            RAISE pkg_exceptionuser.ex_error_inesperado;
                        ELSE
                            pout_mensaje := 'mensaje : '
                                            || sqlerrm
                                            || ' codigo :'
                                            || sqlcode;
                            RAISE pkg_exceptionuser.ex_error_inesperado;
                        END IF;
                END;

                INSERT INTO personal_periodo_rpension (
                    id_cia,
                    codper,
                    codafp,
                    id_prpen,
                    finicio,
                    ffinal,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    pin_id_cia,
                    rec_personal.codper,
                    rec_personal.codafp,
                    1,
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS'),
                    NULL,
                    rec_personal.ucreac,
                    rec_personal.uactua,
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS'),
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS')
                );

                INSERT INTO personal_periodolaboral (
                    id_cia,
                    id_plab,
                    codper,
                    finicio,
                    ffinal,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    pin_id_cia,
                    1,
                    rec_personal.codper,
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS'),
                    NULL,
                    rec_personal.ucreac,
                    rec_personal.uactua,
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS'),
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS')
                );
                -- INSERTANDO EL DOCUMENTO OBLIGATORIO / DOCUMENTO DE IDENTIDAD

                INSERT INTO personal_documento (
                    id_cia,
                    codper,
                    codtip,
                    codite,
                    nrodoc,
                    clase,
                    codigo,
                    situac,
                    ucreac,
                    uactua,
                    fcreac,
                    factua
                ) VALUES (
                    pin_id_cia,
                    rec_personal.codper,
                    'DO',
                    201,
                    rec_personal.codper,
                    3,
                    '01',
                    'N',
                    rec_personal.ucreac,
                    rec_personal.uactua,
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS'),
                    TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                 'YYYY-MM-DD HH24:MI:SS')
                );
                -- INSERTANDO LOS DEMAS DOCUMENTOS OBLIGAATORIOS / DEFINIDOS EN TABLA TIPOITEM/OBLIGA

                FOR i IN (
                    SELECT
                        codite
                    FROM
                        tipoitem
                    WHERE
                            id_cia = pin_id_cia
                        AND codtip = 'DO'
                        AND obliga = 'S'
                        AND codite <> 201
                ) LOOP
                    INSERT INTO personal_documento (
                        id_cia,
                        codper,
                        codtip,
                        codite,
                        situac,
                        ucreac,
                        uactua,
                        fcreac,
                        factua
                    ) VALUES (
                        pin_id_cia,
                        rec_personal.codper,
                        'DO',
                        i.codite,
                        'N',
                        rec_personal.ucreac,
                        rec_personal.uactua,
                        TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                     'YYYY-MM-DD HH24:MI:SS'),
                        TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                     'YYYY-MM-DD HH24:MI:SS')
                    );

                    COMMIT;
                END LOOP;
                -- INSERTAMOS TODOS LOS CONCEPTOS FIJOS INICIALIZADOS EN 0
                FOR i IN (
                    SELECT
                        c.codcon
                    FROM
                        concepto c
                    WHERE
                            c.id_cia = pin_id_cia
                        AND c.empobr = rec_personal.tiptra
                        AND c.fijvar = 'F'
                ) LOOP
                    INSERT INTO personal_concepto (
                        id_cia,
                        codper,
                        codcon,
                        periodo,
                        mes,
                        valcon,
                        ucreac,
                        uactua,
                        fcreac,
                        factua
                    ) VALUES (
                        pin_id_cia,
                        rec_personal.codper,
                        i.codcon,
                        EXTRACT(YEAR FROM current_timestamp),
                        EXTRACT(MONTH FROM current_timestamp),
                        0,
                        rec_personal.ucreac,
                        rec_personal.uactua,
                        TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                     'YYYY-MM-DD HH24:MI:SS'),
                        TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
                                     'YYYY-MM-DD HH24:MI:SS')
                    );

                    COMMIT;
                END LOOP;

                COMMIT;
            WHEN 2 THEN
                v_accion := 'La actualizacion';
                UPDATE personal
                SET
                    apepat =
                        CASE
                            WHEN rec_personal.apepat IS NULL THEN
                                apepat
                            ELSE
                                rec_personal.apepat
                        END,
                    apemat =
                        CASE
                            WHEN rec_personal.apemat IS NULL THEN
                                apemat
                            ELSE
                                rec_personal.apemat
                        END,
                    nombre =
                        CASE
                            WHEN rec_personal.nombre IS NULL THEN
                                nombre
                            ELSE
                                rec_personal.nombre
                        END,
                    direcc =
                        CASE
                            WHEN rec_personal.direcc IS NULL THEN
                                direcc
                            ELSE
                                rec_personal.direcc
                        END,
                    nrotlf =
                        CASE
                            WHEN rec_personal.nrotlf IS NULL THEN
                                nrotlf
                            ELSE
                                rec_personal.nrotlf
                        END,
                    sexper =
                        CASE
                            WHEN rec_personal.sexper IS NULL THEN
                                sexper
                            ELSE
                                rec_personal.sexper
                        END,
                    fecnac =
                        CASE
                            WHEN rec_personal.fecnac IS NULL THEN
                                fecnac
                            ELSE
                                rec_personal.fecnac
                        END,
                    codeci =
                        CASE
                            WHEN rec_personal.codeci IS NULL THEN
                                codeci
                            ELSE
                                rec_personal.codeci
                        END,
                    tiptra =
                        CASE
                            WHEN rec_personal.tiptra IS NULL THEN
                                tiptra
                            ELSE
                                rec_personal.tiptra
                        END,
                    codnac =
                        CASE
                            WHEN rec_personal.codnac IS NULL THEN
                                codnac
                            ELSE
                                rec_personal.codnac
                        END,
                    codcar =
                        CASE
                            WHEN rec_personal.codcar IS NULL THEN
                                codcar
                            ELSE
                                rec_personal.codcar
                        END,
                    forpag =
                        CASE
                            WHEN rec_personal.forpag IS NULL THEN
                                forpag
                            ELSE
                                rec_personal.forpag
                        END,
                    codban =
                        CASE
                            WHEN rec_personal.codban IS NULL THEN
                                codban
                            ELSE
                                rec_personal.codban
                        END,
                    tipcta =
                        CASE
                            WHEN rec_personal.tipcta IS NULL THEN
                                tipcta
                            ELSE
                                rec_personal.tipcta
                        END,
                    codmon =
                        CASE
                            WHEN rec_personal.codmon IS NULL THEN
                                codmon
                            ELSE
                                rec_personal.codmon
                        END,
                    nrocta =
                        CASE
                            WHEN rec_personal.nrocta IS NULL THEN
                                nrocta
                            ELSE
                                rec_personal.nrocta
                        END,
                    situac =
                        CASE
                            WHEN rec_personal.situac IS NULL THEN
                                situac
                            ELSE
                                rec_personal.situac
                        END,
                    codest =
                        CASE
                            WHEN rec_personal.codest IS NULL THEN
                                codest
                            ELSE
                                rec_personal.codest
                        END,
                    glonot =
                        CASE
                            WHEN rec_personal.glonot IS NULL THEN
                                glonot
                            ELSE
                                rec_personal.glonot
                        END,
--                    codafp =
--                        CASE
--                            WHEN rec_personal.codafp IS NULL THEN
--                                codafp
--                            ELSE
--                                rec_personal.codafp
--                        END,
                    fotogr =
                        CASE
                            WHEN rec_personal.fotogr IS NULL THEN
                                fotogr
                            ELSE
                                rec_personal.fotogr
                        END,
                    formato =
                        CASE
                            WHEN rec_personal.formato IS NULL THEN
                                formato
                            ELSE
                                rec_personal.formato
                        END,
                    codsuc =
                        CASE
                            WHEN rec_personal.codsuc IS NULL THEN
                                codsuc
                            ELSE
                                rec_personal.codsuc
                        END,
                    email =
                        CASE
                            WHEN rec_personal.email IS NULL THEN
                                email
                            ELSE
                                rec_personal.email
                        END,
                    uactua =
                        CASE
                            WHEN rec_personal.uactua IS NULL THEN
                                uactua
                            ELSE
                                rec_personal.uactua
                        END,
                    factua = TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
             'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_personal.id_cia
                    AND codper = rec_personal.codper;

                COMMIT;
            WHEN 3 THEN
                v_accion := 'La eliminacion';
                DELETE FROM personal_turno_planilla
                WHERE
                        id_cia = rec_personal.id_cia
                    AND codper = rec_personal.codper;

                DELETE FROM personal_periodolaboral
                WHERE
                        id_cia = rec_personal.id_cia
                    AND codper = rec_personal.codper;

                DELETE FROM personal_periodo_rpension
                WHERE
                        id_cia = rec_personal.id_cia
                    AND codper = rec_personal.codper;

                DELETE FROM personal_documento
                WHERE
                        id_cia = rec_personal.id_cia
                    AND codper = rec_personal.codper;

                DELETE FROM personal_clase
                WHERE
                        id_cia = rec_personal.id_cia
                    AND codper = rec_personal.codper;

                DELETE FROM personal_legajo
                WHERE
                        id_cia = rec_personal.id_cia
                    AND codper = rec_personal.codper;

                DELETE FROM personal_ccosto
                WHERE
                        id_cia = rec_personal.id_cia
                    AND codper = rec_personal.codper;

                DELETE FROM personal_noafecto
                WHERE
                        id_cia = rec_personal.id_cia
                    AND codper = rec_personal.codper;

                DELETE FROM personal_dependiente
                WHERE
                        id_cia = rec_personal.id_cia
                    AND codper = rec_personal.codper;

                DELETE FROM personal_cts
                WHERE
                        id_cia = rec_personal.id_cia
                    AND codper = rec_personal.codper;

                DELETE FROM personal_concepto
                WHERE
                        id_cia = rec_personal.id_cia
                    AND codper = rec_personal.codper;

                DELETE FROM personal
                WHERE
                        id_cia = rec_personal.id_cia
                    AND codper = rec_personal.codper;

                COMMIT;
        END CASE;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE v_accion || ' se realizo satisfactoriamente...!'
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
        WHEN dup_val_on_index THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE 'El registro con codigo de personal [ '
                                    || rec_personal.codper
                                    || ' ] ya existe y no puede duplicarse ...!'
                )
            INTO pin_mensaje
            FROM
                dual;

            ROLLBACK;
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
        WHEN value_error THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE 'El registro execede el limite permitido por el campo y/o se encuentra en un formato incorrecto'
                )
            INTO pin_mensaje
            FROM
                dual;

            ROLLBACK;
        WHEN OTHERS THEN
            IF sqlcode = -2291 THEN
                SELECT
                    JSON_OBJECT(
                        'status' VALUE 1.1,
                        'message' VALUE 'No se registrar o modificar este registro porque algunas de las dependencia no existe ...! '
                    )
                INTO pin_mensaje
                FROM
                    dual;

                ROLLBACK;
            ELSIF sqlcode = -2292 THEN
                SELECT
                    JSON_OBJECT(
                        'status' VALUE 1.1,
                        'message' VALUE 'No se eliminar el Personal [ '
                                        || rec_personal.codper
                                        || ' ] porque tiene Registros de Asistencia o Planilla generados ...! '
                    )
                INTO pin_mensaje
                FROM
                    dual;

                ROLLBACK;
            ELSE
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
            END IF;
    END sp_save;

    PROCEDURE sp_save_img (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_imagen  IN BLOB,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    ) AS
        o            json_object_t;
        rec_personal personal%rowtype;
        v_accion     VARCHAR2(50) := '';
    BEGIN
        o := json_object_t.parse(pin_datos);
        rec_personal.id_cia := pin_id_cia;
        rec_personal.codper := o.get_string('codper');
        rec_personal.ucreac := o.get_string('ucreac');
        rec_personal.uactua := o.get_string('uactua');
        CASE pin_opcdml
            WHEN 2 THEN
                v_accion := 'La actualizacion';
                UPDATE personal
                SET
                    fotogr = pin_imagen,
                    uactua = rec_personal.uactua,
                    factua = TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
             'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_personal.id_cia
                    AND codper = rec_personal.codper;

            WHEN 3 THEN
                UPDATE personal
                SET
                    fotogr = NULL,
                    uactua =
                        CASE
                            WHEN rec_personal.uactua IS NULL THEN
                                ''
                            ELSE
                                rec_personal.uactua
                        END,
                    factua = TO_TIMESTAMP(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
             'YYYY-MM-DD HH24:MI:SS')
                WHERE
                        id_cia = rec_personal.id_cia
                    AND codper = rec_personal.codper;

            ELSE
                NULL;
        END CASE;

        COMMIT;
        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE v_accion || ' se realizo satisfactoriamente...!'
            )
        INTO pin_mensaje
        FROM
            dual;

    EXCEPTION
        WHEN dup_val_on_index THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE 'El registro con codigo de personal [ '
                                    || rec_personal.codper
                                    || ' ] ya existe y no puede duplicarse ...!'
                )
            INTO pin_mensaje
            FROM
                dual;

--        WHEN value_error THEN
--            SELECT
--                JSON_OBJECT(
--                    'status' VALUE 1.2,
--                    'message' VALUE 'El registro execede el limite permitido por el campo y/o se encuentra en un formato incorrecto'
--                )
--            INTO pin_mensaje
--            FROM
--                dual;

        WHEN OTHERS THEN
            IF sqlcode = -2291 THEN
                SELECT
                    JSON_OBJECT(
                        'status' VALUE 1.1,
                        'message' VALUE 'No se registrar o modificar este registro porque algunas de las dependencia no existe ...! '
                    )
                INTO pin_mensaje
                FROM
                    dual;

            ELSIF sqlcode = -2292 THEN
                SELECT
                    JSON_OBJECT(
                        'status' VALUE 1.1,
                        'message' VALUE 'No se eliminar este registro porque tiene dependencias vigentes ...! '
                    )
                INTO pin_mensaje
                FROM
                    dual;

            ELSE
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

            END IF;
    END sp_save_img;

END pack_hr_personal;

/

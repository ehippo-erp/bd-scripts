--------------------------------------------------------
--  DDL for Function SP_GENERA_NUMDOC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "USR_TSI_SUITE"."SP_GENERA_NUMDOC" (
    pin_id_cia  IN INTEGER,
    pin_tipdoc  IN INTEGER,
    pin_series  IN VARCHAR2,
    pin_periodo IN INTEGER,
    pin_mes     IN INTEGER,
    pin_numdoc  IN INTEGER
) RETURN NUMBER AS

    v_tipinv  INTEGER := 0;
    v_count   INTEGER := 0;
    v_numero  INTEGER := 0;
    v_numdoc  INTEGER := 0;
    v_periodo VARCHAR2(6) := to_char((pin_periodo * 100) + pin_mes);
    v_char    VARCHAR2(6);
BEGIN
/*FORMA DE USO*/
--SELECT sacanumerocompuesto (52,100,'111',2022,1')
--FROM DUAL;

    BEGIN
        SELECT
            tipinv
        INTO v_tipinv
        FROM
            documentos
        WHERE
                id_cia = pin_id_cia
            AND codigo = pin_tipdoc
            AND series = pin_series;

    EXCEPTION
        WHEN no_data_found THEN
            v_tipinv := NULL;
    END;

    IF ( v_tipinv IS NULL ) THEN
        v_tipinv := 0;
    END IF;
    BEGIN
        SELECT
            COUNT(0)
        INTO v_count
        FROM
            documentos
        WHERE
                id_cia = pin_id_cia
            AND codigo = pin_tipdoc
            AND series = pin_series;

    EXCEPTION
        WHEN no_data_found THEN
            v_count := NULL;
    END;

    IF ( v_count IS NULL ) THEN
        v_count := 0;
    END IF;
    IF ( v_count = 0 ) THEN
        v_numdoc := 0;
        RAISE pkg_exceptionuser.ex_error_inesperado;
    END IF;
/*Para las ordenes de produccion utiliza el campo tipinv de docuemtos */

    IF pin_tipdoc = 104 THEN /*104 ordenes de produccion */
        BEGIN
            SELECT
                trunc((MAX(numdoc) / 1))
            INTO v_numero
            FROM
                documentos_cab
            WHERE
                    id_cia = pin_id_cia
                AND tipdoc = pin_tipdoc
                AND series = pin_series
                AND substr(CAST(numdoc AS VARCHAR2(10)),
                           1,
                           7) = v_periodo || to_char(v_tipinv);

        EXCEPTION
            WHEN no_data_found THEN
                v_numero := 0;
        END;
    ELSIF pin_tipdoc = 100 THEN /*COTIZACION*/

        IF nvl(pin_numdoc, 0) = 0 THEN
            BEGIN
                SELECT
                    trunc((MAX(numdoc) / 10))
                INTO v_numero
                FROM
                    documentos_cab
                WHERE
                        id_cia = pin_id_cia
                    AND tipdoc = pin_tipdoc
                    AND series = pin_series
                    AND substr(CAST(numdoc AS VARCHAR2(10)),
                               1,
                               6) = v_periodo;

            EXCEPTION
                WHEN no_data_found THEN
                    v_numero := 0;
            END;

        ELSE
            BEGIN
                SELECT
                    trunc((MAX(numdoc) / 1))
                INTO v_numero
                FROM
                    documentos_cab
                WHERE
                        id_cia = pin_id_cia
                    AND tipdoc = pin_tipdoc
                    AND series = pin_series
                    AND substr(CAST(numdoc AS VARCHAR2(10)),
                               1,
                               9) = substr(CAST(pin_numdoc AS VARCHAR2(10)),
                                           1,
                                           9);

            EXCEPTION
                WHEN no_data_found THEN
                    v_numero := 0;
            END;
        END IF;
    ELSE
        BEGIN
            SELECT
                trunc((MAX(numdoc) / 1))
            INTO v_numero
            FROM
                documentos_cab
            WHERE
                    id_cia = pin_id_cia
                AND tipdoc = pin_tipdoc
                AND series = pin_series
                AND substr(CAST(numdoc AS VARCHAR2(10)),
                           1,
                           6) = v_periodo;

        EXCEPTION
            WHEN no_data_found THEN
                v_numero := 0;
        END;
    END IF;

    IF v_numero IS NULL THEN
        v_numero := 0;
    END IF;
    IF pin_tipdoc = 104 THEN /*104 ordenes de produccion */
        IF ( v_numero = 0 ) THEN
            v_numdoc := TO_NUMBER ( v_periodo
                                    || to_char(v_tipinv)
                                    || sp000_ajusta_string('1', 3, '0', 'R') );

        ELSE
            v_numdoc := v_numero + 1;
        END IF;
    ELSIF pin_tipdoc = 100 THEN /*COTIZACION*/
        IF nvl(pin_numdoc, 0) = 0 THEN
            IF v_numero = 0 THEN
                v_numdoc := TO_NUMBER ( v_periodo
                                        || sp000_ajusta_string('1', 3, '0', 'R')
                                        || '0' );

            ELSE
                v_numdoc := v_numero * 10 + 10;
            END IF;

        ELSE
            v_numdoc := v_numero + 1;
            BEGIN
                BEGIN
                    SELECT
                        'S'
                    INTO v_char
                    FROM
                        documentos_cab
                    WHERE
                            id_cia = pin_id_cia
                        AND tipdoc = pin_tipdoc
                        AND series = pin_series
                        AND numdoc = v_numdoc;
                -- SI EXISTE
                    SELECT
                        sacanumerocompuesto(pin_id_cia, pin_tipdoc, pin_series, pin_periodo, pin_mes) -- SACA POR DEFECTO, LA SIGUIENTE NUMERACION
                    INTO v_numdoc
                    FROM
                        dual;

                EXCEPTION
                    WHEN no_data_found THEN -- NO EXISTE EL NUMDOC, OSEA OKEY
                        v_numdoc := v_numdoc;
                END;

            END;

        END IF;
    ELSE
        IF ( v_numero = 0 ) THEN
            v_numdoc := TO_NUMBER ( v_periodo
                                    || sp000_ajusta_string('1', 4, '0', 'R') );

        ELSE
            v_numdoc := v_numero + 1;
        END IF;
    END IF;

    RETURN v_numdoc;
EXCEPTION
    WHEN pkg_exceptionuser.ex_error_inesperado THEN
        raise_application_error(pkg_exceptionuser.error_inesperado, 'No existe serie '
                                                                    || pin_series
                                                                    || ' del tipo de documento '
                                                                    || pin_tipdoc);
END sp_genera_numdoc;

/

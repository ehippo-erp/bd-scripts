--------------------------------------------------------
--  DDL for Package Body PACK_ACTUALIZA_TIPO_CAMBIO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_ACTUALIZA_TIPO_CAMBIO" AS

    PROCEDURE sp_actualiza (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER,
        pin_mes     NUMBER,
        pin_mensaje OUT VARCHAR2
    ) AS

        CURSOR buscar IS
        (
            SELECT
                *
            FROM
                sp_actualiza_tipo_cambio(pin_id_cia, pin_periodo, pin_mes)
        );

        pout_mensaje VARCHAR2(4000) := '';
        v_procede    VARCHAR2(1);
    BEGIN
        --'Actualizando facturas y boletas en documentos_cab'
        BEGIN
            UPDATE documentos_cab d
            SET
                d.tipcam = (
                    SELECT
                        c.venta
                    FROM
                        tcambio c
                    WHERE
                            c.id_cia = d.id_cia
                        AND c.hmoneda = 'PEN'
                        AND c.moneda = CASE
                                           WHEN d.tipmon <> 'PEN' THEN
                                               d.tipmon
                                           ELSE
                                               'USD'
                                       END
                        AND c.fecha = d.femisi
                )
            WHERE
                    d.id_cia = pin_id_cia
                AND d.tipdoc IN ( 1, 3, 8 )
                AND ( EXTRACT(YEAR FROM d.femisi) = pin_periodo )
                AND ( EXTRACT(MONTH FROM d.femisi) = pin_mes )
                AND ( NOT EXISTS (
                    SELECT
                        numint
                    FROM
                        documentos_cab_factor_tipcam
                    WHERE
                            id_cia = d.id_cia
                        AND numint = d.numint
                ) );

        END;

        --Actualizando facturas y boletas en Ctas.Ctes.
        BEGIN
            UPDATE dcta100 d
            SET
                d.tipcam = (
                    SELECT
                        c.venta
                    FROM
                        tcambio c
                    WHERE
                            c.id_cia = d.id_cia
                        AND c.hmoneda = 'PEN'
                        AND c.moneda = CASE
                                           WHEN d.tipmon <> 'PEN' THEN
                                               d.tipmon
                                           ELSE
                                               'USD'
                                       END
                        AND c.fecha = d.femisi
                )
            WHERE
                    d.id_cia = pin_id_cia
                AND d.tipdoc IN ( 1, 3, 8 )
                AND ( EXTRACT(YEAR FROM d.femisi) = pin_periodo )
                AND ( EXTRACT(MONTH FROM d.femisi) = pin_mes )
                AND ( NOT EXISTS (
                    SELECT
                        numint
                    FROM
                        documentos_cab_factor_tipcam
                    WHERE
                            id_cia = pin_id_cia
                        AND numint = d.numint
                ) );

        END;

        FOR registro IN buscar LOOP

            --- SI EL NUMINT NO EXISTE
            IF registro.numintdc3 IS NULL THEN
--                IF registro.femisiref IS NULL THEN
--                    pin_mensaje := 'LA NOTA DE CREDITO [ '
--                                   || registro.series
--                                   || '-'
--                                   || to_char(registro.numdoc)
--                                   || '-'
--                                   || to_char(registro.femisi, 'DD/MM/YY')
--                                   || ' ] TIENE EL DOCUMENTO DE REFERENCIA [ '
--                                   || registro.seriesref
--                                   || '-'
--                                   || to_char(registro.numdocref)
--                                   || ' ] REGISTRADO SIN UNA FECHA DE EMISION';
--
--                    RAISE pkg_exceptionuser.ex_error_inesperado;
--                END IF;
--
--                IF nvl(registro.venta, 0) <= 0 THEN
--                    pin_mensaje := 'LA NOTA DE CREDITO [ '
--                                   || registro.series
--                                   || '-'
--                                   || to_char(registro.numdoc)
--                                   || '-'
--                                   || to_char(registro.femisi, 'DD/MM/YY')
--                                   || ' ] TIENE EL DOCUMENTO DE REFERENCIA [ '
--                                   || registro.seriesref
--                                   || '-'
--                                   || to_char(registro.numdocref)
--                                   || '-'
--                                   || to_char(registro.femisiref, 'DD/MM/YY')
--                                   || ' ] REGISTRADO CON UN FECHA DE EMISION SIN TIPO DE CAMBIO EN EL SISTEMA';
--
--                    RAISE pkg_exceptionuser.ex_error_inesperado;
--                END IF;

                -- FINALMENTE SI TODO ESTA BIEN, ENTONCES ....
--                UPDATE documentos_cab d
--                SET
--                    d.tipcam = registro.venta
--                WHERE
--                        d.id_cia = registro.id_cia
--                    AND d.numint = registro.numint;
--
--                UPDATE documentos_cab_referencia d
--                SET
--                    d.tipcam = registro.venta
--                WHERE
--                        d.id_cia = registro.id_cia
--                    AND d.numint = registro.numint
--                    AND d.tipdoc = registro.tipdocref
--                    AND d.series = registro.seriesref
--                    AND d.numdoc = registro.numdocref;
--
--                UPDATE dcta100 d
--                SET
--                    d.tipcam = registro.venta
--                WHERE
--                        d.id_cia = registro.id_cia
--                    AND d.numint = registro.numint;
                NULL; -- NO HACER NADA, TEMPORALMENTE
            ELSE
            -- SI EL DOCUMENTO EXISTE
                IF registro.tipdocref IS NULL OR registro.tipdocref NOT IN ( 1, 3 ) THEN
                    pin_mensaje := 'LA NOTA DE CREDITO [ '
                                   || registro.series
                                   || '-'
                                   || to_char(registro.numdoc)
                                   || '-'
                                   || to_char(registro.femisi, 'DD/MM/YY')
                                   || ' ] NO TIENE UN TIPO DE DOCUMENTO DE REFERENCIA VALIDO';

                    RAISE pkg_exceptionuser.ex_error_inesperado;
                END IF;

                IF registro.situacdc3 IN ( 'J', 'K' ) THEN
                    pin_mensaje := 'LA NOTA DE CREDITO [ '
                                   || registro.series
                                   || '-'
                                   || to_char(registro.numdoc)
                                   || '-'
                                   || to_char(registro.femisi, 'DD/MM/YY')
                                   || ' ] TIENE EL DOCUMENTO DE REFERENCIA [ '
                                   || registro.seriesref
                                   || '-'
                                   || to_char(registro.numdocref)
                                   || '-'
                                   || to_char(registro.femisiref, 'DD/MM/YY')
                                   || ' ] ANULADO O ELIMINADO DEL SISTEMA';

                    RAISE pkg_exceptionuser.ex_error_inesperado;
                END IF;

                IF registro.femisiref <> registro.femisidc3 THEN
                    pin_mensaje := 'LA NOTA DE CREDITO [ '
                                   || registro.series
                                   || '-'
                                   || to_char(registro.numdoc)
                                   || '-'
                                   || to_char(registro.femisi, 'DD/MM/YY')
                                   || ' ] TIENE EL DOCUMENTO DE REFERENCIA [ '
                                   || registro.seriesref
                                   || '-'
                                   || to_char(registro.numdocref)
                                   || '-'
                                   || to_char(registro.femisiref, 'DD/MM/YY')
                                   || ' ] REGISTRADO CON UN FECHA DE EMISION DIFERENTE AL SISTEMA [ '
                                   || to_char(registro.femisidc3, 'DD/MM/YY')
                                   || ' ]';

                    RAISE pkg_exceptionuser.ex_error_inesperado;
                END IF;

                IF nvl(registro.tipcamdc3, 0) <= 0 THEN
                    pin_mensaje := 'LA NOTA DE CREDITO [ '
                                   || registro.series
                                   || '-'
                                   || to_char(registro.numdoc)
                                   || '-'
                                   || to_char(registro.femisi, 'DD/MM/YY')
                                   || ' ] TIENE EL DOCUMENTO DE REFERENCIA [ '
                                   || registro.seriesref
                                   || '-'
                                   || to_char(registro.numdocref)
                                   || '-'
                                   || to_char(registro.femisidc3, 'DD/MM/YY')
                                   || ' ] REGISTRADO CON TIPO DE CAMBIO NO VALIDO';

                    RAISE pkg_exceptionuser.ex_error_inesperado;
                END IF;

                -- FINALMENTE SI TODO ESTA BIEN, ENTONCES ....
                UPDATE documentos_cab d
                SET
                    d.tipcam = registro.tipcamdc3
                WHERE
                        d.id_cia = registro.id_cia
                    AND d.numint = registro.numint;

                UPDATE documentos_cab_referencia d
                SET
                    d.tipcam = registro.tipcamdc3
                WHERE
                        d.id_cia = registro.id_cia
                    AND d.numint = registro.numint
                    AND d.tipdoc = registro.tipdocref
                    AND d.series = registro.seriesref
                    AND d.numdoc = registro.numdocref;

                UPDATE dcta100 d
                SET
                    d.tipcam = registro.tipcamdc3
                WHERE
                        d.id_cia = registro.id_cia
                    AND d.numint = registro.numint;

            END IF;
        END LOOP;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE 'El proceso termino exitosamente !'
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
                    'message' VALUE pin_mensaje
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
    END sp_actualiza;

    FUNCTION sp_actualiza_tipo_cambio (
        pin_id_cia  NUMBER,
        pin_periodo NUMBER,
        pin_mes     NUMBER
    ) RETURN datatable_actualiza_tipo_cambio
        PIPELINED
    AS
        v_table datatable_actualiza_tipo_cambio;
    BEGIN
        SELECT
            dc.id_cia,
            dc.numint,
            dc.tipdoc,
            dc.series,
            dc.numdoc,
            dc.femisi,
            dc.razonc,
            dc.tipmon,
            dc.situac,
            drr.tipdoc AS tipdocref,
            drr.series AS seriesref,
            drr.numdoc AS numdocref,
            drr.femisi AS femisiref,
            dc3.numint AS numintdc3,
            dc3.tipdoc AS tipdocdc3,
            dc3.series AS seriesdc3,
            dc3.numdoc AS numdocdc3,
            dc3.femisi AS femisidc3,
            dc3.situac AS situacdc3,
            dc3.tipmon AS tipmondc3,
            dc3.tipcam AS tipcamdc3,
            tcc.venta
        BULK COLLECT
        INTO v_table
        FROM
            documentos_cab            dc
            LEFT OUTER JOIN documentos_cab_referencia drr ON drr.id_cia = dc.id_cia
                                                             AND drr.numint = dc.numint
            LEFT OUTER JOIN tcambio                   tcc ON tcc.id_cia = dc.id_cia
                                           AND tcc.hmoneda = 'PEN'
                                           AND tcc.fecha = drr.femisi
                                           AND tcc.moneda = 'USD'
            LEFT OUTER JOIN documentos_cab            dc3 ON dc3.id_cia = dc.id_cia
                                                  AND dc3.tipdoc = drr.tipdoc
                                                  AND dc3.series = drr.series
                                                  AND dc3.numdoc = drr.numdoc
        WHERE
                dc.id_cia = pin_id_cia
            AND dc.tipdoc = 7
            AND dc.situac IN ( 'C', 'F' )
            AND ( EXTRACT(YEAR FROM dc.femisi) = pin_periodo )
            AND ( EXTRACT(MONTH FROM dc.femisi) = pin_mes );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_actualiza_tipo_cambio;

END;

/

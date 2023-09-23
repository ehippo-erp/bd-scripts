--------------------------------------------------------
--  DDL for Package Body PACK_REGISTRO_COMPRAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_REGISTRO_COMPRAS" AS

    FUNCTION existe_compr010 (
        pin_id_cia IN NUMBER,
        pin_tipo   IN NUMBER,
        pin_docume IN NUMBER
    ) RETURN INTEGER AS
        v_count    INTEGER := 0;
        v_response INTEGER := 0; -- 0 : false, 1 : true
    BEGIN
        BEGIN
            SELECT
                COUNT(c.docume)
            INTO v_count
            FROM
                compr010 c
            WHERE
                    c.id_cia = pin_id_cia
                AND c.tipo = pin_tipo
                AND c.docume = pin_docume;

        EXCEPTION
            WHEN no_data_found THEN
                v_count := NULL;
        END;

        IF ( ( v_count IS NULL ) OR ( v_count = 0 ) ) THEN
            v_response := 0;
        ELSE
            v_response := 1;
        END IF;

        RETURN v_response;
    END existe_compr010;

    FUNCTION existe_registros_relacionados_prov101 (
        pin_id_cia IN NUMBER,
        pin_tipo   IN NUMBER,
        pin_docume IN NUMBER
    ) RETURN VARCHAR2 AS

        v_count    INTEGER := 0;
        v_response VARCHAR2(5000) := '';-- '' - False, 'Algun mensaje ...' - True
        v_aux      VARCHAR2(30);
        CURSOR c_registro IS
        SELECT
            p.libro,
            p.periodo,
            p.mes,
            p.secuencia
        FROM
            prov101 p
        WHERE
                p.id_cia = pin_id_cia
            AND p.tipo = pin_tipo
            AND p.docu = pin_docume;

    BEGIN
        BEGIN
            SELECT
                COUNT(p.docu)
            INTO v_count
            FROM
                prov101 p
            WHERE
                    p.id_cia = pin_id_cia
                AND p.tipo = pin_tipo
                AND p.docu = pin_docume;

        EXCEPTION
            WHEN no_data_found THEN
                v_count := NULL;
        END;

        IF ( ( v_count IS NULL ) OR ( v_count = 0 ) ) THEN
            v_response := '';
        ELSE
            FOR reg IN c_registro LOOP
                v_aux := '[ '
                         || reg.libro
                         || '-'
                         || to_char(reg.periodo)
                         || '-'
                         || to_char(reg.mes)
                         || '-'
                         || to_char(reg.secuencia)
                         || ' ] , ';

                v_response := v_response || v_aux;
            END LOOP;
        END IF;

        v_response := substr(v_response, 0, length(v_response) - 2);
        RETURN v_response;
    END existe_registros_relacionados_prov101;

    PROCEDURE eliminar_movimientos (
        pin_id_cia  IN NUMBER,
        pin_periodo IN NUMBER,
        pin_mes     IN NUMBER,
        pin_libro   IN VARCHAR2,
        pin_asiento IN NUMBER
    ) AS
    BEGIN
        DELETE FROM movimientos
        WHERE
                id_cia = pin_id_cia
            AND periodo = pin_periodo
            AND mes = pin_mes
            AND libro = pin_libro
            AND asiento = pin_asiento;

        DELETE FROM asiendet
        WHERE
                id_cia = pin_id_cia
            AND periodo = pin_periodo
            AND mes = pin_mes
            AND libro = pin_libro
            AND asiento = pin_asiento;

    END eliminar_movimientos;

    PROCEDURE actualizar_asienhea (
        pin_id_cia  IN NUMBER,
        pin_periodo IN NUMBER,
        pin_mes     IN NUMBER,
        pin_libro   IN VARCHAR2,
        pin_asiento IN NUMBER,
        pin_situac  IN NUMBER,
        pin_usuari  IN VARCHAR2
    ) AS
    BEGIN
        UPDATE asienhea
        SET
            situac =
                CASE
                    WHEN situac IS NOT NULL THEN
                        pin_situac
                    ELSE
                        situac
                END,
            factua =
                CASE
                    WHEN factua IS NOT NULL THEN
                        sysdate
                    ELSE
                        factua
                END,
            usuari =
                CASE
                    WHEN usuari IS NOT NULL THEN
                        pin_usuari
                    ELSE
                        usuari
                END
        WHERE
                id_cia = pin_id_cia
            AND periodo = pin_periodo
            AND mes = pin_mes
            AND libro = pin_libro
            AND asiento = pin_asiento;

    END actualizar_asienhea;

    PROCEDURE actualizar_situacion (
        pin_id_cia IN NUMBER,
        pin_tipo   IN NUMBER,
        pin_docume IN NUMBER,
        pin_situac IN NUMBER
    ) AS
    BEGIN
        UPDATE compr010
        SET
            situac = pin_situac
        WHERE
                id_cia = pin_id_cia
            AND tipo = pin_tipo
            AND docume = pin_docume;

    END actualizar_situacion;

    PROCEDURE sp_descontabilizar (
        pin_id_cia  IN NUMBER,
        pin_tipo    IN NUMBER,
        pin_docume  IN NUMBER,
        pin_estado  OUT NUMBER,
        pin_mensaje OUT VARCHAR2
    ) AS

        v_id_cia       NUMBER;
        v_libro        VARCHAR2(20);
        v_periodo      NUMBER;
        v_mes          NUMBER;
        v_asiento      NUMBER;
        v_situac       NUMBER;
        v_usuari       VARCHAR2(10);
        v_condicional  VARCHAR2(5000);
        v_condicional2 VARCHAR2(5000);
    BEGIN
        v_condicional := NULL;
        v_condicional2 := NULL;
        -- VALIDA SI EXISTE EL DOCUMENTO
        IF existe_compr010(pin_id_cia, pin_tipo, pin_docume) = 0 THEN
            pin_mensaje := 'No existe ningun documento valido con el identificador [ Tipo :  '
                           || to_char(pin_tipo)
                           || ' ] y [ Docume : '
                           || to_char(pin_docume)
                           || ' ]';

            pin_estado := 1.1;
        ELSE
            --LIBRO, PERIODO, MES, ASIENTO, SITUAC

            SELECT
                libro,
                periodo,
                mes,
                asiento,
                situac,
                usuari
            INTO
                v_libro,
                v_periodo,
                v_mes,
                v_asiento,
                v_situac,
                v_usuari
            FROM
                compr010
            WHERE
                    id_cia = pin_id_cia
                AND tipo = pin_tipo
                AND docume = pin_docume;

            -- VALIDA SI HAY MOVIMIENTOS RELACIONADOS
            v_condicional := sp_valida_movimientos_relacion(pin_id_cia, v_libro, v_periodo, v_mes, v_asiento);
            IF ( ( v_condicional IS NOT NULL ) OR ( v_condicional <> '' ) ) THEN
                pin_mensaje := v_condicional;
                pin_estado := 1.1;
            ELSE
                -- VALIDA SI HAY REGISTROS DE PAGOS RELACIONADOS EN PROV101
                v_condicional2 := existe_registros_relacionados_prov101(pin_id_cia, pin_tipo, pin_docume);
                IF ( ( v_condicional2 IS NOT NULL ) OR ( v_condicional2 <> '' ) ) THEN
                    pin_mensaje := 'No se puede descontabilizar ...!, Existe documentos de pago relacionados : ' || v_condicional2;
                    pin_estado := 1.1;
                ELSE
                    -- DE ESTAR TODO BIEN, EJECUTA ....
                    eliminar_movimientos(pin_id_cia, v_periodo, v_mes, v_libro, v_asiento);
                    actualizar_asienhea(pin_id_cia, v_periodo, v_mes, v_libro, v_asiento,
                                       v_situac, v_usuari);
                    actualizar_situacion(pin_id_cia, pin_tipo, pin_docume, 1);
                    COMMIT;
                    pin_mensaje := 'Success, Documento descontabilizado [ Tipo :  '
                                   || to_char(pin_tipo)
                                   || '
            ] y [ Docume : '
                                   || to_char(pin_docume)
                                   || ' ]';

                    pin_estado := 1.0;
                END IF;

            END IF;

        END IF;

    END sp_descontabilizar;

END pack_registro_compras;

/

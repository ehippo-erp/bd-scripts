--------------------------------------------------------
--  DDL for Package Body PACK_DCTA102_CAJA_CAB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_DCTA102_CAJA_CAB" AS

    PROCEDURE sp_apertura (
        pin_id_cia  IN NUMBER,
        pin_numcaja IN NUMBER,
        pin_mensaje OUT VARCHAR2
    ) AS
        v_response VARCHAR2(120) := '';
    BEGIN
        UPDATE dcta102_caja_cab
        SET
            situac = 0,
            ftermino = current_timestamp,
            factua = current_timestamp
        WHERE
                id_cia = pin_id_cia
            AND numcaja = pin_numcaja;

        pin_mensaje := 'Se completó el proceso';
    END sp_apertura;

    PROCEDURE sp_cierre (
        pin_id_cia  IN NUMBER,
        pin_numcaja IN NUMBER,
        pin_mensaje OUT VARCHAR2
    ) AS
        v_response VARCHAR2(120) := '';
    BEGIN
        UPDATE dcta102_caja_cab
        SET
            situac = 2,
            ftermino = current_timestamp,
            factua = current_timestamp
        WHERE
                id_cia = pin_id_cia
            AND numcaja = pin_numcaja;

        pin_mensaje := 'Se completó el proceso';
    END sp_cierre;

    FUNCTION detalles_caja (
        pin_id_cia  IN NUMBER,
        pin_numcaja IN NUMBER
    ) RETURN tbl_detalles_caja
        PIPELINED
    AS

        r_detalles_dcta102_caja rec_detalles_caja := rec_detalles_caja(NULL, NULL, NULL, NULL, NULL,
                                                                      NULL, NULL, NULL, NULL, NULL);
        CURSOR cur_select IS
        SELECT
            p.periodo,
            p.mes,
            p.libro,
            p.secuencia,
            p.concep,
            upper(p.situac) AS situac,
            l.descri        AS deslibro,
            SUM(d.pagomn)   AS pagomn,
            SUM(d.pagome)   AS pagome
        FROM
            dcta102 p
            LEFT OUTER JOIN tlibro  l ON l.id_cia = p.id_cia
                                        AND l.codlib = p.libro
            LEFT OUTER JOIN dcta103 d ON d.id_cia = p.id_cia
                                         AND d.periodo = p.periodo
                                         AND d.mes = p.mes
                                         AND d.libro = p.libro
                                         AND d.secuencia = p.secuencia
                                         AND NOT ( d.situac IN ( 'K' ) )
        WHERE
                p.id_cia = pin_id_cia
            AND p.numcaja = pin_numcaja
            AND NOT ( p.situac IN ( 'K' ) )
        GROUP BY
            p.periodo,
            p.mes,
            p.libro,
            p.secuencia,
            p.concep,
            p.situac,
            l.descri;

    BEGIN
        FOR registro IN cur_select LOOP
            r_detalles_dcta102_caja.libro := registro.libro;
            r_detalles_dcta102_caja.deslibro := registro.deslibro;
            r_detalles_dcta102_caja.periodo := registro.periodo;
            r_detalles_dcta102_caja.mes := registro.mes;
            r_detalles_dcta102_caja.secuencia := registro.secuencia;
            r_detalles_dcta102_caja.concep := registro.concep;
            r_detalles_dcta102_caja.situac := registro.situac;
            r_detalles_dcta102_caja.dessituac := '**';
            r_detalles_dcta102_caja.pagomn := registro.pagomn;
            r_detalles_dcta102_caja.pagome := registro.pagome;
            IF ( registro.situac = 'A' ) THEN
                r_detalles_dcta102_caja.dessituac := 'EMITIDO';
            END IF;

            IF ( registro.situac = 'B' ) THEN
                r_detalles_dcta102_caja.dessituac := 'APROBADO';
            END IF;

            IF ( registro.situac = 'J' ) THEN
                r_detalles_dcta102_caja.dessituac := 'ANULADO';
            END IF;

            PIPE ROW ( r_detalles_dcta102_caja );
        END LOOP;
    END detalles_caja;

    FUNCTION sp_chequea_caja_usuario (
        pin_id_cia  IN NUMBER,
        pin_codsuc  IN NUMBER,
        pin_femisi  IN DATE,
        pin_coduser IN VARCHAR2
    ) RETURN tblresponse
        PIPELINED
    AS

        rec                              objresponse;
        v_usodecaja49                    VARCHAR2(1);
        v_cobradorpredeterminado63       VARCHAR2(1);
        v_codigocobradorpredeterminado63 VARCHAR2(100);
        v_caja                           NUMBER;
        v_response                       VARCHAR2(1200);
    BEGIN
        DECLARE BEGIN
            SELECT
                swflag
            INTO v_usodecaja49
            FROM
                usuarios_propiedades
            WHERE
                    id_cia = pin_id_cia
                AND coduser = pin_coduser
                AND codigo = 49;

        EXCEPTION
            WHEN no_data_found THEN
                v_usodecaja49 := NULL;
        END;

        IF v_usodecaja49 IS NULL OR v_usodecaja49 = 'N' THEN
            v_response := ' Usuario no tiene configurado la propiedad [ 49 - Usar caja de venta ]. <br>';
        END IF;
        DECLARE BEGIN
            SELECT
                swflag,
                vstring
            INTO
                v_cobradorpredeterminado63,
                v_codigocobradorpredeterminado63
            FROM
                usuarios_propiedades
            WHERE
                    id_cia = pin_id_cia
                AND coduser = pin_coduser
                AND codigo = 63;

        EXCEPTION
            WHEN no_data_found THEN
                v_cobradorpredeterminado63 := NULL;
        END;

        IF v_cobradorpredeterminado63 IS NULL OR v_cobradorpredeterminado63 = 'N' THEN
            v_response := v_response || ' Usuario no tiene configurado la propiedad [ 63 - Cobrador predeterminado ]. <br>';
        END IF;

        IF v_codigocobradorpredeterminado63 IS NULL OR length(v_codigocobradorpredeterminado63) = 0 THEN
            v_response := v_response || ' Usuario no tiene configurado la propiedad [ 63 - Código cobrador predeterminado ]. <br>';
        END IF;

        DECLARE BEGIN
            SELECT
                situac
            INTO v_caja
            FROM
                dcta102_caja_cab
            WHERE
                    id_cia = pin_id_cia
                AND coduser = pin_coduser
                AND codsuc = pin_codsuc
                AND finicio = pin_femisi
                AND situac = 0; -- EMITIDA

        EXCEPTION
            WHEN no_data_found THEN
                v_caja := NULL;
            WHEN too_many_rows THEN
                v_response := v_response || ' El usuario tiene mas de una caja EMITIDA asignada ...';
                 
        END;

        IF v_caja IS NULL THEN
            v_response := v_response || ' No existe caja asignada al usuario... o se encuentra cerrada ...! <br>';
        ELSIF v_caja = 2 THEN
            v_response := v_response || ' Caja asignada del día se encuentra cerrada. ';
            -- NULL
        END IF;

        IF v_response IS NOT NULL OR length(v_response) > 0 THEN
            rec.codigo := '1.1';
            rec.descripcion := v_response;
        ELSE
            rec.codigo := '1.0';
            rec.descripcion := 'Success';
        END IF;

        PIPE ROW ( rec );
    END sp_chequea_caja_usuario;

END pack_dcta102_caja_cab;

/

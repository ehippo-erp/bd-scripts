--------------------------------------------------------
--  DDL for Package Body PACK_ASIENTO_COSTO_VENTA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_ASIENTO_COSTO_VENTA" AS

    PROCEDURE sp_genera_asiento (
        pin_id_cia    IN NUMBER,
        pin_periodo   IN NUMBER,
        pin_mes       IN NUMBER,
        pin_libro     IN VARCHAR2,
        pin_femisi    IN DATE,
        pin_secuencia IN NUMBER,
        pin_cuenta    IN VARCHAR2,
        pin_moneda    IN VARCHAR2,
        pin_saldo01   IN NUMBER,
        pin_saldo02   IN NUMBER,
        pin_dh        IN VARCHAR2,
        pin_item      IN OUT INTEGER,
        pin_concep    IN VARCHAR2,
        pin_coduser   IN VARCHAR2
    ) AS

        v_dh      VARCHAR2(1);
        v_importe NUMBER(16, 2) := 0;
        v_impor01 NUMBER(16, 2) := 0;
        v_impor02 NUMBER(16, 2) := 0;
        v_debe    NUMBER(16, 2) := 0;
        v_haber   NUMBER(16, 2) := 0;
        v_debe01  NUMBER(16, 2) := 0;
        v_haber01 NUMBER(16, 2) := 0;
        v_debe02  NUMBER(16, 2) := 0;
        v_haber02 NUMBER(16, 2) := 0;
        v_tcamb01 NUMBER(16, 6) := 0;
        v_tcamb02 NUMBER(16, 6) := 0;
    BEGIN

    -- Pin_Moneda siempre deberia ser 'PEN'
        IF pin_moneda = 'PEN' THEN
            v_importe := pin_saldo01;
            v_impor01 := pin_saldo01;-- Saldo en Soles
            v_impor02 := pin_saldo02;-- Saldo en Dolares
        END IF;

        IF pin_moneda = 'PEN' THEN
            IF pin_dh = 'H' THEN
                v_dh := 'H';
                v_haber := v_importe;
                v_haber01 := v_impor01;
                v_haber02 := v_impor02;
            ELSIF pin_dh = 'D' THEN
                IF
                    v_impor01 < 0
                    AND v_impor02 < 0
                THEN -- Si es negativo se va al HABER
                    v_dh := 'H';
                    v_haber := v_importe;
                    v_haber01 := v_impor01;
                    v_haber02 := v_impor02;
                ELSE
                    v_dh := 'D';
                    v_debe := v_importe;
                    v_debe01 := v_impor01;
                    v_debe02 := v_impor02;
                END IF;
            END IF;

        END IF;

        IF pin_moneda = 'PEN' THEN
            v_tcamb01 := 1;
            IF v_impor01 <> 0 THEN
                v_tcamb02 := v_impor02 / v_impor01;
            ELSE
                v_tcamb02 := 0;
            END IF;

        END IF;

        pin_item := pin_item + 1;
        INSERT INTO asiendet (
            id_cia,--01
            periodo,--02
            mes,--03
            libro,--04
            asiento,--05
            item,--06
            sitem,--07
            concep,--08
            fecha,--09
            tasien,--10
            topera,--11
            cuenta,--12
            dh,--13
            moneda,--14
            importe,--15
            impor01,--16
            impor02,--17
            debe,--18
            debe01,--19
            debe02,--20
            haber,--21
            haber01,--22
            haber02,--23
            tcambio01,--24
            tcambio02,--25
            ccosto,--26
            proyec,--27
            subcco,--28
            ctaalternativa,--29
            tipo,--30
            docume,--31
            codigo,--32
            razon,--33
            tident,--34
            dident,--35
            tdocum,--36
            serie,--37
            numero,--38
            fdocum,--39
            usuari,--40
            fcreac,--41
            factua,--42
            regcomcol,--43
            swprovicion,--44
            saldo,--45
            swgasoper,--46
            codporret,--47
            swchkconcilia--48
        ) VALUES (
            pin_id_cia,
            pin_periodo,
            pin_mes,
            '79',
            pin_secuencia,
            pin_item,
            0,
            pin_concep,
            pin_femisi,
            66,
            '',
            pin_cuenta,
            v_dh,
            pin_moneda,
            abs(v_importe),
            abs(v_impor01),
            abs(v_impor02),
            v_debe,
            v_debe01,
            v_debe02,
            v_haber,
            v_haber01,
            v_haber02,
            v_tcamb01,
            v_tcamb02,
            '',
            '',
            '',
            '',
            0,
            - 1,
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            NULL,
            pin_coduser,
            current_timestamp,
            current_timestamp,
            0,
            '',
            abs(v_importe),
            0,
            '',
            ''
        );

        COMMIT;
    END sp_genera_asiento;

    PROCEDURE sp_genera (
        pin_id_cia   IN NUMBER,
        pin_tipinv   IN NUMBER,
        pin_periodo  IN NUMBER,
        pin_mes      IN NUMBER,
        pin_coduser  IN VARCHAR2,
        pout_message OUT VARCHAR2
    ) AS

        v_asiento      NUMBER;
        v_finicio      DATE;
        v_ffinal       DATE;
        v_fechaasiento DATE;
        v_moneda01     VARCHAR2(3);
        v_moneda02     VARCHAR2(3);
        v_count        NUMBER;
        v_item         NUMBER;
        v_msj          VARCHAR2(1000);
        v_compra       NUMBER(16, 2) := 0;
        v_venta        NUMBER(16, 2) := 0;
        o              json_object_t;
        v_proceso      NUMBER := 0;
        v_concepto     VARCHAR2(1000) := '';
        v_sinregistro  NUMBER := 0;
        pout_mensaje   VARCHAR2(1000) := '';
    BEGIN
        dbms_output.put_line('ELIMINANDO MOVIMIENTOS');
        DELETE FROM movimientos
        WHERE
                id_cia = pin_id_cia
            AND periodo = pin_periodo
            AND mes = pin_mes
            AND libro = '79';

        dbms_output.put_line('ELIMINANDO ASIENTDET');
        COMMIT;
        DELETE FROM asiendet
        WHERE
                id_cia = pin_id_cia
            AND periodo = pin_periodo
            AND mes = pin_mes
            AND libro = '79';

        dbms_output.put_line('ELIMINANDO ASIENTHEA');
        COMMIT;
        DELETE FROM asienhea
        WHERE
                id_cia = pin_id_cia
            AND periodo = pin_periodo
            AND mes = pin_mes
            AND libro = '79';

        COMMIT;
        dbms_output.put_line('ASIGNANDO FECHAS');
        v_asiento := 1;
        v_ffinal := last_day(trunc(to_date(to_char('01'
                                                   || '/'
                                                   || pin_mes
                                                   || '/'
                                                   || pin_periodo), 'DD/MM/YYYY')));

        v_finicio := to_date(to_char('01'
                                     || '/'
                                     || pin_mes
                                     || '/'
                                     || pin_periodo), 'DD/MM/YYYY');

        v_fechaasiento := v_ffinal;

--        BEGIN
--            SELECT
--                moneda01,
--                moneda02
--            INTO
--                v_moneda01,
--                v_moneda02
--            FROM
--                companias
--            WHERE
--                cia = pin_id_cia;
--
--        EXCEPTION
--            WHEN no_data_found THEN
--                v_moneda01 := '';
--                v_moneda02 := '';
--        END;
--      FRANK - POR DEFECTO PEN

        dbms_output.put_line('ASIGNANDO MONEDA');
        v_moneda01 := 'PEN';
        v_moneda02 := 'USD';
--        BEGIN
--            SELECT
--                COUNT(*)
--            INTO v_count
--            FROM
--                tcambio
--            WHERE
--                    id_cia = pin_id_cia
--                AND fecha = v_fechaasiento
--                AND moneda = v_moneda01--'PEN'
--                AND hmoneda = v_moneda02;
--        EXCEPTION
--            WHEN no_data_found THEN
--                v_count := 0;
--        END;

        dbms_output.put_line('ASIGNANDO TIPO DE CAMBIO');
        BEGIN
            SELECT
                round(compra, 2),
                round(venta, 2)
            INTO
                v_compra,
                v_venta
            FROM
                tcambio
            WHERE
                    id_cia = pin_id_cia
                AND fecha = v_fechaasiento
                AND moneda = v_moneda01--'PEN'
                AND hmoneda = v_moneda02;--'USD'

        EXCEPTION
            WHEN no_data_found THEN
                pout_message := 'No existe tipo de cambio para la fecha ' || to_char(v_fechaasiento, 'DD/MM/YYYY');
                RAISE pkg_exceptionuser.ex_tcambio_no_existe;
            WHEN too_many_rows THEN
                pout_message := 'Existe mas de un tipo de cambio para la fecha ' || to_char(v_fechaasiento, 'DD/MM/YYYY');
                RAISE pkg_exceptionuser.ex_tcambio_no_existe;
        END;

        dbms_output.put_line('CREANDO ASIENTO');
        FOR rti IN (
            SELECT
                *
            FROM
                t_inventario
            WHERE
                    id_cia = pin_id_cia
                AND tipinv IN ( 1, 2, 3 )
        ) LOOP
            v_concepto := 'ASIENTO DE COSTO DE VENTA - ' || rti.dtipinv;
            dbms_output.put_line(v_concepto);
            INSERT INTO asienhea (
                id_cia,
                periodo,
                mes,
                libro,
                asiento,
                concep,
                tasien,
                moneda,
                fecha,
                tcamb01,
                tcamb02,
                situac,
                usuari,
                fcreac,
                factua
            ) VALUES (
                pin_id_cia,
                pin_periodo,
                pin_mes,
                '79',--pin_libro
                v_asiento,
                v_concepto,
                66,
                v_moneda01,
                v_fechaasiento,
                1,
                v_venta,
                1,
                pin_coduser,
                current_timestamp,
                current_timestamp
            );

            COMMIT;
            dbms_output.put_line('GENERANDO RESUMEN PARA - ' || v_concepto);
            v_item := 0;
            v_sinregistro := 0;
            FOR r IN (
                SELECT
                    dr.clase18,
                    dr.clase19,
                    SUM(
                        CASE
                            WHEN c.tipdoc = 7 THEN
                                - 1
                            ELSE
                                1
                        END
                        * nvl(k.costot01, 0)) AS costo01,
                    SUM(
                        CASE
                            WHEN c.tipdoc = 7 THEN
                                - 1
                            ELSE
                                1
                        END
                        * nvl(k.costot02, 0)) AS costo02
                FROM
                    pack_relacion_costo_venta.sp_resumen(pin_id_cia, rti.tipinv, v_finicio, v_ffinal) dr
                    LEFT OUTER JOIN documentos_cab                                                                    c ON c.id_cia =
                    dr.id_cia
                                                        AND c.numint = dr.numint
                    LEFT OUTER JOIN kardex_costoventa                                                                 k ON k.id_cia =
                    dr.id_cia
                                                           AND k.numint = dr.numint
                                                           AND k.numite = dr.numite
                WHERE
                        dr.id_cia = pin_id_cia
                    AND dr.tipinv IN ( 1, 2, 3 )
--                    AND k.cantid IS NOT NULL
--                    AND k.cantid <> 0
                GROUP BY
                    dr.clase18,
                    dr.clase19
            ) LOOP

--                graba_asiendet(query.fieldbyname('CLASE18').asstring, 'H', query.fieldbyname('COSTO01').asfloat, query.fieldbyname('COSTO02').
--                asfloat);
--
                sp_genera_asiento(pin_id_cia, pin_periodo, pin_mes, '79', v_fechaasiento,
                                 v_asiento, nvl(r.clase18, 'ND'), v_moneda01, r.costo01, r.costo02, 'H',
                                 v_item, v_concepto, pin_coduser);

--                graba_asiendet(query.fieldbyname('CLASE19').asstring, 'D', query.fieldbyname('COSTO01').asfloat, query.fieldbyname('COSTO02').
--                asfloat);

                sp_genera_asiento(pin_id_cia, pin_periodo, pin_mes, '79', v_fechaasiento,
                                 v_asiento, nvl(r.clase19, 'ND'), v_moneda01, r.costo01, r.costo02, 'D',
                                 v_item, v_concepto, pin_coduser);

                BEGIN
                    sp_contabilizar_asiento(pin_id_cia, '79', pin_periodo, pin_mes, v_asiento,
                                           pin_coduser, v_msj);
                END;

                v_sinregistro := 1;
                o := json_object_t.parse(v_msj);
                dbms_output.put_line('CONTABILIZAR ASIENTO - ' || o.get_string('message'));
                IF ( o.get_number('status') <> 1.0 ) THEN
                    v_proceso := 1;
                ELSE
                    UPDATE asienhea
                    SET
                        situac = 2,
                        factua = to_timestamp(to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
                        usuari = pin_coduser
                    WHERE
                            id_cia = pin_id_cia
                        AND periodo = pin_periodo
                        AND mes = pin_mes
                        AND libro = '79'
                        AND asiento = v_asiento;

                    COMMIT;
                END IF;

            END LOOP;

            IF v_sinregistro = 0 THEN
                dbms_output.put_line('ERROR ESTE ASIENTO NO TIENE REGISTRO - ' || v_concepto);
                DELETE FROM movimientos
                WHERE
                        id_cia = pin_id_cia
                    AND periodo = pin_periodo
                    AND mes = pin_mes
                    AND libro = '79'
                    AND asiento = v_asiento;

                COMMIT;
                DELETE FROM asiendet
                WHERE
                        id_cia = pin_id_cia
                    AND periodo = pin_periodo
                    AND mes = pin_mes
                    AND libro = '79'
                    AND asiento = v_asiento;

                COMMIT;
                DELETE FROM asienhea
                WHERE
                        id_cia = pin_id_cia
                    AND periodo = pin_periodo
                    AND mes = pin_mes
                    AND libro = '79'
                    AND asiento = v_asiento;

                v_asiento := v_asiento; --NO SE INCREMENTA EL ASIENTO, PORQUE SE BORRO ESTA CABECERA

                COMMIT;
            ELSE
                v_asiento := v_asiento + 1; --SE INCREMENTA, SIGUIENTE CABEZERA
            END IF;

        END LOOP;

        IF v_proceso = 0 THEN
            pout_message := 'Los asientos del costo de venta para el periodo '
                            || pin_periodo
                            || ' , mes '
                            || pin_mes
                            || ' y libro 79 se han procesado correctamente';
        ELSIF v_proceso = 1 THEN
            pout_message := 'Los asientos del costo de venta para el periodo '
                            || pin_periodo
                            || ' , mes '
                            || pin_mes
                            || ' y libro 79 se han procesado, sin embargo algunos asientos no han sido contabilizados porque alguna de las cuentas asociadas, no existen en libro de cuentas';
        END IF;

        SELECT
            JSON_OBJECT(
                'status' VALUE 1.0,
                'message' VALUE pout_message
            )
        INTO pout_message
        FROM
            dual;

    EXCEPTION
        WHEN pkg_exceptionuser.ex_tcambio_no_existe THEN
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.1,
                    'message' VALUE pout_message
                )
            INTO pout_message
            FROM
                dual;

        WHEN OTHERS THEN
            pout_message := 'mensaje : '
                            || sqlerrm
                            || ' codigo :'
                            || sqlcode;
            SELECT
                JSON_OBJECT(
                    'status' VALUE 1.2,
                    'message' VALUE pout_message
                )
            INTO pout_message
            FROM
                dual;

    END sp_genera;

    FUNCTION sp_reporte_clase (
        pin_id_cia NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_reporte_clase
        PIPELINED
    AS
        v_table datatable_reporte_clase;
    BEGIN
        SELECT DISTINCT
            c.id_cia,
            d.tipinv,
            d.codart,
            a.descri AS desart,
            'Articulo registrado sin la Clase 18 o 19!'
        BULK COLLECT
        INTO v_table
        FROM
                 documentos_cab c
            INNER JOIN documentos_det d ON c.id_cia = d.id_cia
                                           AND c.numint = d.numint
            INNER JOIN articulos      a ON a.id_cia = c.id_cia
                                      AND a.tipinv = d.tipinv
                                      AND a.codart = d.codart
        WHERE
                c.id_cia = pin_id_cia
            AND c.tipdoc IN ( 1, 3, 7, 8 )
            AND c.femisi BETWEEN pin_fdesde AND pin_fhasta
            AND NOT EXISTS (
                SELECT
                    ac.codart
                FROM
                    articulos_clase ac
                WHERE
                        ac.id_cia = d.id_cia
                    AND ac.tipinv = d.tipinv
                    AND ac.codart = d.codart
                    AND ac.clase IN ( 18, 19 )
            );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_reporte_clase;

    FUNCTION sp_reporte_cuenta (
        pin_id_cia NUMBER,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_reporte_cuenta
        PIPELINED
    AS
        v_table datatable_reporte_cuenta;
    BEGIN
        SELECT DISTINCT
            c.id_cia,
            d.tipinv,
            d.codart,
            a.descri AS desart,
            ac.clase,
            ac.codigo,
            'Articulo registrado con una Cuenta que no existe en el Libro de Cuentas!'
        BULK COLLECT
        INTO v_table
        FROM
                 documentos_cab c
            INNER JOIN documentos_det  d ON c.id_cia = d.id_cia
                                           AND c.numint = d.numint
            INNER JOIN articulos       a ON a.id_cia = c.id_cia
                                      AND a.tipinv = d.tipinv
                                      AND a.codart = d.codart
            INNER JOIN articulos_clase ac ON ac.id_cia = c.id_cia
                                             AND ac.tipinv = a.tipinv
                                             AND ac.codart = a.codart
        WHERE
                c.id_cia = pin_id_cia
            AND c.tipdoc IN ( 1, 3, 7, 8 )
            AND ac.clase IN ( 18, 19 )
            AND c.femisi BETWEEN pin_fdesde AND pin_fhasta
            AND NOT EXISTS (
                SELECT
                    pc.cuenta
                FROM
                    pcuentas pc
                WHERE
                        pc.id_cia = d.id_cia
                    AND pc.cuenta = ac.codigo
            );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_reporte_cuenta;

    FUNCTION sp_reporte_cuentav2 (
        pin_id_cia NUMBER,
        pin_tipinv NUMBER
    ) RETURN datatable_reporte_cuenta
        PIPELINED
    AS
        v_table datatable_reporte_cuenta;
    BEGIN
        SELECT DISTINCT
            a.id_cia,
            a.tipinv,
            a.codart,
            a.descri AS desart,
            ac.clase,
            ac.codigo,
            'Articulo registrado con una Cuenta que no existe en el Libro de Cuentas!'
        BULK COLLECT
        INTO v_table
        FROM
                 articulos a
            INNER JOIN articulos_clase ac ON ac.id_cia = a.id_cia
                                             AND ac.tipinv = a.tipinv
                                             AND ac.codart = a.codart
        WHERE
                a.id_cia = pin_id_cia
            AND ac.clase IN ( 18, 19 )
            AND a.tipinv = pin_tipinv
            AND NOT EXISTS (
                SELECT
                    pc.cuenta
                FROM
                    pcuentas pc
                WHERE
                        pc.id_cia = a.id_cia
                    AND pc.cuenta = ac.codigo
            );

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_reporte_cuentav2;

END;

/

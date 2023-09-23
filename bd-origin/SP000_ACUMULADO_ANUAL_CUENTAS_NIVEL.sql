--------------------------------------------------------
--  DDL for Function SP000_ACUMULADO_ANUAL_CUENTAS_NIVEL
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP000_ACUMULADO_ANUAL_CUENTAS_NIVEL" (
    pin_id_cia       NUMBER,
    pin_periodo      NUMBER,
    pin_cuentadesde  VARCHAR2,
    pin_cuentahasta  VARCHAR2,
    pin_nivel        NUMBER
) RETURN tbl_acumulado_anual_cuentas_nivel
    PIPELINED
AS

    v_acumulado_anual_cuentas_nivel  rec_acumulado_anual_cuentas_nivel := rec_acumulado_anual_cuentas_nivel(NULL, NULL, 0, 0,
    NULL,
                                  0,0,0,0,0,
                                  0,0,0,0,0,
                                  0,0,0,0,0,
                                  0,0,0,0,0,
                                  0,0,0,0,0);
    CURSOR cur_select (
        plargodesde  NUMBER,
        plargohasta  NUMBER
    ) IS
    SELECT
        p.cuenta,
        p.nombre
    FROM
        pcuentas p
    WHERE
        ( p.id_cia = pin_id_cia )
        AND ( p.nivel = pin_nivel )
        AND ( ( plargodesde = 0 )
              OR ( substr2(p.cuenta, 1, plargodesde) >= pin_cuentadesde ) )
        AND ( ( plargohasta = 0 )
              OR ( substr2(p.cuenta, 1, plargohasta) <= pin_cuentahasta ) )
    ORDER BY
        p.cuenta;

    v_largodesde                     NUMBER := 0;
    v_largohasta                     NUMBER := 0;
    v_cuentadesde                    VARCHAR2(40) := '';
    v_cuentahasta                    VARCHAR2(40) := '';
BEGIN
    IF ( pin_cuentadesde IS NULL ) THEN
        v_cuentadesde := '';
    END IF;
    IF ( pin_cuentahasta IS NULL ) THEN
        v_cuentahasta := '';
    END IF;
    IF ( v_cuentadesde <> '' ) THEN
        v_largodesde := length(pin_cuentadesde);
    END IF;

    IF ( v_cuentahasta <> '' ) THEN
        v_largohasta := length(pin_cuentahasta);
    END IF;

---antes de ejecutar esta funcion deberan de ejecutar este procedimiento ---------------*/
/*sp000_insert_movimientos_acumulados*/

    FOR registro IN cur_select(v_largodesde, v_largohasta) LOOP
        v_acumulado_anual_cuentas_nivel.saldo0001 := 0;
        v_acumulado_anual_cuentas_nivel.saldo0101 := 0;
        v_acumulado_anual_cuentas_nivel.saldo0201 := 0;
        v_acumulado_anual_cuentas_nivel.saldo0301 := 0;
        v_acumulado_anual_cuentas_nivel.saldo0401 := 0;
        v_acumulado_anual_cuentas_nivel.saldo0501 := 0;
        v_acumulado_anual_cuentas_nivel.saldo0601 := 0;
        v_acumulado_anual_cuentas_nivel.saldo0701 := 0;
        v_acumulado_anual_cuentas_nivel.saldo0801 := 0;
        v_acumulado_anual_cuentas_nivel.saldo0901 := 0;
        v_acumulado_anual_cuentas_nivel.saldo1001 := 0;
        v_acumulado_anual_cuentas_nivel.saldo1101 := 0;
        v_acumulado_anual_cuentas_nivel.saldo1201 := 0;
        v_acumulado_anual_cuentas_nivel.saldo9901 := 0;
        v_acumulado_anual_cuentas_nivel.saldo0002 := 0;
        v_acumulado_anual_cuentas_nivel.saldo0102 := 0;
        v_acumulado_anual_cuentas_nivel.saldo0202 := 0;
        v_acumulado_anual_cuentas_nivel.saldo0302 := 0;
        v_acumulado_anual_cuentas_nivel.saldo0402 := 0;
        v_acumulado_anual_cuentas_nivel.saldo0502 := 0;
        v_acumulado_anual_cuentas_nivel.saldo0602 := 0;
        v_acumulado_anual_cuentas_nivel.saldo0702 := 0;
        v_acumulado_anual_cuentas_nivel.saldo0802 := 0;
        v_acumulado_anual_cuentas_nivel.saldo0902 := 0;
        v_acumulado_anual_cuentas_nivel.saldo1002 := 0;
        v_acumulado_anual_cuentas_nivel.saldo1102 := 0;
        v_acumulado_anual_cuentas_nivel.saldo1202 := 0;
        v_acumulado_anual_cuentas_nivel.saldo9902 := 0;
        /* ACUMULA CANTDIDATES DESDE LA TABLA ACUMULADORA */
        BEGIN
            SELECT
                SUM(
                    CASE
                        WHEN m.saldo0001 IS NULL THEN
                            0
                        ELSE
                            m.saldo0001
                    END
                ) AS enero_apertura,
                SUM(
                    CASE
                        WHEN m.saldo0101 IS NULL THEN
                            0
                        ELSE
                            m.saldo0101
                    END
                ) AS enero,
                SUM(
                    CASE
                        WHEN m.saldo0201 IS NULL THEN
                            0
                        ELSE
                            m.saldo0201
                    END
                ) AS febrero,
                SUM(
                    CASE
                        WHEN m.saldo0301 IS NULL THEN
                            0
                        ELSE
                            m.saldo0301
                    END
                ) AS marzo,
                SUM(
                    CASE
                        WHEN m.saldo0401 IS NULL THEN
                            0
                        ELSE
                            m.saldo0401
                    END
                ) AS abril,
                SUM(
                    CASE
                        WHEN m.saldo0501 IS NULL THEN
                            0
                        ELSE
                            m.saldo0501
                    END
                ) AS mayo,
                SUM(
                    CASE
                        WHEN m.saldo0601 IS NULL THEN
                            0
                        ELSE
                            m.saldo0601
                    END
                ) AS junio,
                SUM(
                    CASE
                        WHEN m.saldo0701 IS NULL THEN
                            0
                        ELSE
                            m.saldo0701
                    END
                ) AS julio,
                SUM(
                    CASE
                        WHEN m.saldo0801 IS NULL THEN
                            0
                        ELSE
                            m.saldo0801
                    END
                ) AS agosto,
                SUM(
                    CASE
                        WHEN m.saldo0901 IS NULL THEN
                            0
                        ELSE
                            m.saldo0901
                    END
                ) AS septiembre,
                SUM(
                    CASE
                        WHEN m.saldo1001 IS NULL THEN
                            0
                        ELSE
                            m.saldo1001
                    END
                ) AS octubre,
                SUM(
                    CASE
                        WHEN m.saldo1101 IS NULL THEN
                            0
                        ELSE
                            m.saldo1101
                    END
                ) AS noviembre,
                SUM(
                    CASE
                        WHEN m.saldo1201 IS NULL THEN
                            0
                        ELSE
                            m.saldo1201
                    END
                ) AS diciembre,
                SUM(
                    CASE
                        WHEN m.saldo9901 IS NULL THEN
                            0
                        ELSE
                            m.saldo9901
                    END
                ) AS total,
                SUM(
                    CASE
                        WHEN m.saldo0002 IS NULL THEN
                            0
                        ELSE
                            m.saldo0002
                    END
                ) AS enero_apertura,
                SUM(
                    CASE
                        WHEN m.saldo0102 IS NULL THEN
                            0
                        ELSE
                            m.saldo0102
                    END
                ) AS enero,
                SUM(
                    CASE
                        WHEN m.saldo0202 IS NULL THEN
                            0
                        ELSE
                            m.saldo0202
                    END
                ) AS febrero,
                SUM(
                    CASE
                        WHEN m.saldo0302 IS NULL THEN
                            0
                        ELSE
                            m.saldo0302
                    END
                ) AS marzo,
                SUM(
                    CASE
                        WHEN m.saldo0402 IS NULL THEN
                            0
                        ELSE
                            m.saldo0402
                    END
                ) AS abril,
                SUM(
                    CASE
                        WHEN m.saldo0502 IS NULL THEN
                            0
                        ELSE
                            m.saldo0502
                    END
                ) AS mayo,
                SUM(
                    CASE
                        WHEN m.saldo0602 IS NULL THEN
                            0
                        ELSE
                            m.saldo0602
                    END
                ) AS junio,
                SUM(
                    CASE
                        WHEN m.saldo0702 IS NULL THEN
                            0
                        ELSE
                            m.saldo0702
                    END
                ) AS julio,
                SUM(
                    CASE
                        WHEN m.saldo0802 IS NULL THEN
                            0
                        ELSE
                            m.saldo0802
                    END
                ) AS agosto,
                SUM(
                    CASE
                        WHEN m.saldo0902 IS NULL THEN
                            0
                        ELSE
                            m.saldo0902
                    END
                ) AS septiembre,
                SUM(
                    CASE
                        WHEN m.saldo1002 IS NULL THEN
                            0
                        ELSE
                            m.saldo1002
                    END
                ) AS octubre,
                SUM(
                    CASE
                        WHEN m.saldo1102 IS NULL THEN
                            0
                        ELSE
                            m.saldo1102
                    END
                ) AS noviembre,
                SUM(
                    CASE
                        WHEN m.saldo1202 IS NULL THEN
                            0
                        ELSE
                            m.saldo1202
                    END
                ) AS diciembre,
                SUM(
                    CASE
                        WHEN m.saldo9902 IS NULL THEN
                            0
                        ELSE
                            m.saldo9902
                    END
                ) AS total
            INTO
                v_acumulado_anual_cuentas_nivel.saldo0001,
                v_acumulado_anual_cuentas_nivel.saldo0101,
                v_acumulado_anual_cuentas_nivel.saldo0201,
                v_acumulado_anual_cuentas_nivel.saldo0301,
                v_acumulado_anual_cuentas_nivel.saldo0401,
                v_acumulado_anual_cuentas_nivel.saldo0501,
                v_acumulado_anual_cuentas_nivel.saldo0601,
                v_acumulado_anual_cuentas_nivel.saldo0701,
                v_acumulado_anual_cuentas_nivel.saldo0801,
                v_acumulado_anual_cuentas_nivel.saldo0901,
                v_acumulado_anual_cuentas_nivel.saldo1001,
                v_acumulado_anual_cuentas_nivel.saldo1101,
                v_acumulado_anual_cuentas_nivel.saldo1201,
                v_acumulado_anual_cuentas_nivel.saldo9901,
                v_acumulado_anual_cuentas_nivel.saldo0002,
                v_acumulado_anual_cuentas_nivel.saldo0102,
                v_acumulado_anual_cuentas_nivel.saldo0202,
                v_acumulado_anual_cuentas_nivel.saldo0302,
                v_acumulado_anual_cuentas_nivel.saldo0402,
                v_acumulado_anual_cuentas_nivel.saldo0502,
                v_acumulado_anual_cuentas_nivel.saldo0602,
                v_acumulado_anual_cuentas_nivel.saldo0702,
                v_acumulado_anual_cuentas_nivel.saldo0802,
                v_acumulado_anual_cuentas_nivel.saldo0902,
                v_acumulado_anual_cuentas_nivel.saldo1002,
                v_acumulado_anual_cuentas_nivel.saldo1102,
                v_acumulado_anual_cuentas_nivel.saldo1202,
                v_acumulado_anual_cuentas_nivel.saldo9902
            FROM
                movimientos_acumulados m
            WHERE
                ( m.periodo = pin_periodo )
                AND ( m.cuenta LIKE registro.cuenta || '%' );

        EXCEPTION
            WHEN no_data_found THEN
                v_acumulado_anual_cuentas_nivel.saldo0001 := 0;
                v_acumulado_anual_cuentas_nivel.saldo0101 := 0;
                v_acumulado_anual_cuentas_nivel.saldo0201 := 0;
                v_acumulado_anual_cuentas_nivel.saldo0301 := 0;
                v_acumulado_anual_cuentas_nivel.saldo0401 := 0;
                v_acumulado_anual_cuentas_nivel.saldo0501 := 0;
                v_acumulado_anual_cuentas_nivel.saldo0601 := 0;
                v_acumulado_anual_cuentas_nivel.saldo0701 := 0;
                v_acumulado_anual_cuentas_nivel.saldo0801 := 0;
                v_acumulado_anual_cuentas_nivel.saldo0901 := 0;
                v_acumulado_anual_cuentas_nivel.saldo1001 := 0;
                v_acumulado_anual_cuentas_nivel.saldo1101 := 0;
                v_acumulado_anual_cuentas_nivel.saldo1201 := 0;
                v_acumulado_anual_cuentas_nivel.saldo9901 := 0;
                v_acumulado_anual_cuentas_nivel.saldo0002 := 0;
                v_acumulado_anual_cuentas_nivel.saldo0102 := 0;
                v_acumulado_anual_cuentas_nivel.saldo0202 := 0;
                v_acumulado_anual_cuentas_nivel.saldo0302 := 0;
                v_acumulado_anual_cuentas_nivel.saldo0402 := 0;
                v_acumulado_anual_cuentas_nivel.saldo0502 := 0;
                v_acumulado_anual_cuentas_nivel.saldo0602 := 0;
                v_acumulado_anual_cuentas_nivel.saldo0702 := 0;
                v_acumulado_anual_cuentas_nivel.saldo0802 := 0;
                v_acumulado_anual_cuentas_nivel.saldo0902 := 0;
                v_acumulado_anual_cuentas_nivel.saldo1002 := 0;
                v_acumulado_anual_cuentas_nivel.saldo1102 := 0;
                v_acumulado_anual_cuentas_nivel.saldo1202 := 0;
                v_acumulado_anual_cuentas_nivel.saldo9902 := 0;
        END;

        PIPE ROW ( v_acumulado_anual_cuentas_nivel );
----
    END LOOP;

END sp000_acumulado_anual_cuentas_nivel;

/

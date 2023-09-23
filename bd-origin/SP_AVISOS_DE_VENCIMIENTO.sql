--------------------------------------------------------
--  DDL for Function SP_AVISOS_DE_VENCIMIENTO
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP_AVISOS_DE_VENCIMIENTO" (
    pin_id_cia  IN  NUMBER,
    pin_codcli  IN  VARCHAR2,
    pin_tipo    IN  NUMBER
) RETURN tbl_sp_avisos_de_vencimiento
    PIPELINED
AS

    rec    rec_sp_avisos_de_vencimiento := rec_sp_avisos_de_vencimiento(NULL, NULL, NULL, NULL, NULL,
                             NULL);
    CURSOR cur_vencidos (
        pidcia   INTEGER,
        pcodcli  VARCHAR2
    ) IS
    SELECT
        c.codcli,
        c.razonc,
        CASE
            WHEN cc1.codigo IS NULL THEN
                'XXX'
            ELSE
                cc1.codigo
        END AS codenv
    FROM
             dcta100 d
        INNER JOIN cliente        c ON c.id_cia = d.id_cia
                                AND c.codcli = d.codcli
        LEFT OUTER JOIN cliente_clase  cc1 ON cc1.id_cia = d.id_cia
                                             AND cc1.clase = 5
                                             AND cc1.codigo = 'S'
                                             AND cc1.tipcli = 'A'
                                             AND cc1.codcli = c.codcli
    WHERE
            d.id_cia = pidcia
        AND ( pcodcli IS NULL
              OR ( d.codcli = pcodcli ) )
        AND ( d.saldo <> 0 )
        AND ( d.codubi = 1 )
        AND ( d.fvenci < current_date )
    GROUP BY
        c.codcli,
        c.razonc,
        cc1.codigo
    ORDER BY
        c.codcli;

    CURSOR cur_porvencer (
        pidcia          INTEGER,
        pcodcli         VARCHAR2,
        pdiasporvencer  INTEGER
    ) IS
    SELECT
        c.codcli,
        c.razonc,
        CASE
            WHEN cc1.codigo IS NULL THEN
                'XXX'
            ELSE
                cc1.codigo
        END AS codenv
    FROM
             dcta100 d
        INNER JOIN cliente        c ON c.id_cia = d.id_cia
                                AND c.codcli = d.codcli
        LEFT OUTER JOIN cliente_clase  cc1 ON cc1.id_cia = c.id_cia
                                             AND cc1.clase = 5
                                             AND cc1.codigo = 'S'
                                             AND cc1.tipcli = 'A'
                                             AND cc1.codcli = c.codcli
    WHERE
            d.id_cia = pidcia
        AND ( pcodcli IS NULL
              OR ( d.codcli = pcodcli ) )
        AND ( d.saldo <> 0 )
        AND ( d.codubi = 1 )
        AND ( CAST((current_date - d.fvenci) AS INTEGER) <= ( pdiasporvencer * - 1 ) )
    GROUP BY
        c.codcli,
        c.razonc,
        cc1.codigo
    ORDER BY
        c.codcli;

    CURSOR cur_todos (
        pidcia          INTEGER,
        pcodcli         VARCHAR2,
        pdiasporvencer  INTEGER
    ) IS
    SELECT
        c.codcli,
        c.razonc,
        CASE
            WHEN cc1.codigo IS NULL THEN
                'XXX'
            ELSE
                cc1.codigo
        END AS codenv
    FROM
             dcta100 d
        INNER JOIN cliente        c ON c.id_cia = d.id_cia
                                AND c.codcli = d.codcli
        LEFT OUTER JOIN cliente_clase  cc1 ON cc1.id_cia = c.id_cia
                                             AND cc1.clase = 5
                                             AND cc1.codigo = 'S'
                                             AND cc1.tipcli = 'A'
                                             AND cc1.codcli = c.codcli
    WHERE
            d.id_cia = pidcia
        AND ( d.codcli = pcodcli
              OR pcodcli IS NULL )
        AND ( d.saldo <> 0 )
        AND ( d.codubi = 1 )
        AND ( ( d.fvenci < current_date )
              OR ( CAST((current_date - d.fvenci) AS INTEGER) <= ( pdiasporvencer * - 1 ) ) )
    GROUP BY
        c.codcli,
        c.razonc,
        cc1.codigo
    ORDER BY
        c.codcli;

    v_428  INTEGER := 0;
BEGIN
    BEGIN
    /*Factor 428 Número de días de avisos por vencer */
        SELECT
            ventero
        INTO v_428
        FROM
            factor
        WHERE
                id_cia = pin_id_cia
            AND codfac = 428;

    EXCEPTION
        WHEN no_data_found THEN
            v_428 := 0;
    END;

    CASE
        WHEN pin_tipo = 1 THEN 

      -- VENCIDOS
            FOR rven IN cur_vencidos(pin_id_cia, pin_codcli) LOOP
                BEGIN
                    SELECT
                        SUM(
                            CASE
                                WHEN cc2.codcont IS NULL THEN
                                    0
                                ELSE
                                    1
                            END
                        )
                    INTO rec.sumcont
                    FROM
                        clientecontacto_clase cc2
                    WHERE
                            cc2.id_cia = pin_id_cia
                        AND cc2.codcli = rven.codcli
                        AND cc2.clase = 1
                        AND cc2.codigo = '1';

                EXCEPTION
                    WHEN no_data_found THEN
                        rec.sumcont := NULL;
                END;

                IF rec.sumcont IS NULL THEN
                    rec.sumcont := 0;
                END IF;
                BEGIN
                    SELECT
                        COUNT(codcont)
                    INTO rec.cancon
                    FROM
                        clientecontacto
                    WHERE
                        ( id_cia = pin_id_cia )
                        AND ( codcli = rven.codcli );

                EXCEPTION
                    WHEN no_data_found THEN
                        rec.cancon := NULL;
                END;

                IF rec.cancon IS NULL THEN
                    rec.cancon := 0;
                END IF;
                BEGIN
                    SELECT
                        COUNT(ccp.codcont)
                    INTO rec.conemailvacio
                    FROM
                        clientecontacto        ccp
                        LEFT OUTER JOIN contacto               co ON co.id_cia = ccp.id_cia
                                                       AND co.codcont = ccp.codcont
                        INNER JOIN clientecontacto_clase  co2 ON co2.id_cia = ccp.id_cia
                                                                AND co2.codcli = ccp.codcli
                                                                AND co2.codcont = ccp.codcont
                                                                AND co2.clase = 1
                                                                AND co2.codigo = '1'
                    WHERE
                            ccp.id_cia = pin_id_cia
                        AND ccp.codcli = rven.codcli
                        AND co.email = ''
                        AND rven.codcli IS NOT NULL;

                EXCEPTION
                    WHEN no_data_found THEN
                        rec.conemailvacio := NULL;
                END;

                IF rec.conemailvacio IS NULL THEN
                    rec.conemailvacio := 0;
                END IF;
                rec.codcli := rven.codcli;
                rec.razonc := rven.razonc;
                rec.codenv := rven.codenv;
                PIPE ROW ( rec );
            END LOOP;
        WHEN ( pin_tipo = 2 ) THEN 

-- POR VENCER
            FOR rporven IN cur_porvencer(pin_id_cia, pin_codcli, v_428) LOOP
                BEGIN
                    SELECT
                        SUM(
                            CASE
                                WHEN cc2.codcont IS NULL THEN
                                    0
                                ELSE
                                    1
                            END
                        )
                    INTO rec.sumcont
                    FROM
                        clientecontacto_clase cc2
                    WHERE
                            cc2.id_cia = pin_id_cia
                        AND cc2.codcli = rporven.codcli
                        AND cc2.clase = 1
                        AND cc2.codigo = '1';

                EXCEPTION
                    WHEN no_data_found THEN
                        rec.sumcont := NULL;
                END;

                IF rec.sumcont IS NULL THEN
                    rec.sumcont := 0;
                END IF;
                BEGIN
                    SELECT
                        COUNT(codcont)
                    INTO rec.cancon
                    FROM
                        clientecontacto
                    WHERE
                        ( id_cia = pin_id_cia )
                        AND ( codcli = rporven.codcli );

                EXCEPTION
                    WHEN no_data_found THEN
                        rec.cancon := NULL;
                END;

                IF rec.cancon IS NULL THEN
                    rec.cancon := 0;
                END IF;
                BEGIN
                    SELECT
                        COUNT(ccp.codcont)
                    INTO rec.conemailvacio
                    FROM
                        clientecontacto        ccp
                        LEFT OUTER JOIN contacto               co ON co.id_cia = ccp.id_cia
                                                       AND co.codcont = ccp.codcont
                        INNER JOIN clientecontacto_clase  co2 ON co2.id_cia = ccp.id_cia
                                                                AND co2.codcli = ccp.codcli
                                                                AND co2.codcont = ccp.codcont
                                                                AND co2.clase = 1
                                                                AND co2.codigo = '1'
                    WHERE
                            ccp.id_cia = pin_id_cia
                        AND ccp.codcli = rporven.codcli
                        AND co.email = ''
                        AND rporven.codcli IS NOT NULL;

                EXCEPTION
                    WHEN no_data_found THEN
                        rec.conemailvacio := NULL;
                END;

                IF rec.conemailvacio IS NULL THEN
                    rec.conemailvacio := 0;
                END IF;
                rec.codcli := rporven.codcli;
                rec.razonc := rporven.razonc;
                rec.codenv := rporven.codenv;
                PIPE ROW ( rec );
            END LOOP;
        WHEN ( pin_tipo = 3 ) THEN 

      -- TODOS
            FOR rtodos IN cur_todos(pin_id_cia, pin_codcli, v_428) LOOP
                BEGIN
                    SELECT
                        SUM(
                            CASE
                                WHEN cc2.codcont IS NULL THEN
                                    0
                                ELSE
                                    1
                            END
                        )
                    INTO rec.sumcont
                    FROM
                        clientecontacto_clase cc2
                    WHERE
                            cc2.id_cia = pin_id_cia
                        AND cc2.codcli = rtodos.codcli
                        AND cc2.clase = 1
                        AND cc2.codigo = '1';

                EXCEPTION
                    WHEN no_data_found THEN
                        rec.sumcont := NULL;
                END;

                IF rec.sumcont IS NULL THEN
                    rec.sumcont := 0;
                END IF;
                BEGIN
                    SELECT
                        COUNT(codcont)
                    INTO rec.cancon
                    FROM
                        clientecontacto
                    WHERE
                        ( id_cia = pin_id_cia )
                        AND ( codcli = rtodos.codcli );

                EXCEPTION
                    WHEN no_data_found THEN
                        rec.cancon := NULL;
                END;

                IF rec.cancon IS NULL THEN
                    rec.cancon := 0;
                END IF;
                BEGIN
                    SELECT
                        COUNT(ccp.codcont)
                    INTO rec.conemailvacio
                    FROM
                        clientecontacto        ccp
                        LEFT OUTER JOIN contacto               co ON co.id_cia = ccp.id_cia
                                                       AND co.codcont = ccp.codcont
                        INNER JOIN clientecontacto_clase  co2 ON co2.id_cia = ccp.id_cia
                                                                AND co2.codcli = ccp.codcli
                                                                AND co2.codcont = ccp.codcont
                                                                AND co2.clase = 1
                                                                AND co2.codigo = '1'
                    WHERE
                            ccp.id_cia = pin_id_cia
                        AND ccp.codcli = rtodos.codcli
                        AND co.email = ''
                        AND rtodos.codcli IS NOT NULL;

                EXCEPTION
                    WHEN no_data_found THEN
                        rec.conemailvacio := NULL;
                END;

                IF rec.conemailvacio IS NULL THEN
                    rec.conemailvacio := 0;
                END IF;
                rec.codcli := rtodos.codcli;
                rec.razonc := rtodos.razonc;
                rec.codenv := rtodos.codenv;
                PIPE ROW ( rec );
            END LOOP;
    END CASE;

END sp_avisos_de_vencimiento;

/

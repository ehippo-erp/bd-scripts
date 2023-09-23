--------------------------------------------------------
--  DDL for Function SP_SEL_SALDO_KARDEX_006
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP_SEL_SALDO_KARDEX_006" (
    pin_id_cia    NUMBER,
    pin_tipinv    NUMBER,
    pin_codalm    NUMBER,
    pin_codart    VARCHAR2,
    pin_etiqueta  VARCHAR2,
    pin_nonumint  NUMBER
) RETURN tbl_saldo_kardex_006
    PIPELINED
AS

    r_saldo_kardex_006 rec_saldo_kardex_006 := rec_saldo_kardex_006(NULL, NULL, NULL, NULL, NULL,
                     NULL, NULL, NULL, NULL, NULL,
                     NULL, NULL, NULL);
    CURSOR cur_kardex IS
    SELECT
        k1.tipinv,
        k1.codart,
        k1.codalm,
        (
            CASE
                WHEN k1.etiqueta IS NULL THEN
                    CAST('' AS VARCHAR(100))
                ELSE
                    k1.etiqueta
            END
        ) AS etiqueta,
        SUM(abs(
            CASE
                WHEN k1.id = 'I' THEN
                    k1.cantid
                ELSE
                    0
            END
        )) - SUM(abs(
            CASE
                WHEN k1.id = 'S' THEN
                    k1.cantid
                ELSE
                    0
            END
        )) AS saldo,
        SUM(abs(
            CASE
                WHEN k1.id = 'I' THEN
                    k1.royos
                ELSE
                    0
            END
        )) - SUM(abs(
            CASE
                WHEN k1.id = 'S' THEN
                    k1.royos
                ELSE
                    0
            END
        )) AS royos
    FROM
        kardex k1
    WHERE
        (k1.id_cia = pin_id_cia) and
        ( ( pin_tipinv IS NULL )
          OR ( pin_tipinv <= 0 )
          OR ( k1.tipinv = pin_tipinv ) )
        AND ( ( pin_codalm IS NULL )
              OR ( pin_codalm <= 0 )
              OR ( k1.codalm = pin_codalm ) )
        AND ( ( pin_codart IS NULL )
              OR ( pin_codart = '' )
              OR ( k1.codart = pin_codart ) )
        AND ( ( pin_etiqueta IS NULL )
              OR ( pin_etiqueta = '' )
              OR ( k1.etiqueta = pin_etiqueta ) )
        AND ( ( pin_nonumint IS NULL )
              OR ( pin_nonumint <= 0 )
              OR ( k1.numint <> pin_nonumint ) )
    GROUP BY
        k1.tipinv,
        k1.codart,
        k1.codalm,
        k1.etiqueta
    ORDER BY
        k1.tipinv,
        k1.codart,
        k1.codalm;

BEGIN
    FOR registro IN cur_kardex LOOP
        IF registro.tipinv IS NULL THEN
            r_saldo_kardex_006.tipinv := 0;
        ELSE
            r_saldo_kardex_006.tipinv := registro.tipinv;
        END IF;

        IF registro.codart IS NULL THEN
            r_saldo_kardex_006.codart := '';
        ELSE
            r_saldo_kardex_006.codart := registro.codart;
        END IF;

        IF r_saldo_kardex_006.codalm IS NULL THEN
            r_saldo_kardex_006.codalm := 0;
        ELSE
            r_saldo_kardex_006.codalm := registro.codalm;
        END IF;

        IF r_saldo_kardex_006.etiqueta IS NULL THEN
            r_saldo_kardex_006.etiqueta := ' ';
        ELSE
            r_saldo_kardex_006.etiqueta := registro.etiqueta;
        END IF;

        IF r_saldo_kardex_006.saldo IS NULL THEN
            r_saldo_kardex_006.saldo := 0;
        ELSE
            r_saldo_kardex_006.saldo := registro.saldo;
        END IF;

        IF r_saldo_kardex_006.royos IS NULL THEN
            r_saldo_kardex_006.royos := 0;
        ELSE
            r_saldo_kardex_006.royos := registro.royos;
        END IF;

        r_saldo_kardex_006.opnumdoc := ' ';
        r_saldo_kardex_006.optramo := 0;
        r_saldo_kardex_006.numint := 0;
        r_saldo_kardex_006.numite := 0;
        r_saldo_kardex_006.costot01 := 0;
        r_saldo_kardex_006.costot02 := 0;
        IF (
                    ( length(r_saldo_kardex_006.etiqueta) <= 3 ) AND ( r_saldo_kardex_006.tipinv > 0 )
                AND ( r_saldo_kardex_006.codart <> '' )
            AND ( r_saldo_kardex_006.codalm > 0 )
        ) THEN
            BEGIN
                SELECT
                    CAST(MAX(femisi) AS DATE)
                INTO r_saldo_kardex_006.fingreso
                FROM
                    kardex
                WHERE
                    id_cia = pin_id_cia 
                    AND     id = 'I'
                    AND tipinv = registro.tipinv
                    AND codalm = registro.codalm
                    AND codart = registro.codart
                    AND ( tipdoc <> 111
                          AND ( codmot = 1
                                OR codmot = 6
                                OR codmot = 7
                                OR codmot = 9
                                OR codmot = 4 ) );

            EXCEPTION
                WHEN no_data_found THEN
                    r_saldo_kardex_006.fingreso := NULL;
            END;

            IF ( r_saldo_kardex_006.fingreso IS NULL ) THEN
                BEGIN
                    SELECT
                        CAST(MAX(femisi) AS DATE)
                    INTO r_saldo_kardex_006.fingreso
                    FROM
                        kardex
                    WHERE
                        id_cia = pin_id_cia 
                        AND id = 'I'
                        AND tipinv = registro.tipinv
                        AND codalm = registro.codalm
                        AND codart = registro.codart
                        AND ( tipdoc <> 111
                              AND ( codmot = 1
                                    OR codmot = 6
                                    OR codmot = 7
                                    OR codmot = 9
                                    OR codmot = 4 ) );

                EXCEPTION
                    WHEN no_data_found THEN
                        r_saldo_kardex_006.fingreso := NULL;
                END;

            END IF;

        END IF;

        IF ( length(r_saldo_kardex_006.etiqueta) > 3 ) THEN
            FOR resgistro2 IN (
                SELECT
                    k.opnumdoc,
                    k.optramo,
                    k.fingreso,
                    k.numint,
                    k.numite
                FROM
                    kardex001 k
                WHERE   k.id_cia = pin_id_cia 
                    AND k.etiqueta = registro.etiqueta
                    AND k.codalm = registro.codalm
            ) LOOP
                IF ( resgistro2.opnumdoc IS NULL ) THEN
                    r_saldo_kardex_006.opnumdoc := '';
                ELSE
                    r_saldo_kardex_006.opnumdoc := resgistro2.opnumdoc;
                END IF;

                IF ( resgistro2.optramo IS NULL ) THEN
                    r_saldo_kardex_006.optramo := 0;
                ELSE
                    r_saldo_kardex_006.optramo := resgistro2.optramo;
                END IF;

                IF ( resgistro2.numint IS NULL ) THEN
                    r_saldo_kardex_006.numint := 0;
                ELSE
                    r_saldo_kardex_006.numint := resgistro2.numint;
                END IF;

                IF ( resgistro2.numite IS NULL ) THEN
                    r_saldo_kardex_006.numite := 0;
                ELSE
                    r_saldo_kardex_006.numite := resgistro2.numite;
                END IF;

                r_saldo_kardex_006.fingreso := resgistro2.fingreso;
            END LOOP;
        END IF;

        PIPE ROW ( r_saldo_kardex_006 );
    END LOOP;
END sp_sel_saldo_kardex_006;

/

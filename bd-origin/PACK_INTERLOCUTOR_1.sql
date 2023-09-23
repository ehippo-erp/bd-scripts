--------------------------------------------------------
--  DDL for Package Body PACK_INTERLOCUTOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_INTERLOCUTOR" AS

    FUNCTION sp_sel_interlocutor (
        pin_id_cia   IN NUMBER,
        pin_tipcli   IN VARCHAR2,
        pin_swactivo IN VARCHAR2,
        pin_codtpe   IN NUMBER,
        pin_codcli   IN VARCHAR2,
        pin_dident   IN VARCHAR2,
        pin_razonc   IN VARCHAR2,
        pin_nombres  IN VARCHAR2,
        pin_offset   IN NUMBER,
        pin_limite   IN NUMBER
    ) RETURN t_cliente
        PIPELINED
    AS
        v_table t_cliente;
    BEGIN
    -- TAREA: Se necesita implantación para FUNCTION PACK_INTERLOCUTOR.sp_sel_interlocutor

        if (pin_tipcli is not null) then
        
            SELECT
                c.codcli,
                c.tident,
                i.abrevi   AS tidentnombre,
                c.dident,
                c.razonc,
                c.codtit,
                c.direc1   AS direcc,
                c.codpag,
                c.valident,
                c.codtpe,
                ctp.apepat AS apellidopaterno,
                ctp.apemat AS apellidomaterno,
                ctp.nombre AS nombres,
                CASE
                    WHEN ctp.apepat IS NOT NULL THEN
                            ctp.apepat
                    ELSE
                        ''
                END
                ||
                CASE
                    WHEN ctp.apemat IS NOT NULL THEN
                            ' ' || ctp.apemat
                    ELSE
                        ''
                END
                ||
                CASE
                    WHEN ctp.nombre IS NOT NULL THEN
                            ' ' || ctp.nombre
                    ELSE
                        ''
                END
                AS nombrescompletos
            BULK COLLECT
            INTO v_table
            FROM
                cliente          c
                INNER JOIN cliente_clase cc on cc.id_cia=c.id_cia and cc.tipcli=pin_tipcli and cc.codcli=c.codcli and cc.clase=1
                LEFT OUTER JOIN identidad        i ON i.id_cia = c.id_cia
                                               AND i.tident = c.tident
                LEFT OUTER JOIN cliente_tpersona ctp ON ctp.id_cia = c.id_cia
                                                        AND ctp.codcli = c.codcli

            WHERE
                    c.id_cia = pin_id_cia
                AND ( pin_codtpe IS NULL
                      OR ( c.codtpe = pin_codtpe ) )
                AND ( pin_codcli IS NULL
                      OR ( upper(c.codcli) LIKE upper(pin_codcli) ) )
                AND ( pin_dident IS NULL
                      OR ( upper(c.dident) LIKE upper(pin_dident) ) )
                AND ( pin_razonc IS NULL
                      OR ( pin_razonc IS NOT NULL
                           AND ( upper(c.razonc) LIKE upper(pin_razonc) ) )
                      OR ( pin_nombres IS NOT NULL
                           AND ( upper(
                    CASE
                        WHEN length(ctp.apepat) > 0 THEN
                            ctp.apepat || ' '
                        ELSE
                            ''
                    END
                    ||
                    CASE
                        WHEN length(ctp.apemat) > 0 THEN
                            ctp.apemat || ' '
                        ELSE
                            ''
                    END
                    ||
                    CASE
                        WHEN length(ctp.nombre) > 0 THEN
                            ctp.nombre || ' '
                        ELSE
                            ''
                    END
                ) LIKE upper(pin_nombres) ) ) )
            OFFSET pin_offset ROWS FETCH NEXT pin_limite ROWS ONLY;

            FOR registro IN 1..v_table.count LOOP
                PIPE ROW ( v_table(registro) );
            END LOOP;
            
            RETURN;

            
        else
            SELECT
                c.codcli,
                c.tident,
                i.abrevi   AS tidentnombre,
                c.dident,
                c.razonc,
                c.codtit,
                c.direc1   AS direcc,
                c.codpag,
                c.valident,
                c.codtpe,
                ctp.apepat AS apellidopaterno,
                ctp.apemat AS apellidomaterno,
                ctp.nombre AS nombres,
                CASE
                    WHEN ctp.apepat IS NOT NULL THEN
                            ctp.apepat
                    ELSE
                        ''
                END
                ||
                CASE
                    WHEN ctp.apemat IS NOT NULL THEN
                            ' ' || ctp.apemat
                    ELSE
                        ''
                END
                ||
                CASE
                    WHEN ctp.nombre IS NOT NULL THEN
                            ' ' || ctp.nombre
                    ELSE
                        ''
                END
                AS nombrescompletos
            BULK COLLECT
            INTO v_table
            FROM
                cliente          c
                LEFT OUTER JOIN identidad        i ON i.id_cia = c.id_cia
                                               AND i.tident = c.tident
                LEFT OUTER JOIN cliente_tpersona ctp ON ctp.id_cia = c.id_cia
                                                        AND ctp.codcli = c.codcli
            WHERE
                    c.id_cia = pin_id_cia
                AND ( pin_codtpe IS NULL
                      OR ( c.codtpe = pin_codtpe ) )
                AND ( pin_codcli IS NULL
                      OR ( upper(c.codcli) LIKE upper(pin_codcli) ) )
                AND ( pin_dident IS NULL
                      OR ( upper(c.dident) LIKE upper(pin_dident) ) )
                AND ( pin_razonc IS NULL
                      OR ( pin_razonc IS NOT NULL
                           AND ( upper(c.razonc) LIKE upper(pin_razonc) ) )
                      OR ( pin_nombres IS NOT NULL
                           AND ( upper(
                    CASE
                        WHEN length(ctp.apepat) > 0 THEN
                            ctp.apepat || ' '
                        ELSE
                            ''
                    END
                    ||
                    CASE
                        WHEN length(ctp.apemat) > 0 THEN
                            ctp.apemat || ' '
                        ELSE
                            ''
                    END
                    ||
                    CASE
                        WHEN length(ctp.nombre) > 0 THEN
                            ctp.nombre || ' '
                        ELSE
                            ''
                    END
                ) LIKE upper(pin_nombres) ) ) )
            OFFSET pin_offset ROWS FETCH NEXT pin_limite ROWS ONLY;

            FOR registro IN 1..v_table.count LOOP
                PIPE ROW ( v_table(registro) );
            END LOOP;
            
            RETURN;

        end if;
        
        

        
    END sp_sel_interlocutor;

END pack_interlocutor;

/

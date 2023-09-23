--------------------------------------------------------
--  DDL for Package Body PACK_HELPCLIENTE
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_HELPCLIENTE" AS

    FUNCTION sp_sel_cliente (
        pin_id_cia    IN  NUMBER,
        pin_swactivo  IN  VARCHAR2,
        pin_codtpe    IN  NUMBER,
        pin_codcli    IN  VARCHAR2,
        pin_dident    IN  VARCHAR2,
        pin_razonc    IN  VARCHAR2,
        pin_nombres    IN  VARCHAR2,
        pin_offset    IN  NUMBER,
        pin_limite    IN  NUMBER
    ) RETURN t_cliente
        PIPELINED
    AS
        v_table t_cliente;
    BEGIN
--SELECT
--*
--FROM
--TABLE ( system.pack_helpcliente.sp_sel_cliente(99, NULL, NULL, NULL,'20258007370%', NULL,1,10) );
        SELECT
            c.codcli,
            c.tident,
            i.abrevi    AS tidentnombre,
            c.dident,
            c.razonc,
            c.codtit,
            c.direc1    AS direcc,
            c.codpag,
            (
                CASE
                    WHEN cl.codigo = '1' THEN
                        'S'
                    ELSE
                        'N'
                END
            ) AS clase_01,
            c.valident,
            c.codtpe,
            ctp.APEPAT as apellidoPaterno,
	      	ctp.APEMAT as apellidoMaterno,
	      	ctp.NOMBRE as nombres,
	      	case when ctp.ApePat is not null then ctp.ApePat else '' end  || 
            case when ctp.ApeMat is not null then ' ' || ctp.ApeMat else '' end  || 
            case when ctp.Nombre is not null then ' ' || ctp.Nombre else '' end as nombresCompletos
        BULK COLLECT
        INTO v_table
        FROM
                 cliente c
            INNER JOIN cliente_clase     cl ON cl.id_cia = c.id_cia
                                            AND cl.codcli = c.codcli
                                           AND cl.tipcli = 'A'
                                           AND cl.clase = 1
                                           AND ( ( pin_swactivo IS NULL )
                                                 OR ( cl.codigo = pin_swactivo ) )
            LEFT OUTER JOIN identidad         i ON i.id_cia = c.id_cia
                                           AND i.tident = c.tident
            LEFT OUTER JOIN cliente_tpersona  ctp ON ctp.id_cia = c.id_cia
                                                    AND ctp.codcli = c.codcli
        WHERE
                c.id_cia = pin_id_cia
            AND ( pin_codtpe IS NULL
                  OR ( c.codtpe = pin_codtpe ) )
            AND ( pin_codcli IS NULL
                  OR ( upper(c.codcli) LIKE upper(pin_codcli) ) )
            AND ( pin_dident IS NULL
                  OR ( upper(c.dident) LIKE upper(pin_dident) ) )
            AND ((pin_razonc is not null and  (upper(c.razonc) LIKE upper(pin_razonc) )) or
            (pin_nombres is not null and  (upper(CASE WHEN LENGTH(ctp.APEPAT)>0 THEN ctp.APEPAT||' ' ELSE '' END||
                     CASE WHEN LENGTH(ctp.APEMAT)>0 THEN ctp.APEMAT||' ' ELSE '' END||
                     CASE WHEN LENGTH(ctp.NOMBRE)>0  THEN ctp.NOMBRE||' ' ELSE '' END) LIKE upper(pin_nombres) )) 
            ) 
            
             

            
        OFFSET pin_offset ROWS FETCH NEXT pin_limite ROWS ONLY;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        return;
    END sp_sel_cliente;
    FUNCTION sp_sel_cliente_v2 (
        pin_id_cia    IN  NUMBER,
        pin_swactivo  IN  VARCHAR2,
        pin_codtpe    IN  NUMBER,
        pin_codcli    IN  VARCHAR2,
        pin_dident    IN  VARCHAR2,
        pin_razonc    IN  VARCHAR2,
        pin_offset    IN  NUMBER,
        pin_limite    IN  NUMBER
    ) RETURN t_cliente
        PIPELINED
    AS
        v_table t_cliente;
    BEGIN
--SELECT
--*
--FROM
--TABLE ( system.pack_helpcliente.sp_sel_cliente(99, NULL, NULL, NULL,'20258007370%', NULL,1,10) );
        SELECT
            c.codcli,
            c.tident,
            i.abrevi    AS tidentnombre,
            c.dident,
            c.razonc,
            c.codtit,
            c.direc1    AS direcc,
            c.codpag,
            (
                CASE
                    WHEN cl.codigo = '1' THEN
                        'S'
                    ELSE
                        'N'
                END
            ) AS clase_01,
            c.valident,
            c.codtpe,
                        ctp.APEPAT as apellidoPaterno,
	      	ctp.APEMAT as apellidoMaterno,
	      	ctp.NOMBRE as nombres,
	      	case when ctp.ApePat is not null then ctp.ApePat else '' end  || 
            case when ctp.ApeMat is not null then ' ' || ctp.ApeMat else '' end  || 
            case when ctp.Nombre is not null then ' ' || ctp.Nombre else '' end as nombresCompletos
        BULK COLLECT 
        INTO v_table
        FROM 
                 cliente c
            INNER JOIN cliente_clase     cl ON cl.id_cia = c.id_cia
                                           AND cl.codcli = c.codcli
                                           AND cl.tipcli = 'A'
                                           AND cl.clase = 1
                                           AND ( ( pin_swactivo IS NULL )
                                                 OR ( cl.codigo = pin_swactivo ) )
            LEFT OUTER JOIN identidad         i ON i.id_cia = c.id_cia
                                           AND i.tident = c.tident
            LEFT OUTER JOIN cliente_tpersona  ctp ON ctp.id_cia = c.id_cia
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
                  OR ( upper(c.razonc) LIKE upper(pin_razonc) ) 
            OR (UPPER( CASE WHEN LENGTH(ctp.APEPAT)>0 THEN ctp.APEPAT||' ' ELSE '' END||
                     CASE WHEN LENGTH(ctp.APEMAT)>0 THEN ctp.APEMAT||' ' ELSE '' END||
                     CASE WHEN LENGTH(ctp.NOMBRE)>0  THEN ctp.NOMBRE||' ' ELSE '' END
               ) LIKE UPPER(pin_razonc)))
        OFFSET pin_offset ROWS FETCH NEXT pin_limite ROWS ONLY;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        return;
    END sp_sel_cliente_v2;
    FUNCTION sp_sel_proveedor (
        pin_id_cia    IN  NUMBER,
        pin_swactivo  IN  VARCHAR2,
        pin_codtpe    IN  NUMBER,
        pin_codcli    IN  VARCHAR2,
        pin_dident    IN  VARCHAR2,
        pin_razonc    IN  VARCHAR2,
        pin_offset    IN  NUMBER,
        pin_limite    IN  NUMBER
    ) RETURN t_proveedor
        PIPELINED
    AS
        v_table t_proveedor;
    BEGIN
--SELECT
--*
--FROM
--TABLE ( system.pack_helpcliente.sp_sel_proveedor(99, NULL, NULL, NULL,'06804844%', NULL,1,10) );
        SELECT
            c.codcli    AS codpro,
            c.tident,
            i.abrevi    AS tidentnombre,
            c.dident,
            c.razonc,
            c.direc1    AS direcc,
            c.valident,
            c.codtpe
        BULK COLLECT
        INTO v_table
        FROM
                 cliente c
            INNER JOIN cliente_clase  cl ON cl.id_cia = c.id_cia
                                           AND cl.codcli = c.codcli
                                           AND cl.tipcli = 'B'
                                           AND cl.clase = 1
                                           AND ( ( pin_swactivo IS NULL )
                                                 OR ( cl.codigo = pin_swactivo ) )
            LEFT OUTER JOIN identidad      i ON i.id_cia = c.id_cia
                                           AND i.tident = c.tident
        WHERE
                c.id_cia = pin_id_cia
            AND ( pin_codcli IS NULL
                  OR ( upper(c.codcli) LIKE upper(pin_codcli) ) )
            AND ( pin_dident IS NULL
                  OR ( upper(c.dident) LIKE upper(pin_dident) ) )
            AND ( pin_razonc IS NULL
                  OR ( upper(c.razonc) LIKE upper(pin_razonc) ) )
        OFFSET pin_offset ROWS FETCH NEXT pin_limite ROWS ONLY;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        return;
    END sp_sel_proveedor;

    FUNCTION sp_sel_subcentrocosto (
        pin_id_cia    IN  NUMBER,
        pin_swactivo  IN  VARCHAR2,
        pin_codcli    IN  VARCHAR2,
        pin_dident    IN  VARCHAR2,
        pin_razonc    IN  VARCHAR2,
        pin_offset    IN  NUMBER,
        pin_limite    IN  NUMBER
    ) RETURN t_subcentrocosto
        PIPELINED
    AS
        v_table t_subcentrocosto;
    BEGIN
--SELECT
--*
--FROM
--TABLE ( system.pack_helpcliente.sp_sel_subcentrocosto(99, NULL, NULL,'06804844%', NULL,1,10) );
        SELECT
            c.id_cia,
            c.tipcli,
            c.codcli,
            c.razonc AS descri,
            c.tident,
            c.dident,
            c.valident,
            c.codtpe
        BULK COLLECT
        INTO v_table
        FROM
                 cliente c
            INNER JOIN cliente_clase cl ON cl.id_cia = c.id_cia
                                           AND cl.codcli = c.codcli
                                           AND cl.tipcli IN (
                'E',
                'O'
            )
                                           AND cl.clase = 1
                                           AND ( ( pin_swactivo IS NULL )
                                                 OR ( cl.codigo = pin_swactivo ) )
        WHERE
                c.id_cia = pin_id_cia
            AND ( pin_codcli IS NULL
                  OR ( upper(c.codcli) LIKE upper(pin_codcli) ) )
            AND ( pin_dident IS NULL
                  OR ( upper(c.dident) LIKE upper(pin_dident) ) )
            AND ( pin_razonc IS NULL
                  OR ( upper(c.razonc) LIKE upper(pin_razonc) ) )
        OFFSET pin_offset ROWS FETCH NEXT pin_limite ROWS ONLY;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        return;
    END sp_sel_subcentrocosto;

END;

/

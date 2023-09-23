--------------------------------------------------------
--  DDL for Package Body PACK_CONSULTAS_CXP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_CONSULTAS_CXP" AS

    FUNCTION sp_buscar (
        pin_id_cia NUMBER,
        pin_tipdoc VARCHAR2,
        pin_codcli VARCHAR2,
        pin_fdesde DATE,
        pin_fhasta DATE
    ) RETURN datatable_buscar
        PIPELINED
    AS
        v_table datatable_buscar;
    BEGIN
        SELECT
            p.id_cia,
            ( p.libro
              || ' - '
              || TRIM(to_char(p.periodo, '0000'))
              || TRIM(to_char(p.mes, '00'))
              || TRIM(to_char(p.secuencia, '000000')) ) AS planilla,
            p.libro,
            p.periodo,
            p.mes,
            p.secuencia,
            p.femisi,
            d.tipdoc,
            d.docume,
            d.refere01,
            d.refere02,
            d.femisi,
            d.fvenci,
            p.fproce,
            d.numbco,
            d.tipmon,
            p.impor01 * td.signo                      AS impor01,
            p.impor02 * td.signo                      AS impor02,
            d.codban,
            d.codcli,
            c.razonc,
            c.limcre1,
            c.limcre2,
            c.chedev,
            c.letpro,
            c.renova,
            c.refina,
            c.fecing,
            td.descri                                 AS dtipdoc,
            p.doccan,
            tc.descri                                 AS dtipcan
        BULK COLLECT
        INTO v_table
        FROM
                 prov101 p
            INNER JOIN prov100 d ON d.id_cia = p.id_cia
                                    AND d.tipo = p.tipo
                                    AND d.docu = p.docu
            LEFT OUTER JOIN cliente c ON c.id_cia = p.id_cia
                                         AND c.codcli = d.codcli
            INNER JOIN tdocume td ON td.id_cia = p.id_cia
                                     AND td.codigo = d.tipdoc
            INNER JOIN m_pago  tc ON tc.id_cia = p.id_cia
                                    AND tc.codigo = p.tipcan
        WHERE
                p.id_cia = pin_id_cia
            AND ( ( pin_fdesde IS NULL
                    AND pin_fhasta IS NULL )
                  OR p.femisi BETWEEN pin_fdesde AND pin_fhasta )
            AND d.situac = '2'
            AND ( pin_codcli IS NULL
                  OR d.codcli = pin_codcli )
            AND ( pin_tipdoc IS NULL OR td.codigo = pin_tipdoc )
        ORDER BY
            d.tipdoc,
            d.docume;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar;

END;

/

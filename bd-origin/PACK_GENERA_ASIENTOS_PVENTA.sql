--------------------------------------------------------
--  DDL for Package PACK_GENERA_ASIENTOS_PVENTA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_GENERA_ASIENTOS_PVENTA" AS
    TYPE rec_warning IS RECORD (
        procede  SMALLINT,
        mensaje  VARCHAR2(3500)
    );
    TYPE tbl_warning IS
        TABLE OF rec_warning;
    CURSOR cur_dcta102 (
        pid_cia   IN NUMBER,
		pid_libro IN varchar2,
        pfinicio  IN DATE,
        pffinal   IN DATE
    ) IS
    SELECT
        codsuc,
        libro,
        periodo,
        mes,
        secuencia,
        situac,
        femisi
    FROM
        dcta102
    WHERE
        situac IN (
            'B',
            'J',
            'A'
        )
        AND id_cia= pid_cia
        AND femisi >= pfinicio
        AND femisi <= pffinal
        AND libro = pid_libro;

    CURSOR cur_caja_cab (
        pid_cia   NUMBER,
        pfinicio  IN DATE,
        pffinal   IN DATE
    ) IS
    SELECT
        c.numcaja,
        c.codsuc,
        c.finicio,
        EXTRACT(YEAR FROM c.finicio)        AS periodo,
        EXTRACT(MONTH FROM c.finicio)       AS mes
    FROM
        dcta102_caja_cab c
    WHERE
            c.id_cia = pid_cia
        AND c.situac = 2 /*2-Aprobada*/
        AND trunc(c.finicio) BETWEEN pfinicio AND pffinal
    ORDER BY
        c.finicio,
        c.numcaja;

    TYPE tbl_cajacab IS
        TABLE OF cur_caja_cab%rowtype;
    CURSOR cur_compr010_tipo604 (
        pid_cia    NUMBER,
        pdoc_caja  NUMBER,
        pcod_suc   INTEGER
    ) IS
    SELECT
        c.asiento,
        c.moneda,
        c.tcamb01,
        c.tcamb02,
        td.codigo      AS tipdoc,
        td.descri      AS desdoc,
        mo.desmon      AS desmoneda,
        su.sucursal,
        td.codigo      AS tdoctipdoc,
        td.dh          AS tdocdh,
        tc01.codigo    AS clascodigo,
        mp.codigo      AS codmpag,
        mp.descri      AS desmpag,
        mp.dh          AS mpagdh,
        mp.dh2         AS mpagdh2,
        mpc.codban     AS mpagccodban,
        tb.descri      AS desbanco,
        tb.cuentacon,
        tdc.cuenta     AS cuentagastocaja
    FROM
        compr010        c
        LEFT OUTER JOIN tmoneda         mo ON mo.id_cia = c.id_cia
                                      AND mo.codmon = c.moneda
        LEFT OUTER JOIN sucursal        su ON su.id_cia = c.id_cia
                                       AND su.codsuc = pcod_suc
        LEFT OUTER JOIN tdocume         td ON td.id_cia = c.id_cia
                                      AND td.codigo = c.tdocum
        LEFT OUTER JOIN tdocume_clases  tc01 ON tc01.id_cia = c.id_cia
                                               AND tc01.tipdoc = c.tdocum
                                               AND tc01.clase = 1
        LEFT OUTER JOIN tdocume_caja    tdc ON tdc.id_cia = c.id_cia
                                            AND tdc.tipdoc = c.tdocum
                                            AND tdc.codsuc = pcod_suc
                                            AND tdc.moneda = c.moneda
        LEFT OUTER JOIN m_pago          mp ON mp.id_cia = c.id_cia
                                     AND mp.codigo = tc01.codigo
        LEFT OUTER JOIN m_pago_config   mpc ON mpc.id_cia = c.id_cia
                                             AND mpc.codigo = tc01.codigo
                                             AND mpc.codsuc = pcod_suc
                                             AND mpc.moneda = c.moneda
        LEFT OUTER JOIN tbancos         tb ON tb.id_cia = c.id_cia
                                      AND tb.codban = mpc.codban
    WHERE
        ( c.id_cia = pid_cia )
        AND ( c.tipcaja = 604 )
        AND ( c.doccaja = pdoc_caja )
        AND ( c.situac <> 9 );

    TYPE tbl_compr010_tipo604 IS
        TABLE OF cur_compr010_tipo604%rowtype;
    FUNCTION sp_sel_caja_cab (
        pid_cia   NUMBER,

        pfinicio  IN  DATE,
        pffinal   IN  DATE
    ) RETURN tbl_cajacab
        PIPELINED;

    FUNCTION sp_sel_compr010_tipo604 (
        pid_cia    NUMBER,
        pdoc_caja  NUMBER,
        pcod_suc   INTEGER
    ) RETURN tbl_compr010_tipo604
        PIPELINED;

    FUNCTION valida_cajatienda (
        pin_id_cia  IN  NUMBER,
        pin_fini    IN  DATE,
        pin_ffin    IN  DATE
    ) RETURN tbl_warning
        PIPELINED;

    PROCEDURE sp_genera_asiento_caja_tienda (
        pin_id_cia   IN  NUMBER,
        pin_fini     IN  DATE,
        pin_ffin     IN  DATE,
        pin_coduser  IN  VARCHAR2
    );

    PROCEDURE sp_genera_asiento_cobranza_tienda (
        pin_id_cia   IN  NUMBER,
		pid_libro    IN varchar2,
        pin_fini     IN  DATE,
        pin_ffin     IN  DATE,
        pin_coduser  IN  VARCHAR2
    );

END;

/

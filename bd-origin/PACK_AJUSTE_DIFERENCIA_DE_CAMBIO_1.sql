--------------------------------------------------------
--  DDL for Package Body PACK_AJUSTE_DIFERENCIA_DE_CAMBIO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_AJUSTE_DIFERENCIA_DE_CAMBIO" AS

    FUNCTION sp001_saca_solo_documentos_pagar_saldos_fecha (
        pin_id_cia  IN NUMBER,
        pin_codcli  IN VARCHAR2,
        pin_tipdocs IN VARCHAR2,
        pin_fecha   IN DATE,
        pin_tipo    IN NUMBER,
        pin_docu    IN NUMBER
    ) RETURN tbl_sp001_saca_solo_documentos_pagar_saldos_fecha
        PIPELINED
    AS

        rec            rec_sp001_saca_solo_documentos_pagar_saldos_fecha := rec_sp001_saca_solo_documentos_pagar_saldos_fecha(NULL, NULL,
        NULL, NULL, NULL,
                                                                                                                  NULL, NULL, NULL, NULL,
                                                                                                                  NULL,
                                                                                                                  NULL, NULL, NULL);
        wtipoant       INTEGER;
        wdocuant       INTEGER;
        swflag         VARCHAR(1);
        wxcodcli       VARCHAR(20);
        wxtipdoc       VARCHAR(02);
        wxdesdoc       VARCHAR(50);
        wxabrdoc       VARCHAR(06);
        wxdocume       VARCHAR(25);
        wxtipo         INTEGER;
        wxdocu         INTEGER;
        wxfemisi       DATE;
        wxfvenci       DATE;
        wxdh           VARCHAR(1);
        wxtipmon       VARCHAR(5);
        importedebe    NUMERIC(16, 4);
        importehaber   NUMERIC(16, 4);
        importedebe01  NUMERIC(16, 4);
        importehaber01 NUMERIC(16, 4);
        importedebe02  NUMERIC(16, 4);
        importehaber02 NUMERIC(16, 4);
        wdh_ori        VARCHAR(1);
        wtipmon_ori    VARCHAR(5);
        wimportedebe   NUMERIC(16, 4);
        wimportehaber  NUMERIC(16, 4);
    BEGIN


    -- TAREA: Se necesita implantación para FUNCTION PACK_AJUSTE_DIFERENCIA_DE_CAMBIO.SP001_SACA_SOLO_DOCUMENTOS_PAGAR_SALDOS_FECHA
        wxtipo := NULL;
        wxdocu := NULL;
        wtipoant := -666;
        wdocuant := -666;
        wdh_ori := '';
        wtipmon_ori := '';
        rec.saldo := 0;
        FOR i IN (
            SELECT
                codcli,
                swflag,
                tipdoc,
                abrdoc,
                desdoc,
                docume,
                tipo,
                docu,
                femisi,
                fvenci,
                dh,
                tipmon,
                importedebe,
                importehaber,
                importedebe01,
                importehaber01,
                importedebe02,
                importehaber02
            FROM
                sp000_saca_documentos_pagar_fecha(pin_id_cia, pin_codcli, pin_tipdocs, pin_fecha, pin_tipo,
                                                  pin_docu)
            ORDER BY
                codcli,
                tipo,
                docu,
                swflag,
                femisi
        ) LOOP
            wxcodcli := i.codcli;
            swflag := i.swflag;
            wxtipdoc := i.tipdoc;
            wxabrdoc := i.abrdoc;
            wxdesdoc := i.desdoc;
            wxdocume := i.docume;
            wxtipo := i.tipo;
            wxdocu := i.docu;
            wxfemisi := i.femisi;
            wxfvenci := i.fvenci;
            wxdh := i.dh;
            wxtipmon := i.tipmon;
            importedebe := i.importedebe;
            importehaber := i.importehaber;
            importedebe01 := i.importedebe01;
            importehaber01 := i.importehaber01;
            importedebe02 := i.importedebe02;
            importehaber02 := i.importehaber02;
            IF ( ( wtipoant <> wxtipo ) OR ( wdocuant <> wxdocu ) ) THEN

              --IF ((WTIPOANT<>-666)OR(WDOCUANT<>-666)) THEN 
              --  SUSPEND; 
              -- END IF;
                wtipoant := wxtipo;
                wdocuant := wxdocu;
                rec.codcli := wxcodcli;
                rec.tipdoc := wxtipdoc;
                rec.desdoc := wxdesdoc;
                rec.abrdoc := wxabrdoc;
                rec.docume := wxdocume;
                rec.tipo := wxtipo;
                rec.docu := wxdocu;
                rec.femisi := wxfemisi;
                rec.fvenci := wxfvenci;
                rec.dh := wxdh;
                rec.tipmon := wxtipmon;
            END IF;

            IF ( swflag = 'O' ) THEN
                wdh_ori := rec.dh;
                wtipmon_ori := rec.tipmon;
                rec.saldo := importedebe + importehaber;
            ELSE
                IF ( wtipmon_ori = wxtipmon ) THEN
                    wimportedebe := importedebe;
                    wimportehaber := importehaber;
                ELSE
                    IF ( wtipmon_ori = 'PEN' ) THEN
                        wimportedebe := importedebe01;
                        wimportehaber := importehaber01;
                    ELSE
                        wimportedebe := importedebe02;
                        wimportehaber := importehaber02;
                    END IF;
                END IF;

                IF ( wdh_ori = 'D' ) THEN
                    rec.saldo := rec.saldo + ( wimportedebe - wimportehaber );
                END IF;

                IF ( wdh_ori = 'H' ) THEN
                    rec.saldo := rec.saldo + ( wimportehaber - wimportedebe );
                END IF;

            END IF;

            PIPE ROW ( rec );
        END LOOP;


      /*  IF ((WXTIPO IS NOT NULL)AND(WXDOCU IS NOT NULL))THEN
           CODCLI=WXCODCLI;
           TIPDOC=WXTIPDOC;
           DOCUME=WXDOCUME;
           DESDOC=WXDESDOC;
           ABRDOC=WXABRDOC;
           TIPO  =WXTIPO;
           DOCU  =WXDOCU;
           FEMISI=WXFEMISI;
           FVENCI=WXFVENCI;
           DH    =WXDH;
           TIPMON=WXTIPMON;
           SUSPEND;
         END
     */


    END sp001_saca_solo_documentos_pagar_saldos_fecha;

    FUNCTION sp_sel_saldo_cuenta3 (
        pin_id_cia  IN NUMBER,
        pin_periodo IN NUMBER,
        pin_mes     IN NUMBER,
        pin_codtana IN NUMBER,
        pin_moneda  IN VARCHAR2
    ) RETURN tbl_sp_sel_saldo_cuenta3
        PIPELINED
    AS

        rec     rec_sp_sel_saldo_cuenta3 := rec_sp_sel_saldo_cuenta3(NULL, NULL, NULL, NULL, NULL,
                                                                NULL, NULL, NULL, NULL, NULL,
                                                                NULL, NULL, NULL, NULL, NULL,
                                                                NULL, NULL, NULL, NULL, NULL,
                                                                NULL, NULL, NULL);
        wfecini DATE;
        wfecfin DATE;
        wtemp   INTEGER;
        wlibro  VARCHAR(3);
        witems  INTEGER;
    BEGIN
    -- TAREA: Se necesita implantación para FUNCTION PACK_AJUSTE_DIFERENCIA_DE_CAMBIO.SP_SEL_SALDO_CUENTA3

        FOR i IN (
            SELECT
                p.cuenta,
                m.codigo,
                m.tdocum,
                m.serie,
                m.numero,
                SUM(m.debe01) - SUM(m.haber01) AS saldo01,
                SUM(m.debe02) - SUM(m.haber02) AS saldo02,
                MIN(m.fecha)                   AS wfecini,
                MAX(m.fecha)                   AS wfecfin,
                p.nombre,
                p.codtana,
                p.moneda01                     AS moncta01,
                p.moneda02                     AS moncta02
            FROM
                     movimientos m
                INNER JOIN pcuentas p ON p.id_cia = m.id_cia
                                         AND p.cuenta = m.cuenta
                                         AND p.codtana = pin_codtana
                                         AND p.moneda01 = pin_moneda
            WHERE
                    m.id_cia = pin_id_cia
                AND m.periodo = pin_periodo
                AND m.mes <= pin_mes
            GROUP BY
                p.cuenta,
                m.codigo,
                m.tdocum,
                m.serie,
                m.numero,
                p.nombre,
                p.codtana,
                p.moneda01,
                p.moneda02
            HAVING ( ( SUM(m.debe01) - SUM(m.haber01) ) <> 0 )
                   OR ( ( ( SUM(m.debe02) - SUM(m.haber02) ) <> 0 ) )
        ) LOOP
            rec.cuenta := i.cuenta;
            rec.codigo := i.codigo;
            rec.tdocum := i.tdocum;
            rec.serie := i.serie;
            rec.numero := i.numero;
            rec.saldo01 := i.saldo01;
            rec.saldo02 := i.saldo02;
            wfecini := i.wfecini;
            wfecfin := i.wfecfin;
            rec.nombre := i.nombre;
            rec.codtana := i.codtana;
            rec.moncta01 := i.moncta01;
            rec.moncta02 := i.moncta02;
            rec.moneda := pin_moneda;
            IF ( rec.saldo01 IS NULL ) THEN
                rec.saldo01 := 0;
            END IF;

            IF ( rec.saldo02 IS NULL ) THEN
                rec.saldo02 := 0;
            END IF;

            IF ( rec.codtana IS NULL ) THEN
                rec.codtana := 0;
            END IF;

            IF ( rec.moncta01 IS NULL ) THEN
                rec.moncta01 := 'PEN';
            END IF;

            IF ( rec.moncta02 IS NULL ) THEN
                rec.moncta02 := pin_moneda;
            END IF;

            /* SACA DATOS DEL DOCUMENTO ORIGINAL.. EL 1ER ASIENTO ... ¿¿OJO QUE PASARIA SI EL ASIENTO ES DE OTRO AÑO...??*/
--            DECLARE
--            BEGIN
--                SELECT DISTINCT MO.RAZON,   C.ABREVI,  MO.FDOCUM,
--                               MO.MONEDA,  M.SIMBOLO, MO.IMPORTE,
--                               MO.IMPOR01,MO.IMPOR02, MO.DH,MO.LIBRO
--                               INTO          REC.RAZON,    REC.ABREVI,    REC.FEMISI,
--                              REC.MONEDA,   REC.SIMBOLO,   REC.IMPORTE,
--                              REC.IMPOR01,  REC.IMPOR02,   REC.DH,     WLIBRO
--                FROM MOVIMIENTOS MO
--                LEFT OUTER JOIN TDOCUME     C    ON  C.ID_CIA = MO.ID_CIA AND C.CODIGO=MO.TDOCUM
--                LEFT OUTER JOIN TMONEDA     M    ON  M.ID_CIA = MO.ID_CIA AND M.CODMON=MO.MONEDA
--                WHERE MO.ID_CIA = PIN_ID_CIA 
--                AND ((PIN_PERIODO=0)OR(MO.PERIODO=PIN_PERIODO))AND(MO.FECHA=WFECINI)AND
--                       (MO.CUENTA= REC.CUENTA)AND(MO.CODIGO= REC.CODIGO)AND
--                       (MO.TDOCUM= REC.TDOCUM)AND(MO.SERIE = REC.SERIE) AND (MO.NUMERO=REC.NUMERO)
--               ORDER BY MO.LIBRO  /* SOLUCION PARA CUANDO TIENEN LA MISMA FECHA Y HAY QUE IDENTIFICAR LA PROVICION */
--               FETCH NEXT 1 ROWS ONLY;            
--               EXCEPTION
--               WHEN NO_DATA_FOUND THEN
--                     REC.RAZON := NULL;    
--                     REC.ABREVI := NULL;    
--                     REC.FEMISI := NULL;
--                     REC.MONEDA := NULL;   
--                     REC.SIMBOLO := NULL;   
--                     REC.IMPORTE := NULL;
--                     REC.IMPOR01 := NULL;  
--                     REC.IMPOR02 := NULL;   
--                     REC.DH := NULL;     
--                     WLIBRO  := NULL; 
--            END;


            /* SACA TIPO DE CAMBIO CONTABLE - AJUSTADO - FINAL - DEL SALDO */

            FOR i IN (
                SELECT DISTINCT
                    CASE
                        WHEN mf.moneda = rec.moneda THEN
                            mf.tcambio01
                        ELSE
                            CASE
                                WHEN mf.moneda = 'PEN' THEN
                                        mf.tcambio01 /
                                        CASE
                                            WHEN mf.tcambio02 = 0 THEN
                                                    1
                                            ELSE
                                                mf.tcambio02
                                        END
                                ELSE
                                    1
                            END
                    END                         AS tcambio01, /* TIPO DE CAMBIO FINAL - CONTABLE - SE AJUSTA CADA CIERTO TIEMPO */
                    CASE
                        WHEN mf.moneda = rec.moneda THEN
                            mf.tcambio02
                        ELSE
                            CASE
                                WHEN mf.moneda = 'PEN' THEN
                                        1
                                ELSE
                                    mf.tcambio02 /
                                    CASE
                                        WHEN mf.tcambio01 = 0 THEN
                                                    1
                                        ELSE
                                            mf.tcambio01
                                    END
                            END
                    END                         AS tcambio02,  /* TIPO DE CAMBIO FINAL - CONTABLE - SE AJUSTA CADA CIERTO TIEMPO */
                    mf.libro,
                    ( mf.item * 10 ) + mf.sitem AS items
                FROM
                    movimientos mf
                WHERE
                        mf.id_cia = pin_id_cia
                    AND ( ( pin_periodo = 0 )
                          OR ( mf.periodo = pin_periodo ) )
                    AND ( mf.fecha = wfecfin )
                    AND ( mf.cuenta = rec.cuenta )
                    AND ( mf.codigo = rec.codigo )
                    AND ( mf.tdocum = rec.tdocum )
                    AND ( mf.serie = rec.serie )
                    AND ( mf.numero = rec.numero )
                ORDER BY
                    mf.libro,
                    items
            ) LOOP
                rec.tcambio01 := i.tcambio01;
                rec.tcambio02 := i.tcambio02;
                wlibro := i.libro;
                witems := i.items;
            END LOOP;

            PIPE ROW ( rec );
        END LOOP;
    END sp_sel_saldo_cuenta3;

    FUNCTION sp001_saca_documentos_pagar_saldos_fecha (
        pin_id_cia  IN NUMBER,
        pin_codcli  IN VARCHAR2,
        pin_tipdocs IN VARCHAR2,
        pin_fecha   IN DATE,
        pin_tipo    IN NUMBER,
        pin_docu    IN NUMBER
    ) RETURN tbl_sp001_saca_documentos_pagar_saldos_fecha
        PIPELINED
    AS

        rec           rec_sp001_saca_documentos_pagar_saldos_fecha := rec_sp001_saca_documentos_pagar_saldos_fecha(NULL, NULL, NULL, NULL,
        NULL,
                                                                                                        NULL, NULL, NULL, NULL, NULL,
                                                                                                        NULL, NULL, NULL, NULL, NULL,
                                                                                                        NULL, NULL, NULL, NULL, NULL);
        wtipoant      INTEGER;
        wdocuant      INTEGER;
        wdh_ori       VARCHAR(1);
        wtipmon_ori   VARCHAR(5);
        wimportedebe  NUMERIC(16, 4);
        wimportehaber NUMERIC(16, 4);
    BEGIN
        wtipoant := NULL;
        wdocuant := NULL;
        wdh_ori := '';
        wtipmon_ori := '';
        rec.saldo := 0;
        FOR i IN (
            SELECT
                codcli,
                swflag,
                tipdoc,
                desdoc,
                abrdoc,
                docume,
                tipo,
                docu,
                femisi,
                fvenci,
                dh,
                tipmon,
                importedebe,
                importehaber,
                importedebe01,
                importehaber01,
                importedebe02,
                importehaber02
            FROM
                sp000_saca_documentos_pagar_fecha(pin_id_cia, pin_codcli, pin_tipdocs, pin_fecha, pin_tipo,
                                                  pin_docu)
            ORDER BY
                codcli,
                tipo,
                docu,
                swflag,
                femisi
        ) LOOP
            rec.codcli := i.codcli;
            rec.swflag := i.swflag;
            rec.tipdoc := i.tipdoc;
            rec.desdoc := i.desdoc;
            rec.abrdoc := i.abrdoc;
            rec.docume := i.docume;
            rec.tipo := i.tipo;
            rec.docu := i.docu;
            rec.femisi := i.femisi;
            rec.fvenci := i.fvenci;
            rec.dh := i.dh;
            rec.tipmon := i.tipmon;
            rec.importedebe := i.importedebe;
            rec.importehaber := i.importehaber;
            rec.importedebe01 := i.importedebe01;
            rec.importehaber01 := i.importehaber01;
            rec.importedebe02 := i.importedebe02;
            rec.importehaber02 := i.importehaber02;
            IF ( rec.swflag = 'O' ) THEN
                wdh_ori := rec.dh;
                wtipmon_ori := rec.tipmon;
                rec.saldo := rec.importedebe + rec.importehaber;
            ELSE
                IF ( wtipmon_ori = rec.tipmon ) THEN
                    wimportedebe := rec.importedebe;
                    wimportehaber := rec.importehaber;
                ELSE
                    IF ( wtipmon_ori = 'PEN' ) THEN
                        wimportedebe := rec.importedebe01;
                        wimportehaber := rec.importehaber01;
                    ELSE
                        wimportedebe := rec.importedebe02;
                        wimportehaber := rec.importehaber02;
                    END IF;
                END IF;

                IF ( wdh_ori = 'D' ) THEN
                    rec.saldo := rec.saldo + ( wimportedebe - wimportehaber );
                END IF;

                IF ( wdh_ori = 'H' ) THEN
                    rec.saldo := rec.saldo + ( wimportehaber - wimportedebe );
                END IF;

            END IF;

            PIPE ROW ( rec );
        END LOOP;

    END sp001_saca_documentos_pagar_saldos_fecha;

    FUNCTION sp000_saca_documentos_pagar_fecha (
        pin_id_cia  IN NUMBER,
        pin_codcli  IN VARCHAR2,
        pin_tipdocs IN VARCHAR2,
        pin_fecha   IN DATE,
        pin_tipo    IN NUMBER,
        pin_docu    IN NUMBER
    ) RETURN tbl_sp000_saca_documentos_pagar_fecha
        PIPELINED
    AS

        rec        rec_sp000_saca_documentos_pagar_fecha := rec_sp000_saca_documentos_pagar_fecha(NULL, NULL, NULL, NULL, NULL,
                                                                                          NULL, NULL, NULL, NULL, NULL,
                                                                                          NULL, NULL, NULL, NULL, NULL,
                                                                                          NULL, NULL, NULL, NULL);
        wtipodes   INTEGER;
        wtipohas   INTEGER;
        wdocudes   INTEGER;
        wdocuhas   INTEGER;
        wcodclides VARCHAR(20);
        wcodclihas VARCHAR(20);
        wtipdocs   VARCHAR(60);
    BEGIN
    -- TAREA: Se necesita implantación para FUNCTION PACK_AJUSTE_DIFERENCIA_DE_CAMBIO.SP001_SACA_DOCUMENTOS_PAGAR_SALDOS_FECHA
        wtipodes := 0;
        wtipohas := 9999999;
        wdocudes := 0;
        wdocuhas := 9999999;
        wcodclides := '';
        wcodclihas := 'Z';
        IF ( pin_tipdocs IS NULL ) THEN
            wtipdocs := 'XXX';
        END IF;
        IF (
            ( pin_tipo IS NOT NULL )
            AND ( pin_tipo > 0 )
        ) THEN
            wtipodes := pin_tipo;
            wtipohas := pin_tipo;
        END IF;

        IF (
            ( pin_docu IS NOT NULL )
            AND ( pin_docu > 0 )
        ) THEN
            wdocudes := pin_docu;
            wdocuhas := pin_docu;
        END IF;

        IF (
            ( pin_codcli IS NOT NULL )
            AND ( pin_codcli <> '' )
            AND ( upper(pin_codcli) <> 'ALL' )
        ) THEN
            wcodclides := pin_codcli;
            wcodclihas := pin_codcli;
        END IF;

        FOR i IN (
            SELECT
                d.codcli,
                'O'       AS swflag,
                d.tipdoc,
                td.descri AS desdoc,
                td.abrevi AS abrdoc,
                d.docume,
                d.tipo,
                d.docu,
                d.operac,
                d.femisi,
                d.fvenci,
                d.dh,
                d.tipmon,  /* PARA IGUALAR CON LOS PENDIENTES SIN FECHA ESTADO DE CUENTA */
                CASE
                    WHEN d.dh = 'D' THEN
                        d.importe * CAST(td.signo AS DOUBLE PRECISION)
                    ELSE
                        0
                END       AS importedebe,
                CASE
                    WHEN d.dh = 'H' THEN
                        d.importe * CAST(td.signo AS DOUBLE PRECISION)
                    ELSE
                        0
                END       AS importehaber,
                CASE
                    WHEN d.dh = 'D' THEN
                        d.importemn * CAST(td.signo AS DOUBLE PRECISION)
                    ELSE
                        0
                END       AS importedebe01,
                CASE
                    WHEN d.dh = 'H' THEN
                        d.importemn * CAST(td.signo AS DOUBLE PRECISION)
                    ELSE
                        0
                END       AS importehaber01,
                CASE
                    WHEN d.dh = 'D' THEN
                        d.importeme * CAST(td.signo AS DOUBLE PRECISION)
                    ELSE
                        0
                END       AS importedebe02,
                CASE
                    WHEN d.dh = 'H' THEN
                        d.importeme * CAST(td.signo AS DOUBLE PRECISION)
                    ELSE
                        0
                END       AS importehaber02
            FROM
                prov100 d
                LEFT OUTER JOIN tdocume td ON td.id_cia = d.id_cia
                                              AND td.codigo = d.tipdoc
            WHERE
                    d.id_cia = pin_id_cia
                AND ( d.femisi <= pin_fecha )
                AND ( CASE
                          WHEN d.tipo IS NULL THEN
                              0
                          ELSE
                              d.tipo
                      END >= wtipodes )
                AND ( CASE
                          WHEN d.tipo IS NULL THEN
                              0
                          ELSE
                              d.tipo
                      END <= wtipohas )
                AND ( CASE
                          WHEN d.docu IS NULL THEN
                              0
                          ELSE
                              d.docu
                      END >= wdocudes )
                AND ( CASE
                          WHEN d.docu IS NULL THEN
                              0
                          ELSE
                              d.docu
                      END <= wdocuhas )
                AND ( CASE
                          WHEN d.codcli IS NULL THEN
                              ''
                          ELSE
                              d.codcli
                      END >= wcodclides )
                AND ( CASE
                          WHEN d.codcli IS NULL THEN
                              ''
                          ELSE
                              d.codcli
                      END <= wcodclihas )
                AND ( ( wtipdocs = 'XXX' )
                      OR ( d.tipdoc IN (
                    SELECT
                        *
                    FROM
                        TABLE ( convert_in(wtipdocs) )
                ) ) )
        ) LOOP
            rec.codcli := i.codcli;
            rec.swflag := i.swflag;
            rec.tipdoc := i.tipdoc;
            rec.desdoc := i.desdoc;
            rec.abrdoc := i.abrdoc;
            rec.docume := i.docume;
            rec.tipo := i.tipo;
            rec.docu := i.docu;
            rec.operac := i.operac;
            rec.femisi := i.femisi;
            rec.fvenci := i.fvenci;
            rec.dh := i.dh;
            rec.tipmon := i.tipmon;
            rec.importedebe := i.importedebe;
            rec.importehaber := i.importehaber;
            rec.importedebe01 := i.importedebe01;
            rec.importehaber01 := i.importehaber01;
            rec.importedebe02 := i.importedebe02;
            rec.importehaber02 := i.importehaber02;
            PIPE ROW ( rec );
        END LOOP;


       -------------------------------

        FOR j IN (
            SELECT
                o.codcli,
                'P'                AS swflag,
                o.tipdoc,
                td.descri          AS desdoc,
                td.abrevi          AS abrdoc,
                o.docume,
                d.tipo,
                d.docu,
                o.operac,
                d.femisi,
                CAST(NULL AS DATE) AS fvenci,
                d.dh,
                d.tipmon,    /* PARA IGUALAR CON LOS PENDIENTES SIN FECHA ESTADO DE CUENTA */
                CASE
                    WHEN d.dh = 'D' THEN
                        d.importe * CAST(td.signo AS DOUBLE PRECISION)
                    ELSE
                        0
                END                AS importedebe,
                CASE
                    WHEN d.dh = 'H' THEN
                        d.importe * CAST(td.signo AS DOUBLE PRECISION)
                    ELSE
                        0
                END                AS importehaber,
                CASE
                    WHEN d.dh = 'D' THEN
                        d.impor01 * CAST(td.signo AS DOUBLE PRECISION)
                    ELSE
                        0
                END                AS importedebe01,
                CASE
                    WHEN d.dh = 'H' THEN
                        d.impor01 * CAST(td.signo AS DOUBLE PRECISION)
                    ELSE
                        0
                END                AS importehaber01,
                CASE
                    WHEN d.dh = 'D' THEN
                        d.impor02 * CAST(td.signo AS DOUBLE PRECISION)
                    ELSE
                        0
                END                AS importedebe02,
                CASE
                    WHEN d.dh = 'H' THEN
                        d.impor02 * CAST(td.signo AS DOUBLE PRECISION)
                    ELSE
                        0
                END                AS importehaber02
            FROM
                prov101 d
                LEFT OUTER JOIN prov100 o ON o.id_cia = d.id_cia
                                             AND o.tipo = d.tipo
                                             AND o.docu = d.docu
                LEFT OUTER JOIN tdocume td ON td.id_cia = o.id_cia
                                              AND td.codigo = o.tipdoc
            WHERE
                    d.id_cia = pin_id_cia
                AND ( CASE
                          WHEN d.tipo IS NULL THEN
                              0
                          ELSE
                              d.tipo
                      END >= wtipodes )
                AND ( CASE
                          WHEN d.tipo IS NULL THEN
                              0
                          ELSE
                              d.tipo
                      END <= wtipohas )
                AND ( CASE
                          WHEN d.docu IS NULL THEN
                              0
                          ELSE
                              d.docu
                      END >= wdocudes )
                AND ( CASE
                          WHEN d.docu IS NULL THEN
                              0
                          ELSE
                              d.docu
                      END <= wdocuhas )
                AND ( CASE
                          WHEN o.codcli IS NULL THEN
                              ''
                          ELSE
                              o.codcli
                      END >= wcodclides )
                AND ( CASE
                          WHEN o.codcli IS NULL THEN
                              ''
                          ELSE
                              o.codcli
                      END <= wcodclihas )
                AND ( d.femisi <= pin_fecha )
                AND
        /* NO SE USA (D.TIPCAN<=50) AND /* ESTOS SON POR OTROS MOTIVOS QUE NO DESCUENTAN SALDO IGUAL QUE SP_ACTUALIZA_SALDO_PROV100 */ ( (
                wtipdocs = 'XXX' )
                      OR ( o.tipdoc IN (
                    SELECT
                        *
                    FROM
                        TABLE ( convert_in(wtipdocs) )
                ) ) )
        ) LOOP
            rec.codcli := j.codcli;
            rec.swflag := j.swflag;
            rec.tipdoc := j.tipdoc;
            rec.desdoc := j.desdoc;
            rec.abrdoc := j.abrdoc;
            rec.docume := j.docume;
            rec.tipo := j.tipo;
            rec.docu := j.docu;
            rec.operac := j.operac;
            rec.femisi := j.femisi;
            rec.fvenci := j.fvenci;
            rec.dh := j.dh;
            rec.tipmon := j.tipmon;
            rec.importedebe := j.importedebe;
            rec.importehaber := j.importehaber;
            rec.importedebe01 := j.importedebe01;
            rec.importehaber01 := j.importehaber01;
            rec.importedebe02 := j.importedebe02;
            rec.importehaber02 := j.importehaber02;
            PIPE ROW ( rec );
        END LOOP;

    END sp000_saca_documentos_pagar_fecha;

    PROCEDURE x_tipo_analitica (
        pin_id_cia         IN NUMBER,
        pin_codtana        IN NUMBER,
        pin_codtana_descri IN VARCHAR2,
        pin_fecha          IN DATE,
        pin_tcambio_compra IN NUMBER,
        pin_tcambio_venta  IN NUMBER,
        pin_moneda         IN VARCHAR2,
        pin_codlib         IN VARCHAR2,
        pin_codprov        IN VARCHAR2,
        pin_coduser        IN VARCHAR2,
        pin_responsecode   OUT VARCHAR2,
        pin_response       OUT VARCHAR2
    ) AS

        v_periodo              NUMBER;
        v_mes                  NUMBER;
        v_cant_cuentas         NUMBER := 0;
        v_secuencia            NUMBER := 0;
        rec_asiendet           asiendet%rowtype;
        v_wimporte             NUMBER;
        v_witem                NUMBER := 0;

    -- DETALLE
        v_wtipcam2             NUMBER;
        v_wtipcam              NUMBER;
        v_wdh                  VARCHAR2(6);
        v_wmoneda              VARCHAR2(6);
        v_wmonedaa             VARCHAR2(6);
        v_ltc                  VARCHAR2(6);
        v_cia_moneda01         VARCHAR(5);
        v_mensaje_contabilizar VARCHAR2(1000);
    BEGIN
        v_periodo := extract(YEAR FROM pin_fecha);
        v_mes := extract(MONTH FROM pin_fecha);
        DECLARE BEGIN
            SELECT
                COUNT(*)
            INTO v_cant_cuentas
            FROM
                sp_sel_saldo_cuenta3(pin_id_cia, v_periodo, v_mes, pin_codtana, pin_moneda) s
            WHERE
                    0 = 0
                AND ( pin_codprov IS NULL
                      OR s.codigo = pin_codprov );

        EXCEPTION
            WHEN no_data_found THEN
                v_cant_cuentas := 0;
        END;

        dbms_output.put_line('A');
        IF ( v_cant_cuentas = 0 ) THEN
            pin_responsecode := '1.1';
            pin_response := 'No existen documentos pendientes a esta fecha ' || pin_fecha;
        ELSE
            SELECT
                moneda01
            INTO v_cia_moneda01
            FROM
                companias
            WHERE
                cia = pin_id_cia;

            dbms_output.put_line('B');
            sp00_saca_secuencia_libro(pin_id_cia, pin_codlib, v_periodo, v_mes, pin_coduser,
                                     1, v_secuencia);
            IF v_secuencia <= 0 THEN
                dbms_output.put_line('No se pudo obtener la secuencia del libro ' || pin_codlib);
            END IF;

            dbms_output.put_line('C ' || v_secuencia);



         -- inserta cabecera
            INSERT INTO asienhea (
                id_cia,
                periodo,
                mes,
                libro,
                asiento,
                concep,
                codigo,
                nombre,
                motivo,
                tasien,
                moneda,
                fecha,
                tcamb01,
                tcamb02,
                ncontab,
                situac,
                usuari,
                fcreac,
                factua,
                usrlck,
                codban,
                referencia,
                girara,
                serret,
                numret,
                ucreac
            ) VALUES (
                pin_id_cia,
                v_periodo,
                v_mes,
                pin_codlib,
                v_secuencia,
                'Dif. de cambio por analisis - ' || pin_codtana,
                NULL,
                NULL,
                '',
                66,
                pin_moneda,
                pin_fecha,
                NULL,
                NULL,
                NULL,
                2,
                pin_coduser,
                current_timestamp,
                current_timestamp,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                pin_coduser
            );

            COMMIT;


        -- inserta detalle
            FOR i IN (
                SELECT
                    s.cuenta,
                    s.nombre,
                    s.codigo,
                    s.tdocum,
                    s.serie,
                    s.numero,
                    s.saldo01,
                    s.saldo02,
                    s.abrevi,
                    s.femisi,
                    s.moneda,
                    s.simbolo,
                    s.importe,
                    s.impor01,
                    s.impor02,
                    s.tcambio01,
                    s.tcambio02,
                    s.dh,
                    s.razon
                FROM
                    sp_sel_saldo_cuenta3(pin_id_cia, v_periodo, v_mes, pin_codtana, pin_moneda) s
                WHERE
                        0 = 0
                    AND ( pin_codprov IS NULL
                          OR s.codigo = pin_codprov )
            ) LOOP
                rec_asiendet.id_cia := pin_id_cia;
                rec_asiendet.periodo := v_periodo;
                rec_asiendet.mes := v_mes;
                rec_asiendet.libro := pin_codlib;
                rec_asiendet.asiento := v_secuencia;
                rec_asiendet.fcreac := current_timestamp;
                rec_asiendet.factua := current_timestamp;
                rec_asiendet.concep := i.razon;
                rec_asiendet.fecha := pin_fecha;
                rec_asiendet.tasien := 66;
                rec_asiendet.cuenta := i.cuenta;
                rec_asiendet.tdocum := i.tdocum;
                rec_asiendet.serie := i.serie;
                rec_asiendet.numero := i.numero;
                rec_asiendet.fdocum := i.femisi;
                rec_asiendet.codigo := i.codigo;
                rec_asiendet.razon := i.razon;
                rec_asiendet.docume := -1;
                rec_asiendet.tcambio01 := 0;
                rec_asiendet.tcambio02 := 0;
                dbms_output.put_line('ITEM - '
                                     || rec_asiendet.item
                                     || ' '
                                     || i.moneda);

                IF
                    i.moneda IS NOT NULL
                    AND length(i.moneda) > 0
                THEN
                    v_wmoneda := 'USD';
                    IF v_wmoneda = v_cia_moneda01 THEN
                        v_wmonedaa := pin_moneda;
                    ELSE
                        v_wmonedaa := v_cia_moneda01;
                    END IF;

                    IF (
                        i.saldo01 < 0
                        AND i.saldo02 > 0
                    ) OR (
                        i.saldo01 > 0
                        AND i.saldo02 < 0
                    ) THEN
                        dbms_output.put_line('GENERA_A ');
                        IF i.saldo02 < 0 THEN
                            v_wtipcam := pin_tcambio_venta;
                            v_ltc := 'V';
                        ELSE
                            v_wtipcam := pin_tcambio_compra;
                            v_ltc := 'C';
                        END IF;

                        IF
                            ( i.tdocum = '07' OR i.tdocum = 'A1' )
                            AND NOT ( substr(i.cuenta, 1, 1) = '4' )
                        THEN
                            IF v_ltc = 'C' THEN
                                v_wtipcam := pin_tcambio_venta;
                            ELSE
                                v_wtipcam := pin_tcambio_compra;
                            END IF;
                        END IF;

                        sp_genera_asiento(rec_asiendet, 0, v_wmoneda, 'S', 'N',
                                         i.saldo01, i.saldo02, v_witem);

                        sp_genera_asiento(rec_asiendet, 0, v_wmonedaa, 'S', 'N',
                                         i.saldo01, i.saldo02, v_witem);

                        sp_genera_asiento(rec_asiendet, v_wtipcam, v_wmoneda, 'N', 'N',
                                         i.saldo01, i.saldo02, v_witem);


                             --   OK := Genera_Asiento(0, WMoneda, True) and
                              --  Genera_Asiento(0, WMonedaA, True) and
                              --  Genera_Asiento(WTipCam, WMoneda, False);
                    ELSE
                        dbms_output.put_line('GENERA_b ');
                        IF
                            i.saldo01 <> 0
                            AND i.saldo02 = 0
                        THEN
                            dbms_output.put_line('GENERA_b1 ');
                            v_wtipcam2 := 0;
                            sp_genera_asiento(rec_asiendet, v_wtipcam2, v_cia_moneda01, 'N', 'S',
                                             i.saldo01, i.saldo02, v_witem); 

                                --OK := Genera_Asiento(WTipCam2, Cia.Moneda01, False, True);

                        ELSE
                            dbms_output.put_line('GENERA_b2 ');
                            IF i.saldo02 < 0 THEN
                                v_wtipcam := pin_tcambio_venta;
                                v_ltc := 'V';
                            ELSE
                                v_wtipcam := pin_tcambio_compra;
                                v_ltc := 'C';
                            END IF;

                               -- { 2018-08-27 Solo para notas de credito y anticipos, se invierte la moneda }
                            IF ( i.tdocum = '07' ) OR ( i.tdocum = 'A1' )
                            AND NOT ( substr(i.cuenta, 1, 1) = '4' ) THEN
                                IF v_ltc = 'C' THEN
                                    v_wtipcam := pin_tcambio_venta;
                                ELSE
                                    v_wtipcam := pin_tcambio_compra;
                                END IF;
                            END IF;

                            v_wtipcam2 := 1;
                            IF abs(i.saldo02) <> 0 THEN
                                v_wtipcam2 := abs(i.saldo01) / abs(i.saldo02);
                            END IF;

                            IF v_wtipcam2 = 0 THEN
                                IF abs(i.tcambio02) <> 0 THEN
                                    v_wtipcam2 := i.tcambio01 / i.tcambio02;
                                END IF;
                            END IF;

                            sp_genera_asiento(rec_asiendet, v_wtipcam2, v_wmoneda, 'N', 'N',
                                             i.saldo01, i.saldo02, v_witem);

                            sp_genera_asiento(rec_asiendet, v_wtipcam, v_wmoneda, 'S', 'N',
                                             i.saldo01, i.saldo02, v_witem);


                                 --OK := Genera_Asiento(WTipCam2, WMoneda, False) and
                                 --   Genera_Asiento(WTipCam, WMoneda, True);

                        END IF;

                    END IF;

                END IF;

            END LOOP;

            COMMIT;
            sp_actualiza_ctas_cobrar_pagar(pin_id_cia, pin_codtana, pin_codtana_descri, pin_fecha, pin_tcambio_compra,
                                          pin_tcambio_venta, pin_moneda, v_cia_moneda01, pin_codprov);

            sp_contabilizar_asiento(pin_id_cia, pin_codlib, v_periodo, v_mes, v_secuencia,
                                   pin_coduser, v_mensaje_contabilizar);
            pin_responsecode := '1.0';
            pin_response := 'Asiento generado [ Libro: '
                            || pin_codlib
                            || ', Periodo: '
                            || v_periodo
                            || ', Mes: '
                            || v_mes
                            || ', Asiento: '
                            || v_secuencia
                            || ' ]';

        END IF;

    END x_tipo_analitica;



  /*

  FUNCTION SP_CUENTAS  (
              PIN_ID_CIA IN NUMBER,
            PIN_DOCU IN NUMBER
    ) RETURN  TBL_SP_CUENTAS  PIPELINED AS
  BEGIN
    -- TAREA: Se necesita implantación para FUNCTION PACK_AJUSTE_DIFERENCIA_DE_CAMBIO.SP_CUENTAS
    RETURN NULL;
  END SP_CUENTAS;

    */






    PROCEDURE sp_genera_asiento (
        rec_asiendet asiendet%rowtype,
        wtipcam      IN NUMBER,
        wmoneda      IN VARCHAR2,
        swinvierte   IN VARCHAR2 /* S OR N*/,
        swusasaldo01 IN VARCHAR2 /* S OR N*/,
        saldo01      IN NUMBER,
        saldo02      IN NUMBER,
        item         IN OUT NUMBER
    ) AS
        wimporte NUMBER := 0;
        wdh      VARCHAR2(1);
        rec      asiendet%rowtype;
    BEGIN
        rec := rec_asiendet;
        item := item + 1;
        IF swusasaldo01 = 'S' THEN
            wimporte := saldo01;
        ELSE
            wimporte := saldo02;
        END IF;

        IF wimporte < 0 THEN
            wdh := 'D';
        ELSE
            wdh := 'H';
        END IF;

        IF swinvierte = 'S' THEN
            CASE wdh
                WHEN 'D' THEN
                    wdh := 'H';
                WHEN 'H' THEN
                    wdh := 'D';
            END CASE;
        END IF;

        rec.moneda := wmoneda;
        IF rec.moneda = 'PEN' THEN
            rec.tcambio01 := 1;
            IF wtipcam > 0 THEN
                rec.tcambio02 := 1 / wtipcam;
            END IF;
        ELSE
            rec.tcambio01 := wtipcam;
            rec.tcambio02 := 1;
        END IF;

        rec.importe := abs(wimporte);
        rec.saldo := abs(wimporte);
        rec.impor01 := round(rec.importe * rec.tcambio01, 2);
        rec.impor02 := round(rec.importe * rec.tcambio02, 2);
        rec.debe := 0;
        rec.debe01 := 0;
        rec.debe02 := 0;
        rec.haber := 0;
        rec.haber01 := 0;
        rec.haber02 := 0;
        rec.dh := wdh;
        rec.item := item;
        rec.sitem := 0;
        CASE
            WHEN rec.dh = 'D' THEN
                rec.debe := rec.importe;
                rec.debe01 := rec.impor01;
                rec.debe02 := rec.impor02;
            WHEN rec.dh = 'H' THEN
                rec.haber := rec.importe;
                rec.haber01 := rec.impor01;
                rec.haber02 := rec.impor02;
        END CASE;

        INSERT INTO asiendet VALUES rec;

    END sp_genera_asiento;

    PROCEDURE sp_actualiza_ctas_cobrar_pagar (
        pin_id_cia         IN NUMBER,
        pin_codtana        IN NUMBER,
        pin_codtana_descri IN VARCHAR2,
        pin_fecha          IN DATE,
        pin_tcambio_compra IN NUMBER,
        pin_tcambio_venta  IN NUMBER,
        pin_moneda         IN VARCHAR2,
        pin_moneda_cia     IN VARCHAR2,
        pin_codprov        IN VARCHAR2
    ) AS
        wtipcam  NUMBER;
        wstring  VARCHAR2(120);
        v_existe VARCHAR2(1) := 'N';
    BEGIN
        wstring := pin_codtana_descri;
        IF (
            ( instr(upper(wstring), 'CUENTAS') > 0 )
            AND ( instr(upper(wstring), 'COBRAR') > 0 )
            AND ( instr(upper(wstring), 'CLIENTE') > 0 )
        ) THEN
            FOR i IN (
                SELECT
                    d.numint,
                    d.tipdoc,
                    d.docume,
                    d.refere01,
                    d.femisi,
                    d.fvenci,
                    d.situac,
                    d.codban,
                    c.codcli,
                    c.razonc,
                    c.limcre1,
                    c.limcre2,
                    d.cuenta,
                    d.dh,
                    td.codsunat,
                    c.chedev,
                    c.letpro,
                    c.renova,
                    c.refina,
                    c.fecing,
                    td.abrevi                                      AS dtido,
                    d.tipcam,
                    d.fcance,
                    d.numbco,
                    d.tipmon,
                    d.importe * CAST(td.signo AS DOUBLE PRECISION) AS importe,
                    CASE
                        WHEN d.tipmon = pin_moneda_cia THEN
                            ( ( d.importe - (
                                SELECT
                                    ( abs(CAST(SUM(p.impor01) AS DOUBLE PRECISION)) * 100 ) / 100
                                FROM
                                    dcta101 p
                                WHERE
                                    ( p.tipcan < 50 )
                                    AND ( p.numint = d.numint )
                                    AND ( p.femisi <= pin_fecha )
                            ) ) * CAST(td.signo AS DOUBLE PRECISION) )
                        ELSE
                            ( ( d.importe - (
                                SELECT
                                    ( abs(CAST(SUM(p.impor02) AS DOUBLE PRECISION)) * 100 ) / 100
                                FROM
                                    dcta101 p
                                WHERE
                                    ( p.tipcan < 50 )
                                    AND ( p.numint = d.numint )
                                    AND ( p.femisi <= pin_fecha )
                            ) ) * CAST(td.signo AS DOUBLE PRECISION) )
                    END                                            AS saldox
                FROM
                         dcta100 d
                    INNER JOIN cliente      c ON c.id_cia = d.id_cia
                                            AND c.codcli = d.codcli
                    INNER JOIN tdoccobranza td ON td.id_cia = d.id_cia
                                                  AND td.tipdoc = d.tipdoc
                WHERE
                    ( d.id_cia = pin_id_cia )
                    AND ( d.femisi <= pin_fecha )
                    AND d.tipmon = pin_moneda
                    AND ( (
                        CASE
                            WHEN d.tipmon = pin_moneda_cia THEN
                                d.importe - (
                                    SELECT
                                        ( abs(CAST(SUM(p.impor01) AS DOUBLE PRECISION)) * 100 ) / 100
                                    FROM
                                        dcta101 p
                                    WHERE
                                        ( p.tipcan < 50 )
                                        AND ( p.numint = d.numint )
                                        AND ( p.femisi <= pin_fecha )
                                )
                            ELSE
                                d.importe - (
                                    SELECT
                                        ( abs(CAST(SUM(p.impor02) AS DOUBLE PRECISION)) * 100 ) / 100
                                    FROM
                                        dcta101 p
                                    WHERE
                                        ( p.tipcan < 50 )
                                        AND ( p.numint = d.numint )
                                        AND ( p.femisi <= pin_fecha )
                                )
                        END
                    ) <> 0 )
                    AND ( pin_codprov IS NULL
                          OR d.codcli = pin_codprov )
                ORDER BY
                    c.codcli,
                    d.tipdoc,
                    d.docume
            ) LOOP
                IF i.dh = 'H' THEN
                    wtipcam := pin_tcambio_venta;
                ELSE
                    wtipcam := pin_tcambio_compra;
                END IF;

                IF i.tipdoc = 7 OR i.tipdoc = 9 THEN
                    wtipcam := pin_tcambio_compra;
                END IF;

                IF i.situac <> 'J' THEN
                        -- Actualiza_Documento_CtaxCobrar(pin_id_cia);
                    UPDATE dcta100
                    SET
                        tipcam = wtipcam
                    WHERE
                            id_cia = pin_id_cia
                        AND numint = i.numint;

                END IF;

            END LOOP;

        ELSIF (
            ( instr(upper(wstring), 'CUENTAS') > 0 )
            AND ( instr(upper(wstring), 'PAGAR') > 0 )
            AND ( instr(upper(wstring), 'PROVEEDOR') > 0 )
        ) THEN
            FOR i IN (
                SELECT
                    EXTRACT(YEAR FROM p.fvenci)  AS periodo,
                    EXTRACT(MONTH FROM p.fvenci) AS mes,
                    p.tipdoc,
                    p.docume,
                    d.refere01,
                    p.femisi,
                    p.fvenci,
                    d.fcance,
                    d.numbco,
                    p.tipmon,
                    d.importe,
                    d.codsuc,
                    p.saldo                      AS saldox,
                    d.codban,
                    p.codcli,
                    c.razonc,
                    c.limcre1,
                    c.limcre2,
                    c.chedev,
                    c.letpro,
                    c.renova,
                    c.refina,
                    c.fecing,
                    p.abrdoc                     AS dtido,
                    p.desdoc                     AS destipdoc,
                    b.descri                     AS desban,
                    d.operac,
                    d.dh,
                    p.tipo,
                    p.docu,
                    d.cuenta,
                    m.nombre                     AS descuenta
                FROM
                    sp001_saca_solo_documentos_pagar_saldos_fecha(pin_id_cia, pin_codprov, NULL, pin_fecha, NULL,
                                                                  NULL) p
                    LEFT OUTER JOIN prov100                                             d ON d.id_cia = pin_id_cia
                                                 AND d.tipo = p.tipo
                                                 AND d.docu = p.docu
                    LEFT OUTER JOIN cliente                                             c ON c.id_cia = d.id_cia
                                                 AND c.codcli = d.codcli
                    LEFT OUTER JOIN tbancos                                             b ON b.id_cia = d.id_cia
                                                 AND b.codban = d.codban
                    LEFT OUTER JOIN pcuentas                                            m ON m.id_cia = d.id_cia
                                                  AND m.cuenta = d.cuenta
                WHERE
                    ( d.id_cia = pin_id_cia )
                    AND ( d.tipmon = pin_moneda )
                    AND p.saldo <> 0
                ORDER BY
                    d.cuenta,
                    d.codcli,
                    d.codsuc,
                    d.tipdoc,
                    d.femisi,
                    d.docume
            ) LOOP
                IF i.dh = 'H' THEN
                    wtipcam := pin_tcambio_venta;
                ELSE
                    wtipcam := pin_tcambio_compra;
                END IF;

                IF i.tipdoc = '07' OR i.tipdoc = 'A1' THEN
                    wtipcam := pin_tcambio_venta;
                END IF;

             -- Actualiza_Documento_CtaxPagar(pin_id_cia);

                UPDATE prov100
                SET
                    tipcam = wtipcam
                WHERE
                        id_cia = pin_id_cia
                    AND tipo = i.tipo
                    AND docu = i.docu;

            END LOOP;
        END IF;

    END sp_actualiza_ctas_cobrar_pagar;

    PROCEDURE x_cuenta (
        pin_id_cia         IN NUMBER,
        pin_fecha          IN DATE,
        pin_tcambio_compra IN NUMBER,
        pin_tcambio_venta  IN NUMBER,
        pin_moneda         IN VARCHAR2,
        pin_codlib         IN VARCHAR2,
        pin_cuentas        IN VARCHAR2,
        pin_coduser        IN VARCHAR2,
        pin_responsecode   OUT VARCHAR2,
        pin_response       OUT VARCHAR2
    ) AS

        v_periodo              NUMBER;
        v_mes                  NUMBER;
        v_secuencia            NUMBER := 0;
        rec_asiendet           asiendet%rowtype;
        v_cia_moneda01         VARCHAR2(3);
        v_cia_moneda02         VARCHAR2(3);
        wmoneda                VARCHAR2(3);
        wmonedaa               VARCHAR2(3);
        saldo01                NUMBER;
        saldo02                NUMBER;
        saldoasiento           NUMBER;
        wtipcam                NUMBER;
        wdh                    VARCHAR2(1);
        v_mensaje_contabilizar VARCHAR2(1000);
        v_witem                NUMBER := 0;
        v_cant_cuentas         NUMBER := 0;
    BEGIN
        v_periodo := extract(YEAR FROM pin_fecha);
        v_mes := extract(MONTH FROM pin_fecha);
        DECLARE BEGIN
            SELECT
                COUNT(*) as
            INTO v_cant_cuentas
            FROM
                movimientos m
            WHERE
                    m.id_cia = pin_id_cia
                AND m.cuenta IN (
                    SELECT
                        *
                    FROM
                        TABLE ( convert_in(pin_cuentas) )
                )
                AND m.periodo = v_periodo
                AND m.mes <= v_mes;

        EXCEPTION
            WHEN no_data_found THEN
                v_cant_cuentas := 0;
        END;

        IF v_cant_cuentas = 0 THEN
            pin_responsecode := '1.1';
            pin_response := 'No existen documentos pendientes a esta fecha ' || pin_fecha;
        ELSE
            SELECT
                moneda01,
                moneda02
            INTO
                v_cia_moneda01,
                v_cia_moneda02
            FROM
                companias
            WHERE
                cia = pin_id_cia;

            sp00_saca_secuencia_libro(pin_id_cia, pin_codlib, v_periodo, v_mes, pin_coduser,
                                     1, v_secuencia);
            IF v_secuencia <= 0 THEN
                dbms_output.put_line('No se pudo obtener la secuencia del libro ' || pin_codlib);
            END IF;   




         -- inserta cabecera

            INSERT INTO asienhea (
                id_cia,
                periodo,
                mes,
                libro,
                asiento,
                concep,
                codigo,
                nombre,
                motivo,
                tasien,
                moneda,
                fecha,
                tcamb01,
                tcamb02,
                ncontab,
                situac,
                usuari,
                fcreac,
                factua,
                usrlck,
                codban,
                referencia,
                girara,
                serret,
                numret,
                ucreac
            ) VALUES (
                pin_id_cia,
                v_periodo,
                v_mes,
                pin_codlib,
                v_secuencia,
                SUBSTR('Dif. de cambio por cuenta - ' || pin_cuentas,1,140),
                NULL,
                NULL,
                '',
                66,
                pin_moneda,
                pin_fecha,
                NULL,
                NULL,
                NULL,
                2,
                pin_coduser,
                current_timestamp,
                current_timestamp,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                pin_coduser
            );

            COMMIT;
            FOR i IN (
                SELECT
                    m.cuenta,
                    'PEN'                      moneda,
                    0                          tcambio01,
                    0                          tcambio02,
                    SUM(debe01) - SUM(haber01) saldo01,
                    SUM(debe02) - SUM(haber02) saldo02
                FROM
                    movimientos m
                WHERE
                        m.id_cia = pin_id_cia
                    AND m.cuenta IN (
                        SELECT
                            *
                        FROM
                            TABLE ( convert_in(pin_cuentas) )
                    )
                    AND m.periodo = v_periodo
                    AND m.mes <= v_mes
                GROUP BY
                    m.cuenta
                HAVING ( ( SUM(m.debe01) - SUM(m.haber01) ) <> 0 )
                       OR ( ( ( SUM(m.debe02) - SUM(m.haber02) ) <> 0 ) )
            ) LOOP
                v_witem := v_witem + 1;
                wmoneda := i.moneda;
                saldo01 := i.saldo01;
                saldo02 := i.saldo02;
                IF wmoneda = v_cia_moneda01 THEN
                    wmonedaa := v_cia_moneda02;
                ELSE
                    wmonedaa := v_cia_moneda01;
                END IF;

                IF saldo02 < 0 THEN
                    wtipcam := pin_tcambio_venta;
                ELSE
                    wtipcam := pin_tcambio_compra;
                END IF;

                IF saldo02 = 0 THEN
                    saldoasiento := ( saldo01 ) * -1;
                ELSE
                    saldoasiento := ( saldo02 * wtipcam ) - ( saldo01 );
                END IF;

                IF saldoasiento < 0 THEN
                    wdh := 'H';
                ELSE
                    wdh := 'D';
                END IF;

                rec_asiendet.id_cia := pin_id_cia;
                rec_asiendet.periodo := v_periodo;
                rec_asiendet.mes := v_mes;
                rec_asiendet.libro := pin_codlib;
                rec_asiendet.asiento := v_secuencia;
                rec_asiendet.item := v_witem;
                rec_asiendet.sitem := 0;
                rec_asiendet.fcreac := current_timestamp;
                rec_asiendet.factua := current_timestamp;
                rec_asiendet.concep := 'Ajuste por diferencia de cambio por cuenta';
                rec_asiendet.fecha := pin_fecha;
                rec_asiendet.tasien := 66;
                rec_asiendet.cuenta := i.cuenta;
                rec_asiendet.moneda := 'PEN';
                rec_asiendet.dh := wdh;
                rec_asiendet.docume := -1;
                rec_asiendet.tcambio01 := 0;
                rec_asiendet.tcambio02 := 0;
                rec_asiendet.debe := 0;
                rec_asiendet.debe01 := 0;
                rec_asiendet.debe02 := 0;
                rec_asiendet.haber := 0;
                rec_asiendet.haber01 := 0;
                rec_asiendet.haber02 := 0;
                IF rec_asiendet.moneda = 'PEN' THEN
                    rec_asiendet.tcambio01 := 1;
                    IF wtipcam > 0 THEN
                        rec_asiendet.tcambio02 := 1 / wtipcam;
                    END IF;
                ELSE
                    rec_asiendet.tcambio01 := wtipcam;
                    rec_asiendet.tcambio02 := 1;
                END IF;

                rec_asiendet.importe := abs(saldoasiento);
                rec_asiendet.saldo := abs(saldoasiento);
                rec_asiendet.impor01 := round(rec_asiendet.importe * rec_asiendet.tcambio01, 2);
                rec_asiendet.impor02 := 0.0;
                CASE
                    WHEN rec_asiendet.dh = 'D' THEN
                        rec_asiendet.debe := rec_asiendet.importe;
                        rec_asiendet.debe01 := rec_asiendet.impor01;
                        rec_asiendet.debe02 := rec_asiendet.impor02;
                    WHEN rec_asiendet.dh = 'H' THEN
                        rec_asiendet.haber := rec_asiendet.importe;
                        rec_asiendet.haber01 := rec_asiendet.impor01;
                        rec_asiendet.haber02 := rec_asiendet.impor02;
                END CASE;

                INSERT INTO asiendet VALUES rec_asiendet;

            END LOOP;

            COMMIT;
            sp_contabilizar_asiento(pin_id_cia, pin_codlib, v_periodo, v_mes, v_secuencia,
                                   pin_coduser, v_mensaje_contabilizar);
            pin_responsecode := '1.0';
            pin_response := 'Asiento generado [ Libro: '
                            || pin_codlib
                            || ', Periodo: '
                            || v_periodo
                            || ', Mes: '
                            || v_mes
                            || ', Asiento: '
                            || v_secuencia
                            || ' ]';

        END IF;

    END x_cuenta;

    PROCEDURE dolarizacion_cuentas_soles (
        pin_id_cia         IN NUMBER,
        pin_fecha          IN DATE,
        pin_tcambio_compra IN NUMBER,
        pin_tcambio_venta  IN NUMBER,
        pin_moneda         IN VARCHAR2,
        pin_codlib         IN VARCHAR2,
        pin_coduser        IN VARCHAR2,
        pin_responsecode   OUT VARCHAR2,
        pin_response       OUT VARCHAR2
    ) AS

        v_periodo              NUMBER;
        v_mes                  NUMBER;
        v_secuencia            NUMBER := 0;
        v_witem                NUMBER := 0;
        v_cant_cuentas         NUMBER := 0;
        wmoneda                VARCHAR2(3);
        wmonedaa               VARCHAR2(3);
        saldo01                NUMBER;
        saldo02                NUMBER;
        wtipcam                NUMBER;
        saldoasiento           NUMBER;
        wdh                    VARCHAR2(1);
        rec_asiendet           asiendet%rowtype;
        v_mensaje_contabilizar VARCHAR2(1000);
    BEGIN
        v_periodo := extract(YEAR FROM pin_fecha);
        v_mes := extract(MONTH FROM pin_fecha);
        DECLARE BEGIN
            SELECT
                COUNT(*) as
            INTO v_cant_cuentas
            FROM
                     movimientos m
                INNER JOIN pcuentas_clase p ON p.id_cia = m.id_cia
                                               AND p.cuenta = m.cuenta
                                               AND p.clase = 12
                                               AND p.swflag = 'S'
            WHERE
                    m.id_cia = pin_id_cia
                AND m.periodo = v_periodo
                AND m.mes <= v_mes;

        EXCEPTION
            WHEN no_data_found THEN
                v_cant_cuentas := 0;
        END;

        IF v_cant_cuentas = 0 THEN
            pin_responsecode := '1.1';
            pin_response := 'No existen documentos pendientes a esta fecha ' || pin_fecha;
        ELSE
            sp00_saca_secuencia_libro(pin_id_cia, pin_codlib, v_periodo, v_mes, pin_coduser,
                                     1, v_secuencia);
            IF v_secuencia <= 0 THEN
                dbms_output.put_line('No se pudo obtener la secuencia del libro ' || pin_codlib);
            END IF;   

         -- inserta cabecera

            INSERT INTO asienhea (
                id_cia,
                periodo,
                mes,
                libro,
                asiento,
                concep,
                codigo,
                nombre,
                motivo,
                tasien,
                moneda,
                fecha,
                tcamb01,
                tcamb02,
                ncontab,
                situac,
                usuari,
                fcreac,
                factua,
                usrlck,
                codban,
                referencia,
                girara,
                serret,
                numret,
                ucreac
            ) VALUES (
                pin_id_cia,
                v_periodo,
                v_mes,
                pin_codlib,
                v_secuencia,
                'Ajuste de dolarización por cuentas soles',
                NULL,
                NULL,
                '',
                66,
                'PEN',
                pin_fecha,
                NULL,
                NULL,
                NULL,
                2,
                pin_coduser,
                current_timestamp,
                current_timestamp,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                pin_coduser
            );

            COMMIT;
            FOR i IN (
                SELECT
                    m.cuenta,
                    'PEN'                      moneda,
                    0                          tcambio01,
                    0                          tcambio02,
                    SUM(debe01) - SUM(haber01) saldo01,
                    SUM(debe02) - SUM(haber02) saldo02
                FROM
                         movimientos m
                    INNER JOIN pcuentas_clase p ON p.id_cia = m.id_cia
                                                   AND p.cuenta = m.cuenta
                                                   AND p.clase = 12
                                                   AND p.swflag = 'S'
                WHERE
                        m.id_cia = pin_id_cia
                    AND m.periodo = v_periodo
                    AND m.mes <= v_mes
                GROUP BY
                    m.cuenta,
                    'PEN',
                    0
            ) LOOP
                v_witem := v_witem + 1;
                wmoneda := 'USD';
                saldo01 := i.saldo01;
                saldo02 := i.saldo02;
                IF saldo01 < 0 THEN
                    wtipcam := pin_tcambio_venta;
                ELSE
                    wtipcam := pin_tcambio_compra;
                END IF;

                saldoasiento := round(saldo01 / wtipcam, 2) - saldo02;
                IF saldoasiento < 0 THEN
                    wdh := 'H';
                ELSE
                    wdh := 'D';
                END IF;

                rec_asiendet.id_cia := pin_id_cia;
                rec_asiendet.periodo := v_periodo;
                rec_asiendet.mes := v_mes;
                rec_asiendet.libro := pin_codlib;
                rec_asiendet.asiento := v_secuencia;
                rec_asiendet.item := v_witem;
                rec_asiendet.sitem := 0;
                rec_asiendet.fcreac := current_timestamp;
                rec_asiendet.factua := current_timestamp;
                rec_asiendet.concep := 'Ajuste de dolarización por cuenta';
                rec_asiendet.fecha := pin_fecha;
                rec_asiendet.tasien := 66;
                rec_asiendet.cuenta := i.cuenta;
                rec_asiendet.moneda := 'USD';
                rec_asiendet.dh := wdh;
                rec_asiendet.docume := -1;
                rec_asiendet.tcambio01 := 0;
                rec_asiendet.tcambio02 := 0;
                rec_asiendet.debe := 0;
                rec_asiendet.debe01 := 0;
                rec_asiendet.debe02 := 0;
                rec_asiendet.haber := 0;
                rec_asiendet.haber01 := 0;
                rec_asiendet.haber02 := 0;
                IF rec_asiendet.moneda = 'PEN' THEN
                    rec_asiendet.tcambio01 := 1;
                    IF wtipcam > 0 THEN
                        rec_asiendet.tcambio02 := 1 / wtipcam;
                    END IF;
                ELSE
                    rec_asiendet.tcambio01 := wtipcam;
                    rec_asiendet.tcambio02 := 1;
                END IF;

                rec_asiendet.importe := abs(saldoasiento);
                rec_asiendet.saldo := abs(saldoasiento);
                rec_asiendet.impor01 := 0;-- round(rec_asiendet.importe * rec_asiendet.tcambio01, 2);
                rec_asiendet.impor02 := round(rec_asiendet.importe * rec_asiendet.tcambio02, 2);
                CASE
                    WHEN rec_asiendet.dh = 'D' THEN
                        rec_asiendet.debe := rec_asiendet.importe;
                        rec_asiendet.debe01 := rec_asiendet.impor01;
                        rec_asiendet.debe02 := rec_asiendet.impor02;
                    WHEN rec_asiendet.dh = 'H' THEN
                        rec_asiendet.haber := rec_asiendet.importe;
                        rec_asiendet.haber01 := rec_asiendet.impor01;
                        rec_asiendet.haber02 := rec_asiendet.impor02;
                END CASE;

                INSERT INTO asiendet VALUES rec_asiendet;

            END LOOP;

            COMMIT;
            sp_contabilizar_asiento(pin_id_cia, pin_codlib, v_periodo, v_mes, v_secuencia,
                                   pin_coduser, v_mensaje_contabilizar);
            pin_responsecode := '1.0';
            pin_response := 'Asiento generado [ Libro: '
                            || pin_codlib
                            || ', Periodo: '
                            || v_periodo
                            || ', Mes: '
                            || v_mes
                            || ', Asiento: '
                            || v_secuencia
                            || ' ]';

        END IF;

    END dolarizacion_cuentas_soles;

END pack_ajuste_diferencia_de_cambio;

/

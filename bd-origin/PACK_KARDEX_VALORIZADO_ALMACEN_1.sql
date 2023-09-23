--------------------------------------------------------
--  DDL for Package Body PACK_KARDEX_VALORIZADO_ALMACEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_KARDEX_VALORIZADO_ALMACEN" AS

    FUNCTION sp_ingreso_salida (
        pin_id_cia   INTEGER,
        pin_tipinv   INTEGER,
        pin_codalm   NUMBER,
        pin_codart   VARCHAR2,
        pin_anio     INTEGER,
        pin_mes      INTEGER,
        pin_moneda   VARCHAR2,
        pin_codadd01 VARCHAR2,
        pin_codadd02 VARCHAR2
    ) RETURN datatable_kardex_valorizado
        PIPELINED
    AS

        v_record        datarecord_kardex_valorizado := datarecord_kardex_valorizado(NULL, NULL, NULL, NULL, NULL,
                                                                             NULL, NULL, NULL, NULL, NULL,
                                                                             NULL, NULL, NULL, NULL, NULL,
                                                                             NULL, NULL, NULL, NULL, NULL,
                                                                             NULL, NULL, NULL, NULL, NULL,
                                                                             NULL, NULL, NULL, NULL, NULL,
                                                                             NULL, NULL, NULL);
        v_priorperiod   INTEGER;
        v_currentperiod INTEGER;
        CURSOR cur_select (
            panterior INTEGER,
            pactual   INTEGER
        ) IS
        SELECT
            a.tipinv,
            ti.dtipinv,
            ac2.codigo             AS codfam,
            ac2.desclase           AS desfam,
            ac3.codigo             AS codlin,
            ac3.desclase           AS deslin,
            a.codart,
            a.descri               AS desart,
            u.abrevi               AS codunisunat,
            ka.id,
            mc.valor               AS tipope,
            mo.abrevi              AS abrmot,
            mo.desmot              AS desmot,
            ka.numint,
            ka.numite,
            dcl.codcla             AS tipdoc,
            dc.series,
            dc.numdoc,
            dt.abrevi              AS desdoc,
            dc.femisi,
            ka.codalm,
            al.descri              AS desalm,
            al.abrevi              AS abralm,
            mn.desmon,
            mn.simbolo,
            si.ingreso - si.salida AS stockini,
            CASE
                WHEN ka.id = 'I' THEN
                    ka.cantid
                ELSE
                    0
            END                    AS caning,
            CASE
                WHEN ka.id = 'S' THEN
                    ka.cantid
                ELSE
                    0
            END                    AS cansal,
            sf.ingreso - sf.salida AS stockfinal,
            ti.cuenta              AS ctatinv,
            pc.nombre              AS desctatinv,
            NULL                   AS codadd01,
            NULL                   AS dcodadd01,
            NULL                   AS codadd02,
            NULL                   AS dcodadd02,
            nvl(mk.valor, 'N')     AS mc46
        FROM
            articulos                                                              a
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(a.id_cia, a.tipinv, a.codart, 2) ac2 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(a.id_cia, a.tipinv, a.codart, 3) ac3 ON 0 = 0
            LEFT OUTER JOIN t_inventario                                                           ti ON ti.id_cia = a.id_cia
                                               AND ti.tipinv = a.tipinv
            LEFT OUTER JOIN pcuentas                                                               pc ON pc.id_cia = a.id_cia
                                           AND pc.cuenta = ti.cuenta
            -- SOLO ARTICULO CON MOVIMIENTO EN EL PERIODO ACTUAL
            INNER JOIN kardex                                                                 ka ON ka.id_cia = a.id_cia
                                    AND ka.tipinv = a.tipinv
                                    AND ka.codart = a.codart
                                    AND length(TRIM(ka.codadd01)) IS NULL
                                    AND length(TRIM(ka.codadd02)) IS NULL
                                    AND ka.periodo = pactual
            LEFT OUTER JOIN almacen                                                                al ON al.id_cia = ka.id_cia
                                          AND al.tipinv = ka.tipinv
                                          AND al.codalm = ka.codalm
            LEFT OUTER JOIN tmoneda                                                                mn ON mn.id_cia = pin_id_cia
                                          AND mn.codmon = pin_moneda
            LEFT OUTER JOIN documentos_cab                                                         dc ON dc.id_cia = ka.id_cia
                                                 AND dc.numint = ka.numint
            LEFT OUTER JOIN documentos_tipo                                                        dt ON dt.id_cia = dc.id_cia
                                                  AND dt.tipdoc = dc.tipdoc
            LEFT OUTER JOIN motivos                                                                mo ON mo.id_cia = dc.id_cia
                                          AND mo.tipdoc = dc.tipdoc
                                          AND mo.id = dc.id
                                          AND mo.codmot = dc.codmot
            LEFT OUTER JOIN motivos_clase                                                          mc ON mc.id_cia = dc.id_cia
                                                AND mc.tipdoc = dc.tipdoc
                                                AND mc.id = dc.id
                                                AND mc.codmot = dc.codmot
                                                AND mc.codigo = 12
            LEFT OUTER JOIN motivos_clase                                                          mk ON mk.id_cia = dc.id_cia
                                                AND mk.tipdoc = dc.tipdoc
                                                AND mk.id = dc.id
                                                AND mk.codmot = dc.codmot
                                                AND mk.codigo = 46
            LEFT OUTER JOIN documentos_clase                                                       dcl ON dcl.id_cia = dc.id_cia
                                                    AND dcl.codigo = dc.tipdoc
                                                    AND dcl.series = dc.series
                                                    AND dcl.clase = 10
            LEFT OUTER JOIN articulos_almacen                                                      si ON si.id_cia = ka.id_cia
                                                    AND si.tipinv = ka.tipinv
                                                    AND si.codart = ka.codart
                                                    AND si.codalm = ka.codalm
                                                    AND si.periodo = panterior
            LEFT OUTER JOIN articulos_almacen                                                      sf ON sf.id_cia = ka.id_cia
                                                    AND sf.tipinv = ka.tipinv
                                                    AND sf.codart = ka.codart
                                                    AND sf.codalm = ka.codalm
                                                    AND sf.periodo = pactual
            LEFT OUTER JOIN unidad                                                                 u ON u.id_cia = a.id_cia
                                        AND a.coduni = u.coduni
        WHERE
                a.id_cia = pin_id_cia
            AND a.tipinv = pin_tipinv
            AND ( pin_codart IS NULL
                  OR a.codart = pin_codart )
            AND ka.codalm = pin_codalm
            AND ( pin_codadd01 IS NULL
                  OR ka.codadd01 = pin_codadd01 )
            AND ( pin_codadd02 IS NULL
                  OR ka.codadd02 = pin_codadd02 )
            AND ( ka.cantid <> 0
                  OR ( si.ingreso - si.salida <> 0 )
                  OR ( sf.ingreso - sf.salida <> 0 ) )
        UNION ALL
        -- SE ADICIONO ESTA UNION PARA CONSIDERAR LOS TOTALES DE TODOS LOS ARTICULOS
        SELECT
            ac.tipinv,
            ti.dtipinv,
            ac2.codigo                AS codfam,
            ac2.desclase              AS desfam,
            ac3.codigo                AS codlin,
            ac3.desclase              AS deslin,
            a.codart,
            a.descri                  AS desart,
            u.abrevi                  AS codunisunat,
            'A'                       AS id,
            CAST(NULL AS VARCHAR(25)) AS tipope,
            CAST(NULL AS VARCHAR(6))  AS desmot,
            CAST(NULL AS VARCHAR(6))  AS abrmot,
            CAST(NULL AS INTEGER)     AS numint,
            CAST(NULL AS INTEGER)     AS numite,
            CAST(NULL AS VARCHAR(20)) AS tipdoc,
            CAST(NULL AS VARCHAR(5))  AS series,
            CAST(NULL AS INTEGER)     AS numdoc,
            NULL                      AS desdoc,
            TO_DATE('01/'
                    || TRIM(to_char(pin_mes, '00'))
                    || TRIM(to_char(pin_anio, '0000')),
                    'DD/MM/YY')       AS femisi,
            al.codalm                 AS codalm,
            al.descri                 AS desalm,
            al.abrevi                 AS abralm,
            mn.desmon,
            mn.simbolo,
            ac.ingreso - ac.salida    AS stockini,
            0                         AS caning,
            0                         AS cansal,
            ac.ingreso - ac.salida    AS stockfinal,
            ti.cuenta                 AS ctatinv,
            pc.nombre                 AS desctatinv,
            NULL                      AS codadd01,
            NULL                      AS dcodadd01,
            NULL                      AS codadd02,
            NULL                      AS dcodadd02,
            'N'                       AS mc46
        FROM
            articulos_almacen                                                      ac
            LEFT OUTER JOIN t_inventario                                                           ti ON ti.id_cia = ac.id_cia
                                               AND ti.tipinv = ac.tipinv
            LEFT OUTER JOIN almacen                                                                al ON al.id_cia = ac.id_cia
                                          AND al.tipinv = ac.tipinv
                                          AND al.codalm = ac.codalm
            LEFT OUTER JOIN pcuentas                                                               pc ON pc.id_cia = ti.id_cia
                                           AND pc.cuenta = ti.cuenta
            LEFT OUTER JOIN articulos                                                              a ON a.id_cia = ac.id_cia
                                           AND a.tipinv = ac.tipinv
                                           AND a.codart = ac.codart
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(a.id_cia, a.tipinv, a.codart, 2) ac2 ON 0 = 0
            LEFT OUTER JOIN pack_articulos.sp_buscar_clase_codigo(a.id_cia, a.tipinv, a.codart, 3) ac3 ON 0 = 0
            LEFT OUTER JOIN unidad                                                                 u ON u.id_cia = a.id_cia
                                        AND u.coduni = a.coduni
            LEFT OUTER JOIN tmoneda                                                                mn ON mn.id_cia = ac.id_cia
                                          AND mn.codmon = pin_moneda
        WHERE
                ac.id_cia = pin_id_cia
            AND ac.tipinv = pin_tipinv
            AND ac.codalm = pin_codalm
            AND ( pin_codart IS NULL
                  OR ac.codart = pin_codart )
            AND ac.periodo = panterior
            AND ac.ingreso - ac.salida <> 0
        ORDER BY
            1,
            3,
            5,
            7,
            20,
            10;

    BEGIN
        v_priorperiod := ( pin_anio * 100 ) + ( pin_mes - 1 );
        v_currentperiod := ( pin_anio * 100 ) + pin_mes;
        FOR registro IN cur_select(v_priorperiod, v_currentperiod) LOOP
            v_record.id_cia := pin_id_cia;
            v_record.tipinv := registro.tipinv;
            v_record.dtipinv := registro.dtipinv;
            v_record.codfam := registro.codfam;
            v_record.desfam := registro.desfam;
            v_record.codlin := registro.codlin;
            v_record.deslin := registro.deslin;
            v_record.codart := registro.codart;
            v_record.desart := registro.desart;
            v_record.codunisunat := registro.codunisunat;
            v_record.id := registro.id;
            v_record.desmot := registro.desmot;
            v_record.abrmot := registro.abrmot;
            v_record.numint := registro.numint;
            v_record.numite := registro.numite;
            CASE
                WHEN registro.abrmot IS NULL THEN
                    v_record.tipope := substr(upper(registro.desmot), 1, 15);
                ELSE
                    v_record.tipope := upper(registro.abrmot);
            END CASE;

            v_record.series := registro.series;
            v_record.numdoc := registro.numdoc;
            v_record.femisi := registro.femisi;
            v_record.tipdoc := upper(registro.desdoc);
            v_record.codalm := registro.codalm;
            v_record.desalm := registro.desalm;
            v_record.abralm := registro.abralm;
            v_record.desmon := registro.desmon;
            v_record.simbolo := registro.simbolo;
            v_record.stockini := nvl(registro.stockini, 0);
--            IF ( pin_moneda = 'PEN' ) THEN
--                v_record.cosuniini := nvl(registro.cosuniini01, 0);
--                v_record.costotini := nvl(registro.costotini01, 0);
--                v_record.cosuniing := nvl(registro.cosuniing01, 0);
--                v_record.costoting := nvl(registro.costoting01, 0);
--                v_record.cosunisal := nvl(registro.cosunisal01, 0);
--                v_record.costotsal := nvl(registro.costotsal01, 0);
--                v_record.cosunifin := nvl(registro.cosunifin01, 0);
--                v_record.costotfin := nvl(registro.costotfin01, 0);
--            ELSE
--                v_record.cosuniini := nvl(registro.cosuniini02, 0);
--                v_record.costotini := nvl(registro.costotini02, 0);
--                v_record.cosuniing := nvl(registro.cosuniing02, 0);
--                v_record.costoting := nvl(registro.costoting02, 0);
--                v_record.cosunisal := nvl(registro.cosunisal02, 0);
--                v_record.costotsal := nvl(registro.costotsal02, 0);
--                v_record.cosunifin := nvl(registro.cosunifin02, 0);
--                v_record.costotfin := nvl(registro.costotfin02, 0);
--            END IF;

            v_record.caning := nvl(registro.caning, 0);
            v_record.cansal := nvl(registro.cansal, 0);
            v_record.stockfinal := nvl(registro.stockfinal, 0);
            v_record.ctatinv := registro.ctatinv;
            v_record.desctatinv := registro.desctatinv;
            v_record.codadd01 := registro.codadd01;
            v_record.dcodadd01 := registro.dcodadd01;
            v_record.codadd02 := registro.codadd02;
            v_record.dcodadd02 := registro.dcodadd02;
            v_record.mc46 := registro.mc46;
            PIPE ROW ( v_record );
        END LOOP;

        RETURN;
    END sp_ingreso_salida;

    FUNCTION sp_buscar (
        pin_id_cia   INTEGER,
        pin_tipinv   INTEGER,
        pin_codalm   INTEGER,
        pin_codart   VARCHAR2,
        pin_anio     INTEGER,
        pin_mes      INTEGER,
        pin_moneda   VARCHAR2,
        pin_codadd01 VARCHAR2,
        pin_codadd02 VARCHAR2
    ) RETURN datatable_kardex_valorizado
        PIPELINED
    AS

        v_numint     NUMBER := -1;
        v_aux        NUMBER := 0;
        v_tipinv     NUMBER := 1;
        v_codart     VARCHAR2(50) := 'XXXXXXXXX';
        v_stockfinal NUMBER(18, 2);
        v_cosunifin  NUMBER(18, 2);
        v_costotfin  NUMBER(18, 2);
        v_stockini   NUMBER(18, 2);
        v_cosuniini  NUMBER(18, 2);
        v_costotini  NUMBER(18, 2);
        v_stocking   NUMBER(18, 2);
        v_cosuniing  NUMBER(18, 2);
        v_costoting  NUMBER(18, 2);
        v_stocksal   NUMBER(18, 2);
        v_cosunisal  NUMBER(18, 2);
        v_costotsal  NUMBER(18, 2);
        v_pd_numint  NUMBER := -1;
        rec          datarecord_kardex_valorizado;
        CURSOR kardex_ingeso_salida IS
        SELECT
            *
        FROM
            sp_ingreso_salida(pin_id_cia, pin_tipinv, pin_codalm, pin_codart, pin_anio,
                              pin_mes, pin_moneda, pin_codadd01, pin_codadd02);

    BEGIN
        FOR i IN kardex_ingeso_salida LOOP
            IF (
                v_tipinv = i.tipinv
                AND v_codart = i.codart
            ) THEN
            -- PARA EL OCULTO EN KARDEX, IMPRIME EN KARDEX
                -- SI SOLO SI, EL MOVIMIENTO NO TIENE DOBLE PARTIDA
                IF rec.mc46 = 'S' -- OCULTO EN KARDEX 
                 THEN
                    IF
                        v_numint <> i.numint
                        AND v_pd_numint <> v_numint -- DIFERENTE A UN NUMINT MARCADO CON PARTIDA DOBLE
                    THEN
                        PIPE ROW ( rec );
                    ELSE 
                -- GUARDANDO EL NUMINT CON PARTIDA DOBLE
                        v_pd_numint := i.numint;
                    END IF;

                END IF;
            ELSE
--            IF ( v_tipinv <> i.tipinv OR v_codart <> i.codart ) THEN
                -- IMPRIMIENDO TOTALES DEL ARTICULO ANTERIOR
                rec.tipope := NULL;
                rec.desmot := NULL;
                rec.abrmot := NULL;
                rec.numint := NULL;
                rec.numite := NULL;
                rec.tipdoc := NULL;
                rec.series := NULL;
                rec.numdoc := NULL;
                rec.femisi := NULL;
--                rec.codalm := NULL;
--                rec.desalm := NULL;
--                rec.abralm := NULL;
                rec.stockini := v_stockini;
                rec.cosuniini := 0;
                rec.costotini := v_costotini;
                rec.cansal := v_stocksal;
                rec.cosunisal := 0;
                rec.costotsal := v_costotsal;
                rec.caning := v_stocking;
                rec.cosuniing := 0;
                rec.costoting := v_costoting;
                rec.cosunifin := 0;
                rec.mc46 := 'N';
                rec.id := 'F';
                IF ( v_aux > 0 ) THEN
                    PIPE ROW ( rec );
                END IF;
                v_aux := 1 + v_aux;
                v_stockini := 0;
                v_costotini := 0;
                v_stocking := 0;
                v_costoting := 0;
                v_stocksal := 0;
                v_costotsal := 0;
            END IF;
            -- IMPRIMIENDO CABEZERA
            rec.id_cia := i.id_cia;
            rec.tipinv := i.tipinv;
            rec.dtipinv := i.dtipinv;
            rec.codfam := i.codfam;
            rec.desfam := i.desfam;
            rec.codlin := i.codlin;
            rec.deslin := i.deslin;
            rec.codart := i.codart;
            rec.desart := i.desart;
            rec.codunisunat := i.codunisunat;
            -- PARA IDENTIFICAR REGISTROS SECUNDARIOS DEL ARTICULO
            IF
                v_tipinv = i.tipinv
                AND v_codart = i.codart
            THEN
            -- SEGUNDA LINEA DEL ARTICULO
                rec.id := i.id;
                rec.tipope := i.tipope;
                rec.desmot := i.desmot;
                rec.abrmot := i.abrmot;
                rec.numint := i.numint;
                rec.numite := i.numite;
                rec.tipdoc := i.tipdoc;
                rec.series := i.series;
                rec.numdoc := i.numdoc;
                rec.femisi := i.femisi;
                rec.codalm := i.codalm;
                rec.desalm := i.desalm;
                rec.abralm := i.abralm;
                rec.desmon := i.desmon;
                rec.simbolo := i.simbolo;
                -- CALCULO | ARTICULO CON MOVIMIENTO
                IF rec.id = 'I' THEN
                    rec.stockini := v_stockfinal;
                    rec.cosuniini := v_cosunifin;
                    rec.costotini := v_costotfin;
                    rec.caning := i.caning;
                    rec.cosuniing := i.cosuniing;
                    rec.costoting := i.costoting;
                    rec.cansal := 0;
                    rec.cosunisal := 0;
                    rec.costotsal := 0;
                    rec.stockfinal := ( v_stockfinal + i.caning );
                    rec.costotfin := ( v_costotfin + i.costoting );
                    CASE
                        WHEN rec.stockfinal = 0 THEN
                            rec.cosunifin := 0;
                        ELSE
                            rec.cosunifin := round(rec.costotfin / rec.stockfinal, 2);
                    END CASE;

                    v_stocking := v_stocking + rec.caning;
                    v_costoting := v_costoting + rec.costoting;
                ELSIF rec.id = 'S' THEN
                    rec.stockini := v_stockfinal;
                    rec.cosuniini := v_cosunifin;
                    rec.costotini := v_costotfin;
                    rec.caning := 0;
                    rec.cosuniing := 0;
                    rec.costoting := 0;
                    rec.cansal := i.cansal;
                    rec.cosunisal := i.cosunisal;
                    rec.costotsal := i.costotsal;
                    rec.stockfinal := ( v_stockfinal - i.cansal );
                    rec.costotfin := ( v_costotfin - i.costotsal );
                    CASE
                        WHEN rec.stockfinal = 0 THEN
                            rec.cosunifin := 0;
                        ELSE
                            rec.cosunifin := round(rec.costotfin / rec.stockfinal, 2);
                    END CASE;

                    v_stocksal := v_stocksal + rec.cansal;
                    v_costotsal := v_costotsal + rec.costotsal;
                END IF;
                    -- GUARDANDO VALORES PARA LLEVAR EL ACUMULADO
                v_stockfinal := rec.stockfinal;
                v_cosunifin := rec.cosunifin;
                v_costotfin := rec.costotfin;
                    -- FIN
                rec.ctatinv := i.ctatinv;
                rec.desctatinv := i.desctatinv;
                rec.codadd01 := i.codadd01;
                rec.codadd02 := i.codadd02;
                rec.dcodadd01 := i.dcodadd01;
                rec.dcodadd02 := i.dcodadd02;
                IF i.mc46 = 'N' THEN
                    PIPE ROW ( rec );
                END IF;
            ELSE
                -- PRIMERA LINEA DEL ARTICULO
                -- IMPRIME LOS TOTALES DEL ARTICULO
                -- ASIGNANDO
                v_tipinv := rec.tipinv;
                v_codart := rec.codart;
                v_stockfinal := 0;
                v_cosunifin := 0;
                v_costotfin := 0;
                -- IMPRIMIENDO
                rec.tipope := NULL;
                rec.desmot := NULL;
                rec.abrmot := NULL;
                rec.numint := NULL;
                rec.numite := NULL;
                rec.tipdoc := NULL;
                rec.series := NULL;
                rec.numdoc := NULL;
                rec.femisi := NULL;
--                rec.codalm := NULL;
--                rec.desalm := NULL;
--                rec.abralm := NULL;
                rec.desmon := i.desmon;
                rec.simbolo := i.simbolo;
                -- NO HAY NINGUN CALCULO / STOCK INICIAL ANTES DE LA APERTURA
                rec.stockini := i.stockini;
                rec.cosuniini := i.cosuniini;
                rec.costotini := i.costotini;
                rec.caning := 0;
                rec.cosuniing := 0;
                rec.costoting := 0;
                rec.cansal := 0;
                rec.cosunisal := 0;
                rec.costotsal := 0;
                rec.stockfinal := i.stockini;
                rec.cosunifin := i.cosuniini;
                rec.costotfin := i.costotini;
                -- FIN
                rec.ctatinv := i.ctatinv;
                rec.desctatinv := i.desctatinv;
                rec.codadd01 := i.codadd01;
                rec.codadd02 := i.codadd02;
                rec.dcodadd01 := i.dcodadd01;
                rec.dcodadd02 := i.dcodadd02;
                IF pin_mes = 0 OR i.id IN ( 'I', 'S' ) THEN  -- SOLO SI ES INVENTARIO DE APERTURA
                --- O SI EL ARTICULO NO TENIA STOCK AL INICIAL EL PERIODO ( ARTICULOS_COSTO )
                    v_stockini := rec.stockini;
                    v_cosuniini := rec.cosuniini;
                    v_costotini := rec.costotini;
                    rec.id := 'T';
                    PIPE ROW ( rec );
                    rec.id := i.id;
                ELSE
                    rec.id := 'T';
                END IF;
                -- IMPRIMIENDO EL PRIMER MOVIMIENTO DEL ARTICULO
                rec.tipope := i.tipope;
                rec.desmot := i.desmot;
                rec.abrmot := i.abrmot;
                rec.numint := i.numint;
                rec.numite := i.numite;
                rec.tipdoc := i.tipdoc;
                rec.series := i.series;
                rec.numdoc := i.numdoc;
                rec.femisi := i.femisi;
                rec.codalm := i.codalm;
                rec.desalm := i.desalm;
                rec.abralm := i.abralm;
                rec.desmon := i.desmon;
                rec.simbolo := i.simbolo;
                    -- CALCULO | ARTICULO CON MOVIMIENTO
                IF rec.id = 'I' THEN
                    rec.stockini := i.stockini;
                    rec.cosuniini := i.cosuniini;
                    rec.costotini := i.costotini;
                    rec.caning := i.caning;
                    rec.cosuniing := i.cosuniing;
                    rec.costoting := i.costoting;
                    rec.cansal := 0;
                    rec.cosunisal := 0;
                    rec.costotsal := 0;
                    rec.stockfinal := ( rec.stockini + i.caning );
                    rec.costotfin := ( rec.costotfin + i.costoting );
                    CASE
                        WHEN rec.stockfinal = 0 THEN
                            rec.cosunifin := 0;
                        ELSE
                            rec.cosunifin := round(rec.costotfin / rec.stockfinal, 2);
                    END CASE;

                    v_stocking := v_stocking + rec.caning;
                    v_costoting := v_costoting + rec.costoting;
                ELSIF rec.id = 'S' THEN
                    rec.stockini := i.stockini;
                    rec.cosuniini := i.cosuniini;
                    rec.costotini := i.costotini;
                    rec.caning := 0;
                    rec.cosuniing := 0;
                    rec.costoting := 0;
                    rec.cansal := i.cansal;
                    rec.cosunisal := i.cosunisal;
                    rec.costotsal := i.costotsal;
                    rec.stockfinal := ( rec.stockini - i.cansal );
                    rec.costotfin := ( rec.costotini - i.costotsal );
                    CASE
                        WHEN rec.stockfinal = 0 THEN
                            rec.cosunifin := 0;
                        ELSE
                            rec.cosunifin := round(rec.costotfin / rec.stockfinal, 2);
                    END CASE;

                    v_stocksal := v_stocksal + rec.cansal;
                    v_costotsal := v_costotsal + rec.costotsal;
                ELSIF rec.id = 'T' THEN
                    rec.femisi := NULL; -- ELIMINAR FECHA ( SOLO SE USO PARA EL ORDENAMIENTO )
                    rec.stockini := i.stockini;
                    rec.cosuniini := i.cosuniini;
                    rec.costotini := i.costotini;
                    v_stockini := rec.stockini;
                    v_cosuniini := rec.cosuniini;
                    v_costotini := rec.costotini;
                    rec.caning := 0;
                    rec.cosuniing := 0;
                    rec.costoting := 0;
                    rec.cansal := 0;
                    rec.cosunisal := 0;
                    rec.costotsal := 0;
                    rec.stockfinal := i.stockfinal;
                    rec.costotfin := i.costotfin;
                    rec.cosunifin := i.cosunifin;
                END IF;
                    -- GUARDANDO VALORES PARA LLEVAR EL ACUMULADO
                v_stockfinal := rec.stockfinal;
                v_cosunifin := rec.cosunifin;
                v_costotfin := rec.costotfin;
                    -- FIN
                rec.ctatinv := i.ctatinv;
                rec.desctatinv := i.desctatinv;
                rec.codadd01 := i.codadd01;
                rec.codadd02 := i.codadd02;
                rec.dcodadd01 := i.dcodadd01;
                rec.dcodadd02 := i.dcodadd02;
                IF i.mc46 = 'N' THEN -- CLASE DEL MOTIVO 46 - OCULTO EN KARDEX O EN PLE
                    PIPE ROW ( rec );
                END IF;
            END IF;
                -- VARIABLE AUXILIAR
            v_numint := nvl(i.numint, -1);
            rec.mc46 := i.mc46;
        END LOOP;
            -- IMPRIMIENDO EL ULTIMO ARTICULO, SI NO TIENE PARTIDA DOBLE
        IF
            rec.mc46 = 'S'
            AND v_pd_numint <> v_numint -- DIFERENTE A UN NUMINT MARCADO CON PARTIDA DOBLE
        THEN
            PIPE ROW ( rec );
        END IF;


                --IMPRIMIENDO TOTAL DEL ULTIMO ARTICULO
        rec.tipope := NULL;
        rec.desmot := NULL;
        rec.abrmot := NULL;
        rec.numint := NULL;
        rec.numite := NULL;
        rec.tipdoc := NULL;
        rec.series := NULL;
        rec.numdoc := NULL;
        rec.femisi := NULL;
--        rec.codalm := NULL;
--        rec.desalm := NULL;
--        rec.abralm := NULL;
        rec.stockini := v_stockini;
        rec.cosuniini := 0;
        rec.costotini := v_costotini;
        rec.cansal := v_stocksal;
        rec.cosunisal := 0;
        rec.costotsal := v_costotsal;
        rec.caning := v_stocking;
        rec.cosuniing := 0;
        rec.costoting := v_costoting;
        rec.cosunifin := 0;
        rec.mc46 := 'N';
        rec.id := 'F';
        PIPE ROW ( rec );
    END sp_buscar;

END;

/

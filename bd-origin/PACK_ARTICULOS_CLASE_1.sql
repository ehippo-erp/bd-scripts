--------------------------------------------------------
--  DDL for Package Body PACK_ARTICULOS_CLASE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_ARTICULOS_CLASE" AS

    FUNCTION sp_tipcamlista (
        pin_id_cia    NUMBER,
        pin_codmonlis VARCHAR2,
        pin_incigvlis VARCHAR2,
        pin_codmondoc VARCHAR2,
        pin_incigvdoc VARCHAR2,
        pin_tipcamdoc VARCHAR2,
        pin_preciolis NUMBER,
        pin_porigvlis NUMBER,
        pin_femisi    DATE
    ) RETURN datatable_tipcamlista
        PIPELINED
    AS

        v_rec      datarecord_tipcamlista := datarecord_tipcamlista(NULL, NULL, NULL, NULL, NULL);
        v_tipmon   VARCHAR2(10) := '';
        v_porigvlp NUMBER(16, 5);
    BEGIN
        v_rec.id_cia := pin_id_cia;
        v_porigvlp := 1 + ( pin_porigvlis / 100 );
        IF
            pin_codmondoc IS NOT NULL
            AND pin_tipcamdoc IS NOT NULL
            AND pin_femisi IS NOT NULL
            AND pin_incigvdoc IS NOT NULL
        THEN
            -- PROCESAMOS SI SOLO SI SE HAN OTORGADO TODOS LOS PARAMETROS
            IF pin_codmondoc = 'PEN' THEN
                v_tipmon := 'USD';
            ELSE
                v_tipmon := pin_codmondoc;
            END IF;

            -- PROCESANDO EL PRECIO SEGUN EL IGV
            IF pin_incigvlis = pin_incigvdoc THEN
                v_rec.preciolista := pin_preciolis;
            ELSE
                IF pin_incigvlis = 'S' THEN
                    v_rec.preciolista := ( pin_preciolis / v_porigvlp );
                ELSE
                    v_rec.preciolista := ( pin_preciolis * v_porigvlp );
                END IF;
            END IF;

            -- PROCESANDO EL PRECIO SEGUN LA MONEDA
            IF pin_codmonlis = pin_codmondoc THEN
                v_rec.codmonlista := pin_codmonlis;
                v_rec.tipcamlista := NULL;
                v_rec.preciolista := round(v_rec.preciolista, 5);
                v_rec.femisi := NULL;
                PIPE ROW ( v_rec );
                RETURN;
            ELSE
                --  CALCULANDO EL TIPO DE CAMBIO
                v_rec.codmonlista := pin_codmondoc;
                v_rec.femisi := NULL;
                IF pin_codmonlis = 'PEN' THEN
                    v_rec.tipcamlista := pin_tipcamdoc;
                ELSE
                    BEGIN
                        SELECT
                            t.fventa
                        INTO v_rec.tipcamlista
                        FROM
                            tcambio t
                        WHERE
                                t.id_cia = pin_id_cia
                            AND t.hmoneda = 'PEN'
                            AND trunc(t.fecha) = trunc(pin_femisi)
                            AND t.moneda = v_tipmon;

                    EXCEPTION
                        WHEN no_data_found THEN
                            v_rec.tipcamlista := pin_tipcamdoc;
                    END;
                END IF;
                -- CALCULANDO EL PRECIO
                IF pin_codmondoc = 'PEN' THEN
                    v_rec.preciolista := v_rec.preciolista * v_rec.tipcamlista;
                ELSE -- 'EUR / USD'
                    IF pin_codmonlis = 'PEN' THEN
                        v_rec.preciolista := v_rec.preciolista / pin_tipcamdoc;
                    ELSE -- 'EUR / USD'
                        v_rec.preciolista := ( v_rec.preciolista * v_rec.tipcamlista ) / pin_tipcamdoc;
                    END IF;
                END IF;

                v_rec.preciolista := round(v_rec.preciolista, 5);
                -- FINALMENTE IMPRIMOS LOS RESULTADOS
                PIPE ROW ( v_rec );
                RETURN;
            END IF;

        ELSE
            -- SI NO HAN ENTREGADO TODOS LOS PARAMETROS
            v_rec.id_cia := pin_id_cia;
            v_rec.codmonlista := pin_codmonlis;
            v_rec.tipcamlista := NULL;
            v_rec.preciolista := pin_preciolis;
            v_rec.femisi := NULL;
            PIPE ROW ( v_rec );
            RETURN;
        END IF;

    END sp_tipcamlista;

    FUNCTION sp_buscar (
        pin_id_cia    IN NUMBER,
        pin_tipo      IN NUMBER,
        pin_codtit    IN VARCHAR2,
        pin_tipinv    IN NUMBER,
        pin_codpro    IN VARCHAR2,
        pin_codmon    IN VARCHAR2,
        pin_femisi    IN DATE, --N
        pin_codmondoc IN VARCHAR2, --N
        pin_tipcamdoc NUMBER, --N
        pin_incigvdoc VARCHAR2, --N
        pin_descri    IN VARCHAR2,
        pin_descla1   IN VARCHAR2,
        pin_descla2   IN VARCHAR2,
        pin_descla3   IN VARCHAR2,
        pin_descla4   IN VARCHAR2,
        pin_descla5   IN VARCHAR2,
        pin_descla6   IN VARCHAR2,
        pin_almacenes IN VARCHAR2,
        pin_fdesde    IN NUMBER,
        pin_fhasta    IN NUMBER,
        pin_incstock  IN VARCHAR2
    ) RETURN datatable_buscar
        PIPELINED
    AS

        rbusqueda_por_clases datarecord_buscar := datarecord_buscar(pin_id_cia, NULL, NULL, NULL, NULL,
                                                                   NULL, NULL, NULL, NULL, NULL,
                                                                   NULL, NULL, NULL, NULL, NULL,
                                                                   NULL, NULL, NULL, NULL, NULL,
                                                                   NULL, NULL, NULL, NULL, NULL,
                                                                   NULL, NULL, NULL, NULL, NULL,
                                                                   NULL, NULL, NULL, NULL, NULL,
                                                                   NULL, NULL, NULL, NULL, NULL,
                                                                   NULL, NULL, NULL, NULL, NULL);
        CURSOR cur_selec_tipo_6 (
            pclase1 NUMBER,
            pclase2 NUMBER,
            pclase3 NUMBER,
            pclase4 NUMBER,
            pclase5 NUMBER,
            pclase6 NUMBER
        ) IS
        SELECT
            99999               AS codtit,
            a.tipinv,
            a.codart,
            a.descri            AS desart,
            a.coduni,
--            l.precio            AS precio,
            tc.preciolista      AS precio,
            l.desc01            AS desc01,
            l.desc02            AS desc02,
            l.desc03            AS desc03,
            l.desc04            AS desc04,
            md.simbolo,
            md.codmon           AS codmon,
            l.desmax,
            l.incigv            AS incigv,
            a.consto,
            l.porigv            AS dporigv,
            l.margen            AS dmargen,
            l.otros             AS dotros,
            l.flete             AS dflete,
            a1.clase            AS codcla1,
            upper(a1.descodigo) AS descla1,
            b1.clase            AS codcla2,
            upper(b1.descodigo) AS descla2,
            c1.clase            AS codcla3,
            upper(c1.descodigo) AS descla3,
            d1.clase            AS codcla4,
            upper(d1.descodigo) AS descla4,
            e1.clase            AS codcla5,
            upper(e1.descodigo) AS descla5,
            f1.clase            AS codcla6,
            upper(f1.descodigo) AS descla6,
            ''                  AS codpro,
            CASE
                WHEN ac.codigo = '1' THEN
                    'ACTIVO'
                ELSE
                    'INACTIVO'
            END                 AS situac,
            agc.observ          AS glosacotizaciondefecto,
            agf.observ          AS glosafacturaciondefecto
        FROM
            articulos                                                                 a
            LEFT OUTER JOIN listaprecios                                                              l ON l.id_cia = a.id_cia
                                              AND l.tipinv = a.tipinv
                                              AND l.codart = a.codart
                                              AND l.codtit = 99999
                                              AND l.codpro = pin_codpro
            INNER JOIN articulos_clase                                                           ac ON ac.id_cia = a.id_cia
                                             AND ac.tipinv = a.tipinv
                                             AND ac.codart = a.codart
                                             AND ac.clase = 9
                                             AND ac.codigo = '1'
            LEFT OUTER JOIN articulos_glosa                                                           agc ON agc.id_cia = a.id_cia
                                                   AND agc.tipinv = a.tipinv
                                                   AND agc.codart = a.codart
                                                   AND agc.tipo = 1
            LEFT OUTER JOIN articulos_glosa                                                           agf ON agf.id_cia = a.id_cia
                                                   AND agf.tipinv = a.tipinv
                                                   AND agf.codart = a.codart
                                                   AND agf.tipo = 2
            LEFT OUTER JOIN pack_articulos_clase.sp_tipcamlista(a.id_cia, l.codmon, l.incigv, pin_codmondoc, pin_incigvdoc,
                                                                pin_tipcamdoc, l.precio, l.porigv, pin_femisi)                            tc
                                                                ON 0 = 0
            LEFT OUTER JOIN tmoneda                                                                   md ON md.id_cia = a.id_cia
--                                          AND md.codmon = l.codmon
                                          AND md.codmon = tc.codmonlista
            LEFT OUTER JOIN TABLE ( sp_select_articulo_clase(a.id_cia, a.tipinv, a.codart, pclase1) ) a1 ON 0 = 0
            LEFT OUTER JOIN TABLE ( sp_select_articulo_clase(a.id_cia, a.tipinv, a.codart, pclase2) ) b1 ON 0 = 0
            LEFT OUTER JOIN TABLE ( sp_select_articulo_clase(a.id_cia, a.tipinv, a.codart, pclase3) ) c1 ON 0 = 0
            LEFT OUTER JOIN TABLE ( sp_select_articulo_clase(a.id_cia, a.tipinv, a.codart, pclase4) ) d1 ON 0 = 0
            LEFT OUTER JOIN TABLE ( sp_select_articulo_clase(a.id_cia, a.tipinv, a.codart, pclase5) ) e1 ON 0 = 0
            LEFT OUTER JOIN TABLE ( sp_select_articulo_clase(a.id_cia, a.tipinv, a.codart, pclase6) ) f1 ON 0 = 0
        WHERE
                a.id_cia = pin_id_cia
            AND ( a.tipinv = pin_tipinv )
            AND ( ( pin_descri IS NULL )
                  OR ( upper(a.descri) LIKE upper(pin_descri || '%') ) )
            AND ( ( pin_descla1 IS NULL )
                  OR ( upper(a1.descodigo) LIKE upper(pin_descla1 || '%') ) )
            AND ( ( pin_descla2 IS NULL )
                  OR ( upper(b1.descodigo) LIKE upper(pin_descla2 || '%') ) )
            AND ( ( pin_descla3 IS NULL )
                  OR ( upper(c1.descodigo) LIKE upper(pin_descla3 || '%') ) )
            AND ( ( pin_descla4 IS NULL )
                  OR ( upper(d1.descodigo) LIKE upper(pin_descla4 || '%') ) )
            AND ( ( pin_descla5 IS NULL )
                  OR ( upper(e1.descodigo) LIKE upper(pin_descla5 || '%') ) )
            AND ( ( pin_descla6 IS NULL )
                  OR ( upper(f1.descodigo) LIKE upper(pin_descla6 || '%') ) );

        CURSOR cur_selec_tipo_2_21 (
            pcodpro VARCHAR2,
            pclase1 NUMBER,
            pclase2 NUMBER,
            pclase3 NUMBER,
            pclase4 NUMBER,
            pclase5 NUMBER,
            pclase6 NUMBER
        ) IS
        SELECT
            a.codart,
            a.tipinv,
            a.descri            AS desart,
            a.coduni,
            a1.clase            AS codcla1,
            upper(a1.descodigo) AS descla1,
            b1.clase            AS codcla2,
            upper(b1.descodigo) AS descla2,
            c1.clase            AS codcla3,
            upper(c1.descodigo) AS descla3,
            d1.clase            AS codcla4,
            upper(d1.descodigo) AS descla4,
            e1.clase            AS codcla5,
            upper(e1.descodigo) AS descla5,
            f1.clase            AS codcla6,
            upper(f1.descodigo) AS descla6,
            CASE
                WHEN ac.codigo = 1 THEN
                    'ACTIVO'
                ELSE
                    'INACTIVO'
            END                 AS situacion,
            agc.observ          AS glosacotizaciondefecto,
            agf.observ          AS glosafacturaciondefecto
        FROM
            articulos                                                                   a
            LEFT OUTER JOIN articulos_clase                                                             ac ON ac.id_cia = pin_id_cia
                                                  AND ac.clase = 9
                                                  AND ac.tipinv = a.tipinv
                                                  AND ac.codart = a.codart
            INNER JOIN articulos_clase                                                             ac ON ac.id_cia = a.id_cia -- ADICIONADO
                                             AND ac.tipinv = a.tipinv
                                             AND ac.codart = a.codart
                                             AND ac.clase = 9
                                             AND ac.codigo = '1'
            LEFT OUTER JOIN articulos_glosa                                                             agc ON agc.id_cia = a.id_cia
                                                   AND agc.tipinv = a.tipinv
                                                   AND agc.codart = a.codart
                                                   AND agc.tipo = 1
            LEFT OUTER JOIN articulos_glosa                                                             agf ON agf.id_cia = a.id_cia
                                                   AND agf.tipinv = a.tipinv
                                                   AND agf.codart = a.codart
                                                   AND agf.tipo = 2
            LEFT OUTER JOIN TABLE ( sp_select_articulo_clase(pin_id_cia, a.tipinv, a.codart, pclase1) ) a1 ON 0 = 0
            LEFT OUTER JOIN TABLE ( sp_select_articulo_clase(pin_id_cia, a.tipinv, a.codart, pclase2) ) b1 ON 0 = 0
            LEFT OUTER JOIN TABLE ( sp_select_articulo_clase(pin_id_cia, a.tipinv, a.codart, pclase3) ) c1 ON 0 = 0
            LEFT OUTER JOIN TABLE ( sp_select_articulo_clase(pin_id_cia, a.tipinv, a.codart, pclase4) ) d1 ON 0 = 0
            LEFT OUTER JOIN TABLE ( sp_select_articulo_clase(pin_id_cia, a.tipinv, a.codart, pclase5) ) e1 ON 0 = 0
            LEFT OUTER JOIN TABLE ( sp_select_articulo_clase(pin_id_cia, a.tipinv, a.codart, pclase6) ) f1 ON 0 = 0
        WHERE
            ( a.id_cia = pin_id_cia )
            AND ( a.tipinv = pin_tipinv )
            AND ( ( pcodpro = '00000000001' )
                  OR EXISTS (
                SELECT
                    ll.codart
                FROM
                    listaprecios ll
                WHERE
                    ( ll.id_cia = pin_id_cia )
                    AND ( ll.codtit = 99999 )
                    AND ( ll.codpro = pcodpro )
                    AND ( ll.tipinv = a.tipinv )
                    AND ( ll.codart = a.codart )
            ) )
            AND ( ( pin_descri IS NULL )
                  OR ( upper(a.descri) LIKE upper(pin_descri || '%') ) )
            AND ( ( pin_descla1 IS NULL )
                  OR ( upper(a1.descodigo) LIKE upper(pin_descla1 || '%') ) )
            AND ( ( pin_descla2 IS NULL )
                  OR ( upper(b1.descodigo) LIKE upper(pin_descla2 || '%') ) )
            AND ( ( pin_descla3 IS NULL )
                  OR ( upper(c1.descodigo) LIKE upper(pin_descla3 || '%') ) )
            AND ( ( pin_descla4 IS NULL )
                  OR ( upper(d1.descodigo) LIKE upper(pin_descla4 || '%') ) )
            AND ( ( pin_descla5 IS NULL )
                  OR ( upper(e1.descodigo) LIKE upper(pin_descla5 || '%') ) )
            AND ( ( pin_descla6 IS NULL )
                  OR ( upper(f1.descodigo) LIKE upper(pin_descla6 || '%') ) );

        CURSOR cur_comas_en_filas (
            plistacodtit VARCHAR2
        ) IS
        SELECT
            column_value AS titulo
        FROM
            TABLE ( split_string(plistacodtit) );

        CURSOR cur_selec_tipo_4 (
            pcodpro VARCHAR2,
            pcodtit NUMBER,
            pclase1 NUMBER,
            pclase2 NUMBER,
            pclase3 NUMBER,
            pclase4 NUMBER,
            pclase5 NUMBER,
            pclase6 NUMBER
        ) IS
        SELECT
            l2.codtit,
            l2.tipinv,
            l2.codart,
            a.descri            AS desart,
            a.coduni,
            l2.precio           AS dprecio,
            l2.desc01           AS ddesc01,
            l2.desc02           AS ddesc02,
            l2.desc03           AS ddesc03,
            l2.desc04           AS ddesc04,
            m2.simbolo,
            l2.codmon           AS dcodmon,
            l2.desmax,
            l2.incigv           AS dincigv,
            a.consto,
            l2.porigv           AS dporigv,
            l2.margen           AS dmargen,
            l2.otros            AS dotros,
            l2.flete            AS dflete,
            a1.clase            AS codcla1,
            upper(a1.descodigo) AS descla1,
            b1.clase            AS codcla2,
            upper(b1.descodigo) AS descla2,
            c1.clase            AS codcla3,
            upper(c1.descodigo) AS descla3,
            d1.clase            AS codcla4,
            upper(d1.descodigo) AS descla4,
            e1.clase            AS codcla5,
            upper(e1.descodigo) AS descla5,
            f1.clase            AS codcla6,
            upper(f1.descodigo) AS descla6,
            0                   AS stock,
            l1.codpro,
            CASE
                WHEN ac.codigo = 1 THEN
                    'ACTIVO'
                ELSE
                    'INACTIVO'
            END                 AS situac,
            agc.observ          AS glosacotizaciondefecto,
            agf.observ          AS glosafacturaciondefecto,
--            l1.precio,
            tc.preciolista      AS precio,
            l1.desc01,
            l1.desc02,
            l1.desc03,
            l1.desc04,
            l1.desmax           AS ddesmax,
            l1.incigv,
            m1.codmon,
            l1.factua,
            m1.simbolo          AS dsimbolo
        FROM
                 listaprecios l1
            INNER JOIN articulos                                                                     a ON a.id_cia = pin_id_cia
                                      AND a.tipinv = l1.tipinv
                                      AND a.codart = l1.codart
                                      AND ( ( pin_descri IS NULL )
                                            OR ( upper(a.descri) LIKE upper(pin_descri || '%') ) )
            LEFT OUTER JOIN articulos_glosa                                                               agc ON agc.id_cia = a.id_cia
                                                   AND agc.tipinv = a.tipinv
                                                   AND agc.codart = a.codart
                                                   AND agc.tipo = 1
            LEFT OUTER JOIN articulos_glosa                                                               agf ON agf.id_cia = a.id_cia
                                                   AND agf.tipinv = a.tipinv
                                                   AND agf.codart = a.codart
                                                   AND agf.tipo = 2
            INNER JOIN articulos_clase                                                               ac ON ac.id_cia = pin_id_cia
                                             AND ac.tipinv = l1.tipinv
                                             AND ac.codart = l1.codart
                                             AND ac.clase = 9
                                             AND ac.codigo = '1'
            LEFT OUTER JOIN listaprecios                                                                  l2 ON l2.id_cia = pin_id_cia
                                               AND l2.tipinv = l1.tipinv
                                               AND l2.codart = l1.codart
            LEFT OUTER JOIN pack_articulos_clase.sp_tipcamlista(a.id_cia, l1.codmon, l1.incigv, pin_codmondoc, pin_incigvdoc,
                                                                pin_tipcamdoc, l1.precio, l1.porigv, pin_femisi)                              tc
                                                                ON 0 = 0
            LEFT OUTER JOIN tmoneda                                                                       md ON md.id_cia = a.id_cia
--                                          AND md.codmon = l.codmon
                                          AND md.codmon = tc.codmonlista
            LEFT OUTER JOIN tmoneda                                                                       m1 ON m1.id_cia = pin_id_cia
                                          AND m1.codmon = l1.codmon
            LEFT OUTER JOIN tmoneda                                                                       m2 ON m2.id_cia = pin_id_cia
                                          AND m2.codmon = l2.codmon
            LEFT OUTER JOIN TABLE ( sp_select_articulo_clase(pin_id_cia, l1.tipinv, l1.codart, pclase1) ) a1 ON 0 = 0
            LEFT OUTER JOIN TABLE ( sp_select_articulo_clase(pin_id_cia, l1.tipinv, l1.codart, pclase2) ) b1 ON 0 = 0
            LEFT OUTER JOIN TABLE ( sp_select_articulo_clase(pin_id_cia, l1.tipinv, l1.codart, pclase3) ) c1 ON 0 = 0
            LEFT OUTER JOIN TABLE ( sp_select_articulo_clase(pin_id_cia, l1.tipinv, l1.codart, pclase4) ) d1 ON 0 = 0
            LEFT OUTER JOIN TABLE ( sp_select_articulo_clase(pin_id_cia, l1.tipinv, l1.codart, pclase5) ) e1 ON 0 = 0
            LEFT OUTER JOIN TABLE ( sp_select_articulo_clase(pin_id_cia, l1.tipinv, l1.codart, pclase6) ) f1 ON 0 = 0
        WHERE
                l1.id_cia = pin_id_cia
            AND ( l1.tipinv = pin_tipinv )
            AND ( l1.codtit = 99999 )
            AND ( l2.codtit = pcodtit )
            AND ( ( pcodpro = '*' )
                  OR ( l1.codpro = pcodpro ) )
            AND ( ( pin_codmon IS NULL )
                  OR ( l1.codmon = pin_codmon ) )
            AND ( ( pin_descla1 IS NULL )
                  OR ( upper(a1.descodigo) LIKE upper(pin_descla1 || '%') ) )
            AND ( ( pin_descla2 IS NULL )
                  OR ( upper(b1.descodigo) LIKE upper(pin_descla2 || '%') ) )
            AND ( ( pin_descla3 IS NULL )
                  OR ( upper(c1.descodigo) LIKE upper(pin_descla3 || '%') ) )
            AND ( ( pin_descla4 IS NULL )
                  OR ( upper(d1.descodigo) LIKE upper(pin_descla4 || '%') ) )
            AND ( ( pin_descla5 IS NULL )
                  OR ( upper(e1.descodigo) LIKE upper(pin_descla5 || '%') ) )
            AND ( ( pin_descla6 IS NULL )
                  OR ( upper(f1.descodigo) LIKE upper(pin_descla6 || '%') ) );

        CURSOR cur_selec_tipo_1 (
            pcodpro VARCHAR2,
            pcodtit NUMBER,
            pclase1 NUMBER,
            pclase2 NUMBER,
            pclase3 NUMBER,
            pclase4 NUMBER,
            pclase5 NUMBER,
            pclase6 NUMBER
        ) IS
        SELECT
            l.codtit,
            l.tipinv,
            l.codart,
            a.descri            AS desart,
            a.coduni,
--            l.precio            AS precio,
            tc.preciolista      AS precio,
            l.desc01            AS desc01,
            l.desc02            AS desc02,
            l.desc03            AS desc03,
            l.desc04            AS desc04,
            md.simbolo,
            md.codmon           AS codmon,
            l.desmax,
            l.incigv            AS incigv,
            a.consto,
            l.porigv            AS dporigv,
            l.margen            AS dmargen,
            l.otros             AS dotros,
            l.flete             AS dflete,
            a1.clase            AS codcla1,
            upper(a1.descodigo) AS descla1,
            b1.clase            AS codcla2,
            upper(b1.descodigo) AS descla2,
            c1.clase            AS codcla3,
            upper(c1.descodigo) AS descla3,
            d1.clase            AS codcla4,
            upper(d1.descodigo) AS descla4,
            e1.clase            AS codcla5,
            upper(e1.descodigo) AS descla5,
            f1.clase            AS codcla6,
            upper(f1.descodigo) AS descla6,
            ''                  AS codpro,
            CASE
                WHEN ac.codigo = 1 THEN
                    'ACTIVO'
                ELSE
                    'INACTIVO'
            END                 AS situac,
            agc.observ          AS glosacotizaciondefecto,
            agf.observ          AS glosafacturaciondefecto
        FROM
                 listaprecios l
            INNER JOIN articulos                                                                   a ON a.id_cia = pin_id_cia
                                      AND a.tipinv = l.tipinv
                                      AND a.codart = l.codart
                                      AND ( ( pin_descri IS NULL )
                                            OR ( upper(a.descri) LIKE upper(pin_descri || '%') ) )
            LEFT OUTER JOIN articulos_glosa                                                             agc ON agc.id_cia = a.id_cia
                                                   AND agc.tipinv = a.tipinv
                                                   AND agc.codart = a.codart
                                                   AND agc.tipo = 1
            LEFT OUTER JOIN articulos_glosa                                                             agf ON agf.id_cia = a.id_cia
                                                   AND agf.tipinv = a.tipinv
                                                   AND agf.codart = a.codart
                                                   AND agf.tipo = 2
            INNER JOIN articulos_clase                                                             ac ON ac.id_cia = pin_id_cia
                                             AND ac.tipinv = l.tipinv
                                             AND ac.codart = l.codart
                                             AND ac.clase = 9
                                             AND ac.codigo = '1'
            LEFT OUTER JOIN pack_articulos_clase.sp_tipcamlista(a.id_cia, l.codmon, l.incigv, pin_codmondoc, pin_incigvdoc,
                                                                pin_tipcamdoc, l.precio, l.porigv, pin_femisi)                              tc
                                                                ON 0 = 0
            LEFT OUTER JOIN tmoneda                                                                     md ON md.id_cia = pin_id_cia
                                          --                                          AND md.codmon = l.codmon
                                          AND md.codmon = tc.codmonlista
            LEFT OUTER JOIN TABLE ( sp_select_articulo_clase(pin_id_cia, l.tipinv, l.codart, pclase1) ) a1 ON 0 = 0
            LEFT OUTER JOIN TABLE ( sp_select_articulo_clase(pin_id_cia, l.tipinv, l.codart, pclase2) ) b1 ON 0 = 0
            LEFT OUTER JOIN TABLE ( sp_select_articulo_clase(pin_id_cia, l.tipinv, l.codart, pclase3) ) c1 ON 0 = 0
            LEFT OUTER JOIN TABLE ( sp_select_articulo_clase(pin_id_cia, l.tipinv, l.codart, pclase4) ) d1 ON 0 = 0
            LEFT OUTER JOIN TABLE ( sp_select_articulo_clase(pin_id_cia, l.tipinv, l.codart, pclase5) ) e1 ON 0 = 0
            LEFT OUTER JOIN TABLE ( sp_select_articulo_clase(pin_id_cia, l.tipinv, l.codart, pclase6) ) f1 ON 0 = 0
        WHERE
                l.id_cia = pin_id_cia
            AND ( l.tipinv = pin_tipinv )
            AND ( l.codtit = pcodtit )
            AND ( ( pin_descla1 IS NULL )
                  OR ( upper(a1.descodigo) LIKE upper(pin_descla1 || '%') ) )
            AND ( ( pin_descla2 IS NULL )
                  OR ( upper(b1.descodigo) LIKE upper(pin_descla2 || '%') ) )
            AND ( ( pin_descla3 IS NULL )
                  OR ( upper(c1.descodigo) LIKE upper(pin_descla3 || '%') ) )
            AND ( ( pin_descla4 IS NULL )
                  OR ( upper(d1.descodigo) LIKE upper(pin_descla4 || '%') ) )
            AND ( ( pin_descla5 IS NULL )
                  OR ( upper(e1.descodigo) LIKE upper(pin_descla5 || '%') ) )
            AND ( ( pin_descla6 IS NULL )
                  OR ( upper(f1.descodigo) LIKE upper(pin_descla6 || '%') ) );

        CURSOR cur_selec_tipo_5 (
            pcodpro VARCHAR2,
            pcodtit NUMBER,
            pclase1 NUMBER,
            pclase2 NUMBER,
            pclase3 NUMBER,
            pclase4 NUMBER,
            pclase5 NUMBER,
            pclase6 NUMBER
        ) IS
        SELECT
            l.codtit,
            l.tipinv,
            l.codart,
            a.descri            AS desart,
            a.coduni,
--            l.precio            AS precio,
            tc.preciolista      AS precio,
            l.desc01            AS desc01,
            l.desc02            AS desc02,
            l.desc03            AS desc03,
            l.desc04            AS desc04,
            md.simbolo,
            md.codmon           AS codmon,
            l.desmax,
            l.incigv            AS incigv,
            a.consto,
            l.porigv            AS porigv,
            l.margen            AS margen,
            l.otros             AS otros,
            l.flete             AS flete,
            a1.clase            AS codcla1,
            upper(a1.descodigo) AS descla1,
            b1.clase            AS codcla2,
            upper(b1.descodigo) AS descla2,
            c1.clase            AS codcla3,
            upper(c1.descodigo) AS descla3,
            d1.clase            AS codcla4,
            upper(d1.descodigo) AS descla4,
            e1.clase            AS codcla5,
            upper(e1.descodigo) AS descla5,
            f1.clase            AS codcla6,
            upper(f1.descodigo) AS descla6,
            ll.codpro           AS codpro,
            CASE
                WHEN ac.codigo = 1 THEN
                    'ACTIVO'
                ELSE
                    'INACTIVO'
            END                 AS situac,
            agc.observ          AS glosacotizaciondefecto,
            agf.observ          AS glosafacturaciondefecto
        FROM
                 listaprecios ll
            INNER JOIN articulos                                                                   a ON a.id_cia = pin_id_cia
                                      AND a.tipinv = ll.tipinv
                                      AND a.codart = ll.codart
                                      AND ( ( pin_descri IS NULL )
                                            OR ( upper(a.descri) LIKE upper(pin_descri || '%') ) )
            LEFT OUTER JOIN articulos_glosa                                                             agc ON agc.id_cia = a.id_cia
                                                   AND agc.tipinv = a.tipinv
                                                   AND agc.codart = a.codart
                                                   AND agc.tipo = 1
            LEFT OUTER JOIN articulos_glosa                                                             agf ON agf.id_cia = a.id_cia
                                                   AND agf.tipinv = a.tipinv
                                                   AND agf.codart = a.codart
                                                   AND agf.tipo = 2
            INNER JOIN articulos_clase                                                             ac ON ac.id_cia = pin_id_cia
                                             AND ac.tipinv = ll.tipinv
                                             AND ac.codart = ll.codart
                                             AND ac.clase = 9
                                             AND ac.codigo = '1'
            LEFT OUTER JOIN listaprecios                                                                l ON l.id_cia = pin_id_cia
                                              AND l.tipinv = ll.tipinv
                                              AND l.codart = ll.codart
            LEFT OUTER JOIN pack_articulos_clase.sp_tipcamlista(a.id_cia, l.codmon, l.incigv, pin_codmondoc, pin_incigvdoc,
                                                                pin_tipcamdoc, l.precio, l.porigv, pin_femisi)                              tc
                                                                ON 0 = 0
            LEFT OUTER JOIN tmoneda                                                                     md ON md.id_cia = pin_id_cia
                                          --                                          AND md.codmon = l.codmon
                                          AND md.codmon = tc.codmonlista
            LEFT OUTER JOIN TABLE ( sp_select_articulo_clase(pin_id_cia, l.tipinv, l.codart, pclase1) ) a1 ON 0 = 0
            LEFT OUTER JOIN TABLE ( sp_select_articulo_clase(pin_id_cia, l.tipinv, l.codart, pclase2) ) b1 ON 0 = 0
            LEFT OUTER JOIN TABLE ( sp_select_articulo_clase(pin_id_cia, l.tipinv, l.codart, pclase3) ) c1 ON 0 = 0
            LEFT OUTER JOIN TABLE ( sp_select_articulo_clase(pin_id_cia, l.tipinv, l.codart, pclase4) ) d1 ON 0 = 0
            LEFT OUTER JOIN TABLE ( sp_select_articulo_clase(pin_id_cia, l.tipinv, l.codart, pclase5) ) e1 ON 0 = 0
            LEFT OUTER JOIN TABLE ( sp_select_articulo_clase(pin_id_cia, l.tipinv, l.codart, pclase6) ) f1 ON 0 = 0
        WHERE
                l.id_cia = pin_id_cia
            AND ( l.tipinv = pin_tipinv )
            AND ( l.codtit = 99999 )
            AND ( l.codtit = pcodtit )
            AND ( ( pin_codmon IS NULL )
                  OR ( ll.codmon = pin_codmon ) )
            AND ( ( pcodpro = '*' )
                  OR ( ll.codpro = pcodpro ) )
            AND ( ( pin_descla1 IS NULL )
                  OR ( upper(a1.descodigo) LIKE upper(pin_descla1 || '%') ) )
            AND ( ( pin_descla2 IS NULL )
                  OR ( upper(b1.descodigo) LIKE upper(pin_descla2 || '%') ) )
            AND ( ( pin_descla3 IS NULL )
                  OR ( upper(c1.descodigo) LIKE upper(pin_descla3 || '%') ) )
            AND ( ( pin_descla4 IS NULL )
                  OR ( upper(d1.descodigo) LIKE upper(pin_descla4 || '%') ) )
            AND ( ( pin_descla5 IS NULL )
                  OR ( upper(e1.descodigo) LIKE upper(pin_descla5 || '%') ) )
            AND ( ( pin_descla6 IS NULL )
                  OR ( upper(f1.descodigo) LIKE upper(pin_descla6 || '%') ) );

        CURSOR cur_selec_tipo_otros (
            pcodpro VARCHAR2,
            pcodtit NUMBER,
            pclase1 NUMBER,
            pclase2 NUMBER,
            pclase3 NUMBER,
            pclase4 NUMBER,
            pclase5 NUMBER,
            pclase6 NUMBER
        ) IS
        SELECT
            l.codtit,
            l.tipinv,
            l.codart,
            a.descri            AS desart,
            a.coduni,
--            l.precio            AS precio,
            tc.preciolista      AS precio,
            l.desc01            AS desc01,
            l.desc02            AS desc02,
            l.desc03            AS desc03,
            l.desc04            AS desc04,
            md.simbolo,
            md.codmon           AS codmon,
            l.desmax,
            l.incigv            AS incigv,
            a.consto,
            l.porigv            AS porigv,
            l.margen            AS margen,
            l.otros             AS otros,
            l.flete             AS flete,
            a1.clase            AS codcla1,
            upper(a1.descodigo) AS descla1,
            b1.clase            AS codcla2,
            upper(b1.descodigo) AS descla2,
            c1.clase            AS codcla3,
            upper(c1.descodigo) AS descla3,
            d1.clase            AS codcla4,
            upper(d1.descodigo) AS descla4,
            e1.clase            AS codcla5,
            upper(e1.descodigo) AS descla5,
            f1.clase            AS codcla6,
            upper(f1.descodigo) AS descla6,
            ''                  AS codpro,
            CASE
                WHEN ac.codigo = 1 THEN
                    'ACTIVO'
                ELSE
                    'INACTIVO'
            END                 AS situac,
            agc.observ          AS glosacotizaciondefecto,
            agf.observ          AS glosafacturaciondefecto
        FROM
                 listaprecios l
            INNER JOIN articulos                                                                   a ON a.id_cia = pin_id_cia
                                      AND a.tipinv = l.tipinv
                                      AND a.codart = l.codart
                                      AND ( ( pin_descri IS NULL )
                                            OR ( upper(a.descri) LIKE upper(pin_descri || '%') ) )
            LEFT OUTER JOIN articulos_glosa                                                             agc ON agc.id_cia = a.id_cia
                                                   AND agc.tipinv = a.tipinv
                                                   AND agc.codart = a.codart
                                                   AND agc.tipo = 1
            LEFT OUTER JOIN articulos_glosa                                                             agf ON agf.id_cia = a.id_cia
                                                   AND agf.tipinv = a.tipinv
                                                   AND agf.codart = a.codart
                                                   AND agf.tipo = 2
            INNER JOIN articulos_clase                                                             ac ON ac.id_cia = pin_id_cia
                                             AND ac.tipinv = l.tipinv
                                             AND ac.codart = l.codart
                                             AND ac.clase = 9
                                             AND ac.codigo = '1'
            LEFT OUTER JOIN pack_articulos_clase.sp_tipcamlista(a.id_cia, l.codmon, l.incigv, pin_codmondoc, pin_incigvdoc,
                                                                pin_tipcamdoc, l.precio, l.porigv, pin_femisi)                              tc
                                                                ON 0 = 0
            LEFT OUTER JOIN tmoneda                                                                     md ON md.id_cia = pin_id_cia
                                          --                                          AND md.codmon = l.codmon
                                          AND md.codmon = tc.codmonlista
            LEFT OUTER JOIN TABLE ( sp_select_articulo_clase(pin_id_cia, l.tipinv, l.codart, pclase1) ) a1 ON 0 = 0
            LEFT OUTER JOIN TABLE ( sp_select_articulo_clase(pin_id_cia, l.tipinv, l.codart, pclase2) ) b1 ON 0 = 0
            LEFT OUTER JOIN TABLE ( sp_select_articulo_clase(pin_id_cia, l.tipinv, l.codart, pclase3) ) c1 ON 0 = 0
            LEFT OUTER JOIN TABLE ( sp_select_articulo_clase(pin_id_cia, l.tipinv, l.codart, pclase4) ) d1 ON 0 = 0
            LEFT OUTER JOIN TABLE ( sp_select_articulo_clase(pin_id_cia, l.tipinv, l.codart, pclase5) ) e1 ON 0 = 0
            LEFT OUTER JOIN TABLE ( sp_select_articulo_clase(pin_id_cia, l.tipinv, l.codart, pclase6) ) f1 ON 0 = 0
        WHERE
                l.id_cia = pin_id_cia
            AND ( l.tipinv = pin_tipinv )
            AND ( l.codtit = pcodtit )
            AND ( ( pin_descla1 IS NULL )
                  OR ( upper(a1.descodigo) LIKE upper(pin_descla1 || '%') ) )
            AND ( ( pin_descla2 IS NULL )
                  OR ( upper(b1.descodigo) LIKE upper(pin_descla2 || '%') ) )
            AND ( ( pin_descla3 IS NULL )
                  OR ( upper(c1.descodigo) LIKE upper(pin_descla3 || '%') ) )
            AND ( ( pin_descla4 IS NULL )
                  OR ( upper(d1.descodigo) LIKE upper(pin_descla4 || '%') ) )
            AND ( ( pin_descla5 IS NULL )
                  OR ( upper(e1.descodigo) LIKE upper(pin_descla5 || '%') ) )
            AND ( ( pin_descla6 IS NULL )
                  OR ( upper(f1.descodigo) LIKE upper(pin_descla6 || '%') ) );

        v_codpro             VARCHAR2(20);
        v_clase1             NUMBER;
        v_clase2             NUMBER;
        v_clase3             NUMBER;
        v_clase4             NUMBER;
        v_clase5             NUMBER;
        v_clase6             NUMBER;
        v_hcodtit            NUMBER;
    BEGIN
        BEGIN
            SELECT
                clase1,
                clase2,
                clase3,
                clase4,
                clase5,
                clase6
            INTO
                v_clase1,
                v_clase2,
                v_clase3,
                v_clase4,
                v_clase5,
                v_clase6
            FROM
                TABLE ( sp000_saca_clases_treference(pin_id_cia) );

        EXCEPTION
            WHEN no_data_found THEN
                v_clase1 := NULL;
                v_clase2 := NULL;
                v_clase3 := NULL;
                v_clase4 := NULL;
                v_clase5 := NULL;
                v_clase6 := NULL;
        END;

        IF ( pin_codpro IS NULL ) THEN
            v_codpro := '00000000001';
        ELSE
            v_codpro := pin_codpro;
        END IF;

        IF ( ( pin_tipo = 2 ) OR ( pin_tipo = 21 ) ) THEN
            FOR registro_tipo_2_21 IN cur_selec_tipo_2_21(v_codpro, v_clase1, v_clase2, v_clase3, v_clase4,
                                                         v_clase5, v_clase6) LOOP
                rbusqueda_por_clases.codart := registro_tipo_2_21.codart;
                rbusqueda_por_clases.tipinv := registro_tipo_2_21.tipinv;
                rbusqueda_por_clases.desart := registro_tipo_2_21.desart;
                rbusqueda_por_clases.coduni := registro_tipo_2_21.coduni;
                rbusqueda_por_clases.codcla1 := registro_tipo_2_21.codcla1;
                rbusqueda_por_clases.descla1 := registro_tipo_2_21.descla1;
                rbusqueda_por_clases.codcla2 := registro_tipo_2_21.codcla2;
                rbusqueda_por_clases.descla2 := registro_tipo_2_21.descla2;
                rbusqueda_por_clases.codcla3 := registro_tipo_2_21.codcla3;
                rbusqueda_por_clases.descla3 := registro_tipo_2_21.descla3;
                rbusqueda_por_clases.codcla4 := registro_tipo_2_21.codcla4;
                rbusqueda_por_clases.descla4 := registro_tipo_2_21.descla4;
                rbusqueda_por_clases.codcla5 := registro_tipo_2_21.codcla5;
                rbusqueda_por_clases.descla5 := registro_tipo_2_21.descla5;
                rbusqueda_por_clases.codcla6 := registro_tipo_2_21.codcla6;
                rbusqueda_por_clases.descla6 := registro_tipo_2_21.descla6;
                rbusqueda_por_clases.situacion := registro_tipo_2_21.situacion;
                rbusqueda_por_clases.simbolo := '';
                rbusqueda_por_clases.codmon := '';
                rbusqueda_por_clases.precio := 0;
                rbusqueda_por_clases.desc01 := 0;
                rbusqueda_por_clases.desc02 := 0;
                rbusqueda_por_clases.desc03 := 0;
                rbusqueda_por_clases.desc04 := 0;
                rbusqueda_por_clases.desmax := 0;
                rbusqueda_por_clases.incigv := '';
                rbusqueda_por_clases.consto := 0;
                rbusqueda_por_clases.dprecio := 0;
                rbusqueda_por_clases.dincigv := '';
                rbusqueda_por_clases.dporigv := 0;
                rbusqueda_por_clases.dmargen := 0;
                rbusqueda_por_clases.dotros := 0;
                rbusqueda_por_clases.dflete := 0;
                rbusqueda_por_clases.dcodmon := '';
                rbusqueda_por_clases.ddesc01 := 0;
                rbusqueda_por_clases.ddesc02 := 0;
                rbusqueda_por_clases.ddesc03 := 0;
                rbusqueda_por_clases.ddesc04 := 0;
                rbusqueda_por_clases.stock := 0;
                IF ( pin_incstock = 'S' ) THEN
                    rbusqueda_por_clases.stock := sp000_saca_stock_comas(pin_id_cia, registro_tipo_2_21.tipinv, registro_tipo_2_21.codart
                    , pin_almacenes, pin_fdesde,
                                                                        pin_fhasta);
                END IF;

                rbusqueda_por_clases.codpro := '00000000001';
                rbusqueda_por_clases.profactua := NULL;
--            rbusqueda_por_clases.glosacotizaciondefecto := registro_tipo_2_21.glosacotizaciondefecto;
--            rbusqueda_por_clases.glosafacturaciondefecto := registro_tipo_2_21.glosafacturaciondefecto;
                PIPE ROW ( rbusqueda_por_clases );
            END LOOP;
        ELSIF pin_tipo = 4 THEN
            FOR registro_filas IN cur_comas_en_filas(pin_codtit) LOOP
                FOR registro_tipo_004 IN cur_selec_tipo_4(v_codpro, registro_filas.titulo, v_clase1, v_clase2, v_clase3,
                                                         v_clase4, v_clase5, v_clase6) LOOP
                    rbusqueda_por_clases.codtit := registro_tipo_004.codtit;
                    rbusqueda_por_clases.tipinv := registro_tipo_004.tipinv;
                    rbusqueda_por_clases.codart := registro_tipo_004.codart;
                    rbusqueda_por_clases.desart := registro_tipo_004.desart;
                    rbusqueda_por_clases.coduni := registro_tipo_004.coduni;
                    rbusqueda_por_clases.dprecio := registro_tipo_004.dprecio;
                    rbusqueda_por_clases.ddesc01 := registro_tipo_004.ddesc01;
                    rbusqueda_por_clases.ddesc02 := registro_tipo_004.ddesc02;
                    rbusqueda_por_clases.ddesc03 := registro_tipo_004.ddesc03;
                    rbusqueda_por_clases.ddesc04 := registro_tipo_004.ddesc04;
                    rbusqueda_por_clases.simbolo := registro_tipo_004.simbolo;
                    rbusqueda_por_clases.dcodmon := registro_tipo_004.dcodmon;
                    rbusqueda_por_clases.desmax := registro_tipo_004.desmax;
                    rbusqueda_por_clases.dincigv := registro_tipo_004.dincigv;
                    rbusqueda_por_clases.consto := registro_tipo_004.consto;
                    rbusqueda_por_clases.dporigv := registro_tipo_004.dporigv;
                    rbusqueda_por_clases.dmargen := registro_tipo_004.dmargen;
                    rbusqueda_por_clases.dotros := registro_tipo_004.dotros;
                    rbusqueda_por_clases.dflete := registro_tipo_004.dflete;
                    rbusqueda_por_clases.codcla1 := registro_tipo_004.codcla1;
                    rbusqueda_por_clases.descla1 := registro_tipo_004.descla1;
                    rbusqueda_por_clases.codcla2 := registro_tipo_004.codcla2;
                    rbusqueda_por_clases.descla2 := registro_tipo_004.descla2;
                    rbusqueda_por_clases.codcla3 := registro_tipo_004.codcla3;
                    rbusqueda_por_clases.descla3 := registro_tipo_004.descla3;
                    rbusqueda_por_clases.codcla4 := registro_tipo_004.codcla4;
                    rbusqueda_por_clases.descla4 := registro_tipo_004.descla4;
                    rbusqueda_por_clases.codcla5 := registro_tipo_004.codcla5;
                    rbusqueda_por_clases.descla5 := registro_tipo_004.descla5;
                    rbusqueda_por_clases.codcla6 := registro_tipo_004.codcla6;
                    rbusqueda_por_clases.descla6 := registro_tipo_004.descla6;
                    rbusqueda_por_clases.stock := NULL;
                    IF ( pin_incstock = 'S' ) THEN
                        rbusqueda_por_clases.stock := sp000_saca_stock_comas(pin_id_cia, registro_tipo_004.tipinv, registro_tipo_004.codart
                        , pin_almacenes, pin_fdesde,
                                                                            pin_fhasta);
                    END IF;

                    rbusqueda_por_clases.codpro := registro_tipo_004.codpro;
                    rbusqueda_por_clases.situacion := registro_tipo_004.situac;
                    rbusqueda_por_clases.precio := registro_tipo_004.precio;
                    rbusqueda_por_clases.desc01 := registro_tipo_004.desc01;
                    rbusqueda_por_clases.desc02 := registro_tipo_004.desc02;
                    rbusqueda_por_clases.desc03 := registro_tipo_004.desc03;
                    rbusqueda_por_clases.desc04 := registro_tipo_004.desc04;
                    rbusqueda_por_clases.desmax := registro_tipo_004.desmax;
                    rbusqueda_por_clases.incigv := registro_tipo_004.incigv;
                    rbusqueda_por_clases.codmon := registro_tipo_004.codmon;
                    rbusqueda_por_clases.profactua := registro_tipo_004.factua;
                    rbusqueda_por_clases.simbolo := registro_tipo_004.simbolo;
--                rbusqueda_por_clases.glosacotizaciondefecto := registro_tipo_004.glosacotizaciondefecto;
--                rbusqueda_por_clases.glosafacturaciondefecto := registro_tipo_004.glosafacturaciondefecto;
                    PIPE ROW ( rbusqueda_por_clases );
                END LOOP;
            END LOOP;
        ELSIF pin_tipo = 1 THEN
            FOR registro_filas IN cur_comas_en_filas(pin_codtit) LOOP
                FOR registro_tipo_001 IN cur_selec_tipo_1(v_codpro, registro_filas.titulo, v_clase1, v_clase2, v_clase3,
                                                         v_clase4, v_clase5, v_clase6) LOOP
                    rbusqueda_por_clases.codtit := registro_tipo_001.codtit;
                    rbusqueda_por_clases.tipinv := registro_tipo_001.tipinv;
                    rbusqueda_por_clases.codart := registro_tipo_001.codart;
                    rbusqueda_por_clases.desart := registro_tipo_001.desart;
                    rbusqueda_por_clases.coduni := registro_tipo_001.coduni;
                    rbusqueda_por_clases.precio := registro_tipo_001.precio;
                    rbusqueda_por_clases.desc01 := registro_tipo_001.desc01;
                    rbusqueda_por_clases.desc02 := registro_tipo_001.desc02;
                    rbusqueda_por_clases.desc03 := registro_tipo_001.desc03;
                    rbusqueda_por_clases.desc04 := registro_tipo_001.desc04;
                    rbusqueda_por_clases.simbolo := registro_tipo_001.simbolo;
                    rbusqueda_por_clases.codmon := registro_tipo_001.codmon;
                    rbusqueda_por_clases.desmax := registro_tipo_001.desmax;
                    rbusqueda_por_clases.incigv := registro_tipo_001.incigv;
                    rbusqueda_por_clases.consto := registro_tipo_001.consto;
                    rbusqueda_por_clases.dporigv := registro_tipo_001.dporigv;
                    rbusqueda_por_clases.dmargen := registro_tipo_001.dmargen;
                    rbusqueda_por_clases.dotros := registro_tipo_001.dotros;
                    rbusqueda_por_clases.dflete := registro_tipo_001.dflete;
                    rbusqueda_por_clases.codcla1 := registro_tipo_001.codcla1;
                    rbusqueda_por_clases.descla1 := registro_tipo_001.descla1;
                    rbusqueda_por_clases.codcla2 := registro_tipo_001.codcla2;
                    rbusqueda_por_clases.descla2 := registro_tipo_001.descla2;
                    rbusqueda_por_clases.codcla3 := registro_tipo_001.codcla3;
                    rbusqueda_por_clases.descla3 := registro_tipo_001.descla3;
                    rbusqueda_por_clases.codcla4 := registro_tipo_001.codcla4;
                    rbusqueda_por_clases.descla4 := registro_tipo_001.descla4;
                    rbusqueda_por_clases.codcla5 := registro_tipo_001.codcla5;
                    rbusqueda_por_clases.descla5 := registro_tipo_001.descla5;
                    rbusqueda_por_clases.codcla6 := registro_tipo_001.codcla6;
                    rbusqueda_por_clases.descla6 := registro_tipo_001.descla6;
                    rbusqueda_por_clases.stock := NULL;
                    IF ( pin_incstock = 'S' ) THEN
                        rbusqueda_por_clases.stock := '25';
                        rbusqueda_por_clases.stock := sp000_saca_stock_comas(pin_id_cia, registro_tipo_001.tipinv, registro_tipo_001.codart
                        , pin_almacenes, pin_fdesde,
                                                                            pin_fhasta);

                    END IF;

                    rbusqueda_por_clases.codpro := registro_tipo_001.codpro;
                    rbusqueda_por_clases.situacion := registro_tipo_001.situac;
                    rbusqueda_por_clases.dprecio := 0;
                    rbusqueda_por_clases.ddesc01 := NULL;
                    rbusqueda_por_clases.ddesc02 := NULL;
                    rbusqueda_por_clases.ddesc03 := NULL;
                    rbusqueda_por_clases.ddesc04 := NULL;
                    rbusqueda_por_clases.dcodmon := NULL;
                    rbusqueda_por_clases.profactua := NULL;
                    rbusqueda_por_clases.glosacotizaciondefecto := registro_tipo_001.glosacotizaciondefecto;
                    rbusqueda_por_clases.glosafacturaciondefecto := registro_tipo_001.glosafacturaciondefecto;
                    PIPE ROW ( rbusqueda_por_clases );
                END LOOP;
            END LOOP;

 -----           

        ELSIF pin_tipo = 5 THEN
            FOR registro_filas IN cur_comas_en_filas(pin_codtit) LOOP
                FOR registro_tipo_005 IN cur_selec_tipo_5(v_codpro, registro_filas.titulo, v_clase1, v_clase2, v_clase3,
                                                         v_clase4, v_clase5, v_clase6) LOOP
                    rbusqueda_por_clases.codtit := registro_tipo_005.codtit;
                    rbusqueda_por_clases.tipinv := registro_tipo_005.tipinv;
                    rbusqueda_por_clases.codart := registro_tipo_005.codart;
                    rbusqueda_por_clases.desart := registro_tipo_005.desart;
                    rbusqueda_por_clases.coduni := registro_tipo_005.coduni;
                    rbusqueda_por_clases.precio := registro_tipo_005.precio;
                    rbusqueda_por_clases.desc01 := registro_tipo_005.desc01;
                    rbusqueda_por_clases.desc02 := registro_tipo_005.desc02;
                    rbusqueda_por_clases.desc03 := registro_tipo_005.desc03;
                    rbusqueda_por_clases.desc04 := registro_tipo_005.desc04;
                    rbusqueda_por_clases.simbolo := registro_tipo_005.simbolo;
                    rbusqueda_por_clases.codmon := registro_tipo_005.codmon;
                    rbusqueda_por_clases.desmax := registro_tipo_005.desmax;
                    rbusqueda_por_clases.incigv := registro_tipo_005.incigv;
                    rbusqueda_por_clases.consto := registro_tipo_005.consto;
                    rbusqueda_por_clases.dporigv := registro_tipo_005.porigv;
                    rbusqueda_por_clases.dmargen := registro_tipo_005.margen;
                    rbusqueda_por_clases.dotros := registro_tipo_005.otros;
                    rbusqueda_por_clases.dflete := registro_tipo_005.flete;
                    rbusqueda_por_clases.codcla1 := registro_tipo_005.codcla1;
                    rbusqueda_por_clases.descla1 := registro_tipo_005.descla1;
                    rbusqueda_por_clases.codcla2 := registro_tipo_005.codcla2;
                    rbusqueda_por_clases.descla2 := registro_tipo_005.descla2;
                    rbusqueda_por_clases.codcla3 := registro_tipo_005.codcla3;
                    rbusqueda_por_clases.descla3 := registro_tipo_005.descla3;
                    rbusqueda_por_clases.codcla4 := registro_tipo_005.codcla4;
                    rbusqueda_por_clases.descla4 := registro_tipo_005.descla4;
                    rbusqueda_por_clases.codcla5 := registro_tipo_005.codcla5;
                    rbusqueda_por_clases.descla5 := registro_tipo_005.descla5;
                    rbusqueda_por_clases.codcla6 := registro_tipo_005.codcla6;
                    rbusqueda_por_clases.descla6 := registro_tipo_005.descla6;
                    rbusqueda_por_clases.stock := NULL;
                    IF ( pin_incstock = 'S' ) THEN
                        rbusqueda_por_clases.stock := sp000_saca_stock_comas(pin_id_cia, registro_tipo_005.tipinv, registro_tipo_005.codart
                        , pin_almacenes, pin_fdesde,
                                                                            pin_fhasta);
                    END IF;

                    rbusqueda_por_clases.codpro := registro_tipo_005.codpro;
                    rbusqueda_por_clases.situacion := registro_tipo_005.situac;
                    rbusqueda_por_clases.dprecio := 0;
                    rbusqueda_por_clases.ddesc01 := NULL;
                    rbusqueda_por_clases.ddesc02 := NULL;
                    rbusqueda_por_clases.ddesc03 := NULL;
                    rbusqueda_por_clases.ddesc04 := NULL;
                    rbusqueda_por_clases.dcodmon := NULL;
                    rbusqueda_por_clases.profactua := NULL;
--                rbusqueda_por_clases.glosacotizaciondefecto := registro_tipo_005.glosacotizaciondefecto;
--                rbusqueda_por_clases.glosafacturaciondefecto := registro_tipo_005.glosafacturaciondefecto;
                    PIPE ROW ( rbusqueda_por_clases );
                END LOOP;
            END LOOP;
        ELSIF pin_tipo = 6 THEN
            FOR registro_tipo_6 IN cur_selec_tipo_6(v_clase1, v_clase2, v_clase3, v_clase4, v_clase5,
                                                   v_clase6) LOOP
                rbusqueda_por_clases.codtit := registro_tipo_6.codtit;
                rbusqueda_por_clases.tipinv := registro_tipo_6.tipinv;
                rbusqueda_por_clases.codart := registro_tipo_6.codart;
                rbusqueda_por_clases.desart := registro_tipo_6.desart;
                rbusqueda_por_clases.coduni := registro_tipo_6.coduni;
                rbusqueda_por_clases.precio := registro_tipo_6.precio;
                rbusqueda_por_clases.desc01 := registro_tipo_6.desc01;
                rbusqueda_por_clases.desc02 := registro_tipo_6.desc02;
                rbusqueda_por_clases.desc03 := registro_tipo_6.desc03;
                rbusqueda_por_clases.desc04 := registro_tipo_6.desc04;
                rbusqueda_por_clases.simbolo := registro_tipo_6.simbolo;
                rbusqueda_por_clases.codmon := registro_tipo_6.codmon;
                rbusqueda_por_clases.desmax := registro_tipo_6.desmax;
                rbusqueda_por_clases.incigv := registro_tipo_6.incigv;
                rbusqueda_por_clases.consto := registro_tipo_6.consto;
                rbusqueda_por_clases.dporigv := registro_tipo_6.dporigv;
                rbusqueda_por_clases.dmargen := registro_tipo_6.dmargen;
                rbusqueda_por_clases.dotros := registro_tipo_6.dotros;
                rbusqueda_por_clases.dflete := registro_tipo_6.dflete;
                rbusqueda_por_clases.codcla1 := registro_tipo_6.codcla1;
                rbusqueda_por_clases.descla1 := registro_tipo_6.descla1;
                rbusqueda_por_clases.codcla2 := registro_tipo_6.codcla2;
                rbusqueda_por_clases.descla2 := registro_tipo_6.descla2;
                rbusqueda_por_clases.codcla3 := registro_tipo_6.codcla3;
                rbusqueda_por_clases.descla3 := registro_tipo_6.descla3;
                rbusqueda_por_clases.codcla4 := registro_tipo_6.codcla4;
                rbusqueda_por_clases.descla4 := registro_tipo_6.descla4;
                rbusqueda_por_clases.codcla5 := registro_tipo_6.codcla5;
                rbusqueda_por_clases.descla5 := registro_tipo_6.descla5;
                rbusqueda_por_clases.codcla6 := registro_tipo_6.codcla6;
                rbusqueda_por_clases.descla6 := registro_tipo_6.descla6;
                rbusqueda_por_clases.stock := NULL;
                IF ( pin_incstock = 'S' ) THEN
                    rbusqueda_por_clases.stock := sp000_saca_stock_comas(pin_id_cia, registro_tipo_6.tipinv, registro_tipo_6.codart, pin_almacenes
                    , pin_fdesde,
                                                                        pin_fhasta);
                END IF;

--            rbusqueda_por_clases.glosacotizaciondefecto := registro_tipo_6.glosacotizaciondefecto;
--            rbusqueda_por_clases.glosafacturaciondefecto := registro_tipo_6.glosafacturaciondefecto;
                PIPE ROW ( rbusqueda_por_clases );
            END LOOP;
        ELSE
            FOR registro_filas IN cur_comas_en_filas(pin_codtit) LOOP
                FOR registro_tipo_otros IN cur_selec_tipo_otros(v_codpro, registro_filas.titulo, v_clase1, v_clase2, v_clase3,
                                                               v_clase4, v_clase5, v_clase6) LOOP
                    rbusqueda_por_clases.codtit := registro_tipo_otros.codtit;
                    rbusqueda_por_clases.tipinv := registro_tipo_otros.tipinv;
                    rbusqueda_por_clases.codart := registro_tipo_otros.codart;
                    rbusqueda_por_clases.desart := registro_tipo_otros.desart;
                    rbusqueda_por_clases.coduni := registro_tipo_otros.coduni;
                    rbusqueda_por_clases.precio := registro_tipo_otros.precio;
                    rbusqueda_por_clases.desc01 := registro_tipo_otros.desc01;
                    rbusqueda_por_clases.desc02 := registro_tipo_otros.desc02;
                    rbusqueda_por_clases.desc03 := registro_tipo_otros.desc03;
                    rbusqueda_por_clases.desc04 := registro_tipo_otros.desc04;
                    rbusqueda_por_clases.simbolo := registro_tipo_otros.simbolo;
                    rbusqueda_por_clases.codmon := registro_tipo_otros.codmon;
                    rbusqueda_por_clases.desmax := registro_tipo_otros.desmax;
                    rbusqueda_por_clases.incigv := registro_tipo_otros.incigv;
                    rbusqueda_por_clases.consto := registro_tipo_otros.consto;
                    rbusqueda_por_clases.dporigv := registro_tipo_otros.porigv;
                    rbusqueda_por_clases.dmargen := registro_tipo_otros.margen;
                    rbusqueda_por_clases.dotros := registro_tipo_otros.otros;
                    rbusqueda_por_clases.dflete := registro_tipo_otros.flete;
                    rbusqueda_por_clases.codcla1 := registro_tipo_otros.codcla1;
                    rbusqueda_por_clases.descla1 := registro_tipo_otros.descla1;
                    rbusqueda_por_clases.codcla2 := registro_tipo_otros.codcla2;
                    rbusqueda_por_clases.descla2 := registro_tipo_otros.descla2;
                    rbusqueda_por_clases.codcla3 := registro_tipo_otros.codcla3;
                    rbusqueda_por_clases.descla3 := registro_tipo_otros.descla3;
                    rbusqueda_por_clases.codcla4 := registro_tipo_otros.codcla4;
                    rbusqueda_por_clases.descla4 := registro_tipo_otros.descla4;
                    rbusqueda_por_clases.codcla5 := registro_tipo_otros.codcla5;
                    rbusqueda_por_clases.descla5 := registro_tipo_otros.descla5;
                    rbusqueda_por_clases.codcla6 := registro_tipo_otros.codcla6;
                    rbusqueda_por_clases.descla6 := registro_tipo_otros.descla6;
                    rbusqueda_por_clases.stock := NULL;
                    IF ( pin_incstock = 'S' ) THEN
                        rbusqueda_por_clases.stock := sp000_saca_stock_comas(pin_id_cia, registro_tipo_otros.tipinv, registro_tipo_otros.codart
                        , pin_almacenes, pin_fdesde,
                                                                            pin_fhasta);
                    END IF;

                    rbusqueda_por_clases.codpro := registro_tipo_otros.codpro;
                    rbusqueda_por_clases.situacion := registro_tipo_otros.situac;
                    rbusqueda_por_clases.dprecio := 0;
                    rbusqueda_por_clases.ddesc01 := NULL;
                    rbusqueda_por_clases.ddesc02 := NULL;
                    rbusqueda_por_clases.ddesc03 := NULL;
                    rbusqueda_por_clases.ddesc04 := NULL;
                    rbusqueda_por_clases.dcodmon := NULL;
                    rbusqueda_por_clases.profactua := NULL;
--                rbusqueda_por_clases.glosacotizaciondefecto := registro_tipo_otros.glosacotizaciondefecto;
--                rbusqueda_por_clases.glosafacturaciondefecto := registro_tipo_otros.glosafacturaciondefecto;
                    PIPE ROW ( rbusqueda_por_clases );
                END LOOP;
            END LOOP;
             --   END IF;--tipo 5 otros
          --  END IF;--tipo 1
       -- END IF;--tipo 4
        END IF;--tipo 2 or 21

    END sp_buscar;

    FUNCTION sp_buscar_stock (
        pin_id_cia    IN NUMBER,
        pin_tipo      IN NUMBER,
        pin_codtit    IN VARCHAR2,
        pin_tipinv    IN NUMBER,
        pin_codpro    IN VARCHAR2,
        pin_codmon    IN VARCHAR2,
        pin_femisi    IN DATE, --N
        pin_codmondoc IN VARCHAR2, --N
        pin_tipcamdoc NUMBER, --N
        pin_incigvdoc VARCHAR2, --N
        pin_descri    IN VARCHAR2,
        pin_descla1   IN VARCHAR2,
        pin_descla2   IN VARCHAR2,
        pin_descla3   IN VARCHAR2,
        pin_descla4   IN VARCHAR2,
        pin_descla5   IN VARCHAR2,
        pin_descla6   IN VARCHAR2,
        pin_almacenes IN VARCHAR2,
        pin_fdesde    IN NUMBER,
        pin_fhasta    IN NUMBER,
        pin_incstock  IN VARCHAR2,
        pin_anystock  IN VARCHAR2
    ) RETURN datatable_buscar_stock
        PIPELINED
    AS
        v_table datatable_buscar_stock;
    BEGIN
        IF pin_anystock = 'S' THEN
            SELECT
                id_cia,
                codtit,
                tipinv,
                codart,
                desart,
                coduni,
                simbolo,
                codmon,
                precio,
                desc01,
                desc02,
                desc03,
                desc04,
                desmax,
                incigv,
                consto,
                dprecio,
                dincigv,
                dporigv,
                dmargen,
                dotros,
                dflete,
                dcodmon,
                ddesc01,
                ddesc02,
                ddesc03,
                ddesc04,
                codcla1,
                descla1,
                codcla2,
                descla2,
                codcla3,
                descla3,
                codcla4,
                descla4,
                codcla5,
                descla5,
                codcla6,
                descla6,
                stock,
                codpro,
                profactua,
                situacion,
                glosacotizaciondefecto,
                glosafacturaciondefecto,
                (
                    SELECT
                        SUM(TO_NUMBER(column_value))
                    FROM
                        TABLE ( split_string(stock) )
                ) AS totalstock
            BULK COLLECT
            INTO v_table
            FROM
                pack_articulos_clase.sp_buscar(pin_id_cia, pin_tipo, pin_codtit, pin_tipinv, pin_codpro,
                                               pin_codmon, pin_femisi, pin_codmondoc, pin_tipcamdoc, pin_incigvdoc,
                                               pin_descri, pin_descla1, pin_descla2, pin_descla3, pin_descla4,
                                               pin_descla5, pin_descla6, pin_almacenes, pin_fdesde, pin_fhasta,
                                               pin_incstock)
            WHERE
                (
                    SELECT
                        SUM(TO_NUMBER(column_value))
                    FROM
                        TABLE ( split_string(stock) )
                ) > 0;

        ELSIF pin_anystock = 'N' THEN
            SELECT
                id_cia,
                codtit,
                tipinv,
                codart,
                desart,
                coduni,
                simbolo,
                codmon,
                precio,
                desc01,
                desc02,
                desc03,
                desc04,
                desmax,
                incigv,
                consto,
                dprecio,
                dincigv,
                dporigv,
                dmargen,
                dotros,
                dflete,
                dcodmon,
                ddesc01,
                ddesc02,
                ddesc03,
                ddesc04,
                codcla1,
                descla1,
                codcla2,
                descla2,
                codcla3,
                descla3,
                codcla4,
                descla4,
                codcla5,
                descla5,
                codcla6,
                descla6,
                stock,
                codpro,
                profactua,
                situacion,
                glosacotizaciondefecto,
                glosafacturaciondefecto,
                (
                    SELECT
                        SUM(TO_NUMBER(column_value))
                    FROM
                        TABLE ( split_string(stock) )
                ) AS totalstock
            BULK COLLECT
            INTO v_table
            FROM
                pack_articulos_clase.sp_buscar(pin_id_cia, pin_tipo, pin_codtit, pin_tipinv, pin_codpro,
                                               pin_codmon, pin_femisi, pin_codmondoc, pin_tipcamdoc, pin_incigvdoc,
                                               pin_descri, pin_descla1, pin_descla2, pin_descla3, pin_descla4,
                                               pin_descla5, pin_descla6, pin_almacenes, pin_fdesde, pin_fhasta,
                                               pin_incstock);
--            WHERE
--                (
--                    SELECT
--                        SUM(TO_NUMBER(column_value))
--                    FROM
--                        TABLE ( split_string(stock) )
--                ) <= 0;

        ELSE
            SELECT
                id_cia,
                codtit,
                tipinv,
                codart,
                desart,
                coduni,
                simbolo,
                codmon,
                precio,
                desc01,
                desc02,
                desc03,
                desc04,
                desmax,
                incigv,
                consto,
                dprecio,
                dincigv,
                dporigv,
                dmargen,
                dotros,
                dflete,
                dcodmon,
                ddesc01,
                ddesc02,
                ddesc03,
                ddesc04,
                codcla1,
                descla1,
                codcla2,
                descla2,
                codcla3,
                descla3,
                codcla4,
                descla4,
                codcla5,
                descla5,
                codcla6,
                descla6,
                stock,
                codpro,
                profactua,
                situacion,
                glosacotizaciondefecto,
                glosafacturaciondefecto,
                (
                    SELECT
                        SUM(TO_NUMBER(column_value))
                    FROM
                        TABLE ( split_string(stock) )
                ) AS totalstock
            BULK COLLECT
            INTO v_table
            FROM
                pack_articulos_clase.sp_buscar(pin_id_cia, pin_tipo, pin_codtit, pin_tipinv, pin_codpro,
                                               pin_codmon, pin_femisi, pin_codmondoc, pin_tipcamdoc, pin_incigvdoc,
                                               pin_descri, pin_descla1, pin_descla2, pin_descla3, pin_descla4,
                                               pin_descla5, pin_descla6, pin_almacenes, pin_fdesde, pin_fhasta,
                                               pin_incstock);

        END IF;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_buscar_stock;

    FUNCTION sp_ayuda (
        pin_id_cia     NUMBER,
        pin_tipinv     NUMBER,
        pin_codart     VARCHAR2,
        pin_desart     VARCHAR2,
        pin_offset     NUMBER,
        pin_limit      NUMBER,
        pin_soloactivo VARCHAR2
    ) RETURN datatable_ayuda
        PIPELINED
    AS
        v_table datatable_ayuda;
    BEGIN
        SELECT
            a.tipinv  AS tipinv,
            a.codart  AS codart,
            a.descri  AS descri,
            a.codmar  AS codmar,
            a.codubi  AS codubi,
            a.codprc  AS codprc,
            a.codmod  AS codmod,
            a.modelo  AS modelo,
            a.codobs  AS codobs,
            a.coduni  AS coduni,
            a.codlin  AS codlin,
            a.codori  AS codori,
            a.codfam  AS codfam,
            a.codbar  AS codbar,
            a.consto  AS consto,
            a.codprv  AS codprv,
            a.agrupa  AS agrupa,
            a.fcreac  AS fcreac,
            a.fmatri  AS fmatri,
            a.factua  AS factua,
            a.usuari  AS usuari,
            a.wglosa  AS wglosa,
            a.faccon  AS faccon,
            a.tusoesp AS tusoesp,
            a.tusoing AS tusoing,
            a.diacmm  AS diacmm,
            a.cuenta  AS cuenta,
            a.codope  AS codope,
            a.situac  AS situac
        BULK COLLECT
        INTO v_table
        FROM
            articulos       a
            LEFT OUTER JOIN articulos_clase ac ON ac.id_cia = a.id_cia
                                                  AND ac.tipinv = a.tipinv
                                                  AND ac.codart = a.codart
                                                  AND ac.clase = 9
                                                  AND ac.codigo = '1'
        WHERE
                a.id_cia = pin_id_cia
            AND ( nvl(pin_tipinv, - 1) = - 1
                  OR a.tipinv = pin_tipinv )
            AND ( pin_codart IS NULL
                  OR lower(a.codart) LIKE lower(pin_codart) )
            AND ( pin_desart IS NULL
                  OR lower(a.descri) LIKE lower(pin_desart) )
            AND ( nvl(pin_soloactivo, 'N') = 'N'
                  OR ( nvl(pin_soloactivo, 'S') = 'S'
                       AND ac.codigo = '1' ) )
        OFFSET
            CASE
                WHEN pin_offset = - 1 THEN
                    0
                ELSE
                    pin_offset
            END
        ROWS FETCH NEXT
            CASE
                WHEN pin_limit = - 1 THEN
                    1000000
                ELSE
                    pin_limit
            END
        ROWS ONLY;

        FOR registro IN 1..v_table.count LOOP
            PIPE ROW ( v_table(registro) );
        END LOOP;

        RETURN;
    END sp_ayuda;

END;

/

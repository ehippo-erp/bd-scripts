--------------------------------------------------------
--  DDL for Function SP_PLE_14_REGISTRO_VENTAS
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP_PLE_14_REGISTRO_VENTAS" (
    pin_id_cia   IN  NUMBER,
    pin_periodo  IN  NUMBER,
    pin_mes      IN  NUMBER
) RETURN tbl_sp_ple_14_registro_ventas
    PIPELINED


AS
v_secuencia  INTEGER;
v_item INTEGER;
    reg rec_sp_ple_14_registro_ventas := rec_sp_ple_14_registro_ventas(NULL, NULL, NULL, NULL, NULL,
                                                                      NULL, NULL, NULL, NULL, NULL, NULL,
                                                                      NULL, NULL, NULL, NULL, NULL, NULL,
                                                                      NULL, NULL, NULL, NULL,
                                                                      NULL,
                                                                      NULL,
                                                                      NULL,
                                                                      NULL,
                                                                      NULL,
                                                                      NULL,
                                                                      NULL,
                                                                      NULL,
                                                                      NULL,
                                                                      NULL,
                                                                      NULL,
                                                                      NULL);



BEGIN 

    v_item := 1;

    FOR i IN ( 

                SELECT
                    extract(year from c.femisi) * 10000 + extract(month from c.femisi) * 100 AS periodo,

                    fr.ventero fac_entero,
                    doc.libro,

                    c.numint,
                    c.series,
                    c.numdoc,
                    1 AS mcorrasien,                    
                    CAST(
                        CASE
                            WHEN c.situac = 'J' THEN
                                '01/01/0001'
                            ELSE 
                                (to_char(c.femisi, 'DD/MM/RRRR'))
                        END
                    AS VARCHAR(10))                                AS vfeccom,
                    CAST(
                        CASE
                            WHEN c.situac = 'J' THEN
                                '01/01/0001'
                            ELSE
                               (to_char(c.femisi, 'DD/MM/RRRR'))
                        END
                    AS VARCHAR(10))                                AS vfecvenpag,
                                                                    CAST(d2.codsunat AS VARCHAR(02))               AS vtipdoccom,
                    CAST(c.series AS VARCHAR(20))                   AS vnumser,
                    CAST(c.numdoc AS VARCHAR(20))                  AS vnumdoccoi,
                    CASE
                        WHEN c.tipmon IS NULL THEN
                            'PEN'
                        ELSE
                            c.tipmon
                    END                                            AS vmoneda,
                    0                                              AS imptotope,
                    di.codsunat                                    AS vtipdidcli,
                    CAST(c.ruc AS VARCHAR(15))                     AS vnumdidcli,
                    CASE
                        WHEN c.situac = 'J' THEN
                            CAST('ANULADO' AS VARCHAR(100))
                        ELSE
                            c.razonc
                    END                                            AS vapenomrso,
                    CAST(
                        CASE WHEN c.situac = 'J' THEN
                                0
                            ELSE
                                CASE WHEN(coalesce(c.destin, 1) = 2
                                         AND c.monina > 0)
                                        AND(cl.codtpe = 3)
                                        AND(EXISTS(
                                            SELECT
                                                *
                                            FROM
                                                documentos_det
                                            WHERE ID_CIA = c.ID_CIA AND 
                                                    numint = c.numint
                                                AND tipinv IN(1, 2, 3, 6)
                                        )) THEN
                                            c.monina
                                    ELSE
                                        CAST(0 AS NUMERIC(10, 2))
                                END
                                *
                                CASE WHEN c.tipmon = 'PEN' THEN
                                        d2.signo
                                     ELSE
                                        c.tipcam * d2.signo
                                END
                        END
                    AS NUMERIC(16, 2))                                       AS vvalfacexp,
                    CASE WHEN ((c.tipdoc=7) and ( ((extract(year from dr.femisi)*100)+extract(month from dr.femisi)) <> ((extract(year from c.femisi)*100)+extract(month from c.femisi))     )   ) THEN
                                0.0
                        ELSE
                                1.0
                    END
                    * CAST(
                        CASE
                            WHEN c.situac = 'J' THEN 0
                            ELSE CASE WHEN c.tipmon = 'PEN' THEN c.monafe * d2.signo ELSE (c.monafe * c.tipcam) * d2.signo END
                        END
                    AS NUMERIC(16, 2))                                            AS vbasimpgra,
                    CASE WHEN ((c.tipdoc=7) and ( ((extract(year from dr.femisi)*100)+extract(month from dr.femisi)) <> ((extract(year from c.femisi)*100)+extract(month from c.femisi))     )   ) THEN
                                1.0--Modifcado por Problemas en Taga 16-08-2022
                        ELSE
                                0.0
                    END
                    * CAST(
                        CASE WHEN c.situac = 'J' THEN
                                0
                            ELSE
                                CASE WHEN c.tipmon = 'PEN' THEN
                                            c.monigv
                                    ELSE
                                        (c.monigv * c.tipcam)
                                END
                        END
                    AS NUMERIC(16,2))                                            AS vdesigvipm,
                    CASE WHEN ((c.tipdoc=7) and ( ((extract(year from dr.femisi)*100)+extract(month from dr.femisi)) <> ((extract(year from c.femisi)*100)+extract(month from c.femisi))     )   ) THEN
                                1.0--Modifcado por Problemas en Taga 16-08-2022
                        ELSE
                                0.0
                    END
                    * CAST(
                        CASE WHEN c.situac = 'J' THEN
                                0
                            ELSE
                                CASE WHEN c.tipmon = 'PEN' THEN
                                         c.monafe
                                    ELSE
                                        (c.monafe * c.tipcam)
                                END
                        END
                    AS NUMERIC(16, 2))                                            AS vdesbasimpgra,
                    CAST(
                        CASE
                            WHEN c.situac = 'J' THEN
                                0
                            ELSE
                                (
                                    CASE
                                        WHEN(coalesce(c.destin, 1) <> 2
                                             AND c.monina > 0)
                                            AND(cl.codtpe <> 3
                                                AND c22.codigo = 'S') THEN
                                            c.monina
                                        ELSE
                                            CAST(0 AS NUMERIC(10, 2))
                                    END
                                    +
                                    CASE
                                        WHEN(coalesce(c.destin, 1) = 2
                                             AND c.monina > 0)
                                            AND(cl.codtpe = 3)
                                            AND NOT(EXISTS(
                                            SELECT
                                                *
                                            FROM
                                                documentos_det
                                            WHERE ID_CIA = c.ID_CIA AND 
                                                    numint = c.numint
                                                AND tipinv IN(1, 2, 3, 6)
                                        )) THEN
                                            c.monina
                                        ELSE
                                            c.seguro + c.gasadu + c.flete
                                    END
                                    + c.monexo) *
                                CASE
                                    WHEN c.tipmon = 'PEN' THEN
                                            d2.signo
                                    ELSE
                                        c.tipcam * d2.signo
                                END
                        END
                    AS NUMERIC(16, 2))                                       AS vimptotexo,
                    CAST(
                        CASE
                            WHEN c.situac = 'J' THEN
                                0
                            ELSE
                                CASE
                                    WHEN(coalesce(c.destin, 1) = 2
                                         AND c.monina > 0)
                                        OR(cl.codtpe <> 3
                                           AND c22.codigo = 'S') THEN
                                            CAST(0 AS NUMERIC(10, 2))
                                    ELSE
                                        c.monina
                                END
                                *
                                CASE
                                    WHEN c.tipmon = 'PEN' THEN
                                            d2.signo
                                    ELSE
                                        c.tipcam * d2.signo
                                END
                        END
                    AS NUMERIC(16, 2))                                       AS vimptotina,
                    CAST(
                        CASE
                            WHEN c.situac = 'J' THEN
                                0
                            ELSE
                                CASE
                                    WHEN c.tipmon = 'PEN' THEN
                                            c.monisc * d2.signo
                                    ELSE
                                        (c.monisc * c.tipcam) * d2.signo
                                END
                        END
                    AS NUMERIC(16, 2))                                       AS visc,

                    CASE WHEN ((c.tipdoc=7) and ( ((extract(year from dr.femisi)*100)+extract(month from dr.femisi)) <> ((extract(year from c.femisi)*100)+extract(month from c.femisi))     )   ) THEN
                            0.0--Modifcado por Problemas en Taga 16-08-2022
                        ELSE
                            1.0
                    END
                    * CAST(
                        CASE WHEN c.situac = 'J' THEN
                                0
                            ELSE
                                CASE WHEN c.tipmon = 'PEN' THEN
                                            c.monigv * d2.signo
                                    ELSE
                                        (c.monigv * c.tipcam) * d2.signo
                                END
                        END
                    AS NUMERIC(16, 2))                                            AS vigvipm,
                    CAST(0 * d2.signo AS NUMERIC(16, 2))           AS vbasimivap,
                    CAST(0 * d2.signo AS NUMERIC(16, 2))           AS bivap,

                      CAST(CASE WHEN c.SITUAC='J' THEN 0 ELSE
               CASE WHEN C.TIPMON='PEN' THEN C.MONOTR*D2.SIGNO ELSE (C.MONOTR*C.TIPCAM)*D2.SIGNO END
            END                                                                                            AS NUMERIC (16,2)) AS VICBPER,


                    CAST(
                        CASE
                            WHEN c.situac = 'J' THEN
                                0
                            ELSE
                                CASE
                                    WHEN c.tipmon = 'PEN' THEN
                                            c.monotr * d2.signo
                                    ELSE
                                        (c.monotr * c.tipcam) * d2.signo
                                END
                        END
                    AS NUMERIC(16,
                         2))                                       AS votrtricgo,
                    CAST(
                        CASE
                            WHEN c.situac = 'J' THEN
                                0
                            ELSE
                                CASE
                                    WHEN c.tipmon = 'PEN' THEN
                                            c.preven * d2.signo
                                    ELSE
                                        (c.preven * c.tipcam) * d2.signo
                                END
                        END
                    AS NUMERIC(16,
                         2))                                       AS vimptotcom,
                    CAST(
                        CASE
                            WHEN c.situac = 'J' THEN
                                    CASE
                                        WHEN(NOT(c.tipcam IS NULL)
                                                AND(c.tipcam > 0)) THEN
                                            c.tipcam
                                        ELSE
                                            ( SELECT MAX(tc.venta) FROM tcambio tc WHERE ID_CIA = c.ID_CIA AND tc.hmoneda = 'PEN'
                                                    AND tc.fecha = c.femisi
                                                    AND tc.moneda = 'USD'
                                            )
                                    END
                            ELSE
                                c.tipcam
                        END
                    AS NUMERIC(06,
                         3))                                       AS vtipcam,
                    CASE
                        WHEN c.situac = 'J' THEN
                            NULL
                        ELSE
                            dr.tipdoc
                    END AS tipdocre,
                    CASE WHEN c.situac = 'J' THEN NULL ELSE dr.series END AS seriere,
                    CASE WHEN c.situac = 'J' THEN NULL ELSE dr.numdoc END AS numdocre,
                    CASE WHEN c.situac = 'J' THEN NULL ELSE dr.femisi END AS femisire,
                    '0' AS vfobexp,
                    CASE WHEN c.situac <> 'J' THEN 1 ELSE 2 END AS estado
                FROM documentos_cab c
                left outer join documentos doc on doc.id_cia = c.id_cia and doc.codigo = c.tipdoc and doc.series = c.series  
                LEFT OUTER JOIN factor fr ON fr.id_cia = c.id_cia and ( fr.codfac = 380 ) /* TIPO DE REGIMEN */
                LEFT OUTER JOIN identidad di ON di.id_cia = c.id_cia and ( di.tident = c.tident )
                LEFT OUTER JOIN documentos_cab_referencia dr ON DR.id_cia=c.id_cia and (DR.NUMINT=c.NUMINT) AND ( dr.tipdoc IN ( 1, 3, 7, 8, 12 ) ) /* 2015-09-25-NO LETRAS */
                LEFT OUTER JOIN cliente cl ON cl.id_cia = c.id_cia and ( cl.codcli = c.codcli )
                LEFT OUTER JOIN tdoccobranza d2 ON d2.id_cia = c.id_cia  and ( d2.tipdoc = c.tipdoc )
                LEFT OUTER JOIN motivos_clase  mc ON mc.id_cia = c.id_cia and ( mc.tipdoc = c.tipdoc ) AND ( mc.id = c.id ) AND ( mc.codmot = c.codmot ) AND ( mc.codigo = 4 )
                LEFT OUTER JOIN cliente_clase c22 ON c22.id_cia = c.id_cia and c22.tipcli = 'A' AND c22.codcli = c.codcli AND c22.clase = 22 AND NOT ( c22.codigo = 'ND' )
                WHERE c.ID_CIA = pin_id_cia 
                AND ( c.tipdoc IN ( 1, 3, 7, 8, 12 ) )
                and (c.situac IN ('F','C','J'))
                AND ( EXTRACT(year from c.femisi) = pin_periodo )
                AND ( EXTRACT(month from c.femisi) = pin_mes )
                AND ( ( mc.valor IS NULL )
                OR ( upper(mc.valor) = 'S' ) )
                ORDER BY c.tipdoc, c.series, c.numdoc, c.femisi

)
    LOOP

        reg.mcorrasien :=  CASE WHEN i.libro = '00' THEN 'A'
                            ELSE
                                CASE WHEN i.libro = '99' THEN 'C'
                                    ELSE CASE WHEN i.fac_entero = 2 THEN 'M-RER'
                                            ELSE 'M'
                                        END
                                END
                        END || (sp000_ajusta_string(v_item, 4, '0', 'R')) ;
        reg.periodo :=  i.periodo;

        reg.numregope := CASE
                        WHEN i.fac_entero = 1 THEN
                            i.numint 
                            || '-'
                            || i.series
                            || '-'
                            || i.numdoc
                            || '-'
                            || i.libro
                            || '-'
                            || sp000_ajusta_string(v_item , 05, '0', 'R') 
                        ELSE
                            i.libro
                            || '-'
                            || sp000_ajusta_string(v_item , 05, '0', 'R') 
                         END;
        reg.vfeccom := i.vfeccom;
        reg.vfecvenpag := i.vfecvenpag;
        reg.vtipdoccom := i.vtipdoccom;
        reg.vnumser := i.vnumser;
        reg.vnumdoccoi := i.vnumdoccoi;
        reg.vmoneda := i.vmoneda;
        reg.imptotope := i.imptotope;
        reg.vtipdidcli := i.vtipdidcli;
        reg.vnumdidcli := i.vnumdidcli;
        reg.vapenomrso := i.vapenomrso;
        reg.vvalfacexp := i.vvalfacexp;
        reg.vbasimpgra := i.vbasimpgra;
        reg.vdesigvipm := i.vdesigvipm;
        reg.vdesbasimpgra := i.vdesbasimpgra;
        reg.vimptotexo := i.vimptotexo;
        reg.vimptotina := i.vimptotina;
        reg.visc := i.visc;
        reg.vigvipm := i.vigvipm;
        reg.vbasimivap := i.vbasimivap;
        reg.bivap := i.bivap;
        reg.vicbper := i.vicbper; 
        reg.votrtricgo := i.votrtricgo; 
        reg.vimptotcom := i.vimptotcom;
        reg.vtipcam := i.vtipcam;
        reg.tipdocre := i.tipdocre;
        reg.seriere := i.seriere;
        reg.numdocre := i.numdocre;
        reg.femisire := i.femisire; 
        reg.vfobexp := i.vfobexp;
        reg.estado := i.estado; 
        v_item := v_item + 1;
        PIPE ROW ( reg );
    END LOOP;

    RETURN;


END sp_ple_14_registro_ventas;

/

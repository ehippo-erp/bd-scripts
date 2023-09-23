--------------------------------------------------------
--  DDL for Function SP_GETBYNUMINT_TOMAINVENTARIO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "USR_TSI_SUITE"."SP_GETBYNUMINT_TOMAINVENTARIO" (
    pin_id_cia   IN   NUMBER,
    pin_numint   IN   NUMBER
) RETURN tbl_sp_getbynumint_tomainventario
    PIPELINED
AS
    registro rec_sp_getbynumint_tomainventario := rec_sp_getbynumint_tomainventario(NULL, NULL, NULL, NULL, NULL,
                                  NULL, NULL, NULL, NULL, NULL,
                                  NULL, NULL, NULL, NULL, NULL,
                                  NULL, NULL, NULL, NULL, NULL,
                                  NULL, NULL, NULL, NULL, NULL,
                                  NULL, NULL, NULL, NULL, NULL,
                                  NULL, NULL, NULL, NULL, NULL,
                                  NULL, NULL, NULL, NULL, NULL,
                                  NULL, NULL, NULL, NULL, NULL,
                                  NULL, NULL, NULL, NULL, NULL,
                                  NULL, NULL, NULL, NULL, NULL,
                                  NULL, NULL, NULL, NULL, NULL,
                                  NULL, NULL, NULL, NULL, NULL,
                                  NULL, NULL, NULL, NULL, NULL);
CURSOR cur_sp_re_abre_qryformatos_guiaremision IS SELECT
                                                      c.tipdoc       AS tipdoc,
                                                      c.numint       AS numint,
                                                      c.id           AS id,
                                                      c.codmot       AS codmot,
                                                      c.series       AS series,
                                                      c.numdoc       AS numdoc,
                                                      c.femisi       AS femisi,
                                                      c.codcli       AS codcli,
                                                      c.razonc       AS razonc,
                                                      c.direc1       AS direc1,
                                                      c.ruc          AS ruc,
                                                      c.tipcam       AS tipcam,
                                                      c.situac       AS situac,
                                                      c.observ       AS obscab,
                                                      c.fentreg      AS fentreg,
                                                      c.opnumdoc     AS opnumdoc,
                                                      c.ordcom       AS ordcom,
                                                      c.fordcom      AS fordcom,
                                                      c.guipro       AS guipro,
                                                      c.fguipro      AS fguipro,
                                                      c.facpro       AS facpro,
                                                      c.ffacpro      AS ffacpro,
                                                      d.numite       AS dd_numite,
                                                      d.tipinv       AS dd_tipinv,
                                                      d.codalm       AS dd_codalm,
                                                      d.codart       AS dd_codart,
                                                      a.coduni       AS dd_codund,
                                                      d.cantid       AS dd_cantid,
                                                      d.monafe + d.monina AS dd_monlinneto,
                                                      CASE
                                                          WHEN d.cantid IS NULL
                                                               OR d.cantid = 0 THEN
                                                              0
                                                          ELSE
                                                              ( d.monafe + d.monina ) / d.cantid
                                                      END AS dd_monuni,
                                                      d.observ       AS dd_obsdet,
                                                      d.opronumdoc   AS dd_opronumdoc,
                                                      d.opnumdoc     AS dd_dopnumdoc,
                                                      d.opcargo      AS dd_dopcargo,
                                                      d.opnumite     AS dd_dopnumite,
                                                      a.descri       AS dd_desart,
                                                      a.faccon       AS dd_faccon,
                                                      a1.desarea     AS desarea,
                                                      c1.direc1      AS dircli1,
                                                      c1.direc2      AS dircli2,
                                                      m1.desmon      AS desmon,
                                                      m1.simbolo     AS simbolo,
                                                      s2.dessit      AS dessit,
                                                      s2.alias       AS aliassit,
                                                      mt.desmot      AS desmot,
                                                      c2.piepag05    AS piepag05,
                                                      c2.ruc         AS ciaruc,
                                                      c2.fax         AS ciafax,
                                                      c2.telefo      AS ciatelefo,
                                                      NULL AS ocseries,
                                                      0 AS ocnumdoc,
                                                      NULL AS ocfemisi,
                                                      d.opnumite     AS dd_ocnumite,
                                                      d.codadd01     AS dd_codcalid,
                                                      d.codadd02     AS dd_codcolor,
                                                      ca1.descri     AS dd_dcalidad,
                                                      d.codadd02
                                                      || ' - '
                                                      || ca2.descri AS dd_dcolor,
                                                      dcc.vchar      AS situacimp,
                                                      CASE
                                                          WHEN dcc.vchar = 'S' THEN
                                                              'Liquidado'
                                                          ELSE
                                                              'En proceso'
                                                      END AS dessituacimp,
                                                      d.numint       AS dd_numint,
                                                      d.largo        AS dd_largo,
                                                      d.piezas       AS dd_piezas,
                                                      d.tottramo     AS dd_tottramo,
                                                      d.preuni       AS dd_preuni,
                                                      d.costot01     AS dd_costot01,
                                                      d.costot02     AS dd_costot02,
                                                      c.codsuc,
                                                      c.codalm,
                                                      c.optipinv,
                                                      c.tipmon       AS moneda
                                                  FROM
                                                      documentos_cab         c
                                                      LEFT OUTER JOIN documentos_det         d ON d.id_cia = c.id_cia
                                                                                          AND d.numint = c.numint
                                                      LEFT OUTER JOIN documentos_cab_clase   dcc ON dcc.id_cia = c.id_cia
                                                                                                  AND dcc.numint = c.numint
                                                                                                  AND dcc.clase = 1
                                                      LEFT OUTER JOIN articulos              a ON a.id_cia = d.id_cia
                                                                                     AND a.codart = d.codart
                                                                                     AND a.tipinv = d.tipinv
                                                      LEFT OUTER JOIN cliente                c1 ON c1.id_cia = c.id_cia
                                                                                    AND ( c1.codcli = c.codcli )
                                                      LEFT OUTER JOIN tmoneda                m1 ON m1.id_cia = c.id_cia
                                                                                    AND ( m1.codmon = c.tipmon )
                                                      LEFT OUTER JOIN situacion              s2 ON s2.id_cia = c.id_cia
                                                                                      AND ( s2.situac = c.situac )
                                                                                      AND ( s2.tipdoc = c.tipdoc )
                                                      LEFT OUTER JOIN motivos                mt ON mt.id_cia = c.id_cia
                                                                                    AND ( mt.codmot = c.codmot )
                                                                                    AND ( mt.id = c.id )
                                                                                    AND ( c.tipdoc = mt.tipdoc )
                                                      LEFT OUTER JOIN areas                  a1 ON a1.id_cia = c.id_cia
                                                                                  AND ( a1.codarea = c.codarea )
                                                      LEFT OUTER JOIN companias              c2 ON ( c2.cia = c.id_cia )
                                                                                      AND
 ( c.codsuc = c2.codsuc )
LEFT OUTER JOIN cliente_articulos_clase ca1 ON ca1.id_cia = a.id_cia
                                               AND ca1.tipcli = 'B'
                                                   AND ca1.codcli = a.codprv
                                                       AND ca1.clase = 1
                                                           AND ca1.codigo = d.codadd01
LEFT OUTER JOIN cliente_articulos_clase ca2 ON ca2.id_cia = a.id_cia
                                               AND ca2.tipcli = 'B'
                                                   AND ca2.codcli = a.codprv
                                                       AND ca2.clase = 2
                                                           AND ca2.codigo = d.codadd02
		WHERE ( c.id_cia = pin_id_cia )
                                                                                             AND ( c.numint = pin_numint )
		ORDER by c.numint
                                                                                             ,
    d.numite asc;
BEGIN
    FOR j IN cur_sp_re_abre_qryformatos_guiaremision LOOP
        registro.tipdoc := j.tipdoc;
        registro.id := j.id;
        registro.codmot := j.codmot;
        registro.series := j.series;
        registro.numdoc := j.numdoc;
        registro.femisi := j.femisi;
        registro.codcli := j.codcli;
        registro.razonc := j.razonc;
        registro.direc1 := j.direc1;
        registro.ruc := j.ruc;
        registro.tipcam := j.tipcam;
        registro.situac := j.situac;
        registro.obscab := j.obscab;
        registro.fentreg := j.fentreg;
        registro.opnumdoc := j.opnumdoc;
        registro.ordcom := j.ordcom;
        registro.fordcom := j.fordcom;
        registro.guipro := j.guipro;
        registro.fguipro := j.fguipro;
        registro.facpro := j.facpro;
        registro.ffacpro := j.ffacpro;
        registro.dd_numite := j.dd_numite;
        registro.dd_tipinv := j.dd_tipinv;
        registro.dd_codalm := j.dd_codalm;
        registro.dd_codart := j.dd_codart;
        registro.dd_codund := j.dd_codund;
        registro.dd_cantid := j.dd_cantid;
        registro.dd_monlinneto := j.dd_monlinneto;
        registro.dd_monuni := j.dd_monuni;
        registro.dd_obsdet := j.dd_obsdet;
        registro.dd_opronumdoc := j.dd_opronumdoc;
        registro.dd_dopnumdoc := j.dd_dopnumdoc;
        registro.dd_dopcargo := j.dd_dopcargo;
        registro.dd_dopnumite := j.dd_dopnumite;
        registro.dd_desart := j.dd_desart;
        registro.dd_faccon := j.dd_faccon;
        registro.desarea := j.desarea;
        registro.dircli1 := j.dircli1;
        registro.dircli2 := j.dircli2;
        registro.desmon := j.desmon;
        registro.simbolo := j.simbolo;
        registro.dessit := j.dessit;
        registro.aliassit := j.aliassit;
        registro.desmot := j.desmot;
        registro.piepag05 := j.piepag05;
        registro.ciaruc := j.ciaruc;
        registro.ciafax := j.ciafax;
        registro.ciatelefo := j.ciatelefo;
        registro.ocseries := j.ocseries;
        registro.ocnumdoc := j.ocnumdoc;
        registro.ocfemisi := j.ocfemisi;
        registro.dd_ocnumite := j.dd_ocnumite;
        registro.dd_codcalid := j.dd_codcalid;
        registro.dd_codcolor := j.dd_codcolor;
        registro.dd_dcalidad := j.dd_dcalidad;
        registro.situacimp := j.situacimp;
        registro.dessituacimp := j.dessituacimp;
        registro.numint := j.numint;
        registro.dd_largo := j.dd_largo;
        registro.dd_piezas := j.dd_piezas;
        registro.dd_tottramo := j.dd_tottramo;
        registro.dd_preuni := j.dd_preuni;
        registro.dd_costot01 := j.dd_costot01;
        registro.dd_costot02 := j.dd_costot02;
        registro.codsuc := j.codsuc;
        registro.moneda := j.moneda;
        registro.codalm := j.codalm;
        registro.optipinv := j.optipinv;
        PIPE ROW ( registro );
    END LOOP;
END sp_getbynumint_tomainventario;

/

--------------------------------------------------------
--  DDL for Function SP00_SACA_STOCK_DE_ATICULOS_POR_FAMILIA
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP00_SACA_STOCK_DE_ATICULOS_POR_FAMILIA" (
    pin_id_cia    IN  NUMBER,
    pin_anopro    IN  NUMBER,
    pin_mespro    IN  NUMBER,
    pin_tipinv    IN  NUMBER,
    pin_codalm    IN  NUMBER,
    pin_idmoneda  IN  NUMBER,
    pin_indstock  IN  NUMBER
--) RETURN VARCHAR2
) RETURN tbl_stock_por_familia02
    PIPELINED
 AS

    v_table       tbl_stock_por_familia02;
    v_sqlselect   VARCHAR2(10096) := '';
    v_sqlorder    VARCHAR2(150) := '';
--    v_sqljoin     VARCHAR2(1000) := '';
    v_sqlwhere    VARCHAR2(500) := '';
    v_sqlclase1   VARCHAR2(500) := '';
    v_sqlclase2   VARCHAR2(500) := '';
--    v_stralma     VARCHAR2(500) := '';
    v_strmoneda   VARCHAR2(250) := '';
    v_strcodcla1  VARCHAR2(250) := '';
    v_strcodcla2  VARCHAR2(250) := '';
    v_cod_alm     NUMBER;
BEGIN
    IF ( ( pin_codalm IS NULL ) OR ( pin_codalm = 0 ) ) THEN
        v_cod_alm := -1;
    ELSE
        v_cod_alm := pin_codalm;
    END IF;

    v_sqlselect := v_sqlselect
                   || pin_anopro
                   || ','
                   || pin_mespro
                   || ','
                   || ' AA.CODALM, AA.DESALM,AA.ABREVI, ';

    --v_stralma := '';v_stralma || ' AND (AL.CODALM=AA.CODALM)';
    --v_sqljoin := v_sqljoin
--                 || '  LEFT OUTER JOIN ALMACEN   AL ON (AL.id_cia ='
--                 || pin_id_cia
--                 || ') and '
--                 || ' ( al.tipinv = a.tipinv ) '
--                 || v_stralma;

--    v_sqlwhere := v_sqlwhere || v_stralma;

    IF ( pin_idmoneda = 0 ) THEN
        v_strmoneda := '  nvl(AA.COSTOT01,0), nvl(AA.COSUNI01,0),0,0 ';
    END IF;
    IF ( pin_idmoneda = 1 ) THEN
        v_strmoneda := '  0,0,nvl(AA.COSTOT02,0), nvl(AA.COSUNI02,0) ';
    END IF;
    IF ( pin_idmoneda = -1 ) THEN
        v_strmoneda := '  nvl(AA.COSTOT01,0), nvl(AA.COSUNI01,0) , nvl(AA.COSTOT02,0), nvl(AA.COSUNI02,0) ';
    END IF;
    v_sqlselect := v_sqlselect
                   || '  A.TIPINV, TI.DTIPINV , A.CODART , A.DESCRI , A.CODUNI, AC8.VSTRG,'
                   || '  nvl(AA.STOCK,0), nvl(AA.STOCK,0) *(nvl(A.FACCON,0)), '
                   || v_strmoneda;
    v_sqlorder := v_sqlorder || ' A.TIPINV,A.CODART,AA.CODALM ';
    CASE pin_indstock
        WHEN 0 THEN
            v_sqlwhere := v_sqlwhere || ' AND (AA.STOCK <> 0) ';
        WHEN 1 THEN
            v_sqlwhere := v_sqlwhere || ' AND (AA.STOCK > 0 ) ';
        WHEN 2 THEN
            v_sqlwhere := v_sqlwhere || ' AND (AA.STOCK < 0) ';
        WHEN -1 THEN
            v_sqlwhere := v_sqlwhere || ' ';
    END CASE;

    v_sqlselect := 'SELECT rec_stock_por_familia02('
                   || v_sqlselect
                   || ')  FROM  ARTICULOS A '
                   || '  LEFT OUTER JOIN table(SP000_SACA_STOCK_COSTO_ARTICULOS_por_ALMACEN_COSTO('
                   || pin_id_cia
                   || ', a.tipinv,'
                   || v_cod_alm
                   || ',A.CODART,'
                   || pin_anopro
                   || ','
                   || pin_mespro
                   || ')) AA ON (AA.STOCK IS NOT NULL)'
                   || '  LEFT OUTER JOIN T_INVENTARIO               TI  ON '
                   || ' ( TI.id_cia ='
                   || pin_id_cia
                   || ') and (TI.TIPINV =A.TIPINV) '
                   || '  LEFT OUTER JOIN ARTICULO_ESPECIFICACION    AC8 ON '
                   || ' ( AC8.id_cia ='
                   || pin_id_cia
                   || ') and (AC8.TIPINV=A.TIPINV) AND '
                   || '                                                    (AC8.CODART=A.CODART) AND '
                   || '                                                    (AC8.CODESP=8) '
                --   || v_sqljoin
                   || ' WHERE ( A.id_cia ='
                   || pin_id_cia
                   || ') and (A.TIPINV='
                   || pin_tipinv
                   || ') '
                   || v_sqlwhere
                   || ' ORDER BY '
                   || v_sqlorder;

    EXECUTE IMMEDIATE v_sqlselect BULK COLLECT
    INTO v_table;
    FOR registro IN 1..v_table.count LOOP
        PIPE ROW ( v_table(registro) );
    END LOOP;

    return;

--    RETURN v_sqlselect;
END sp00_saca_stock_de_aticulos_por_familia;

/

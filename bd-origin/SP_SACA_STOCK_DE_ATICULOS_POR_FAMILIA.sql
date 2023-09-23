--------------------------------------------------------
--  DDL for Function SP_SACA_STOCK_DE_ATICULOS_POR_FAMILIA
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP_SACA_STOCK_DE_ATICULOS_POR_FAMILIA" (
    pin_id_cia    IN  NUMBER,
    pin_anopro    IN  NUMBER,
    pin_mespro    IN  NUMBER,
    pin_tipinv    IN  NUMBER,
    pin_codalm    IN  NUMBER,
    pin_idmoneda  IN  NUMBER,
    pin_indstock  IN  NUMBER,
    pin_clase1    IN  NUMBER,
    pin_codcla1   IN  VARCHAR2,
    pin_clase2    IN  NUMBER,
    pin_codcla2   IN  VARCHAR2,
    pin_indorden  IN  NUMBER
) RETURN tbl_stock_por_familia
    PIPELINED
AS

    v_table       tbl_stock_por_familia;
    v_sqlselect   VARCHAR2(10096) := '';
    v_sqlorder    VARCHAR2(80) := '';
    v_sqljoin     VARCHAR2(1000) := '';
    v_sqlwhere    VARCHAR2(500) := '';
    v_sqlclase1   VARCHAR2(500) := '';
    v_sqlclase2   VARCHAR2(500) := '';
    v_stralma     VARCHAR2(500) := '';
    v_stralmax    VARCHAR2(20) := '-1';
    v_strmoneda   VARCHAR2(50) := '';
    v_strclase1   VARCHAR2(250) := '';
    v_strcodcla1  VARCHAR2(250) := '';
    v_strclase2   VARCHAR2(250) := '';
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
                   || 'NULL, '
                   || ''''
                   || 'TODOS'
                   || ''''
                   || ', ';

    IF ( v_cod_alm <> -1 ) THEN
        v_sqlselect := '';
        v_sqlselect := v_sqlselect
                       || pin_anopro
                       || ','
                       || pin_mespro
                       || ','
                       || ' AL.CODALM, AL.DESCRI, ';

        v_stralma := v_stralma
                     || ' AND (AL.CODALM='
                     || to_char(v_cod_alm)
                     || ')';
        v_stralmax := v_cod_alm;
        v_sqljoin := v_sqljoin
                     || '  LEFT OUTER JOIN ALMACEN   AL ON (AL.id_cia ='
                     || pin_id_cia
                     || ') and '
                     || ' ( al.tipinv = a.tipinv ) '
                     || v_stralma;

        v_sqlwhere := v_sqlwhere || v_stralma;
        v_sqlorder := v_sqlorder || ' AL.CODALM, ';
    END IF;
    v_strmoneda:= ' 0 , 0 ';
    IF ( pin_idmoneda = 0 ) THEN
        v_strmoneda := '  nvl(AA.COSTOT01,0), nvl(AA.COSUNI01,0) ';
    END IF;
    IF ( pin_idmoneda = 1 ) THEN
        v_strmoneda := '  nvl(AA.COSTOT02,0), nvl(AA.COSUNI02,0) ';
    END IF;
    v_sqlselect := v_sqlselect
                   || '  A.TIPINV, TI.DTIPINV , A.CODART , A.DESCRI , A.CODUNI, AC8.VSTRG,'
                   || '  nvl(AA.STOCK,0), nvl(AA.STOCK,0) *(nvl(A.FACCON,0)), '
                   || v_strmoneda;
    v_sqlorder := v_sqlorder || '  A.TIPINV ';
    v_sqlclase1 := '  ,0 ,'
                   || ''''
                   || ''''
                   || ','
                   || ''''
                   || ''''
                   || ','
                   || ''''
                   || '''';

    v_sqlclase2 := '  ,0 ,'
                   || ''''
                   || ''''
                   || ','
                   || ''''
                   || ''''
                   || ','
                   || ''''
                   || '''';

    IF (
        ( pin_clase1 IS NOT NULL ) AND ( pin_clase1 <> 0 )
    ) THEN
        v_strclase1 := ' AND (AC1.Clase = '
                       || pin_clase1
                       || ') ';
        IF (
            ( pin_codcla1 IS NOT NULL ) AND ( pin_codcla1 <> '-1' )
        ) THEN
            v_strcodcla1 := ' And (AC1.CODIGO='
                            || ''''
                            || pin_codcla1
                            || ''''
                            || ')';
        END IF;

        v_sqlclase1 := '  ,AC1.CLASE ,C1.DESCRI, AC1.CODIGO, CC1.DESCRI ';
        v_sqlwhere := v_sqlwhere
                      || v_strclase1
                      || v_strcodcla1;
        v_sqljoin := v_sqljoin
                     || '  LEFT OUTER JOIN ARTICULOS_CLASE   AC1 on '
                     || ' ( AC1.id_cia= '
                     || pin_id_cia
                     || ') and (AC1.TIPINV =A.TIPINV) AND (AC1.CODART=A.CODART) '
                 --    || v_strcodcla1
                     || '  LEFT OUTER JOIN CLASE C1  ON '
                     || ' ( C1.id_cia= '
                     || pin_id_cia
                     || ') and (C1.TIPINV =A.TIPINV) AND (C1.CLASE =AC1.CLASE) '
                     || '  LEFT OUTER Join CLASE_CODIGO      CC1 ON '
                     || ' ( CC1.id_cia= '
                     || pin_id_cia
                     || ') and(CC1.TIPINV =A.TIPINV) AND (CC1.CLASE =AC1.CLASE) And (CC1.CODIGO=AC1.CODIGO) ';

        v_sqlorder := v_sqlorder || ',AC1.CLASE,AC1.CODIGO';
    END IF;

    IF (
        ( pin_clase2 IS NOT NULL ) AND ( pin_clase2 <> 0 )
    ) THEN
        v_strclase2 := ' AND (AC2.Clase = '
                       || pin_clase2
                       || ') ';
        IF (
            ( pin_codcla2 IS NOT NULL ) AND ( pin_codcla2 <> '-1' )
        ) THEN
            v_strcodcla2 := ' AND (AC2.CODIGO='
                            || ''''
                            || pin_codcla2
                            || ''''
                            || ')';
        END IF;

        v_sqlclase2 := '  ,AC2.CLASE ,C2.DESCRI, AC2.CODIGO, CC2.DESCRI ';
        v_sqlwhere := v_sqlwhere
                      || v_strclase2
                      || v_strcodcla2;
        v_sqljoin := v_sqljoin
                     || '  LEFT OUTER JOIN ARTICULOS_CLASE   AC2 on '
                     || ' ( AC2.id_cia ='
                     || pin_id_cia
                     || ') and (AC2.TIPINV =A.TIPINV) AND (AC2.CODART=A.CODART) '
                  --   || v_strcodcla2
                     || '  LEFT OUTER JOIN CLASE C2  ON '
                     || ' ( C2.id_cia ='
                     || pin_id_cia
                     || ') and (C2.TIPINV =A.TIPINV) AND (C2.CLASE =AC2.CLASE) '
                     || '  LEFT OUTER Join CLASE_CODIGO      CC2 ON '
                     || ' ( CC2.id_cia ='
                     || pin_id_cia
                     || ') and (CC2.TIPINV =A.TIPINV) AND (CC2.CLASE =AC2.CLASE) And (CC2.CODIGO=AC2.CODIGO) ';

        v_sqlorder := v_sqlorder || ',AC2.CLASE,AC2. CODIGO';
    END IF;

    v_sqlselect := v_sqlselect
                   || v_sqlclase1
                   || v_sqlclase2;
    IF ( pin_indorden = 0 ) THEN
        v_sqlorder := v_sqlorder || ',A.CODART ';
    END IF;
    IF ( pin_indorden = 1 ) THEN
        v_sqlorder := v_sqlorder || ',A.DESCRI ';
    END IF;
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

    v_sqlselect := 'SELECT rec_stock_por_familia('
                   || v_sqlselect
                   || ')  FROM  ARTICULOS A '
                   || '  LEFT OUTER JOIN table(SP000_SACA_STOCK_COSTO_ARTICULOS_ALMACEN_COSTO('
                   || pin_id_cia
                   || ', a.tipinv,'
                   || v_stralmax
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
                   || v_sqljoin
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
END sp_saca_stock_de_aticulos_por_familia;

/

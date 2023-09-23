--------------------------------------------------------
--  DDL for Function SP01_SACA_UNA_CUENTA_CLIENTE
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP01_SACA_UNA_CUENTA_CLIENTE" (
    pid_cia  NUMBER,
    pcodcli  cliente.codcli%TYPE,
    ptipmon  VARCHAR2
) RETURN VARCHAR2 IS

    p_returnvalue  SYS_REFCURSOR;
    TYPE datarecord IS RECORD (
        desefi   e_financiera_tipo.descri%TYPE,
        simbolo  tmoneda.simbolo%TYPE,
        cuenta   cliente_bancos.cuenta%TYPE
    );
    v_rec          datarecord;
    strin          VARCHAR2(350) := 'IN ('
                           || ''''
                           || replace(ptipmon, ' ', ''''
                                                    || ','
                                                    || '''')
                           || ''''
                           || ')';
    strselect      VARCHAR2(2000) := 'SELECT  EF.DESCRI,TM.SIMBOLO,CB.CUENTA '
                                || 'FROM CLIENTE_BANCOS CB '
                                || 'LEFT OUTER JOIN E_FINANCIERA_TIPO EF ON ef.id_cia = cb.id_cia '
                                || '                                        and EF.TIPCTA=CB.TIPCTA '
                                || 'LEFT OUTER JOIN TMONEDA TM ON tm.id_cia = cb.id_cia '
                                || '                           and TM.CODMON=CB.TIPMON '
                                || ' WHERE cb.id_cia = :wid_cia '
                                || '       and CB.CODCLI= :wCodcli '
                                || ' AND CB.TIPMON '
                                || strin
                                || ' FETCH FIRST 1 ROW ONLY';
BEGIN
    IF TRIM(ptipmon) IS NULL THEN
        RETURN NULL;
    ELSE
        OPEN p_returnvalue FOR strselect
            USING pid_cia, pcodcli;

        LOOP
            FETCH p_returnvalue INTO v_rec;
            IF p_returnvalue%found THEN
                RETURN v_rec.desefi
                       || ' '
                       || v_rec.simbolo
                       || ' NRO '
                       || v_rec.cuenta;

            ELSE
                RETURN NULL;
            END IF;

        END LOOP;

        CLOSE p_returnvalue;
    END IF;
END sp01_saca_una_cuenta_cliente;

/

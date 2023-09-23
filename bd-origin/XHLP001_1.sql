--------------------------------------------------------
--  DDL for Package Body XHLP001
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."XHLP001" IS

    FUNCTION clasestbancos RETURN datatable
        PIPELINED
    IS
        v_clasestbancos datarecord := datarecord(NULL, NULL);
    BEGIN
        FOR i IN pkg_constantes.kaclastbancos.first..pkg_constantes.kaclastbancos.last LOOP
            v_clasestbancos.codigo := i;
            v_clasestbancos.descripcion := pkg_constantes.kaclastbancos(i);
            PIPE ROW ( v_clasestbancos );
        END LOOP;

        return;
    END clasestbancos;
    FUNCTION bancos RETURN datatable
        PIPELINED
    IS
        v_bancos datarecord := datarecord(NULL, NULL);
    BEGIN
        FOR i IN pkg_constantes.kabancos.first..pkg_constantes.kabancos.last LOOP
            v_bancos.codigo := i;
            v_bancos.descripcion := pkg_constantes.kabancos(i);
            PIPE ROW ( v_bancos );
        END LOOP;

        return;
    END bancos;
END xhlp001;

/

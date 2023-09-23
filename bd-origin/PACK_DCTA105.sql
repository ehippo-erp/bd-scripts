--------------------------------------------------------
--  DDL for Package PACK_DCTA105
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_DCTA105" AS

    TYPE datarecord_imprime_letra IS RECORD(
        id_cia dcta105.id_cia%TYPE,
        series dcta105.series%TYPE,
        numdoc dcta105.numdoc%TYPE,
        libro dcta105.libro%TYPE,
        periodo dcta105.periodo%TYPE,
        mes dcta105.mes%TYPE,
        secuencia dcta105.secuencia%TYPE,
        femisi dcta105.femisi%TYPE,
        fvenci dcta105.fvenci%TYPE,
        tipmon dcta105.tipmon%TYPE,
        importe dcta105.importe%TYPE,
        refere dcta105.refere%TYPE,
        simbolo tmoneda.simbolo%TYPE,
        nomdis sucursal.nomdis%TYPE,
        codcli dcta105.codcli%TYPE,
        razonc cliente.razonc%TYPE,
        dident cliente.dident%TYPE,
        codtpe cliente.codtpe%TYPE,
        direc1 cliente.direc1%TYPE,
        direc2 cliente.direc2%TYPE,
        telefono cliente.telefono%TYPE,
        codaval cliente.codcli%TYPE,
        telefonoaval cliente.telefono%TYPE,
        razoncaval cliente.razonc%TYPE,
        didentaval cliente.dident%TYPE,
        direc1aval cliente.direc1%TYPE,
        direc2aval cliente.direc2%TYPE,
        codaval2 cliente.codcli%TYPE,
        telefonoaval2 cliente.telefono%TYPE,
        dir_depart VARCHAR2(250),
        dir_provin VARCHAR2(250),
        dir_distri VARCHAR2(250),
        distrito VARCHAR2(250),
        razoncaval2 cliente.razonc%TYPE,
        didentaval2 cliente.dident%TYPE,
        direc1aval2 cliente.direc1%TYPE,
        direc2aval2 cliente.direc2%TYPE,
        distriaval1 VARCHAR2(250),
        distriaval2 VARCHAR2(250),
        codsuc NUMBER,
        dessuc VARCHAR2(120)
    );
        TYPE datatable_imprime_letra IS
            TABLE OF datarecord_imprime_letra;

    FUNCTION sp_imprime_letra (
        pin_id_cia NUMBER,
        pin_tipdoc NUMBER,
        pin_numdoc NUMBER
    ) RETURN datatable_imprime_letra
        PIPELINED;

    FUNCTION sp_imprime_letra_planilla (
        pin_id_cia NUMBER,
        pin_libro VARCHAR2,
        pin_periodo NUMBER,
        pin_mes NUMBER,
        pin_secuencia NUMBER
    ) RETURN datatable_imprime_letra
        PIPELINED;

END;

/

--------------------------------------------------------
--  DDL for Package Body PACK_AYUDA_CAJACHICA_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_AYUDA_CAJACHICA_001" AS

    FUNCTION hlp_libros_cajachica (
        pin_id_cia IN NUMBER
    ) RETURN librodatatable
        PIPELINED
    IS

        registro librodatarecord := librodatarecord(NULL, NULL, NULL);
        CURSOR cur_sp_libro_pack_ayuda_cajachica_001 IS     
     /*LIBRO*/
        SELECT
            l.codlib,
            l.descri,
            l.motivo
        FROM
            tlibro          l
            INNER JOIN tlibros_clase   lc ON ( lc.id_cia = l.id_cia )
                                           AND ( lc.codlib = l.codlib )
                                           AND ( lc.clase = 4 )
                                           AND ( lc.vstrg = 'S' )
        WHERE
            l.id_cia = pin_id_cia;

    BEGIN
        FOR j IN cur_sp_libro_pack_ayuda_cajachica_001 LOOP
            registro.codlib := j.codlib;
            registro.descri := j.descri;
            registro.motivo := j.motivo;
            PIPE ROW ( registro );
        END LOOP;
    END;

    /**************FUNCION AYUDA PERSONA*****************************/

    FUNCTION hlp_personal_cajachica (
        pin_id_cia IN NUMBER
    ) RETURN personaldatatable
        PIPELINED
    IS

        registro personaldatarecord := personaldatarecord(NULL, NULL);
        CURSOR cur_sp_personal_pack_ayuda_cajachica_001 IS     
    /*PERSONAL*/
        SELECT DISTINCT
            e.codcli   AS codper,
            e.razonc   AS nombres
        FROM
            cliente         e
            INNER JOIN cliente_clase   t ON ( t.id_cia = e.id_cia )
                                          AND t.codcli = e.codcli
                                          AND t.tipcli IN (
                'E',
                'O',
                'P'
            )
                                          AND t.clase = 1
                                          AND t.codigo = '1'
            INNER JOIN cliente_clase   c ON ( c.id_cia = e.id_cia )
                                          AND c.codcli = e.codcli
                                          AND c.tipcli IN (
                'E',
                'O',
                'P'
            )
                                          AND c.clase = 10
                                          AND upper(c.codigo) = 'S'
        WHERE
            e.id_cia = pin_id_cia
        ORDER BY
            e.razonc;

    BEGIN
        FOR j IN cur_sp_personal_pack_ayuda_cajachica_001 LOOP
            registro.codper := j.codper;
            registro.nombres := j.nombres;
            PIPE ROW ( registro );
        END LOOP;
    END;

/**************FUNCION CAJA DE PAGO PERSONA*****************************/

    FUNCTION hlp_cuenta_de_pago_cajachica (
        pin_id_cia IN NUMBER
    ) RETURN cuentapagodatatable
        PIPELINED
    IS

        registro cuentapagodatarecord := cuentapagodatarecord(NULL, NULL);
        CURSOR cur_sp_cuentapago_pack_ayuda_cajachica_001 IS     
     /*CUENTA DE PAGO*/
        SELECT
            p.cuenta,
            p.nombre
        FROM
            pcuentas         p
            INNER JOIN pcuentas_clase   pc ON ( pc.id_cia = p.id_cia )
                                            AND pc.cuenta = p.cuenta
                                            AND pc.clase = 11
                                            AND pc.codigo = '1'
            INNER JOIN pcuentas_clase   pc2 ON ( pc2.id_cia = p.id_cia )
                                             AND pc2.cuenta = p.cuenta
                                             AND pc2.clase = 9
                                             AND pc2.swflag = 'S'
        WHERE
            ( p.imputa = 'S' )
            AND ( p.id_cia = pin_id_cia )
        ORDER BY
            p.nombre;

    BEGIN
        FOR j IN cur_sp_cuentapago_pack_ayuda_cajachica_001 LOOP
            registro.cuenta := j.cuenta;
            registro.nombre := j.nombre;
            PIPE ROW ( registro );
        END LOOP;
    END;

    /**************FUNCION CENTRO DE COSTO*****************************/

    FUNCTION hlp_centro_de_costo_cajachica (
        pin_id_cia IN NUMBER
    ) RETURN centrocostodatatable
        PIPELINED
    IS

        registro centrocostodatarecord := centrocostodatarecord(NULL, NULL);
        CURSOR cur_sp_centrocosto_pack_ayuda_cajachica_001 IS     
     /*CENTRO DE COSTO*/
        SELECT
            codigo,
            descri
        FROM
            tccostos
        WHERE
            tccostos.id_cia = pin_id_cia
        ORDER BY
            descri;

    BEGIN
        FOR j IN cur_sp_centrocosto_pack_ayuda_cajachica_001 LOOP
            registro.codigo := j.codigo;
            registro.descri := j.descri;
            PIPE ROW ( registro );
        END LOOP;
    END;

    /**************FUNCION TIPOS DE PAGO*****************************/

    FUNCTION hlp_tipo_de_pago_cajachica (
        pin_id_cia IN NUMBER
    ) RETURN tipopagodatatable
        PIPELINED
    IS

        registro tipopagodatarecord := tipopagodatarecord(NULL, NULL);
        CURSOR cur_sp_tipopago_pack_ayuda_cajachica_001 IS     
     /*TIPO DE PAGO*/
        SELECT
            codigo,
            descri
        FROM
            m_pago
        WHERE
            m_pago.id_cia = pin_id_cia
        ORDER BY
            descri;

    BEGIN
        FOR j IN cur_sp_tipopago_pack_ayuda_cajachica_001 LOOP
            registro.codigo := j.codigo;
            registro.descri := j.descri;
            PIPE ROW ( registro );
        END LOOP;
    END;

    /**************FUNCION NUMERO CAJA *****************************/

    FUNCTION hlp_numero_caja_cajachica (
        pin_id_cia    IN   NUMBER,
        pin_coduser   IN   VARCHAR2,
        pin_tipo      IN   NUMBER,
        pin_periodo   IN   NUMBER,
        pin_mes       IN   NUMBER
    ) RETURN numerocajadatatable
        PIPELINED
    IS

        registro   numerocajadatarecord := numerocajadatarecord(NULL, NULL, NULL);
        CURSOR cur_sp_numerocaja_pack_ayuda_cajachica_001 (
            pv_p030 VARCHAR2
        ) IS     
     /*NUMERO DE CAJA*/
        SELECT
            c.tipo,
            c.docume,
            h.girara
        FROM
            compr040   c
            LEFT OUTER JOIN asienhea   h ON h.periodo = c.periodo
                                          AND h.mes = c.mes
                                          AND h.libro = c.librop
                                          AND h.asiento = c.asientop
        WHERE
            ( c.id_cia = pin_id_cia )
            AND ( ( c.usuari = pin_coduser )
                  OR ( pv_p030 = 'S' ) )
            AND ( ( c.tipo = pin_tipo )
                  OR ( 0 = pin_tipo ) )
            AND ( ( c.periodo = pin_periodo )
                  OR ( 0 = pin_periodo ) )
            AND ( ( c.mes = pin_mes )
                  OR ( 0 = pin_mes ) );

        v_p030     VARCHAR2(38) := '';
    BEGIN
        BEGIN
            SELECT
                swflag
            INTO v_p030
            FROM
                usuarios_propiedades
            WHERE
                coduser = 'ADMIN'
                AND codigo = 30;

        EXCEPTION
            WHEN no_data_found THEN
                v_p030 := 'N';
        END;

        FOR j IN cur_sp_numerocaja_pack_ayuda_cajachica_001(v_p030) LOOP
            registro.tipo := j.tipo;
            registro.docume := j.docume;
            registro.girara := j.girara;
            PIPE ROW ( registro );
        END LOOP;

    END;

END;

/

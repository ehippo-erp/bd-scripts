--------------------------------------------------------
--  DDL for Procedure SP_GENERA_DATOS_NUEVA_EMPRESA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_GENERA_DATOS_NUEVA_EMPRESA" (
    pin_id_cia         IN NUMBER,
    pin_id_cia_orig    IN NUMBER,
    pin_id_cia_hr_orig IN NUMBER,
    pin_inc_pcuentas   IN VARCHAR2,
    pin_inc_usuarios   IN VARCHAR2,
    pin_grupo          IN VARCHAR2,
    pin_coduser        IN VARCHAR2,
    pin_mensaje        OUT VARCHAR2
) AS

    empresa_modelo_id    NUMBER := 5;
    hr_empresa_modelo_id NUMBER := 5;
    v_user_admin         VARCHAR2(20);
    v_inc_pcuentas       VARCHAR2(20) := 'S';
    v_accion             VARCHAR2(50) := '';
    o                    json_object_t;
    m                    json_object_t;
    v_mensaje            VARCHAR2(1000 CHAR);
    pout_mensaje         VARCHAR2(1000 CHAR);
BEGIN
    IF nvl(pin_inc_usuarios, 'N') = 'N' THEN
        v_user_admin := 'admin';
    ELSE
        v_user_admin := NULL;
    END IF;

    IF pin_id_cia_orig IS NOT NULL THEN
        empresa_modelo_id := pin_id_cia_orig;
    END IF;
    IF pin_id_cia_hr_orig IS NOT NULL THEN
        hr_empresa_modelo_id := pin_id_cia_hr_orig;
    END IF;
    IF pin_inc_pcuentas IS NOT NULL THEN
        v_inc_pcuentas := pin_inc_pcuentas;
    END IF;

-- INSERTANDO GRUPO DE EMPRESA, SI EXISTE
    INSERT INTO companias_grupo
        (
            SELECT
                cg.id_grup,
                cg.grupo,
                pin_id_cia
            FROM
                companias_grupo cg
            WHERE
                cg.grupo = pin_grupo
            FETCH NEXT 1 ROWS ONLY
        );

-- ALMACEN 
    INSERT INTO almacen (
        id_cia,
        tipinv,
        codalm,
        codsuc,
        descri,
        abrevi,
        fcreac,
        factua,
        usuari,
        swacti,
        swterc,
        ubigeo,
        direcc,
        consigna
    )
        SELECT
            pin_id_cia,
            tipinv,
            codalm,
            codsuc,
            descri,
            abrevi,
            fcreac,
            factua,
            usuari,
            swacti,
            swterc,
            ubigeo,
            direcc,
            consigna
        FROM
            almacen
        WHERE
            id_cia = empresa_modelo_id;

-- ALMACEN_CLASE 
    INSERT INTO almacen_clase (
        id_cia,
        tipinv,
        codalm,
        clase,
        codigo,
        vreal,
        vstrg,
        vchar,
        vdate,
        vtime,
        ventero,
        codusercrea,
        coduseractu,
        fcreac,
        factua
    )
        SELECT
            pin_id_cia,
            tipinv,
            codalm,
            clase,
            codigo,
            vreal,
            vstrg,
            vchar,
            vdate,
            vtime,
            ventero,
            codusercrea,
            coduseractu,
            fcreac,
            factua
        FROM
            almacen_clase
        WHERE
            id_cia = empresa_modelo_id;

-- BGENERALHEA 
    INSERT INTO bgeneralhea (
        id_cia,
        codigo,
        tipo,
        titulo,
        codadic,
        consig
    )
        SELECT
            pin_id_cia,
            codigo,
            tipo,
            titulo,
            codadic,
            consig
        FROM
            bgeneralhea
        WHERE
            id_cia = empresa_modelo_id;

-- BGENERALDET 
    INSERT INTO bgeneraldet (
        id_cia,
        codigo,
        cuenta
    )
        SELECT
            pin_id_cia,
            codigo,
            cuenta
        FROM
            bgeneraldet
        WHERE
            id_cia = empresa_modelo_id;

-- C_PAGO 
    INSERT INTO c_pago (
        id_cia,
        codpag,
        despag,
        detalle,
        diaven,
        fcreac,
        factua,
        usuari,
        canjlet,
        cantlet,
        pordes,
        swacti
    )
        SELECT
            pin_id_cia,
            codpag,
            despag,
            detalle,
            diaven,
            fcreac,
            factua,
            usuari,
            canjlet,
            cantlet,
            pordes,
            swacti
        FROM
            c_pago
        WHERE
                id_cia = empresa_modelo_id
            AND codpag = 1;

-- C_PAGO_CLASE 
    INSERT INTO c_pago_clase (
        id_cia,
        codpag,
        codigo,
        descri,
        valor
    )
        SELECT
            pin_id_cia,
            cp.codpag,
            cp.codigo,
            cp.descri,
            cp.valor
        FROM
            c_pago_clase cp
        WHERE
                cp.id_cia = empresa_modelo_id
            AND cp.codpag = 1
            AND NOT EXISTS (
                SELECT
                    *
                FROM
                    c_pago_clase
                WHERE
                        id_cia = pin_id_cia
                    AND codpag = 1
                    AND codigo = cp.codigo
            );

        -- C_PAGO_COMPRAS 
    INSERT INTO c_pago_compras (
        id_cia,
        codpag,
        despag,
        detalle,
        fcreac,
        factua,
        usuari,
        swacti
    )
        SELECT
            pin_id_cia,
            codpag,
            despag,
            detalle,
            fcreac,
            factua,
            usuari,
            swacti
        FROM
            c_pago_compras
        WHERE
            id_cia = empresa_modelo_id;

-- C_PAGO_DET 
    INSERT INTO c_pago_det (
        id_cia,
        codpag,
        item,
        despag,
        diaven,
        fcreac,
        factua,
        usuari
    )
        SELECT
            pin_id_cia,
            codpag,
            item,
            despag,
            diaven,
            fcreac,
            factua,
            usuari
        FROM
            c_pago_det cpd
        WHERE
                cpd.id_cia = empresa_modelo_id
            AND NOT EXISTS (
                SELECT
                    *
                FROM
                    c_pago_det
                WHERE
                        id_cia = cpd.id_cia
                    AND codpag = cpd.codpag
                    AND item = cpd.item
            );

-- CLASE 
    INSERT INTO clase (
        id_cia,
        tipinv,
        clase,
        descri,
        secuen,
        longit,
        autogenera,
        obliga,
        situac,
        fcreac,
        factua,
        usuari,
        swcorr,
        correl
    )
        SELECT
            pin_id_cia,
            c.tipinv,
            c.clase,
            c.descri,
            c.secuen,
            c.longit,
            c.autogenera,
            c.obliga,
            c.situac,
            c.fcreac,
            c.factua,
            c.usuari,
            c.swcorr,
            c.correl
        FROM
            clase c
        WHERE
                c.id_cia = empresa_modelo_id
            AND NOT EXISTS (
                SELECT
                    *
                FROM
                    clase
                WHERE
                        id_cia = pin_id_cia
                    AND tipinv = c.tipinv
                    AND clase = c.clase
            );



-- CLASE_ARTICULOS_ALTERNATIVO 
    INSERT INTO clase_articulos_alternativo (
        id_cia,
        clase,
        descri,
        vreal,
        vstrg,
        vchar,
        vdate,
        vtime,
        ventero,
        swacti,
        obliga,
        codusercrea,
        coduseractu,
        fcreac,
        factua
    )
        SELECT
            pin_id_cia,
            clase,
            descri,
            vreal,
            vstrg,
            vchar,
            vdate,
            vtime,
            ventero,
            swacti,
            obliga,
            codusercrea,
            coduseractu,
            fcreac,
            factua
        FROM
            clase_articulos_alternativo
        WHERE
            id_cia = empresa_modelo_id;

-- CLASE_CLIENTE 
    INSERT INTO clase_cliente (
        id_cia,
        tipcli,
        clase,
        descri,
        secuen,
        longit,
        situac,
        fcreac,
        factua,
        usuari,
        obliga
    )
        SELECT
            pin_id_cia,
            tipcli,
            clase,
            descri,
            secuen,
            longit,
            situac,
            fcreac,
            factua,
            usuari,
            obliga
        FROM
            clase_cliente
        WHERE
            id_cia = empresa_modelo_id;

-- CLASE_CLIENTE_ARTICULOS 
    INSERT INTO clase_cliente_articulos (
        id_cia,
        tipcli,
        clase,
        descri,
        vreal,
        vstrg,
        vchar,
        vdate,
        vtime,
        ventero,
        swacti,
        obliga,
        fcreac,
        factua,
        usuari
    )
        SELECT
            pin_id_cia,
            tipcli,
            clase,
            descri,
            vreal,
            vstrg,
            vchar,
            vdate,
            vtime,
            ventero,
            swacti,
            obliga,
            fcreac,
            factua,
            usuari
        FROM
            clase_cliente_articulos
        WHERE
            id_cia = empresa_modelo_id;


-- CLASE_CLIENTE_CODIGO 
    INSERT INTO clase_cliente_codigo (
        id_cia,
        tipcli,
        clase,
        codigo,
        descri,
        abrevi,
        situac,
        fcreac,
        factua,
        usuari,
        swdefaul
    )
        SELECT
            pin_id_cia,
            tipcli,
            clase,
            codigo,
            descri,
            abrevi,
            situac,
            fcreac,
            factua,
            usuari,
            swdefaul
        FROM
            clase_cliente_codigo
        WHERE
            id_cia = empresa_modelo_id;

-- CLASE_CLIENTES_ALMACEN 
    INSERT INTO clase_clientes_almacen (
        id_cia,
        clase,
        descri,
        vreal,
        vstrg,
        vchar,
        vdate,
        vtime,
        ventero,
        vblob,
        swacti,
        obliga,
        usuari,
        codusercrea,
        coduseractu,
        fcreac,
        factua
    )
        SELECT
            pin_id_cia,
            clase,
            descri,
            vreal,
            vstrg,
            vchar,
            vdate,
            vtime,
            ventero,
            vblob,
            swacti,
            obliga,
            usuari,
            codusercrea,
            coduseractu,
            fcreac,
            factua
        FROM
            clase_clientes_almacen
        WHERE
            id_cia = empresa_modelo_id;


-- CLASE_CLIENTES_ALMACEN_CODIGO 
    INSERT INTO clase_clientes_almacen_codigo (
        id_cia,
        clase,
        codigo,
        descri,
        abrevi,
        situac,
        usuari,
        codusercrea,
        coduseractu,
        fcreac,
        factua,
        swdefaul
    )
        SELECT
            pin_id_cia,
            clase,
            codigo,
            descri,
            abrevi,
            situac,
            usuari,
            codusercrea,
            coduseractu,
            fcreac,
            factua,
            swdefaul
        FROM
            clase_clientes_almacen_codigo
        WHERE
            id_cia = empresa_modelo_id;


-- CLASE_CODIGO 
    INSERT INTO clase_codigo (
        id_cia,
        tipinv,
        clase,
        codigo,
        descri,
        abrevi,
        situac,
        fcreac,
        factua,
        usuari,
        swdefaul,
        orden
    )
        SELECT
            pin_id_cia,
            cc.tipinv,
            cc.clase,
            cc.codigo,
            cc.descri,
            cc.abrevi,
            cc.situac,
            cc.fcreac,
            cc.factua,
            cc.usuari,
            cc.swdefaul,
            cc.orden
        FROM
            clase_codigo cc
        WHERE
                id_cia = empresa_modelo_id
            AND NOT EXISTS (
                SELECT
                    *
                FROM
                    clase_codigo
                WHERE
                        id_cia = pin_id_cia
                    AND tipinv = cc.tipinv
                    AND clase = cc.clase
                    AND codigo = cc.codigo
            );
-- CLASE_DOCUMENTOS_CAB 
    INSERT INTO clase_documentos_cab (
        id_cia,
        tipdoc,
        clase,
        descri,
        vreal,
        vstrg,
        vchar,
        vdate,
        vtime,
        ventero,
        vblob,
        swacti,
        codusercrea,
        coduseractu,
        fcreac,
        factua,
        obliga,
        editable,
        swcodigo
    )
        SELECT
            pin_id_cia,
            tipdoc,
            clase,
            descri,
            vreal,
            vstrg,
            vchar,
            vdate,
            vtime,
            ventero,
            vblob,
            swacti,
            codusercrea,
            coduseractu,
            fcreac,
            factua,
            obliga,
            editable,
            swcodigo
        FROM
            clase_documentos_cab
        WHERE
            id_cia = empresa_modelo_id;

-- CLASE_DOCUMENTOS_CAB_CODIGO 
    INSERT INTO clase_documentos_cab_codigo (
        id_cia,
        tipdoc,
        clase,
        codigo,
        descri,
        abrevi,
        swacti,
        codusercrea,
        coduseractu,
        fcreac,
        factua
    )
        SELECT
            pin_id_cia,
            tipdoc,
            clase,
            codigo,
            descri,
            abrevi,
            swacti,
            codusercrea,
            coduseractu,
            fcreac,
            factua
        FROM
            clase_documentos_cab_codigo
        WHERE
            id_cia = empresa_modelo_id;

-- CLASE_DOCUMENTOS_DET 
    INSERT INTO clase_documentos_det (
        id_cia,
        tipdoc,
        clase,
        descri,
        vreal,
        vstrg,
        vchar,
        vdate,
        vtime,
        ventero,
        obliga,
        swacti,
        codusercrea,
        coduseractu,
        fcreac,
        factua,
        swcodigo
    )
        SELECT
            pin_id_cia,
            tipdoc,
            clase,
            descri,
            vreal,
            vstrg,
            vchar,
            vdate,
            vtime,
            ventero,
            obliga,
            swacti,
            codusercrea,
            coduseractu,
            fcreac,
            factua,
            swcodigo
        FROM
            clase_documentos_det
        WHERE
            id_cia = empresa_modelo_id;

-- CLASE_DOCUMENTOS_DET_CODIGO 
    INSERT INTO clase_documentos_det_codigo (
        id_cia,
        tipdoc,
        clase,
        codigo,
        descri,
        abrevi,
        swacti,
        codusercrea,
        coduseractu,
        fcreac,
        factua,
        swdefaul
    )
        SELECT
            pin_id_cia,
            tipdoc,
            clase,
            codigo,
            descri,
            abrevi,
            swacti,
            codusercrea,
            coduseractu,
            fcreac,
            factua,
            swdefaul
        FROM
            clase_documentos_det_codigo
        WHERE
            id_cia = empresa_modelo_id;

-- CLASE_DOCUMENTOS_TIPO 
    INSERT INTO clase_documentos_tipo (
        id_cia,
        clase,
        descri,
        vreal,
        vstrg,
        vchar,
        vdate,
        vtime,
        ventero,
        swcodigo,
        swacti,
        ucreac,
        uactua,
        fcreac,
        factua
    )
        SELECT
            pin_id_cia,
            clase,
            descri,
            vreal,
            vstrg,
            vchar,
            vdate,
            vtime,
            ventero,
            swcodigo,
            swacti,
            ucreac,
            uactua,
            fcreac,
            factua
        FROM
            clase_documentos_tipo
        WHERE
            id_cia = empresa_modelo_id;

-- CLASE_DOCUMENTOS_TIPO_CODIGO 
    INSERT INTO clase_documentos_tipo_codigo (
        id_cia,
        clase,
        codigo,
        descri,
        abrevi,
        swacti,
        ucreac,
        uactua,
        fcreac,
        factua
    )
        SELECT
            pin_id_cia,
            clase,
            codigo,
            descri,
            abrevi,
            swacti,
            ucreac,
            uactua,
            fcreac,
            factua
        FROM
            clase_documentos_tipo_codigo
        WHERE
            id_cia = empresa_modelo_id;

-- CLASE_E_FINANCIERA 
    INSERT INTO clase_e_financiera (
        id_cia,
        clase,
        descri,
        vreal,
        vstrg,
        vchar,
        vdate,
        vtime,
        ventero,
        vblob,
        swacti,
        usuari,
        codusercrea,
        coduseractu,
        fcreac,
        factua
    )
        SELECT
            pin_id_cia,
            clase,
            descri,
            vreal,
            vstrg,
            vchar,
            vdate,
            vtime,
            ventero,
            vblob,
            swacti,
            usuari,
            codusercrea,
            coduseractu,
            fcreac,
            factua
        FROM
            clase_e_financiera
        WHERE
            id_cia = empresa_modelo_id;

-- CLASE_E_FINANCIERA_CODIGO 
    INSERT INTO clase_e_financiera_codigo (
        id_cia,
        clase,
        codigo,
        descri,
        abrevi,
        situac,
        usuari,
        codusercrea,
        coduseractu,
        fcreac,
        factua,
        swdefaul
    )
        SELECT
            pin_id_cia,
            clase,
            codigo,
            descri,
            abrevi,
            situac,
            usuari,
            codusercrea,
            coduseractu,
            fcreac,
            factua,
            swdefaul
        FROM
            clase_e_financiera_codigo
        WHERE
            id_cia = empresa_modelo_id;
-- CLASE_EVENTOS 
    INSERT INTO clase_eventos (
        id_cia,
        clase,
        descri,
        vreal,
        vstrg,
        vchar,
        vdate,
        vtime,
        ventero,
        vcolor,
        swacti,
        codusercrea,
        coduseractu,
        fcreac,
        factua
    )
        SELECT
            pin_id_cia,
            clase,
            descri,
            vreal,
            vstrg,
            vchar,
            vdate,
            vtime,
            ventero,
            vcolor,
            swacti,
            codusercrea,
            coduseractu,
            fcreac,
            factua
        FROM
            clase_eventos
        WHERE
            id_cia = empresa_modelo_id;

-- CLASE_EVENTOS_CODIGO 
    INSERT INTO clase_eventos_codigo (
        id_cia,
        clase,
        codigo,
        descri,
        abrevi,
        situac,
        fcreac,
        factua,
        usuari,
        swdefaul
    )
        SELECT
            pin_id_cia,
            clase,
            codigo,
            descri,
            abrevi,
            situac,
            fcreac,
            factua,
            usuari,
            swdefaul
        FROM
            clase_eventos_codigo
        WHERE
            id_cia = empresa_modelo_id;

-- CLASE_GLOBAL 
    INSERT INTO clase_global (
        id_cia,
        clase,
        descri,
        secuen,
        longit,
        autogenera,
        obliga,
        situac,
        fcreac,
        factua,
        usuari,
        swcorr,
        correl
    )
        SELECT
            pin_id_cia,
            clase,
            descri,
            secuen,
            longit,
            autogenera,
            obliga,
            situac,
            fcreac,
            factua,
            usuari,
            swcorr,
            correl
        FROM
            clase_global
        WHERE
            id_cia = empresa_modelo_id;

-- CLASE_GLOBAL_CODIGO 
    INSERT INTO clase_global_codigo (
        id_cia,
        clase,
        codigo,
        descri,
        abrevi,
        situac,
        fcreac,
        factua,
        usuari,
        swdefaul
    )
        SELECT
            pin_id_cia,
            clase,
            codigo,
            descri,
            abrevi,
            situac,
            fcreac,
            factua,
            usuari,
            swdefaul
        FROM
            clase_global_codigo
        WHERE
            id_cia = empresa_modelo_id;

-- CLASE_NOTICIAS 
    INSERT INTO clase_noticias (
        id_cia,
        clase,
        descri,
        vreal,
        vstrg,
        vchar,
        vdate,
        vtime,
        ventero,
        vcolor,
        swacti,
        codusercrea,
        coduseractu,
        fcreac,
        factua
    )
        SELECT
            pin_id_cia,
            clase,
            descri,
            vreal,
            vstrg,
            vchar,
            vdate,
            vtime,
            ventero,
            vcolor,
            swacti,
            codusercrea,
            coduseractu,
            fcreac,
            factua
        FROM
            clase_noticias
        WHERE
            id_cia = empresa_modelo_id;

-- CLASE_NOTICIAS_CODIGO 
    INSERT INTO clase_noticias_codigo (
        id_cia,
        clase,
        codigo,
        descri,
        abrevi,
        situac,
        fcreac,
        factua,
        usuari,
        swdefaul
    )
        SELECT
            pin_id_cia,
            clase,
            codigo,
            descri,
            abrevi,
            situac,
            fcreac,
            factua,
            usuari,
            swdefaul
        FROM
            clase_noticias_codigo
        WHERE
            id_cia = empresa_modelo_id;

-- TANALITICA 
    INSERT INTO tanalitica (
        id_cia,
        codtana,
        descri,
        usuari,
        fcreac,
        factua,
        swacti,
        moneda
    )
        SELECT
            pin_id_cia,
            codtana,
            descri,
            usuari,
            fcreac,
            factua,
            swacti,
            moneda
        FROM
            tanalitica
        WHERE
            id_cia = empresa_modelo_id;

-- CLASE_PCUENTAS 

    IF v_inc_pcuentas = 'S' THEN
        INSERT INTO clase_pcuentas (
            id_cia,
            clase,
            descri,
            vreal,
            vstrg,
            vchar,
            vdate,
            vtime,
            ventero,
            obliga,
            swacti,
            fcreac,
            factua,
            usuari
        )
            SELECT
                pin_id_cia,
                clase,
                descri,
                vreal,
                vstrg,
                vchar,
                vdate,
                vtime,
                ventero,
                obliga,
                swacti,
                fcreac,
                factua,
                usuari
            FROM
                clase_pcuentas
            WHERE
                id_cia = empresa_modelo_id;

        -- CLASE_PCUENTAS_ALTERNATIVO 
        INSERT INTO clase_pcuentas_alternativo (
            id_cia,
            clase,
            descri,
            vreal,
            vstrg,
            vchar,
            vdate,
            vtime,
            ventero,
            swacti,
            obliga,
            codusercrea,
            coduseractu,
            fcreac,
            factua
        )
            SELECT
                pin_id_cia,
                clase,
                descri,
                vreal,
                vstrg,
                vchar,
                vdate,
                vtime,
                ventero,
                swacti,
                obliga,
                codusercrea,
                coduseractu,
                fcreac,
                factua
            FROM
                clase_pcuentas_alternativo
            WHERE
                id_cia = empresa_modelo_id;

        -- CLASE_PCUENTAS_CODIGO 
        INSERT INTO clase_pcuentas_codigo (
            id_cia,
            clase,
            codigo,
            descri,
            abrevi,
            swacti,
            codusercrea,
            coduseractu,
            fcreac,
            factua
        )
            SELECT
                pin_id_cia,
                clase,
                codigo,
                descri,
                abrevi,
                swacti,
                codusercrea,
                coduseractu,
                fcreac,
                factua
            FROM
                clase_pcuentas_codigo
            WHERE
                id_cia = empresa_modelo_id;

        -- PCUENTAS 
        INSERT INTO pcuentas (
            id_cia,
            cuenta,
            nombre,
            tipgas,
            cpadre,
            nivel,
            imputa,
            codtana,
            destino,
            destid,
            destih,
            dh,
            moneda01,
            moneda02,
            ccosto,
            proyec,
            docori,
            tipo,
            refere,
            fhabdes,
            fhabhas,
            balance,
            regcomcol,
            regvencol,
            clasif,
            situac,
            usuari,
            fcreac,
            factua,
            balancecol,
            habilitado,
            concilia,
            tcuenta
        )
            SELECT
                pin_id_cia,
                cuenta,
                nombre,
                tipgas,
                cpadre,
                nivel,
                imputa,
                codtana,
                destino,
                destid,
                destih,
                dh,
                moneda01,
                moneda02,
                ccosto,
                proyec,
                docori,
                tipo,
                refere,
                fhabdes,
                fhabhas,
                balance,
                regcomcol,
                regvencol,
                clasif,
                situac,
                usuari,
                fcreac,
                factua,
                balancecol,
                habilitado,
                concilia,
                tcuenta
            FROM
                pcuentas
            WHERE
                id_cia = empresa_modelo_id;

        -- PCUENTAS_CLASE 
        INSERT INTO pcuentas_clase (
            id_cia,
            cuenta,
            clase,
            codigo,
            swflag,
            vreal,
            vstrg,
            vchar,
            vdate,
            vtime,
            ventero,
            codusercrea,
            coduseractu,
            fcreac,
            factua,
            nombre,
            vstring
        )
            SELECT
                pin_id_cia,
                cuenta,
                clase,
                codigo,
                swflag,
                vreal,
                vstrg,
                vchar,
                vdate,
                vtime,
                ventero,
                codusercrea,
                coduseractu,
                fcreac,
                factua,
                nombre,
                vstring
            FROM
                pcuentas_clase
            WHERE
                    id_cia = empresa_modelo_id
                AND clase <> 11;

        -- PCUENTAS_CLASE_ALTERNATIVO 
        INSERT INTO pcuentas_clase_alternativo (
            id_cia,
            cuenta,
            clase,
            codigo,
            descodigo,
            vreal,
            vstrg,
            vchar,
            vdate,
            vtime,
            ventero,
            codusercrea,
            coduseractu,
            fcreac,
            factua,
            orden
        )
            SELECT
                pin_id_cia,
                cuenta,
                clase,
                codigo,
                descodigo,
                vreal,
                vstrg,
                vchar,
                vdate,
                vtime,
                ventero,
                codusercrea,
                coduseractu,
                fcreac,
                factua,
                orden
            FROM
                pcuentas_clase_alternativo
            WHERE
                id_cia = empresa_modelo_id;

        -- TCCOSTOS 
        INSERT INTO tccostos (
            id_cia,
            codigo,
            descri,
            succcosto,
            destino,
            destin,
            usuari,
            fcreac,
            factua,
            swacti
        )
            SELECT
                pin_id_cia,
                codigo,
                descri,
                succcosto,
                destino,
                destin,
                usuari,
                fcreac,
                factua,
                swacti
            FROM
                tccostos
            WHERE
                id_cia = empresa_modelo_id;
        --- end tccostos 

        -- PCUENTASTCCOSTOS 
        INSERT INTO pcuentastccostos (
            id_cia,
            cuenta,
            ccosto,
            porcentaje
        )
            SELECT
                pin_id_cia,
                cuenta,
                ccosto,
                porcentaje
            FROM
                pcuentastccostos
            WHERE
                id_cia = empresa_modelo_id;

    END IF;


    -- CLASE_TDOCCOBRANZA 
    INSERT INTO clase_tdoccobranza (
        id_cia,
        tipdoc,
        clase,
        descri,
        vreal,
        vstrg,
        vchar,
        vdate,
        vtime,
        ventero,
        swacti,
        codusercrea,
        coduseractu,
        fcreac,
        factua
    )
        SELECT
            pin_id_cia,
            tipdoc,
            clase,
            descri,
            vreal,
            vstrg,
            vchar,
            vdate,
            vtime,
            ventero,
            swacti,
            codusercrea,
            coduseractu,
            fcreac,
            factua
        FROM
            clase_tdoccobranza
        WHERE
            id_cia = empresa_modelo_id;

-- CLASE_TDOCCOBRANZA_CODIGO 
    INSERT INTO clase_tdoccobranza_codigo (
        id_cia,
        tipdoc,
        clase,
        codigo,
        descri,
        abrevi,
        swacti,
        codusercrea,
        coduseractu,
        fcreac,
        factua
    )
        SELECT
            pin_id_cia,
            tipdoc,
            clase,
            codigo,
            descri,
            abrevi,
            swacti,
            codusercrea,
            coduseractu,
            fcreac,
            factua
        FROM
            clase_tdoccobranza_codigo
        WHERE
            id_cia = empresa_modelo_id;

-- CLASE_VENDEDOR 
    INSERT INTO clase_vendedor (
        id_cia,
        clase,
        descri,
        vreal,
        vstrg,
        vchar,
        vdate,
        vtime,
        ventero,
        swacti,
        codusercrea,
        coduseractu,
        fcreac,
        factua
    )
        SELECT
            pin_id_cia,
            clase,
            descri,
            vreal,
            vstrg,
            vchar,
            vdate,
            vtime,
            ventero,
            swacti,
            codusercrea,
            coduseractu,
            fcreac,
            factua
        FROM
            clase_vendedor
        WHERE
            id_cia = empresa_modelo_id;

-- CLASE_VENDEDOR_CODIGO 
    INSERT INTO clase_vendedor_codigo (
        id_cia,
        clase,
        codigo,
        descri,
        abrevi,
        swacti,
        codusercrea,
        coduseractu,
        fcreac,
        factua
    )
        SELECT
            pin_id_cia,
            clase,
            codigo,
            descri,
            abrevi,
            swacti,
            codusercrea,
            coduseractu,
            fcreac,
            factua
        FROM
            clase_vendedor_codigo
        WHERE
            id_cia = empresa_modelo_id;

-- CLASES_TDOCUME 
    INSERT INTO clases_tdocume (
        id_cia,
        clase,
        descri,
        vreal,
        vstrg,
        vchar,
        vdate,
        vtime,
        ventero,
        swacti,
        codusercrea,
        coduseractu,
        fcreac,
        factua
    )
        SELECT
            pin_id_cia,
            clase,
            descri,
            vreal,
            vstrg,
            vchar,
            vdate,
            vtime,
            ventero,
            swacti,
            codusercrea,
            coduseractu,
            fcreac,
            factua
        FROM
            clases_tdocume
        WHERE
            id_cia = empresa_modelo_id;

-- CLASES_TDOCUME_CODIGO 
    INSERT INTO clases_tdocume_codigo (
        id_cia,
        tipdoc,
        clase,
        codigo,
        descri,
        abrevi,
        swacti,
        codusercrea,
        coduseractu,
        fcreac,
        factua
    )
        SELECT
            pin_id_cia,
            tipdoc,
            clase,
            codigo,
            descri,
            abrevi,
            swacti,
            codusercrea,
            coduseractu,
            fcreac,
            factua
        FROM
            clases_tdocume_codigo
        WHERE
            id_cia = empresa_modelo_id;

-- CLASES_TITULOLISTA 
    INSERT INTO clases_titulolista (
        id_cia,
        clase,
        descri,
        vreal,
        vstrg,
        vchar,
        vdate,
        vtime,
        ventero,
        swacti,
        codusercrea,
        coduseractu,
        fcreac,
        factua
    )
        SELECT
            pin_id_cia,
            clase,
            descri,
            vreal,
            vstrg,
            vchar,
            vdate,
            vtime,
            ventero,
            swacti,
            codusercrea,
            coduseractu,
            fcreac,
            factua
        FROM
            clases_titulolista
        WHERE
            id_cia = empresa_modelo_id;

-- CLASES_TITULOLISTA_CODIGO 
    INSERT INTO clases_titulolista_codigo (
        id_cia,
        codtit,
        clase,
        codigo,
        descri,
        abrevi,
        swacti,
        codusercrea,
        coduseractu,
        fcreac,
        factua
    )
        SELECT
            pin_id_cia,
            codtit,
            clase,
            codigo,
            descri,
            abrevi,
            swacti,
            codusercrea,
            coduseractu,
            fcreac,
            factua
        FROM
            clases_titulolista_codigo
        WHERE
            id_cia = empresa_modelo_id;

-- DOCUMENTOS_CLASE_AYUDA 
    INSERT INTO documentos_clase_ayuda (
        id_cia,
        clase,
        descri,
        observ
    )
        SELECT
            pin_id_cia,
            clase,
            descri,
            observ
        FROM
            documentos_clase_ayuda
        WHERE
            id_cia = empresa_modelo_id;

-- DOCUMENTOS_TIPO 
    INSERT INTO documentos_tipo (
        id_cia,
        tipdoc,
        descri,
        abrevi,
        codigosunat,
        libro,
        cnfxml,
        dtolera
    )
        SELECT
            pin_id_cia,
            tipdoc,
            descri,
            abrevi,
            codigosunat,
            libro,
            cnfxml,
            dtolera
        FROM
            documentos_tipo
        WHERE
            id_cia = empresa_modelo_id;

-- E_FINANCIERA 
    INSERT INTO e_financiera (
        id_cia,
        codigo,
        descri,
        situac,
        usuari,
        fcreac,
        factua
    )
        SELECT
            pin_id_cia,
            codigo,
            descri,
            situac,
            usuari,
            fcreac,
            factua
        FROM
            e_financiera
        WHERE
            id_cia = empresa_modelo_id;

-- E_FINANCIERA_CLASE 
    INSERT INTO e_financiera_clase (
        id_cia,
        financiera,
        clase,
        codigo,
        vreal,
        vstrg,
        vchar,
        vdate,
        vtime,
        ventero,
        vblob,
        usuari,
        codusercrea,
        coduseractu,
        fcreac,
        factua
    )
        SELECT
            pin_id_cia,
            financiera,
            clase,
            codigo,
            vreal,
            vstrg,
            vchar,
            vdate,
            vtime,
            ventero,
            vblob,
            usuari,
            codusercrea,
            coduseractu,
            fcreac,
            factua
        FROM
            e_financiera_clase
        WHERE
            id_cia = empresa_modelo_id;

-- E_FINANCIERA_TIPO 
    INSERT INTO e_financiera_tipo (
        id_cia,
        tipcta,
        descri
    )
        SELECT
            pin_id_cia,
            tipcta,
            descri
        FROM
            e_financiera_tipo
        WHERE
            id_cia = empresa_modelo_id;

-- ESPECIFICACIONES 
    INSERT INTO especificaciones (
        id_cia,
        tipinv,
        codesp,
        descri,
        vreal,
        vstrg,
        vchar,
        vdate,
        vtime,
        ventero,
        fcreac,
        factua,
        usuari,
        swacti,
        swreque
    )
        SELECT
            pin_id_cia,
            tipinv,
            codesp,
            descri,
            vreal,
            vstrg,
            vchar,
            vdate,
            vtime,
            ventero,
            fcreac,
            factua,
            usuari,
            swacti,
            swreque
        FROM
            especificaciones
        WHERE
            id_cia = empresa_modelo_id;

-- ESPECIFICACIONES_CERTIFICADOS 
    INSERT INTO especificaciones_certificados (
        id_cia,
        tipdoc,
        series,
        codesp,
        descri,
        vreal,
        vstrg,
        vchar,
        vdate,
        vtime,
        ventero,
        fcreac,
        factua,
        coduser,
        swacti,
        swreque
    )
        SELECT
            pin_id_cia,
            tipdoc,
            series,
            codesp,
            descri,
            vreal,
            vstrg,
            vchar,
            vdate,
            vtime,
            ventero,
            fcreac,
            factua,
            coduser,
            swacti,
            swreque
        FROM
            especificaciones_certificados
        WHERE
            id_cia = empresa_modelo_id;

-- ESPECIFICACIONES_CLIENTES 
    INSERT INTO especificaciones_clientes (
        id_cia,
        tipcli,
        codesp,
        descri,
        vreal,
        vstrg,
        vchar,
        vdate,
        vtime,
        ventero,
        swacti,
        swreque,
        usuari,
        fcreac,
        factua
    )
        SELECT
            pin_id_cia,
            tipcli,
            codesp,
            descri,
            vreal,
            vstrg,
            vchar,
            vdate,
            vtime,
            ventero,
            swacti,
            swreque,
            usuari,
            fcreac,
            factua
        FROM
            especificaciones_clientes
        WHERE
            id_cia = empresa_modelo_id;

-- ESTADO_CIVIL 
    INSERT INTO estado_civil (
        id_cia,
        codeci,
        deseci,
        fcreac,
        factua,
        ucreac,
        uactua,
        swacti
    )
        SELECT
            pin_id_cia,
            codeci,
            deseci,
            fcreac,
            factua,
            ucreac,
            uactua,
            swacti
        FROM
            estado_civil
        WHERE
            id_cia = empresa_modelo_id;

-- ESTADO_ENVIO_SUNAT 
    INSERT INTO estado_envio_sunat (
        id_cia,
        codest,
        descri
    )
        SELECT
            pin_id_cia,
            codest,
            descri
        FROM
            estado_envio_sunat
        WHERE
            id_cia = empresa_modelo_id;

        -- FACTOR 

    INSERT INTO factor (
        id_cia,
        codfac,
        nomfac,
        tfactor,
        vreal,
        vstrg,
        vdate,
        vtime,
        ventero,
        cuenta,
        situac,
        fcreac,
        usuari,
        factua,
        swacti,
        observ
    )
        SELECT
            pin_id_cia,
            f.codfac,
            f.nomfac,
            f.tfactor,
            f.vreal,
            f.vstrg,
            f.vdate,
            f.vtime,
            f.ventero,
            f.cuenta,
            f.situac,
            f.fcreac,
            f.usuari,
            f.factua,
            f.swacti,
            f.observ
        FROM
            factor f
        WHERE
                f.id_cia = empresa_modelo_id
            AND NOT EXISTS (
                SELECT
                    *
                FROM
                    factor
                WHERE
                        id_cia = pin_id_cia
                    AND codfac = f.codfac
            );
-- FIDELIDAD 
    INSERT INTO fidelidad (
        id_cia,
        codfid,
        desfid,
        fcreac,
        factua,
        usuari,
        swacti
    )
        SELECT
            pin_id_cia,
            codfid,
            desfid,
            fcreac,
            factua,
            usuari,
            swacti
        FROM
            fidelidad
        WHERE
            id_cia = empresa_modelo_id;


-- GANAPERDIHEA 
    INSERT INTO ganaperdihea (
        id_cia,
        codigo,
        tipo,
        titulo,
        signo
    )
        SELECT
            pin_id_cia,
            codigo,
            tipo,
            titulo,
            signo
        FROM
            ganaperdihea
        WHERE
            id_cia = empresa_modelo_id;

-- GANAPERDIDET 
    INSERT INTO ganaperdidet (
        id_cia,
        codigo,
        cuenta
    )
        SELECT
            pin_id_cia,
            codigo,
            cuenta
        FROM
            ganaperdidet
        WHERE
            id_cia = empresa_modelo_id;

-- GRUPOS 
    INSERT INTO grupos (
        id_cia,
        codgru,
        nombre,
        direccion,
        fcreac,
        factua,
        usuari,
        swacti,
        codsunat
    )
        SELECT
            pin_id_cia,
            codgru,
            nombre,
            direccion,
            fcreac,
            factua,
            usuari,
            swacti,
            codsunat
        FROM
            grupos
        WHERE
            id_cia = empresa_modelo_id;

-- GRUPOS_ALMACEN 
    INSERT INTO grupos_almacen (
        id_cia,
        codgru,
        tipinv,
        almacenes,
        fcreac,
        factua,
        usuari,
        swacti
    )
        SELECT
            pin_id_cia,
            codgru,
            tipinv,
            almacenes,
            fcreac,
            factua,
            usuari,
            swacti
        FROM
            grupos_almacen
        WHERE
            id_cia = empresa_modelo_id;

-- GRUPOS_ARTICULOS_COSTO 
    INSERT INTO grupos_articulos_costo (
        id_cia,
        codgru,
        tipinv,
        codart,
        periodo,
        costo01,
        costo02,
        cantid
    )
        SELECT
            pin_id_cia,
            codgru,
            tipinv,
            codart,
            periodo,
            costo01,
            costo02,
            cantid
        FROM
            grupos_articulos_costo
        WHERE
            id_cia = empresa_modelo_id;

-- IDENTIDAD 
    INSERT INTO identidad (
        id_cia,
        tident,
        descri,
        abrevi,
        tamano,
        tpersona,
        situac,
        codsunat,
        fcreac,
        factua,
        usuari
    )
        SELECT
            pin_id_cia,
            tident,
            descri,
            abrevi,
            tamano,
            tpersona,
            situac,
            codsunat,
            fcreac,
            factua,
            usuari
        FROM
            identidad
        WHERE
            id_cia = empresa_modelo_id;

-- IMPORTSI 
-- INSERT INTO IMPORTSI (ID_CIA,NUMINT,DESCRI,NTABLA,SWVISIBLE,CNFXML,OBSERV,CLAVE) 
-- SELECT pin_id_cia,NUMINT,DESCRI,NTABLA,SWVISIBLE,CNFXML,OBSERV,CLAVE
-- FROM IMPORTSI WHERE ID_CIA = empresa_modelo_ID;


-- LUGAR_EMISION 
    INSERT INTO lugar_emision (
        id_cia,
        codemi,
        descri,
        fcreac,
        factua,
        usuari,
        swacti
    )
        SELECT
            pin_id_cia,
            codemi,
            descri,
            fcreac,
            factua,
            usuari,
            swacti
        FROM
            lugar_emision
        WHERE
            id_cia = empresa_modelo_id;

-- M_DESTINO 
    INSERT INTO m_destino (
        id_cia,
        codigo,
        descri,
        situac,
        usuari,
        fcreac,
        factua
    )
        SELECT
            pin_id_cia,
            codigo,
            descri,
            situac,
            usuari,
            fcreac,
            factua
        FROM
            m_destino
        WHERE
            id_cia = empresa_modelo_id;

-- M_PAGO 
    INSERT INTO m_pago (
        id_cia,
        codigo,
        descri,
        abrevi,
        situac,
        tipmon,
        usuari,
        fcreac,
        factua,
        dh,
        libro,
        dh2,
        filtro,
        signo
    )
        SELECT
            pin_id_cia,
            codigo,
            descri,
            abrevi,
            situac,
            tipmon,
            usuari,
            fcreac,
            factua,
            dh,
            libro,
            dh2,
            filtro,
            signo
        FROM
            m_pago
        WHERE
            id_cia = empresa_modelo_id;

-- M_PAGO_CLASE 
    INSERT INTO m_pago_clase (
        id_cia,
        codmpago,
        clase,
        codigo,
        vreal,
        vstrg,
        vchar,
        vdate,
        vtime,
        ventero,
        codusercrea,
        coduseractu,
        fcreac,
        factua
    )
        SELECT
            pin_id_cia,
            codmpago,
            clase,
            codigo,
            vreal,
            vstrg,
            vchar,
            vdate,
            vtime,
            ventero,
            codusercrea,
            coduseractu,
            fcreac,
            factua
        FROM
            m_pago_clase
        WHERE
            id_cia = empresa_modelo_id;

-- M_PAGO_CONFIG 
    INSERT INTO m_pago_config (
        id_cia,
        codigo,
        codsuc,
        moneda,
        codban
    )
        SELECT
            pin_id_cia,
            codigo,
            codsuc,
            moneda,
            codban
        FROM
            m_pago_config
        WHERE
            id_cia = empresa_modelo_id;

-- MESES 
    INSERT INTO meses (
        id_cia,
        nromes,
        desmay,
        desmin,
        abrmay,
        abrmin
    )
        SELECT
            pin_id_cia,
            nromes,
            desmay,
            desmin,
            abrmay,
            abrmin
        FROM
            meses
        WHERE
            id_cia = empresa_modelo_id;

-- MOTIVOS 
    INSERT INTO motivos (
        id_cia,
        tipdoc,
        id,
        codmot,
        desmot,
        abrevi,
        costea,
        cospro,
        gening,
        gensal,
        reqpre,
        fcreac,
        factua,
        usuari,
        swacti,
        tipcli,
        docayuda,
        filtrodocu,
        observ
    )
        SELECT
            pin_id_cia,
            tipdoc,
            id,
            codmot,
            desmot,
            abrevi,
            costea,
            cospro,
            gening,
            gensal,
            reqpre,
            fcreac,
            factua,
            usuari,
            swacti,
            tipcli,
            docayuda,
            filtrodocu,
            observ
        FROM
            motivos
        WHERE
            id_cia = empresa_modelo_id;

-- MOTIVOS_CLASE 
    INSERT INTO motivos_clase (
        id_cia,
        tipdoc,
        id,
        codmot,
        codigo,
        descri,
        valor
    )
        SELECT
            pin_id_cia,
            tipdoc,
            id,
            codmot,
            codigo,
            descri,
            valor
        FROM
            motivos_clase
        WHERE
            id_cia = empresa_modelo_id;

-- MOTIVOS_CUENTAS 
    INSERT INTO motivos_cuentas (
        id_cia,
        tipdoc,
        id,
        codmot,
        tipinv,
        codfam,
        cuenta,
        fcreac,
        factua,
        usuari
    )
        SELECT
            pin_id_cia,
            tipdoc,
            id,
            codmot,
            tipinv,
            codfam,
            cuenta,
            fcreac,
            factua,
            usuari
        FROM
            motivos_cuentas
        WHERE
            id_cia = empresa_modelo_id;




-- PERMISOS 
    INSERT INTO permisos (
        id_cia,
        codmod,
        codacc,
        coduser,
        situac
    )
        SELECT
            pin_id_cia,
            codmod,
            codacc,
            coduser,
            situac
        FROM
            permisos
        WHERE
                id_cia = empresa_modelo_id
            AND ( v_user_admin IS NULL
                  OR coduser = v_user_admin );

-- REGIMEN_RETENCIONES 
    INSERT INTO regimen_retenciones (
        id_cia,
        codigo,
        descri,
        afecto,
        fcreac,
        factua,
        usuari,
        swacti
    )
        SELECT
            pin_id_cia,
            codigo,
            descri,
            afecto,
            fcreac,
            factua,
            usuari,
            swacti
        FROM
            regimen_retenciones
        WHERE
            id_cia = empresa_modelo_id;

-- REGIMEN_RETENCIONES_VIGENCIA 
    INSERT INTO regimen_retenciones_vigencia (
        id_cia,
        codigo,
        finicio,
        tope,
        tasa
    )
        SELECT
            pin_id_cia,
            codigo,
            finicio,
            tope,
            tasa
        FROM
            regimen_retenciones_vigencia
        WHERE
            id_cia = empresa_modelo_id;

-- SITUACION 
    INSERT INTO situacion (
        id_cia,
        tipdoc,
        situac,
        dessit,
        permis,
        alias,
        swacti,
        usuari,
        fcreac,
        factua
    )
        SELECT
            pin_id_cia,
            tipdoc,
            situac,
            dessit,
            permis,
            alias,
            swacti,
            usuari,
            fcreac,
            factua
        FROM
            situacion
        WHERE
            id_cia = empresa_modelo_id;

-- SUCURSAL 
    INSERT INTO sucursal (
        id_cia,
        codsuc,
        sucursal,
        nomdis,
        direcc,
        telef,
        fax,
        logoc,
        logod,
        formcab,
        formdet,
        formato,
        horent,
        fcreac,
        factua,
        usuari,
        swacti,
        series,
        almacenes,
        plaza,
        presen,
        formpre,
        ubigeo,
        logoticket,
        formticket
    )
        SELECT
            pin_id_cia,
            codsuc,
            sucursal,
            nomdis,
            direcc,
            telef,
            fax,
            logoc,
            logod,
            formcab,
            formdet,
            formato,
            horent,
            fcreac,
            factua,
            usuari,
            swacti,
            series,
            almacenes,
            plaza,
            presen,
            formpre,
            ubigeo,
            logoticket,
            formticket
        FROM
            sucursal
        WHERE
                id_cia = empresa_modelo_id
            AND codsuc = 1;


-- SUCURSAL_CLASES 
    INSERT INTO sucursal_clases (
        id_cia,
        codsuc,
        clase,
        codigo,
        vreal,
        vstrg,
        vdate,
        vtime,
        ventero,
        cuenta,
        situac,
        fcreac,
        usuari,
        factua,
        swacti
    )
        SELECT
            pin_id_cia,
            codsuc,
            clase,
            codigo,
            vreal,
            vstrg,
            vdate,
            vtime,
            ventero,
            cuenta,
            situac,
            fcreac,
            usuari,
            factua,
            swacti
        FROM
            sucursal_clases
        WHERE
            id_cia = empresa_modelo_id;

-- T_INVENTARIO 
    INSERT INTO t_inventario (
        id_cia,
        tipinv,
        dtipinv,
        abrevi,
        codsunat,
        fcreac,
        factua,
        usuari,
        swacti,
        cuenta,
        patron
    )
        SELECT
            pin_id_cia,
            tipinv,
            dtipinv,
            abrevi,
            codsunat,
            fcreac,
            factua,
            usuari,
            swacti,
            cuenta,
            patron
        FROM
            t_inventario
        WHERE
            id_cia = empresa_modelo_id;

-- T_INVENTARIO_CLASE 
    INSERT INTO t_inventario_clase (
        id_cia,
        tipinv,
        clase,
        codigo,
        vreal,
        vstrg,
        vchar,
        vdate,
        vtime,
        ventero,
        codusercrea,
        coduseractu,
        fcreac,
        factua
    )
        SELECT
            pin_id_cia,
            tipinv,
            clase,
            codigo,
            vreal,
            vstrg,
            vchar,
            vdate,
            vtime,
            ventero,
            codusercrea,
            coduseractu,
            fcreac,
            factua
        FROM
            t_inventario_clase
        WHERE
            id_cia = empresa_modelo_id;

-- T_INVENTARIOSUNAT 
    INSERT INTO t_inventariosunat (
        id_cia,
        codsunat,
        nombre,
        abrevi,
        fcreac,
        factua,
        usuari,
        swacti
    )
        SELECT
            pin_id_cia,
            codsunat,
            nombre,
            abrevi,
            fcreac,
            factua,
            usuari,
            swacti
        FROM
            t_inventariosunat
        WHERE
            id_cia = empresa_modelo_id;

-- T_NEGOCIO 
    INSERT INTO t_negocio (
        id_cia,
        codtne,
        destne,
        fcreac,
        factua,
        usuari,
        swacti
    )
        SELECT
            pin_id_cia,
            codtne,
            destne,
            fcreac,
            factua,
            usuari,
            swacti
        FROM
            t_negocio
        WHERE
            id_cia = empresa_modelo_id;

-- T_PERSONA 
    INSERT INTO t_persona (
        id_cia,
        codtpe,
        destpe,
        fcreac,
        factua,
        usuari,
        swacti
    )
        SELECT
            pin_id_cia,
            codtpe,
            destpe,
            fcreac,
            factua,
            usuari,
            swacti
        FROM
            t_persona
        WHERE
            id_cia = empresa_modelo_id;

-- T_SOCIEDAD 
    INSERT INTO t_sociedad (
        id_cia,
        codtso,
        destso,
        fcreac,
        factua,
        usuari,
        swacti
    )
        SELECT
            pin_id_cia,
            codtso,
            destso,
            fcreac,
            factua,
            usuari,
            swacti
        FROM
            t_sociedad
        WHERE
            id_cia = empresa_modelo_id;



-- TBANCOS 
    INSERT INTO tbancos (
        id_cia,
        codban,
        descri,
        sector,
        moneda,
        direcc,
        clibro,
        cuenta,
        codsunat,
        situac,
        usuari,
        fcreac,
        factua,
        cuentacon,
        cuentaret,
        secuencia,
        cuentacta,
        cuentacar,
        cuentacprot,
        cuentacob,
        cuentades,
        cuentagar,
        cuentaord01,
        cuentaord02,
        cuentaenvios,
        filtro,
        swacti,
        abrevi
    )
        SELECT
            pin_id_cia,
            codban,
            descri,
            sector,
            moneda,
            direcc,
            clibro,
            cuenta,
            codsunat,
            situac,
            usuari,
            fcreac,
            factua,
            cuentacon,
            cuentaret,
            secuencia,
            cuentacta,
            cuentacar,
            cuentacprot,
            cuentacob,
            cuentades,
            cuentagar,
            cuentaord01,
            cuentaord02,
            cuentaenvios,
            filtro,
            swacti,
            abrevi
        FROM
            tbancos
        WHERE
            id_cia = empresa_modelo_id;

-- TBANCOS_CLASE 
    INSERT INTO tbancos_clase (
        id_cia,
        codban,
        clase,
        codigo,
        vreal,
        vstrg,
        vchar,
        vdate,
        vtime,
        ventero,
        codusercrea,
        coduseractu,
        fcreac,
        factua
    )
        SELECT
            pin_id_cia,
            codban,
            clase,
            codigo,
            vreal,
            vstrg,
            vchar,
            vdate,
            vtime,
            ventero,
            codusercrea,
            coduseractu,
            fcreac,
            factua
        FROM
            tbancos_clase
        WHERE
            id_cia = empresa_modelo_id;



-- TDOCCOBRANZA 
    INSERT INTO tdoccobranza (
        id_cia,
        tipdoc,
        descri,
        abrevi,
        dh,
        signo,
        situac,
        fcreac,
        factua,
        usuari,
        swacti,
        codsunat
    )
        SELECT
            pin_id_cia,
            tipdoc,
            descri,
            abrevi,
            dh,
            signo,
            situac,
            fcreac,
            factua,
            usuari,
            swacti,
            codsunat
        FROM
            tdoccobranza
        WHERE
            id_cia = empresa_modelo_id;

-- TDOCCOBRANZA_CLASE 
    INSERT INTO tdoccobranza_clase (
        id_cia,
        tipdoc,
        clase,
        moneda,
        codigo,
        vreal,
        vstrg,
        vchar,
        vdate,
        vtime,
        ventero,
        codusercrea,
        coduseractu,
        fcreac,
        factua
    )
        SELECT
            pin_id_cia,
            tipdoc,
            clase,
            moneda,
            codigo,
            vreal,
            vstrg,
            vchar,
            vdate,
            vtime,
            ventero,
            codusercrea,
            coduseractu,
            fcreac,
            factua
        FROM
            tdoccobranza_clase
        WHERE
            id_cia = empresa_modelo_id;

        -- TDOCUME 
    INSERT INTO tdocume (
        id_cia,
        codigo,
        descri,
        abrevi,
        dh,
        factor,
        cdocum,
        clibro,
        rinfadi,
        signo,
        situac,
        usuari,
        fcreac,
        factua,
        salectas,
        ctagascolregcom,
        valor,
        swchkcompr010
    )
        SELECT
            pin_id_cia,
            codigo,
            descri,
            abrevi,
            dh,
            factor,
            cdocum,
            clibro,
            rinfadi,
            signo,
            situac,
            usuari,
            fcreac,
            factua,
            salectas,
            ctagascolregcom,
            valor,
            swchkcompr010
        FROM
            tdocume
        WHERE
            id_cia = empresa_modelo_id;

-- TDOCUME_CAJA 
    INSERT INTO tdocume_caja (
        id_cia,
        tipdoc,
        codsuc,
        moneda,
        cuenta
    )
        SELECT
            pin_id_cia,
            tipdoc,
            codsuc,
            moneda,
            cuenta
        FROM
            tdocume_caja
        WHERE
            id_cia = empresa_modelo_id;

-- TDOCUME_CLASES 
    INSERT INTO tdocume_clases (
        id_cia,
        tipdoc,
        clase,
        moneda,
        codigo,
        vreal,
        vstrg,
        vchar,
        vdate,
        vtime,
        ventero,
        codusercrea,
        coduseractu,
        fcreac,
        factua
    )
        SELECT
            pin_id_cia,
            tipdoc,
            clase,
            moneda,
            codigo,
            vreal,
            vstrg,
            vchar,
            vdate,
            vtime,
            ventero,
            codusercrea,
            coduseractu,
            fcreac,
            factua
        FROM
            tdocume_clases
        WHERE
            id_cia = empresa_modelo_id;

-- TFACTOR 
    INSERT INTO tfactor (
        id_cia,
        tipo,
        codfac,
        nomfac,
        vreal,
        vstrg,
        vdate,
        vtime,
        ventero,
        cuenta,
        dh,
        situac,
        usuari,
        fcreac,
        factua
    )
        SELECT
            pin_id_cia,
            tipo,
            codfac,
            nomfac,
            vreal,
            vstrg,
            vdate,
            vtime,
            ventero,
            cuenta,
            dh,
            situac,
            usuari,
            fcreac,
            factua
        FROM
            tfactor
        WHERE
            id_cia = empresa_modelo_id;

-- TGASTOS 
    INSERT INTO tgastos (
        id_cia,
        codigo,
        descri,
        situac,
        usuari,
        fcreac,
        factua
    )
        SELECT
            pin_id_cia,
            codigo,
            descri,
            situac,
            usuari,
            fcreac,
            factua
        FROM
            tgastos
        WHERE
            id_cia = empresa_modelo_id;

-- TIPO_AFECTACION_IGV 
    INSERT INTO tipo_afectacion_igv (
        id_cia,
        codigo,
        descri,
        codtri
    )
        SELECT
            pin_id_cia,
            codigo,
            descri,
            codtri
        FROM
            tipo_afectacion_igv
        WHERE
            id_cia = empresa_modelo_id;

-- TIPO_CONTROL_STOCK 
    INSERT INTO tipo_control_stock (
        id_cia,
        tipo,
        descripcion,
        observacion,
        swacti
    )
        SELECT
            pin_id_cia,
            tipo,
            descripcion,
            observacion,
            swacti
        FROM
            tipo_control_stock
        WHERE
            id_cia = empresa_modelo_id;

-- TIPO_HORA 
    INSERT INTO tipo_hora (
        id_cia,
        codtho,
        descri,
        factor,
        fcreac,
        factua,
        usuari,
        swacti
    )
        SELECT
            pin_id_cia,
            codtho,
            descri,
            factor,
            fcreac,
            factua,
            usuari,
            swacti
        FROM
            tipo_hora
        WHERE
            id_cia = empresa_modelo_id;

-- TIPO_HORA_TAREO 
    INSERT INTO tipo_hora_tareo (
        id_cia,
        codigo,
        descri,
        factor,
        horlab,
        swacti
    )
        SELECT
            pin_id_cia,
            codigo,
            descri,
            factor,
            horlab,
            swacti
        FROM
            tipo_hora_tareo
        WHERE
            id_cia = empresa_modelo_id;

-- TIPOCLIENTE 
    INSERT INTO tipocliente (
        id_cia,
        tipcli,
        nomtcl,
        fcreac,
        factua,
        usuari,
        swacti
    )
        SELECT
            pin_id_cia,
            tipcli,
            nomtcl,
            fcreac,
            factua,
            usuari,
            swacti
        FROM
            tipocliente
        WHERE
            id_cia = empresa_modelo_id;

-- TIPOTAREA 
    INSERT INTO tipotarea (
        id_cia,
        codtta,
        nomtta,
        nomgen,
        fcreac,
        factua,
        usuari,
        swacti
    )
        SELECT
            pin_id_cia,
            codtta,
            nomtta,
            nomgen,
            fcreac,
            factua,
            usuari,
            swacti
        FROM
            tipotarea
        WHERE
            id_cia = empresa_modelo_id;

-- TITULOLISTA 
    INSERT INTO titulolista (
        id_cia,
        codtit,
        codmon,
        titulo,
        abrevi,
        tipcal,
        factor,
        incigv,
        modpre,
        fcreac,
        factua,
        usuari,
        swacti,
        porcom
    )
        SELECT
            pin_id_cia,
            codtit,
            codmon,
            titulo,
            abrevi,
            tipcal,
            factor,
            incigv,
            modpre,
            fcreac,
            factua,
            usuari,
            swacti,
            porcom
        FROM
            titulolista
        WHERE
            id_cia = empresa_modelo_id;

-- TITULOLISTA_CLASES 
    INSERT INTO titulolista_clases (
        id_cia,
        codtit,
        clase,
        codigo,
        vreal,
        vstrg,
        vchar,
        vdate,
        vtime,
        ventero,
        codusercrea,
        coduseractu,
        fcreac,
        factua
    )
        SELECT
            pin_id_cia,
            codtit,
            clase,
            codigo,
            vreal,
            vstrg,
            vchar,
            vdate,
            vtime,
            ventero,
            codusercrea,
            coduseractu,
            fcreac,
            factua
        FROM
            titulolista_clases
        WHERE
            id_cia = empresa_modelo_id;

-- TLIBRO 
    INSERT INTO tlibro (
        id_cia,
        codlib,
        descri,
        moneda01,
        moneda02,
        destino,
        abrevi,
        usuario,
        swacti,
        fcreac,
        factua,
        filtro,
        motivo
    )
        SELECT
            pin_id_cia,
            codlib,
            descri,
            moneda01,
            moneda02,
            destino,
            abrevi,
            usuario,
            swacti,
            fcreac,
            factua,
            filtro,
            motivo
        FROM
            tlibro
        WHERE
            id_cia = empresa_modelo_id;

-- TLIBROS_CLASE 
    INSERT INTO tlibros_clase (
        id_cia,
        codlib,
        clase,
        nombre,
        vreal,
        vstrg,
        vchar,
        vdate,
        vtime,
        ventero,
        fcreac,
        factua
    )
        SELECT
            pin_id_cia,
            codlib,
            clase,
            nombre,
            vreal,
            vstrg,
            vchar,
            vdate,
            vtime,
            ventero,
            fcreac,
            factua
        FROM
            tlibros_clase
        WHERE
            id_cia = empresa_modelo_id;

-- TMONEDA 
    INSERT INTO tmoneda (
        id_cia,
        codmon,
        desmon,
        abrevi,
        simbolo,
        nacional,
        cdifdeb,
        cdifhab,
        codsunat,
        fcreac,
        factua,
        usuari,
        swacti,
        tcdesde,
        tchasta
    )
        SELECT
            pin_id_cia,
            codmon,
            desmon,
            abrevi,
            simbolo,
            nacional,
            cdifdeb,
            cdifhab,
            codsunat,
            fcreac,
            factua,
            usuari,
            swacti,
            tcdesde,
            tchasta
        FROM
            tmoneda
        WHERE
            id_cia = empresa_modelo_id;
-- UNIDAD 
    INSERT INTO unidad (
        id_cia,
        coduni,
        desuni,
        codsunat,
        fcreac,
        factua,
        usuari,
        swacti,
        abrevi,
        undmedco,
        codiso
    )
        SELECT
            pin_id_cia,
            coduni,
            desuni,
            codsunat,
            fcreac,
            factua,
            usuari,
            swacti,
            abrevi,
            undmedco,
            codiso
        FROM
            unidad
        WHERE
            id_cia = empresa_modelo_id;

-- UNIDAD_MEDIDA_SUNAT 
    INSERT INTO unidad_medida_sunat (
        id_cia,
        codigo,
        descri_ing,
        descri_esp
    )
        SELECT
            pin_id_cia,
            codigo,
            descri_ing,
            descri_esp
        FROM
            unidad_medida_sunat
        WHERE
            id_cia = empresa_modelo_id;

-- MODULOS DE USUARIO
-- USUARIOS 
    INSERT INTO usuarios (
        id_cia,
        coduser,
        nombres,
        clave,
        atributos,
        fexpira,
        situac,
        fcreac,
        factua,
        swacti,
        usuari,
        comentario,
        impeti,
        numcaja,
        cargo,
        codsuc,
        email
    )
        SELECT
            pin_id_cia,
            coduser,
            nombres,
            clave,
            atributos,
            fexpira,
            situac,
            fcreac,
            factua,
            swacti,
            usuari,
            comentario,
            impeti,
            numcaja,
            cargo,
            codsuc,
            email
        FROM
            usuarios
        WHERE
                id_cia = empresa_modelo_id
            AND ( v_user_admin IS NULL
                  OR coduser = v_user_admin );

-- GRUPO_USUARIO
    INSERT INTO grupo_usuario (
        id_cia,
        codgrupo,
        desgrupo,
        swacti
    )
        SELECT
            pin_id_cia,
            codgrupo,
            desgrupo,
            swacti
        FROM
            grupo_usuario
        WHERE
            id_cia = empresa_modelo_id;

-- USUARIO_GRUPO
    INSERT INTO usuario_grupo (
        id_cia,
        codgrupo,
        coduser
    )
        SELECT
            pin_id_cia,
            codgrupo,
            coduser
        FROM
            usuario_grupo
        WHERE
                id_cia = empresa_modelo_id
            AND ( v_user_admin IS NULL
                  OR coduser = v_user_admin );

-- USUARIOS_PROPIEDADES 
    INSERT INTO usuarios_propiedades (
        id_cia,
        coduser,
        codigo,
        nombre,
        swflag,
        vstring,
        observ
    )
        SELECT
            pin_id_cia,
            coduser,
            codigo,
            nombre,
            swflag,
            vstring,
            observ
        FROM
            usuarios_propiedades
        WHERE
                id_cia = empresa_modelo_id
            AND ( v_user_admin IS NULL
                  OR coduser = v_user_admin );

-- EMPRESA MODULOS
    INSERT INTO empresa_modulos (
        id_cia,
        codmod,
        swacti
    )
        SELECT
            pin_id_cia,
            m.codmod,
            m.swacti
        FROM
            empresa_modulos m
        WHERE
                m.id_cia = empresa_modelo_id
            AND NOT EXISTS (
                SELECT
                    x.codmod
                FROM
                    empresa_modulos x
                WHERE
                        x.id_cia = pin_id_cia
                    AND x.codmod = m.codmod
            );

-- USUARIOS MODULOS
    INSERT INTO usuario_modulos (
        id_cia,
        codmod,
        coduser,
        swacti
    )
        SELECT
            pin_id_cia,
            codmod,
            coduser,
            swacti
        FROM
            usuario_modulos
        WHERE
                id_cia = empresa_modelo_id
            AND ( v_user_admin IS NULL
                  OR coduser = v_user_admin );

-- EXCELDINAMICO_GENERICO
    INSERT INTO exceldinamico_especifico (
        id_cia,
        codexc,
        desexc,
        cadsql,
        observ,
        nlibro,
        codmod,
        tipbd,
        params,
        swtabd,
        swsistema
    )
        SELECT
            pin_id_cia,
            codexc,
            desexc,
            cadsql,
            observ,
            nlibro,
            codmod,
            tipbd,
            params,
            swtabd,
            swsistema
        FROM
            exceldinamico_especifico
        WHERE
            id_cia = empresa_modelo_id;

-- EXCELDINAMICO_GRUPO 
    INSERT INTO exceldinamico_grupo (
        id_cia,
        codexc,
        codgrupo
    )
        SELECT
            pin_id_cia,
            codexc,
            codgrupo
        FROM
            exceldinamico_grupo
        WHERE
            id_cia = empresa_modelo_id;

-- EXCELDINAMICO_USUARIO 
    INSERT INTO exceldinamico_usuario (
        id_cia,
        codexc,
        coduser
    )
        SELECT
            pin_id_cia,
            codexc,
            coduser
        FROM
            exceldinamico_usuario
        WHERE
                id_cia = empresa_modelo_id
            AND ( v_user_admin IS NULL
                  OR coduser = v_user_admin );

-- VENDEDOR 
    INSERT INTO vendedor (
        id_cia,
        codven,
        desven,
        cargo,
        email,
        celular,
        telefo,
        comisi,
        abrevi,
        fcreac,
        factua,
        usuari,
        swacti,
        firma,
        formfirma
    )
        SELECT
            pin_id_cia,
            codven,
            desven,
            cargo,
            email,
            celular,
            telefo,
            comisi,
            abrevi,
            fcreac,
            factua,
            usuari,
            swacti,
            firma,
            formfirma
        FROM
            vendedor
        WHERE
                id_cia = empresa_modelo_id
            AND codven = 1;

-- VENDEDOR_CLASE 
    INSERT INTO vendedor_clase (
        id_cia,
        codven,
        clase,
        codigo,
        vreal,
        vstrg,
        vchar,
        vdate,
        vtime,
        ventero,
        codusercrea,
        coduseractu,
        fcreac,
        factua
    )
        SELECT
            pin_id_cia,
            codven,
            clase,
            codigo,
            vreal,
            vstrg,
            vchar,
            vdate,
            vtime,
            ventero,
            codusercrea,
            coduseractu,
            fcreac,
            factua
        FROM
            vendedor_clase
        WHERE
                id_cia = empresa_modelo_id
            AND codven = 1;

    INSERT INTO colregcom (
        id_cia,
        tipo,
        columna,
        descri
    )
        SELECT
            pin_id_cia,
            tipo,
            columna,
            descri
        FROM
            colregcom
        WHERE
            id_cia = empresa_modelo_id;

    INSERT INTO cuentas_cchica (
        id_cia,
        motivo,
        cuenta,
        nombre,
        dh
    )
        SELECT
            pin_id_cia,
            motivo,
            cuenta,
            nombre,
            dh
        FROM
            cuentas_cchica
        WHERE
            id_cia = empresa_modelo_id;

    -- INSETANDO DOCUMENTOS POR DEFECTO
    INSERT INTO documentos (
        id_cia,
        codigo,
        series,
        tipinv,
        codalm,
        codsuc,
        libro,
        cuenta,
        docid,
        docdef,
        descri,
        correl,
        nomser,
        swcorr,
        usuari,
        fcreac,
        factua,
        swacti,
        lpt,
        compago,
        kardex,
        canitem,
        filart,
        visachkcred,
        despoblapro,
        actcorr,
        docelec,
        tipimp
    ) VALUES (
        pin_id_cia,
        '601',
        '0',
        NULL,
        NULL,
        '1',
        NULL,
        NULL,
        NULL,
        'S',
        'Documento de compras proveedor',
        '1',
        NULL,
        'A',
        NULL,
        current_timestamp,
        current_timestamp,
        'S',
        NULL,
        NULL,
        NULL,
        '0',
        NULL,
        NULL,
        NULL,
        NULL,
        'N',
        '0'
    );

    INSERT INTO documentos (
        id_cia,
        codigo,
        series,
        tipinv,
        codalm,
        codsuc,
        libro,
        cuenta,
        docid,
        docdef,
        descri,
        correl,
        nomser,
        swcorr,
        usuari,
        fcreac,
        factua,
        swacti,
        lpt,
        compago,
        kardex,
        canitem,
        filart,
        visachkcred,
        despoblapro,
        actcorr,
        docelec,
        tipimp
    ) VALUES (
        pin_id_cia,
        '602',
        '0',
        NULL,
        NULL,
        '1',
        NULL,
        NULL,
        NULL,
        'S',
        'Recibo por Honorarios',
        '1',
        NULL,
        'A',
        NULL,
        current_timestamp,
        current_timestamp,
        'S',
        NULL,
        NULL,
        NULL,
        '0',
        NULL,
        NULL,
        NULL,
        NULL,
        'N',
        '0'
    );

    INSERT INTO documentos (
        id_cia,
        codigo,
        series,
        tipinv,
        codalm,
        codsuc,
        libro,
        cuenta,
        docid,
        docdef,
        descri,
        correl,
        nomser,
        swcorr,
        usuari,
        fcreac,
        factua,
        swacti,
        lpt,
        compago,
        kardex,
        canitem,
        filart,
        visachkcred,
        despoblapro,
        actcorr,
        docelec,
        tipimp
    ) VALUES (
        pin_id_cia,
        '610',
        '0',
        NULL,
        NULL,
        '1',
        NULL,
        NULL,
        NULL,
        'S',
        'Ctas. x Pagar Proveedores',
        '1',
        NULL,
        'A',
        NULL,
        current_timestamp,
        current_timestamp,
        'S',
        NULL,
        NULL,
        NULL,
        '0',
        NULL,
        NULL,
        NULL,
        NULL,
        'N',
        '0'
    );

    INSERT INTO documentos (
        id_cia,
        codigo,
        series,
        tipinv,
        codalm,
        codsuc,
        libro,
        cuenta,
        docid,
        docdef,
        descri,
        correl,
        nomser,
        swcorr,
        usuari,
        fcreac,
        factua,
        swacti,
        lpt,
        compago,
        kardex,
        canitem,
        filart,
        visachkcred,
        despoblapro,
        actcorr,
        docelec,
        tipimp
    ) VALUES (
        pin_id_cia,
        '611',
        '0',
        NULL,
        NULL,
        '1',
        NULL,
        NULL,
        NULL,
        'S',
        'Registro de Recibos',
        '1',
        NULL,
        'A',
        NULL,
        current_timestamp,
        current_timestamp,
        'S',
        NULL,
        NULL,
        NULL,
        '0',
        NULL,
        NULL,
        NULL,
        NULL,
        'N',
        '0'
    );

    INSERT INTO regimen_retenciones_vigencia (
        id_cia,
        codigo,
        finicio,
        tope,
        tasa
    )
        SELECT
            pin_id_cia,
            codigo,
            finicio,
            tope,
            tasa
        FROM
            regimen_retenciones_vigencia
        WHERE
            id_cia = empresa_modelo_id;
            
    -- MODULO CRM
    INSERT INTO turno_asistencia (
        id_cia,
        codturno,
        descri
    )
        SELECT
            pin_id_cia,
            codturno,
            descri
        FROM
            turno_asistencia
        WHERE
            id_cia = empresa_modelo_id;

    sp_genera_secuencia_tdocume(pin_id_cia);
    sp_update_sequence_tdocume(pin_id_cia, NULL);
    sp_generate_sequences_the_documents_for_cia(pin_id_cia);
    v_accion := 'El proceso se realizó satisfactoriamente';
    pack_hr_empresa.sp_generar(pin_id_cia, hr_empresa_modelo_id, pin_coduser, v_mensaje);
    dbms_output.put_line(v_mensaje);
    m := json_object_t.parse(v_mensaje);
    IF ( m.get_number('status') <> 1.0 ) THEN
        pout_mensaje := m.get_string('message');
        RAISE pkg_exceptionuser.ex_error_inesperado;
    END IF;

    SELECT
        JSON_OBJECT(
            'status' VALUE 1.0,
            'message' VALUE 'Succes ...!'
        )
    INTO pin_mensaje
    FROM
        dual;

    COMMIT;
EXCEPTION
    WHEN pkg_exceptionuser.ex_error_inesperado THEN
        SELECT
            JSON_OBJECT(
                'status' VALUE 1.2,
                'message' VALUE pout_mensaje
            )
        INTO pin_mensaje
        FROM
            dual;

        ROLLBACK;
        DELETE FROM companias
        WHERE
            cia = pin_id_cia;

        DELETE FROM companias_glosa
        WHERE
            id_cia = pin_id_cia;

        COMMIT;
    WHEN OTHERS THEN
        pin_mensaje := 'mensaje : '
                       || sqlerrm
                       || ' fijvar :'
                       || sqlcode;
        SELECT
            JSON_OBJECT(
                'status' VALUE 1.2,
                'message' VALUE pin_mensaje
            )
        INTO pin_mensaje
        FROM
            dual;

        ROLLBACK;
        DELETE FROM companias
        WHERE
            cia = pin_id_cia;

        DELETE FROM companias_glosa
        WHERE
            id_cia = pin_id_cia;

        COMMIT;
END sp_genera_datos_nueva_empresa;

/

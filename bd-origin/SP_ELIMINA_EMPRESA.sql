--------------------------------------------------------
--  DDL for Procedure SP_ELIMINA_EMPRESA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "USR_TSI_SUITE"."SP_ELIMINA_EMPRESA" (
    pin_id_cia IN NUMBER
) AS

    v_mensaje    VARCHAR2(1000);
    pin_mensaje  VARCHAR2(1000);
    pout_mensaje VARCHAR2(1000);
    o            json_object_t;
BEGIN

-- PRIMERO DESACTIVAMOS LOS TRIGGERS DE LAS TABLAS TRANSACCIONALES
    sp_disable_enable_all_triggers(0, 'TSI', v_mensaje);
    o := json_object_t.parse(v_mensaje);
    IF ( o.get_number('status') <> 1.0 ) THEN
        pout_mensaje := o.get_string('message');
        RAISE pkg_exceptionuser.ex_error_inesperado;
    END IF;

    DELETE FROM companias_glosa
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM companias_grupo
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM companias
    WHERE
        cia = pin_id_cia;    

--  MODULO CONTABILIDAD

    DELETE FROM wmovimientos
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM movimientos_relacion
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM movimientos
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM t_inventario_clase
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM titulolista
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM asiendet
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM m_pago_config
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM dcta102_caja_cab
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM t_inventariosunat
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM clases_tdocume
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM tipo_afectacion_igv
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM procedencia
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM bgeneralhea
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM compr001
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM companias_config_email
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM tocasionales
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM titulolista_clases
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM documentos_situac_max
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM dcta105
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM tbancos
    WHERE
        id_cia = pin_id_cia;
    -- ARTICULO

    DELETE FROM tratamiento
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM prov102
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM globa010
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM oprodtrans_pendientes
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM tdoccobranza
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM detraccion_det_envio_sunat
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM e_financiera_tipo
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM tiempos_det
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM oprodtranferencias
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM usos
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM especificaciones_certificados
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM bgeneraldet
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM areas
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM norma_iso
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM cuentas_cchica
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM pcuentas_clase
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM pcuentas_ccosto
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM tccostos
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM pcuentastccostos
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM pcuentas
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM clase_global
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM estado
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM colregcom
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM eventos_clase
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM envio_almacen
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM dcta101
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM zona
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM dcta100_log
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM dcta100
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM idx001
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM caja_cuad
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM situacion
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM ubicacion
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM tsinoticias
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM kardex001_situac_max
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM calidad
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM diametro
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM conceptos_pdt
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM tsubccosto
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM t_sociedad
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM m_pago_clase
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM proceso_costo
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM asienhea
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM ordeproddet
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM estado_cxc
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM clase_concepto
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM documentos_materiales
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM wcodigo
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM materiales_estandar
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM documento_destino
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM clase_cliente_articulos
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM produccion_kanban
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM kardex_costoventa
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM familias
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM usuarios_conecta
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM comprometido
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM movimiento_cta_cte_cab
    WHERE
        id_cia = pin_id_cia;
-- MOVIMIENTOS

    DELETE FROM dcta102
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM clientecontacto
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM banco011
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM documentos_ent
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM prov113
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM unidad
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM compr002
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM clientes_credito_log
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM documentos_cab_imagen
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM listaprecios
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM clase_vendedor_codigo
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM guia_cab
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM operarios_categoria
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM regimen_retenciones_vigencia
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM levv
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM dcta100_ori
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM tanalitica
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM e_financiera
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM kardex002
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM documentos_tipo_clase
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM tapiz
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM profesion
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM tipotarea
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM reg_eliminados
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM rel_factura_cotizacion
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM observacion
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM almacen
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM documentos_cab_c_pago
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM clase_tdoccobranza
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM compr010docrel
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM etapas
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM documentos_cab_log
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM compania_facelec
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM region
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM documentos_det_clieart_clase
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM movimientos_acumulados
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM lineas
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM proceso_costo_kardex
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM documentos_det_ent
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM oprodavance
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM compr010_clase
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM detraccion_cab_envio_sunat
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM documentos_cab_clase
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM documentos_cab_envio_sunat
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM documentos_cab_xml
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM documentos_det_imagen
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM documentos_imagen
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM documentos_tipo
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM e_financiera_clase
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM estructuras_cdsxml
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM estructuras_certificado_xml
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM eventos
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM favoritos
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM fe_comunica_baja_cab
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM fe_resumendiario_cab
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM clase_tdoccobranza_codigo
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM tcierre
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM tbkanban
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM dcta104
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM cobrador
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM documentos_det_2
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM vendedor_clase
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM compr004
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM certificadocal_cab
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM oprodetapas
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM oprodcosto
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM banco010
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM compr003
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM etiquetas_activas_2
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM grupos_articulos_costo
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM compr010_imagen
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM tarea_asistencia
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM usuario_impresora
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM estado_envio_detraccion
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM documentos_det_aprobacion
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM proyecto_tarea
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM movimientos_relacion_asiento
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM ordeprodcab
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM conta001
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM compr010guia
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM kanban_cab
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM clase_pcuentas_codigo
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM clientecontacto_clase
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM anticuamiento
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM kardex_saldo_etiqueta
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM articulos_movimiento
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM estado_envio_sunat
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM articulos_exonerado
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM filt001
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM factor
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM fe_comunica_baja_det
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM articulos_ean
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM adicionales
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM kardexlevv
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM documentos
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM dcta103
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM bancos_estadocuenta
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM clase_documentos_det
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM almacen_clase
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM kardex001_impr
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM cliente_tpersona
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM cargo
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM bancos002
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM tipoacabado
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM vehiculos
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM kardex000
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM regimen_retenciones
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM cventas
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM compr010
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM ganaperdidet
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM procedencia_orden
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM motivos_clase
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM kardex
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM noticias_clase
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM clase_clientes_almacen_codigo
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM kardex_asiento
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM prov104
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM articulos_muebles
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM clase_cliente
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM pcuentas_clase_alternativo
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM marcas
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM cliente_garantia
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM tdocume
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM afp
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM modulos
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM documentos_esp
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM documentos_relacion
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM bancos001
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM prov100
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM liquihea
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM sector
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM motivos_cuentas
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM liquidet
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM tlibro
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM articulos_isc
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM kardex001
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM meses
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM articulos_almacen_codadd
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM tcuentas
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM clase_e_financiera
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM documentos_cab_aprobacion
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM cventas_mes
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM articulos_glosa
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM tipo_hora
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM sucursal_clases
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM articulo_especificacion
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM fidelidad
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM clase_global_codigo
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM operaciones
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM caja_det
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM caja_ubicacion
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM clase_eventos
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM volumen
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM tcancelacion
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM banco002
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM documentos_cab_verificacion
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM documentos_clase_ayuda
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM clase_documentos_tipo
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM tbancos_clase
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM alma
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM articulos_almacen
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM clase_vendedor
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM clientes_especificacion
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM clase_codigo
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM tipo_notificacion_usuarios_grupos
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM dcta103_aprobacion
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM tdh
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM clase_e_financiera_codigo
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM t_inventario
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM clase_articulos_alternativo
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM articulos_costo_codadd
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM tipo_uso_esp
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM fe_resumendiario_det
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM clientes_aval
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM tarea
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM tipoplanilla
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM tmoneda
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM c_pago_det
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM cliente_codpag
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM documentos_cab_referencia
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM personal
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM desicion
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM usuarios_charts
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM empresa_modulos
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM clase_noticias_codigo
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM articulos_detraccion
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM documentos_aprobacion
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM tdocume_caja
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM ccompras
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM ordprodproc
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM tmotivos
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM etiquetas_activas
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM tipo_trabajador
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM clase_documentos_det_codigo
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM clase_clientes_almacen
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM articulos_ventas
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM tipo_uso_ing
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM articulos_clase_global
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM cierre
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM dcta102_aprobacion
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM clases_titulolista_codigo
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM articulos_costo
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM motivos
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM articulo_intermedio
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM movimientos_conciliacion_a
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM articulos_clase
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM logdocumentos
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM tipo_hora_tareo
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM wasienhea
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM maquinas
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM permisos
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM almacen_ubicacion
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM tlibros_clase
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM articulos_clase_alternativo
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM destino_ventas
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM t_negocio
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM tipocliente
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM oprodcostoanterior
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM banco005
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM clase_documentos_cab
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM documentos_det_percepcion
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM listaprecios_alternativa
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM articulos_depreciacion
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM prov105
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM clientes_almacen
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM t_persona
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM documentos_cab_almacen
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM documentos_glosa
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM asterisc
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM color
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM tdoccobranza_clase
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM mayor
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM saldos_tanalitica
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM tproyecto
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM tipo_control_stock
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM clase_pcuentas
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM tittablas
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM estado_civil
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM dcta106
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM kilos_unitario
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM c_pago_clase
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM antiguamiento_almacen
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM temp_estudio_mermas
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM cuentas_x_pagar
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM prov101
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM clase_documentos_cab_codigo
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM cliente_bancos
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM especificaciones
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM treference
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM pendientes_tipo
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM banco030
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM acciontarea
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM tcambio
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM ar_cobranza
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM kanban_det
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM contacto
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM ganaperdihea
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM clase_pcuentas_alternativo
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM articulos_adjunto
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM articulos_imagen
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM certificadocal_det
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM certificados_pfx
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM charts
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM cliente_documento
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM cliente_potencial_xml
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM cliente_xml
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM clientes_almacen_clase
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM companias_glosa
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM importsi
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM kpis
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM noticias
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM notificacion
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM oprodespecifica
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM pendientes_orden
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM retencion_envio_sunat
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM seguimiento_impr
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM sucursal
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM tarea_documento
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM tarea_imagen
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM tecnico
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM tipo_notificacion
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM usuarios_grids
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM usuarios_imagen
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM vendedor
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM movimientos_conciliacion
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM unidad_medida_sunat
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM clase
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM caja_surtidor_articulos
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM grupos_almacen
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM dcta113
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM documentos_det_relacion
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM c_pago_compras
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM caja_turno
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM proyecto_tarea_grupo
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM ccotizaciones
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM prov103
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM tdocume_clases
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM docrefere
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM ctascompania
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM identidad
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM especificaciones_clientes
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM clase_noticias
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM cliente_clase
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM tfactor
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM clases_tdocume_codigo
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM proyecto_tarea_usuario
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM m_pago
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM tiempos_cab
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM lugar_emision
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM torcido
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM modelo
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM caja_cab
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM funcion_planilla
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM listaprecios_codund
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM comprometido_almacen
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM compr005
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM documentos_relacion_hash
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM factor_afp
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM grupos
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM retenhea
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM documentos_clase
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM articulos_deprealt
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM estado_personal
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM motivo_planilla
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM nacionalidad
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM documentos_materiales_ent
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM etapas_usos
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM articulos_costo_reposicion
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM c_pago
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM caja_surtidor
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM banco003
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM clases_titulolista
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM clase_eventos_codigo
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM dcta103_rel
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM exceldinamico
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM clase_documentos_tipo_codigo
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM documentos_cab_factor_tipcam
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM cliente_articulos_clase
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM tgastos
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM documentos_cab_impexp
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM periodo_comision
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM compr040
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM construccion
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM cliente
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM compr011
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM documentos_det
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM histosto
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM clase_cliente_codigo
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM kanban_det_codadd
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM notificacion_comentario
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM banco004
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM articulos_combos
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM documentos_cab_infodespacho
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM transportista
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM documentos_stock
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM operarios
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM tdimension
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM tautomaticos
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM cuentas_x_cobrar
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM cod_auxiliar
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM retendet
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM tarea_documentos_relacion
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM clase_concepto_codigo
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM documentos_cab_ordcom
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM documentos_cab_contacto
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM vendedor_metas
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM tbancos_cheques
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM listaprove
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM documentos_det_clase
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM prioridad
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM tipo_notificacion_usuarios
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM tcontab
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM relacion
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM tituloinventa
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM libros
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM articulos_stock
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM documentos_cab_transportista
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM documentos_cab
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM m_destino
    WHERE
        id_cia = pin_id_cia;

    -- ELIMINANDO ARTICULOS

    DELETE FROM articulos
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM articulo_almacen
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM almacen_clase
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM almacen_ubicacion
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM almacen
    WHERE
        id_cia = pin_id_cia;

    COMMIT;

    -- MODULO PLANILLA
    DELETE FROM tccostos
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM tipo_trabajador
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM situacion_personal
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM estado_civil
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM nacionalidad
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM afp
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM factor_afp
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM tipoplanilla
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM tipoplanilla_concepto
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM concepto_clase
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM concepto_funcion
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM concepto
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM dsctoprestamo
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM factor_clase_planilla
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM factor_planilla
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM funcion_planilla
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM cargo
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM motivo_planilla
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM personal_ccosto
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM clase_codigo_personal
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM clase_personal
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM personal_clase
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM personal_contrato
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM personal_cts
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM personal_dependiente
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM personal_documento
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM personal_legajo
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM personal_noafecto
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM personal_periodo_rpension
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM personal_periodolaboral
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM planilla_concepto_leyenda
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM planilla_rango
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM planilla_resumen
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM planilla_concepto
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM planilla_auxiliar
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM planilla_afp
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM planilla
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM prestamo_tipoplanilla
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM prestamo
    WHERE
        id_cia = pin_id_cia;

-- MODULO USUARIOS
    DELETE FROM usuario_grupo
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM exceldinamico_grupo
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM grupo_usuario
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM usuarios_propiedades
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM exceldinamico_usuario
    WHERE
        id_cia = pin_id_cia;

--    DELETE FROM exceldinamico
--    WHERE
--        id_cia = pin_id_cia;

    DELETE FROM exceldinamico_especifico
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM usuarios_activos
    WHERE
        id_cia = pin_id_cia;

    DELETE FROM usuarios
    WHERE
        id_cia = pin_id_cia;
    -- FINALMENTE ACTIVAMOS LOS TRIGGERS
    sp_disable_enable_all_triggers(1, 'TSI', v_mensaje);
    o := json_object_t.parse(v_mensaje);
    IF ( o.get_number('status') <> 1.0 ) THEN
        pout_mensaje := o.get_string('message');
        RAISE pkg_exceptionuser.ex_error_inesperado;
    END IF;

    dbms_output.put_line('Success ... !');
EXCEPTION
    WHEN pkg_exceptionuser.ex_error_inesperado THEN
        dbms_output.put_line(pout_mensaje);
    WHEN OTHERS THEN
        pin_mensaje := 'mensaje : '
                       || sqlerrm
                       || ' codigo :'
                       || sqlcode;
        pout_mensaje := 'Ocurrio un Error [ '
                        || pin_mensaje
                        || ' ]';
        dbms_output.put_line(pout_mensaje);
        ROLLBACK;
END sp_elimina_empresa;

/

--------------------------------------------------------
--  DDL for Package PACK_TR_TAREA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_TR_TAREA" AS
    TYPE datarecord_grupo_usuario IS RECORD (
        id_cia grupo_usuario.id_cia%TYPE,
        codigo grupo_usuario.codgrupo%TYPE,
        descri grupo_usuario.desgrupo%TYPE
    );
    TYPE datatable_grupo_usuario IS
        TABLE OF datarecord_grupo_usuario;
    TYPE datarecord_tarea IS RECORD (
        id_cia        tarea.id_cia%TYPE,
        numint        tarea.numint%TYPE,
        numero        tarea.numtta%TYPE,
--        usu_coduser          tarea.usuari%TYPE,
--        usu_nombres          usuarios.nombres%TYPE,
        uactua        tarea.usuari%TYPE,
        nomuactua     usuarios.nombres%TYPE,
        cargo         usuarios.cargo%TYPE,
        titulo        tarea.titulo%TYPE,
        codtta     tarea.codtta%TYPE,
        codacc     tarea.codacc%TYPE,
        codaccDesc     acciontarea.nomacc%TYPE,
        codpri        tarea.codpri%TYPE,
        codpriDesc        prioridad.nompri%TYPE,
        fvisita   tarea.fvisita%TYPE,
        hinicio    VARCHAR2(100 CHAR),
        ffinal    tarea.ffinal%TYPE,
        hfinal     VARCHAR2(100 CHAR),
        observacion   tarea.observacion%TYPE,
        situac        tarea.situac%TYPE,
        situacDesc    situacion.dessit%TYPE,
        fcreac        tarea.fcreac%TYPE,
        factua        tarea.factua%TYPE,
        tipcli    tarea.tipcli%TYPE,
        codcli    cliente.codcli%TYPE,
        razonc    cliente.razonc%TYPE,
        telefono  cliente.telefono%TYPE,
        email    cliente.email%TYPE,
        direccion    cliente.direc1%TYPE,
        codcont  contacto.codcont%TYPE,
        nomcont  contacto.nomcont%TYPE,
        cont_telefono contacto.telefono%TYPE,
        cont_email    contacto.email%TYPE,
        numint_tpadre tarea.numint_tpadre%TYPE,
        numint_proyec tarea.numint_proyec%TYPE,
        proyecto      proyecto_tarea.titulo%TYPE,
--        usu_asignado_coduser usuarios.coduser%TYPE,
--        usu_asignado_nombres usuarios.nombres%TYPE,
        coduser       usuarios.coduser%TYPE,
        nomcoduser    usuarios.nombres%TYPE,
        ua_cargo      usuarios.cargo%TYPE
    );
    TYPE datatable_tarea IS
        TABLE OF datarecord_tarea;
    TYPE datarecord_buscar_tarea IS RECORD (
        id_cia     tarea.id_cia%TYPE,
        numint     tarea.numint%TYPE,
        numero     tarea.numtta%TYPE,
        titulo     tarea.titulo%TYPE,
        fecha      tarea.ffinal%TYPE,
        hora       tarea.hfinal%TYPE,
        prioridad  tarea.codpri%TYPE,
        completado VARCHAR2(100 CHAR),
        subtareas  NUMBER,
        uactua     tarea.usuari%TYPE,
        coduser    tarea.coduserori%TYPE,
        situac     tarea.situac%TYPE,
        factua     tarea.factua%TYPE
    );
    TYPE datatable_buscar_tarea IS
        TABLE OF datarecord_buscar_tarea;
    TYPE datarecord_tarea_pendiente IS RECORD (
        id_cia     tarea.id_cia%TYPE,
        numint     tarea.numint%TYPE,
        numero     tarea.numtta%TYPE,
        titulo     tarea.titulo%TYPE,
        fecha      tarea.ffinal%TYPE,
        hora       tarea.hfinal%TYPE,
        prioridad  tarea.codpri%TYPE,
        completado VARCHAR2(100 CHAR),
        subtareas  NUMBER,
        uactua     tarea.usuari%TYPE,
        coduser    tarea.coduserori%TYPE
    );
    TYPE datatable_tarea_pendiente IS
        TABLE OF datarecord_tarea_pendiente;
    TYPE datarecord_proyecto_asignado_usuario IS RECORD (
        id_cia proyecto_tarea.id_cia%TYPE,
        numint proyecto_tarea.numint%TYPE,
        titulo proyecto_tarea.titulo%TYPE,
        color  proyecto_tarea.color%TYPE
    );
    TYPE datatable_proyecto_asignado_usuario IS
        TABLE OF datarecord_proyecto_asignado_usuario;
    FUNCTION sp_count_subtareas (
        pin_id_cia NUMBER,
        pin_numint NUMBER
    ) RETURN NUMBER;

    FUNCTION sp_proyecto_grupo_usuario (
        pin_id_cia        NUMBER,
        pin_numint_proyec NUMBER
    ) RETURN datatable_grupo_usuario
        PIPELINED;

    FUNCTION sp_obtener (
        pin_id_cia NUMBER,
        pin_numint NUMBER
    ) RETURN datatable_tarea
        PIPELINED;

    FUNCTION sp_buscar (
        pin_id_cia  NUMBER,
        pin_coduser VARCHAR2,
        pin_fdesde  DATE,
        pin_fhasta  DATE,
        pin_situac  VARCHAR2,
        pin_codtta  NUMBER,
        pin_codcli  VARCHAR2,
        pin_offset  NUMBER,
        pin_limit   NUMBER
    ) RETURN datatable_buscar_tarea
        PIPELINED;

    PROCEDURE sp_save (
        pin_id_cia  IN NUMBER,
        pin_datos   IN VARCHAR2,
        pin_opcdml  IN INTEGER,
        pin_mensaje OUT VARCHAR2
    );

    FUNCTION sp_tarea_pendiente (
        pin_id_cia        NUMBER,
        pin_coduser       VARCHAR2,
        pin_numint_proyec NUMBER
    ) RETURN datatable_tarea_pendiente
        PIPELINED;

    FUNCTION sp_tarea_completada (
        pin_id_cia        NUMBER,
        pin_coduser       VARCHAR2,
        pin_numint_proyec NUMBER,
        pin_offset        NUMBER,
        pin_limit         NUMBER
    ) RETURN datatable_tarea_pendiente
        PIPELINED;

    FUNCTION sp_tarea_pendiente_proyecto (
        pin_id_cia        NUMBER,
        pin_numint_proyec NUMBER,
        pin_offset        NUMBER,
        pin_limit         NUMBER
    ) RETURN datatable_tarea_pendiente
        PIPELINED;

    FUNCTION sp_tarea_completada_proyecto (
        pin_id_cia        NUMBER,
        pin_numint_proyec NUMBER,
        pin_offset        NUMBER,
        pin_limit         NUMBER
    ) RETURN datatable_tarea_pendiente
        PIPELINED;

    FUNCTION sp_buscar_subtareas (
        pin_id_cia NUMBER,
        pin_numint NUMBER
    ) RETURN datatable_tarea_pendiente
        PIPELINED;

    FUNCTION sp_proyecto_asignado_usuario (
        pin_id_cia  NUMBER,
        pin_coduser VARCHAR2
    ) RETURN datatable_proyecto_asignado_usuario
        PIPELINED;

END;

/

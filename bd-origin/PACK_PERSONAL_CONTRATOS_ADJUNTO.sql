--------------------------------------------------------
--  DDL for Package PACK_PERSONAL_CONTRATOS_ADJUNTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "USR_TSI_SUITE"."PACK_PERSONAL_CONTRATOS_ADJUNTO" AS
    TYPE t_personal_contratos_adjunto IS
        TABLE OF personal_contratos_adjunto%rowtype;
    FUNCTION sp_sel_personal_contratos_adjunto (
        pin_id_cia  IN  NUMBER,
        pin_codper  IN  VARCHAR2,
        pin_nrocon  IN  SMALLINT,
        pin_item    IN  SMALLINT
    ) RETURN t_personal_contratos_adjunto
        PIPELINED;

    PROCEDURE sp_save_personal_contratos_adjunto (
        pin_id_cia   IN   NUMBER,
        pin_datos    IN   VARCHAR2,
        pin_opcdml   INTEGER,
        pin_mensaje  OUT  VARCHAR2
    );

END;

/

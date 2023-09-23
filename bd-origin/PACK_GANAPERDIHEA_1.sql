--------------------------------------------------------
--  DDL for Package Body PACK_GANAPERDIHEA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_GANAPERDIHEA" AS

  PROCEDURE sp_save (
        pin_id_cia   IN   NUMBER,
        pin_datos    IN   VARCHAR2,
        pin_opcdml   INTEGER,
        pin_mensaje  OUT  VARCHAR2
    ) AS
        o               json_object_t;
        rec  GANAPERDIHEA%rowtype;
        v_response        VARCHAR2(220) := '';
  BEGIN


        o := json_object_t.parse(pin_datos);
        rec.id_cia := pin_id_cia;
        rec.codigo := o.get_number('codigo');
        rec.tipo := o.get_string('tipo');
        rec.titulo := o.get_string('titulo');
        rec.signo := o.get_string('signo');

         CASE pin_opcdml
            WHEN 1 THEN
                v_response := 'La grabación';
                INSERT INTO GANAPERDIHEA values rec;
                COMMIT;
            WHEN 2 THEN
                update GANAPERDIHEA
                set tipo = rec.tipo, titulo = rec.titulo, signo = rec.signo
                where id_cia = pin_id_cia
                and codigo = rec.codigo;
                COMMIT;
            WHEN 3 THEN
                v_response := 'La eliminación';
                DELETE FROM GANAPERDIHEA
                WHERE id_cia = rec.id_cia
                AND codigo = rec.codigo;
                COMMIT;
        END CASE;

        pin_mensaje := v_response || ' se realizó satisfactoriamente';      

  END sp_save;

  PROCEDURE sp_save_det (
        pin_id_cia   IN   NUMBER,
        pin_datos    IN   VARCHAR2,
        pin_opcdml   INTEGER,
        pin_mensaje  OUT  VARCHAR2
    ) AS
        o               json_object_t;
        rec  GANAPERDIDET%rowtype;
        v_response        VARCHAR2(220) := '';
  BEGIN

        o := json_object_t.parse(pin_datos);
        rec.id_cia := pin_id_cia;
        rec.codigo := o.get_string('codigo');
        rec.cuenta := o.get_string('cuenta');

          CASE pin_opcdml
            WHEN 1 THEN
                v_response := 'La grabación';
                INSERT INTO GANAPERDIDET values rec;
                COMMIT;
            WHEN 2 THEN

                COMMIT;
            WHEN 3 THEN
                v_response := 'La eliminación';
                DELETE FROM GANAPERDIDET
                WHERE id_cia = rec.id_cia
                AND codigo = rec.codigo
                AND cuenta = rec.cuenta;
                COMMIT;
        END CASE;

        pin_mensaje := v_response || ' se realizó satisfactoriamente';   
  END sp_save_det;

END PACK_GANAPERDIHEA;

/

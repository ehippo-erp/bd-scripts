--------------------------------------------------------
--  DDL for Package Body PACK_BGENERALHEA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "USR_TSI_SUITE"."PACK_BGENERALHEA" AS

  PROCEDURE sp_save (
        pin_id_cia   IN   NUMBER,
        pin_datos    IN   VARCHAR2,
        pin_opcdml   INTEGER,
        pin_mensaje  OUT  VARCHAR2
    ) AS
        o               json_object_t;
        rec  BGENERALHEA%rowtype;
        v_response        VARCHAR2(220) := '';

  BEGIN 
            o := json_object_t.parse(pin_datos);
            rec.id_cia := pin_id_cia;
            rec.codigo := o.get_number('codigo');
            rec.tipo := o.get_string('tipo');
            rec.titulo := o.get_string('titulo');
            rec.codadic := o.get_number('codadic');
            rec.consig := o.get_string('consig');
           CASE pin_opcdml
            WHEN 1 THEN
                v_response := 'La grabación';
                INSERT INTO BGENERALHEA values rec;
                COMMIT;
            WHEN 2 THEN
                update BGENERALHEA
                set tipo = rec.tipo, titulo = rec.titulo, codadic = rec.codadic, consig = rec.consig
                where id_cia = pin_id_cia
                and codigo = rec.codigo;
                COMMIT;
            WHEN 3 THEN
                v_response := 'La eliminación';
                DELETE FROM BGENERALHEA
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
        rec  BGENERALDet%rowtype;
        v_response        VARCHAR2(220) := '';
  BEGIN
        o := json_object_t.parse(pin_datos);
        rec.id_cia := pin_id_cia;
        rec.codigo := o.get_string('codigo');
        rec.cuenta := o.get_string('cuenta');

          CASE pin_opcdml
            WHEN 1 THEN
                v_response := 'La grabación';
                INSERT INTO BGENERALDet values rec;
                COMMIT;
            WHEN 2 THEN

                COMMIT;
            WHEN 3 THEN
                v_response := 'La eliminación';
                DELETE FROM BGENERALDet
                WHERE id_cia = rec.id_cia
                AND codigo = rec.codigo
                AND cuenta = rec.cuenta;
                COMMIT;
        END CASE;
        pin_mensaje := v_response || ' se realizó satisfactoriamente';  
  END sp_save_det;

END PACK_BGENERALHEA;

/

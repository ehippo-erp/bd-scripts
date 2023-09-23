--------------------------------------------------------
--  DDL for Package PKG_CONSTANTES
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE "USR_TSI_SUITE"."PKG_CONSTANTES" AS
---tipos de documento---
    c_td100 NUMBER := 100;/** cotizaciones        **/
    c_td101 NUMBER := 101;/** orden de desapacho  **/
    c_td102 NUMBER := 102;/** Guia de remision    **/
    c_td103 NUMBER := 104;/** Orden de produccion   **/
    TYPE arr_clastbancos IS
        VARRAY(15) OF VARCHAR2(80) NOT NULL;
    kaclastbancos arr_clastbancos := arr_clastbancos('Contabilidad opción bancos', 'Planilla de cobranza', 'Planilla de cuentas por pagar',
    'Cantidad de items - Planilla de envío documentos cobranza', 'Cantidad de items - Planilla de envío documentos descuento',
                'Porcentaje minimo de renovaciones de letras', 'Imprime DNI si es persona natural en letra renovada', 'Planilla de envío al banco',
                'Planilla documentos varios - Anticipos', 'Planilla documentos varios - Letras',
                'Generar cheques', 'Codigo de formato de bancos', 'Visible en envio por correo de avisos de vencimiento', 'Contacto de banco',
                'Operacion retencion');
    TYPE arr_bancos IS
        VARRAY(6) OF VARCHAR2(80) NOT NULL;
    kabancos arr_bancos := arr_bancos('No definido', 'BCP', 'Interbank', 'Scotiabank', 'BBVA',
           'BIF');
    TYPE arr_cierres IS
        VARRAY(5) OF VARCHAR2(80) NOT NULL;
    kacierres arr_cierres := arr_cierres('Contabilidad', 'Cuentas por cobrar', 'Comercial', 'Logistica', 'Cuentas por pagar');
END pkg_constantes;

/

--------------------------------------------------------
--  DDL for Function SP000_AJUSTA_STRING
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE FUNCTION "USR_TSI_SUITE"."SP000_AJUSTA_STRING" (
 WSTRING IN VARCHAR2,
 WLARGO IN NUMBER,
 WCARACTER IN CHAR,
 WDIRECCION IN CHAR)
 RETURN VARCHAR2
 IS
 WX NUMBER;
 WY NUMBER;
 SVALOR VARCHAR2(200);
 XDIRECCION CHAR;
BEGIN
 IF (WSTRING IS NULL) THEN 
  SVALOR:='';
 ELSE
  WX := 1;
  WY := WLARGO-LENGTH(WSTRING);
  SVALOR :='';
  XDIRECCION:=UPPER(WDIRECCION);
  WHILE (WX<=WY) LOOP
    SVALOR:=SVALOR||WCARACTER;
    WX:=WX+1;
  END LOOP;

  IF (XDIRECCION='R') THEN SVALOR:=SVALOR||WSTRING; END IF;
  IF (XDIRECCION='L') THEN SVALOR:=WSTRING||SVALOR; END IF;
  IF (XDIRECCION='C') THEN 
   WX:=WY/2;
   WY:=WY-WX;
   SVALOR:=SUBSTR(SVALOR,1,WX)||WSTRING||SUBSTR(SVALOR,1,WY);
  END IF;
 END IF;
 RETURN SVALOR;
END SP000_AJUSTA_STRING;

/

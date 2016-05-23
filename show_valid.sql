---------------------------------------------------------------------
--
--               Copyright(C) 2013 Tim St. Hilaire
--                         All Rights Reserved
--
---------------------------------------------------------------------
SET PAGESIZE 1000

set serverout on

PROMPT ================================================================================
PROMPT ==  ACL Valid Test
PROMPT ==
PROMPT == Check Validitity of all ACL sources
PROMPT == NOTE: An invalid ACL will raise an ORA-44416: Invalid ACL error
PROMPT ================================================================================

Set feedback off
DECLARE
  -- na
BEGIN
  FOR X IN 
  (
          SELECT 
            (
              SELECT SYS_OP_R2O(extractValue(P.RES, '/Resource/XMLRef')) 
                FROM XDB.XDB$ACL A, PATH_VIEW P
               WHERE extractValue(P.RES, '/Resource/XMLRef') = REF(A) AND
                     EQUALS_PATH(P.RES, ACL) = 1
            ) as ACL_ID, ACL
            FROM (
                  select distinct ACL from dba_network_acls
                 )
  )
  LOOP
    dbms_output.put_line('------------------------------------------------------------------');
    dbms_output.put_line('testing ACL:  '|| X.ACL);
    DBMS_XDBZ.ValidateACL(X.ACL_ID);
    dbms_output.put_line('PASSED');
    dbms_output.put_line('------------------------------------------------------------------');

  END LOOP;
  
END;
/
PROMPT ================================================================================


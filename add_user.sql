---------------------------------------------------------------------
--
--               Copyright(C) 2013 Tim St. Hilaire
--                         All Rights Reserved
--
---------------------------------------------------------------------

--  verify off prevents the old/new substitution message
set verify off
-- Show the dbms_output results
set serverout on

PROMPT ================================================================================
PROMPT == Add User to ACL 
PROMPT == 
PROMPT == This will add a database user to an existing ACL using its full XML file path
PROMPT ================================================================================

-- Show the existing ACL files
@show_descrip

-- setup bind variables
variable ACL_FILE varchar2(4000)
variable ACL_USER varchar2(4000)

-- Prompt the user for an application ID overide
ACCEPT ACL_FILE CHAR DEFAULT NULL PROMPT '== Enter the ACL to assign the user to (xml path and file)      : '
ACCEPT ACL_USER CHAR DEFAULT NULL PROMPT '== Enter the DATABASE USER to assign to the ACL (case sensitive): '
PROMPT

-- Assign Values to bind variables
exec :ACL_FILE := trim('&ACL_FILE')
exec :ACL_USER := trim('&ACL_USER')

DECLARE
  l_process_error EXCEPTION;
  l_temp VARCHAR2(32767);
  l_ACL_ID    RAW(16);
BEGIN

  IF :ACL_FILE IS NULL THEN
    dbms_output.put_line('** ISSUE: No ACL given.  ACL assignment aborted.');
    raise l_process_error;
  END IF;

  -- Confirm ACL file input exists
  BEGIN
    SELECT path
    INTO l_temp
    FROM path_view 
    WHERE path = :ACL_FILE
      AND path LIKE '/sys/acls/%.xml';
  EXCEPTION WHEN NO_DATA_FOUND THEN
    dbms_output.put_line('** ISSUE: The user entered ['||:ACL_FILE||'] does not exist');
    raise l_process_error;
  END;

  -- Confirm the USER NAME exists
  BEGIN
    SELECT username 
    INTO l_temp
    FROM dba_users
    WHERE username = :ACL_USER;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    dbms_output.put_line('** ISSUE: The user entered ['||:ACL_USER||'] does not exist. (case sensitive)');
    raise l_process_error;
  END;


  SELECT SYS_OP_R2O(extractValue(P.RES, '/Resource/XMLRef')) 
    INTO l_ACL_ID
    FROM XDB.XDB$ACL A, PATH_VIEW P
   WHERE extractValue(P.RES, '/Resource/XMLRef') = REF(A) AND
         EQUALS_PATH (P.RES, :ACL_FILE) = 1;

  DBMS_XDBZ.ValidateACL(l_ACL_ID);

  dbms_output.put_line('All Checks Passed...');

  dbms_output.put_line('Adding User...');
  DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE(:ACL_FILE, :ACL_USER, TRUE, 'connect'); 
  DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE(:ACL_FILE, :ACL_USER, TRUE, 'resolve'); 

  /* Note: from 11g docs
  If you enter a value for the lower_port and leave the upper_port at null (or just omit it), Oracle Database assumes the upper_port setting is the same as the lower_port. For example, if you set lower_port to 80 and omit upper_port, the upper_port setting is assumed to be 80.
  The resolve privilege in the access control list takes no effect when a port range is specified in the access control list assignment.
  */

  commit;
  
  dbms_output.put_line('Complete...   Review results below.');


EXCEPTION  
  WHEN l_process_error THEN
    dbms_output.put_line('** Due to issue the process has ended....');
END;
/

-- shows the results
-- includes the prompt
@show_users

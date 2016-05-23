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
-- Hide the "procedure completed messages"
set feedback off

-- Show Current Assignemnts
@show_users

PROMPT ================================================================================
PROMPT == ACL USER REMOVE
PROMPT ==
PROMPT == Remove a User from an ACL assignment
PROMPT ==
PROMPT == NOTE: not all users can be removed from an ACL.  One is required
PROMPT ================================================================================
PROMPT

-- setup bind variables
variable ACL_FILE varchar2(4000)
variable ACL_USER varchar2(4000)

-- Gather User Input into substitution variables
ACCEPT ACL_FILE CHAR  PROMPT '== Enter the ACL to remove the user from (xml path and file) : '
ACCEPT ACL_USER CHAR  PROMPT '== Enter the DATABASE USER to remove to the ACL              : '
PROMPT

-- Assign Values to bind variables
exec :ACL_FILE := trim('&ACL_FILE')
exec :ACL_USER := trim('&ACL_USER')


DECLARE
  l_process_error EXCEPTION;
  l_temp VARCHAR2(32767);
BEGIN

  IF :ACL_FILE = '' THEN
    dbms_output.put_line('** ISSUE: No ACL given.  ACL assignment aborted.');
    raise l_process_error;
  END IF;

  -- Confirm ACL file input exists
  BEGIN
    SELECT acl  
    INTO l_temp
    FROM dba_network_acls 
    WHERE acl = :ACL_FILE;
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


  dbms_output.put_line('All Checks Passed...');
  dbms_output.put_line('Removing User...');

  -- To remove....
  DBMS_NETWORK_ACL_ADMIN.DELETE_PRIVILEGE(:ACL_FILE, :ACL_USER, TRUE, 'connect'); 
  
  commit;

EXCEPTION 
  WHEN l_process_error THEN
    dbms_output.put_line('** Due to issue the process has ended....');
    dbms_output.put_line('.');
END;
/

-- shows the results
-- includes the prompt
@show_users

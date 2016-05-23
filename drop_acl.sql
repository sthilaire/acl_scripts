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

-- Show existing Data 
@show_descrip

PROMPT ================================================================================
PROMPT == ACL REMOVE
PROMPT == 
PROMPT == This will REMOVE an existing ACL file and related hosts and user references
PROMPT ================================================================================
PROMPT

-- setup bind variables
variable ACL_FILE varchar2(4000)

-- Gather User Input into substitution variables
ACCEPT ACL_FILE CHAR DEFAULT NULL        PROMPT '== Enter the ACL FILE   (Full .xml Path)   : '

PROMPT

-- use bind variables
exec :ACL_FILE := trim('&ACL_FILE')

DECLARE
  l_process_error EXCEPTION;
  l_temp VARCHAR2(32767);
BEGIN

  -- Input Check
  IF :ACL_FILE IS NULL THEN
    dbms_output.put_line('** ISSUE: An ACL file input is required..');
    raise l_process_error;
  END IF;

  -- Confirm ACL file input exists
  -- include ACL list that may not have privs
  BEGIN
    SELECT path
    INTO l_temp
    FROM path_view 
    WHERE path = :ACL_FILE
      AND path LIKE '/sys/acls/%.xml';
  EXCEPTION WHEN NO_DATA_FOUND THEN
    dbms_output.put_line('** ISSUE: The ACL File entered ['||:ACL_FILE||'] does not exist');
    raise l_process_error;
  END;

  dbms_output.put_line('All Checks Passed...');

  dbms_network_acl_admin.drop_acl( acl         => :ACL_FILE);
  dbms_output.put_line('Complete: The ACL File ['||:ACL_FILE||'] has been removed.');

  commit;

EXCEPTION 
  WHEN l_process_error THEN
    dbms_output.put_line('** Due to issue the process has ended....');
END;
/

-- shows the results
-- includes the prompt
@show_descrip

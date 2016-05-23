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

-- show existing data
@show_hosts

PROMPT ================================================================================
PROMPT == ACL HOST REMOVE
PROMPT == 
PROMPT == This will remove a specific host and port range from an ACL file 
PROMPT ================================================================================
PROMPT

-- setup bind variables
variable ACL_FILE varchar2(4000)
variable ACL_HOST varchar2(4000)
variable ACL_PLOW number
variable ACL_PHI  number

-- Gather User Input into substitution variables
ACCEPT ACL_FILE CHAR                PROMPT '== Enter the ACL FILE   (Full .xml Path)         : '
ACCEPT ACL_HOST CHAR DEFAULT '*'    PROMPT '== Enter the HOST to REMOVE FROM the ACL [*]     : '
ACCEPT ACL_PLOW CHAR DEFAULT NULL   PROMPT '== Enter the LOW PORT  (must match current value): '
ACCEPT ACL_PHI  CHAR DEFAULT NULL   PROMPT '== Enter the HIGH PORT (must match current value): '
PROMPT

-- use bind variables
exec :ACL_FILE := trim('&ACL_FILE')
exec :ACL_HOST := trim('&ACL_HOST')
-- NULL default will not be seen as a string here
exec :ACL_PLOW := &ACL_PLOW 
exec :ACL_PHI  := &ACL_PHI    

DECLARE
  l_process_error EXCEPTION;
  l_temp VARCHAR2(32767);
BEGIN



  -- Input Check
  IF :ACL_FILE IS NULL 
  or :ACL_FILE = ''
  or :ACL_HOST IS NULL 
  THEN
    dbms_output.put_line(' ');
    dbms_output.put_line('** ISSUE: FILE and HOST inputs are required..');
    dbms_output.put_line(' ');
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

  -- Actual Assignment procedure
  DBMS_NETWORK_ACL_ADMIN.UNASSIGN_ACL (
     acl         => :ACL_FILE,
     host        => :ACL_HOST,
     lower_port  => :ACL_PLOW,
     upper_port  => :ACL_PHI
     );

  commit;

  dbms_output.put_line('Complete...   Review results below.');


EXCEPTION 
  WHEN l_process_error THEN
    dbms_output.put_line('** Due to issue the process has ended....');
    dbms_output.put_line('.');

END;
/

-- shows the results
-- includes the prompt
@show_hosts

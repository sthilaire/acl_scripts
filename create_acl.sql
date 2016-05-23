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
PROMPT == ACL Create
PROMPT == 
PROMPT == This will create a new ACL file and assign a default user 
PROMPT ==
PROMPT == When creating an ACL - it needs to be assigned to a user by default.
PROMPT ================================================================================

-- setup bind variables
variable ACL_NAME varchar2(4000)
variable ACL_USER varchar2(4000)
variable ACL_DESC varchar2(4000)
variable ACL_FILE varchar2(4000)
variable ACL_HOST varchar2(4000)
variable ACL_PLOW number
variable ACL_PHI  number

ACCEPT ACL_NAME CHAR DEFAULT NULL PROMPT '== Enter the ACL NAME   (do not include .xml)        : '
ACCEPT ACL_USER CHAR DEFAULT NULL PROMPT '== Enter the DATABASE USER as Owner (case sensitive) : '
ACCEPT ACL_DESC CHAR DEFAULT NULL PROMPT '== Enter a useful description for the ACL usage      : '
ACCEPT ACL_HOST CHAR DEFAULT '*'  PROMPT '== Enter the HOST for the ACL (ex.* or *.google.com) : '
ACCEPT ACL_PLOW CHAR DEFAULT NULL PROMPT '== Enter the LOW PORT limit  (null is OK)            : '
ACCEPT ACL_PHI  CHAR DEFAULT NULL PROMPT '== Enter the HIGH PORT limit (null is OK)            : '

PROMPT

-- Assign Values to bind variables
exec :ACL_NAME := trim('&ACL_NAME')
exec :ACL_USER := trim('&ACL_USER')
exec :ACL_DESC := trim('&ACL_DESC')
exec :ACL_FILE := trim('&ACL_NAME')||'.xml'
--exec :ACL_FILE := '/sys/acls/'||trim('&ACL_NAME')||'.xml'
exec :ACL_HOST := trim('&ACL_HOST')
exec :ACL_PLOW := &ACL_PLOW
exec :ACL_PHI  := &ACL_PHI


DECLARE
  l_process_error EXCEPTION;
  l_temp VARCHAR2(32767);
BEGIN

  -- Input Check
  IF :ACL_NAME IS NULL 
  or :ACL_USER IS NULL 
  or :ACL_DESC IS NULL 
  or :ACL_HOST IS NULL 
  THEN
    dbms_output.put_line('** ISSUE: Not enought inputs....');
    raise l_process_error;
  END IF;

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


dbms_network_acl_admin.create_acl(
  acl         => :ACL_NAME||'.xml',
  description => :ACL_DESC,
  principal   => :ACL_USER, 
  is_grant    => TRUE, 
  privilege   => 'connect');

  dbms_output.put_line('ACL File created.....');

    -- Actual Assignment procedure
  DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL (
     acl         => :ACL_FILE,
     host        => :ACL_HOST,
     lower_port  => :ACL_PLOW,
     upper_port  => :ACL_PHI
     );

  DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE(:ACL_FILE, :ACL_USER, TRUE, 'resolve'); 

  dbms_output.put_line('Host Assignment Complete...   Review results below.');

  commit;
  
EXCEPTION 
  WHEN l_process_error THEN
    dbms_output.put_line('** Due to issue the process has ended....');
END;
/

-- shows the results
@show_users

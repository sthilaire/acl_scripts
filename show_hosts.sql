---------------------------------------------------------------------
--
--               Copyright(C) 2013 Tim St. Hilaire
--                         All Rights Reserved
--
---------------------------------------------------------------------
SET PAGESIZE 1000

PROMPT ================================================================================
PROMPT == ACL Host Access Information
PROMPT ==
PROMPT == Show the current ACL Host Assignments
PROMPT == These are the lists of HOST and PORT range
PROMPT == The list of privelages assigned are in the ACL list
PROMPT ==
PROMPT == NOTE: removing all the hosts from a file will prevent the users from displaying
PROMPT ================================================================================

COLUMN HOST        HEADING 'HOST'      FORMAT A25
COLUMN LOWER_PORT  HEADING 'Port|From' FORMAT 999999
COLUMN UPPER_PORT  HEADING 'Port|To'   FORMAT 999999
COLUMN ACL         HEADING 'ACL File'  FORMAT A25

SELECT acl, host, lower_port, upper_port
FROM dba_network_acls;

PROMPT ================================================================================

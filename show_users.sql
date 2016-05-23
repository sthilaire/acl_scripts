---------------------------------------------------------------------
--
--               Copyright(C) 2013 Tim St. Hilaire
--                         All Rights Reserved
--
---------------------------------------------------------------------
SET PAGESIZE 1000

PROMPT ================================================================================
PROMPT ==  ACL User Assignments 
PROMPT ==
PROMPT == This is the list of the users assigned to each ACL.
PROMPT ==    Note: ACL files that do not have assigned hosts will not show
PROMPT ================================================================================

COLUMN ACL         HEADING 'ACL File'   FORMAT A35
COLUMN PRINCIPAL   HEADING 'User'       FORMAT A20
COLUMN privilege   HEADING 'Priv'       FORMAT A10
COLUMN IS_GRANT    HEADING 'Is|Grant'   FORMAT A8 
--COLUMN INVERT      HEADING 'Invert'     FORMAT A8
SELECT ACL, PRINCIPAL, privilege, IS_GRANT--,INVERT, START_DATE,END_DATE
from dba_network_acl_privileges;

PROMPT ================================================================================

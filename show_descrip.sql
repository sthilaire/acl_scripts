---------------------------------------------------------------------
--
--               Copyright(C) 2013 Tim St. Hilaire
--                         All Rights Reserved
--
---------------------------------------------------------------------
SET PAGESIZE 1000

set serverout on

PROMPT ================================================================================
PROMPT == ACL Descriptions
PROMPT ==
PROMPT == Description of ACL Files.  
PROMPT == Note: ACL files with no host assignment can still be used.
PROMPT ================================================================================

COLUMN ACL         HEADING 'ACL File'   FORMAT A30
COLUMN DESCRIP     HEADING 'ACL Description' FORMAT A40
COLUMN PRIVS       HEADING 'Privs' FORMAT A5

SELECT distinct
PATH as ACL,
XDBUriType(ACL).getXML().extract('/acl/@description').getStringVal() as DESCRIP,
NVL2(ACL,'Yes','No') as PRIVS
from 
dba_network_acls full outer join PATH_VIEW on PATH = ACL
where REGEXP_LIKE (PATH, '^/sys/acls/([^/]*.xml)')
and PATH NOT IN
(-- seeded XMLDB ACL LIST
'/sys/acls/bootstrap_acl.xml',
'/sys/acls/all_owner_acl.xml',
'/sys/acls/all_all_acl.xml',
'/sys/acls/ro_all_acl.xml',
'/sys/acls/ro_anonymous_acl.xml'
);

PROMPT ================================================================================

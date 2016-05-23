
PROMPT ================================================================================
PROMPT = Any display of HTML text means that process was able to fetch data on port 80
PROMPT ================================================================================

select user from dual;
select substr(utl_http.request('http://www.google.com'),1,200) TEST from dual;

PROMPT ================================================================================

--Show all tables in SCHEMA
--# http://dba.stackexchange.com/questions/1285/how-do-i-list-all-databases-and-tables-using-psql
SELECT table_name FROM information_schema.tables WHERE table_schema = '[schema_name]';

--Create New Schema
CREATE SCHEMA resultstbls;

--Count unique values of a field
SELECT COUNT(*) FROM (SELECT DISTINCT column_name FROM schema_name.table_name) AS temp;


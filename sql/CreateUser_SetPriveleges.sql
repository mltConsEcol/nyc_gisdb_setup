--Create Username and password
CREATE USER [username] WITH password '[insert password]';

--Grant access to schemas
GRANT USAGE ON SCHEMA public, staging, resultlayers  TO [insert username];

--grant access to tables within schemas
GRANT SELECT, INSERT, UPDATE, DELETE on ALL TABLES in SCHEMA public, staging, resultlayers  TO [insert username];
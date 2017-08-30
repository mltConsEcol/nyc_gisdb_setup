--Thinned from 
select DISTINCT ON (OWNERNAME) * from resultlayers.compiled_lands_pluto_ipis_colp_final_centr where ownername @@  'US*' or ownername @@ 'United States' or ownername @@ 'U.S.' or ownername @@ 'U. S.' --Also added USPS

--SELECT * FROM resultlayers.compiled_lands_pluto_ipis_colp_final_centr into test.finalownership

--Define Federal Owner entity
UPDATE resultlayers.compiled_lands_pluto_ipis_colp_final_centr
SET entity = 'FED' WHERE
entity like 'FED' or entity like 'OTFED'
or (ownername like 'THE UNITED STATES OF'
or ownername like 'U S AMERICA'
or ownername like 'U S GOV'
or ownername like 'U S GOVERNMENT'
or ownername like 'U S GOVERNMENT OWNED'
or ownername like 'U S GOVT INTERIOR'
or ownername like 'U S GOVT LAND & BLDGS'
or ownername like 'U S GOVT POST OFFIC'
or ownername like 'U S GOVT POST OFFICE'
or ownername like 'U S OF AMERICA'
or ownername like 'U S POST OFFICE'
or ownername like 'U S POSTAL SER'
or ownername like 'U S POSTAL SERVICE'
or ownername like 'U S POSTAL SVCE'
or ownername like 'U.S. CUSTOMS AND BORD'
or ownername like 'U.S. DEPARTMENT OF H.'
or ownername like 'U.S. DEPARTMENT OF HU'
or ownername like 'U.S. DEPARTMENT OF TR'
or ownername like 'UNITED STATE AVA'
or ownername like 'UNITED STATE OF AMERI'
or ownername like 'UNITED STATES A- VA'
or ownername like 'UNITED STATES A-HUD'
or ownername like 'UNITED STATES A-V A'
or ownername like 'UNITED STATES A-VA'
or ownername like 'UNITED STATES A HUD'
or ownername like 'UNITED STATES A OF VA'
or ownername like 'UNITED STATES A VA'
or ownername like 'UNITED STATES AMERICA'
or ownername like 'UNITED STATES ARMY'
or ownername like 'UNITED STATES MARSHAL'
or ownername like 'UNITED STATES OF AMER'
or ownername like 'UNITED STATES OF AMFB'
or ownername like 'UNITED STATES POST OF'
or ownername like 'UNITED STATES POSTAL'
or ownername like 'UNITED STATES POSTALE'
or ownername like 'UNITED STATES POSTALS'
or ownername like 'UNITED STATES POSTLSR'
or ownername like 'US COAST GUARD'
or ownername like 'US DEPARTMENT OF TRAN'
or ownername like 'US DEPT OF HOUSING &'
or ownername like 'US DEPT OF HUD-MF/REO'
or ownername like 'US GENERAL SERVICES A'
or ownername like 'US GOV'
or ownername like 'US GOVERNMENT'
or ownername like 'US GOVERNMENT GEN SER'
or ownername like 'US GOVT POST OFFICE'
or ownername like 'US MARSHAL SERVICE, S'
or ownername like 'US POSTAL SERV'
or ownername like 'USPS'
or ownername like 'US TREASURY' and entity like 'UNK');



--Update Entity to City where Owned is indicated from IPIS dataset
UPDATE resultlayers.compiled_lands_pluto_ipis_colp_final_centr
SET entity = 'CITY' WHERE entity LIKE 'UNK' 
AND (ownertype LIKE 'C' OR owned_leased LIKE 'O' OR ownername LIKE 'THE CITY OF NEW YORK' OR ownername LIKE 'CITY OF NEW YORK')

UPDATE resultlayers.compiled_lands_pluto_ipis_colp_final_centr
SET entity = 'FED' WHERE 
zonedist1 like 'PARKUS';

UPDATE resultlayers.compiled_lands_pluto_ipis_colp_final_centr
SET entity = 'STATE' WHERE 
ownername like 'THE PEOPLE OF THE STA' OR ownername like 'PEOPLE OF THE STATE O' or zonedist1 like 'PARKNYS';
set search_path to raw, stage, working, campaign_finance, election_results;

show search_path;

-- drop table stage.election_results;

create table stage.election_results
    (
        last_updated timestamp,
        county varchar(100),
        precinct varchar(100),
        input_office varchar(100),
        office varchar(100),
        district varchar(100),
        input_candidate varchar(100),
        candidate varchar(100),
        party varchar(50),
        total_votes varchar(50),
        vote_type varchar(50),
        votes varchar(50)
    );

-- truncate table stage.election_results;

-- Run python script to load xml files...

update stage.election_results
    set last_updated = '2020-11-20 15:37:43';

select *
from stage.election_results
limit 5000;

select count(*) as cnt
from stage.election_results;
-- 194688

select input_candidate, count(*) as cnt
from stage.election_results
group by input_candidate
order by input_candidate;
-- 263 candidates...
-- These need a bit of cleanup...

select input_office, count(*) as cnt
from stage.election_results
group by input_office
order by input_office;
-- 164 offices...
-- These need a bit of cleanup to match Branch offices...

update stage.election_results
    set office = input_office,
        candidate = input_candidate;
-- Move over inputs...don't touch inputs incase we need to reset...

------------------------------------------------------------------------------------------------------------------------
-- FIX #1 - REMOVE DOUBLE SPACES IN CANDIDATE NAMES AND REMOVE PARTY NAME...
------------------------------------------------------------------------------------------------------------------------
update stage.election_results
    set candidate = trim(regexp_replace(candidate, '\s+', ' ', 'g'));

update stage.election_results
    set candidate = replace(candidate, ' (Rep)', '')
where office is not null
    and candidate like '% (Rep)';

update stage.election_results
    set candidate = replace(candidate, ' (Dem)', '')
where office is not null
    and candidate like '% (Dem)';

update stage.election_results
    set candidate = replace(candidate, ' (Ind)', '')
where office is not null
    and candidate like '% (Ind)';

update stage.election_results
    set candidate = replace(candidate, ' (Lib)', '')
where office is not null
    and candidate like '% (Lib)';

select candidate, count(*) as cnt
from stage.election_results
group by candidate
order by candidate;

------------------------------------------------------------------------------------------------------------------------
-- FIX #2 - REMOVE SPANISH PORTION OF OFFICE NAME...
------------------------------------------------------------------------------------------------------------------------
select
    input_office,
    office,
    count(*) as cnt
from stage.election_results
where input_office ilike '%/%'
group by input_office, office
order by office;

update stage.election_results
    set office = (regexp_split_to_array(office, '/'))[1]
where input_office ilike '%/%';

select distinct office
from stage.election_results
order by office;

------------------------------------------------------------------------------------------------------------------------
-- CLARITY - FIX #3 - STANDARDIZE DIST TO DISTRICT TO MATCH ALL OTHERS...
------------------------------------------------------------------------------------------------------------------------
select office, count(*) as cnt
from stage.election_results
where input_office ilike '% Dist %'
group by office
order by office;

update stage.election_results
    set office = replace(office, ' Dist ', ' District ')
where input_office ilike '% Dist %';

------------------------------------------------------------------------------------------------------------------------
-- CLARITY - FIX #4 - COUPLE OF SPECIAL FIXES...
------------------------------------------------------------------------------------------------------------------------
update stage.election_results
    set office = 'State Senate District 39'
where input_office = 'State Senate District 39 - Special Democratic Primary';

update stage.election_results
    set office = 'US Senate (Special)'
where input_office = 'US Senate (Loeffler) - Special';

update stage.election_results
    set office = 'US Senate (Special)'
where input_office = 'US Senate (Loeffler) - Special/Senado de los EE.UU. (Loeffler) - Especial';

update stage.election_results
    set office = 'US Senate'
where input_office = 'US Senate (Perdue)';

update stage.election_results
    set office = 'US Senate'
where input_office = 'US Senate (Perdue)/Senado de los EE.UU. (Perdue)';

update stage.election_results
    set office = 'District Attorney - Clayton'
where input_office = 'District Attorney - Clayton - Special Election';

update stage.election_results
    set office = 'District Attorney - Cobb'
where input_office = 'District Attorney - Cobb - Special';

update stage.election_results
    set office = 'District Attorney - Douglas'
where input_office = 'District Attorney - Douglas - Special';

update stage.election_results
    set office = 'District Attorney - Southwestern'
where input_office = 'District Attorney - Southwestern - Special';

update stage.election_results
    set office = 'District Attorney - Western'
where input_office = 'District Attorney - Western - Special';

select distinct input_office, office
from stage.election_results
order by office;
------------------------------------------------------------------------------------------------------------------------
-- END CLARITY FIXES...
------------------------------------------------------------------------------------------------------------------------



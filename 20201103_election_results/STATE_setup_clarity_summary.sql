show search_path;

-- create schema election_results;

set search_path to raw, stage, working, campaign_finance, election_results;

-- drop table raw.summary;

-- IMPORT SUMMARY TABLE...

-- drop table election_results.clarity_summary;

create table election_results.clarity_summary as
select
    '2020-11-20 15:37:43'::timestamp as last_updated,
    "choice name" as input_candidate,
    null::text as candidate,
    "contest name" as input_office,
    null::text as office,
    "total votes" as votes,
    "percent of votes" as percent_votes
from raw.summary;

select *
from election_results.clarity_summary;

update election_results.clarity_summary
    set office = input_office,
        candidate = input_candidate;
-- Move over inputs...don't touch inputs incase we need to reset...

------------------------------------------------------------------------------------------------------------------------
-- START CLARITY FIXES...
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
-- CLARITY - FIX #1 - REMOVE DOUBLE SPACES IN CANDIDATE NAMES AND STRIP PARTY FROM NAME...
------------------------------------------------------------------------------------------------------------------------
update election_results.clarity_summary
    set candidate = trim(regexp_replace(candidate, '\s+', ' ', 'g'));

update election_results.clarity_summary
    set candidate = replace(candidate, ' (Rep)', '')
where office is not null
    and candidate like '% (Rep)';

update election_results.clarity_summary
    set candidate = replace(candidate, ' (Dem)', '')
where office is not null
    and candidate like '% (Dem)';

update election_results.clarity_summary
    set candidate = replace(candidate, ' (Ind)', '')
where office is not null
    and candidate like '% (Ind)';

update election_results.clarity_summary
    set candidate = replace(candidate, ' (Lib)', '')
where office is not null
    and candidate like '% (Lib)';

select distinct input_candidate, candidate
from election_results.clarity_summary
order by input_candidate;

------------------------------------------------------------------------------------------------------------------------
-- CLARITY - FIX #2 - REMOVE SPANISH PORTION OF OFFICE NAME...
------------------------------------------------------------------------------------------------------------------------
select
    input_office,
    office,
    count(*) as cnt
from election_results.clarity_summary
where input_office ilike '%/%'
group by input_office, office
order by office;

update election_results.clarity_summary
    set office = (regexp_split_to_array(office, '/'))[1]
where input_office ilike '%/%';

------------------------------------------------------------------------------------------------------------------------
-- CLARITY - FIX #3 - STANDARDIZE DIST TO DISTRICT TO MATCH ALL OTHERS...
------------------------------------------------------------------------------------------------------------------------
select office, count(*) as cnt
from election_results.clarity_summary
where input_office ilike '% Dist %'
group by office
order by office;

update election_results.clarity_summary
    set office = replace(office, ' Dist ', ' District ')
where input_office ilike '% Dist %';

------------------------------------------------------------------------------------------------------------------------
-- CLARITY - FIX #4 - COUPLE OF SPECIAL FIXES...
------------------------------------------------------------------------------------------------------------------------
update election_results.clarity_summary
    set office = 'State Senate District 39'
where input_office = 'State Senate District 39 - Special Democratic Primary';

update election_results.clarity_summary
    set office = 'US Senate (Special)'
where input_office = 'US Senate (Loeffler) - Special';

update election_results.clarity_summary
    set office = 'US Senate'
where input_office = 'US Senate (Perdue)';

update election_results.clarity_summary
    set office = 'District Attorney - Clayton'
where input_office = 'District Attorney - Clayton - Special Election';

update election_results.clarity_summary
    set office = 'District Attorney - Cobb'
where input_office = 'District Attorney - Cobb - Special';

update election_results.clarity_summary
    set office = 'District Attorney - Douglas'
where input_office = 'District Attorney - Douglas - Special';

update election_results.clarity_summary
    set office = 'District Attorney - Southwestern'
where input_office = 'District Attorney - Southwestern - Special';

update election_results.clarity_summary
    set office = 'District Attorney - Western'
where input_office = 'District Attorney - Western - Special';

select distinct input_office, office
from election_results.clarity_summary
order by office;
------------------------------------------------------------------------------------------------------------------------
-- END CLARITY FIXES...
------------------------------------------------------------------------------------------------------------------------
select *
from election_results.clarity_summary;

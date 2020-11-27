show search_path;

-- create schema election_results;

set search_path to raw, stage, working, campaign_finance, election_results;

-- Load up branch candidate/office information...
select *
from stage.candidates_general_20201021;
-- 478 candidates

select race_id, count(*) as cnt
from stage.candidates_general_20201021
group by race_id
order by race_id;
-- 294 races

-- drop table election_results.branch_candidates_office_county_level;

create table election_results.branch_candidates_office_county_level
as
select
    election,
    branch_id,
    name as branch_candidate,
    race_id as branch_race_id,
    null::text as branch_county,
    null::text as clarity_candidate,
    null::text as clarity_office
from stage.candidates_general_20201021
where race_id ilike '%ga-fulton%'
    or race_id ilike '%ga-cobb%'
    or race_id ilike '%ga-dekalb%'
    or race_id ilike '%ga-gwinnett%';

select *
from election_results.branch_candidates_office_county_level;

------------------------------------------------------------------------------------------------------------------------
-- Tag counties...
------------------------------------------------------------------------------------------------------------------------
update election_results.branch_candidates_office_county_level
    set branch_county = 'Fulton'
where branch_race_id ilike '%ga-fulton%';

update election_results.branch_candidates_office_county_level
    set branch_county = 'Cobb'
where branch_race_id ilike '%ga-cobb%';

update election_results.branch_candidates_office_county_level
    set branch_county = 'DeKalb'
where branch_race_id ilike '%ga-dekalb%';

update election_results.branch_candidates_office_county_level
    set branch_county = 'Gwinnett'
where branch_race_id ilike '%ga-gwinnett%';

------------------------------------------------------------------------------------------------------------------------
-- Tag Cobb offices...
------------------------------------------------------------------------------------------------------------------------
update election_results.branch_candidates_office_county_level
    set clarity_office = 'County Commission District 2'
where clarity_office is null
    and branch_county = 'Cobb'
    and branch_race_id = 'ga-general-2020-ga-cobb-2-county-commissioner';

update election_results.branch_candidates_office_county_level
    set clarity_office = 'County Commission District 4'
where clarity_office is null
    and branch_county = 'Cobb'
    and branch_race_id = 'ga-general-2020-ga-cobb-4-county-commissioner';

update election_results.branch_candidates_office_county_level
    set clarity_office = 'County Commission Chair'
where clarity_office is null
    and branch_county = 'Cobb'
    and branch_race_id = 'ga-general-2020-ga-cobb-county-comission-chair';

update election_results.branch_candidates_office_county_level
    set clarity_office = 'Sheriff'
where clarity_office is null
    and branch_county = 'Cobb'
    and branch_race_id = 'ga-general-2020-ga-cobb-county-sheriff';

update election_results.branch_candidates_office_county_level
    set clarity_office = 'Surveyor'
where clarity_office is null
    and branch_county = 'Cobb'
    and branch_race_id = 'ga-general-2020-ga-cobb-county-surveyor';

update election_results.branch_candidates_office_county_level
    set clarity_office = 'Tax Commissioner'
where clarity_office is null
    and branch_county = 'Cobb'
    and branch_race_id = 'ga-general-2020-ga-cobb-county-tax-commissioner';

update election_results.branch_candidates_office_county_level
    set clarity_office = 'Board of Education District 1'
where clarity_office is null
    and branch_county = 'Cobb'
    and branch_race_id = 'ga-general-2020-ga-cobb-school-1-county-school-board';

update election_results.branch_candidates_office_county_level
    set clarity_office = 'Board of Education District 3'
where clarity_office is null
    and branch_county = 'Cobb'
    and branch_race_id = 'ga-general-2020-ga-cobb-school-3-county-school-board';

update election_results.branch_candidates_office_county_level
    set clarity_office = 'Board of Education District 5'
where clarity_office is null
    and branch_county = 'Cobb'
    and branch_race_id = 'ga-general-2020-ga-cobb-school-5-county-school-board';

update election_results.branch_candidates_office_county_level
    set clarity_office = 'Board of Education District 7'
where clarity_office is null
     and branch_county = 'Cobb'
   and branch_race_id = 'ga-general-2020-ga-cobb-school-7-county-school-board';

update election_results.branch_candidates_office_county_level
    set clarity_office = 'Clerk of State Court'
where clarity_office is null
     and branch_county = 'Cobb'
   and branch_race_id = 'ga-general-2020-ga-cobb-state-court-clerk';

update election_results.branch_candidates_office_county_level
    set clarity_office = 'Clerk of Superior Court'
where clarity_office is null
     and branch_county = 'Cobb'
   and branch_race_id = 'ga-general-2020-ga-cobb-superior-court-clerk';

------------------------------------------------------------------------------------------------------------------------
-- Tag Dekalb offices...
------------------------------------------------------------------------------------------------------------------------
update election_results.branch_candidates_office_county_level
    set clarity_office = 'County Commission District 1'
where clarity_office is null
     and branch_county = 'DeKalb'
   and branch_race_id = 'ga-general-2020-ga-dekalb-1-county-commissioner';

update election_results.branch_candidates_office_county_level
    set clarity_office = 'County Commission District 4'
where clarity_office is null
     and branch_county = 'DeKalb'
   and branch_race_id = 'ga-general-2020-ga-dekalb-4-county-commissioner';

update election_results.branch_candidates_office_county_level
    set clarity_office = 'County Commission District 5'
where clarity_office is null
     and branch_county = 'DeKalb'
   and branch_race_id = 'ga-general-2020-ga-dekalb-5-county-commissioner';

update election_results.branch_candidates_office_county_level
    set clarity_office = 'County Commission District 6'
where clarity_office is null
     and branch_county = 'DeKalb'
   and branch_race_id = 'ga-general-2020-ga-dekalb-6-county-commissioner';

update election_results.branch_candidates_office_county_level
    set clarity_office = 'Chief Magistrate'
where clarity_office is null
     and branch_county = 'DeKalb'
   and branch_race_id = 'ga-general-2020-ga-dekalb-chief-magistrate';

update election_results.branch_candidates_office_county_level
    set clarity_office = 'Chief Executive Officer'
where clarity_office is null
     and branch_county = 'DeKalb'
   and branch_race_id = 'ga-general-2020-ga-dekalb-county-ceo';

update election_results.branch_candidates_office_county_level
    set clarity_office = 'Sheriff'
where clarity_office is null
     and branch_county = 'DeKalb'
   and branch_race_id = 'ga-general-2020-ga-dekalb-county-sheriff';

update election_results.branch_candidates_office_county_level
    set clarity_office = 'Tax Commissioner'
where clarity_office is null
     and branch_county = 'DeKalb'
   and branch_race_id = 'ga-general-2020-ga-dekalb-county-tax-commissioner';

update election_results.branch_candidates_office_county_level
    set clarity_office = 'Solicitor General'
where clarity_office is null
     and branch_county = 'DeKalb'
   and branch_race_id = 'ga-general-2020-ga-dekalb-solicitor-general';

update election_results.branch_candidates_office_county_level
    set clarity_office = 'Clerk of Superior Court'
where clarity_office is null
     and branch_county = 'DeKalb'
   and branch_race_id = 'ga-general-2020-ga-dekalb-superior-court-clerk';

------------------------------------------------------------------------------------------------------------------------
-- Tag Fulton offices...
------------------------------------------------------------------------------------------------------------------------
update election_results.branch_candidates_office_county_level
    set clarity_office = 'County Commission District 2'
where clarity_office is null
     and branch_county = 'Fulton'
   and branch_race_id = 'ga-general-2020-ga-fulton-2-county-commissioner';

update election_results.branch_candidates_office_county_level
    set clarity_office = 'County Commission District 4'
where clarity_office is null
     and branch_county = 'Fulton'
   and branch_race_id = 'ga-general-2020-ga-fulton-4-county-commissioner';

update election_results.branch_candidates_office_county_level
    set clarity_office = 'County Commission District 6'
where clarity_office is null
     and branch_county = 'Fulton'
   and branch_race_id = 'ga-general-2020-ga-fulton-6-county-commissioner';

update election_results.branch_candidates_office_county_level
    set clarity_office = 'Sheriff'
where clarity_office is null
     and branch_county = 'Fulton'
   and branch_race_id = 'ga-general-2020-ga-fulton-county-sheriff';

update election_results.branch_candidates_office_county_level
    set clarity_office = 'Tax Commissioner'
where clarity_office is null
     and branch_county = 'Fulton'
   and branch_race_id = 'ga-general-2020-ga-fulton-county-tax-commissioner';

update election_results.branch_candidates_office_county_level
    set clarity_office = 'Solicitor General'
where clarity_office is null
     and branch_county = 'Fulton'
   and branch_race_id = 'ga-general-2020-ga-fulton-solicitor-general';

update election_results.branch_candidates_office_county_level
    set clarity_office = 'Clerk of Superior Court'
where clarity_office is null
     and branch_county = 'Fulton'
   and branch_race_id = 'ga-general-2020-ga-fulton-superior-court-clerk';

------------------------------------------------------------------------------------------------------------------------
-- Tag Gwinnett offices...
------------------------------------------------------------------------------------------------------------------------
update election_results.branch_candidates_office_county_level
    set clarity_office = 'Co Commission District 1'
where clarity_office is null
     and branch_county = 'Gwinnett'
   and branch_race_id = 'ga-general-2020-ga-gwinnett-1-county-commissioner';

update election_results.branch_candidates_office_county_level
    set clarity_office = 'Co Commission District 3'
where clarity_office is null
     and branch_county = 'Gwinnett'
   and branch_race_id = 'ga-general-2020-ga-gwinnett-3-county-commissioner';

update election_results.branch_candidates_office_county_level
    set clarity_office = 'Co Commission Chair'
where clarity_office is null
     and branch_county = 'Gwinnett'
   and branch_race_id = 'ga-general-2020-ga-gwinnett-county-comission-chair';

update election_results.branch_candidates_office_county_level
    set clarity_office = 'Sheriff'
where clarity_office is null
     and branch_county = 'Gwinnett'
   and branch_race_id = 'ga-general-2020-ga-gwinnett-county-sheriff';

update election_results.branch_candidates_office_county_level
    set clarity_office = 'Tax Commissioner'
where clarity_office is null
     and branch_county = 'Gwinnett'
   and branch_race_id = 'ga-general-2020-ga-gwinnett-county-tax-commissioner';

update election_results.branch_candidates_office_county_level
    set clarity_office = 'Brd of Education District 1'
where clarity_office is null
     and branch_county = 'Gwinnett'
   and branch_race_id = 'ga-general-2020-ga-gwinnett-school-1-county-school-board';

update election_results.branch_candidates_office_county_level
    set clarity_office = 'Brd of Education District 3'
where clarity_office is null
     and branch_county = 'Gwinnett'
   and branch_race_id = 'ga-general-2020-ga-gwinnett-school-3-county-school-board';

update election_results.branch_candidates_office_county_level
    set clarity_office = 'Brd of Education District 5'
where clarity_office is null
     and branch_county = 'Gwinnett'
   and branch_race_id = 'ga-general-2020-ga-gwinnett-school-5-county-school-board';

update election_results.branch_candidates_office_county_level
    set clarity_office = 'Clerk of Superior Court'
where clarity_office is null
     and branch_county = 'Gwinnett'
   and branch_race_id = 'ga-general-2020-ga-gwinnett-superior-court-clerk';

update election_results.branch_candidates_office_county_level
    set clarity_office = 'District Attorney - Gwinnett'
where clarity_office is null
     and branch_county = 'Gwinnett'
   and branch_race_id = 'ga-general-2020-ga-jud-circuit-gwinnett-district-attorney';

------------------------------------------------------------------------------------------------------------------------
-- End of tagging clarity office...
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- Tag candidate names...
------------------------------------------------------------------------------------------------------------------------
-- RESET
update election_results.branch_candidates_office_county_level
    set clarity_candidate = null;

-- PASS #1...
with clarity_names as
(
    select distinct
        candidate,
        trim(replace(candidate, ' (I)', '')) as match_candidate
    from stage.election_results
)
update election_results.branch_candidates_office_county_level as a
    set clarity_candidate = b.candidate
from clarity_names as b
where a.clarity_candidate is null
    and trim(upper(a.branch_candidate)) = trim(upper(b.match_candidate));

-- PASS #2...
with clarity_names as
(
    select distinct
        candidate,
        trim(replace(replace(candidate, ', ', ' '), ' (I)', '')) as match_candidate
    from stage.election_results
)
update election_results.branch_candidates_office_county_level as a
    set clarity_candidate = b.candidate
from clarity_names as b
where a.clarity_candidate is null
    and trim(upper(a.branch_candidate)) = trim(upper(b.match_candidate));

-- PASS #3...
with clarity_names as
(
    select
        candidate,
        trim((regexp_split_to_array(candidate, ' '))[1]) as first_name,
        trim((regexp_split_to_array(candidate, ' '))[array_upper(regexp_split_to_array(replace(candidate, ' (I)', ''), ' '), 1)]) as last_name
    from stage.election_results
    where (regexp_split_to_array(candidate, ' '))[array_upper(regexp_split_to_array(replace(candidate, ' (I)', ''), ' '), 1)] not in ('Jr.', 'Jr', 'Sr.', 'Sr', 'II', 'III')
        and length(candidate) > 10
        and length((regexp_split_to_array(candidate, ' '))[1]) > 2
    order by candidate
)
update election_results.branch_candidates_office_county_level as a
    set clarity_candidate = b.candidate
from clarity_names as b
where a.clarity_candidate is null
    and upper(trim(a.branch_candidate)) = upper(trim(b.first_name) || ' ' || trim(b.last_name));

-- PASS #4 - manaul fixes...
update election_results.branch_candidates_office_county_level set clarity_candidate = 'Luis ""Lou"" Solis, Jr.' where clarity_candidate is null and branch_id = 'lou-solis';
update election_results.branch_candidates_office_county_level set clarity_candidate = 'Patrick ""Pat"" Labat' where clarity_candidate is null and branch_id = 'pat-labat';
update election_results.branch_candidates_office_county_level set clarity_candidate = 'Edward ""Ted"" Terry' where clarity_candidate is null and branch_id = 'ted-terry';

-- These will need to be fixed...
select branch_id, branch_candidate, branch_race_id
from election_results.branch_candidates_office_county_level
where clarity_candidate is null
order by branch_candidate;

select distinct
    input_candidate,
    candidate,
    trim((regexp_split_to_array(input_candidate, ' '))[1]) as first_name,
    trim((regexp_split_to_array(input_candidate, ' '))[array_upper(regexp_split_to_array(replace(input_candidate, ' (I)', ''), ' '), 1)]) as last_name
from stage.election_results
where input_candidate ilike '%Davis%'
order by input_candidate;


select *
from election_results.branch_candidates_office_county_level;

------------------------------------------------------------------------------------------------------------------------
-- VALIDATE CANDIDATES...
------------------------------------------------------------------------------------------------------------------------
with branch as
(
    select distinct branch_id, clarity_candidate
    from election_results.branch_candidates_office_county_level
),
clarity as
(
    select distinct candidate
    from stage.election_results
)
select *
from branch as a
    left join clarity as b
        on trim(a.clarity_candidate) = trim(b.candidate)
where b.candidate is null
order by a.branch_id;

------------------------------------------------------------------------------------------------------------------------
-- VALIDATE OFFICES (AKA RACES) - COUNTY LEVEL...
------------------------------------------------------------------------------------------------------------------------
with branch as
(
    select distinct branch_county, branch_race_id, clarity_office
    from election_results.branch_candidates_office_county_level
    where branch_county is not null
),
clarity as
(
    select distinct office, county
    from stage.election_results
)
select *
from branch as a
    left join clarity as b
        on upper(trim(a.clarity_office)) = upper(trim(b.office))
            and upper(trim(a.branch_county)) = upper(trim(b.county))
where b.office is null
order by a.branch_race_id;

select *
from election_results.branch_candidates_office_county_level
where branch_race_id = 'ga-general-2020-ga-cobb-state-court-clerk'
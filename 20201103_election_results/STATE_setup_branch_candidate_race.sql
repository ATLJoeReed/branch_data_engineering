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

-- drop table election_results.branch_candidates_office_state_level;

create table election_results.branch_candidates_office_state_level
as
select
    election,
    branch_id,
    name as branch_candidate,
    race_id as branch_race_id,
    null::text as clarity_candidate,
    null::text as clarity_office
from stage.candidates_general_20201021
where race_id not ilike '%ga-fulton%'
    and race_id not ilike '%ga-cobb%'
    and race_id not ilike '%ga-dekalb%'
    and race_id not ilike '%ga-gwinnett%';

select *
from election_results.branch_candidates_office_state_level;

------------------------------------------------------------------------------------------------------------------------
-- Tag State House offices...
------------------------------------------------------------------------------------------------------------------------
select *
from election_results.branch_candidates_office_state_level
where branch_race_id ilike '%ga%house%';

update election_results.branch_candidates_office_state_level
    set clarity_office = 'State House District ' || (regexp_split_to_array(branch_race_id, '-'))[array_upper(regexp_split_to_array(branch_race_id, '-'), 1)]
where branch_race_id ilike '%ga%house%'
    and clarity_office is null;

------------------------------------------------------------------------------------------------------------------------
-- Tag State Senate offices...
------------------------------------------------------------------------------------------------------------------------
select *
from election_results.branch_candidates_office_state_level
where branch_race_id ilike '%ga-senate%';

update election_results.branch_candidates_office_state_level
    set clarity_office = 'State Senate District ' || (regexp_split_to_array(branch_race_id, '-'))[array_upper(regexp_split_to_array(branch_race_id, '-'), 1)]
where branch_race_id ilike '%ga-senate%'
    and clarity_office is null;

------------------------------------------------------------------------------------------------------------------------
-- Tag US House offices...
------------------------------------------------------------------------------------------------------------------------
select *
from election_results.branch_candidates_office_state_level
where branch_race_id ilike '%us-hor%';

update election_results.branch_candidates_office_state_level
    set clarity_office = 'US House District ' || (regexp_split_to_array(branch_race_id, '-'))[array_upper(regexp_split_to_array(branch_race_id, '-'), 1)]
where branch_race_id ilike '%us-hor%'
    and clarity_office is null;

------------------------------------------------------------------------------------------------------------------------
-- Tag US Senate offices...
------------------------------------------------------------------------------------------------------------------------
select *
from election_results.branch_candidates_office_state_level
where branch_race_id ilike '%us-senate%';

update election_results.branch_candidates_office_state_level
    set clarity_office = 'US Senate'
where branch_race_id ilike '%us-senate%'
    and clarity_office is null
    and branch_race_id = 'ga-general-2020-us-senate';

update election_results.branch_candidates_office_state_level
    set clarity_office = 'US Senate (Special)'
where branch_race_id ilike '%us-senate%'
    and clarity_office is null
    and branch_race_id = 'ga-general-2020-us-senate-special';

------------------------------------------------------------------------------------------------------------------------
-- Tag PSC offices...
------------------------------------------------------------------------------------------------------------------------
select *
from election_results.branch_candidates_office_state_level
where branch_race_id ilike '%-psc-%';

update election_results.branch_candidates_office_state_level
    set clarity_office = 'Public Service Commission District ' || (regexp_split_to_array(branch_race_id, '-'))[array_upper(regexp_split_to_array(branch_race_id, '-'), 1)]
where branch_race_id ilike '%-psc-%'
    and clarity_office is null;

------------------------------------------------------------------------------------------------------------------------
-- Tag District Attorney offices...
------------------------------------------------------------------------------------------------------------------------
select *
from election_results.branch_candidates_office_state_level
where branch_race_id ilike '%-district-attorney%';

update election_results.branch_candidates_office_state_level
    set clarity_office = 'District Attorney - Atlanta'
where branch_race_id = 'ga-general-2020-ga-jud-circuit-atlanta-district-attorney'
    and clarity_office is null;

update election_results.branch_candidates_office_state_level
    set clarity_office = 'District Attorney - Gwinnett'
where branch_race_id = 'ga-general-2020-ga-jud-circuit-gwinnett-district-attorney'
    and clarity_office is null;

update election_results.branch_candidates_office_state_level
    set clarity_office = 'District Attorney - Stone Mountain'
where branch_race_id = 'ga-general-2020-ga-jud-circuit-stone-mountain-district-attorney'
    and clarity_office is null;

select distinct branch_race_id, clarity_office
from election_results.branch_candidates_office_state_level
order by clarity_office;
------------------------------------------------------------------------------------------------------------------------
-- End of tagging clarity office...
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- Tag candidate names...
------------------------------------------------------------------------------------------------------------------------
-- RESET
update election_results.branch_candidates_office_state_level
    set clarity_candidate = null;

-- PASS #1...
with clarity_names as
(
    select distinct
        candidate,
        trim(replace(candidate, ' (I)', '')) as match_candidate
    from election_results.clarity_summary
)
update election_results.branch_candidates_office_state_level as a
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
    from election_results.clarity_summary
)
update election_results.branch_candidates_office_state_level as a
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
    from election_results.clarity_summary
    where (regexp_split_to_array(candidate, ' '))[array_upper(regexp_split_to_array(replace(candidate, ' (I)', ''), ' '), 1)] not in ('Jr.', 'Jr', 'Sr.', 'Sr', 'II', 'III')
        and length(candidate) > 10
        and length((regexp_split_to_array(candidate, ' '))[1]) > 2
    order by candidate
)
update election_results.branch_candidates_office_state_level as a
    set clarity_candidate = b.candidate
from clarity_names as b
where a.clarity_candidate is null
    and upper(trim(a.branch_candidate)) = upper(trim(b.first_name) || ' ' || trim(b.last_name));

-- These will need to be fixed...
select branch_id, branch_candidate
from election_results.branch_candidates_office_state_level
where clarity_candidate is null
order by branch_candidate;
-- 38

-- MANUAL UPDATES FROM GOOGLE SHEETS...
update election_results.branch_candidates_office_state_level set clarity_candidate = 'William ""Bill"" Werkheiser (I)' where clarity_candidate is null and branch_id = 'bill-werkheiser';
update election_results.branch_candidates_office_state_level set clarity_candidate = 'Bob Trammell, Jr. (I)' where clarity_candidate is null and branch_id = 'bob-trammell';
update election_results.branch_candidates_office_state_level set clarity_candidate = 'Brian Slowinski (Lib)' where clarity_candidate is null and branch_id = 'brian-slowinski';
update election_results.branch_candidates_office_state_level set clarity_candidate = 'Lauren Bubba McDonald, Jr. (I)' where clarity_candidate is null and branch_id = 'bubba-mcdonald';
update election_results.branch_candidates_office_state_level set clarity_candidate = 'Michael ""Buckle"" Moore' where clarity_candidate is null and branch_id = 'buckle-moore';
update election_results.branch_candidates_office_state_level set clarity_candidate = 'Earl L. ""Buddy"" Carter (I)' where clarity_candidate is null and branch_id = 'buddy-carter';
update election_results.branch_candidates_office_state_level set clarity_candidate = 'Cecil T. ""Butch"" Miller (I)' where clarity_candidate is null and branch_id = 'butch-miller';
update election_results.branch_candidates_office_state_level set clarity_candidate = 'Charles E. ""Chuck"" Martin (I)' where clarity_candidate is null and branch_id = 'chuck-martin';
update election_results.branch_candidates_office_state_level set clarity_candidate = 'Daniel J. ""Danny"" Porter (I)' where clarity_candidate is null and branch_id = 'danny-porter';
update election_results.branch_candidates_office_state_level set clarity_candidate = 'David E. Lucas, Sr. (I)' where clarity_candidate is null and branch_id = 'david-lucas';
update election_results.branch_candidates_office_state_level set clarity_candidate = 'Elizabeth Melton (Lib)' where clarity_candidate is null and branch_id = 'elizabeth-melton';
update election_results.branch_candidates_office_state_level set clarity_candidate = 'Emory Dunahoo, Jr. (I)' where clarity_candidate is null and branch_id = 'emory-dunahoo';
update election_results.branch_candidates_office_state_level set clarity_candidate = 'Henry C. ""Hank"" Johnson, Jr. (I)' where clarity_candidate is null and branch_id = 'hank-johnson';
update election_results.branch_candidates_office_state_level set clarity_candidate = 'Harold V. Jones, II (I)' where clarity_candidate is null and branch_id = 'harold-jones-ii';
update election_results.branch_candidates_office_state_level set clarity_candidate = 'Jennifer ""Jen"" Jordan (I)' where clarity_candidate is null and branch_id = 'jen-jordan';
update election_results.branch_candidates_office_state_level set clarity_candidate = 'John Fortuin (Grn)' where clarity_candidate is null and branch_id = 'john-fortuin';
update election_results.branch_candidates_office_state_level set clarity_candidate = 'Lauren W. McDonald, III' where clarity_candidate is null and branch_id = 'lauren-mcdonald';
update election_results.branch_candidates_office_state_level set clarity_candidate = 'Lester G. Jackson, III (I)' where clarity_candidate is null and branch_id = 'lester-jackson-iii';
update election_results.branch_candidates_office_state_level set clarity_candidate = '""Mokah"" Jasmine Johnson' where clarity_candidate is null and branch_id = 'mokah-jasmine-johnson';
update election_results.branch_candidates_office_state_level set clarity_candidate = 'Nathan Wilson (Lib)' where clarity_candidate is null and branch_id = 'nathan-wilson';
update election_results.branch_candidates_office_state_level set clarity_candidate = 'Pedro ""Pete"" Marin (I)' where clarity_candidate is null and branch_id = 'pete-marin';
update election_results.branch_candidates_office_state_level set clarity_candidate = 'Ricky ""Rick"" Williams (I)' where clarity_candidate is null and branch_id = 'rick-williams';
update election_results.branch_candidates_office_state_level set clarity_candidate = 'Shane Hazel (Lib)' where clarity_candidate is null and branch_id = 'shane-hazel';
update election_results.branch_candidates_office_state_level set clarity_candidate = 'Sheila McNeill' where clarity_candidate is null and branch_id = 'sheila-mcneil';
update election_results.branch_candidates_office_state_level set clarity_candidate = 'Stephen M. George, Jr.' where clarity_candidate is null and branch_id = 'stephen-george';
update election_results.branch_candidates_office_state_level set clarity_candidate = 'Vance Smith, Jr. (I)' where clarity_candidate is null and branch_id = 'vance-smith';
update election_results.branch_candidates_office_state_level set clarity_candidate = 'Henry ""Wayne"" Howard (I)' where clarity_candidate is null and branch_id = 'wayne-howard';
update election_results.branch_candidates_office_state_level set clarity_candidate = 'A. Wayne Johnson' where clarity_candidate is null and branch_id = 'wayne-johnson';
update election_results.branch_candidates_office_state_level set clarity_candidate = 'William K. Boddie, Jr. (I)' where clarity_candidate is null and branch_id = 'william-boddie-jr.';

update election_results.branch_candidates_office_state_level set clarity_candidate = 'Al Bartell' where clarity_candidate is null and branch_id = 'elbert-bartell';


select distinct input_candidate, candidate
from election_results.clarity_summary
where input_candidate ilike '%Bartell%'
order by input_candidate;

-- These need further research...
select branch_id, branch_candidate, branch_race_id
from election_results.branch_candidates_office_state_level
where clarity_candidate is null
order by branch_candidate;
-- 9


select *
from election_results.branch_candidates_office_state_level;

------------------------------------------------------------------------------------------------------------------------
-- VALIDATE CANDIDATES...
------------------------------------------------------------------------------------------------------------------------
with branch as
(
    select distinct branch_id, clarity_candidate
    from election_results.branch_candidates_office_state_level
),
clarity as
(
    select distinct candidate
    from election_results.clarity_summary
)
select *
from branch as a
    left join clarity as b
        on trim(a.clarity_candidate) = trim(b.candidate)
where b.candidate is null
order by a.branch_id;

------------------------------------------------------------------------------------------------------------------------
-- VALIDATE OFFICES (AKA RACES) - STATE LEVEL...
------------------------------------------------------------------------------------------------------------------------
with branch as
(
    select distinct branch_race_id, clarity_office
    from election_results.branch_candidates_office_state_level
),
clarity as
(
    select distinct office
    from election_results.clarity_summary
)
select *
from branch as a
    left join clarity as b
        on trim(a.clarity_office) = trim(b.office)
where b.office is null
order by a.branch_race_id;

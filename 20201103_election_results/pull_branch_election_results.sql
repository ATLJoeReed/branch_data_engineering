set search_path to raw, stage, working, campaign_finance, election_results;

show search_path;

select *
from election_results.branch_candidates_office_state_level;
-- 422

-- Pull State level results...
select
    b.last_updated,
    a.branch_id,
    a.branch_race_id,
    b.candidate as clarity_candidate,
    b.office as clarity_office,
    b.votes,
    b.percent_votes
from election_results.branch_candidates_office_state_level as a
    left join election_results.clarity_summary as b
        on trim(a.clarity_candidate) = trim(b.candidate)
            and trim(a.clarity_office) = trim(b.office)
where b.office is not null
order by a.branch_race_id;
-- 414

select *
from election_results.branch_candidates_office_county_level;
-- 56

-- drop table temp_county_results;

-- Pull County level results...
create temp table temp_county_results
as
with clarity_aggregated_candidate as
(
    select
        max(a.last_updated) as last_updated,
        a.county,
        a.candidate,
        a.office,
        max(a.total_votes)::int as votes
    from stage.election_results as a
        inner join election_results.branch_candidates_office_county_level  as b
            on trim(a.office) = trim(b.clarity_office)
                and trim(a.county) = trim(b.branch_county)
    group by a.county, a.candidate, a.office
)
select
    b.last_updated,
    a.branch_id,
    a.branch_race_id,
    b.candidate as clarity_candidate,
    b.office as clarity_office,
    sum(b.votes) as votes
from election_results.branch_candidates_office_county_level as a
    inner join clarity_aggregated_candidate as b
        on trim(a.clarity_candidate) = trim(b.candidate)
            and trim(a.clarity_office) = trim(b.office)
            and trim(a.branch_county) = trim(b.county)
group by b.last_updated, a.branch_id, a.branch_race_id, b.candidate, b.office
order by a.branch_race_id;

with total_votes as
(
    select branch_race_id, sum(votes) as total_votes
    from temp_county_results
    group by branch_race_id
)
select
    a.last_updated,
    a.branch_id,
    a.branch_race_id,
    a.clarity_candidate,
    a.clarity_office,
    a.votes,
    (a.votes/nullif(b.total_votes, 0) * 100)::numeric(10,2) as percent_votes
from temp_county_results as a
    inner join total_votes as b
        on a.branch_race_id = b.branch_race_id;

select *
from temp_county_results;


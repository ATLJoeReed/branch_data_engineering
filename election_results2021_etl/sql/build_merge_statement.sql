select *
from stage.ga_general_election_2021;

-- truncate table stage.ga_general_election_2021;

update stage.ga_general_election_2021
    set total_votes = 999
where choice_name = 'Stan Watson';

update stage.ga_general_election_2021
    set results_last_updated = '2021-03-15 18:05:04.000000';

insert into election_results.ga_general_election_2021
    (office, candidate, party, total_votes, percent_votes, num_precinct_total,
    num_precinct_reporting, over_vote, under_vote, results_last_updated)
select
    contest_name as office,
    choice_name as candidate,
    party_name as party,
    total_votes,
    percent_votes,
    num_precinct_total,
    num_precinct_reporting,
    over_vote,
    under_vote,
    results_last_updated
from stage.ga_general_election_2021
on conflict on constraint ga_general_election_2021_pkey
do
    update
        set total_votes = excluded.total_votes,
            percent_votes = excluded.percent_votes,
            num_precinct_total = excluded.num_precinct_total,
            num_precinct_reporting = excluded.num_precinct_reporting,
            over_vote = excluded.over_vote,
            under_vote = excluded.under_vote,
            results_last_updated = excluded.results_last_updated,
            updated_ymd = now()
    where election_results.ga_general_election_2021.results_last_updated != excluded.results_last_updated;

select *
from election_results.ga_general_election_2021;

update election_results.ga_general_election_2021
    set percent_votes = 99.99
where candidate = 'Stan Watson';

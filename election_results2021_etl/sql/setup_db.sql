create schema stage;

create table stage.ga_general_election_2021 (
    last_updated timestamp,
    line_number int,
    contest_name text,
    choice_name text,
    party_name text,
    total_votes int,
    percent_of_votes numeric (10, 2),
    num_precinct_total int,
    num_precinct_reporting int,
    over_vote int,
    under_vote int,
);

create schema election_results;

create table election_results.ga_general_election_2021 (
    office text,
    candidate text,
    party text,
    total_votes int,
    percent_votes numeric (10, 2),
    num_precinct_total int,
    num_precinct_reporting int,
    over_vote int,
    under_vote int,
    results_last_updated timestamp,
	created_ymd timestamp default now(),
	updated_ymd timestamp default now()
);

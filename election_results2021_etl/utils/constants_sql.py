#!/usr/bin/python3.9
# -*- coding: utf-8 -*-
INSERT_STAGE_ELECTION_RESULTS_SQL = """
insert into stage.ga_general_election_2021 (results_last_updated, line_number, 
    contest_name, choice_name, party_name, total_votes, percent_votes, 
    num_precinct_total, num_precinct_reporting, over_vote, under_vote)
values (%(results_last_updated)s, %(line_number)s,
    %(contest_name)s, %(choice_name)s, %(party_name)s, %(total_votes)s, %(percent_votes)s,
    %(num_precinct_total)s, %(num_precinct_reporting)s, %(over_vote)s, %(under_vote)s);
""" # noqa

MERGE_ELECTION_RESULTS_SQL = """
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
""" # noqa

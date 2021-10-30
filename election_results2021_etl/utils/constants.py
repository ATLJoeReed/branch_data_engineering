#!/usr/bin/python3.9
# -*- coding: utf-8 -*-
COLUMN_RENAMES = {
    'line number': 'line_number',
    'contest name': 'contest_name',
    'choice name': 'choice_name',
    'party name': 'party_name',
    'total votes': 'total_votes',
    'percent of votes': 'percent_votes',
    'num Precinct total': 'num_precinct_total',
    'num Precinct rptg': 'num_precinct_reporting',
    'over votes': 'over_vote',
    'under votes': 'under_vote',
}

SUMMARY_CSV_URL = 'https://results.enr.clarityelections.com//GA//108418/275859/reports/summary.zip' # noqa

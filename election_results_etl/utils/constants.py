#!/usr/bin/python3.8
# -*- coding: utf-8 -*-
BRANCH_CANDIDATE_OFFICES = [
    {
        'branch_id': 'linda-pritchett',
        'branch_candidate': 'Linda Pritchett',
        'branch_race_id': 'ga-general-runoff-2020-ga-senate-39',
        'clarity_candidate': 'Linda Pritchett (DEM)',
        'clarity_office': 'State Senate District 39 - Special Democratic Primary'
    },
    {
        'branch_id': 'sonya-halpern',
        'branch_candidate': 'Sonya Halpern',
        'branch_race_id': 'ga-general-runoff-2020-ga-senate-39',
        'clarity_candidate': 'Sonya Halpern (DEM)',
        'clarity_office': 'State Senate District 39 - Special Democratic Primary'
    },
    {
        'branch_id': 'kwanza-hall',
        'branch_candidate': 'Kwanza Hall',
        'branch_race_id': 'ga-special-2020-us-house-5',
        'clarity_candidate': 'Kwanza Hall',
        'clarity_office': 'US House District 5'
    },
    {
        'branch_id': 'robert-franklin',
        'branch_candidate': 'Robert Franklin',
        'branch_race_id': 'ga-special-2020-us-house-5',
        'clarity_candidate': 'Robert Franklin',
        'clarity_office': 'US House District 5'
    },
]

COLUMN_RENAMES = {
    "contest name": "clarity_office",
    "choice name": "clarity_candidate",
    "total votes": "votes",
    "percent of votes": "percent_votes",
}

OUTPUT_COLUMNS = [
    'last_updated',
    'branch_id',
    'branch_race_id',
    'clarity_candidate',
    'clarity_office',
    'votes',
    'percent_votes'
]

SUMMARY_CSV_URL = 'https://results.enr.clarityelections.com//GA//107395/272627/reports/summary.zip' # noqa

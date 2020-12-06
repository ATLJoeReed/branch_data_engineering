#!/usr/bin/python3.8
# -*- coding: utf-8 -*-
import io
import logging
import sys
import zipfile

import requests

from utils import constants, settings


def extract_last_updated(content, logger):
    try:
        m = content.infolist()[0].date_time
    except Exception as e:
        logger.error(f'Extracting last updated: {e}')
        return None
    return f'{m[0]}-{m[1]}-{m[2]} {m[3]}:{m[4]}:{m[5]}.000000'


def extract_csv(df):
    election_results_csv = io.StringIO()
    df.to_csv(
        election_results_csv,
        columns=constants.OUTPUT_COLUMNS,
        header=True,
        index=False
    )
    return election_results_csv


def fetch_summary_results(logger):
    url = constants.SUMMARY_CSV_URL
    r = requests.get(url)
    if r.status_code == 200:
        return zipfile.ZipFile(io.BytesIO(r.content))
    else:
        logger.error(f'Summary requst - status code: {r.status_code}')
        return None


def get_branch_token(logger):
    url = settings.BRANCH_URL_AUTH
    headers = {"Content-Type": "application/json"}
    data = {
        "email": settings.BRANCH_EMAIL,
        "password": settings.BRANCH_PASSWORD,
        "strategy": settings.BRANCH_STRATEGY,
    }
    r = requests.post(url, json=data, headers=headers)
    if r.status_code == 201:
        return r.json().get('accessToken')
    else:
        logger.error(f'Get Branch token - status code: {r.status_code}')
        return None


def push_results_branch(election_results_csv, token, logger):
    url = settings.BRANCH_URL
    headers = {'Authorization': token}
    files = {'file': election_results_csv.getvalue()}
    r = requests.post(url, files=files, headers=headers)
    if r.status_code == 201:
        return r.json().get('location')
    else:
        logger.error(f'Push results to Branch - status code: {r.status_code}')
        return None
    return


def setup_logger_stdout(logger_name):
    logger = logging.getLogger(logger_name)
    logger.setLevel(logging.DEBUG)
    ch = logging.StreamHandler(sys.stdout)
    formatter = logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )
    ch.setFormatter(formatter)
    logger.addHandler(ch)
    return logger


def transform_dataframe(summary_results):
    column_rename = constants.COLUMN_RENAMES
    summary_results.rename(columns=column_rename, inplace=True)
    summary_results.drop(
        columns=['line number', 'party name', 'num Precinct total', 'num Precinct rptg', 'over votes', 'under votes'], # noqa
        inplace=True
    )
    return summary_results

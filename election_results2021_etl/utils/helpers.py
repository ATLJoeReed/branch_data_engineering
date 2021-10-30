#!/usr/bin/python3.9
# -*- coding: utf-8 -*-
import io
import logging
import sys
import zipfile

import psycopg2
import requests

from utils import constants, constants_sql, settings


def extract_last_updated(content, logger):
    try:
        m = content.infolist()[0].date_time
    except Exception as e:
        logger.error(f'Extracting last updated: {e}')
        return None
    return f'{m[0]}-{str(m[1]).zfill(2)}-{str(m[2]).zfill(2)} {str(m[3]).zfill(2)}:{str(m[4]).zfill(2)}:{str(m[5]).zfill(2)}.000000' # noqa


def fetch_summary_results(logger):
    url = constants.SUMMARY_CSV_URL
    r = requests.get(url)
    if r.status_code == 200:
        return zipfile.ZipFile(io.BytesIO(r.content))
    else:
        logger.error(f'Summary requst - status code: {r.status_code}')
        return None


def get_database_connection():
    return psycopg2.connect(**settings.DB_CONN)


def load_summary_results(conn, summary_results, logger):
    # Convert dataframe to list of dictionaries...
    data = summary_results.to_dict('records')
    # Clear out stage table...
    conn.cursor().execute('truncate table stage.ga_general_election_2021;')
    logger.info('Inserting summary results into stage table')
    conn.cursor().executemany(constants_sql.INSERT_STAGE_ELECTION_RESULTS_SQL, data) # noqa
    logger.info('Merging summary results into election results table')
    conn.cursor().execute(constants_sql.MERGE_ELECTION_RESULTS_SQL)


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
    return summary_results

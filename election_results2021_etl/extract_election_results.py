#!/usr/bin/python3.9
# -*- coding: utf-8 -*-
import io
import os
import sys

import pandas as pd

from utils import helpers


def extract_election_results(logger):
    logger.info('Starting to extract election summary results')

    try:
        conn = helpers.get_database_connection()
        conn.set_session(autocommit=True)
    except Exception as e:
        logger.error(f"Getting database connection: {e}")
        sys.exit("Unable to get database connection")

    logger.info('Fetching summary results file from clarityelections.com')
    content = helpers.fetch_summary_results(logger)
    last_updated = helpers.extract_last_updated(content, logger)
    logger.info(f'Summary results last updated: {last_updated}')

    logger.info('Building summary results dataframe')
    summary_results = pd.read_csv(io.BytesIO(
        content.read('summary.csv')),
        encoding='latin1'
    )
    summary_results = helpers.transform_dataframe(summary_results)
    # Tag summary results last updated timestamp...
    summary_results.insert(0, 'results_last_updated', last_updated)
    helpers.load_summary_results(conn, summary_results,  logger)
    conn.close()


if __name__ == '__main__':
    # move to working directory...
    abspath = os.path.abspath(__file__)
    dname = os.path.dirname(abspath)
    os.chdir(dname)

    logger = helpers.setup_logger_stdout('extract_election_results')

    extract_election_results(logger)

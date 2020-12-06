#!/usr/bin/python3.8
# -*- coding: utf-8 -*-
import io
import os

import pandas as pd

from utils import constants, helpers


def extract_election_results(logger):
    logger.info('Starting to extract election results')

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

    logger.info('Building Branch candidate/office information')
    branch_info = pd.DataFrame(constants.BRANCH_CANDIDATE_OFFICES)

    logger.info('Merging election results with Branch info')
    merged_results = pd.merge(
        branch_info,
        summary_results,
        on=['clarity_candidate', 'clarity_office'],
        how='inner'
    )
    logger.info('Adding last_updated column')
    merged_results.insert(0, 'last_updated', last_updated)

    logger.info('Extracting csv from merge results')
    election_results_csv = helpers.extract_csv(merged_results)

    logger.info('Push results to Branch API')
    token = helpers.get_branch_token(logger)
    results = helpers.push_results_branch(election_results_csv, token, logger)
    logger.info(f'File {results} pushed to Branch API')


if __name__ == '__main__':
    # move to working directory...
    abspath = os.path.abspath(__file__)
    dname = os.path.dirname(abspath)
    os.chdir(dname)

    logger = helpers.setup_logger_stdout('extract_election_results')

    extract_election_results(logger)

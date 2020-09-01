import csv
import logging
import os
import sys
import yaml
import tempfile

from time import time
from typing import Dict, List, Generator, Any, Tuple

from gitlabdata.orchestration_utils import (
    dataframe_uploader,
    dataframe_enricher,
    snowflake_engine_factory,
    query_executor,
)
import pandas as pd
import sqlalchemy
from google.cloud import storage
from google.cloud.storage.bucket import Bucket
from google.oauth2 import service_account
from sqlalchemy import create_engine
from sqlalchemy.engine.base import Engine

SCHEMA = "tap_postgres"


def get_gcs_bucket(gapi_keyfile: str, bucket_name: str) -> Bucket:
    """ Do the auth and return a usable gcs bucket object."""

    scope = ["https://www.googleapis.com/auth/cloud-platform"]
    credentials = service_account.Credentials.from_service_account_info(gapi_keyfile)
    scoped_credentials = credentials.with_scopes(scope)
    storage_client = storage.Client(credentials=scoped_credentials)
    return storage_client.get_bucket(bucket_name)


def upload_to_gcs(
    advanced_metadata: bool, upload_df: pd.DataFrame, upload_file_name: str
) -> bool:
    """
    Write a dataframe to local storage and then upload it to a GCS bucket.
    """

    keyfile = yaml.load(os.environ["GCP_SERVICE_CREDS"], Loader=yaml.FullLoader)
    bucket_name = "postgres_pipeline"
    bucket = get_gcs_bucket(keyfile, bucket_name)
    logging.info(bucket)
    # Write out the TSV and upload it

    enriched_df = dataframe_enricher(advanced_metadata, upload_df)
    logging.info(enriched_df.head(5))
    enriched_df.to_csv(
        upload_file_name,
        compression="gzip",
        escapechar="\\",
        index=False,
        quoting=csv.QUOTE_NONE,
        sep="\t",
    )
    logging.info("Written successfully")
    blob = bucket.blob(upload_file_name)
    blob.upload_from_filename(upload_file_name)

    return True


def trigger_snowflake_upload(
    engine: Engine, table: str, upload_file_name: str, purge: bool = False
) -> None:
    """ Trigger Snowflake to upload a tsv file from GCS."""

    purge_opt = "purge = true" if purge else ""

    upload_query = f"""
        copy into {table}
        from 'gcs://postgres_pipeline'
        storage_integration = gcs_integration
        pattern = '{upload_file_name}'
        {purge_opt}
        force = TRUE
        file_format = (
            type = csv
            field_delimiter = '\\\\t'
            skip_header = 1
        );
    """
    results = query_executor(engine, upload_query)
    log_result = f"Loaded {results[0][2]} rows from file: {results[0][0]}"
    logging.info(log_result)


def postgres_engine_factory(
    connection_dict: Dict[str, str], env: Dict[str, str]
) -> Engine:
    """
    Create a postgres engine to be used by pandas.
    """

    # Set the Vars
    user = env[connection_dict["user"]]
    password = env[connection_dict["pass"]]
    host = env[connection_dict["host"]]
    database = env[connection_dict["database"]]
    port = env[connection_dict["port"]]

    # Inject the values to create the engine
    engine = create_engine(
        f"postgresql://{user}:{password}@{host}:{port}/{database}",
        connect_args={"sslcompression": 0},
    )
    logging.info(engine)
    return engine


def manifest_reader(file_path: str) -> Dict[str, Dict]:
    """
    Read a yaml manifest file into a dictionary and return it.
    """

    with open(file_path, "r") as file:
        manifest_dict = yaml.load(file, Loader=yaml.FullLoader)

    return manifest_dict

def read_sql_tmpfile(query, db_engine, tmp_file):
    copy_sql = f"COPY ({query}) TO STDOUT WITH CSV HEADER"
    logging.info(f" running COPY ({query}) TO STDOUT WITH CSV HEADER")
    conn = db_engine.raw_connection()
    cur = conn.cursor()
    cur.copy_expert(copy_sql, tmp_file)
    tmp_file.seek(0)
    logging.info("Reading csv")
    df = pd.read_csv(tmp_file, chunksize=1_000_000, parse_dates=True, low_memory=False)
    logging.info("CSV read")
    return df

def query_results_generator(
    query: str, engine: Engine, chunksize: int = 100_000
) -> pd.DataFrame:
    """
    Use pandas to run a sql query and load it into a dataframe.
    Yield it back in chunks for scalability.
    """

    try:
        query_df_iterator = pd.read_sql(sql=query, con=engine, chunksize=chunksize)

    except Exception as e:
        logging.exception(e)
        sys.exit(1)
    return query_df_iterator

def df_data_type_reader(
    query: str, engine: Engine
) -> pd.DataFrame:
    """
    Bit of a silly fix for a data type issue when creating csvs rather than using the pd read sql
    Need the pd read sql meta data to create the table with the correct types, this is a much cheaper
    option than reading in the whole csv.
    """

    try:
        query = query + ' LIMIT 100000'
        logging.info(query)
        csv_data_type_df = pd.read_sql(sql=query, con=engine)
        logging.info(csv_data_type_df)
        logging.info(type(csv_data_type_df))
    except Exception as e:
        logging.exception(e)
        sys.exit(1)
    return csv_data_type_df

def seed_table(
    advanced_metadata: bool,
    df: pd.DataFrame,
    engine: Engine,
    table: str,
    rows_to_seed: int = 10000,
    data_types : dict = None,
) -> bool:
    """
    Load a set number of rows to Snowflake through pandas to create the table
    and set the proper data types and column names.
    """

    logging.info(f"Seeding {rows_to_seed} rows directly into Snowflake...")
    if dataframe_enricher(advanced_metadata, df.iloc[:rows_to_seed]).to_sql(
            name=table,
            con=engine,
            index=False,
            if_exists="replace",
            chunksize=10000,
            dtype=data_types,
    ):
        return True
    else:
        return False


def chunk_and_upload(
    query: str,
    source_engine: Engine,
    target_engine: Engine,
    target_table: str,
    advanced_metadata: bool = False,
    backfill: bool = False,
    data_types: dict = None,
) -> None:
    """
    Call the functions that upload the dataframes as TSVs in GCS and then trigger Snowflake
    to load those new files.

    If it is part of a backfill, the first chunk gets sent to the dataframe_uploader
    so that the table can be created automagically with the correct data types.

    Each chunk is uploaded to GCS with a suffix of which chunk number it is.
    All of the chunks are uploaded by using a regex that gets all of the files.
    """

    rows_uploaded = 0
    get_db_metadata
    type_df = df_data_type_reader(query, source_engine)
    logging.info(type_df.info())

    with tempfile.TemporaryFile() as tmpfile:

        iter_csv = read_sql_tmpfile(query, source_engine, tmpfile)

        for idx, chunk_df in enumerate(iter_csv):
            type_df = type_df.drop(type_df.index)

            logging.info(type_df.info())

            type_df = type_df.append(chunk_df)
            if backfill:
                seed_table(
                        advanced_metadata,
                        type_df,
                        target_engine,
                        target_table,
                        rows_to_seed=1,
                        data_types=data_types
                )
                backfill = False

            upload_file_name = f"{target_table}_CHUNK.tsv.gz"

            rows_uploaded += len(chunk_df)

            logging.info("Uploading to GCS")
            upload_to_gcs(
                    advanced_metadata, type_df, upload_file_name + "." + str(idx)
            )
            logging.info("Uploading to SF")
            trigger_snowflake_upload(
                    target_engine, target_table, upload_file_name + "[.]\\\\d*", purge=True
            )
            logging.info("Uploaded to ssf")
            logging.info(
                    f"Uploaded {rows_uploaded} total rows to table {target_table}."
            )

    target_engine.dispose()
    source_engine.dispose()




def range_generator(
    start: int, stop: int, step: int = 100_000
) -> Generator[Tuple[int, ...], None, None]:
    """
    Yields a list that contains the starting and ending number for a given window.
    """

    while True:
        if start > stop:
            break
        else:
            yield tuple([start, start + step])
        start += step


def check_if_schema_changed(
    raw_query: str,
    source_engine: Engine,
    source_table: str,
    table_index: str,
    target_engine: Engine,
    target_table: str,
) -> bool:
    """
    Query the source table with the manifest query to get the columns, then check
    what columns currently exist in the DW. Return a bool depending on whether
    there has been a change or not.

    If the table does not exist this function will also return True.
    """

    if not target_engine.has_table(target_table):
        return True
    # Get the columns from the current query
    query_stem = raw_query.lower().split("where")[0]
    source_query = "{0} where {1} = (select max({1}) from {2}) limit 1"
    source_columns = pd.read_sql(
        sql=source_query.format(query_stem, table_index, source_table),
        con=source_engine,
    ).columns

    # Get the columns from the target_table
    target_query = "select * from {0} where {1} = (select max({1}) from {0}) limit 1"
    target_columns = (
        pd.read_sql(
            sql=target_query.format(target_table, table_index), con=target_engine
        )
        .drop(axis=1, columns=["_uploaded_at", "_task_instance"], errors="ignore")
        .columns
    )

    return set(source_columns) != set(target_columns)


def id_query_generator(
    postgres_engine: Engine,
    primary_key: str,
    raw_query: str,
    snowflake_engine: Engine,
    source_table: str,
    target_table: str,
    id_range: int = 100_000,
) -> Generator[str, Any, None]:
    """
    This function generates a list of queries based on the max ID in the target table.

    Gets the diff between the IDs that exist in the DB vs the DW, generates queries for any rows
    with IDs that are missing from the DW.

    i.e. if the table in Snowflake has a max id of 2000, but postgres has a max id of 5000,
    it will return a list of queries that load chunks of IDs until it has the same max id.
    """

    # Get the max ID from the target DB
    logging.info(f"Getting max primary key from target_table: {target_table}")
    max_target_id_query = f"SELECT MAX({primary_key}) as id FROM {target_table}"
    # If the table doesn't exist it will throw an error, ignore it and set a default ID
    if snowflake_engine.has_table(target_table):
        max_target_id_results = query_results_generator(
            max_target_id_query, snowflake_engine
        )
        # Grab the max primary key, or if the table is empty default to 0
        max_target_id = next(max_target_id_results)[primary_key].tolist()[0] or 0
    else:
        max_target_id = 0
    logging.info(f"Target Max ID: {max_target_id}")

    # Get the max ID from the source DB
    logging.info(f"Getting max ID from source_table: {source_table}")
    max_source_id_query = (
        f"SELECT MAX({primary_key}) as {primary_key} FROM {source_table}"
    )
    try:
        max_source_id_results = query_results_generator(
            max_source_id_query, postgres_engine
        )
        max_source_id = next(max_source_id_results)[primary_key].tolist()[0]
    except sqlalchemy.exc.ProgrammingError as e:
        logging.exception(e)
        sys.exit(1)
    logging.info(f"Source Max ID: {max_source_id}")

    # Get the min ID from the source DB
    logging.info(f"Getting min ID from source_table: {source_table}")
    min_source_id_query = (
        f"SELECT MIN({primary_key}) as {primary_key} FROM {source_table}"
    )
    try:
        min_source_id_results = query_results_generator(
            min_source_id_query, postgres_engine
        )
        min_source_id = next(min_source_id_results)[primary_key].tolist()[0]
    except sqlalchemy.exc.ProgrammingError as e:
        logging.exception(e)
        sys.exit(1)
    logging.info(f"Source Min ID: {min_source_id}")

    # Generate the range pairs based on the max source id and the
    # greatest of either the min_source_id or the max_target_id
    for id_pair in range_generator(
        max(max_target_id, min_source_id), max_source_id, step=id_range
    ):
        id_range_query = (
            "".join(raw_query.lower().split("where")[0])
            + f"WHERE {primary_key} BETWEEN {id_pair[0]} AND {id_pair[1]}"
        )
        logging.info(f"ID Range: {id_pair}")
        yield id_range_query

def get_db_metadata(
    source_engine: Engine,
    source_table: str,
    table_index: str,
    target_engine: Engine,
    target_table: str,):
    query = f"SELECT * FROM information_schema.columns " \
            f"WHERE table_name = '{source_table}'"
    df = pd.read_sql(sql=query, con=source_engine)
    logging.info(df[["table_name","column_name", "data_type"]])
    return df[["table_name","column_name", "data_type"]]

def get_engines(connection_dict: Dict[str, str]) -> Tuple[Engine, Engine]:
    """
    Generates Snowflake and Postgres engines from env vars and returns them.
    """

    logging.info("Creating database engines...")
    env = os.environ.copy()
    postgres_engine = postgres_engine_factory(connection_dict, env)
    snowflake_engine = snowflake_engine_factory(env, "LOADER", SCHEMA)
    return postgres_engine, snowflake_engine

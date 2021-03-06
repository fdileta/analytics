import logging
from typing import Dict, Any

from sqlalchemy.engine.base import Engine

import load_functions
from utils import check_if_schema_changed


class PostgresPipelineTable:
    def __init__(self, table_config: Dict[str, str]):
        self.query = table_config["import_query"]
        self.import_db = table_config["import_db"]
        self.source_table_name = table_config["export_table"]
        self.source_table_primary_key = table_config["export_table_primary_key"]
        if "additional_filtering" in table_config:
            self.additional_filtering = table_config["additional_filtering"]
        self.advanced_metadata = ("advanced_metadata" in table_config) and table_config[
            "advanced_metadata"
        ] == "true"
        self.target_table_name = "{import_db}_{export_table}".format(
            **table_config
        ).upper()
        self.table_dict = table_config

    def is_scd(self) -> bool:
        return not self.is_incremental()

    def do_scd(
        self, source_engine: Engine, target_engine: Engine, use_temp_table: bool
    ) -> bool:
        if not self.is_scd():
            return True
        target_table = (
            self.get_temp_target_table_name()
            if use_temp_table
            else self.get_target_table_name()
        )
        return load_functions.load_scd(
            source_engine,
            target_engine,
            self.source_table_name,
            self.table_dict,
            target_table,
        )

    def is_incremental(self) -> bool:
        return "{EXECUTION_DATE}" in self.query

    def do_incremental(
        self, source_engine: Engine, target_engine: Engine, use_temp_table: bool
    ) -> bool:
        if not self.needs_incremental_backfill(source_engine, target_engine):
            return False
        target_table = (
            self.get_temp_target_table_name()
            if use_temp_table
            else self.get_target_table_name()
        )
        return load_functions.load_incremental(
            source_engine,
            target_engine,
            self.source_table_name,
            self.table_dict,
            target_table,
        )

    def needs_incremental_backfill(
        self, source_engine: Engine, target_engine: Engine
    ) -> bool:
        """
        Temporary logic for now
        """
        return self.is_incremental()

    def do_incremental_backfill(
        self, source_engine: Engine, target_engine: Engine, use_temp_table: bool
    ) -> bool:
        if not self.is_incremental():
            return False
        target_table = (
            self.get_temp_target_table_name()
            if use_temp_table
            else self.get_target_table_name()
        )
        return load_functions.sync_incremental_ids(
            source_engine,
            target_engine,
            self.source_table_name,
            self.table_dict,
            target_table,
        )

    def check_new_table(
        self, source_engine: Engine, target_engine: Engine, use_temp_table: bool
    ) -> bool:
        target_table = (
            self.get_temp_target_table_name()
            if use_temp_table
            else self.get_target_table_name()
        )
        return load_functions.check_new_tables(
            source_engine,
            target_engine,
            self.source_table_name,
            self.table_dict,
            target_table,
        )

    def do_load(
        self,
        load_type: str,
        source_engine: Engine,
        target_engine: Engine,
        use_temp_table: bool,
    ) -> bool:
        load_types = {
            "incremental": self.do_incremental,
            "scd": self.do_scd,
            "backfill": self.do_incremental_backfill,
            "test": self.check_new_table,
        }
        return load_types[load_type](source_engine, target_engine, use_temp_table)

    def check_if_schema_changed(
        self, source_engine: Engine, target_engine: Engine
    ) -> bool:
        schema_changed = check_if_schema_changed(
            self.query,
            source_engine,
            self.source_table_name,
            self.source_table_primary_key,
            target_engine,
            self.target_table_name,
        )
        if schema_changed:
            logging.info(f"Schema has changed for table: {self.target_table_name}.")
        return schema_changed

    def get_target_table_name(self):
        return self.target_table_name

    def get_temp_target_table_name(self):
        return self.get_target_table_name() + "_TEMP"

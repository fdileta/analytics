from orchestration.drop_snowflake_objects import get_list_of_dbs_to_keep


def test_dbs_to_keep():
    dbs_to_keep = get_list_of_dbs_to_keep()
    assert "analytics" in dbs_to_keep
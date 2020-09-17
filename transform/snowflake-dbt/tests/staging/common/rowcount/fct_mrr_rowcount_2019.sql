{{ config({
    "tags": ["tdf","common", "mrr"]
    })
}}

{{ model_rowcount('fct_mrr',
    137493,
    "DATE_ID > 20190101 and DATE_ID <= 20200101") }}

{{ config({
    "tags": ["tdf","zuora"]
    })
}}

{{ source_rowcount('zuora', 'account', 26000) }}

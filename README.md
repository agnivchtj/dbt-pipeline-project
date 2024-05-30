# Building an ETL pipeline with DBT Core and Snowflake

In this project we are building a ETL pipeline using DBT and Snowflake. The main objective is to load data from a source (i.e. TPCH_SF1 dataset) from Snowflake and perform some basic data modeling techniques, such as building data marts, fact tables, macros and tests.

## Project setup

The following schema ```dbt_schema``` was set up in a worksheet in Snowflake and under database ```dbt_database```:
```
%%initializing resources
use role accountadmin;

create warehouse dbt_warehouse with warehouse_size='x-small';
create database dbt_database;
create role dbt_role;

show grants on warehouse dbt_warehouse;

grant usage on warehouse dbt_warehouse to role dbt_role;
grant all on database dbt_database to role dbt_role;
grant role dbt_role to user agnivchtj;

use role dbt_role;

create schema dbt_database.dbt_schema;
```
To run the project with DBT we run ```dbt init``` and enter details such as project name (```data_pl```) and Snowflake account identifier as well as the names for the role, warehouse, database and schema we have created.
Once authentication is successfully done we can make changes within DBT and these are then reflected in ```dbt_schema``` on Snowflake (as tables, views).

In our ```dbt_project.yml``` file we instruct DBT to build all source tables as views in staging folder, while tables derived these are saved as marts:
```
models:
  data_pl:
    # Config indicated by + and applies to all files under models/*/
    staging:
      +materialized: view
      snowflake_warehouse: dbt_warehouse
    marts:
      +materialized: table
      snowflake_warehouse: dbt_warehouse
```

Then, we specify the data sources that we are using (in ```models/staging/tpch_sources.yml```) and provide details such as name, database, schema and the tables:
```
version: 2
sources:
  - name: tpch
    database: snowflake_sample_data
    schema: tpch_sf1
    tables:
      - name: orders
        columns:
          - name: o_orderkey
            tests:
              - unique
              - not_null
      - name: lineitem
        columns:
          - name: l_orderkey
            tests:
              - relationships:
                  to: source('tpch', 'orders')
                  field: o_orderkey
```

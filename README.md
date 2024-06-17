# Building an ELT pipeline with DBT Core and Snowflake

In this project we are building a ELT pipeline using DBT and Snowflake. The main objective is to load data from a source (i.e. TPCH_SF1 dataset) from Snowflake and perform some basic data modelling techniques, such as building data marts, fact tables, macros and tests.

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

In our ```dbt_project.yml``` file we instruct DBT to build all source tables in staging folder as views in Snowflake, while tables derived from these are saved as marts:
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
## Setting up sources

Within the sample data in Snowflake, there are 2 tables that we make use of: ```orders``` and ```lineitem```. These tables are specified as our source, where column 'l_orderkey' (in ```lineitem``` table) is a foreign key in the ```orders``` table. Using the source, we can create source tables that contain the fields desired.

For ```orders```, we create a source table including fields such as 'o_orderkey', 'o_custkey', 'o_orderstatus', 'o_totalprice' etc. For ```lineitem```, we create a source table comprising fields such as 'l_orderkey', 'l_linenumber', 'l_partkey', 'l_suppkey', 'l_extendedprice', 'l_discount' etc. These can be found in the ```models/staging/``` folder.

These models can be run and become visible as views in Snowflake:
```
dbt run -s staging_tpch_orders
dbt run -s staging_tpch_line_items
```

## Applying business transformations to staging tables

Using the staging tables as reference, we can apply transformations to the data and format it such that it conveys something for business use. In dimensional modeling, these are referred to as 'fact tables'. 

For example, ```int_order_items.sql``` provides an overview of line items for orders with the discounted price computed. The latter calculation can be found as a function in the ```macros``` folder. ```int_order_items_summary.sql``` then uses that fact table as reference to provide a total summary of prices for orders.

## Writing tests

In dbt, there are two ways of defining tests:
- A *singular* test is testing in its simplest form, where you test for a single use case: so for example, writing a SQL query that returns failing rows.
- A *generic* test is a parameterized query that accepts arguments, and is defined in a special block (like a macro function). It can be referenced later for models, columns, sources, snapshots etc.

We wrote tests to check for the following conditions:
- **Discounts are valid**: this is by verifying that there are no rows with total price lower than the discounted price.
- **Valid order date**: this verifies there are no rows where order date is either in the future or before 1990.

Singular tests can be run simply with the ```dbt test``` command.

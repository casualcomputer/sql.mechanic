Summarizing large tables with SQL
================
Henry Luan

## Overview

The helper function `get_summary_codes` in the `sql.mechanic` package
takes in a string that specifies a table’s database name, schema name,
and table name. It outputs an SQL query that summarizes the table’s
column statistics. If you need a quick solution, jump to **Example 2**.

## Intended User

- If you work with tables inside databases hosted on powerful servers
  (usually on-premise) but have limited compute resources (e.g. RAM,
  GPU, CPU) for advanced BI (e.g. Python, R, SAS, etc.)

- If it’s much cheaper for you to use database servers than analytics
  servers (e.g. those for Python, R, etc.) either on-premise or on the
  cloud.

## Limitations

- You should test the CPU and disk usage of your database server using
  some simple test cases constructed based on **Example 2**.

- Currently, the function only works with Microsoft SQL Server and
  Netezza databases. Feel free to contribute to the codes, if
  interested.

## Example 1: Generate SQL queries and execute them in DMBS

### \* Step 1: Install packages

You can install the library from my GitHub. If you have concerns
regarding the package’s security, you can download, check, and use the
`get_summary_codes.R` file directly.

``` r
# Install package
  library(devtools)
  install_github("casualcomputer/sql.mechanic",quiet=TRUE)

# Alternative: use the 'get_summary_codes.R' file only
  # source("get_summary_codes.R")
```

### \* Step 2: Generate SQL quires

The following codes 1) **generate** the SQL queries you need to
summarize a table, and 2) **copy** (Ctrl+C) the codes to your clipboard.
All you have to do is paste it to your SQL editor and execute the
queries.

``` r
library(sql.mechanic)

#SQL codes for basic summary, Netezza database 
    sql_basic_netezza = get_summary_codes("DB_NAME.SCHEMA_NAME.TABLE_NAME", type="basic", dbtype="Netezza")   
    
#SQL codes for advanced summary, Netezza database 
    sql_advanced_netezza = get_summary_codes("DB_NAME.SCHEMA_NAME.TABLE_NAME", type="advanced", dbtype="Netezza")   
    
#SQL codes for basic summary, Microsoft SQL Server 
    sql_basic_mssql = get_summary_codes("DB_NAME.SCHEMA_NAME.TABLE_NAME", type="basic", dbtype="MSSQL")  

#SQL codes for advanced summary, Microsoft SQL Server
    sql_advanced_mssql = get_summary_codes("DB_NAME.SCHEMA_NAME.TABLE_NAME", type="advanced", dbtype="MSSQL")  
    
#copy some of the sql queries to the clipboard    
    writeClipboard(sql_basic_netezza) 
```

### \* Step 3: Paste the codes in your clipboard and run it in SQL

### \* Step 4: Copy, paste and execute the SQL queries from Step 3.

## Example 2: Automatically summarize tables in your databases

This example shows you how you can achieve everything you did in Example
1 with a few lines of R codes.

``` r
library(odbc)
library(DBI)

# Method 1: prompting user (you need to make changes)
con <- dbConnect(odbc(),
                 Driver = "SQL Server",
                 Server = "mysqlhost",
                 Database = "mydbname",
                 UID = "myuser",
                 PWD = "Database password",
                 Port = 1433, encoding = 'windows-1252') #'windows-1252' allows French to display properly

# Alternative Method: Using a DSN
#con <- dbConnect(odbc::odbc(), "DNS_NAMES", encoding = 'windows-1252')

sql_query = get_summary_codes("DB_NAME.SCHEMA_NAME.TABLE_NAME", type="basic", dbtype="Netezza") 

res = dbSendQuery(con, sql_query) # part of Step 3 in "Example 1"
sql_query_mod = dbFetch(res) # part of Step 3 in "Example 1"

res = dbSendQuery(con, sql_query_mod) # part of Step 4 in "Example 1"
output_table = dbFetch(res) # part of Step 4 in "Example 1"
print(output) #desired summary table

dbDisconnect(con) #close database connection
```

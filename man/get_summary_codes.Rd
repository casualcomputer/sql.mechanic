\name{get_summary_codes}
\alias{get_summary_codes}
\title{Generate SQL summary in various DBMS}
\description{
This function takes a character string as an argument and returns a character string that stores SQL scripts that generate detailed table summaries of the table corresponding to target_path. The outputs of the function are automatically copied to the clipboard, which can then be run in the interface of various database management systems (e.g. Netezza, Microsoft SQL Server, DB2, etc.).
}

\usage{
get_summary_codes(target_path, show_codes=FALSE, type="basic", dbtype="Netezza")
}

\arguments{
\item{target_path}{character string: location of the table, i.e., "database_name.schema_name.table_name"}
\item{show_codes}{Boolean value, which is either TRUE or FALSE}
\item{type}{character string: exact matching to one of c("basic", "advanced")}
\item{dbtype}{character string: exact matching to one of c("Netezza", "MSSQL")}
}

\examples{
#SQL codes for basic summary, Netezza database
get_summary_codes("DB_NAME.SCHEMA_NAME.TABLE_NAME", type="basic", dbtype="Netezza")


#SQL codes for advanced summary, Netezza database
get_summary_codes("DB_NAME.SCHEMA_NAME.TABLE_NAME", type="advanced", dbtype="Netezza")


#SQL codes for basic summary, Microsoft SQL Server
get_summary_codes("DB_NAME.SCHEMA_NAME.TABLE_NAME", type="basic", dbtype="MSSQL")


#SQL codes for advanced summary, Microsoft SQL Server
get_summary_codes("DB_NAME.SCHEMA_NAME.TABLE_NAME",type="advanced", dbtype="MSSQL")
}

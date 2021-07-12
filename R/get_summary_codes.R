#' Generate SQL codes used to summarize tables'

#' @param target_path character string: location of the table, i.e., "database_name.schema_name.table_name"
#' @param show_codes Boolean: set to TRUE to print out results, FALSE otherwise
#' @param type character string: choice of basic or advance summary
#' @param dbtype character string: exact matching to one of c("basic", "advanced")
#' @param quote_table_name Boolean: wrap quotation marks around the table name, if set to TRUE; otherwise, FALSE
#' @param clipboard_enabled Boolean: copy resulting SQL scripts to Clipboard, if set to TRUE, otherwise, if set to FALSE
#' @return character string containing the SQL scripts
#' @export

get_summary_codes <- function(target_path, show_codes=FALSE, type="basic", dbtype="Netezza", quote_table_name=FALSE, clipboard_enabled=TRUE){

      target_path <- gsub("\\[|\\]","",target_path) #get rid of opening/closing square brackets in the [db].[schema].[table] notation.
      db_path <- unlist(strsplit(target_path,"\\.")) #split on period to make a vector of length 3
      if (length(db_path)!=3){

        stop("The path of the table has an invalid format. Example of a valid format: 'DATABASE_NAME.SCHEMA_NAME.TABLE_NAME'")

      }


      if (!(dbtype %in% c("Netezza", "MSSQL"))){

        stop("Currently, you can only generate SQL codes for 'Netezza' and 'MSSQL' databases. More updates are coming...")

      }

      if (!(type %in% c("basic","advanced"))){

        stop("Input 'type' is invalid.\nReminder: type='basic' is the short summary and type='advanced' is the more detailed summary.")

      }


      db_name <- db_path[1] #database name
      schema_name <- db_path[2] #schema name
      table_name <-  db_path[3] #table name


      if(type=="basic"& dbtype=="Netezza"){


        if (quote_table_name){ table_name_quoted = paste0("\'\"",table_name,"\"\'")} else {
          table_name_quoted = paste0("\'",table_name,"\'")}

        sql_codes <- paste0(" SELECT REPLACE(REPLACE(REPLACE(
                               '<start> SELECT ''<col>'' as colname,
                               COUNT(*) as numvalues,
                               MAX(freqnull) as freqnull,
                               CAST(MIN(minval) as CHAR(100)) as minval,
                               SUM(CASE WHEN <col> = minval THEN freq ELSE 0 END) as numminvals,
                               CAST(MAX(maxval) as CHAR(100)) as maxval,
                               SUM(CASE WHEN <col> = maxval THEN freq ELSE 0 END) as nummaxvals,
                               SUM(CASE WHEN freq =1 THEN 1 ELSE 0 END) as numuniques

                               FROM (SELECT <col>, COUNT(*) as freq
                               FROM ",schema_name,".<tab> GROUP BY <col>) osum
                                                   CROSS JOIN (SELECT MIN(<col>) as minval, MAX(<col>) as maxval, SUM(CASE WHEN <col> IS NULL THEN 1 ELSE 0 END) as freqnull
                                                   FROM (SELECT <col> FROM ",schema_name,".<tab>) osum
                                                   ) summary',
                               '<col>', column_name),
                               '<tab>', ", table_name_quoted, "),
                               '<start>',
                               (CASE WHEN ordinal_position = 1 THEN ''
                               ELSE 'UNION ALL' END)) as codes_data_summary
                               FROM (SELECT table_name, case when regexp_like(column_name,'[a-z.]|GROUP')  then \'\"\'||column_name||\'\"\'
                                                             else column_name end as column_name  , ordinal_position
                               FROM information_schema.columns
                               WHERE table_name =","'",table_name,"'",") a;")
      }


      if(type=="advanced"&dbtype=="Netezza"){


        if (quote_table_name){ table_name_quoted = paste0("\'\"",table_name,"\"\'")} else {
          table_name_quoted = paste0("\'",table_name,"\'")}

        sql_codes <-  paste0("SELECT REPLACE(REPLACE(REPLACE(
                                    '<start> SELECT ''<col>'' as colname,
                                     COUNT(*) as numvalues,
                                     MAX(freqnull) as freqnull,
                                     CAST(MIN(minval) AS VARCHAR(250)) as minval,
                                     SUM(CASE WHEN <col>  = minval THEN freq ELSE 0 END) as numminvals,
                                     CAST(MAX(maxval) AS VARCHAR(250)) as maxval,
                                     SUM(CASE WHEN <col>  = maxval THEN freq ELSE 0 END) as nummaxvals,
                                     CAST(MIN(CASE WHEN freq = maxfreq THEN <col>  END) AS VARCHAR(250)) as mode,
                                     SUM(CASE WHEN freq = maxfreq THEN 1 ELSE 0 END) as nummodes,
                                     MAX(maxfreq) as modefreq,
                                     CAST(MIN(CASE WHEN freq = minfreq THEN <col>  END) AS VARCHAR(250)) as antimode,
                                     SUM(CASE WHEN freq = minfreq THEN 1 ELSE 0 END) as numantimodes,
                                     MAX(minfreq) as antimodefreq,
                                     SUM(CASE WHEN freq = 1 THEN freq ELSE 0 END) as numuniques
                                     FROM (SELECT <col> , COUNT(*) as freq
                                     FROM ",schema_name,".<tab>
        GROUP BY <col> ) osum CROSS JOIN
                                     (SELECT MIN(freq) as minfreq, MAX(freq) as maxfreq,
                                     MIN(<col> ) as minval, MAX(<col> ) as maxval,
                                     SUM(CASE WHEN <col>  IS NULL THEN freq ELSE 0 END) as freqnull
                                     FROM (SELECT <col> , COUNT(*) as freq
                                     FROM ",schema_name,".<tab>
        GROUP BY <col> ) osum) summary',
                                     '<col>', column_name),
                                     '<tab>',", table_name_quoted,"),
                                     '<start>',
                                     (CASE WHEN ordinal_position = 1 THEN ''
                                     ELSE 'UNION ALL' END)) as codes_data_summary
                                     FROM (SELECT table_name, ordinal_position,
                                                  case when regexp_like(column_name,'[a-z.]|GROUP')  then \'\"\'||column_name||\'\"\'
                                                       else column_name end as column_name
                                     FROM information_schema.columns
                                     WHERE table_name = ","'",table_name,"'",") a;")

      }


      if(type=="basic"& dbtype=="MSSQL"){

          sql_codes <-  paste0("
                                                 USE ", db_name,
                               "
                                                 GO
                                                 SELECT REPLACE(REPLACE(REPLACE('<start> SELECT ''<col>'' as colname,
                                                 COUNT(*) as numvalues, MAX(freqnull) as freqnull, CAST(MIN(minval) as
                                                 VARCHAR) as minval, SUM(CASE WHEN <col> = minval THEN freq ELSE 0 END)
                                                 as numminvals, CAST(MAX(maxval) as VARCHAR) as maxval, SUM(CASE WHEN
                                                 <col> = maxval THEN freq ELSE 0 END) as nummaxvals, SUM(CASE WHEN freq =
                                                 1 THEN 1 ELSE 0 END) as numuniques FROM (SELECT <col>, COUNT(*) as freq
                                                 FROM ", schema_name, ".<tab> GROUP BY <col>) osum CROSS JOIN (SELECT MIN(<col>) as minval,
                                                 MAX(<col>) as maxval, SUM(CASE WHEN <col> IS NULL THEN 1 ELSE 0 END) as
                                                 freqnull FROM (SELECT <col> FROM ", schema_name, ".<tab>) osum) summary',
                                                 '<col>', column_name),
                                                 '<tab>', table_name),
                                                 '<start>',
                                                 (CASE WHEN ordinal_position = 1 THEN ''
                                                 ELSE 'UNION ALL' END)) as codes_data_summary
                                                 FROM (", "SELECT table_name, case when column_name like ","'",'%[\\.]%',"'",
                                                          " then concat(","'",'"',"'",",column_name,","'", '"' ,"'",")",
                                                          " else column_name end as column_name, ordinal_position",
                                                " FROM information_schema.columns
                                                 WHERE table_name = ", "'",table_name,"'",") a;")
      }


      if(type=="advanced" & dbtype=="MSSQL"){

        sql_codes <-  paste0("

                                     USE ",db_name,
                             "

                                     GO

                                     SELECT REPLACE(REPLACE(REPLACE(
                                     '<start> SELECT ''<col>'' as colname,
                                     COUNT(*) as numvalues,
                                     MAX(freqnull) as freqnull,
                                     CAST(MIN(minval) AS VARCHAR) as minval,
                                     SUM(CASE WHEN <col>  = minval THEN freq ELSE 0 END) as numminvals,
                                     CAST(MAX(maxval) AS VARCHAR) as maxval,
                                     SUM(CASE WHEN <col>  = maxval THEN freq ELSE 0 END) as nummaxvals,
                                     CAST(MIN(CASE WHEN freq = maxfreq THEN <col>  END) AS VARCHAR) as mode,
                                     SUM(CASE WHEN freq = maxfreq THEN 1 ELSE 0 END) as nummodes,
                                     MAX(maxfreq) as modefreq,
                                     CAST(MIN(CASE WHEN freq = minfreq THEN <col>  END) AS VARCHAR) as antimode,
                                     SUM(CASE WHEN freq = minfreq THEN 1 ELSE 0 END) as numantimodes,
                                     MAX(minfreq) as antimodefreq,
                                     SUM(CASE WHEN freq = 1 THEN freq ELSE 0 END) as numuniques
                                     FROM (SELECT <col> , COUNT(*) as freq
                                     FROM ",schema_name,".<tab>
                                     GROUP BY <col> ) osum CROSS JOIN
                                     (SELECT MIN(freq) as minfreq, MAX(freq) as maxfreq,
                                     MIN(<col> ) as minval, MAX(<col> ) as maxval,
                                     SUM(CASE WHEN <col>  IS NULL THEN freq ELSE 0 END) as freqnull
                                     FROM (SELECT <col> , COUNT(*) as freq
                                     FROM ",schema_name,".<tab>
                                     GROUP BY <col> ) osum) summary',
                                     '<col>', column_name),
                                     '<tab>', table_name),
                                     '<start>',
                                     (CASE WHEN ordinal_position = 1 THEN ''
                                     ELSE 'UNION ALL' END)) as codes_data_summary
                                     FROM (SELECT table_name, column_name, ordinal_position
                                     FROM information_schema.columns
                                     WHERE table_name = ","'",table_name,"'",") a;")

      }


      if(show_codes==TRUE){
        cat(sql_codes)
        cat(rep('\n',5))#print codes
      }

      if (clipboard_enabled) {writeClipboard(sql_codes)} #copy to clipboard, if the clipboard option is enabled
      
      return(sql_codes) #return SQL texts

}

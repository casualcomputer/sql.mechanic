# sql.mechanic
This package contains functions that generate SQL queries, which can summarize high-dimensional tables stored in various databases (e.g. Microsoft SQL Servers, Netezza, DB2, etc.). The outputs of the functions can be directly executed in the interface of various database management systems. Compared to the summary function in base R, this solution can be hundreds or thousands of times better, especially when your server is much more powerful than your local computer.

If you are trying to summarize tables stored in enterprise-level servers, the execution speed of this package's outputs are limited only by the capacity of the servers, instead of RAM of local computers. If you use a powerful server to store your data and prefer to use the R language, you are no longer limited by the RAM of your computer.

Credits: the R codes in this package were built on top of Gordon S. Linoff's book _Data Analysis Using SQL and Excel, 2nd Edition_. His work has been a tremendous inspiration for the creation of this package.  

# JIRA-CleanExport
JIRA can generate a csv of the records and columns displayed on the screen. 
I wanted to open the csv in Excel and use pivot tables for reporting but JIRA 
will create varying numbers of multiple columns in the export with exactly the
same column name  which breads pivots. 

This R script cleans up the csv export 
and merges all similar column names and writes an excel file. 
Components, Labels and Links are the three columns that are merged.

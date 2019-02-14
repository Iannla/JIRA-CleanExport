# JIRA-CleanExport
JIRA can generate a csv of the records and columns displayed on the screen. 
I wanted to open the csv in Excel and use pivot tables for reporting but JIRA 
will create varying numbers of multiple columns in the export with exactly the
same column name which breaks pivots. I now have MS Access linking to the XLSX which produces
all the reports i need with one click.

This R script cleans up the csv export 
and merges all similar column names and writes an excel file. 
Components, Labels and Links are the three columns that are merged.

Files and what they do.
jira_export_example  = example csv export from JIRA
jira_search_config.txt  = how i setup my search in jira
reportData.xlsx = resulting cleaned csv file now as an excel file
JIRA_CSV_clean_RC.R = main R Script

Notes
Ensure that your JAVA install, required by xlsx package, is the same type as your R and R studio package. 
i.e. 64bit java for 64 bit R and R Studio. 32bit java for 32 bit R and R studio or you will get errors 
during the xlsx creation.

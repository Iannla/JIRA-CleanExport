#  R Script Template - May 2018
#
###
# Replace items in square brackets [ ] as indicated
###
# Script name: JAVA_CSV_Clean_RC.R
# Creator:  Ian King
# Created:  August 30, 2018
# Script Purpose:  This script is used to transform the standard JIRA csv export with multiple component, 
#           links and label fields into single fields for each column and cleans up the data.
#           Script designed for readability as opposed to efficiency
# input:    csv e.g. Jira export tickets.csv
# output:   excel spreasheet  - reportData.xlsx
# Script type: [load, transform, create]
# Rev 1.0
# on January 30,2019
#
#
#
########## REQUIREMENTS
#### Packages Used
# commented out as once loaded there is no need to reload unless there is a major update
# note always load dplyr last
# install.packages("magrittr")
# install.packages("janitor")
# install.packages("readr")
# install.packages("tidyverse")
# install.packages("xlsx")
# install.packages("dplyr")

# load libraries
# note always load dplyr last
library("magrittr") # %>%
library("tidyverse") # unite
library("readr") #read_csv
library("xlsx") # create xlsx
library("janitor") # clean_names
library("dplyr") # grep


# Create main data table from the JIRA csv export
# Display a dialog to choose the csv file
myFile <- rstudioapi::selectFile(caption = "Select CSV File",
                               filter = "CSV Files (*.csv)",
                               existing = TRUE)
# note this script expects a csv 
rawData <- read_csv(myFile) %>% clean_names(case="lower_camel")

# create a list of column names like "labels"
myLabels <- rawData%>% dplyr:: select(grep("labels", names(rawData)))
labelNames <-names(myLabels)
# no longer need the dataset so delete it
remove(myLabels)

# create a list of column names like "components"
myComponents <- rawData%>% dplyr:: select(grep("component", names(rawData)))
componentNames <-names(myComponents)
# no longer need the dataset so delete it
remove(myComponents)

# create a list of column names like "link"
myLink <- rawData%>% dplyr:: select(grep("outwardIssue", names(rawData)))
linkNames <-names(myLink)
# no longer need the dataset so delete it
remove(myLink)

# next line removes the issueid field which JIRA always produces in its export
reportData <- rawData[c(1,2,4:ncol(rawData))]



# merge the various Components fields into one field and delete original columns
reportData <-(unite_(reportData, "components", c(componentNames),
                                              sep = ";",
                                              remove = TRUE))

# merge the various labels fields into one field and delete original columns
reportData <-(unite_(reportData, "labels", c(labelNames),
                                              sep = ";",
                                              remove = TRUE))

# merge the various links fields into one field and delete original columns
reportData <-(unite_(reportData, "link", c(linkNames),
                                              sep = ";",
                                              remove = TRUE))
# make a backup and restore as required
# bkreportData <- reportData
# reportData <- bkreportData

# should now have only thirteen of the original 'n' columns in reportData
# clean up the "created" field to remove the timestamp e.g. 17/Dec/18 1:53 PM to 17/12/18
reportData$created <- format(as.Date(strptime(reportData$created, '%d/%b/%y %H:%M')), "%d/%m/%y")
# now we have an unambiguous date format convert the character to a date
reportData$created <- as.Date(reportData$created,tryFormats = c("%d/%m/%y", "%d/%m/%y"),optional = FALSE)
# head(reportData$created)

# clean up the "updated" field to remove the timestamp e.g. 17/Dec/18 1:53 PM to 17/12/18
reportData$updated <- format(as.Date(strptime(reportData$updated, '%d/%b/%y %H:%M')), "%d/%m/%y")
# now we have an unambiguous date format convert the character to a date
reportData$updated <- as.Date(reportData$updated,tryFormats = c("%d/%m/%y", "%d/%m/%y"),optional = FALSE)

# clean up the ;NA, NA, NA; create during the column merges
reportData$link <- gsub("NA;", "", reportData$link)
reportData$link <- gsub(";NA", "", reportData$link)
reportData$link <- gsub("NA", "", reportData$link)
reportData$labels <- gsub("NA;", "", reportData$labels)
reportData$labels <- gsub(";NA", "", reportData$labels)
reportData$labels <- gsub("NA", "", reportData$labels)
reportData$components <- gsub("NA;", "", reportData$components)
reportData$components <- gsub(";NA", "", reportData$components)
reportData$components <- gsub("NA", "", reportData$components)
# following two lines clean up the resolution field into either Open or Resolved.
reportData$resolution[!is.na(reportData$resolution)] <- "Resolved"
reportData$resolution[is.na(reportData$resolution)] <- "Open"


# write an excel file for reporting in Excel or Access
# note that MsAccess has to be closed as it puts a file lock on the reportdate file
# this stops the file from being created, you will see red error in console
# Error in .jnew("java/io/FileOutputStream", jFile) : 
# java.io.FileNotFoundException: Data\reportData.xlsx (The process cannot access the 
# file because it is being used by another process)
write.xlsx(as.data.frame(reportData),file.path("Data","reportData.xlsx"), sheetName="reportData", 
       col.names=TRUE, row.names=FALSE, append=FALSE, showNA=FALSE, password=NULL)

# remove datafiles as they are no longer required
remove(componentNames)
remove(labelNames)
remove(linkNames)
remove(rawData)
remove(reportData)
remove(bkreportData)
remove(myFile)

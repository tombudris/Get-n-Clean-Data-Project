---
output: html_document
---
## README for run_analysis.R

This script reads and manipulates the "Human Activity Recognition Using Smartphones Data Set" from the University of California - Irvine, provided at:  https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

The purpose of this script is twofold: **First**, it reads and consolidates two subdirectories of this data set, extracting only those variables that report mean and standard deviations.  **Secondly**, the script calculates the mean for each value for all subject-activity pairings, and generates a "tidy" data output called "tidy_averages.txt"

### 1. Reading and consolidating the source data
This script should be run from within the top level of the directory structure created by  the UCI zipfile.  At this top level, it will read "features.txt" (a codebook for the recorded variable values) and "activities.txt" (a mapping of various activities to integer values).  These are captured in R data.frame structures using read.table().  

Also, at this top-most level, the script performs a text search on the feature labels that were read in, creating a logical vector corresponding to positions in the features data.frame where the strings 'mean()' or 'std()' were found by grep().  Using this logical vector, the script loops to build an identically dimensioned character vector to use as an argument for read.table() as the col.classes argument later when reading the subdirectory X data... "numeric" for "TRUE" entries of the above logical vector, and "NULL" for "FALSE", which will be skipped by read.table()

The script next enters a loop to read the subdirectories of 'test' and 'train', where subject, activity, and measurement data are recorded.  "subject" and "y" (activity) files are read in a straightforward manner with read.table(), but "y" data are modified via a lookup-style join, replacing the integer value with a descriptive name.  Reading of "X" (measurement) data is constrained by the col.classes argument with the character vector described in the paragraph above, such that only "mean" and "std" entries are read (all others skipped)

Within a single loop, the various data.frames corresponding to each of the data files are bound with cbind() into a single table.  Across iterations of the loop (one for each subdirectory), the tables are accumulated with cbind().  This yields a single large data frame of [subject, activity, and 79 measurements] across 10299 observation rows.

### 2. Summarizing and tidying the summary data
The mean values for all subject-activity pairs are calculated with a combination of melt() and dcast().  First, the data.frame is melted, such that the 79 measurement fields are transformed into two columns: variable (from "features.txt") and value (from the X data files).  Next, dcast() is used to calculate the mean value across each class of feature measurements for each subject-activity combination.  The result is a data.frame in the dimension of the original frame above (81 columns, 10299 rows), which is arguably tidy, but only because this data set is well populated.  To make sure this script generates reproducably tidy output for different data in the same format, we apply melt() once more, to return it to a "long-tidy" format: [subject, activity, feature_name, avg_value]

This tidy summary table is written back to the initial top-level directory (where the script started) and is named "tidy_averages.txt".  This file can be read and viewed in RStudio via:
```{r}
tidy_averages <- read.table("tidy_averages.txt")
View(tidy_averages)
```



If you've read this far, thanks for bearing with me, and have a nice day.

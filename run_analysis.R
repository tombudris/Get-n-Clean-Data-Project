
## -----------------------------------------------------------------
## "Getting and Cleaning Data", Week 3 Project
## Two phase approach below: (1) read the data, (2) create a tidy summary data set
## -----------------------------------------------------------------
library(plyr)
library(reshape2)

## (Part 1) Read the data

# for navigation purposes, where are we?
top_dir<-getwd()

# read the feature data and activity data at the top level
feature_labels <- read.table("features.txt", col.names=c("feature", "label"), 
                             stringsAsFactors = FALSE)
activity_labels <- read.table("activity_labels.txt", 
                              col.names=c("activity", "label"),stringsAsFactors = FALSE)

# When we get to the component subdirectories for the X data, we need to be selective:
# just getting the cols corresponding with "std()" or "mean()" feature measurements...
# Figure out which variable names contain the strings we care about with a logical vector
features2extract<-grepl("std()|mean()", feature_labels$label)

# Before reading X_ data later, we will need to be selective... it's big.
# Use col.classes to exclude data based on 'features2extract' vector:
# Loop and create a vector of class labels for extraction ("numeric") or skip ("NULL")
cols2extract <- vector(mode = "character")
for (j in 1:length(feature_labels$label)){
        if(features2extract[j]) {
                cols2extract[j] <- "numeric"
        }
        else {
                cols2extract[j] <- "NULL"
        }
}

# Execute the reading once in a loop to avoid repetitive code
# (one pass for each subdirectory: "train" & "test")
sub_dirs<-c("train", "test")

# need to declare an empty data.frame to store our accumulated data from the loop:
complete_data = data.frame()

for (i in 1:length(sub_dirs)){         ## loop over the subdirectories
        
        setwd(paste0(top_dir, "/", sub_dirs[i]))
        subj_data <- read.table(paste0("subject_",sub_dirs[i],".txt"))
        names(subj_data)<-"subject"   
        y_data <- read.table(paste0("y_",sub_dirs[i],".txt"))
        names(y_data)<-"activity"   # needs to match the column in activity_labels
        
        # Need to replace 'y_data' values with descriptive activity_labels
        y_data$activity<-join(y_data,activity_labels)$label
      
        # Read the X_ data, using only the non-NULL columns we want
        x_data <-read.table(paste0("X_",sub_dirs[i],".txt"), 
                             col.names = feature_labels$label,
                             colClasses=cols2extract)
        
        # finally, bind the tables 
        partial_data <- cbind(subj_data, y_data)
        partial_data <- cbind(partial_data, x_data)
        complete_data <- rbind(complete_data, partial_data)
}       ## end subdirectory read loop

## -----------------------------------------------------------------
## (Part 2) Create a tidy summary data set
## Computing the mean value for all possible subject(1:30) X activity(1:6) combinations

# First melt the complete_data frame, turning all the various feature columns into 
# two columns ('variable' and 'value'), preserving the first two columns 'subject' 
# and 'activity'
melted_data <- melt(complete_data, id=1:2)

# Cast the melted frame back into a data.frame that contains averages for all 
# measurements for each subject-activity pair
recast_averages<-dcast(melted_data, subject + activity ~ variable, mean)

# Finally re-tidy the data by melting it back into a 'long' tidy format, where each
# row contains a unique (subject, activity, variable, averaged_variable_value)
tidy_averages <- melt(recast_averages, id=1:2)

# Write out the results back at the directory we started from
setwd(top_dir)
write.table(tidy_averages, "tidy_averages.txt", row.names=FALSE)



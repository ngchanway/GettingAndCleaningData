url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
zipfile <- "getdata-projectfiles-UCI HAR Dataset.zip"
folder <- "UCI HAR Dataset"

## Check the existence of the dataset
## If the dataset is not exist but is downloaded in a zipfile,
## unzip the dataset
## If the dataset is not exist and the zipfile is not downloaded,
## download the dataset and unzip the dataset from the zipfile
if(!file.exists(folder)) {
        if(!file.exists(zipfile)) {
                download.file(url, zipfile, method = "curl")                        
        }
        unzip(zipfile)
        unlink(zipfile)
}

## Read the training and the test sets
## Merge them to create one data set
X_train <- read.table("UCI HAR Dataset/train/X_train.txt")
X_test <- read.table("UCI HAR Dataset/test/X_test.txt")
X <- rbind(X_train, X_test)

## Read the complete list of of variables of each feature vector
## Label the data set with descriptive variable names
## Extract the mean and standard deviation for each measurement
features <- read.table("UCI HAR Dataset/features.txt",
                       colClasses = "character")[ , 2]
names(X) <- features
X <- X[ , grep("mean()|std()|Mean", features)]

## Read the training and test labels
## and ID of the subject who performed the activity for each window sample
## Merge them with the train and the test sets
y_train <- read.table("UCI HAR Dataset/train/y_train.txt")
y_test <- read.table("UCI HAR Dataset/test/y_test.txt")
y <- rbind(y_train, y_test)
names(y) <- "activities"

subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt")
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt")
subject <- rbind(subject_train, subject_test)
names(subject) <- "subjects"
subject$subjects <- as.factor(subject$subjects)

dataset <- cbind(subject, y, X)

## Uses descriptive activity names to name the activities in the data set
y_labels <- read.table("UCI HAR Dataset/activity_labels.txt",
                       colClasses = "character")[ , 2]
dataset$activities <- y_labels[dataset$activities]
dataset$activities <- as.factor(dataset$activities)

## Create an independent tidy data set with the average of each variable
## for each activity and each subject.
library(reshape2)
library(plyr)
dataset <- melt(dataset, id.vars = c("subjects", "activities"),
                    measure.vars = names(dataset)[3:88])
tidydataset <- ddply(dataset, .(subjects, activities, variable), summarize,
                     average = mean(value))

## Output the tidy data set as a txt file.
write.table(tidydataset, "tidydataset.txt", row.names = FALSE)
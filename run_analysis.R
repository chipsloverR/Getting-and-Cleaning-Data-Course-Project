library(plyr)
library(dplyr)

# set file name
filename <- "getdata_dataset.zip" 
 
# Download and unzip the dataset
if (!file.exists(filename)){ 
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip " 
download.file(fileURL, filename, method="curl") 
}   
if (!file.exists("UCI HAR Dataset")) {  
unzip(filename)  
} 

# load the training and testing data sets
train <- read.table("UCI HAR Dataset/train/X_train.txt") 
test <- read.table("UCI HAR Dataset/test/X_test.txt") 

# merge the training and testing sets
mergeSet <- rbind(train,test)

# load the features names 
features <- read.table("UCI HAR Dataset/features.txt",col.names = c("featureid","featuredes"))

# assign the features description as the column names of merge dataset
colnames(mergeSet) <- features$featuredes

# extract only the measurements on the mean and standard deviation for each measurement.
mergeSetSub1 <- mergeSet[,grep("mean|std",features$featuredes)]

# load the activity labels for the training and testing sets and merge them
trainLabels <- read.table("UCI HAR Dataset/train/y_train.txt",col.names = "actRefID") 
testLabels <- read.table("UCI HAR Dataset/test/y_test.txt",col.names = "actRefID") 
activityLabels <- rbind(trainLabels,testLabels)

# load the activity labels description reference table (i.e // 1 = Walking, 2 = Walking_Upstairs)
actLabRefTab <- read.table("UCI HAR Dataset/activity_labels.txt",stringsAsFactors = FALSE,col.names = c("actRefID","activityName")) 

# identify the activity label using the reference table and merge with principal dataset
activityLabelsWDesc <- left_join(activityLabels,actLabRefTab,by="actRefID")
mergeSetSub2 <- cbind(activityLabelsWDesc,mergeSetSub1)

# load the data that identifies the subject who performed the activity for the training and testing sets and merge them 
subjectTrain <- read.table("UCI HAR Dataset/train/subject_train.txt",col.names = "subjectID") 
subjectTest <- read.table("UCI HAR Dataset/test/subject_test.txt",col.names = "subjectID") 
subjectAll <- rbind(subjectTrain,subjectTest)

# add the subject column to the main data frame
mergeSetSub3 <- cbind(subjectAll,mergeSetSub2[,2:ncol(mergeSetSub2)])

# Creates a second, independent tidy data set with the average of each variable for each activity and each subject.
finaldf <- mergeSetSub3 %>% group_by(subjectID,activityName) %>% summarise_each(funs(mean))
View(finaldf)

# create a txt file with the final df and hoping for the best:)
write.table(finaldf,"tidySetR.txt",row.names = FALSE)



install.packages("data.table")
library(dplyr)

#1
URL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
destFile <- "CourseDataset.zip"
#2
if (!file.exists(destFile)){
  download.file(URL, destfile = destFile, mode='wb')
}
#3
if (!file.exists("./UCI_HAR_Dataset")){
  unzip(destFile)
}

dateDownloaded <- date()

#Reading files:
setwd("./UCI HAR Dataset")
#Reading Activity files
ActivityTest <- read.table("./test/y_test.txt", header = F)
ActivityTrain <- read.table("./train/y_train.txt", header = F)

#Reading features files
FeaturesTest <- read.table("./test/X_test.txt", header = F)
FeaturesTrain <- read.table("./train/X_train.txt", header = F)

#Read subject files
SubjectTest <- read.table("./test/subject_test.txt", header = F)
SubjectTrain <- read.table("./train/subject_train.txt", header = F)

#Read Activity Labels
ActivityLabels <- read.table("./activity_labels.txt",header = F)

#Read Feature Names
FeatureNames <- read.table("./features.txt", header = F)

#Merging dframes: Test&Train Features, Activity, Subject
FeaturesData <- rbind(FeaturesTest,FeaturesTrain)
SubjectData <- rbind(SubjectTest,SubjectTrain)
ActivityData <- rbind(ActivityTest,ActivityTrain)

###Rename columns in ActivityData & ActivityLabels
names(ActivityData) <- "ActivityN"
names(ActivityLabels) <- c("ActivityN","Activity")

####Get factor of Activity names
Activity <- left_join(ActivityData,ActivityLabels,"ActivityN")[,2]

####Rename SubjectData columns
names(SubjectData) <- "Subject"

####Rename FeaturesData columns by FeaturesNames
names(FeaturesData) <- FeatureNames$V2

###Big dataset
DataSet <- cbind(SubjectData,Activity)
DataSet <- cbind(DataSet,FeaturesData)

###New datasets by using measurements of mean stddev
subFeaturesNames <- FeatureNames$V2[grep("mean\\(\\)|std\\(\\)", FeatureNames$V2)]
DataNames <- c("Subject","Activity", as.character(subFeaturesNames))
DataSet <- subset(DataSet,select=DataNames)

#####Rename the columns to more descriptive names
names(DataSet)<-gsub("^t","time",names(DataSet))
names(DataSet)<-gsub("^f","frequency",names(DataSet))
names(DataSet)<-gsub("Acc","Accelerometer",names(DataSet))
names(DataSet)<-gsub("Gyro","Gyroscope",names(DataSet))
names(DataSet)<-gsub("Mag","Magnitude",names(DataSet))
names(DataSet)<-gsub("BodyBody","Body",names(DataSet))

####Create a tidy data set with the average of each variable for each activity and subject
TidyDataSet <- aggregate(. ~Subject + Activity, DataSet, mean)
TidyDataSet <- TidyDataSet[order(TidyDataSet$Subject,TidyDataSet$Activity),]
write.table(TidyDataSet,file="tidyset.txt",row.name=FALSE)
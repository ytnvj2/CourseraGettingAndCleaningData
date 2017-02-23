#creates directory Data and downloads the file from the URL.
if(!file.exists("./data"))
  dir.create("./data")
fileURL<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileURL,destfile = "./data/projectData.zip")
#Extracts the file contents into the directory
listZip<- unzip("./data/projectData.zip",exdir = "./data")

#Reads the Train data and Test data
train.x<- read.table("./data/UCI HAR Dataset/train/X_train.txt")
train.y<- read.table("./data/UCI HAR Dataset/train/y_train.txt")
train.subject<- read.table("./data/UCI HAR Dataset/train/subject_train.txt")
test.x<- read.table("./data/UCI HAR Dataset/test/X_test.txt")
test.y<- read.table("./data/UCI HAR Dataset/test/y_test.txt")
test.subject<- read.table("./data/UCI HAR Dataset/test/subject_test.txt")

#Binds the subject train and test data
Subject<- rbind(train.subject,test.subject)
#Binds the y train and y test data
Activity<-rbind(train.y,test.y)
#Binds the X train and X test data
Features<-rbind(train.x,test.x)

#Assigns variable name to Subject and Activity
names(Subject)<-c("subject")
names(Activity)<- c("activity")

#Reads the features file and sets the variable names in Features
FeaturesNames <- read.table(file.path(path_rf, "features.txt"),head=FALSE)
names(Features)<- FeaturesNames$V2

#Merge columns to get the data frame Data1 containing full data
Data1 <- cbind(Features, Subject, Activity)

#Subset Name of Features by measurements on the mean and standard deviation
subFeaturesNames<-FeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", FeaturesNames$V2)]

#Subset the data frame Data1 by seleted names of Features
selectedNames<-c(as.character(subFeaturesNames), "subject", "activity" )
Data1<-subset(Data1,select=selectedNames)

#Read descriptive activity names from "activity_labels.txt"
activityLabels <- read.table(file.path(path_rf, "activity_labels.txt"),header = FALSE)

#Facorize Variale activity in the data frame Data using descriptive activity names
Data1$activity <- factor(Data1$activity, levels = activityLabels[,1], labels = activityLabels[,2])

#Labels the data set with descriptive variable names
names(Data1)<-gsub("^t", "time", names(Data1))
names(Data1)<-gsub("^f", "frequency", names(Data1))
names(Data1)<-gsub("Acc", "Accelerometer", names(Data1))
names(Data1)<-gsub("Gyro", "Gyroscope", names(Data1))
names(Data1)<-gsub("Mag", "Magnitude", names(Data1))
names(Data1)<-gsub("BodyBody", "Body", names(Data1))

library(plyr);
Data2<-aggregate(. ~subject + activity, Data1, mean)
Data2<-Data2[order(Data2$subject,Data2$activity),]

#Creates the final Tidy Dataset
write.table(Data2, file = "tidydata.txt",row.name=FALSE)



# first need to download the dataset zipped file 
  #store the url
 urlName <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
 ## make the file path for where I am going to store the file in the current WD
 loc <- file.path(getwd(), "ProjectData.zip")
#download the file into the current wd 
download.file(urlName,loc)
# unzip the file in the WD, it made the UCI HAR Data Set
unzip(zipfile="ProjectData.zip")

## load the data.table and reshape2 packages
library(data.table)
library(reshape2)

##read in the activity labels and featrue labels using read.table 
actLbls <- read.table("./UCI HAR Dataset/activity_labels.txt")
featLbls <- read.table("./UCI HAR Dataset/features.txt", header = FALSE)

## read in the test and training datasets along with the subject files again using read.table
## x is features y is activity 
subTest <- read.table("./UCI HAR Dataset/test/subject_test.txt", header = FALSE)
actTest <- read.table("./UCI HAR Dataset/test/y_test.txt", header = FALSE)
featTest <- read.table("./UCI HAR Dataset/test/X_test.txt", header = FALSE)
subTrain <- read.table("./UCI HAR Dataset/train/subject_train.txt", header = FALSE)
actTrain <- read.table("./UCI HAR Dataset/train/y_train.txt", header = FALSE)
featTrain <- read.table("./UCI HAR Dataset/train/X_train.txt", header = FALSE)

#merget the subject data sets together
subMerged <- rbind(subTrain, subTest)
#merget the features data sets together
featMerged<- rbind(featTrain, featTest)
#merget the activity data sets together
actMerged<- rbind(actTrain, actTest)
#now we need to name the datasets that were binded above
names(subMerged)<-c("subject")
names(actMerged)<- c("activity")
#use the feature lbls read in before use V2 because the names are in column 2 
names(featMerged)<- featLbls$V2
# combine all of the data sets
MergedData <- cbind(featMerged,subMerged,actMerged)

# i only want the mean and standrad deviation from the features data set
#find the mean and std lbls in the featlbs table
msFeat <- featLbls$V2[grep("mean\\(\\)|std\\(\\)", featLbls$V2)]
#to get the data set with mean and std and subj and lbls, subset with these names
colNam<-c(as.character(msFeat), "subject", "activity" )
FinData<-subset(MergedData,select=colNam)

#put in he activity labels using a for loop
i = 1
for (actLbl in actLbls$V2) {
  FinData$activity <- gsub(i, actLbl, FinData$activity)
  i <- i + 1
}


#rename the column names with hte full names in the feature labels
names(FinData)<-gsub("^t", "time", names(FinData))
names(FinData)<-gsub("^f", "frequency", names(FinData))
names(FinData)<-gsub("Acc", "Accelerometer", names(FinData))
names(FinData)<-gsub("Gyro", "Gyroscope", names(FinData))
names(FinData)<-gsub("Mag", "Magnitude", names(FinData))
names(FinData)<-gsub("BodyBody", "Body", names(FinData))

#write the tidydata.tt
#run the mean on the columns
tidyData<-aggregate(. ~subject + activity, FinData, mean)
tidyData<-tidyData[order(tidyData$subject,tidyData$activity),]
#write the tidy data table
write.table(tidyData, file = "tidydata.txt",row.name=FALSE)


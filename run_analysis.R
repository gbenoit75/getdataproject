## A function that create a tidy dataset
## from raw data

library(plyr)
library(dplyr)
library(reshape2)

#################################################################
######################### STEP 1 ################################
#################################################################

# download data
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, dest="data.zip", method="curl")

# Unzip file
raw_data <- unzip("data.zip")

# Load test data
subj_test <- read.table(raw_data[14])
x_test <- read.table(raw_data[15])
y_test <- read.table(raw_data[16])

# Load train data
subj_train <- read.table(raw_data[26])
x_train <- read.table(raw_data[27])
y_train <- read.table(raw_data[28])

# Merge data into one data set
df1 <- cbind(x_test, y_test, subj_test)
df2 <- cbind(x_train, y_train, subj_train)
dset <- rbind(df1, df2)

#################################################################
######################### STEP 2 ################################
#################################################################

# Find index of measurements on mean and std
features <- read.table(raw_data[2]) 
index_m <- sapply(features[,2], function(x) grepl("mean()", x, fixed=TRUE))
index_std <- sapply(features[,2], function(x) grepl("std()", x, fixed=TRUE))
indexs <- index_m | index_std
index <- c(indexs, TRUE, TRUE)

# Keep only measurements on mean and std in step 1 data set
dset <- rbind(index, dset)
dset2 <- dset[,dset[1,]!=0]
dset2 <- dset2[-1,]

#################################################################
######################### STEP 3 ################################
#################################################################

# Label activities
col <- ncol(dset2)-1
dset2[,col] <- sapply(dset2[,col], function(x) gsub(1, "walking",x))
dset2[,col] <- sapply(dset2[,col], function(x) gsub(2, "walkingupstairs",x))
dset2[,col] <- sapply(dset2[,col], function(x) gsub(3, "walkingdownstairs",x))
dset2[,col] <- sapply(dset2[,col], function(x) gsub(4, "sitting",x))
dset2[,col] <- sapply(dset2[,col], function(x) gsub(5, "standing",x))
dset2[,col] <- sapply(dset2[,col], function(x) gsub(6, "laying",x))

#################################################################
######################### STEP 4 ################################
#################################################################

# label the data set with descriptive variables names
vec <- cbind(indexs, features)
vec <- vec[vec[,1]!=0,]
vec[,3] <- gsub("-", "", vec[,3], fixed=TRUE)
vec[,3] <- gsub("()", "", vec[,3], fixed=TRUE)
vec[,3] <- gsub("BodyBody", "Body", vec[,3], fixed=TRUE)
vec[,3] <- tolower(vec[,3])
dset2 <- setNames(dset2, c(vec[,3], "activity", "subject"))

#################################################################
######################### STEP 5 ################################
#################################################################

# create tidy data set and return mean for each variable
# for each activity and each subject

mdata <- melt(dset2, id=c("subject","activity"), measure.vars=1:(ncol(dset2)-2))
mdata <- mdata[order(mdata$subject),]
tidydata <- ddply(mdata, .(subject, activity, variable), summarize, mean=mean(value))
tidydata <- dcast(tidydata, subject + activity ~...)
write.table(tidydata, file="tidyData.txt", row.names=FALSE)
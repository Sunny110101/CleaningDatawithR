# Load necessary libraries
library(dplyr)

# Download and unzip dataset if not already present
filename <- "getdata_projectfiles_UCI HAR Dataset.zip"

if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileURL, filename, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}
# Read data
features <- read.table("UCI HAR Dataset/features.txt")
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt", col.names = c("activityId", "activityLabel"))

# Read training data
x_train <- read.table("UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt")

# Read test data
x_test <- read.table("UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt")
# Merge training and test data
x_data <- rbind(x_train, x_test)
y_data <- rbind(y_train, y_test)
subject_data <- rbind(subject_train, subject_test)

# Name columns
colnames(x_data) <- features$V2
colnames(y_data) <- "activityId"
colnames(subject_data) <- "subjectId"

# Combine all data into one dataset
complete_data <- cbind(subject_data, y_data, x_data)
# Extract columns with mean and standard deviation
columns_to_extract <- grepl("mean|std", features$V2)
columns_to_extract <- c(TRUE, TRUE, columns_to_extract)
extracted_data <- complete_data[, columns_to_extract]

# Merge with activity labels
extracted_data <- merge(extracted_data, activity_labels, by='activityId', all.x=TRUE)
# Make descriptive variable names
names(extracted_data) <- gsub("^t", "time", names(extracted_data))
names(extracted_data) <- gsub("^f", "frequency", names(extracted_data))
names(extracted_data) <- gsub("Acc", "Accelerometer", names(extracted_data))
names(extracted_data) <- gsub("Gyro", "Gyroscope", names(extracted_data))
names(extracted_data) <- gsub("Mag", "Magnitude", names(extracted_data))
names(extracted_data) <- gsub("BodyBody", "Body", names(extracted_data))
# Create tidy data set with the average of each variable for each activity and each subject
tidy_data <- extracted_data %>%
  group_by(subjectId, activityId) %>%
  summarise_all(funs(mean))

write.table(tidy_data, "tidy_data.txt", row.name=FALSE)

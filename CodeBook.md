# GettingCleaningDataAssignment CodeBook
This code book describes whats going on in run_analysis.R

## Step 1 - Load Data
All raw data is located in the directory UCI HAR Dataset, which should be located in the working directory.

First, train and test directory strings are defined for convenience.
```r
## initiate train and test dir strings
train_dir <- paste("./UCI HAR Dataset/train",sep = "")
test_dir <- paste("./UCI HAR Dataset/test",sep = "")
````

The features and activity labels are imported, which generally apply to both train and test datasets. Features will be the column names for the "X" train and data. Activities are denoted by activity numbers in the Y train and test data.
```r
## load features
features <- read.table("./UCI HAR Dataset/features.txt",quote = "") 
## load activity labels
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt",quote = "")
names(activity_labels) <- c("activity_number","activity_description")
```

Next, the training data is loaded. X_train.txt is a 2 dimensional dataset, where rows correspond to an event recorded on a subject, and columns correspond to the calculated feature. Y_train.txt is the list of activities (in terms of number), which match the events (rows) of X_train.txt. Subject_test.txt lists the subject identifiers, and also match the events (rows) in X_train.txt
```r
## load training data
## subject numbers
train_subjects_filename <- paste(train_dir,"/subject_train.txt",sep = "")
train_subjects <- read.table(train_subjects_filename)
subject_num_train<-train_subjects$V1
## X train - the data with features calculated
X_train_filename <- paste(train_dir,"/X_train.txt",sep = "")
X_train <- read.table(X_train_filename,quote = "")
## Y train - activity labels
Y_train_filename <- paste(train_dir,"/Y_train.txt",sep = "")
Y_train <- read.table(Y_train_filename)
```
The test data is read with similar filenames and variables, where the word "test" replaces "train"
```r
## load test data
## subject numbers
test_subjects_filename <- paste(test_dir,"/subject_test.txt",sep = "")
test_subjects <- read.table(test_subjects_filename)
subject_num_test<-test_subjects$V1
## X test - the data with features calculated
X_test_filename <- paste(test_dir,"/X_test.txt",sep = "")
X_test <- read.table(X_test_filename,quote = "")
## Y test - activity labels
Y_test_filename <- paste(test_dir,"/Y_test.txt",sep = "")
Y_test <- read.table(Y_test_filename)
```
## Step 2 - Merge Training and Test data
rbind() is used to merge the X_train and X_test data together, as well as the Y_train and Y_test. The subject number vectors are combined using the c(,) function.
```r
##Merge X and Y data together
X_combined <- rbind(X_train,X_test)
Y_combined <- rbind(Y_train,Y_test)
subject_num <- c(subject_num_train, subject_num_test)
```

## Step 3 - Activity Labels

Add activity labels to the merged dataset to clearly describe the activity numbers. The activity labels are temporarily stored to the activity_number_vect, and will later be added to the main dataset
```r
##create vector of activity desciptions to match Y_train activity numbers
activity_descriptions_vect <- NULL
activity_number_vect <- NULL
for (i in 1:length(activity_labels$activity_number)){
  activity_number_idx <- Y_combined$V1 == activity_labels$activity_number[i]
  activity_descriptions_vect[activity_number_idx] <- activity_labels$activity_description[i]
  activity_number_vect[activity_number_idx] <- activity_labels$activity_number[i]
}
```
## Step 4 - Update Feature Names
Feature names are updated to remove redundant "()". The variables beginning in "t" and "f" are changed to "Time" and "Freq", respectively, for a clearer description. 
```r
## features names correspond to column headers in X_train
feature_names <- features$V2
feature_names <- sub("\\()","",feature_names)
feature_names <- sub("^t","Time",feature_names)
feature_names <- sub("^f","Freq",feature_names)
names(X_combined)<-feature_names
```

## Step 5 - Combine Data and Limit Features
The X_combined, Y_combined, are combined into the same dataframe, called temp_df, which will be used temporarily to tidy up the data. The features are limited to only those with "mean" or "std" in their name.
```r
## create a temp dataframe with only features containing "mean" and "std"
mean_col_idx <- grepl("mean",features$V2)
std_col_idx <- grepl("std",features$V2)
temp_df <- data.frame(subject_num)
temp_df <- mutate(temp_df,activity_descriptions_vect)
temp_df <- mutate(temp_df,activity_number_vect)
temp_df <- mutate(temp_df,X_combined[mean_col_idx | std_col_idx])
```

## Step 6 - Create the tidy_df
The tidy_df is first initialized using the first row of the temp_df, in order to translate the column headers. Next, the average value for each feature at each activity level and subject number are added to the tidy_df by looping through each unique subject id and activity label. Finally, the tiny_df is written to "tiny_df.txt".
```r
## initialize tidy_df by making a dataframe with the same columns as temp_df
tidy_df <- temp_df[1,]

unique_subject_id <- unique(temp_df$subject_num)
cntr<-0
for (i in 1:length(unique_subject_id)){
  for (j in 1:length(activity_labels$activity_description)){
    cntr <- cntr + 1
    subject_mask <- temp_df$subject_num == unique_subject_id[i]
    activity_mask <- temp_df$activity_number_vect == activity_labels$activity_number[j]
    
    tidy_df[cntr,1] <- unique_subject_id[i]
    tidy_df[cntr,2] <- activity_labels$activity_description[j]
    tidy_df[cntr,3] <- activity_labels$activity_number[j]
    tidy_df[cntr,4:length(temp_df)] <- sapply(temp_df[subject_mask & activity_mask,4:length(temp_df)],mean)
  }
}

## write tidy_df to file
write.table(tidy_df,"tidy_df.txt",row.names = FALSE)
```

## initiate train and test dir strings
train_dir <- paste("./UCI HAR Dataset/train",sep = "")
test_dir <- paste("./UCI HAR Dataset/test",sep = "")

## load features
features <- read.table("./UCI HAR Dataset/features.txt",quote = "") 
## load activity labels
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt",quote = "")
names(activity_labels) <- c("activity_number","activity_description")

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

##Merge X and Y data together
X_combined <- rbind(X_train,X_test)
Y_combined <- rbind(Y_train,Y_test)
subject_num <- c(subject_num_train, subject_num_test)
  
##create vector of activity desciptions to match Y_train activity numbers
activity_descriptions_vect <- NULL
activity_number_vect <- NULL
for (i in 1:length(activity_labels$activity_number)){
  activity_number_idx <- Y_combined$V1 == activity_labels$activity_number[i]
  activity_descriptions_vect[activity_number_idx] <- activity_labels$activity_description[i]
  activity_number_vect[activity_number_idx] <- activity_labels$activity_number[i]
}

## features names correspond to column headers in X_train
feature_names <- features$V2
feature_names <- sub("\\()","",feature_names)
feature_names <- sub("^t","Time",feature_names)
feature_names <- sub("^f","Freq",feature_names)
names(X_combined)<-feature_names

## create a temp dataframe with only features containing "mean" and "std"
mean_col_idx <- grepl("mean",features$V2)
std_col_idx <- grepl("std",features$V2)
temp_df <- data.frame(subject_num)
temp_df <- mutate(temp_df,activity_descriptions_vect)
temp_df <- mutate(temp_df,activity_number_vect)
temp_df <- mutate(temp_df,X_combined[mean_col_idx | std_col_idx])

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

  


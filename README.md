# GettingCleaningDataAssignment
This repository includes R code to complete the programming assignment for the Coursera course "Getting and Cleaning Data"

## run_analysis.R

The main script is run_analysis.R, which:

1.  imports and merges the training and test data from the UCI HAR Dataset folder
2.  extracts only the features where a "mean" or "std" is calculated
3.  adds activity label names to match activity numbers
4.  modifies feature names to be more descriptive
5.  creates a "tidy" data set, where the average of each feature is calculated by subject and activity type

## CodeBook.md
The file CodeBook.md explains the code and variables in more detail.
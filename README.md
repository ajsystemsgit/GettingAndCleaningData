GettingAndCleaningData
======================
run_analysis.R  does the following tasks on the data provided
============================================================

1)  Merges the training and the test sets to create one data set.
 
2)  Extracts only the measurements on the mean and standard deviation for each measurement. 
 
3)  Uses descriptive activity names to name the activities in the data set
 
4)  Appropriately labels the data set with descriptive variable names. 
   
5)  From the data set in step 4, creates a second, independent tidy data set with the average
       of each variable for each activity and each subject.


Repository structure
====================
-directory /data, contains all files needed for evaluation by run_analysis.R

-README.md: This file which describes how to execute the script.

-codebook.md: Has all the variable descriptions

-run_analysis.R: is the R script that produces the cleaned dataset(tidyData.txt) 

-tidyData.txt: the file produced by run_analysis.R 

How to run the run_analysis.R script
=========================================

1) Clone the repository

2) Copy the data folder into your current working directory.

3) Copy run_analysis.R to the current working directory (To the same directory as on step 2)

4) Open R Studio.

5) type source("run_analysis.R") on R-Studio and press enter.

6) Locate the tidyData.txt created in the same directory as the run_analysis.R

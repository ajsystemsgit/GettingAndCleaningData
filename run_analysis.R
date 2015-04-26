

# Load
packages <- c("data.table", "reshape2", "plyr")

sapply(packages, require, character.only=TRUE, quietly=TRUE)

#get the working directory
path <- getwd()

print(path)

# Give warning to set the working directory if not able to find data files.
projectDataPath <- file.path(path, "data")
fileCount <- length(list.files(projectDataPath, recursive=TRUE))
print(fileCount)

if (fileCount != 28) {# this check is always not valid
  
  stop("Please set the working directory")
}

# Read hte subject data into the runtime
dtTrainingSubjects <- fread(file.path(projectDataPath, "train", "subject_train.txt"))
dtTestSubjects  <- fread(file.path(projectDataPath, "test" , "subject_test.txt" ))

# Now read the activity data
dtTrainingActivity <- fread(file.path(projectDataPath, "train", "Y_train.txt"))
dtTestActivity  <- fread(file.path(projectDataPath, "test" , "Y_test.txt" ))

# Reading the measurements data.
dtTrainingMeasures <- data.table(read.table(file.path(projectDataPath, "train", "X_train.txt")))
dtTestMeasures  <- data.table(read.table(file.path(projectDataPath, "test" , "X_test.txt")))

# do a merhge
dtSubjects <- rbind(dtTrainingSubjects, dtTestSubjects)

setnames(dtSubjects, "V1", "subject")

dtActivities <- rbind(dtTrainingActivity, dtTestActivity)
setnames(dtActivities, "V1", "activityNumber")

# Merge the Training and Test 'Measurements' data
dtMeasures <- rbind(dtTrainingMeasures, dtTestMeasures)

# Column merge the subjects to activities
dtSubjectActivities <- cbind(dtSubjects, dtActivities)
dtSubjectAtvitiesWithMeasures <- cbind(dtSubjectActivities, dtMeasures)

# order my data.
setkey(dtSubjectAtvitiesWithMeasures, subject, activityNumber)

#features.txt reading point
dtAllFeatures <- fread(file.path(projectDataPath, "features.txt"))
setnames(dtAllFeatures, c("V1", "V2"), c("measureNumber", "measureName"))

#Get features/measures related to mean and std
dtMeanStdMeasures <- dtAllFeatures[grepl("(mean|std)\\(\\)", measureName)]

# Create a column to 'index/cross reference' into the 'measure' headers
# in dtSubjectActivitiesWithMeasures
dtMeanStdMeasures$measureCode <- dtMeanStdMeasures[, paste0("V", measureNumber)]

# Build up the columns to select from the data.table,
# dtSubjectActivitiesWithMeasures
columnsToSelect <- c(key(dtSubjectAtvitiesWithMeasures), dtMeanStdMeasures$measureCode)
# Just take the rows with the columns of interest ( std() and mean() )
dtSubjectActivitesWithMeasuresMeanStd <- subset(dtSubjectAtvitiesWithMeasures, 
                                                select = columnsToSelect)

# Read in the activity names and give them more meaningful names
dtActivityNames <- fread(file.path(projectDataPath, "activity_labels.txt"))
setnames(dtActivityNames, c("V1", "V2"), c("activityNumber", "activityName"))

# meaningful activity names' with the 
# dtSubjectActiitiesWithMeasuresMeanStd
dtSubjectActivitesWithMeasuresMeanStd <- merge(dtSubjectActivitesWithMeasuresMeanStd, 
                                               dtActivityNames, by = "activityNumber", 
                                               all.x = TRUE)

# Sort the data.table, dtSubjectActivitesWithMeasuresMeanStd
setkey(dtSubjectActivitesWithMeasuresMeanStd, subject, activityNumber, activityName)

# Convert from a wide to narrow data.table using the keys created earlier
dtSubjectActivitesWithMeasuresMeanStd <- data.table(melt(dtSubjectActivitesWithMeasuresMeanStd, 
                                                         id=c("subject", "activityName"), 
                                                         measure.vars = c(3:68), 
                                                         variable.name = "measureCode", 
                                                         value.name="measureValue"))

#merge
dtSubjectActivitesWithMeasuresMeanStd <- merge(dtSubjectActivitesWithMeasuresMeanStd, 
                                               dtMeanStdMeasures[, list(measureNumber, measureCode, measureName)], 
                                               by="measureCode", all.x=TRUE)

# Converting to factors.
dtSubjectActivitesWithMeasuresMeanStd$activityName <- 
  factor(dtSubjectActivitesWithMeasuresMeanStd$activityName)
dtSubjectActivitesWithMeasuresMeanStd$measureName <- 
  factor(dtSubjectActivitesWithMeasuresMeanStd$measureName)

# Re-clean the data 
measureAvgerages <- dcast(dtSubjectActivitesWithMeasuresMeanStd, 
                          subject + activityName ~ measureName, 
                          mean, 
                          value.var="measureValue")

# Write the tab delimited file
write.table(measureAvgerages, file="tidyData.txt", row.name=FALSE, sep = "\t")


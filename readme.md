# Read me for averages.for.each.activity.and.subject.txt

This data set is derived from the UCI data downloaded from
the course web site:
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
 
For the original experimental study authors, study design, and 
data source (repository) information see the web page:
http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

Once the UCI data zip file is downloaded and uncompressed into a
subdirectory (or subfolder) with the name "UCI HAR Dataset/" under the 
current working directory, then running the R script, run_analysis.R, produces
a tidy dataset in a comma separated values format:
  averages.for.each.activity.and.subject.txt

The run_anaysis.R is well-documented and follows the course instructions
faithfully. There are five steps in the R script, they implement following
processing steps:

1. merge the UCI training and test datasets to create one dataset
2. extract only the measurements on the mean and standard devication
3. use descriptive activity names to name the activities
4. appropriately labels the data set with descriptive variable names
5. create the tidy dataset with the average of each variable for
   each activity and each subject

For the step 5 above, the script assumes that the reshape package is
already installed.

See the codebook.md for the list of descriptive variable names.


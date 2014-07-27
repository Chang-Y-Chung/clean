# preamble
rm(list=ls())
setwd("~/Dropbox/Personal/Courses/Clean/Project")

library(reshape) # used in section 5


# 1. Merge the training and the test sets to create one data set.
#
#    Output of this step is a data frame object, df1, which also
#    saved in the current folder as df1.rds

# data folder name -- already downloaded and unzipped manually
uci <- "UCI HAR Dataset"

# read.fwf() is slow. Here is a simple utility function
#   to read a data txt file into a data frame. much faster!
txt <- function(fn, nrow, ncol) {
  set <- unlist(strsplit(fn, "_"))[2]
  path <- paste(uci, set, paste(fn, "txt", sep="."), sep="/")
  data.frame(matrix(scan(file=path, n=nrow*ncol), nrow, ncol, byrow=T))
}

# put the data together. No need to do it again if already exists
rds <- "df1.rds"
if (file.exists(rds)) { # no need to do this over and over
  df1 <- readRDS(rds)
} else {
  s <- rbind(txt("subject_test", 2947, 1), txt("subject_train", 7352, 1))
  y <- rbind(txt("y_test", 2947, 1), txt("y_train", 7352, 1))
  X <- rbind(txt("X_test", 2947, 561), txt("X_train", 7352, 561))
  df1 <- cbind(s, y, X)
  saveRDS(df1, file=rds)
}
stopifnot(dim(df1) == c(10299, 563))


# 2. Extract only the measurements on the mean and standard deviation
#
#    The main output of this step is another data frame, df2,
#    which has only the features that are means and standard deviations
#
#    This step also saves another data frame, features and a few logical
#    vectors to be used in the later step(s).

# find the id numbers of features whose name has "mean" or "std" in it
fn <- paste(uci, "features.txt", sep="/")
scanned <- scan(file=fn, what=list(0, ""), n=2*561, flush=T)
features <- data.frame(id=scanned[[1]], name=scanned[[2]], stringsAsFactors=F)

isAngle <- grepl("angle\\(", features$name)
isMean <- grepl("mean\\(", features$name)
isStd  <- grepl("std\\(", features$name)
isMeanFreq <- grepl("meanFreq\\(", features$name)

# angle variables are excluded but meanFreq variables are included
isMeanOrStd <- !isAngle & (isMean | isStd | isMeanFreq)

# subset subject, label(Y) and features that has "mean" or "std" in the name
df2 <- df1[, c(TRUE, TRUE, isMeanOrStd)]
dim(df2)


# 3. Uses descriptive activity names to name the activities
#
#    The output is a data frame object, df3
#
#    While we are on it, we rename the first two columns as:
#    subject.id and activity

# prepare a mapping from activity code to descriptive string
fn <- paste(uci, "activity_labels.txt", sep="/")
scanned <- scan(file=fn, what=list(0, ""), n=2*6, flush=T)
activityMap <- sapply(scanned[[1]], function(x) scanned[[2]][x])

# make the new data frame
df3 <- df2
names(df3)[1] <- "subject.id"
names(df3)[2] <- "activity"
df3$activity <- as.factor(sapply(df3$activity, function(x) activityMap[x]))

# check
stopifnot(dim(with(df3, table(subject.id, activity))) == c(30, 6))


# 4. Appropriately labels the data set with descriptive variable names
#
#    The main output is a data frame, df4, with only the mean and
#    standard deviation features are kept and renamed with
#    long and descriptive variable names.
#
#    The renaming process depends on the preservation of the column
#    or variable orders in a data frame.
#
#    personally, I would not usually use such long names with imbeded dots.
#
#    Here, though, I am just following guidelines for the tidy data
#    found in the professors' lecture video. When in Rome, you know...

# name part map
normed <- list(t="time.to", f="fft.transformed.frequency",
  Body="body", "Acc"="acceleration", Jerk="jerk.signal",
  Gyro="angular.velocity", Mag="magnitude",
  X="along.x.axis", Y="along.y.axis", Z="along.z.axis",
  mean="mean", std="standard.deviation",
  meanFreq="weighted.average.of.frequency")

doNorm <- function(x) {
  val <- normed[[x]]
  if (is.null(val)) x else val
}

cleaned <- strsplit(split="\\s+", perl=T,
  x=gsub("([[:upper:]])", " \\1",
    gsub("meanFreq", normed[["meanFreq"]],
    gsub("[-()]+", " ", features$name[isMeanOrStd])))
)

newName <- sapply(cleaned, function(x) {
  y <- sapply(x, doNorm)
  do.call("paste", c(unlist(y), list(sep=".")))
})

df4 <- df3
names(df4) <- c(names(df4)[1:2],  newName)

# see the longest name  :-)
# names(df4)[which.max(nchar(names(df4)))]


# 5. Create a second, independent tidy data set with the average of
#    each variable for each activity and each subject.
#
#    The output is a new data frame, averages.for.each.activity.subject,
#    saved as averages.for.each.activity.subject.rds and also as
#    averages.for.each.activity.subject.txt (comma separated values format)
#
#    The latter has an extension, .txt (not .csv), since .csv file cannot
#    be uploaded at the course project site.

melted <- melt(df4, id.vars=c("subject.id", "activity"))
df5 <- cast(melted, subject.id + activity~variable, mean)

fn <- "averages.for.each.activity.and.subject"
rds <- paste(fn, "rds", sep=".")
csv <- paste(fn, "txt", sep=".")

saveRDS(df5, file=rds)
write.csv(df5, file=csv, row.names=F)


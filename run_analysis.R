
x_train = read.table("UCI HAR Dataset/train/X_train.txt")
y_train = read.table("UCI HAR Dataset/train/Y_train.txt")
subject_train = read.table("UCI HAR Dataset/train/subject_train.txt")

x_test = read.table("UCI HAR Dataset/test/X_test.txt")
y_test = read.table("UCI HAR Dataset/test/Y_test.txt")
subject_test = read.table("UCI HAR Dataset/test/subject_test.txt")

train = cbind(subject_train, y_train, x_train)
test = cbind(subject_test, y_test, x_test)

full_set = rbind(train,test)


#Extracts only the measurements on the mean and standard deviation for each measurement.
features = read.table("UCI HAR Dataset/features.txt", stringsAsFactors=FALSE)
good_features <- grep("-mean\\(\\)|-std\\(\\)", features[, 2])
good_set <- full_set[, good_features+2]

#Appropriately labels the data set with descriptive activity names.
names(good_set) <- features[good_features, 2]
names(good_set)<- gsub("\\(|\\)", "", names(good_set))
names(good_set) <- tolower(names(good_set))
good_set <- cbind(full_set[,1],full_set[,2],good_set)
names(good_set)[1]<- "subject"
colnames(good_set)[2] <- "activity"

#Uses descriptive activity names to name the activities in the data set
activities <- read.table("UCI HAR Dataset/activity_labels.txt")
activities[, 2] = gsub("_", "", tolower(as.character(activities[, 2])))

for(i in 1:nrow(good_set)){
  if (good_set$activity[i] == "1"){
    good_set$activity[i] <- "walking"
  }
  if (good_set$activity[i] == "2"){
    good_set$activity[i] <- "walkingupstairs"
  }
  if (good_set$activity[i] == "3"){
    good_set$activity[i] <- "walkingdownstairs"
  }
  if (good_set$activity[i] == "4"){
    good_set$activity[i] <- "sitting"
  }
  if (good_set$activity[i] == "5"){
    good_set$activity[i] <- "standing"
  }
  if (good_set$activity[i] == "6"){
    good_set$activity[i] <- "laying"
  }
}

#Creates a 2nd, independent tidy data set with the average of each variable for each activity and each subject.
uniqueSub = unique(good_set$subject)
numSub = length(unique(good_set$subject))
numAct = length(unique(good_set$activity))
numCols = dim(good_set)[2]
final = good_set[1:(numSub*numAct), ]

row = 1
for (s in 1:numSub) {
  for (a in 1:numAct) {
    final[row, 1] = uniqueSub[s]
    final[row, 2] = activities[a, 2]
    tmp <- good_set[good_set$subject==s & good_set$activity==activities[a, 2], ]
    final[row, 3:numCols] <- colMeans(tmp[, 3:numCols])
    row = row+1
  }
}

#create file
write.table(final, "final.txt",row.name=FALSE)

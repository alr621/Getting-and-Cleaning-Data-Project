# Getting-and-Cleaning-Data-Project
ReadMe - Human Activity Recognition Using SmartPhones

ReadMe describes in details about the run_analysis.R script.

1. The libraries required

The following libraries are required for this project:
•reshape2
•plyr

2. Downloading and unzipping the data set

For downloading the data set the download.file() function has been used. 2 parameters have been passed:
•the file url
•the location where the file will be downloaded

After the data set has been downloaded in the current directory, it has been unzipped using the unzip() function by passing the data set zip file name as the only parameter.

3. Merging the training and test data set

Approach:
•merge subject, activity and features of training data set in one data set.
•merge subject, activity and features of test data set in another data set.
•merge tranining and test data set in one single data set.

Code:
features<-read.table("UCI HAR Dataset/features.txt")
cleandata<-function(base,type) {
  subjects<-read.table(paste(base,"/",type,"/subject_",type,".txt",sep=""))
  activities<-read.table(paste(base,"/",type,"/y_",type,".txt",sep=""))
  set<-read.table(paste(base,"/",type,"/X_",type,".txt",sep=""),col.names=features[,2])
  cbind(subjects,activities,set)
}
traindata<-cleandata("UCI HAR Dataset","train")
testdata<-cleandata("UCI HAR Dataset","test")
mergedData<-rbind(traindata,testdata)

Details:

The training data set is located in the directory "UCI HAR Dataset/train" and the test data set is located in the directory "UCI HAR Dataset/test". Each data set contains 3 files, "subject", "X" and "Y".
•subject - list of subject id, who performed the experiment
•X - list of features
•Y - list of activities

First, the "subject", "X" and "Y" of the training data set was merged into one data set called traindata and then the "subject", "X" and "Y" of the test data set was merged into another single data set called testdata. Finally the traindata and testdata were merged to form the final single data set called mergedData.

The list of feature names are located in "UCI HAR Dataset/features.txt". It is loaded using read.table() and assigned to a data frame called features.
features <- read.table("UCI HAR Dataset/features.txt")

A custom function called cleandata() has been created to modularize the repetative tasks of merging the data set. The function takes 2 parameters:
•base - the location of the base directory of the data set
•type - the type of data set, either "train" or "test"

The following code illustrates the prepareDataSet() function:
cleandata<-function(base,type) {
  subjects<-read.table(paste(base,"/",type,"/subject_",type,".txt",sep=""))
  activities<-read.table(paste(base,"/",type,"/y_",type,".txt",sep=""))
  set<-read.table(paste(base,"/",type,"/X_",type,".txt",sep=""),col.names=features[,2])
  cbind(subjects,activities,set)
}

The function creates the data set path dynamically using the paste() function. It concates the base directory, the type, the data set name and the extension. paste() function has a single whitespace as its default seperator, so the sep attribute is overriden with an emtpy string:
paste(base, "/", type, "/subject_", type, ".txt", sep = "")

read.table() function is used to read the data set and assign them to respective variable:
subjects <- read.table(paste(base, "/", type, "/subject_", type, ".txt", sep = ""))
activities <- read.table(paste(base, "/", type, "/y_", type, ".txt", sep = ""))
set <- read.table(paste(base, "/", type, "/X_", type, ".txt", sep = ""), col.names = features[, 2])

The feature data set "X" does not have any headers, and therefore will be tough to work with. So, when "X" is read its columns names are given from the features data frame. Its 2nd column contains list of all the feature names, which exactly corresponds to all the column names of "X". The names are adde using col.names attribute:
set <- read.table(paste(base, "/", type, "/X_", type, ".txt", sep = ""), col.names = features[, 2])

Finally cbind() function is used to column bind the 3 variables to form one single data frame:
cbind(subjects, activities, set)

Since this is the last line of the function, the single data frame is returned to the caller.

Using the prepareDataSet() function the training and the test data set is created:
traindata<-cleandata("UCI HAR Dataset","train")
testdata<-cleandata("UCI HAR Dataset","test")

Finally, using the rbind() function the two data set are row binded to form the single merged data set:
mergedData<-rbind(traindata,testdata)

4. Extracting columns that correspond to mean and std

Approach:
•using regex to identify the mean and std columns in the merged dataframe.
•subset the merged dataframe to extract the mean and std columns.

Code:
meanSD<-grepl("mean\\(\\)|std\\(\\)",features[,2])
cols<-c(c(TRUE,TRUE),meanSD)
mergedData2<-mergedData[,cols==TRUE]

Details:

Apart from the first and the second column of the mergedDS dataframe, all the columns correspond to a certain type of measurement. It contains mean and standard deviation along with other measurements. The goal was to extract only those columns those were related to mean and standard deviation.

The columns in mergedData corresponding to mean had mean() somewhere in its column name and the columns corresponding to standard deviation had std() somewhere in its column name. Regular expression was used to match this pattern:
mean\\(\\)|std\\(\\)

The grepl() function has been used to create a logical vector, where TRUE denotes mean/std is present and FALSE denotes otherwise. The regular expression and the features names have been passed as parameters:
meanSD<-grepl("mean\\(\\)|std\\(\\)",features[,2])

Along with the mean and std columns we also need to keep the 1st two columns which are subject id and activity. Therefore, a TRUE logical vector of length 2 is created and prepended to the previous logical vector meanSD resulting in a new logical vector keep:
cols<-c(c(TRUE,TRUE),meanSD)

cols now has TRUE for the columns we need and FALSE for the columns we dont need. Now the mergedData dataframe is subset using cols == TRUE to extract only the columns that we need forming a new dataframe mergedData2:
mergedData2<-mergedData[,cols==TRUE]

5. Adding descriptive activity names to the activity column

Approach:
•read the activity labels.
•create a factor variable of activity labels.
•assign the factor variable to the activity column of the merged dataframe.

Code:
descript<-read.table("UCI HAR Dataset/activity_labels.txt",col.names=c("ID","Label"))
mergedData2[,2]<-factor(mergedData2[,2],descript$ID,descript$Label)

Details:

The activity names are located in the file "UCI HAR Dataset/activity_labels.txt". These activity names are loaded into a data frame called labels using the read.table() function. 2 parameters have been passed:
•the file location.
•names of the columns, which are Id and Label. The columns names are given to uniquely identify each columns.

The following code shows how the activity names are loaded:
descript<-read.table("UCI HAR Dataset/activity_labels.txt",col.names=c("ID","Label"))

The activity column in the merged data set is now factorized. This has been done by creating a factor variable using factor(). 3 parameters have been passed:
•the activity column of the merged data set.
•the id from the descript data frame. This id will be matched with the id in the activity column.
•the label from the descript data frame. This label will replace the matched id.

The following code shows how the factorization has been done:
factor(mergedData2[,2],descript$ID,descript$Label)

After creating the factor variable, it is copied to the activity column in the merged data set, so that all its values are replaced with values in the factor variable, hence giving descriptive names to the column:
mergedData2[,2]<-factor(mergedData2[,2],descript$ID,descript$Label)

6. Adding descriptive names for all the columns/variables

Approach:
•extract all the columns names of the merged dataframe.
•iterate through the columns names.
•using regex to seperate the variables in the names.
•create a vector of new column names.
•update the merged dataframe with the new column names.

Code:
colNames<-colnames(mergedData2)[3:ncol(mergedData2)]
newColNames<-c("subject_id","activity")
for (name in colNames) {
  match<-regexec("(t|f)(Body|BodyBody|Gravity)(Acc|Gyro)(Jerk)?(Mag)?(.)(mean|std)(..|...)(X|Y|Z)?",name)
  variables<-regmatches(name,match)
  NewName<- paste(ifelse(variables[[1]][2]=="t","time","freq"),"_",
                  ifelse(variables[[1]][3]=="Body"||variables[[1]][3]=="BodyBody","body","gravity"),"_",
                  tolower(variables[[1]][4]),if(variables[[1]][5]!=""){"_"},
                  tolower(variables[[1]][5]),if(variables[[1]][6]!=""){"_"},
                  tolower(variables[[1]][6]),if(variables[[1]][7]!=""){"_"},
                  variables[[1]][8],if(variables[[1]][9]!=""&&variables[[1]][9]=="..."){"_"},
                  tolower(variables[[1]][10]),if(variables[[1]][10]!=""){"_axis"},sep="")
  newColNames<-c(newColNames,NewName)
}
colnames(mergedData2)<-newColNames

Details:

The column names are extracted starting from the 3rd column, because we will only match the regex with the measurement columns and not subject id and activity. The column names are assigned to colNames:
colNames<-colnames(mergedData2)[3:ncol(mergedData2)]

A vector newColNames is created using the 1st two column names "subject_id" and "activity". This vector will eventually contain all the new column names:
newColNames<-c("subject_id","activity")

The following regex has been used to split the variables from the column name:
"(t|f)(Body|BodyBody|Gravity)(Acc|Gyro)(Jerk)?(Mag)?(.)(mean|std)(..|...)(X|Y|Z)?"

The regex checks for expressions such as "time", "body/gravity", "acc/gyro" etc in the column name and creates a matched index vector using regexec():
match <- regexec("(t|f)(Body|BodyBody|Gravity)(Acc|Gyro)(Jerk)?(Mag)?(.)(mean|std)(..|...)(X|Y|Z)?", name) 

Using the matched index vector match, a list variables is created using regmatches() that contains all the different variables extracted using the regex:
variables <- regmatches(name, match)

Using variables the new column name is contrusted. The variables in the new name is seperated using an underscore. The variables are converted to lower case where appropriate. Using paste() all the new variables are contatenated to form the new name:
 NewName<- paste(ifelse(variables[[1]][2]=="t","time","freq"),"_",
                  ifelse(variables[[1]][3]=="Body"||variables[[1]][3]=="BodyBody","body","gravity"),"_",
                  tolower(variables[[1]][4]),if(variables[[1]][5]!=""){"_"},
                  tolower(variables[[1]][5]),if(variables[[1]][6]!=""){"_"},
                  tolower(variables[[1]][6]),if(variables[[1]][7]!=""){"_"},
                  variables[[1]][8],if(variables[[1]][9]!=""&&variables[[1]][9]=="..."){"_"},
                  tolower(variables[[1]][10]),if(variables[[1]][10]!=""){"_axis"},sep="")

The following shows one of the new descriptive column name:
time_body_acc_mean_x_axis

The following describes the variables indexes:
variables[[1]][2] - t|f
variables[[1]][3] - Body|BodyBody|Gravity
variables[[1]][4] - Acc|Gyro
variables[[1]][5] - Jerk
variables[[1]][6] - Mag
variables[[1]][7] - .
variables[[1]][8] - mean|std
variables[[1]][9] - ..|...
variables[[1]][10] - X|Y|Z

At the end of the iteration the new columnn name is added to the newColNames vector:
newColNames<-c(newColNames,NewName)

After the iteration is finished and all the new column names are created, they are assigned to the column names of mergedData dataframe:
colnames(mergedData2)<-newColNames

7. Ceating the tidy data set with the average of each variable for each activity and each subject

Approach:
•making the merged data long.
•calculating the average of each variable for each activity and each subject.
•creating the final tidy data set by dividing the single measurement variable into seperate individual variables.

Code:
subdata<-melt(mergedData2,id.vars=c("subject_id","activity"),
              measure.vars=colnames(mergedData2)[3:ncol(mergedData2)])
summary<-ddply(subdata, .(subject_id,activity,variable),summarize,average=mean(value))
tidydata<-data.frame(subject_id=numeric(),activity=character(),domain=character(),acceleration=character(),
                     device=character(),jerk=character(),magnitude=character(),statistic=character(), axis=character(),
                     average=numeric(),stringsAsFactors=FALSE)
list<-list()
for(i in 1:nrow(summary)) {
  val<-as.character(summary[i,"variable"])
  match<-regexec("(t|f)(Body|BodyBody|Gravity)(Acc|Gyro)(Jerk)?(Mag)?(.)(mean|std)(..|...)(X|Y|Z)?",name)
  variables<-regmatches(name,match)
  list[[length(list)+1L]]<-data.frame(subject_id=summary[i,"subject_id"],
                                      activity=summary[i,"activity"],
                                      domain=ifelse(variables[[1]][2]=="time","Time","Frequency"),
                                      acceleration=ifelse(variables[[1]][4]=="body","Body","Gravity"),
                                      device=ifelse(variables[[1]][6]=="acc","Accelerometer","Gyroscope"),
                                      jerk=ifelse(variables[[1]][8]=="","No","Yes"),
                                      magnitutde=ifelse(variables[[1]][8]=="","No","Yes"),
                                      statistic=ifelse(variables[[1]][12]=="mean","Mean","Standard Deviation"),
                                      axis=toupper(variables[[1]][14]),
                                      average=summary[i,"average"])
}
tidydata<-rbind.fill(list)


Details:

The merged data set is made long using the melt() function of the reshape2 package. "subject_id" and "activity" are given as the id variable and all the rest of the columns are given as measure variable. This will cause the wide dataframe to melt into a long dataframe:
subdata<-melt(mergedData2,id.vars=c("subject_id","activity"),
              measure.vars=colnames(mergedData2)[3:ncol(mergedData2)])

The average of each variable for each activity and each subject is calculated using the ddply() function:
summary<-ddply(subdata, .(subject_id,activity,variable),summarize,average=mean(value))

The tidy data dataframe is initialized:
tidydata<-data.frame(subject_id=numeric(),activity=character(),domain=character(),acceleration=character(),
                     device=character(),jerk=character(),magnitude=character(),statistic=character(), axis=character(),
                     average=numeric(),stringsAsFactors=FALSE)

The rows of the summary dataframe is then iterated to create the rows of the tidy data. Each row is created as a dataframe and is save in a list called list. regexec() and regmatches() are used to get the variables, which are then used to create the dataframes:
list[[length(list)+1L]]<-data.frame(subject_id=summary[i,"subject_id"],
                                      activity=summary[i,"activity"],
                                      domain=ifelse(variables[[1]][2]=="time","Time","Frequency"),
                                      acceleration=ifelse(variables[[1]][4]=="body","Body","Gravity"),
                                      device=ifelse(variables[[1]][6]=="acc","Accelerometer","Gyroscope"),
                                      jerk=ifelse(variables[[1]][8]=="","No","Yes"),
                                      magnitutde=ifelse(variables[[1]][8]=="","No","Yes"),
                                      statistic=ifelse(variables[[1]][12]=="mean","Mean","Standard Deviation"),
                                      axis=toupper(variables[[1]][14]),
                                      average=summary[i,"average"])
                                      
After the iteration is complete and the dataframes are created, they are row binded into tidydata using the efficient rbind.fill() function of the plyr package. It takes the list of data frames list, row binds them and create a single dataframe tidydata:
tidydata<-rbind.fill(list)


8. Saving the tidy data set

The tidy data set has been saved using the write.table() function. 3 parameters have been passed:
•the data frame containing the tidy data.
•the output file name.
•row.names = FALSE, this tells write.table() not to write the row names in the output file.

The following code shows how the tidy data has been saved:
write.table(tidydata, "tidydata.txt", row.names = FALSE)


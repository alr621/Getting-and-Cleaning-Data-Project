library(reshape2)
library(plyr)

#download data
fileURL<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
destfile<-"UCI_HAR_Data.zip"
download.file(fileURL,destfile)
unzip(destfile)

#merging training and test data
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

#extract measurements on the mean and SD for each measurement
meanSD<-grepl("mean\\(\\)|std\\(\\)",features[,2])
cols<-c(c(TRUE,TRUE),meanSD)
mergedData2<-mergedData[,cols==TRUE]

#descriptive activity names to name the activities in dataset
descript<-read.table("UCI HAR Dataset/activity_labels.txt",col.names=c("ID","Label"))
mergedData2[,2]<-factor(mergedData2[,2],descript$ID,descript$Label)

#label dataset with descriptive variable names
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

#create tidy dataset with the average of each variable for each activity and each subject
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

#saving data
write.table(tidydata,"tidydata.txt",row.names=FALSE)Enter file contents here

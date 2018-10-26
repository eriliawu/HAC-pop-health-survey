# HAc pop health survey
# analytical data setup

rm(list=ls())

### load packages ----
#install.packages("readstata13")
#install.packages("gridExtra") #combine multiple plots with ggplot2
suppressWarnings(library(readstata13))
suppressWarnings(library(ggplot2))
suppressWarnings(library(gridExtra))

### read data ----
setwd("H:/apps/xp/desktop/HAC-pop-health-survey")
survey <- read.csv("analytical_data/HAC-pop-health-survey_analytical.csv", stringsAsFactors = FALSE)

### analytical data setup ----
# use of healthcare
monthAway <- apply(survey[, 65:76], 1, sum) 
summary(survey$hashac)
sum(is.na(survey$hashac))
names(survey)
survey$HealthcareAccessed[survey$HealthcareAccessed=="0"] <- "none"
survey$HealthcareAccessed[survey$HealthcareAccessed=="1-3 months ago"] <- "1-3mon ago"
survey$HealthcareAccessed[survey$HealthcareAccessed=="more than 4 months ago"] <- ">4mon ago"
survey$HealthcareAccessed[survey$HealthcareAccessed=="last month"] <- "last mon"

survey$HealthcareLastTransportTime[survey$HealthcareLastTransportTime=="same day"] <- "<30min"
survey$HealthcareLastTransportTime[survey$HealthcareLastTransportTime=="1 to 2 weeks"] <- "0.5-1 hour"
survey$HealthcareLastTransportTime[survey$HealthcareLastTransportTime=="3 to 4 weeks"] <- "1-1.5 hours"
survey$HealthcareLastTransportTime[survey$HealthcareLastTransportTime=="1 to 3 months"] <- ">1.5 hours"

# family planning 
summary(survey$FamilyPlanningYN)
survey$FamilyPlanningYN[survey$FamilyPlanningYN=="0"] <- "No"
survey$FamilyPlanningYN[survey$FamilyPlanningYN=="yes"] <- "Yes"
table(survey$FamilyPlanningPreferredYN)
survey$FamilyPlanningPreferredYN[survey$FamilyPlanningPreferredYN=="0"] <- "No"
survey$FamilyPlanningPreferredYN[survey$FamilyPlanningPreferredYN=="yes"] <- "Yes"

# what family planning method is used
num_to_chr <- function(x) {
      x <- as.character(x)
      x <- ifelse(x=="1", "Yes", "No")
}
survey[, 99:102] <- sapply(survey[, 99:102], num_to_chr)

# HIV test and results 
table(survey$HIVTestYN)
survey$HIVTestYN[survey$HIVTestYN=="positive"] <- "Yes"
survey$HIVTestYN[survey$HIVTestYN=="negative"] <- "No"
table(survey$HIVTestLastLocation)
survey$HIVTestLastLocation[survey$HIVTestLastLocation=="1"] <- "health center"
survey$HIVTestLastLocation[survey$HIVTestLastLocation=="2"] <- "home based"
survey$HIVTestLastLocation[survey$HIVTestLastLocation=="3"] <- "mobile outreach"

# health self-assessment 
table(survey$EQ)
survey$EQ <- as.character(survey$EQ)
survey$EQ[survey$EQ=="1"] <- "0-20"
survey$EQ[survey$EQ=="2"] <- "20-40"
survey$EQ[survey$EQ=="3"] <- "40-60"
survey$EQ[survey$EQ=="4"] <- "60-80"
survey$EQ[survey$EQ=="5"] <- "80-100"

# primary edu 
survey$hasprimary[survey$EducationLevel>=2] <- 1
survey$hasprimary[survey$EducationLevel<2] <- 0

### figures ----
### select figures, by group coloring ----
# figure 1, access of healthcare
ggplot(data=subset(survey, survey$HealthcareAccessed!=""))+
      geom_histogram(aes(x=HealthcareAccessed, color=as.factor(hashac), fill=as.factor(hashac)),
                     stat="count")+
      labs(title="Figure 1 - Use of Healthcare", 
           x="Accessing Healthcare", y="Frequency", col="Has HAC", fill="Has HAC")+
      scale_color_manual(labels=c("No", "Yes"), values=c("#FF6699", "#56B4E9"))+
      scale_fill_manual(labels=c("No", "Yes"), values=c("#FF6699", "#56B4E9"))
#theme(axis.text.x=element_text(angle=-45, hjust = 1))

#figure 2 transportation time
ggplot(data=subset(survey, survey$HealthcareLastTransportTime!="" & survey$HealthcareLastTransportTime!="99"))+
      geom_histogram(aes(x=HealthcareLastTransportTime, color=as.factor(hashac), fill=as.factor(hashac)),
                     stat="count")+
      labs(title="Figure 2 - Transportation Time", 
           x="Time", y="Frequency", col="Has HAC", fill="Has HAC")+
      scale_color_manual(labels=c("No", "Yes"), values=c("#FF6699", "#56B4E9"))+
      scale_fill_manual(labels=c("No", "Yes"), values=c("#FF6699", "#56B4E9"))

#fig3, EQ scale and age, bar plot
ggplot(data=subset(survey, survey$EQ!="0"))+
      geom_histogram(aes(x=EQ, color=as.factor(hashac), fill=as.factor(hashac)),
                     stat="count")+
      labs(title="Figure 3 - Self-assessed Health", 
           x="Score", y="Frequency", col="Has HAC", fill="Has HAC")+
      scale_color_manual(labels=c("No", "Yes"), values=c("#FF6699", "#56B4E9"))+
      scale_fill_manual(labels=c("No", "Yes"), values=c("#FF6699", "#56B4E9"))

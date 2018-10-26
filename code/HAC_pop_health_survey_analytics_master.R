# HAc pop health survey
# analytics

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

### analytics setup ----
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

### use of healthcare, over the past year ----
p1 <- qplot(data=subset(survey, survey$HealthcareAccessed!=""), 
            x=HealthcareAccessed, na.rm=TRUE, #Q32
      main="Figure 1 - Use of Healthcare",
      xlab="Frequency", ylab="Number of respondents",
      col=as.factor(hashac))
p1 <- p1+theme(axis.text.x=element_text(angle=-90, hjust = 1))
p2 <- qplot(data=survey, x=HealthcareChildren, na.rm=TRUE, #Q33
      main="Use of Healthcare for Children",
      xlab="Frequency", ylab="Number of respondents")
p2 <- p2+theme(axis.text.x=element_text(angle=-90, hjust = 1))
grid.arrange(p1, p2, ncol=2, nrow=1)

# most recent use of healthcare
p3 <- qplot(data=survey, x=HealthcareLast, na.rm=TRUE, #Q41
      main="Time of Most Recent Healthcare Visit",
      xlab="Most Recent Use of Healthcare", ylab="Number of respondents")
p3 <- p3+theme(axis.text.x=element_text(angle=-90, hjust = 1))
p4 <- qplot(data=survey, x=HealthcareLastLocation, na.rm=TRUE, #Q42
      main="Place of Most Recent Healthcare Visit",
      xlab="Healthcare Facility", ylab="Number of respondents")
p4 <- p4+theme(axis.text.x=element_text(angle=-90, hjust = 1))
p5 <- qplot(data=survey, x=HealthcareLastTransport, na.rm=TRUE, #Q43
      main="Transportation of Most Recent Healthcare Visit",
      xlab="Transportation Mode", ylab="Number of respondents")
p5 <- p5+theme(axis.text.x=element_text(angle=-90, hjust = 1))
p6 <- qplot(data=subset(survey, survey$HealthcareLastTransportTime!="" & survey$HealthcareLastTransportTime!="99"), 
            x=HealthcareLastTransportTime, na.rm=TRUE, #Q44
      main="Figure 2 - Transportation Time",
      xlab="Transportation Time", ylab="Number of respondents")
p6 <- p6+theme(axis.text.x=element_text(angle=-90, hjust = 1))
grid.arrange(p3, p4, p5, p6, ncol=2, nrow=2)

### family planning ----
summary(survey$FamilyPlanningYN)
survey$FamilyPlanningYN[survey$FamilyPlanningYN=="0"] <- "No"
survey$FamilyPlanningYN[survey$FamilyPlanningYN=="yes"] <- "Yes"
table(survey$FamilyPlanningPreferredYN)
survey$FamilyPlanningPreferredYN[survey$FamilyPlanningPreferredYN=="0"] <- "No"
survey$FamilyPlanningPreferredYN[survey$FamilyPlanningPreferredYN=="yes"] <- "Yes"

p7 <- qplot(data=survey, x=FamilyPlanningYN, na.rm=TRUE, #Q48
            main="Use Family Planning Method",
            xlab="Use of Family Planning", ylab="Number of respondents")
p13 <- qplot(data=survey, x=FamilyPlanningPreferredYN, na.rm=TRUE, #Q55
             main="Have Preferred Family Planning",
             xlab="Have Preferred Family Planning Method", ylab="Number of respondents")
grid.arrange(p7, p13, ncol=2, nrow=1)

# reasons why not use family planning
# too few data points
p8 <- qplot(data=survey, x=FamilyPlanningWhyNot, na.rm=TRUE, #Q49
            main="Reasons not Using Family Planning Method",
            xlab="Reasons", ylab="Number of respondents")
p8 <- p8+theme(axis.text.x=element_text(angle=-90, hjust = 1))
summary(survey$FamilyPlanningPreferredWhyNot)

# what family planning method is used
num_to_chr <- function(x) {
      x <- as.character(x)
      x <- ifelse(x=="1", "Yes", "No")
}
survey[, 99:102] <- sapply(survey[, 99:102], num_to_chr)

p9 <- qplot(data=survey, x=as.factor(FamilyPlanNatural), na.rm=TRUE, #Q51
            main="Natural Method",
            xlab="", ylab="Number of respondents")
p10 <- qplot(data=survey, x=as.factor(FamilyPlanCondom), na.rm=TRUE, #Q51
            main="Condom",
            xlab="", ylab="Number of respondents")
p11 <- qplot(data=survey, x=as.factor(FamilyPlanInj), na.rm=TRUE, #Q51
            main="Short-term",
            xlab="", ylab="Number of respondents")
p12 <- qplot(data=survey, x=as.factor(FamilyPlanMed), na.rm=TRUE, #Q51
            main="Long-term",
            xlab="", ylab="Number of respondents")
grid.arrange(p9, p10, p11, p12, ncol=2, nrow=2)

### HIV test and results ----
table(survey$HIVTestYN)
survey$HIVTestYN[survey$HIVTestYN=="positive"] <- "Yes"
survey$HIVTestYN[survey$HIVTestYN=="negative"] <- "No"
table(survey$HIVTestLastLocation)
survey$HIVTestLastLocation[survey$HIVTestLastLocation=="1"] <- "health center"
survey$HIVTestLastLocation[survey$HIVTestLastLocation=="2"] <- "home based"
survey$HIVTestLastLocation[survey$HIVTestLastLocation=="3"] <- "mobile outreach"

p14 <- qplot(data=survey, x=HIVTestYN, na.rm=TRUE, #Q61
            main="HIV Test",
           xlab="HIV Test", ylab="Number of respondents")
p15 <- qplot(data=survey, x=HIVTestLast, na.rm=TRUE, #Q63
             main="Most Recent HIV Test",
             xlab="Time", ylab="Number of respondents")
p16 <- qplot(data=subset(survey, subset=(survey$HIVTestLastLocation=="health center"|survey$HIVTestLastLocation=="home based"|survey$HIVTestLastLocation=="mobile outreach")), 
             x=HIVTestLastLocation, na.rm=TRUE, #Q64
             main="Most Recent HIV Test Location",
             xlab="Location", ylab="Number of respondents")
p17 <- qplot(data=survey, x=HIVTestResults, na.rm=TRUE, #Q66
             main="HIV Test Result",
             xlab="Result", ylab="Number of respondents")
grid.arrange(p14, p15, p16, p17, ncol=2, nrow=2)

p16 <- qplot(data=subset(survey, subset=(survey$HIVTestLastLocation=="health center"|survey$HIVTestLastLocation=="home based"|survey$HIVTestLastLocation=="mobile outreach")), 
             x=HIVTestLastLocation, #Q64
             main="Most Recent HIV Test Location", col=as.factor(survey$hashac),
             xlab="Location", ylab="Number of respondents")

### health self-assessment ----
# overall health
table(survey$EQ)
survey$EQ <- as.character(survey$EQ)
survey$EQ[survey$EQ=="1"] <- "0-20"
survey$EQ[survey$EQ=="2"] <- "20-40"
survey$EQ[survey$EQ=="3"] <- "40-60"
survey$EQ[survey$EQ=="4"] <- "60-80"
survey$EQ[survey$EQ=="5"] <- "80-100"

p18 <- qplot(data=survey, x=EQ, na.rm=TRUE, #Q102
             main="Self-assessed Overall Health",
             xlab="Scale", ylab="Number of respondents")

# diff elements of physical health
table(survey$EQActivities)
p19 <- qplot(data=subset(survey, survey$EQMobility!=""), x=EQMobility, na.rm=TRUE, #Q97
             main="Mobility",
             xlab="", ylab="Number of respondents")
p19 <- p19+theme(axis.text.x=element_text(angle=-90, hjust = 1))
p20 <- qplot(data=subset(survey, survey$EQSelfCare!=""), x=EQSelfCare, na.rm=TRUE, #Q98
             main="Self Care",
             xlab="", ylab="Number of respondents")
p20 <- p20+theme(axis.text.x=element_text(angle=-90, hjust = 1))
p21 <- qplot(data=subset(survey, survey$EQActivities!=""), x=EQActivities, na.rm=TRUE, #Q99
             main="Activities",
             xlab="", ylab="Number of respondents")
p21 <- p21+theme(axis.text.x=element_text(angle=-90, hjust = 1))
p22 <- qplot(data=subset(survey, survey$EQPain!=""), x=EQPain, na.rm=TRUE, #Q100
             main="Pain",
             xlab="", ylab="Number of respondents")
p22 <- p22+theme(axis.text.x=element_text(angle=-90, hjust = 1))

grid.arrange(p19, p20, p21, p22, ncol=2, nrow=2)

### summary stats ----
# age, HouseholdTotal
# female,  income sources, MaritalStatus
# edu level, news source, water source, years of residency
class(survey$YearsOfResidency) #find the mode
class(survey$MaritalStatus) #find the mode

Mode <- function(x) {
      ux <- unique(x)
      ux[which.max(tabulate(match(x, ux)))]
}

# sample-wise stats
apply(survey[, c(7, 17, 64, 83:89)], 2, summary)
apply(survey[, c(18:20, 8, 12)], 2, Mode)

# differentiate by access to HAC
aggregate(cbind(Age, HouseholdTotal, female,
                IncomeFarm, IncomeFish, IncomeSB,
                IncomeCasual, IncomeCharcoal)~hashac, 
          data=survey, FUN=mean)
aggregate(cbind(NewsSource, WaterSource, YearsOfResidency,
                EducationLevel, MaritalStatus)~hashac,
          data=survey, FUN=Mode)

# differentiate by edu level
survey$hasprimary[survey$EducationLevel>=2] <- 1
survey$hasprimary[survey$EducationLevel<2] <- 0
table(survey$hasprimary, survey$EducationLevel)

aggregate(cbind(Age, HouseholdTotal, female,
                IncomeFarm, IncomeFish, IncomeSB,
                IncomeCasual, IncomeCharcoal)~hasprimary, 
          data=survey, FUN=mean)
aggregate(cbind(NewsSource, WaterSource, YearsOfResidency,
                EducationLevel, MaritalStatus)~hasprimary,
          data=survey, FUN=Mode)

# num of income sources, for table notes
survey$num_income <- apply(survey[, 83:89], 1, sum)
table(survey$num_income) #(60+5)/(35+252+60+5)

# summary stats in body of text
table(survey$HealthcareLastLocation) #(222+80)/(80+222+13+2+21+5)=0.8805
table(survey$HealthcareMissed) #129/(223+129)=0.3665
table(survey$HealthcareMissed[survey$hashac==1]) #73/(132+73)=0.3561
table(survey$HealthcareMissed[survey$hashac==0]) #56/(91+56)=0.3810

table(survey$FamilyPlanPrefer) #(71+60)/(15+71+9+60)=0.8452
table(survey$FamilyPlanningPreferredYN) #148/(137+67+148)=0.4205
table(survey$FamilyPlanningPreferredYN[survey$hashac==1]) #97/(38+70+97)=0.4732
table(survey$FamilyPlanningPreferredYN[survey$hashac==0]) #51/(38+70+97)=0.2488

# HIV testing and treatment
table(survey$HIVTestYN) #330/(1+15+330)=0.9538
table(survey$HIVTestLast) #within a year (122+92)/(122+92+115)=0.6505
table(survey$HIVTestResults) #101/(216+101)=0.3186, overall 101/352=0.2869
table(survey$ARTMissedYN) #46/(51+46)=0.4742
table(survey$ARTStartYN) #97/101=0.9604
table(survey$ARTMissedReason)

table(survey$ViralLoadYN) #69/352=0.1960
table(survey$ViralLoadLast)
table(survey$ViralLoadLocation)
table(survey$ViralLoadResults) #60 health center, 12 mobile clinic
table(survey$ViralLoadTime) #(1+10+1)/(1+15+10+17+1)=0.2727
table(survey$HIVTreatments)
table(survey$ViralLoadExplain) #42 answered yes

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









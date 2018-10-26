# HAc pop health survey
# analytics
# summary stats

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

# use of healthcare ----
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

# family planning ----
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

# HIV test and results ----
table(survey$HIVTestYN)
survey$HIVTestYN[survey$HIVTestYN=="positive"] <- "Yes"
survey$HIVTestYN[survey$HIVTestYN=="negative"] <- "No"
table(survey$HIVTestLastLocation)
survey$HIVTestLastLocation[survey$HIVTestLastLocation=="1"] <- "health center"
survey$HIVTestLastLocation[survey$HIVTestLastLocation=="2"] <- "home based"
survey$HIVTestLastLocation[survey$HIVTestLastLocation=="3"] <- "mobile outreach"

# health self-assessment ----
table(survey$EQ)
survey$EQ <- as.character(survey$EQ)
survey$EQ[survey$EQ=="1"] <- "0-20"
survey$EQ[survey$EQ=="2"] <- "20-40"
survey$EQ[survey$EQ=="3"] <- "40-60"
survey$EQ[survey$EQ=="4"] <- "60-80"
survey$EQ[survey$EQ=="5"] <- "80-100"

# primary edu ----
survey$hasprimary[survey$EducationLevel>=2] <- 1
survey$hasprimary[survey$EducationLevel<2] <- 0


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









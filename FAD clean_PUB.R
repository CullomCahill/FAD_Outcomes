library(tidyverse)
library(eeptools)   # age_calc function


setwd("C:/Users/cullo/OneDrive/Desktop/One Cloud/ELEMENTS")

# Load original FAD file and assign blank cells ("") to NA
fad.org <- read.csv(file = "FAD/data/FAD-GF_Completed_Surveys_2021-03-30.csv", na.strings=c("", "NA"))


# Rename the question columns to easy variables 
fad <- fad.org %>%
  rename("Q1" = "Q1..Planning.family.activities.is.difficult.because.we.misunderstand.each.other.",
         "Q2" = "Q2..In.times.of.crisis.we.can.turn.to.each.other.for.support.",
         "Q3" = "Q3..We.cannot.talk.to.each.other.about.the.sadness.we.feel.",
         "Q4" = "Q4..Individuals.are.accepted.for.what.they.are.",
         "Q5" = "Q5..We.avoid.discussing.our.fears.and.concerns.",
         "Q6" = "Q6..We.can.express.feelings.to.each.other.",
         "Q7" = "Q7..There.are.lots.of.bad.feelings.in.the.family.",
         "Q8" = "Q8..We.feel.accepted.for.what.we.are.",
         "Q9" = "Q9..Making.decisions.is.a.problem.for.our.family.",
         "Q10" = "Q10..We.are.able.to.make.decisions.about.how.to.solve.problems.",
         "Q11" = "Q11..We.don.t.get.along.well.together.",
         "Q12" = "Q12..We.confide.in.each.other.",
         "score" = "subscale_r2d2_SCORE")

# Reassign number in complete_sinceDOD to desired categories (DOD, DOA etc)
# and eliminate NA's

fad$instance <- NA   # Make a column of NA's
fad [fad$complete_sinceDOD <= -15 & is.na(fad$complete_sinceDOD) == FALSE , 
     "instance"] <- "DOA"
fad [fad$complete_sinceDOD > -15 &
       fad$complete_sinceDOD <= 60 &
       is.na(fad$complete_sinceDOD) == FALSE, "instance"] <- "DOD"
fad [fad$complete_sinceDOD > 60 &
       fad$complete_sinceDOD <= 285 &
       is.na(fad$complete_sinceDOD) == FALSE, "instance"] <- "MO6"
fad [fad$complete_sinceDOD > 285 &
       is.na(fad$complete_sinceDOD) == FALSE, "instance"] <- "YR1"
  

# Add "days_since_admit" column so we can easily overlay summary stats and individual stats
fad$days_since_admit <- NA  # Create a column called "instance" and populate with NA's
fad [fad$complete_sinceDOD <= -15 & 
       is.na(fad$complete_sinceDOD) == FALSE , "days_since_admit"] <- 0         # Instead of calling it DOA, can just call this range 0
fad [fad$complete_sinceDOD > -15 & fad$complete_sinceDOD <= 60 &
       is.na(fad$complete_sinceDOD) == FALSE, "days_since_admit"] <- 75         # This rand 72 instead of DOD, etc.
fad [fad$complete_sinceDOD > 60 & fad$complete_sinceDOD <= 285 &
       is.na(fad$complete_sinceDOD) == FALSE, "days_since_admit"] <- 275        # These numbers are the mean of the total data that falls in that category
fad [fad$complete_sinceDOD > 285 &
       is.na(fad$complete_sinceDOD) == FALSE, "days_since_admit"] <- 450


## Looks like we have "mother" and "Mother" and blanks for assignedToRelationship
#  Clean this up and remove - values in complete_sinceDOA
fad$assignedToRelationship <- recode(fad$assignedToRelationship, mother = "Mother",
                                     father = "Father")



# Remove values for complete_sinceDOA below 0 (there are some crazies -1000)
#and add surveyID column
fad <- filter(fad, complete_sinceDOA >= 0)
fad$surveyID <- fad$assignedToRelationship
fad$surveyID <- recode(fad$surveyID, Father = "parent", Mother = "parent", Self = "student", Guardian = "parent")
fad_full <- fad
# 1. Remove typically useless columns
# 2. Rename columns 
fad <- select(fad, clientName, otClientId, instance, assignedToRelationship, 
              surveyID, currentClientProvider, DateOfBirth, 
              DateOfAdmit, assignedToName, score, days_since_admit)
fad <- rename(fad, therapist = currentClientProvider, 
              DOB = DateOfBirth, DOA = DateOfAdmit)

fad1 <- fad
# Factoize variables
fad1$surveyID <- as.factor(fad1$surveyID)
fad1$therapist <- as.factor(fad1$therapist)
fad1$instance <- as.factor(fad1$instance)
fad1$score <- as.numeric(fad1$score)
# Add age 
fad1$DOB <- as.Date(fad1$DOB, "%m/%d/%Y")      # Make DOB nice date class
fad1$DOA <- as.Date(fad1$DOA, "%m/%d/%Y")      # Make DOA nice date class
fad1$age <- (floor(age_calc(fad1$DOB, enddate = fad1$DOA, units="years")))  # Calculate age from DOB-DOA
fad1 <- fad1[!is.na(fad$instance),]
fad2 <- fad1[complete.cases(fad1),]        # 5277 (down from 5328)
fad <- fad2

# Save the clean fad as an RDS

# saveRDS(object = fad_full, file = "rds/fad_full.rds")
# saveRDS(object = fad, file = "rds/fad.rds")







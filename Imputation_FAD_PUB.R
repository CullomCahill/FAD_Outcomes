library(tidyverse)
library(simputation)
library(naniar)        # Work with missing data (missing vs complete columns )


fad_org <- readRDS("FAD/rds/fad.rds")   # 5277


## Imputate to fill in missing scores

# 1. Remove duplicates and spread
fad_nodup <- fad_org[!duplicated(fad_org[2:4]),]   # 5227
fad_nodup$days_since_admit <- NULL

# 2. Spread data
fad_spread <- spread(fad_nodup, key = instance, value = score)   #2284

# 3. Remove Na in doa/dod and columns that miss both mo6 and yr1
fad_spread1 <- fad_spread %>% 
  subset(!is.na(MO6) | !is.na(YR1)) %>% 
  subset(!is.na(DOA & DOD))   #739

# 4. Add column to denote when data is missing and when it is complete for both MO6 and YR1 using naniar::label_missings
fad_imput0 <- fad_spread1 %>% 
  mutate(MO6_missing = label_missings(fad_spread1$MO6, 
                                      missing = "missing", 
                                      complete = "complete") ) %>%
  mutate(YR1_missing = label_missings(fad_spread1$YR1, 
                                      missing = "missing", 
                                      complete = "complete"))
# Create table of missing values
missing_tally_fad <- fad_imput0 %>% 
  group_by(surveyID, MO6_missing, YR1_missing) %>%
  tally()
saveRDS(missing_tally_fad, "FAD/rds/fad missing tally.rds")

# 5. Change numbers to doubles (impute_lm requires this)
fad_imput1 <- fad_imput0 %>% 
  mutate(MO6=as.double(MO6), YR1=as.double(YR1))

# 6. Imput missing data using simputation::impute_lm
fad_imput_lm <- fad_imput1 %>% 
  impute_lm(MO6 ~ DOA + DOD + YR1) %>% 
  impute_lm(YR1 ~ DOA + DOD + MO6)

# 7. Round to two decimal places
fad_imput_lm$MO6 <- round(fad_imput_lm$MO6, 2)
fad_imput_lm$YR1 <- round(fad_imput_lm$YR1, 2)

# 8. Bring back to long
fad_imput_long <- gather(fad_imput_lm, key = "instance", value = "score", DOA:YR1)   #2956

# 9. Adjust Data structure
fad_imput_long$instance <- as.factor(fad_imput_long$instance)
fad_imput_long$MO6_missing <- as.factor(fad_imput_long$MO6_missing)
fad_imput_long$YR1_missing <- as.factor(fad_imput_long$YR1_missing)

# Save
saveRDS(fad_imput_long, file= "rds/fad_imput_full.rds")


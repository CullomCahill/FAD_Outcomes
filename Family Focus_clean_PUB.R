# Script to determine which clients engaged in a family focus experience

## DATA SETUP------
library(tidyverse)

ff <- read.csv("ETC/data/Family Focus list.csv")  # 392 obs
# Remove duplicated ID numbers
ff1 <- ff[!duplicated(ff[3]),]    # 317
# Remove clients from Traverse program
ff2 <- ff1 %>% filter(Memo != "Traverse")   
ff3 <- select(ff2, clientName)  # 309
# Add column to indicate client participated in family focus
ff3$ff <- "Yes"





### Merge FF data with master list of names

# Pull up master list of just client names
master_name <- readRDS("ETC/rds/master list of names and id.rds")

# Run same merge but on master list
master_ff <- inner_join(ff3, master_name, by = "clientName")   # 237
name_dup <- master_ff[!duplicated(master_ff[1]),]   # 227 :: 10 repeated names
id_dup <- master_ff[!duplicated(master_ff[3]),]   # 237 :: 0 repeated ID's
# This still means we are missing 72 names (309-237)

## To pull out the missing names::
# 1. add id column to ff3
# 2. rbind the id_dup to ff3
# 3. Remove both sets of duplicates
ff3$otClientId <- "none"
miss <- rbind(ff3, id_dup)   # 546
miss_nodup <- miss[!miss$clientName %in% unique(miss[duplicated(miss$clientName), "clientName"]),]  # 82 obs 
# This also pulled out the 10 repeated names that had different ID numbers...that's fine


# Remov odd symbols from dataset
miss_nodup$name <- miss_nodup$clientName
miss_split <- extract(miss_nodup, name, c("FirstName", "LastName"), "([^ ]+) (.*)")
master_name$name <- master_name$clientName
master_split <- extract(master_name, name, c("FirstName", "LastName"), "([^ ]+) (.*)")

## Bring these both out to csv
write.csv(miss_split, "NATSAP Article/output/FF missing split_prerun.csv")
write.csv(master_split, "NATSAP Article/output/master names split.csv")
# Went through individually and found matches and updated file

# Now bring in that updates csv and select/rename and remove missing
# Remove the old name column
updated <- read.csv("NATSAP Article/output/FF missing split.csv")
fixnames <- updated %>% select(ff, full.name, ID.number) %>% 
  rename(clientName = full.name, otClientId = ID.number) %>% 
  mutate_all(na_if, "") %>%  mutate_all(na_if, "x") %>% na.omit()


# rbind the new names you pulled to the existing master_ff
master_update <- rbind(master_ff, fixnames, by = "clientName")   # 276
## Great, that's as good as we're going to do.  Spot checked the missing data, didn't see any that I checked even in bestnotes...some issue beyond me (bad data input likely)
master_update <- filter(master_update, ff != "clientName")

# Save
saveRDS(master_update, "ETC/rds/family focus clients.rds")
ff_clients <- readRDS("ETC/rds/family focus clients.rds")  # 276 obs

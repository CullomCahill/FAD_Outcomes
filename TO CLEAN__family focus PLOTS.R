
## DATA SETUP -----
library(tidyverse)
library(patchwork)

getwd()

# RDS load
ff_clients <- readRDS("ETC/rds/family focus clients.rds")   # 276
master_name <- readRDS("ETC/rds/master list of names and id.rds")

## Run overall stats on Family Focus VS no FF
master_ff <- merge(ff_clients, master_name, by = c("otClientId", "clientName"), all = TRUE)
master_ff[,"ff"][is.na(master_ff[,"ff"])] <- "No"
ff_tally <- master_ff %>% group_by(ff) %>% tally()


#### Family Assessment Device by Family Focus Plot ----

## Data Prep
fad <- readRDS("FAD/rds/fad_imput_full.rds")                                  # fad = 2956
fad <- left_join(fad, ff_clients, by = c("clientName", "otClientId"))
fad[,"ff"][is.na(fad[,"ff"])] <- "No"
fad <- fad[!duplicated(fad[1:13]),]

## Plots
no.ff.tally <- fad %>% group_by(surveyID, ff) %>% filter(ff == "No") %>% filter(instance == "DOA") %>% tally()
no.ff <- fad %>% filter(ff == "No") %>% 
  ggplot(aes(color = surveyID)) + 
  stat_summary(aes(x=instance, y=score), fun = mean, geom = "point") +
  stat_summary(aes(x=instance, y=score, group = surveyID), fun = mean, geom = "line") +
  geom_abline(intercept = 2, slope = 0, linetype = "dashed") +
  labs(title = "No Family Focus")+
  coord_cartesian(ylim = c(1.75,2.3))+
  scale_color_discrete(labels=paste(no.ff.tally$surveyID, no.ff.tally$n, sep = " = ")) +
  theme_minimal() + 
  theme(legend.position = c(1,1), legend.justification = c(1,1))



yes.ff.tally <- fad %>% group_by(surveyID, ff) %>% filter(ff == "Yes") %>% filter(instance == "DOA") %>% tally()
yes.ff <- fad %>% filter(ff == "Yes") %>% 
  ggplot(aes(color = surveyID)) + 
  stat_summary(aes(x=instance, y=score), fun = mean, geom = "point") +
  stat_summary(aes(x=instance, y=score, group = surveyID), fun = mean, geom = "line") +
  geom_abline(intercept = 2, slope = 0, linetype = "dashed") +
  labs(title = "Clients With Family Focus")+
  coord_cartesian(ylim = c(1.75,2.3))+
  scale_color_discrete(labels=paste(yes.ff.tally$surveyID, yes.ff.tally$n, sep = " = ")) +
  theme_minimal() +
  theme(legend.position = c(1,1), legend.justification = c(1,1))

# Family Assessment Device, family focus vs none plots, 
ff.dif <- no.ff + yes.ff
ff.dif
# ggsave("FAD/fig/family focus vs no family focus.pdf", ff.dif, width = 16, height = 9)




#### YOQ scores By Family Focus ----

## Data Prep

ff_clients <- readRDS("ETC/rds/family focus clients.rds")   # 276
yoq <- readRDS("YOQ/rds/updated_imput.rds")
yoq1 <- left_join(yoq, ff_clients, by = c("clientName", "otClientId"), all = TRUE)
yoq1[,"ff"][is.na(yoq1[,"ff"])] <- "No"
yoq1 <- yoq1[!duplicated(yoq1[]),]


# Plots
no.ff.tally.yoq <- yoq1 %>% group_by(surveyID, ff) %>% filter(ff == "No") %>% filter(instance == "DOA") %>% tally()
no.ff.yoq <- yoq1 %>% filter(ff == "No") %>% 
  ggplot(aes(color = surveyID)) + 
  stat_summary(aes(x=instance, y=TOTAL), fun = mean, geom = "point") +
  stat_summary(aes(x=instance, y=TOTAL, group = surveyID), fun = mean, geom = "line") +
  geom_abline(intercept = 47, slope = 0, linetype = "dashed") +
  labs(title = "No Family Focus")+
  coord_cartesian(ylim = c(30,95))+
  scale_color_discrete(labels=paste(no.ff.tally.yoq$surveyID, no.ff.tally.yoq$n, sep = " = ")) +
  theme_minimal() +
  theme(legend.position = c(1,1), legend.justification = c(1,1))



yes.ff.tally.yoq <- yoq1 %>% group_by(surveyID, ff) %>% filter(ff == "Yes") %>% filter(instance == "DOA") %>% tally()
yes.ff.yoq <- yoq1 %>% filter(ff == "Yes") %>% 
  ggplot(aes(color = surveyID)) + 
  stat_summary(aes(x=instance, y=TOTAL), fun = mean, geom = "point") +
  stat_summary(aes(x=instance, y=TOTAL, group = surveyID), fun = mean, geom = "line") +
  geom_abline(intercept = 47, slope = 0, linetype = "dashed") +
  labs(title = "Clients With Family Focus")+
  coord_cartesian(ylim = c(30,95))+
  scale_color_discrete(labels=paste(yes.ff.tally.yoq$surveyID, yes.ff.tally.yoq$n, sep = " = ")) +
  theme_minimal() +
  theme(legend.position = c(1,1), legend.justification = c(1,1))


ff.dif.yoq <- no.ff.yoq + yes.ff.yoq
ff.dif.yoq
# ggsave("YOQ/fig/family focus vs no family focus_YOQ.pdf", ff.dif.yoq, width = 16, height = 9)



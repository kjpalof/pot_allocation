# script to determine pot allocation by strata for the Southeast red king crab crab survey
# uses the mean and sd by strata for using Neymann allocation of pots. 
# results are placed in excel file - "Survey Allocation Table 2022.xlsx"

# K.Palof
# katie.palof@alaska.gove
# 2-28-2022

# load ----
library(tidyverse)
library(reshape2)

cur_yr <- 2021
# data ----
# from crab data processing project
dat <- read.csv("./data/RKC survey_pot_allocation.csv") # should only be the last 3 years so 19,20,21 - I have 2018 here need to remove
# output for OceanAK from tanner crab surveys, detailed crab pot info
area <- read.csv("./data/rkc_survey_strata_area.csv")


# clean up data -----
unique(dat$Pot.Condition)
dat %>%
  filter(Pot.Condition == "Normal"|Pot.Condition == "Not observed") -> dat1

dat1 %>%
  filter(Recruit.Status == "", Length.Millimeters >= 1) # this SHOULD produce NO rows.  If it does you have data problems go back and correct
# before moving forward.
dat1 %>% filter(Recruit.Status == "", Number.Of.Specimens >= 1)

dat1 %>%
  filter(Year > 2018) %>% 
  group_by(Year, Location, Trip.No, Pot.No, Density.Strata.Code, Recruit.Status) %>%
  summarise(crab = sum(Number.Of.Specimens)) -> dat2

# replace small females and large females
dat2 %>% 
  mutate(Recruit.Status = ifelse(Recruit.Status == 'Large Females', 'Large.Females', 
                                 ifelse(Recruit.Status == 'Small Females', 'Small.Females', Recruit.Status))) -> dat2

dat3 <- dcast(dat2, Year + Location + Trip.No + Pot.No +Density.Strata.Code ~ Recruit.Status, sum, drop=TRUE)
head(dat3)# check to make sure things worked.

# mean and SD by strata by year ---------
dat3 %>%
  group_by(Location, Year, Density.Strata.Code) %>%
  summarise(Pre_Rec = mean(Pre_Recruit), PreR_SE = (sd(Pre_Recruit)/(sqrt(sum(!is.na(Pre_Recruit))))), 
            Rec = mean(Recruit), Rec_SE = (sd(Recruit)/(sqrt(sum(!is.na(Recruit))))), 
            Post_Rec = mean(Post_Recruit), PR_SE = (sd(Post_Recruit)/(sqrt(sum(!is.na(Post_Recruit))))),
            Juvenile = mean(Juvenile), Juv_SE = (sd(Juvenile)/(sqrt(sum(!is.na(Juvenile))))), 
            SmallF = mean(Small.Females), SmallF_SE = (sd(Small.Females)/(sqrt(sum(!is.na(Small.Females))))),
            MatF = mean(Large.Females), MatF_SE = (sd(Large.Females)/(sqrt(sum(!is.na(Large.Females)))))) -> CPUE_by_strata

# just need total crab
dat3 %>%
  mutate(total_crab = Juvenile + Large.Females + Post_Recruit + Pre_Recruit + Recruit + Small.Females) %>% 
  group_by(Location, Year, Density.Strata.Code) %>%
  summarise(tot_crab = mean(total_crab), totc_SD = sd(total_crab)) -> total_CPUE_by_strata

## juneau area ---
total_CPUE_by_strata %>% 
  filter(Location == "Juneau") 


# mean and SD 3 year interval -------
dat3 %>%
  mutate(total_crab = Juvenile + Large.Females + Post_Recruit + Pre_Recruit + Recruit + Small.Females) %>% 
         ##interval = ifelse(Year < (cur_yr-3), 1, 2)) %>% 
  filter(Density.Strata.Code != 0) %>% 
  filter(Year >= cur_yr-3) %>% 
  group_by(Location, Density.Strata.Code) %>%
  summarise(tot_crab = mean(total_crab), totc_SD = sd(total_crab)) %>% 
  as.data.frame()-> yr_group_total_CPUE_by_strata

# Allocation 3 yrs ------
yr_group_total_CPUE_by_strata %>% 
  #filter(interval == 2) %>% 
  left_join(area) %>% 
  mutate(km_SD = totc_SD*Area)

# perform allocation by area all together ---
yr_group_total_CPUE_by_strata %>% 
  #filter(interval ==2) %>% 
  left_join(area) %>% 
  mutate(km_SD = totc_SD*Area) %>% 
  group_by(Location) %>% 
  mutate(allocate_pot_52 = round(52*km_SD/ sum(km_SD), 0)) %>% 
  mutate(allocate_pot_78 = round(78*km_SD/ sum(km_SD), 0)) -> allocation_2022_survey
write.csv(allocation_2022_survey, paste0('results/',cur_yr, '_pot_allocation_rkcs.csv'), row.names = FALSE) # use this to put into the allocation spreadsheet. 
# These will be adjusted due to minimum, etc.   **fix** add rules here (see Excel sheet)


## allocation on mature males ---------------
dat3 %>%
  mutate(male_crab = Post_Recruit + Pre_Recruit + Recruit) %>% 
  group_by(Location, Year, Density.Strata.Code) %>%
  summarise(mmale_crab = mean(male_crab), totc_SD = sd(male_crab)) -> male_CPUE_by_strata

## juneau area ---
male_CPUE_by_strata %>% 
  filter(Location == "Juneau") 


# mean and SD 3 year interval -------
dat3 %>%
  mutate(male_crab = Post_Recruit + Pre_Recruit + Recruit) %>% 
  ##interval = ifelse(Year < (cur_yr-3), 1, 2)) %>% 
  filter(Density.Strata.Code != 0) %>% 
  filter(Year >= cur_yr-3) %>% 
  group_by(Location, Density.Strata.Code) %>%
  summarise(mmale_crab = mean(male_crab), totc_SD = sd(male_crab)) %>% 
  as.data.frame()-> yr_group_male_CPUE_by_strata

# Allocation 3 yrs ------
yr_group_male_CPUE_by_strata %>% 
  #filter(interval == 2) %>% 
  left_join(area) %>% 
  mutate(km_SD = totc_SD*Area)

# perform allocation by area all together ---
yr_group_male_CPUE_by_strata %>% 
  #filter(interval ==2) %>% 
  left_join(area) %>% 
  mutate(km_SD = totc_SD*Area) %>% 
  group_by(Location) %>% 
  mutate(allocate_pot_52 = round(52*km_SD/ sum(km_SD), 0)) %>% 
  mutate(allocate_pot_78 = round(78*km_SD/ sum(km_SD), 0)) -> allocation_2022_survey_MM
write.csv(allocation_2022_survey_MM, paste0('results/',cur_yr, '_mature_male_pot_allocation_rkcs.csv'), row.names = FALSE) # use this to put into the allocation spreadsheet. 
# These will be adjusted due to minimum, etc.   **fix** add rules here (see Excel sheet)
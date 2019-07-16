# script to determine pot allocation by strata for the Southeast Tanner crab survey
# uses the mean and sd by strata for using Neymann allocation of pots. 

# K.Palof
# katie.palof@alaska.gove
# 9-27-2018

# load ----
library(tidyverse)
library(reshape2)

cur_yr <- 2018
# data ----
# from crab data processing project
dat <- read.csv("C:/Users/kjpalof/Documents/R projects/crab_data_processing/data/TCS/tanner crab survey for CSA_13_18.csv")
 # output for OceanAK from tanner crab surveys, detailed crab pot info
area <- read.csv("./data/TCSstrata_area_allocation.csv")

# clean up data -----
levels(dat$Pot.Condition)
dat %>%
  filter(Pot.Condition == "Normal"|Pot.Condition == "Not observed") -> dat1
dat1 %>%
  filter(Location != "Port Camden") %>% 
  filter(Location != "Stephens Passage")-> dat1

dat1 %>%
  #filter(!is.na(Width.Millimeters)) %>%  # lots of hoops to jump through so that NA come out as missing and not NA
  mutate(mod_recruit = ifelse(Number.Of.Specimens ==0, 'No_crab', 
                        ifelse(Sex.Code ==1 & Width.Millimeters <110 & !is.na(Width.Millimeters),
                          'Juvenile', ifelse(Sex.Code ==1 & Width.Millimeters>109 & 
                            Width.Millimeters < 138 & !is.na(Width.Millimeters),'Pre_Recruit', 
                             ifelse(Sex.Code ==1 & Width.Millimeters > 137 & Width.Millimeters <170 &
                              !is.na(Width.Millimeters)& Shell.Condition.Code <4, 'Recruit',
                               ifelse((Sex.Code ==1 & !is.na(Width.Millimeters)) &
                                Width.Millimeters >169|(Shell.Condition.Code >3 & 
                                 Width.Millimeters >137 & !is.na(Width.Millimeters)), 'Post_Recruit', 
                                  ifelse(Sex.Code ==2 & Egg.Development.Code==4 & 
                                   !is.na(Egg.Development.Code), 'Small.Females', 
                                    ifelse(Sex.Code ==2 & Width.Millimeters>0 & 
                                     !is.na(Width.Millimeters), 'Large.Females', 
                                      ifelse(is.na(Width.Millimeters), 'Missing', 
                                             'Missing'))))))))) -> Tdat1
Tdat1 %>%
  group_by(Year, Location, Pot.No, Density.Strata.Code,mod_recruit) %>% 
  summarise(crab = sum(Number.Of.Specimens)) -> dat2
dat3 <- dcast(dat2, Year + Location + Pot.No + Density.Strata.Code ~ mod_recruit, sum, drop=TRUE)


# mean and SD by strata by year ---------
dat3 %>%
  group_by(Location, Year, Density.Strata.Code) %>%
  summarise(Pre_Rec = mean(Pre_Recruit), PreR_SE = (sd(Pre_Recruit)/(sqrt(sum(!is.na(Pre_Recruit))))), 
            Rec = mean(Recruit), Rec_SE = (sd(Recruit)/(sqrt(sum(!is.na(Recruit))))), 
            Post_Rec = mean(Post_Recruit), PR_SE = (sd(Post_Recruit)/(sqrt(sum(!is.na(Post_Recruit))))),
            Juvenile_wt = mean(Juvenile), Juv_SE = (sd(Juvenile)/(sqrt(sum(!is.na(Juvenile))))), 
            SmallF_wt = mean(Small.Females), SmallF_SE = (sd(Small.Females)/(sqrt(sum(!is.na(Small.Females))))),
            MatF_wt = mean(Large.Females), MatF_SE = (sd(Large.Females)/(sqrt(sum(!is.na(Large.Females)))))) -> CPUE_by_strata
# just need total crab
dat3 %>%
  mutate(total_crab = Juvenile + Large.Females + Post_Recruit + Pre_Recruit + Recruit + Small.Females) %>% 
  group_by(Location, Year, Density.Strata.Code) %>%
  summarise(tot_crab = mean(total_crab), totc_SD = sd(total_crab)) -> total_CPUE_by_strata

# mean and SD 3 year interval -------
dat3 %>%
  mutate(total_crab = Juvenile + Large.Females + Post_Recruit + Pre_Recruit + Recruit + Small.Females, 
         interval = ifelse(Year < 2016, 1, 2)) %>% 
  filter(Density.Strata.Code != 0) %>% 
  group_by(Location, interval, Density.Strata.Code) %>%
  summarise(tot_crab = mean(total_crab), totc_SD = sd(total_crab)) -> yr_group_total_CPUE_by_strata


# Allocation 3 yrs ------
yr_group_total_CPUE_by_strata %>% 
  filter(interval == 2) %>% 
  left_join(area) %>% 
  mutate(km_SD = totc_SD*Area_km)

# perform allocation by area all together ---
yr_group_total_CPUE_by_strata %>% 
  filter(interval ==2) %>% 
  left_join(area) %>% 
  mutate(km_SD = totc_SD*Area_km) %>% 
  group_by(Location) %>% 
  mutate(allocate_pot_52 = round(52*km_SD/ sum(km_SD), 0)) %>% 
  mutate(allocate_pot_78 = round(78*km_SD/ sum(km_SD), 0)) -> allocation_2019_survey
write.csv(allocation_2019_survey, paste0('results/',cur_yr, '_pot_allocation.csv'), row.names = FALSE) # use this to put into the allocation spreadsheet. 
# These will be adjusted due to minimum, etc.   **fix** add rules here (see Excel sheet)

  
  
# Glacier Bay pots from 2016-2018
yr_group_total_CPUE_by_strata %>% 
  filter(interval == 2 & Location == "Glacier Bay") %>% 
  left_join(area) %>% 
  mutate(km_SD = totc_SD*Area_km) %>% 
  mutate(allocate_pot = round(52*km_SD/ sum(km_SD), 0)) 

# Icy Strait pots from 2016-2018
yr_group_total_CPUE_by_strata %>% 
  filter(interval == 2 & Location == "Icy Strait") %>% 
  left_join(area) %>% 
  mutate(km_SD = totc_SD*Area_km) %>% 
  mutate(allocate_pot = round(52*km_SD/ sum(km_SD), 0))

# Thomas Bay pots from 2016-2018
yr_group_total_CPUE_by_strata %>% 
  filter(interval == 2 & Location == "Thomas Bay") %>% 
  left_join(area) %>% 
  mutate(km_SD = totc_SD*Area_km) %>% 
  mutate(allocate_pot = round(52*km_SD/ sum(km_SD), 0))

# Holkham pots from 2016-2018
yr_group_total_CPUE_by_strata %>% 
  filter(interval == 2 & Location == "Holkham Bay") %>% 
  left_join(area) %>% 
  mutate(km_SD = totc_SD*Area_km) %>% 
  mutate(allocate_pot = round(78*km_SD/ sum(km_SD), 0))

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
dat <- read.csv("C:/Users/kjpalof/Documents/R projects/crab_data_processing/data/TCS/tanner crab survey for CSA_13_18.csv")
# output for OceanAK from tanner crab surveys, detailed crab pot info
area <- read.csv("./data/TCSstrata_area_allocation.csv")
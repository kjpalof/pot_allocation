# pot_allocation
determine pot allocation for each strata in the southeast crab surveys - currently performed every 3 to 5 years.

#Pot allocation.
Prior to 2012 pots were re-allocated annually based on the previous years results of CPUE and SD by strata.  In 2012 it was determined that these allocations would be based on multiple years of data and re-allocated every 3 years.  In 2015 re-allocation was performed based on the CPUE of total crab/ SD by strata using the average of the CPUE and SD from 2012, 2013, and 2014.  
The same basic procedure was used in 2018.  Additional guidance on pot allocations after the intial Neyman allocation is provided below.

##2018 pot allocation instructions for red king crab:
1. Calculate total crab CPUE and SD by strata for 2015, 2016, and 2017 for each area.  Take an average of these values and put them in columns E and F on "Allocate_totalcrab" tab.
2. Equations in the spreadsheet should assign the number of pots per strata based on the Neyman Allocation (column G, references calculations done in column W).
3. Round allocation to whole numbers (column H), default in Excel is to round up but may need to round down to get desired number of total pots.  
4. Assign number of pots to each strats - column S- 2018 pots allocation.
	a. Minimium number of pots per strata is 3, to ensure adequate data collection for future years.
	b. Adjust minimium to 3.  
	c. To keep the same total pots per area, take away pots from larger allocations - based on area covered (column I), and ensuring that the majority of pots >60% are still placed 		in stratas 4 and 5. 
5. Final allocation numbers for 2018 are in red in column S

## 2023 pot allocation instructions for tanner crab:
1. Calculated allocation using R script - tanner_allocation.R
2. Output results to .csv
3. Open .csv in excel and same as excel sheeet under "excel" folder
3. Adjust allocation based on some of above:
  a. Minimium number of pots per strata is 3, to ensure adequate data collection for future years.
	b. Adjust minimium to 3.  
	c. To keep the same total pots per area, take away pots from larger allocations - and ensuring that the majority of pots > 60% are still placed in stratas 3, 4 and 5.  
	
Final results in "/excel files/2023tanner_pot_allocation.xlsx"
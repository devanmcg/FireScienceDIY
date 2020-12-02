pacman::p_load(tidyverse, readxl)

wx_fp = "./data/fromMZ/Fire_Behavior_Weather_All.xlsx"

# see if names are the same across worksheets
for(i in 1:length(excel_sheets(wx_fp))) {
  ws = excel_sheets(wx_fp)[i]
  read_xlsx(wx_fp, ws) %>%
    names %>%
    print
}

wx_d <- tibble() 

for(i in 1:length(excel_sheets(wx_fp))) {
  ws = excel_sheets(wx_fp)[i]
  read_xlsx(wx_fp, ws) %>%
    select(Station, Year, Month, Day, Hour, 
           dbC, RH, mean_mph, deg, lys, dpF) %>%
    bind_rows(wx_d) -> wx_d
}


WriteXLS::WriteXLS(c('wx_d'), 
         "./data/fromMZ/weather.xlsx") 

# Get 2019 fuel moisture data 

  fp_19 = "./fromMZ/2019_FuelMoistureData.xlsx"
  
  read_xlsx(fp_19, "CGREC") %>%
    separate(Ps.Pa.Sbp, c("pasture", "patch", "subpatch")) %>%
    select(-LAI1, -LAI2) %>%
    filter(!arrayID %in% c(4, 5) ) %>% 
      write_csv("data/fromMZ/CGREC_2019_fuels.csv")

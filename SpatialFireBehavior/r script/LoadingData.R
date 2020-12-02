pacman::p_load(tidyverse, readxl)

wd_fp = "C:/Users/Devan.McGranahan/GoogleDrive/rangeR/rangeR/SpatialFireBehavior/data/"

xl_fp = paste0(wd_fp, "/AllLocations.xlsx")

# Thermocouple data 
temps <- 
  read_csv(paste0(wd_fp, "ThermocoupleData.csv")) %>%
  filter(tempC != is.na(.)) %>%
    mutate(time = str_remove(time, "[.]+[0-9]"))%>%
    unite(timestamp, c(date, time), sep = " ") %>%
  mutate(timestamp = as.POSIXct(timestamp, format = "%m-%d-%Y %H:%M:%S")) %>%
    mutate(L = str_remove(location, "REC"), 
           B = str_sub(block, 1,3), 
           Ps = str_replace(pasture, "[.]", ""), 
           Ps = str_sub(Ps, 1,2), 
           y = format(timestamp, "%y"),
           problematic = as.character(problematic)) %>%
    unite("FireCode", c(L,B,Ps,patch,y), sep=".") %>%
    filter(is.na(problematic) ) %>%
    select(FireCode, timestamp, location, block, plot, array, 
           TC, tempC) 

# save(temps, file="./r objects/temps.Rdata")

# Fuels data 
fuels <- 
  read_xlsx(xl_fp, "fuels") %>%
    mutate(date = paste(str_sub(date, 1,4), 
                        str_sub(date, 5,6),
                        str_sub(date, 7,8),
                        sep='-'), 
           date = as.Date(date)) %>%
    bind_rows(read_csv(paste0(wd_fp, "fromMZ/CGREC_2019_fuels.csv"))) %>%
    filter(location != "Oakville") %>%
    mutate(L = str_remove(location, "REC"), 
           B = str_sub(block, 1,3), 
           Ps = str_replace(pasture, "[.]", ""), 
           Ps = str_sub(Ps, 1,2), 
           y = format(date, "%y")) %>%
    unite("FireCode", c(L,B,Ps,patch,y), sep=".") %>%
    select(FireCode, date, location, block, plot, array, 
           sample, LAI, SoilMoisture, FuelMoisture, burned)

# save(fuels, file="./r objects/fuels.Rdata")

# Weather data 

BurnIDs <- 
  read_xlsx(xl_fp, "UniqueCodes") %>%
    select(id) %>%
  filter(id != is.na(.))

# save(BurnIDs, file="./r objects/BurnIDs.Rdata")

FireHours <- 
  temps %>% 
    filter(FireCode %in% c(BurnIDs$id)) %>%
      mutate(DayHour = format(timestamp, "%Y-%d-%m %H")) %>%
      select(location, DayHour) %>%
      group_by(location, DayHour) %>%
      slice(1) %>%
      unite(BurnHourID, c(location, DayHour), sep="_")

wx_d <- 
  read_xlsx(xl_fp, "weather") %>%
    rename(location = Station) %>% 
    mutate(location = recode(location, Streeter = 'CGREC', 
                             Hettinger = 'HREC'),
           Hour = Hour/100, 
           Month = str_pad(Month, 2, pad="0"), 
           Day = str_pad(Day, 2, pad="0")) %>%
    unite(date, c(Year, Day, Month), sep = "-") %>%
    unite(DayHour, c(date, Hour), sep=" ") %>%
    unite(BurnHourID, c(location, DayHour), sep="_") %>%
    filter(BurnHourID %in% FireHours$BurnHourID) 

# save(wx_d, file="./r objects/wx_d.Rdata")
    

    

    
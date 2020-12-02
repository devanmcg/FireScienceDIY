pacman::p_load(tidyverse)

load("./r objects/wx_d.Rdata")
load("./r objects/ROS.Rdata")
load("./r objects/fuels.Rdata")

# Summarize to array scale 

  fuels_sum <- 
    fuels %>%
      select(-date, -location, -block, -burned) %>%
      pivot_longer(cols = (LAI:FuelMoisture), 
                   names_to = "response", 
                   values_to = "value") %>%
      group_by(FireCode, plot, array, response) %>%
        summarize(value = mean(value)) %>%
      ungroup() %>%
      pivot_wider(names_from = response, 
                  values_from = value)

# Summarize & bring in weather data by the hour 

  DataCombined <- 
    temps %>% 
    group_by(FireCode,location, plot, array) %>%
    summarize(timestamp = mean(timestamp), 
              tempC = mean(tempC)) %>%
    ungroup() %>%
    mutate(DayHour = format(timestamp, "%Y-%d-%m %H")) %>% 
    unite(BurnHourID, c(location, DayHour), sep='_') %>%
    select(-timestamp) %>%
    left_join(wx_d, 
              by = 'BurnHourID')%>%
    left_join(fuels_sum, 
              by = c('FireCode', 'plot', 'array')) %>%
    select(-BurnHourID) %>%
    left_join(ROS, 
              by = c('FireCode', 'plot', 'array')) %>%
    separate(FireCode, c('location','block','pasture','patch','year'))

  # save(DataCombined, file="./data/DataCombined.Rdata")


  

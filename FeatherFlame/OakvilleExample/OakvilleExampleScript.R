pacman::p_load(tidyverse, magrittr, lubridate)

DataDir = "C:/Users/Devan.McGranahan/GoogleDrive/FireScienceDIY/data/OakvilleRaw"

files <- list.files(path=DataDir, pattern=".TXT$")

oak_d <- tibble() 

for(i in 1:length(files)) {
  oak_d <-
    file.path(paste(DataDir, "/", files[i], sep="")) %>%
    read_csv(col_types = cols(.default = "c"), 
             col_names = FALSE )  %>%
    gather("tc","temp", -X1, -X2) %>%
    setNames(c("logger","timestamp","tc","temp")) %>%
    mutate(tc = case_when(
              tc == "X3" ~ "1", 
              tc == "X4" ~ "2", 
              tc == "X5" ~ "3", 
              tc == "X6" ~ "4", 
              tc == "X7" ~ "5", 
              tc == "X8" ~ "6", 
              tc == "X9" ~ "7")) %>%
    filter(temp != "nan") %>%
    bind_rows(., oak_d)
}

oak_d %<>%
  mutate(timestamp = as.POSIXct(timestamp, 
                                format = "%Y-%m-%d %H:%M:%OS"), 
         temp = as.numeric(temp)) %>%
  group_by(logger, tc, timestamp) %>%
  summarize(temp = max(temp)) %>%
  ungroup

oak_d %<>% filter(hour(timestamp) >= 18, 
                  day(timestamp) == 25) %>%
            mutate(logger = case_when(
              logger == "4" ~ "3", 
              logger == "5" ~ "4", 
              logger == "7" ~ "5", 
              logger == "8" ~ "6", 
              TRUE ~ logger
            ))

oak_d %<>%
    filter(temp >= 20, 
           hour(timestamp) <= 18.5,
           tc != "5")

save(oak_d, file="./data/oak_d.Rdata")

source("C:/Users/Devan.McGranahan/GoogleDrive/Computer stuff/code snippets/custom functions/fmt_dcimals.R")  




  
    

  

